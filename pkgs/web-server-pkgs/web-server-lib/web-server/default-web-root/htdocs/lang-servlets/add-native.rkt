#lang web-server
(require web-server/managers/lru)

(define interface-version 'stateless)
(define manager
  (make-threshold-LRU-manager #f (* 1024 1024 128)))
(provide start manager interface-version)

;; get-number-from-user: string -> number
;; ask the user for a number
(define (gn msg)
  (let ([req
         (send/suspend/url
          (lambda (k-url)
            (response/xexpr
             `(html (head (title ,(format "Get ~a number" msg)))
                    (body
                     (form ([action ,(url->string k-url)]
                            [method "get"]
                            [enctype "application/x-www-form-urlencoded"])
                           ,(format "Enter the ~a number to add: " msg)
                           (input ([type "text"] [name "number"] [value ""]))
                           (input ([type "submit"]))))))))])
    (string->number
     (cdr (assoc 'number (url-query (request-uri req)))))))

(define (gn* m)
  (first (serial->native (map (lambda (m) (native->serial (gn m))) (list m)))))

(define (start initial-request)
  (response/xexpr
   `(html (head (title "Final Page"))
          (body
           (h1 "Final Page")
           (p ,(format "The answer is ~a"
                       (+ (gn* "first") (gn* "second"))))))))
