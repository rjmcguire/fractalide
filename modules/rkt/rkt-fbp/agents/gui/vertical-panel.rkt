#lang racket/base

(require fractalide/modules/rkt/rkt-fbp/agent
         fractalide/modules/rkt/rkt-fbp/agents/gui/helper)


(require racket/gui/base
         racket/match
         racket/list)
(require (rename-in racket/class [send class-send]))

(define (generate-hp input)
  (lambda (frame)
    (let* ([hp (new vertical-panel% [parent frame])])
      (send (input "acc") hp))))

(define (process-msg msg widget input output output-array)
  (define managed #f)
  (set! managed (area-manage widget msg output output-array))
  (set! managed (window-manage widget msg output output-array))
  (set! managed (area-container-manage widget msg output output-array))
  (if managed
      (void)
      (match msg
             ;TODO: manage orientation
             [else (send-action output output-array msg)])))

(define-agent
  #:input '("in") ; in port
  #:input-array '("place")
  #:output '("out") ; out port
  #:output-array '("out")
  (fun
    (define acc (try-recv (input "acc")))
    (define msg-in (try-recv (input "in")))
    ; Init the first time
    (define hp (if acc
                   acc
                   (begin
                     (send (output "out") (cons 'init (generate-hp input)))
                     (cons '() (recv (input "acc"))))))

    (if msg-in
        ; TRUE : A message in the input port
        (process-msg msg-in (cdr hp) input output output-array)
        ; FALSE : At least a message in the input array port
        ; Change the accumulator HP with set!
        (for ([(place containee) (input-array "place")])
             (define msg (try-recv containee))
             (if msg
                 (match msg
                        [(cons 'init cont)
                         ; Add it
                         (cont (cdr hp))
                         ; order
                         (class-send (cdr hp) change-children
                                     (lambda (act)
                                       ; get the new one
                                       (define val (last act))
                                       ; add it in the acc
                                       (set! hp (cons (add-ordered (car hp) place val)
                                                      (cdr hp)))
                                       (map (lambda (x) (cdr x))
                                            (car hp))))]
                        [(cons 'delete #t)
                         (set! hp (cons (remove place (car hp)
                                                (lambda (x y)
                                                  (= x (car y))))
                                        (cdr hp)))
                         (class-send (cdr hp) change-children
                                     (lambda (act)
                                       (map (lambda (x) (cdr x))
                                            (car hp))))]
                        [else (send-action output output-array msg)])
                 void)))

    (send (output "acc") hp)))

(define (add-ordered acc key val)
  (define (add-ordered ls acc)
    (cond
      [(empty? ls) (reverse (cons (cons key val) acc))]
      [else
        (if (> (caar ls) key)
            ; must add
            (append (reverse (cons (cons key val) acc)) ls)
            ; continue
            (add-ordered (cdr ls) (cons (car ls) acc)))]))
  (add-ordered acc '()))
