#lang racket/base

;; =========================================================================
;; CS F301 Assignment 2 - Problem S1: Binary Tree Traversals
;; Group: 11
;;
;; Pure functional implementation using strictly allowed built-ins:
;; define, car, cadr, caddr, null?, and, not, if, cons.
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

;; -------------------------------------------------------------------------
;; Traversal Helpers (Accumulator-based, O(N) time, zero append / reverse)
;;
;; Since append and reverse are forbidden, each helper traverses the subtrees
;; and threads the accumulator directly using cons in pure linear time.
;; -------------------------------------------------------------------------

;; tree->inorder-acc: produces (left, node, right) prepended onto acc
(define (tree->inorder-acc tree acc)
  (if (null? tree)
      acc
      (tree->inorder-acc
       (cadr tree)
       (cons (car tree)
             (tree->inorder-acc (caddr tree) acc)))))

;; tree->inorder: returns list of values in inorder
(define (tree->inorder tree)
  (tree->inorder-acc tree '()))

;; tree->preorder-acc: produces (node, left, right) prepended onto acc
(define (tree->preorder-acc tree acc)
  (if (null? tree)
      acc
      (cons (car tree)
            (tree->preorder-acc
             (cadr tree)
             (tree->preorder-acc (caddr tree) acc)))))

;; tree->preorder: returns list of values in preorder
(define (tree->preorder tree)
  (tree->preorder-acc tree '()))

;; tree->postorder-acc: produces (left, right, node) prepended onto acc
(define (tree->postorder-acc tree acc)
  (if (null? tree)
      acc
      (tree->postorder-acc
       (cadr tree)
       (tree->postorder-acc
        (caddr tree)
        (cons (car tree) acc)))))

;; tree->postorder: returns list of values in postorder
(define (tree->postorder tree)
  (tree->postorder-acc tree '()))

;; -------------------------------------------------------------------------
;; Task S1.a: print-inorder
;; Prints on one line using display the list of values of tree in inorder
;; (left subtree, node, right subtree), followed by a newline.
;; For '(), prints () followed by a newline.
;; -------------------------------------------------------------------------
(define (print-inorder tree)
  (display (tree->inorder tree))
  (newline))
