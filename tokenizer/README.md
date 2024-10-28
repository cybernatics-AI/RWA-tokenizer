## Overview

The Real World Asset Tokenization Smart Contract enables the representation of physical assets (e.g., real estate, art, precious metals) as digital tokens. This contract introduces features like asset registration, dividend distribution, compliance via KYC checks, and voting-based governance. Tokenization allows fractional ownership, enabling smaller investors to invest in traditionally illiquid assets.

## Features

- **Asset Registration**: Register assets with metadata, value, and ownership details.
- **Fractional Ownership**: Assets are divided into smaller, tradeable tokens.
- **Dividend Distribution**: Distribute dividends to token holders based on ownership.
- **KYC Compliance**: Enforce KYC levels to ensure only verified addresses can hold assets.
- **Governance**: Implement on-chain voting for asset-related decisions.
- **Price Feed Integration**: Track asset prices and update them periodically.
  
## Contract Components

### Constants
- Define essential values like the maximum asset value, durations for proposals, and KYC levels.
- Include error codes for ease of debugging and user-friendly error handling.

### Data Maps
- `assets`: Stores asset details, including ownership, metadata, and valuation.
- `token-balances`: Manages token balances for each asset holder.
- `kyc-status`: Keeps track of KYC approval levels for participants.
- `proposals` and `votes`: Implements governance features, allowing token holders to create and vote on proposals.
- `dividend-claims`: Records dividend claims for individual asset holders.
- `price-feeds`: Maintains price data for assets.

### Helper Functions
- **Input Validators**: Ensure input values (e.g., asset value, duration) conform to specified criteria.
- **Utility Functions**: Retrieve asset and proposal IDs and verify KYC compliance.

## Functions

### Public Functions

- **Asset Management**
  - `register-asset(metadata-uri, asset-value)`: Registers a new asset, specifying metadata and valuation. Only the contract owner can register assets.
  - `claim-dividends(asset-id)`: Allows token holders to claim dividends based on their share of ownership.

- **Governance and Voting**
  - `create-proposal(asset-id, title, duration, minimum-votes)`: Creates a proposal for asset-related decisions. A minimum amount of tokens is required to participate.
  - `vote(proposal-id, vote-for, amount)`: Enables token holders to vote on proposals by committing a specific amount of tokens.

### Read-Only Functions

- `get-asset-info(asset-id)`: Retrieves detailed information about a specific asset.
- `get-balance(owner, asset-id)`: Checks the token balance of a particular owner for an asset.
- `get-proposal(proposal-id)`: Fetches details of a specific proposal.
- `get-price-feed(asset-id)`: Returns the current price information for an asset.

### Private Functions

- `get-next-asset-id()`, `get-next-proposal-id()`: Retrieve unique IDs for new assets or proposals.
- `validate-asset-value(value)`, `validate-duration(duration)`, etc.: Helper functions to validate input values, improving contract security and integrity.

## Setup and Deployment

1. **Prerequisites**: Ensure you have Clarity tools and a testnet wallet setup.
2. **Compilation**: Compile the contract using a Clarity-compatible development environment.
3. **Deployment**: Deploy the contract to the Stacks testnet or mainnet with a wallet holding enough STX for deployment fees.
4. **Post-deployment Configuration**: Configure price feeds and KYC information for users as needed.


## Error Codes

| Code                  | Meaning                           |
|-----------------------|-----------------------------------|
| `err-owner-only`      | Only the contract owner can execute this action |
| `err-not-found`       | Asset or proposal not found      |
| `err-already-listed`  | Asset is already registered      |
| `err-invalid-amount`  | Invalid amount specified         |
| `err-not-authorized`  | Action requires additional permissions |
| `err-kyc-required`    | KYC verification required        |
| `err-invalid-duration`| Duration exceeds limits          |
| `err-invalid-votes`   | Minimum votes not met            |

-- Author: Amobi Ndubuisi
