#lang racket
(require racklog)

(provide (all-defined-out))

(define (%pred-true pred?)
  (%rel (x)
        [(x)
         (%is #true (pred? x))]))

;; %true if list has no repeated elements
(define %distinct
  (%rel (head tail)
        [('()) %true]
        [((cons head tail))
         (%not (%member head tail))
         (%distinct tail)]))

;; idk, not reversible very well
#;(define %length
  (%rel (lst len rest rest-len)
        [('() 0)]
        [((cons (_) rest) len)
         (%length rest rest-len)
         (%is len (+ rest-len 1))]))

(define %filter
  (%rel (%goal x xs ys)
        [((_) '() '())]
        [(%goal (cons x xs) (cons x ys))
         (%goal x)
         (%filter %goal xs ys)]
        [(%goal (cons x xs) ys)
         (%not (%goal x))
         (%filter %goal xs ys)]))

(define %remove-all
  (%rel (lst x y xs without-x)
        [((_) '() '())]
        [(x (cons x xs) without-x)
         (%remove-all x xs without-x)]
        [(x (cons y xs) (cons y without-x))
         (%/= x y)
         (%remove-all x xs without-x)]))

(define %implies
  (λ (%P %Q)
    (%if-then-else %P %Q
                   (%not %P))))

;;;;;; working on these

#;(define %singles
  (%rel (lst just-singles x xs)
        [('() '())]
        [(lst lst)
         (%distinct lst)]
        [(lst just-singles)
         (%append (list x) xs lst)]))
