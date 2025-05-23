;; Demand Forecasting Contract
;; Predicts resource requirements

(define-data-var admin principal tx-sender)

;; Map to store demand forecasts by region and resource
(define-map demand-forecasts
  { region: (string-utf8 50), resource-id: uint }
  {
    predicted-quantity: uint,
    confidence-level: uint,  ;; 1-100 percentage
    forecast-date: uint,
    expiry-date: uint
  }
)

;; Function to add a new forecast
(define-public (add-forecast
  (region (string-utf8 50))
  (resource-id uint)
  (predicted-quantity uint)
  (confidence-level uint)
  (expiry-blocks uint))
  (begin
    (asserts! (is-authorized) (err u403))
    (asserts! (<= confidence-level u100) (err u400))
    (ok (map-set demand-forecasts
      { region: region, resource-id: resource-id }
      {
        predicted-quantity: predicted-quantity,
        confidence-level: confidence-level,
        forecast-date: block-height,
        expiry-date: (+ block-height expiry-blocks)
      }
    ))
  )
)

;; Function to get forecast
(define-read-only (get-forecast (region (string-utf8 50)) (resource-id uint))
  (map-get? demand-forecasts { region: region, resource-id: resource-id })
)

;; Function to check if forecast is valid (not expired)
(define-read-only (is-forecast-valid (region (string-utf8 50)) (resource-id uint))
  (match (map-get? demand-forecasts { region: region, resource-id: resource-id })
    forecast (< block-height (get expiry-date forecast))
    false
  )
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
