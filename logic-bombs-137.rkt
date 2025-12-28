#lang racket
;; logic bombs 137
;; idk how to solve this so I guess it's time to learn racklog https://docs.racket-lang.org/racklog/
(require racklog)
(require "racklogic-bombs.rkt")

(%find-all (x y z a b c)
           (%and
            ; possible solutions by what bombs can see
            (%hits 34
                   (list (bomb 'x 2 '[(3 2)
                                      (3 1 2)])
                         (bomb 'y 4 '[(3 3 3)
                                      (3 1 {1 2})
                                      (3 3 3)
                                      (1 2 2)])
                         (bomb 'z 3 '[({1 2} 1 3)
                                      (1 3)
                                      ({1 2} 2)])
                         (bomb 'a 1 '[(3 1 {1 2})])
                         (bomb 'b 1 '[(3 3 1)])
                         (bomb 'c 1 '[(2 1 3)]))
                   (list x y z a b c))
            ; rule out obviously wrong counts
            (%>= x 2)
            (%>= y 3)
            (%>= z 1)
            (%>= a 2)
            (%>= c 2)
            ; based on that, b must be 6
            (%=:= b 6)))
