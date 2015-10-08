(define (domain test)
    (:requirements :fluents :typing)
    (:types
        bank sawmill - area
	)
    (:predicates
        (at ?place - area)
		(connected ?a ?b - area)
    )
    (:functions
    )

    (:action Move_To
        :parameters (?from ?to - area)
        :precondition 
        (and 
            (at ?from)
            (not (at ?to))
			(connected ?from ?to)
        )
        :effect 
        (and
            (at ?to)
            (not (at ?from))
        )
    )
)
