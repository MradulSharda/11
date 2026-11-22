#lang racket/base

(require racket/runtime-path)

;; -------------------------------------------------------------------------
;; Locate and dynamically load code/11_q4.rkt relative to this test file.
;; -------------------------------------------------------------------------
(define-runtime-path code-file "../code/11_q4.rkt")

;; Resolve the namespace of code/11_q4.rkt to access internal definitions
;; without modifying code/11_q4.rkt.
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

(define my-reverse (namespace-variable-value 'my-reverse #f #f ns))
(define my-length (namespace-variable-value 'my-length #f #f ns))
(define my-map (namespace-variable-value 'my-map #f #f ns))
(define make-inserter (namespace-variable-value 'make-inserter #f #f ns))
(define insert-if-short (namespace-variable-value 'insert-if-short #f #f ns))
(define print-insert-result (namespace-variable-value 'print-insert-result #f #f ns))

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

;; Test Suite 1: All PDF Examples
(define (test-pdf-examples)
  (display "Running Test Suite 1: PDF Examples...\n")
  ;; Example 1: 42 ((1 2) (3 4 5) (6) ()) 3
  (check "PDF Example 1: insert 42 when len < 3"
         (equal? (insert-if-short 42 '((1 2) (3 4 5) (6) ()) 3)
                 '((42 1 2) (3 4 5) (42 6) (42))))

  ;; Example 2: 0 (((1) 2) (3) ((4 5 6) ())) 3
  (check "PDF Example 2: nested structure with 0 when len < 3"
         (equal? (insert-if-short 0 '(((1) 2) (3) ((4 5 6) ())) 3)
                 '((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))))

  ;; Example 3: 7 () 3 -> (7)
  (check "PDF Example 3: empty list with n=3 -> (7)"
         (equal? (insert-if-short 7 '() 3)
                 '(7)))

  ;; Example 4: 7 () 0 -> ()
  (check "PDF Example 4: empty list with n=0 -> ()"
         (equal? (insert-if-short 7 '() 0)
                 '())))

;; Test Suite 2: Edge Cases
(define (test-edge-cases)
  (display "Running Test Suite 2: Edge Cases...\n")
  ;; n = 0 on nested lists: no sublist can have length < 0
  (check "n = 0 on nested lists leaves list unmodified"
         (equal? (insert-if-short 'x '((1 (2 ())) 3) 0)
                 '((1 (2 ())) 3)))

  ;; List with elements >= n: untouched
  (check "Flat atom list with length >= n remains untouched"
         (equal? (insert-if-short 'x '(a b c d) 4)
                 '(a b c d)))

  ;; List with length strictly less than n
  (check "Flat atom list with length < n receives insertion at front"
         (equal? (insert-if-short 'x '(a b c d) 5)
                 '(x a b c d)))

  ;; Multiple empty lists at different nesting levels
  (check "Multiple empty lists at different nesting levels receive insertion"
         (equal? (insert-if-short 99 '(() (()) ((()))) 2)
                 '((99) (99 (99)) (99 (99 (99))))))

  ;; Custom predicate with make-inserter
  (check "make-inserter with custom predicate (even length)"
         (equal? ((make-inserter 'even (lambda (len) (= (remainder len 2) 0)))
                  '((1 2) (1 2 3) ()))
                 '((even 1 2) (1 2 3) (even)))))

;; Test Suite 3: Stress Tests (Depth 100 and 10,000 Elements)
(define (test-stress)
  (display "Running Test Suite 3: Stress Tests (Nesting Depth 100 & 10,000 Elements)...\n")

  ;; Depth 100 test
  (define (make-nested-list depth)
    (let loop ((d depth) (acc '()))
      (if (= d 0)
          acc
          (loop (- d 1) (list acc)))))

  (define nested-100 (make-nested-list 100))
  (define transformed-100 (insert-if-short 'x nested-100 2))

  ;; Check that outermost has 'x inserted
  (check "Depth 100: processes without stack overflow and inserts at top level"
         (and (pair? transformed-100)
              (eq? (car transformed-100) 'x)))

  ;; Large list of 10,000 elements
  (define (make-large-list n)
    (let loop ((i n) (acc '()))
      (if (= i 0)
          acc
          (loop (- i 1) (cons i acc)))))

  (define large-10000 (make-large-list 10000))

  ;; Test my-length on 10,000 elements
  (check "Stress my-length: 10,000 elements computed without stack overflow"
         (= (my-length large-10000) 10000))

  ;; Test insert-if-short when length < n (10000 < 10001)
  (define inserted-large (insert-if-short 'head large-10000 10001))
  (check "Stress insert-if-short: 10,000 elements receives head insert (length 10001)"
         (and (= (my-length inserted-large) 10001)
              (eq? (car inserted-large) 'head)))

  ;; Test insert-if-short when length >= n (10000 < 10000 is false)
  (define uninserted-large (insert-if-short 'head large-10000 10000))
  (check "Stress insert-if-short: 10,000 elements unchanged when n <= length"
         (= (my-length uninserted-large) 10000)))

;; Test Suite 4: Standard I/O Handler (print-insert-result)
(define (test-io-handler)
  (display "Running Test Suite 4: Standard I/O Handler (print-insert-result)...\n")

  (define (test-io-case input-str expected-str case-name)
    (define in (open-input-string input-str))
    (define out (open-output-string))
    (parameterize ([current-input-port in]
                   [current-output-port out])
      (print-insert-result))
    (check case-name (string=? (get-output-string out) expected-str)))

  (test-io-case "42 ((1 2) (3 4 5) (6) ()) 3\n"
                "((42 1 2) (3 4 5) (42 6) (42))\n"
                "print-insert-result: PDF Example 1 via ports")

  (test-io-case "7 () 3\n"
                "(7)\n"
                "print-insert-result: PDF Example 3 via ports")

  (test-io-case "7 () 0\n"
                "()\n"
                "print-insert-result: PDF Example 4 via ports"))

;; -------------------------------------------------------------------------
;; Main Test Runner
;; -------------------------------------------------------------------------
(define (run-all-tests)
  (display "\n========================================\n")
  (display "  Running Scheme Unit Tests for S2\n")
  (display "========================================\n\n")
  (test-pdf-examples)
  (newline)
  (test-edge-cases)
  (newline)
  (test-stress)
  (newline)
  (test-io-handler)
  (newline)
  (display "----------------------------------------\n")
  (display "Test Summary: ")
  (display passed-tests)
  (display " / ")
  (display total-tests)
  (display " tests passed.\n")
  (if (= passed-tests total-tests)
      (display "All test suites passed successfully!\n")
      (display "Some tests failed.\n"))
  (display "----------------------------------------\n\n"))

(run-all-tests)
