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
        (>= ~cash 5)
        (<= ~cash (balance ?m))
        (canwithdraw ?p ?m)
    )

    :effect (and
        (decrease (balance ?m) ~cash)
        (increase (inpocket ?p) ~cash)
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

)
