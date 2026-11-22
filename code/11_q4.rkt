#lang racket/base

;; -------------------------------------------------------------------------
;; Helper 1: my-reverse
;; Reverses a list using a strictly tail-recursive named let with an accumulator.
;; O(N) time, O(1) auxiliary stack space.
;; -------------------------------------------------------------------------
(define (my-reverse lst)
  (let loop ((rem lst) (acc '()))
    (if (null? rem)
        acc
        (loop (cdr rem) (cons (car rem) acc)))))

;; -------------------------------------------------------------------------
;; Helper 2: my-length
;; Computes the number of top-level elements of lst using a strictly
;; tail-recursive loop with an accumulator. Safe for lists of 10,000+ elements.
;; -------------------------------------------------------------------------
(define (my-length lst)
  (let loop ((rem lst) (acc 0))
    (if (null? rem)
        acc
        (loop (cdr rem) (+ acc 1)))))

;; -------------------------------------------------------------------------
;; Helper 3: my-map
;; Applies unary function f to each element of lst in order.
;; Uses a tail-recursive accumulator loop to collect elements in reverse order,
;; followed by a tail-call to my-reverse. Safe for 10,000+ elements.
;; -------------------------------------------------------------------------
(define (my-map f lst)
  (let loop ((rem lst) (acc '()))
    (if (null? rem)
        (my-reverse acc)
        (loop (cdr rem) (cons (f (car rem)) acc)))))
