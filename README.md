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

This is a [crucible](https://github.com/uniteum/crucible) project — see crucible for development workflow, deployment, and shared configuration.

For comprehensive protocol documentation, see [CLAUDE.md](CLAUDE.md).
