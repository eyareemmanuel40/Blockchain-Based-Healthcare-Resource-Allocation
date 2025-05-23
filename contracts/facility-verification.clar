;; Facility Verification Contract
;; This contract validates healthcare providers

(define-data-var admin principal tx-sender)

;; Map to store verified facilities
(define-map verified-facilities principal
  {
    name: (string-utf8 100),
    license-number: (string-utf8 50),
    verified: bool,
    verification-date: uint
  }
)

;; Function to verify a facility
(define-public (verify-facility (facility principal) (name (string-utf8 100)) (license-number (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set verified-facilities facility
      {
        name: name,
        license-number: license-number,
        verified: true,
        verification-date: block-height
      }
    ))
  )
)

;; Function to check if a facility is verified
(define-read-only (is-verified (facility principal))
  (default-to false (get verified (map-get? verified-facilities facility)))
)

;; Function to get facility details
(define-read-only (get-facility-details (facility principal))
  (map-get? verified-facilities facility)
)

;; Function to update admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
