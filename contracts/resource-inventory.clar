;; Resource Inventory Contract
;; Records available medical supplies

(define-data-var admin principal tx-sender)

;; Map to store resources by ID
(define-map resources uint
  {
    name: (string-utf8 100),
    category: (string-utf8 50),
    quantity: uint,
    last-updated: uint
  }
)

;; Counter for resource IDs
(define-data-var resource-id-counter uint u1)

;; Function to add a new resource
(define-public (add-resource (name (string-utf8 100)) (category (string-utf8 50)) (quantity uint))
  (let ((resource-id (var-get resource-id-counter)))
    (begin
      (asserts! (is-authorized) (err u403))
      (map-set resources resource-id
        {
          name: name,
          category: category,
          quantity: quantity,
          last-updated: block-height
        }
      )
      (var-set resource-id-counter (+ resource-id u1))
      (ok resource-id)
    )
  )
)

;; Function to update resource quantity
(define-public (update-quantity (resource-id uint) (new-quantity uint))
  (begin
    (asserts! (is-authorized) (err u403))
    (asserts! (is-some (map-get? resources resource-id)) (err u404))
    (let ((resource (unwrap-panic (map-get? resources resource-id))))
      (ok (map-set resources resource-id
        (merge resource { quantity: new-quantity, last-updated: block-height })
      ))
    )
  )
)

;; Function to get resource details
(define-read-only (get-resource (resource-id uint))
  (map-get? resources resource-id)
)

;; Helper function to check if caller is authorized
(define-private (is-authorized)
  (is-eq tx-sender (var-get admin))
)

;; Function to update admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
