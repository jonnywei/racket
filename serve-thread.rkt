#lang racket
(define (serve port-no)
  (define listener (tcp-listen port-no 5 #t))
  (define (loop)
    (accept-and-handle listener)
    (loop))
  ;define线程，loop run in its own thread
  (define t (thread loop))
  (lambda ()
    (kill-thread t)
    (tcp-close listener)))
  

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
 

(define (handle in out)
  ;discard the request header 
  (regexp-match #rx"(\r\n|^)\r\n" in)
  ; sleep random seconds
  ;(sleep 33)
  ;send reply
  (display "HTTP/1.0 200 OK\r\n" out)
  (display "Server:racket\r\nContent-Type:text/html\r\n\r\n" out)
  (display "<html><body>Hello,racket!</body></html>" out))


