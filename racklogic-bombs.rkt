#lang racket
;; goals for finding and narrowing-down potential bomb values for logic bombs puzzles
(require racklog)
(require "possible-hits.rkt")
(require "racklog-helpers.rkt")

(provide (all-defined-out))

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

;;;;;;;; example solves ;;;;;;;;;
(module+ main

  (define target-count 34)
  (define x-bomb
    (bomb 'x 2 '[(3 1 2)
                 (3 1 2)]))
  (define y-bomb
    (bomb 'y 4 '[(3 3 3)
                 (3 1 {1 2})
                 (3 3 3)
                 (1 2 2)]))
  (define z-bomb
    (bomb 'z 3 '[({1 2} 1 3)
                 (1 3 3)
                 ({1 2} 1 2)]))
  (define a-bomb
    (bomb 'a 1 '[(3 1 {1 2})]))
  (define b-bomb
    (bomb 'b 1 '[(3 3 1)]))
  (define c-bomb
    (bomb 'c 1 '[(2 1 3)]))
  (define bombs (list x-bomb y-bomb z-bomb a-bomb b-bomb c-bomb))
  
  (displayln "All possible combinations from start of puzzle:")
  (%find-all (x y z a b c)
             (%hits target-count
                    bombs
                    (list x y z a b c)))

  (define x-bomb-filtered
    (bomb 'x 2 '[(3 2)
                 (3 1 2)]))
  (define z-bomb-filtered
    (bomb 'z 3 '[({1 2} 1 3)
                 (1 3)
                 ({1 2} 2)]))
  (define bombs-filtered (list x-bomb-filtered y-bomb z-bomb-filtered a-bomb b-bomb c-bomb))
  
  (displayln "Remove clearly impossible options for %can-see:")
  (%find-all (x y z a b c)
             (%hits target-count
                    bombs-filtered
                    (list x y z a b c)))

  (displayln "Constrain hit counts where possible:")
  (%find-all (x y z a b c)
             (%and (%hits target-count
                          bombs-filtered
                          (list x y z a b c))
                   (%>= x 2)
                   (%>= z 1)
                   (%>= y 3)
                   (%>= a 2)
                   (%>= c 2))))
