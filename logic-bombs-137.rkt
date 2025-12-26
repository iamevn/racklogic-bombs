#lang racket
;; logic bombs 137
;; idk how to get going with this puzzle so I guess it's time to learn racklog https://docs.racket-lang.org/racklog/

(require racklog)
(require "possible-hits.rkt")

;; how many of a type of bomb are there?
(define %bomb-count %empty-rel)

;; how many targets can each bomb of a type see?
(define %can-see %empty-rel)

;; can a bomb hit given number of targets?
(define %can-hit
  (%rel (bomb n can-see can-hit)
        [(bomb n)
         (%can-see bomb can-see)
         (%is can-hit (possible-hits can-see))
         (%member n can-hit)]))

;; if a type of bomb hits a number of targets, how many total do all bombs of that type hit?
(define %bomb-total
  (%rel (bomb hit total-hit count)
        [(bomb hit total-hit)
         (%bomb-count bomb count)
         (%is total-hit (* hit count))]))

;; %true if list has no repeated elements
(define %distinct
  (%rel (head tail)
        [('()) %true]
        [((cons head tail))
         (%not (%member head tail))
         (%distinct tail)]))

;; for a list of bombs and a list of how many targets that type of bomb hits, how many total targets are hit?
(define %combined-total
  (%rel (bombs hits total totals)
        [(bombs hits total)
         (%andmap %bomb-total bombs hits totals)
         (%is total (apply + totals))]))

;; number of targets, list of bombs, list of hits each bomb does
(define %hits
  (%rel (target-count bombs hits)
        [(target-count bombs hits)
         (%andmap %can-hit bombs hits)
         (%distinct hits)
         (%combined-total bombs hits target-count)]))

;;;;;;;; solve it ;;;;;;;;;

(%assert! %bomb-count ()
          [('x 2)]
          [('y 4)]
          [('z 3)]
          [('a 1)]
          [('b 1)]
          [('c 1)])

(%assert! %can-see ()
          [('x '[(3 2)
                 (3 1 2)])]
          [('y '[(3 3 3)
                 (3 1 {1 2})
                 (3 3 3)
                 (1 2 2)])]
          [('z '[({1 2} 1 3)
                 (1 3)
                 ({1 2} 2)])]
          [('a '[(3 1 {1 2})])]
          [('b '[(3 3 1)])]
          [('c '[(2 1 3)])])

(%find-all (x y z a b c)
           (%and (%hits 34
                        '(x y z a b c)
                        (list x y z a b c))
                 (%>= x 2)
                 (%>= y 3)
                 (%>= z 1)
                 (%>= a 2)
                 (%>= c 2)))
