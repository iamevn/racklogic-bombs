#lang racket
;; logic bombs 137
;; idk how to get going with this puzzle so I guess it's time to learn racklog https://docs.racket-lang.org/racklog/

(require racklog)
(require "possible-hits.rkt")

;; how many targets can each bomb of a type see?
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

;; how many of a type of bomb are there?
(define %bomb-count %empty-rel)
(%assert! %bomb-count ()
          [('x 2)]
          [('y 4)]
          [('z 3)]
          [('a 1)]
          [('b 1)]
          [('c 1)])

;; if a type of bomb hits a number of targets, how many total do all bombs of that type hit?
(define %bomb-total
  (%rel (bomb hit total-hit count)
        [(bomb hit total-hit)
         (%bomb-count bomb count)
         (%is total-hit (* hit count))]))

;; how many do all bombs hit given counts for each type?
(define %combined-total
  (%rel (x y z a b c total x-total y-total z-total a-total b-total c-total)
        [(x y z a b c total)
         (%bomb-total 'x x x-total)
         (%bomb-total 'y y y-total)
         (%bomb-total 'z z z-total)
         (%bomb-total 'a a a-total)
         (%bomb-total 'b b b-total)
         (%bomb-total 'c c c-total)
         (%is total (+ x-total y-total z-total a-total b-total c-total))]))

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

;; given hit numbers for each type of bomb and a number of targets to hit
;; can that many of each type of bomb be hit, do they satisify distinct rule, and do they hit the right number of targets?
(define %hits
  (%rel (x y z a b c total)
        [(x y z a b c total)
         (%can-hit 'x x)
         (%can-hit 'y y)
         (%can-hit 'z z)
         (%can-hit 'a a)
         (%can-hit 'b b)
         (%can-hit 'c c)
         (%distinct x y z a b c)
         (%combined-total x y z a b c total)]))
(define TARGETS 34)

#;(displayln "All possible combinations from start of puzzle")
#;(%find-all (x y z a b c) (%hits x y z a b c TARGETS))
#;(displayln "")
(%find-all (x y z a b c)
           (%and (%hits x y z a b c TARGETS)
                 (%>= x 2)
                 (%>= y 3)
                 (%>= z 1)
                 (%>= a 2)
                 (%>= c 2)))
