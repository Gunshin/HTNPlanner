(define (domain runescape)
    (:requirements :fluents :typing)
    (:types
        resource - item
        wood plank - resource
        bank sawmill - area
        number
    )
    (:predicates
        (at ?place - area)
        (contains ?area - area ?resource - resource)
		(conversion ?resource_a ?resource_b - resource)
    )
    (:functions
        (banked ?item - item)
        
        (inventory_max)
        (inventory_left)
        (inventory_has_item ?item - item)
    )
    
    (:action Cut_Down_Tree
        :parameters (?resource - wood ?area - area)
		:values (~count ~test - integer-range)
        :precondition 
        (and 
			(at ?area)
            (contains ?area ?resource)
			(== (~test) (* 2 (~count)))
			(or
				(and
					(> (~count) 0)
					(<= (~count) (inventory_left))
				)
			)
			(or
				(and
					(> (~test) 0)
					(<= (~test) 10)
				)
			)
        )
        :effect 
        (and
            (decrease (inventory_left) (~count))
            (increase (inventory_has_item ?resource) (~count))
        )
    )
	
    (:action Move_To
        :parameters (?from ?to - area)
        :precondition 
        (and 
            (at ?from)
            (not (at ?to))
        )
        :effect 
        (and
            (at ?to)
            (not (at ?from))
        )
    )
)
