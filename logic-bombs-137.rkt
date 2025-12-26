#lang racket
;; logic bombs 137
;; idk how to get going with this puzzle so I guess it's time to learn racklog https://docs.racket-lang.org/racklog/

(require racklog)
(require "possible-hits.rkt")

(define bomb
  ;; structure-builder for a bomb
  (λ (name count hits can-see)
    (list 'bomb name count hits can-see)))
(define %bomb-name
  (%rel (name count hits can-see)
        [((bomb name count hits can-see) name)]))
(define %bomb-count
  (%rel (name count hits can-see)
        [((bomb name count hits can-see) count)]))
(define %bomb-hits
  (%rel (name count hits can-see)
        [((bomb name count hits can-see) hits)]))
(define %bomb-can-see
  (%rel (name count hits can-see)
        [((bomb name count hits can-see) can-see)]))

(define %bomb-can-hit
  (%rel (bomb can-see can-hit)
        [(bomb can-hit)
         (%bomb-can-see bomb can-see)
         (%is can-hit (possible-hits can-see))]))

(define %bomb-total
  (%rel (bomb count hits total)
        [(bomb total)
         (%bomb-count bomb count)
         (%bomb-hits bomb hits)
         (%is total (* count hits))]))
(define %combined-total
  (%rel (bombs total totals)
        [(bombs total)
         (%let (b n)
               (%bag-of n (%bomb-total b n) totals))
         (%is total (apply + totals))]))

(define %distinct
  ;; %true for lists containing no duplicate elements
  (%rel (l h t)
        [('()) %true]
        [((cons h t))
         (%not (%member h t))
         (%distinct t)]))
(define %hits-distinct
  (%rel (bombs hits)
        [(bombs)
         (%let (b n)
               (%bag-of n (%bomb-hits b n) hits))
         (%distinct hits)]))

(%find-all (x y z a b c)
           (%and
            (%>= x 2)
            (%>= y 3)
            (%>= z 1)
            (%>= a 2)
            (%>= c 2)
            (%let (bx by bz ba bb bc)
                  (%is bx (bomb 'x 2 x '[(3 2)
                                         (3 1 2)]))
                  (%is by (bomb 'y 4 y '[(3 3 3)
                                         (3 1 {1 2})
                                         (3 3 3)
                                         (1 2 2)]))
                  (%is bz (bomb 'z 3 z '[({1 2} 1 3)
                                         (1 3)
                                         ({1 2} 2)]))
                  (%is ba (bomb 'a 1 a '[(3 1 {1 2})]))
                  (%is bb (bomb 'b 1 b '[(3 3 1)]))
                  (%is bc (bomb 'c 1 c '[(2 1 3)]))
                  (let ([bombs (list bx by bz ba bb bc)])
                    (%hits-distinct bombs)
                    (%combined-total bombs 34)))))
