#lang racket
(define (serve port-no)
  (define main-cust (make-custodian))
  (parameterize ([current-custodian main-cust])
    (define listener (tcp-listen port-no 5 #t))
    (define (loop)
      (accept-and-handle listener)
      (loop))
  ;define线程，loop run in its own thread
  (thread loop))
  (lambda ()
    (custodian-shutdown-all main-cust)))
    
  

(define (accept-and-handle listener)
  (define cust (make-custodian))
  (parameterize ([current-custodian cust])
    (define-values (in out) (tcp-accept listener))
    ( thread 
             (lambda()
               (handle in out)
               (close-input-port in)
               (close-output-port out))))
 
  ;; watch thread:
  (thread (lambda()
            (sleep 10)
            (custodian-shutdown-all cust))))
 
(require xml net/url)
(define (handle in out)
  (define req 
    ;match the fire line to extract request
    (regexp-match #rx"^GET (.+) HTTP/[0-9]+\\.[0-9]+"
                  (read-line in)))
  (when req
    ;discard the request header 
    (regexp-match #rx"(\r\n|^)\r\n" in)
    (let ([xexpr (dispatch (list-ref req 1))])
    ; sleep random seconds
    ;(sleep 33)
    ;send reply
      (display "HTTP/1.0 200 OK\r\n" out)
      (display "Server:racket\r\nContent-Type:text/html\r\n\r\n" out)
      (display (xexpr->string xexpr) out))))

;define dispatch
(define (dispatch str-path)
  ;parse the request as url
  (define url (string->url str-path))
  ;extarct the path param
  (define path (map path/param-path (url-path url)))
  ;find a handler based on the path's first element
  (define h (hash-ref dispatch-table (car path) #f))
  (if h
      (h (url-query url))
      ;no handler found:
      `(html (head (title "Error"))
             (body 
              (font ((color "red"))
                    "Unknown page: "
                    ,str-path)))))

(define dispatch-table (make-hash))

