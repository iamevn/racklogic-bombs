#lang racket
;; logic bombs 137
;; idk how to get going with this puzzle so I guess it's time to learn racklog https://docs.racket-lang.org/racklog/

(require racklog)
(require "possible-hits.rkt")

(define TARGET-TOTAL 34)

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
