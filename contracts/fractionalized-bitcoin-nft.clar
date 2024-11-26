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
(define-constant ERR-INVALID-UTXO-ID (err u6))
(define-constant ERR-INVALID-BITCOIN-ADDRESS (err u7))

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

;; Create a fractionalized Bitcoin NFT
(define-public (create-bitcoin-fraction 
  (utxo-id (string-ascii 64))
  (bitcoin-address (string-ascii 35))
  (original-value uint)
  (total-fractions uint)
)
  (begin
    ;; Validate input
    (asserts! (is-valid-utxo-id utxo-id) ERR-INVALID-UTXO-ID)
    (asserts! (is-valid-bitcoin-address bitcoin-address) ERR-INVALID-BITCOIN-ADDRESS)
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
      (nft-mint? bitcoin-fraction 
        (unwrap! (some utxo-id) ERR-INVALID-UTXO-ID) 
        tx-sender
      )
    )

    (ok true)
  )
)

;; Transfer a fraction of the Bitcoin NFT
(define-public (transfer-bitcoin-fraction
  (utxo-id (string-ascii 64))
  (new-owner principal)
  (fraction-amount uint)
)
  (let 
    (
      (utxo-details 
        (unwrap! 
          (map-get? bitcoin-utxo-details { utxo-id: utxo-id }) 
          ERR-INVALID-FRACTIONS
        )
    )
    )
    ;; Validate input
    (asserts! (is-valid-utxo-id utxo-id) ERR-INVALID-UTXO-ID)
    
    ;; Validate transfer
    (asserts! (is-eq tx-sender (get owner utxo-details)) ERR-NOT-OWNER)
    (asserts! (> fraction-amount u0) ERR-INVALID-FRACTIONS)
    
    ;; Update ownership details
    (map-set bitcoin-utxo-details 
      { utxo-id: utxo-id }
      (merge utxo-details { owner: new-owner })
    )

    (try! 
      (nft-transfer? bitcoin-fraction 
        (unwrap! (some utxo-id) ERR-INVALID-UTXO-ID) 
        tx-sender 
        new-owner
      )
    )

    (ok true)
  )
)

;; Unlock and burn fractionalized Bitcoin NFT
(define-public (burn-bitcoin-fraction
  (utxo-id (string-ascii 64))
)
  (let 
    (
      (utxo-details 
        (unwrap! 
          (map-get? bitcoin-utxo-details { utxo-id: utxo-id }) 
          ERR-INVALID-FRACTIONS
        )
    )
    )
    ;; Validate input
    (asserts! (is-valid-utxo-id utxo-id) ERR-INVALID-UTXO-ID)
    
    ;; Validate burn
    (asserts! (is-eq tx-sender (get owner utxo-details)) ERR-NOT-OWNER)

    ;; Burn NFT
    (try! 
      (nft-burn? bitcoin-fraction 
        (unwrap! (some utxo-id) ERR-INVALID-UTXO-ID) 
        tx-sender
      )
    )

    ;; Remove UTXO details and unlock
    (map-delete bitcoin-utxo-details { utxo-id: utxo-id })

    (ok true)
  )
)

;; Read-only function to get UTXO details
(define-read-only (get-utxo-details 
  (utxo-id (string-ascii 64))
)
  ;; Add validation before retrieving details
  (if (is-valid-utxo-id utxo-id)
    (map-get? bitcoin-utxo-details { utxo-id: utxo-id })
    none
  )
)

;; Utility function to validate UTXO ID
(define-private (is-valid-utxo-id (utxo-id (string-ascii 64)))
  (and 
    (> (len utxo-id) u0)
    (<= (len utxo-id) u64)
    ;; Optional: Add more specific validation if needed
    ;; For example, check for hexadecimal characters
    true
  )
)

;; Utility function to validate Bitcoin address
(define-private (is-valid-bitcoin-address (address (string-ascii 35)))
  (and 
    (or 
      ;; Supports both legacy and segwit addresses
      (and 
        (>= (len address) u26)
        (<= (len address) u35)
      )
      ;; You might want to add more specific address validation here
      false
    )
  )
)