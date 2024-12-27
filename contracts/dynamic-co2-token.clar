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