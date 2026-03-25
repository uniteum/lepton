# Contributing

## Quick Start

```bash
git clone git@github.com:uniteum/lepton.git
cd lepton
forge build
forge test
```

## Development

### Build

```bash
forge build
```

### Test

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv
```

### Format

```bash
forge fmt
```

## Deployment

Lepton is already deployed as a proto-factory at a deterministic address across chains. These instructions are only needed if deploying to a new chain.

### Environment Variables

Set these in your `.bashrc` or `.zshrc`:

```bash
# Required for deployment (keep secure!)
export tx_key=<YOUR_PRIVATE_WALLET_KEY>
export ETHERSCAN_API_KEY=<YOUR_ETHERSCAN_API_KEY>

# Chain selection
export chain=11155111  # Sepolia testnet
# export chain=1       # Ethereum mainnet
# export chain=8453    # Base
# export chain=137     # Polygon
```

Get your ETHERSCAN_API_KEY at [Etherscan](https://etherscan.io/myaccount).

### Deploy

```bash
forge script script/Lepton.s.sol -f $chain --private-key $tx_key --broadcast --verify --delay 10 --retries 10
```
