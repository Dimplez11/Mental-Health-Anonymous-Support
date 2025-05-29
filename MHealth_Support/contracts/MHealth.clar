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

;; Support Requests
(define-map SupportRequests
  uint
  {
    requester: principal,
    request-type: (string-ascii 50),
    anonymity-level: uint,
    status: (string-ascii 20),
    assigned-supporter: (optional principal),
    emergency-flag: bool,
    interaction-logs: (list 10 (string-ascii 100)),
    creation-time: uint,            ;; NEW: timestamp when created
    resolution-time: (optional uint) ;; NEW: timestamp when resolved
  }
)

;; Support Interaction Ratings
(define-map SupportInteractionRatings
  {request-id: uint, rater: principal}
  {
    rating: uint,
    feedback: (string-ascii 200)
  }
)

;; Educational Resources
(define-map MentalHealthResources
  (string-ascii 50)
  {
    title: (string-ascii 100),
    resource-type: (string-ascii 20), ;; video, article, guide, etc.
    content-hash: (buff 32),          ;; IPFS or other distributed hash
    creator: principal,
    votes: uint,
    verified: bool
  }
)

;; Community Events
(define-map CommunityEvents
  uint
  {
    event-name: (string-ascii 100),
    event-type: (string-ascii 50),    ;; workshop, group session, etc.
    organizer: principal,
    max-participants: uint,
    current-participants: uint,
    event-date: uint,
    location-hash: (buff 32),         ;; encrypted location data
    description: (string-ascii 200)
  }
)

;; Group Support Sessions
(define-map GroupSessions
  uint
  {
    session-name: (string-ascii 100),
    facilitator: principal,
    participants: (list 20 principal),
    topic: (string-ascii 100),
    status: (string-ascii 20),
    scheduled-time: uint,
    max-capacity: uint
  }
)

;; Global counters and variables
(define-data-var total-members uint u0)
(define-data-var support-request-counter uint u0)
(define-data-var emergency-support-fund uint u1000) ;; Initial emergency fund
(define-data-var resource-counter uint u0)          ;; NEW: counter for resources
(define-data-var event-counter uint u0)             ;; NEW: counter for events
(define-data-var group-session-counter uint u0)     ;; NEW: counter for group sessions
(define-data-var nft-counter uint u0)               ;; NEW: counter for NFTs

;; Emergency Support Request
(define-public (create-emergency-support-request 
  (request-type (string-ascii 50))
)
  (let 
    (
      (request-id (var-get support-request-counter))
      (member (unwrap! (map-get? Members tx-sender) ERR-NOT-MEMBER))
      (emergency-fund (var-get emergency-support-fund))
    )
    (asserts! (get is-verified member) ERR-UNAUTHORIZED)
    
    ;; Check if emergency fund is sufficient
    (asserts! (> emergency-fund u0) ERR-INSUFFICIENT-EMERGENCY-FUND)
    
    (map-set SupportRequests 
      request-id 
      {
        requester: tx-sender,
        request-type: request-type,
        anonymity-level: u3, ;; Highest anonymity
        status: "EMERGENCY_PENDING",
        assigned-supporter: none,
        emergency-flag: true,
        interaction-logs: (list),
        creation-time: block-height,
        resolution-time: none
      }
    )

    ;; Reduce emergency fund
    (var-set emergency-support-fund (- emergency-fund u100))
    (var-set support-request-counter (+ request-id u1))
    (ok request-id)
  )
)
