(define (domain cash_withdraw) 
  (:requirements :fluents :typing :conditional-effects) 
  (:types
    person
    location
    machine 
  ) 
  (:predicates 
    (located ?m - machine ?a - location)
    (at ?p - person ?a - location)
    (snacksat ?a - location)
    (gotsnacks ?p - person)
    (canwithdraw ?p - person ?m - machine)
   )
  (:functions
        (inpocket ?p - person)
        (balance ?m - machine)
   ) 

    (:action WithdrawCash
    :parameters (?p - person ?a - location ?m - machine)
    :values (~cash - integer-range)

    :precondition (and 
        (at ?p ?a)
        (located ?m ?a)
        (> ~cash 0)
        (<= ~cash 20)
        (<= (* inc ~cash) (balance ?m))
        (canwithdraw ?p ?m)
    )

    :effect (and
        (decrease (balance ?m) (* inc ~cash))
        (increase (inpocket ?p) (* inc ~cash))
    ))

 
    (:action BuySnacks
    :parameters (?p - person ?a - location)

    :precondition (and
        (at ?p ?a)
        (snacksat ?a)
        (>= (inpocket ?p) 3)
    )

    :effect (and
        (decrease (inpocket ?p) 3)
        (gotsnacks ?p)
    ))

	(:action move
	:parameters (?p - person ?c ?a - location)
    :precondition (and
		(at ?p ?c)
        (not (at ?p ?a))
    )

    :effect (and
        (at ?p ?a)
		(not (at ?p ?c))
    ))
	
)
