#!/bin/sh
# Placement: sunx/_shared/versioning/check_skill_version.sh
# Purpose: Generic version-check helper for any SunX skill.
# Dependencies: POSIX sh + curl + grep + sed + awk + date + mkdir + cp + mv

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEFAULT_CONFIG_FILE="$SCRIPT_DIR/version-check.conf"

CONFIG_FILE="${1:-$DEFAULT_CONFIG_FILE}"
TARGET_SKILL_FILE="${2:-}"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "{\"status\":\"error\",\"message\":\"Config file not found: $CONFIG_FILE\"}"
  exit 1
fi

# shellcheck disable=SC1090
. "$CONFIG_FILE"

if [ -z "${TARGET_SKILL_FILE}" ]; then
  TARGET_SKILL_FILE="${LOCAL_SKILL_FILE:-}"
fi

if [ -z "${TARGET_SKILL_FILE}" ]; then
  echo "{\"status\":\"error\",\"message\":\"LOCAL_SKILL_FILE is not set and no target skill file argument was provided.\"}"
  exit 1
fi

if [ ! -f "$TARGET_SKILL_FILE" ]; then
  echo "{\"status\":\"error\",\"message\":\"Local skill file not found: $TARGET_SKILL_FILE\"}"
  exit 1
fi

if [ "${ENABLE_VERSION_CHECK:-true}" != "true" ]; then
  echo "{\"status\":\"ok\",\"check_enabled\":false,\"should_check\":false,\"needs_upgrade\":false,\"message\":\"Version check is disabled by config.\"}"
  exit 0
fi

TODAY_UTC=$(date -u +%F)

if [ "${MANUAL_UPGRADE_ONLY:-false}" = "true" ]; then
  echo "{\"status\":\"ok\",\"check_enabled\":true,\"should_check\":false,\"needs_upgrade\":false,\"message\":\"Manual upgrade mode is enabled.\"}"
  exit 0
fi

if [ "${LAST_CHECKED_DATE:-}" = "$TODAY_UTC" ]; then
  echo "{\"status\":\"ok\",\"check_enabled\":true,\"should_check\":false,\"needs_upgrade\":false,\"message\":\"Already checked today.\",\"last_checked_date\":\"$TODAY_UTC\"}"
  exit 0
fi

if [ -z "${GITHUB_REPO_URL:-}" ] || [ -z "${REMOTE_BRANCH:-}" ] || [ -z "${REMOTE_METADATA_PATH:-}" ]; then
  echo "{\"status\":\"error\",\"message\":\"GITHUB_REPO_URL, REMOTE_BRANCH, and REMOTE_METADATA_PATH must be set in config.\"}"
  exit 1
fi

normalize_repo() {
  printf '%s' "$1" | sed 's#/$##' | sed 's#\.git$##'
}

repo_no_suffix=$(normalize_repo "$GITHUB_REPO_URL")
repo_path=$(printf '%s' "$repo_no_suffix" | sed 's#^https\{0,1\}://github\.com/##')
raw_base="https://raw.githubusercontent.com/$repo_path/$REMOTE_BRANCH"

remote_metadata_url="$raw_base/$REMOTE_METADATA_PATH"

fetch_remote_file() {
  url="$1"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url"
  else
    return 1
  fi
}

extract_version() {
  awk '
    /^metadata:/ { in_metadata=1; next }
    in_metadata && /^[^[:space:]]/ { in_metadata=0 }
    in_metadata && /^[[:space:]]*version:[[:space:]]*/ {
      sub(/^[[:space:]]*version:[[:space:]]*/, "", $0)
      gsub(/"/, "", $0)
      gsub(/'\''/, "", $0)
      print $0
      exit
    }
  ' "$1"
}

extract_release_summary() {
  awk '
    BEGIN { capture=0; count=0 }
    /^##[[:space:]]+(Release Summary|What.s New|Changelog)/ {
      capture=1
      next
    }
    capture && /^##[[:space:]]+/ { exit }
    capture {
      if (count < 12) {
        line=$0
        gsub(/\r/, "", line)
        print line
        count++
      }
    }
  ' "$1"
}

json_escape() {
  awk 'BEGIN { ORS="" }
  {
    gsub(/\\/,"\\\\")
    gsub(/"/,"\\\"")
    gsub(/\t/,"\\t")
    printf "%s\\n", $0
  }' "$1" | sed 's/\\n$//'
}

tmp_dir="${TMPDIR:-/tmp}/sunx-skill-version-check.$$"
mkdir -p "$tmp_dir"
trap 'rm -rf "$tmp_dir"' EXIT INT TERM

remote_tmp="$tmp_dir/remote_metadata.md"
local_tmp="$tmp_dir/local_skill.md"
summary_tmp="$tmp_dir/release_summary.txt"

cp "$TARGET_SKILL_FILE" "$local_tmp"

if ! fetch_remote_file "$remote_metadata_url" > "$remote_tmp"; then
  echo "{\"status\":\"error\",\"message\":\"Failed to fetch remote metadata from $remote_metadata_url\"}"
  exit 1
fi

local_version=$(extract_version "$local_tmp" || true)
remote_version=$(extract_version "$remote_tmp" || true)

if [ -z "$local_version" ]; then
  echo "{\"status\":\"error\",\"message\":\"Could not parse local metadata.version from $TARGET_SKILL_FILE\"}"
  exit 1
fi

if [ -z "$remote_version" ]; then
  echo "{\"status\":\"error\",\"message\":\"Could not parse remote metadata.version from $remote_metadata_url\"}"
  exit 1
fi

extract_release_summary "$remote_tmp" > "$summary_tmp" || true
summary_escaped=$(json_escape "$summary_tmp")

needs_upgrade=false
if [ "$local_version" != "$remote_version" ]; then
  needs_upgrade=true
fi

tmp_config="$tmp_dir/version-check.conf.tmp"
awk -v today="$TODAY_UTC" '
  BEGIN { updated=0 }
  /^LAST_CHECKED_DATE=/ {
    print "LAST_CHECKED_DATE=\"" today "\""
    updated=1
    next
  }
  { print }
  END {
    if (updated == 0) {
      print "LAST_CHECKED_DATE=\"" today "\""
    }
  }
' "$CONFIG_FILE" > "$tmp_config"
mv "$tmp_config" "$CONFIG_FILE"

printf '{'
printf '"status":"ok",'
printf '"check_enabled":true,'
printf '"should_check":true,'
printf '"needs_upgrade":%s,' "$needs_upgrade"
printf '"local_version":"%s",' "$local_version"
printf '"remote_version":"%s",' "$remote_version"
printf '"remote_metadata_url":"%s",' "$remote_metadata_url"
printf '"repo_url":"%s",' "$repo_no_suffix"
printf '"release_summary":"%s",' "$summary_escaped"
printf '"last_checked_date":"%s"' "$TODAY_UTC"
printf '}\n'
