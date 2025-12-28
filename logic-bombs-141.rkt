#lang racket
;; idk how to solve this so I guess it's time to learn racklog https://docs.racket-lang.org/racklog/
(require racklog)
(require "racklogic-bombs.rkt")

(define (can-see-dup n)
  (build-list n (λ (_) '({1 2 3 4 5}))))

(%find-all (x y n a b)
           (%let (top-row bottom-row)
                 (%and
                  (%= top-row (list b x n y b x a b))
                  (%= bottom-row (list a y n x a y b a))
                  ; possible solutions by what bombs can see
                  (%hits 48
                         (list (bomb 'x 3 (can-see-dup 3))
                               (bomb 'y 3 (can-see-dup 3))
                               (bomb 'n 2 (can-see-dup 2))
                               (bomb 'a 4 (can-see-dup 4))
                               (bomb 'b 4 (can-see-dup 4)))
                         (list x y n a b))
                  (%andmap (curry %<= 1) (list x y n a b))
                  (%=:= n 3)
                  (%=/= a 1)
                  (%=/= x 2)
                  (%=/= a 4)
                  (%member 1 (list x b))
                  (%member 2 (list y a)))))
