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

;; data maps
(define-map bitcoin-utxo-details 
  { utxo-id: (string-ascii 64) }
  {
    total-fractions: uint,
    owner: principal,
    bitcoin-address: (string-ascii 35),
    original-value: uint,
    is-locked: bool
  }
)

;; public functions
(define-public (create-bitcoin-fraction 
  (utxo-id (string-ascii 64))
  (bitcoin-address (string-ascii 35))
  (original-value uint)
  (total-fractions uint)
)
  (begin
    ;; Validate input
    (asserts! (> total-fractions u0) ERR-INVALID-FRACTIONS)
    (asserts! (> original-value u0) ERR-INVALID-FRACTIONS)

    ;; Check if UTXO is already fractionalized
    (asserts! 
      (is-eq 
        (default-to false 
          (get is-locked 
            (map-get? bitcoin-utxo-details { utxo-id: utxo-id }))) 
        false
      ) 
      ERR-ALREADY-FRACTIONALIZED
    )

    ;; Store UTXO details
    (map-set bitcoin-utxo-details 
      { utxo-id: utxo-id }
      {
        total-fractions: total-fractions,
        owner: tx-sender,
        bitcoin-address: bitcoin-address,
        original-value: original-value,
        is-locked: true
      }
    )

    ;; Mint NFT fractions
    (try! 
      (nft-mint? bitcoin-fraction utxo-id tx-sender)
    )

    (ok true)
  )
)