#lang racket/base

(require racket/runtime-path)

;; -------------------------------------------------------------------------
;; Locate and dynamically load code/11_q3.rkt relative to this test file.
;; -------------------------------------------------------------------------
(define-runtime-path code-file "../code/11_q3.rkt")

(define ns
  (with-handlers ([exn:fail? (lambda (e)
                               ;; Fallback: read definitions and evaluate in fresh base namespace
                               (define new-ns (make-base-namespace))
                               (call-with-input-file code-file
                                 (lambda (p)
                                   (read-line p) ; skip #lang racket/base
                                   (let loop ()
                                     (define form (read p))
                                     (unless (eof-object? form)
                                       (eval form new-ns)
                                       (loop)))))
                               new-ns)])
    (dynamic-require code-file #f)
    (module->namespace (make-resolved-module-path code-file))))

(define tree-val (namespace-variable-value 'tree-val #f #f ns))
(define tree-left (namespace-variable-value 'tree-left #f #f ns))
(define tree-right (namespace-variable-value 'tree-right #f #f ns))
(define tree-empty? (namespace-variable-value 'tree-empty? #f #f ns))
(define tree-leaf? (namespace-variable-value 'tree-leaf? #f #f ns))
(define tree->inorder (namespace-variable-value 'tree->inorder #f #f ns))
(define tree->preorder (namespace-variable-value 'tree->preorder #f #f ns))
(define tree->postorder (namespace-variable-value 'tree->postorder #f #f ns))
(define print-inorder (namespace-variable-value 'print-inorder #f #f ns))
(define print-all-traversals (namespace-variable-value 'print-all-traversals #f #f ns))
(define tree-height (namespace-variable-value 'tree-height #f #f ns))
(define tree-leaf-count (namespace-variable-value 'tree-leaf-count #f #f ns))
(define print-height-and-leaves (namespace-variable-value 'print-height-and-leaves #f #f ns))

;; -------------------------------------------------------------------------
;; Test Helpers & Test Suite
;; -------------------------------------------------------------------------

(define total-tests 0)
(define passed-tests 0)

(define (check name condition)
  (set! total-tests (+ total-tests 1))
  (if condition
      (begin
        (set! passed-tests (+ passed-tests 1))
        (display "  [PASS] ")
        (display name)
        (newline))
      (begin
        (display "  [FAIL] ")
        (display name)
        (newline))))

(define (capture-output thunk)
  (define out (open-output-string))
  (parameterize ([current-output-port out])
    (thunk))
  (get-output-string out))

(displayln "============================================================")
(displayln "Running Unit Tests for Problem S1 (11_q3.rkt)")
(displayln "============================================================")

;; Trees from assignment specification
(define t1 '(4 (2 (1 () ()) (3 () ()))
               (6 (5 () ()) (7 () ()))))

(define t2 '(1 () (2 () (3 () ()))))

(define t3 '(a (b () ()) (c () ())))

(define t-empty '())
(define t-single '(42 () ()))
(define t-left-skewed '(3 (2 (1 () ()) ()) ()))

;; Section 1: Tree Selectors & Predicates
(displayln "\n-- Selectors & Predicates --")
(check "tree-empty? on empty" (tree-empty? t-empty))
(check "tree-empty? on non-empty" (not (tree-empty? t-single)))
(check "tree-val root" (equal? (tree-val t1) 4))
(check "tree-left subtree root" (equal? (tree-val (tree-left t1)) 2))
(check "tree-right subtree root" (equal? (tree-val (tree-right t1)) 6))
(check "tree-leaf? on leaf" (tree-leaf? '(1 () ())))
(check "tree-leaf? on non-leaf" (not (tree-leaf? t1)))
(check "tree-leaf? on empty" (not (tree-leaf? t-empty)))

;; Section 2: Traversals on t1
(displayln "\n-- Traversals on t1 (Balanced Tree) --")
(check "inorder t1" (equal? (tree->inorder t1) '(1 2 3 4 5 6 7)))
(check "preorder t1" (equal? (tree->preorder t1) '(4 2 1 3 6 5 7)))
(check "postorder t1" (equal? (tree->postorder t1) '(1 3 2 5 7 6 4)))

;; Section 3: Traversals on t2 (Right-Skewed)
(displayln "\n-- Traversals on t2 (Right-Skewed Tree) --")
(check "inorder t2" (equal? (tree->inorder t2) '(1 2 3)))
(check "preorder t2" (equal? (tree->preorder t2) '(1 2 3)))
(check "postorder t2" (equal? (tree->postorder t2) '(3 2 1)))

;; Section 4: Traversals on t3 (Symbol Tree)
(displayln "\n-- Traversals on t3 (Symbols) --")
(check "inorder t3" (equal? (tree->inorder t3) '(b a c)))
(check "preorder t3" (equal? (tree->preorder t3) '(a b c)))
(check "postorder t3" (equal? (tree->postorder t3) '(b c a)))

;; Section 5: Traversals on Edge Cases
(displayln "\n-- Traversals on Edge Cases (Empty & Single Node) --")
(check "inorder empty" (equal? (tree->inorder t-empty) '()))
(check "preorder empty" (equal? (tree->preorder t-empty) '()))
(check "postorder empty" (equal? (tree->postorder t-empty) '()))
(check "inorder single" (equal? (tree->inorder t-single) '(42)))
(check "preorder single" (equal? (tree->preorder t-single) '(42)))
(check "postorder single" (equal? (tree->postorder t-single) '(42)))

;; Section 6: Height and Leaves
(displayln "\n-- Height and Leaf Count --")
(check "height t1 is 3" (= (tree-height t1) 3))
(check "leaves t1 is 4" (= (tree-leaf-count t1) 4))
(check "height t2 is 3" (= (tree-height t2) 3))
(check "leaves t2 is 1" (= (tree-leaf-count t2) 1))
(check "height t3 is 2" (= (tree-height t3) 2))
(check "leaves t3 is 2" (= (tree-leaf-count t3) 2))
(check "height empty is 0" (= (tree-height t-empty) 0))
(check "leaves empty is 0" (= (tree-leaf-count t-empty) 0))
(check "height single is 1" (= (tree-height t-single) 1))
(check "leaves single is 1" (= (tree-leaf-count t-single) 1))
(check "height left-skewed is 3" (= (tree-height t-left-skewed) 3))
(check "leaves left-skewed is 1" (= (tree-leaf-count t-left-skewed) 1))

;; Section 7: Output Formatting & Displays
(displayln "\n-- Standard Output Display Tests --")
(check "print-inorder t1 formatted"
       (equal? (capture-output (lambda () (print-inorder t1))) "(1 2 3 4 5 6 7)\n"))
(check "print-inorder empty formatted"
       (equal? (capture-output (lambda () (print-inorder t-empty))) "()\n"))

(check "print-all-traversals t1 formatted"
       (equal? (capture-output (lambda () (print-all-traversals t1)))
               "(1 2 3 4 5 6 7)\n(4 2 1 3 6 5 7)\n(1 3 2 5 7 6 4)\n"))

(check "print-all-traversals empty formatted"
       (equal? (capture-output (lambda () (print-all-traversals t-empty)))
               "()\n()\n()\n"))

(check "print-height-and-leaves t1 formatted"
       (equal? (capture-output (lambda () (print-height-and-leaves t1))) "(3 4)\n"))

(check "print-height-and-leaves empty formatted"
       (equal? (capture-output (lambda () (print-height-and-leaves t-empty))) "(0 0)\n"))

(displayln "============================================================")
(displayln (format "Result: ~a / ~a tests passed." passed-tests total-tests))
(displayln "============================================================")
