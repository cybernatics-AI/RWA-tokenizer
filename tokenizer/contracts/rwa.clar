;; Real World Asset Token Contract
;; Implements a secure tokenization system for real-world assets

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-listed (err u102))
(define-constant err-invalid-amount (err u103))

;; Data Maps
(define-map assets 
    { asset-id: uint }
    {
        owner: principal,
        metadata-uri: (string-ascii 256),
        asset-value: uint,
        is-locked: bool,
        creation-height: uint
    }
)

(define-map token-balances
    { owner: principal, asset-id: uint }
    { balance: uint }
)

;; SFTs per asset
(define-constant tokens-per-asset u100000)

;; Asset Registration
(define-public (register-asset (metadata-uri (string-ascii 256)) (asset-value uint))
    (let 
        (
            (asset-id (get-next-asset-id))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set assets
            { asset-id: asset-id }
            {
                owner: contract-owner,
                metadata-uri: metadata-uri,
                asset-value: asset-value,
                is-locked: false,
                creation-height: block-height
            }
        )
        (map-set token-balances
            { owner: contract-owner, asset-id: asset-id }
            { balance: tokens-per-asset }
        )
        (ok asset-id)
    )
)

;; Token Transfer
(define-public (transfer (asset-id uint) (amount uint) (recipient principal))
    (let
        (
            (sender-balance (get-balance tx-sender asset-id))
            (asset (unwrap! (get-asset-info asset-id) err-not-found))
        )
        (asserts! (>= sender-balance amount) err-invalid-amount)
        (asserts! (not (get is-locked asset)) err-owner-only)
        
        (map-set token-balances
            { owner: tx-sender, asset-id: asset-id }
            { balance: (- sender-balance amount) }
        )
        (map-set token-balances
            { owner: recipient, asset-id: asset-id }
            { balance: (+ (get-balance recipient asset-id) amount) }
        )
        (ok true)
    )
)

;; Asset Locking
(define-public (lock-asset (asset-id uint))
    (let
        (
            (asset (unwrap! (get-asset-info asset-id) err-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set assets
            { asset-id: asset-id }
            (merge asset { is-locked: true })
        )
        (ok true)
    )
)

;; Read Functions
(define-read-only (get-asset-info (asset-id uint))
    (map-get? assets { asset-id: asset-id })
)

(define-read-only (get-balance (owner principal) (asset-id uint))
    (default-to u0
        (get balance
            (map-get? token-balances
                { owner: owner, asset-id: asset-id }
            )
        )
    )
)

(define-read-only (get-next-asset-id)
    (default-to u1
        (get-last-asset-id)
    )
)

;; Private Functions
(define-private (get-last-asset-id)
    ;; Implementation would track the last asset ID
    ;; For simplicity, we're returning none here
    none
)
