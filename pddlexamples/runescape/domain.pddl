(define (domain runescape)
    (:requirements :fluents :typing)
    (:types
        resource - item
        wood - resource
        bank - area
        number
    )
	(:constants
		one five ten twenty - number
	)
    (:predicates
        (at ?place - area)
        (contains ?area - area ?resource - resource)
    )
    (:functions
        (banked ?item - item)
        
        (inventory_max)
        (inventory_left)
        (inventory_has_item ?item - item)
		
		(one)
		(five)
		(ten)
		(twenty)
    )
    
    (:action Cut_Down_Tree
        :parameters (?resource - wood ?area - area ?count - number)
        :precondition 
        (and 
			(at ?area)
            (contains ?area ?resource)
            (>= (inventory_left) (?count))
        )
        :effect 
        (and
            (decrease (inventory_left) (?count))
            (increase (inventory_has_item ?resource) (?count))
        )
    )
	
	(:action Bank_Item
        :parameters (?bank - bank ?item - item ?count - number)
        :precondition 
        (and 
            (at ?bank)
            (< (inventory_left) (inventory_max))
			(>= (inventory_has_item ?item) (?count))
        )
        :effect 
        (and
			(increase (banked ?item) (?count))
			(decrease (inventory_has_item ?item) (?count))
            (increase (inventory_left) (?count))
        )
    )
    
    (:action Bank_All
        :parameters (?bank - bank)
        :precondition 
        (and 
            (at ?bank)
            (< (inventory_left) (inventory_max))
        )
        :effect 
        (and
            (forall (?item - item)
                (when 
                    (and 
                        (> (inventory_has_item ?item) 0)
                    )
                    (and
                        (increase (banked ?item) (inventory_has_item ?item))
                        (= (inventory_has_item ?item) 0)
                    )
                )
            )
            (= (inventory_left) (inventory_max))
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
