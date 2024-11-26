;; title: Fractionalized Bitcoin NFT Smart Contract
;; summary: This smart contract allows the creation, transfer, and burning of fractionalized Bitcoin NFTs, enabling the tokenization of rare Bitcoin addresses or UTXOs.
;; description: The contract defines a non-fungible token (NFT) called `bitcoin-fraction` and a map to store details of fractionalized Bitcoin UTXOs. It includes public functions to create, transfer, and burn these NFTs, as well as a read-only function to retrieve UTXO details. The contract ensures proper validation and error handling for operations involving fractionalized Bitcoin NFTs.

;; token definitions
(define-non-fungible-token bitcoin-fraction (string-ascii 64))

;; constants
(define-constant ERR-NOT-OWNER (err u1))
(define-constant ERR-INVALID-FRACTIONS (err u2))
(define-constant ERR-ALREADY-FRACTIONALIZED (err u3))
(define-constant ERR-INSUFFICIENT-FRACTIONS (err u4))
(define-constant ERR-UTXO-LOCKED (err u5))