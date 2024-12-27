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