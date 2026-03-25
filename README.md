# Lepton

Lepton is a minimalist fixed-supply ERC-20 token factory on Ethereum with deterministic deployment.

## Deployed Contracts

### Mainnet
- **Lepton (Proto-factory)**: [0x14ae57aed6ac1cd48fa811ed885ab4a4c5e28c42](https://etherscan.io/address/0x14ae57aed6ac1cd48fa811ed885ab4a4c5e28c42#code)

## Overview

Lepton is a token factory where:
- Calling `make(name, symbol, supply)` deploys a new ERC-20 token as an EIP-1167 minimal proxy clone
- The entire supply is minted to the caller — no inflation, no minting after creation
- Addresses are deterministic (CREATE2) — the same parameters always produce the same address
- `make` is idempotent — calling it again with the same parameters returns the existing token
- Permissionless — anyone can deploy a new token

For comprehensive documentation, see [CLAUDE.md](CLAUDE.md).

## Documentation

- [CLAUDE.md](CLAUDE.md) - Comprehensive protocol documentation
- [CONTRIBUTING.md](CONTRIBUTING.md) - Development and deployment
- [Foundry Book](https://book.getfoundry.sh/) - Foundry development framework

## Security

This codebase uses:
- Solidity 0.8.30+ with built-in overflow checks
- EIP-1167 minimal proxy clones for gas-efficient deployment
- Deterministic CREATE2 deployments

See [CLAUDE.md](CLAUDE.md) for detailed security considerations.
