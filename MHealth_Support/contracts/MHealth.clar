;; Mental Health Anonymous Support Network Smart Contract 
;; Version: 3.0.0

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-ALREADY-MEMBER (err u101))
(define-constant ERR-NOT-MEMBER (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-SUPPORT-REQUEST-NOT-FOUND (err u104))
(define-constant ERR-INVALID-RATING (err u105))
(define-constant ERR-CANNOT-RATE-SELF (err u106))
(define-constant ERR-ALREADY-RATED (err u107))
(define-constant ERR-MAX-SPECIALIZATIONS (err u108))
(define-constant ERR-MAX-LEN-REACHED (err u109))
(define-constant ERR-INSUFFICIENT-EMERGENCY-FUND (err u110))
(define-constant ERR-NO-ASSIGNED-SUPPORTER (err u111))
(define-constant ERR-MAX-RATINGS-REACHED (err u112))
(define-constant ERR-INVALID-REWARD-AMOUNT (err u113))
(define-constant ERR-SESSION-NOT-COMPLETED (err u114))
(define-constant ERR-INVALID-RESOURCE (err u115))
(define-constant ERR-RESOURCE-EXISTS (err u116))
(define-constant ERR-EVENT-FULL (err u117))
(define-constant ERR-INVALID-NFT-OWNERSHIP (err u118))

;; Member Storage
(define-map Members
  principal
  {
    is-verified: bool,
    support-credits: uint,
    total-contributions: uint,
    support-ratings: (list 10 uint),
    average-rating: uint,
    specializations: (list 5 (string-ascii 50)),
    last-active: uint,
    reputation-score: uint,           ;; NEW: reputation score based on activities
    support-sessions-completed: uint, ;; NEW: track completed sessions
    member-tier: uint,                ;; NEW: member tier system (1-5)
    badges: (list 10 (string-ascii 30)), ;; NEW: achievement badges
    nft-token-ids: (list 5 uint)      ;; NEW: owned support NFTs
  }
)