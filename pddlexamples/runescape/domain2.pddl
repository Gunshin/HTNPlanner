(define (domain runescape)
    (:requirements :fluents :typing)
    (:types
        resource - item
        wood plank - resource
        bank sawmill - area
    )
    (:predicates
        (at ?place - area)
        (contains ?area - area ?resource - resource)
		(conversion ?resource_a ?resource_b - resource)
		(connected ?a ?b - area)
    )
    (:functions
        (banked ?item - item)
        
        (inventory_max)
        (inventory_left)
        (inventory_has_item ?item - item)
    )
    
    (:action Cut_Down_Tree
        :parameters (?resource - wood ?area - area)
		:values (~count - integer-range)
        :precondition 
        (and 
			(at ?area)
            (contains ?area ?resource)
			(> (~count) 0)
			(<= (~count) (inventory_left))
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
			(connected ?from ?to)
        )
        :effect 
        (and
            (at ?to)
            (not (at ?from))
        )
    )
)
