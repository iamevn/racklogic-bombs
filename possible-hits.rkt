#lang racket
(provide possible-sums possible-hit-set possible-hits)

(module+ test
  (require rackunit)
  
  (define (list-or-set->set list-or-set)
    (if (list? list-or-set)
        (apply set list-or-set)
        list-or-set))

  (define (lists-match? a b)
    (equal? (sort a <)
            (sort b <)))
  
  (define-syntax-rule (test-possible-sums? NAME INPUT EXPECTED)
    (test-equal? NAME (possible-sums INPUT) EXPECTED))
  (define-syntax-rule (test-possible-hit-set? NAME INPUT EXPECTED)
    (test-equal? NAME (possible-hit-set INPUT) EXPECTED)))

;; given a list of numbers/options for numbers (as a list) return set of all possible sums of subsets of those numbers
;; e.g. (possible-sums '(1 2 3)) => (set 0 1 2 3 4 5 6)
;; when an option is given, use one of but not multiple of the alternatives
;; e.g. (possible-sums '(1 {10 20})) => (set 0 1 20 21 10 11)
(define (possible-sums single-can-see)
  (if (empty? single-can-see)
      (set 0)
      (let loop ([current (car single-can-see)]
                 [rest (cdr single-can-see)]
                 [found (set 0)])
        (let* ([subsums (possible-sums rest)]
               [newfound (cond [(list? current)
                                (apply set-union
                                       (for/list ([current-option current])
                                         (list->set (set-map subsums (λ (n) (+ current-option n))))))]
                               [else
                                (list->set (set-map subsums (λ (n) (+ current n))))])]
               [allfound (set-union found newfound)])
          (if (empty? rest) allfound
              (loop (car rest) (cdr rest) allfound))))))

(module+ test
  (test-possible-sums? "Can always get 0" '() (set 0))
  (test-possible-sums? "Basic with sum" '(1 2) (set 0 1 2 3))
  (test-possible-sums? "Alternative can't sum" '({1 2}) (set 0 1 2))
  (test-possible-sums? "Multiple alternatives" '({1 2} {10 20}) (set 0 1 2 10 20 11 21 12 22)))

;; given a list of what each bomb of the same type can see, return set of
;; possible target values for that type of bomb (see possible-sums above or test cases for input format)
(define (possible-hit-set can-see)
  (apply set-intersect (map possible-sums can-see)))

;; helper producing a list instead of a set
(define possible-hits (compose set->list possible-hit-set))
 

(module+ test
  (test-possible-hit-set? "x example"
                       '[(1 2 3)
                         (3 1 2)]
                       (set 0 1 2 3 4 5 6))
  (test-possible-hit-set? "y example"
                       '[(3 3 3)
                         (3 1 {1 2})
                         (3 3 3)
                         (1 2 2)]
                       (set 0 3))
  (test-possible-hit-set? "z example"
                       '[({1 2} 1 3)
                         (1 3 3)
                         ({1 2} 1 2)]
                       (set 0 1 3 4))
  (test-possible-hit-set? "a example"
                       '[(3 1 {1 2})]
                       (set 0 1 2 3 4 5 6))
  (test-possible-hit-set? "b example"
                       '[(3 3 1)]
                       (set 0 1 3 4 6 7))
  
  (test-possible-hit-set? "c example"
                       '[(2 3 1)]
                       (set 0 1 2 3 4 5 6)))
