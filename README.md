# Real World Asset Token Smart Contract

## Overview

This Clarity smart contract implements a comprehensive system for tokenizing real-world assets on the Stacks blockchain. It provides advanced features for asset management, token distribution, governance, and price feed integration.

## Key Features

1. Asset Registration and Management
2. Semi-Fungible Token (SFT) Implementation
3. Dividend Distribution System
4. Governance Proposal and Voting Mechanism
5. KYC (Know Your Customer) Integration
6. Price Feed Oracle Integration
7. Robust Input Validation and Error Handling

## Core Functions

### Asset Management

- `register-asset`: Register a new real-world asset
- `claim-dividends`: Claim dividends for a specific asset

### Governance

- `create-proposal`: Create a new governance proposal
- `vote`: Vote on an existing proposal

### Read-Only Functions

- `get-asset-info`: Retrieve information about a specific asset
- `get-balance`: Get the token balance of an address for a specific asset
- `get-proposal`: Retrieve details of a specific proposal
- `get-vote`: Get voting information for a specific proposal and voter
- `get-price-feed`: Retrieve price feed information for an asset
- `get-last-claim`: Get the last dividend claim amount for an address

## Data Structures

- `assets`: Stores metadata and state for each registered asset
- `token-balances`: Tracks token ownership for each asset
- `kyc-status`: Manages KYC approval status and levels for addresses
- `proposals`: Stores governance proposal details
- `votes`: Records votes cast on proposals
- `dividend-claims`: Tracks dividend claims for each asset and address
- `price-feeds`: Manages price feed data for assets

## Constants

- `MAX-ASSET-VALUE`: 1 trillion (1,000,000,000,000)
- `MIN-ASSET-VALUE`: 1 thousand (1,000)
- `MAX-DURATION`: ~1 day in blocks (144)
- `MIN-DURATION`: ~1 hour in blocks (12)
- `MAX-KYC-LEVEL`: 5
- `MAX-EXPIRY`: ~1 year in blocks (52,560)
- `tokens-per-asset`: 100,000 (number of SFTs per asset)

## Error Handling

The contract uses a comprehensive set of error codes for various scenarios, ensuring proper validation and error reporting. Some key error codes include:

- `err-owner-only`: Operation restricted to contract owner
- `err-not-found`: Requested item not found
- `err-invalid-amount`: Invalid token or value amount
- `err-not-authorized`: User not authorized for the operation
- `err-kyc-required`: KYC approval required for the operation

## Input Validation

The contract implements several helper functions for input validation:

- `validate-asset-value`: Ensures asset value is within allowed range
- `validate-duration`: Checks if proposal duration is valid
- `validate-kyc-level`: Verifies KYC level is within allowed range
- `validate-expiry`: Ensures expiry is set to a valid future block height
- `validate-minimum-votes`: Checks if minimum vote count is valid
- `validate-metadata-uri`: Verifies metadata URI length and format

## Usage

To use this contract, deploy it to the Stacks blockchain and interact with it using the provided public functions. Ensure that users have the necessary permissions and meet the required conditions (e.g., KYC approval) for their intended actions.

## Security Considerations

- Only the contract owner can register new assets
- KYC checks are implemented for certain operations
- Input validation is performed to prevent invalid data entry
- Proposal voting has minimum token holding requirements

## Note on Completeness

This README is based on the provided contract snippet. Some functionalities, such as KYC management and price feed updates, may not be fully represented here if they were not included in the provided code.
