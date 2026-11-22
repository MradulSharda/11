#lang racket/base

;; =========================================================================
;; CS F301 Assignment 2 - Problem S1: Binary Tree Traversals
;; Group: 11
;;
;; Pure functional implementation using strictly allowed built-ins:
;; define, car, cadr, caddr, null?, and, not.
;; =========================================================================

;; -------------------------------------------------------------------------
;; Binary Tree Representation:
;; Either '() or (list value left right) where left and right are trees.
;; -------------------------------------------------------------------------

;; tree-val: returns the value stored at the root of a non-empty node
(define (tree-val tree)
  (car tree))

;; tree-left: returns the left binary subtree of a non-empty node
(define (tree-left tree)
  (cadr tree))

;; tree-right: returns the right binary subtree of a non-empty node
(define (tree-right tree)
  (caddr tree))

;; tree-empty?: returns #t if the tree is the empty tree '(), #f otherwise
(define (tree-empty? tree)
  (null? tree))

;; tree-leaf?: returns #t if tree is a non-empty node whose subtrees are both '()
(define (tree-leaf? tree)
  (and (not (null? tree))
       (null? (cadr tree))
       (null? (caddr tree))))
