---
name: shared-versioning
description: Reusable version-check module for SunX skills.
metadata:
  version: 1.10.2
  author: SunX
license: MIT
---

## Changelog
- `升级测试1`
- `升级测试2`
- `升级测试3`

# Shared Versioning Module for SunX Skills

This module provides a reusable version-check flow for SunX skills.

## Placement

Place the files in the following directories:

- `sunx/_shared/versioning/check_skill_version.sh`
- `sunx/_shared/versioning/version-check.conf`
- `sunx/_shared/versioning/README.md`

For the SunX DEX skill itself:

- `sunx/sunx-dex/SKILL.md`

## Recommended Structure

```text
sunx/
├── _shared/
│   └── versioning/
│       ├── check_skill_version.sh
│       ├── version-check.conf
│       └── README.md
└── sunx-dex/
    └── SKILL.md
```

## What the checker does

1. Reads `version-check.conf`
2. Stops immediately when version checking is disabled
3. Skips checking if `MANUAL_UPGRADE_ONLY="true"`
4. Skips checking if `LAST_CHECKED_DATE` is already today in UTC
5. Fetches remote `README.md` metadata from GitHub
6. Compares remote `metadata.version` against local `SKILL.md` `metadata.version`
7. Returns a JSON payload that the skill can interpret
8. Updates `LAST_CHECKED_DATE` after a real check

## Expected AI behavior

When the checker reports `needs_upgrade: true`, the skill should ask the user to choose one of the following:

1. **Upgrade now**
2. **Remind me later**
3. **I will manage upgrades manually**

If the user chooses **Upgrade now**, the AI should:

1. Go to the GitHub repository:
   - `https://github.com/SunX-DEX/sunx-skills-hub`
2. Refresh the local skill by re-downloading:
   - the latest `SKILL.md`
   - any supporting references if needed
3. Replace the local skill files
4. Re-invoke the same skill with the same original user request

If the user chooses **Remind me later**, the AI should continue the current task without changing the config.

If the user chooses **I will manage upgrades manually**, the AI should set:

```sh
MANUAL_UPGRADE_ONLY="true"
```

## Invocation example

Run the checker from inside a skill directory:

```sh
../_shared/versioning/check_skill_version.sh ../_shared/versioning/version-check.conf ./SKILL.md
```


## Notes

- The script uses only standard shell tooling and `curl`
- No Python, Node, jq, or extra SDK is required
- Keep the remote README frontmatter updated so the checker can compare versions reliably
