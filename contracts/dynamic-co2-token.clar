(impl-trait .sip-010-trait.sip-010-trait)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant TOKEN-NAME "CO2Token")
(define-constant TOKEN-SYMBOL "CO2T")
(define-constant TOKEN-DECIMALS u6)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-VALUE (err u101))

;; Data Variables
(define-data-var total-supply uint u0)
(define-data-var base-co2-level uint u410) 
(define-data-var emission-factor uint u100000)

;; Token balances map
(define-map balances principal uint)

;; Read-only functions
(define-read-only (get-name)
    (ok TOKEN-NAME))
(define-read-only (get-symbol)
    (ok TOKEN-SYMBOL))
(define-read-only (get-decimals)
    (ok TOKEN-DECIMALS))
(define-read-only (get-balance (account principal))
    (ok (default-to u0 (map-get? balances account))))
(define-read-only (get-total-supply)
    (ok (var-get total-supply)))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) ERR-NOT-AUTHORIZED)
        (asserts! (>= (default-to u0 (map-get? balances sender)) amount) ERR-INVALID-VALUE)
        (map-set balances sender 
            (- (default-to u0 (map-get? balances sender)) amount))
        (map-set balances recipient 
            (+ (default-to u0 (map-get? balances recipient)) amount))
        (ok true)))

;; Initialize contract
(begin
    (var-set total-supply u0)
    (map-set balances CONTRACT-OWNER u0))

    ;; CO2 Level Management
(define-public (set-co2-level (new-level uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (asserts! (> new-level u0) ERR-INVALID-VALUE)
        (let ((old-level (var-get base-co2-level))
              (diff (if (> new-level old-level)
                       (- new-level old-level)
                       u0)))
            (var-set base-co2-level new-level)
            (if (> diff u0)
                (mint-tokens diff)
                (ok u0)))))

;; Token Operations
(define-private (mint-tokens (amount uint))
    (let ((tokens-to-mint (* amount (var-get emission-factor))))
        (var-set total-supply (+ (var-get total-supply) tokens-to-mint))
        (map-set balances CONTRACT-OWNER 
            (+ (default-to u0 (map-get? balances CONTRACT-OWNER)) tokens-to-mint))
        (ok tokens-to-mint)))

;; Distribution to Eco-Projects
(define-public (distribute-to-project (project principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        (transfer amount CONTRACT-OWNER project none)))