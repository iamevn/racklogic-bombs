#lang racket
;; logic bombs 137
;; idk how to get going with this puzzle so I guess it's time to learn racklog https://docs.racket-lang.org/racklog/
(require racklog)
(require "possible-hits.rkt")

;; constructor for a list representing a type of bomb, has a name, count, and list of how many targets each bomb of that type can see
(define (bomb name count can-see)
  (list 'bomb name count can-see))

(define %name
  (%rel (name)
        [((bomb name (_) (_)) name)]))

(define %bomb-count
  (%rel (count)
        [((bomb (_) count (_)) count)]))

(define %can-see
  (%rel (can-see)
        [((bomb (_) (_) can-see) can-see)]))

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
(%find-all (x y z a b c)
           (let ([target-count 34]
                 [bombs (list (bomb 'x 2 '[(3 2)
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
                              (bomb 'c 1 '[(2 1 3)]))])
             (%and (%hits target-count
                          bombs
                          (list x y z a b c))
                   (%>= x 2)
                   (%>= z 1)
                   (%>= y 3)
                   (%>= a 2)
                   (%>= c 2))))
