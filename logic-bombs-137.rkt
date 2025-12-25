#lang racket
;; logic bombs 137
;; idk how to get going with this puzzle so I guess it's time to learn racklog https://docs.racket-lang.org/racklog/

(require racklog)

(define TARGET-TOTAL 34)

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

;; given a list of what each bomb of the same type can see, return list of
;; possible target values for that type of bomb (see possible-sums above or test cases for input format)
(define (possible-hits can-see)
  (set->list (apply set-intersect (map possible-sums can-see))))

(define possible-hits-test-cases
  `([x
     [(3 1 2)
      (3 1 2)]
     (0 1 2 3 4 5 6)]
    [y
     [(3 3 3)
      (3 1 {1 2})
      (3 3 3)
      (1 2 2)]
     (0 3)]
    [z
     [({1 2} 1 3)
      (1 3 3)
      ({1 2} 1 2)]
     (0 1 3 4)]
    [a
     [(3 1 {1 2})]
     (0 1 2 3 4 5 6)]
    [b
     [(3 3 1)]
     (0 1 3 4 6 7)]
    [c
     [(2 3 1)]
     (0 1 2 3 4 5 6)]))

(define (lists-match? a b)
  (equal? (sort a <)
          (sort b <)))

(for ([test-case possible-hits-test-cases])
  (match test-case
    [(list title can-see expected)
     (let* ([got (possible-hits can-see)]
            [pass? (lists-match? expected got)])
       (unless pass?
         #;(displayln (~a title " PASS"))
         (displayln (~a title " FAIL: expected " expected ", got " got))))]))

(define %can-see %empty-rel)
(%assert! %can-see ()
          [('x '[#;(3 1 2) (3 2)
                 (3 1 2)])]
          [('y '[(3 3 3)
                 (3 1 {1 2})
                 (3 3 3)
                 (1 2 2)])]
          [('z '[({1 2} 1 3)
                 #;(1 3 3) (1 3)
                 #;({1 2} 1 2) ({1 2} 2)])]
          [('a '[(3 1 {1 2})])]
          [('b '[(3 3 1)])]
          [('c '[(2 1 3)])])

;; can a bomb 'x/'y/'z/'a/'b/'c hit given number of targets?
(define %can-hit
  (%rel (bomb n can-see can-hit)
        [(bomb n)
         (%can-see bomb can-see)
         (%is can-hit (possible-hits can-see))
         (%member n can-hit)]))

;; how many of each bomb type are present
(define (bomb-count bomb)
  (second (assoc bomb '((x 2)
                        (y 4)
                        (z 3)
                        (a 1)
                        (b 1)
                        (c 1)))))

;; given numbers hit for each bomb type, return sum of targets hit
;; by all bombs of each type
(define (bomb-total x y z a b c)
  (+ (* x (bomb-count 'x))
     (* y (bomb-count 'y))
     (* z (bomb-count 'z))
     (* a (bomb-count 'a))
     (* b (bomb-count 'b))
     (* c (bomb-count 'c))))

;; there's definitely a better way to write this lmao
(define %distinct
  (%rel (x y z a b c)
        [(x y z a b c)
         (%=/= x y)
         (%=/= x z)
         (%=/= x a)
         (%=/= x b)
         (%=/= x c)
         (%=/= y z)
         (%=/= y a)
         (%=/= y b)
         (%=/= y c)
         (%=/= z a)
         (%=/= z b)
         (%=/= z c)
         (%=/= a b)
         (%=/= a c)
         (%=/= b c)]))

(define %sums-to-target
  (%rel (x y z a b c target)
        [(x y z a b c target)
         (%is target (bomb-total x y z a b c))]))

;; given hit numbers for each type of bomb and a number of targets to hit
;; can that many of each type of bomb be hit, do they satisify distinct rule, and do they hit the right number of targets?
(define %hits
  (%rel (x y z a b c)
        [(x y z a b c)
         (%can-hit 'x x)
         (%can-hit 'y y)
         (%can-hit 'z z)
         (%can-hit 'a a)
         (%can-hit 'b b)
         (%can-hit 'c c)
         (%distinct x y z a b c)
         (%sums-to-target x y z a b c TARGET-TOTAL)]))

#;(displayln "All possible combinations from start of puzzle")
#;(%find-all (x y z a b c) (%hits x y z a b c))
#;(displayln "")
(%find-all (x y z a b c)
           (%and (%hits x y z a b c)
                 (%>= x 2)
                 (%>= y 3)
                 (%>= z 1)
                 (%>= a 2)
                 (%>= c 2)))
