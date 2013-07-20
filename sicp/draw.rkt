#lang racket
(require scheme/class scheme/gui/base)
(define frame(new frame% (label "painter")
                  (width 320)
                  (height 240)))

(define canvas
  (new canvas% (parent frame)
       (paint-callback
        (lambda (canvas dc) (draw-face dc )))))

;;show windows
(send frame show #t)
;;# 得到画笔 get pen and canvas 

(define dc (send canvas get-dc))

(define pen (make-object pen% "BLACK" 1 'solid))
(define (draw-face dc)
  (send dc set-pen pen) )


(send dc draw-line 0 0 320 240)
 
; http://bbs.chinaunix.net/thread-1280862-1-1.html
  
 