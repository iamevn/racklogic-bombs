#lang racket
;; idk how to solve this so I guess it's time to learn racklog https://docs.racket-lang.org/racklog/
(require racklog)
(require "racklog-helpers.rkt")
(require "racklogic-bombs.rkt")

(define (run)
  (%find-all (x y a b n)
             ; possible solutions by what bombs can see
             (%hits 15
                    (list (bomb 'x 1 '(({1 2 3} {1 2} 1 1)))
                          (bomb 'y 1 '((1 1 {1 2 3} {1 2})))
                          (bomb 'a 1 '(({1 2 3} {1 2 3})))
                          (bomb 'b 1 '(({1 2 3} {1 2 3})))
                          (bomb 'n 1 '(({1 2} {1 2} {1 2 3}))))
                    (list x y a b n))
             (%not (%member 0 (list x y a n)))
             (%implies (%=:= b 0)
                       (%and (%member a '(3 4 5))
                             (%member x '(3 4 5))
                             (%member y '(1 2 3 4))
                             (%member n '(4 5))))))
(define (run2)
  ;; partition board
  (%find-all (x y a b n)
             (%hits 15
                    (list (bomb 'x 1 '((1 {1 2} 1 1)))
                          (bomb 'y 1 '((1 1 {1 2})))
                          (bomb 'a 1 '(({1 2} {1 2 3})))
                          (bomb 'b 1 '(({1 2 3} 1)))
                          (bomb 'n 1 '(({1 2} {1 2 3}))))
                    (list x y a b n))
             (%= b 4)
             (%= y 2)
             (%>= n 1)
             (%>= x 1)
             (%> a 2)
             (%implies (%= n 1) (%= x 3))
             (%>= n 4)
             ))

(define (Q res v)
  (let* ([foundset (for/set ([l res])
                    (cdr (assoc v l)))]
         [found (set->list foundset)]
         [only-one? (equal? (length found) 1)])
    (if only-one? (car found) foundset)))

(define res (run2))
res
(displayln (~a "Found " (length res) " solutions with possible values"))
(for ([v '(x y a b n)])
  (displayln (~a v ": " (Q res v))))
