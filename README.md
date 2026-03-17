# SunX Skills

SunX is the first top-tier decentralized perpetual contract trading platform on the TRON blockchain, dedicated to providing users with an institutional-grade trading experience and ultimate asset security. By deeply integrating cross-chain liquidity, gas-free transactions, and intelligent risk control mechanisms, we are redefining efficient, convenient, and reliable DeFi derivatives trading.

## Available Skills

| Skill      | Description |
|------------|-------------|
| `sunx-dex` | Perpetual futures trading on SunX DEX including positions, leverage management, orders, and TP/SL strategies |

## Features

### SunX DEX (`sunx-dex`)
- **Basic Information**: Contract info, index prices, risk limits, funding rates, price limitations, multi-asset collateral support
- **Market Data**: Real-time market depth, K-line data, market overview, trade records, BBO data, mark price, premium index, estimated funding rate
- **Account Management**: Account balance queries, trading bill records, fee rate information
- **Trading**: Order placement (limit/market), batch orders, order cancellation, position closing at market price
- **Order Management**: Current orders query, execution details, order history, order information lookup, order limits
- **Position Management**: Current positions, leverage configuration, position mode (single-side/dual-side), risk limits, position limits
- **Wallet Operations**: Withdrawal requests, withdrawal confirmation, deposit & withdraw record queries
- **Risk Management**: cross margin modes, position mode switching, risk limit configuration

## Supported Markets

SunX DEX supports perpetual futures trading for major cryptocurrencies including:
- **Perpetual Contracts**: BTC-USDT, ETH-USDT, and other major perpetual contracts on TRON blockchain

## Prerequisites

All skills require SunX API credentials. You can obtain API keys from SunX platform.

**Required Permissions**:
- Read permission for market data and account queries
- Trade permission for order placement and cancellation
- Withdrawal permission (if using withdrawal features)

Recommended: create a `.env` file or use account configuration:

```bash
SUNX_API_KEY="your-api-key"
SUNX_SECRET_KEY="your-secret-key"
```

**Security warning**: Never commit API credentials to git (add `.env` to `.gitignore`) and never expose credentials in logs, screenshots, or chat messages.

## Installation

### Recommended

```bash
npx skills add https://github.com/SunX-DEX/sunx-skills-hub
```

Works with Claude Code, Cursor, Codex CLI, and OpenCode. Auto-detects your environment and installs accordingly.

## API Key Security Notice

**Production Usage** For stable and reliable production usage, you must provide your own API credentials by setting the following environment variables:

* `SUNX_API_KEY`
* `SUNX_SECRET_KEY`

You are solely responsible for the security, confidentiality, and proper management of your own API keys. We shall not be liable for any unauthorized access, asset loss, or damages resulting from improper key management on your part.

**Mainnet Trading Confirmation** When performing transactions on mainnet, the AI assistant will always ask for confirmation before executing orders. This is a safety feature to prevent accidental trades.

**Important Security Practices**:
- Use API keys with minimal required permissions
- Set IP whitelist restrictions when possible
- Never share your secret key
- Regularly rotate API keys
- Monitor account activity

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

SunX Skills is an informational tool only. SunX Skills and its outputs are provided to you on an "as is" and "as available" basis, without representation or warranty of any kind. It does not constitute investment, financial, trading or any other form of advice; represent a recommendation to buy, sell or hold any assets; guarantee the accuracy, timeliness or completeness of the data or analysis presented.

Your use of SunX Skills and any information provided in connection with this feature is at your own risk, and you are solely responsible for evaluating the information provided and for all trading decisions made by you. We do not endorse or guarantee any AI-generated information. Any AI-generated information or summary should not be solely relied on for decision making. AI-generated content may include or reflect information, views and opinions of third parties, and may also include errors, biases or outdated information.

We are not responsible for any losses or damages incurred as a result of your use of or reliance on the SunX Skills feature. We may modify or discontinue the SunX Skills feature at our discretion, and functionality may vary by region or user profile.

Digital asset prices are subject to high market risk and price volatility. The value of your investment may go down or up, and you may not get back the amount invested. You are solely responsible for your investment decisions and we are not liable for any losses you may incur. Past performance is not a reliable predictor of future performance. You should only invest in products you are familiar with and where you understand the risks. You should carefully consider your investment experience, financial situation, investment objectives and risk tolerance and consult an independent financial adviser prior to making any investment. This material should not be construed as advice.

## License

MIT
