;; Enhanced Real World Asset Token Contract
;; Implements advanced features for real-world asset tokenization

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-listed (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-not-authorized (err u104))
(define-constant err-kyc-required (err u105))
(define-constant err-vote-exists (err u106))
(define-constant err-vote-ended (err u107))
(define-constant err-price-expired (err u108))

;; Data Maps
(define-map assets 
    { asset-id: uint }
    {
        owner: principal,
        metadata-uri: (string-ascii 256),
        asset-value: uint,
        is-locked: bool,
        creation-height: uint,
        last-price-update: uint,
        total-dividends: uint
    }
)

(define-map token-balances
    { owner: principal, asset-id: uint }
    { balance: uint }
)

(define-map kyc-status
    { address: principal }
    { 
        is-approved: bool,
        level: uint,
        expiry: uint 
    }
)

(define-map proposals
    { proposal-id: uint }
    {
        title: (string-ascii 256),
        asset-id: uint,
        start-height: uint,
        end-height: uint,
        executed: bool,
        votes-for: uint,
        votes-against: uint,
        minimum-votes: uint
    }
)

(define-map votes
    { proposal-id: uint, voter: principal }
    { vote-amount: uint }
)

(define-map dividend-claims
    { asset-id: uint, claimer: principal }
    { last-claimed-amount: uint }
)

;; Price Oracle Integration
(define-map price-feeds
    { asset-id: uint }
    {
        price: uint,
        decimals: uint,
        last-updated: uint,
        oracle: principal
    }
)

;; SFTs per asset
(define-constant tokens-per-asset u100000)

;; Asset Registration with Enhanced Metadata
(define-public (register-asset 
    (metadata-uri (string-ascii 256)) 
    (asset-value uint)
    (minimum-votes uint))
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
                creation-height: block-height,
                last-price-update: block-height,
                total-dividends: u0
            }
        )
        (map-set token-balances
            { owner: contract-owner, asset-id: asset-id }
            { balance: tokens-per-asset }
        )
        (ok asset-id)
    )
)

;; KYC/AML Functions
(define-public (set-kyc-status (address principal) (is-approved bool) (level uint) (expiry uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set kyc-status
            { address: address }
            {
                is-approved: is-approved,
                level: level,
                expiry: expiry
            }
        )
        (ok true)
    )
)

(define-read-only (get-kyc-status (address principal))
    (default-to 
        { is-approved: false, level: u0, expiry: u0 }
        (map-get? kyc-status { address: address })
    )
)

;; Enhanced Transfer with KYC Check
(define-public (transfer (asset-id uint) (amount uint) (recipient principal))
    (let
        (
            (sender-balance (get-balance tx-sender asset-id))
            (asset (unwrap! (get-asset-info asset-id) err-not-found))
            (sender-kyc (get-kyc-status tx-sender))
            (recipient-kyc (get-kyc-status recipient))
        )
        (asserts! (>= sender-balance amount) err-invalid-amount)
        (asserts! (not (get is-locked asset)) err-owner-only)
        (asserts! (get is-approved sender-kyc) err-kyc-required)
        (asserts! (get is-approved recipient-kyc) err-kyc-required)
        
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

;; Dividend Distribution System
(define-public (distribute-dividends (asset-id uint) (total-amount uint))
    (let
        (
            (asset (unwrap! (get-asset-info asset-id) err-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set assets
            { asset-id: asset-id }
            (merge asset 
                { total-dividends: (+ (get total-dividends asset) total-amount) }
            )
        )
        (ok true)
    )
)

(define-public (claim-dividends (asset-id uint))
    (let
        (
            (asset (unwrap! (get-asset-info asset-id) err-not-found))
            (balance (get-balance tx-sender asset-id))
            (last-claim (get-last-claim asset-id tx-sender))
            (total-dividends (get total-dividends asset))
            (claimable-amount (/ (* balance (- total-dividends last-claim)) tokens-per-asset))
        )
        (asserts! (> claimable-amount u0) err-invalid-amount)
        (map-set dividend-claims
            { asset-id: asset-id, claimer: tx-sender }
            { last-claimed-amount: total-dividends }
        )
        ;; Transfer STX implementation here
        (ok claimable-amount)
    )
)

;; Governance System
(define-public (create-proposal 
    (asset-id uint)
    (title (string-ascii 256))
    (duration uint)
    (minimum-votes uint))
    (let
        (
            (proposal-id (get-next-proposal-id))
        )
        (asserts! (>= (get-balance tx-sender asset-id) (/ tokens-per-asset u10)) err-not-authorized)
        (map-set proposals
            { proposal-id: proposal-id }
            {
                title: title,
                asset-id: asset-id,
                start-height: block-height,
                end-height: (+ block-height duration),
                executed: false,
                votes-for: u0,
                votes-against: u0,
                minimum-votes: minimum-votes
            }
        )
        (ok proposal-id)
    )
)

(define-public (vote 
    (proposal-id uint)
    (vote-for bool)
    (amount uint))
    (let
        (
            (proposal (unwrap! (get-proposal proposal-id) err-not-found))
            (asset-id (get asset-id proposal))
            (balance (get-balance tx-sender asset-id))
        )
        (asserts! (>= balance amount) err-invalid-amount)
        (asserts! (< block-height (get end-height proposal)) err-vote-ended)
        (asserts! (is-none (get-vote proposal-id tx-sender)) err-vote-exists)
        
        (map-set votes
            { proposal-id: proposal-id, voter: tx-sender }
            { vote-amount: amount }
        )
        (map-set proposals
            { proposal-id: proposal-id }
            (merge proposal
                {
                    votes-for: (if vote-for
                        (+ (get votes-for proposal) amount)
                        (get votes-for proposal)
                    ),
                    votes-against: (if vote-for
                        (get votes-against proposal)
                        (+ (get votes-against proposal) amount)
                    )
                }
            )
        )
        (ok true)
    )
)

;; Price Oracle Integration
(define-public (update-price (asset-id uint) (new-price uint))
    (let
        (
            (price-feed (unwrap! (get-price-feed asset-id) err-not-found))
        )
        (asserts! (is-eq tx-sender (get oracle price-feed)) err-not-authorized)
        (map-set price-feeds
            { asset-id: asset-id }
            (merge price-feed
                {
                    price: new-price,
                    last-updated: block-height
                }
            )
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

(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals { proposal-id: proposal-id })
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
    (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (get-price-feed (asset-id uint))
    (map-get? price-feeds { asset-id: asset-id })
)

(define-read-only (get-last-claim (asset-id uint) (claimer principal))
    (default-to u0
        (get last-claimed-amount
            (map-get? dividend-claims
                { asset-id: asset-id, claimer: claimer }
            )
        )
    )
)

;; Private Functions
(define-private (get-next-asset-id)
    (default-to u1
        (get-last-asset-id)
    )
)

(define-private (get-next-proposal-id)
    (default-to u1
        (get-last-proposal-id)
    )
)

(define-private (get-last-asset-id)
    none
)

(define-private (get-last-proposal-id)
    none
)
