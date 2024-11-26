# Fractionalized Bitcoin NFT Smart Contract

## Overview

This Clarity smart contract enables the creation, transfer, and burning of fractionalized Bitcoin Non-Fungible Tokens (NFTs). It allows users to tokenize rare Bitcoin addresses or Unspent Transaction Outputs (UTXOs), providing a novel way to represent and trade fractional ownership of Bitcoin assets.

## Features

- Create fractionalized NFTs from Bitcoin UTXOs
- Transfer ownership of NFT fractions
- Burn (unlock) fractionalized NFTs
- Retrieve UTXO details
- Robust input validation and error handling

## Contract Functions

### 1. `create-bitcoin-fraction`

Creates a new fractionalized Bitcoin NFT.

**Parameters:**

- `utxo-id`: Unique identifier for the UTXO (64-character ASCII string)
- `bitcoin-address`: Bitcoin address associated with the UTXO (35-character ASCII string)
- `original-value`: Original value of the UTXO
- `total-fractions`: Number of fractions to create

**Validations:**

- Ensures valid UTXO ID and Bitcoin address
- Checks that fractions and original value are greater than zero
- Prevents re-fractionalization of an already locked UTXO

### 2. `transfer-bitcoin-fraction`

Transfers ownership of a fraction of the Bitcoin NFT.

**Parameters:**

- `utxo-id`: Unique identifier of the UTXO
- `new-owner`: Principal (address) receiving the fraction
- `fraction-amount`: Number of fractions to transfer

**Validations:**

- Verifies the sender is the current owner
- Ensures valid fraction amount

### 3. `burn-bitcoin-fraction`

Unlocks and burns a fractionalized Bitcoin NFT.

**Parameters:**

- `utxo-id`: Unique identifier of the UTXO to burn

**Validations:**

- Confirms the sender is the current owner
- Removes UTXO details from the contract

### 4. `get-utxo-details`

Read-only function to retrieve UTXO details.

**Parameters:**

- `utxo-id`: Unique identifier of the UTXO

**Returns:** Details of the specified UTXO or `none`

## Error Handling

The contract defines several custom error constants:

- `ERR-NOT-OWNER`: Unauthorized transfer or burn attempt
- `ERR-INVALID-FRACTIONS`: Invalid fraction count or value
- `ERR-ALREADY-FRACTIONALIZED`: Attempting to fractionalize an already locked UTXO
- `ERR-INSUFFICIENT-FRACTIONS`: Insufficient fractions for transfer
- `ERR-UTXO-LOCKED`: UTXO is currently locked
- `ERR-INVALID-UTXO-ID`: Invalid UTXO identifier
- `ERR-INVALID-BITCOIN-ADDRESS`: Invalid Bitcoin address format

## Data Storage

Utilizes a `bitcoin-utxo-details` map to store:

- Total fractions
- Owner principal
- Bitcoin address
- Original UTXO value
- Lock status

## Utility Functions

- `is-valid-utxo-id`: Validates UTXO ID length
- `is-valid-bitcoin-address`: Validates Bitcoin address format

## Security Considerations

- Strict ownership checks
- Input validation for all operations
- Prevents re-fractionalization of UTXOs
- Ensures proper UTXO management

## Deployment and Usage

### Requirements

- Clarinet development environment
- Stacks blockchain compatible wallet

### Deployment Steps

1. Install Clarinet
2. Configure your project
3. Deploy the contract using Clarinet or Stacks CLI

### Example Workflow

1. Create a Bitcoin fraction NFT
2. Transfer fractions between principals
3. Burn (unlock) the NFT when needed

## Limitations and Future Improvements

- Enhance Bitcoin address validation
- Add more granular fraction transfer mechanisms
- Implement additional access control features
