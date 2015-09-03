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
		:values (~count - integer-range)
        :precondition 
        (and 
			(at ?area)
            (contains ?area ?resource)
            (or
				(and
					(>= (inventory_left) (~count))
					(> (~count) 0)
				)
				(and
					(> (~count) 50)
					(< (~count) 60)
				)
			)
        )
        :effect 
        (and
            (decrease (inventory_left) (~count))
            (increase (inventory_has_item ?resource) (~count))
        )
    )
	
	(:action Create_Plank
        :parameters (?resource - wood ?plank - plank ?area - sawmill)
		:values (~count - integer-range)
        :precondition 
        (and 
			(at ?area)
            (>= (inventory_has_item ?resource) (~count))
			(conversion ?resource ?plank)
			(> (~count) 0)
        )
        :effect 
        (and
            (decrease (inventory_has_item ?resource) (~count))
			(increase (inventory_has_item ?plank) (~count))
        )
    )
	
	(:action Bank_Item
        :parameters (?bank - bank ?item - item)
		:values (~count - integer-range)
        :precondition 
        (and 
            (at ?bank)
            (< (inventory_left) (inventory_max))
			(>= (inventory_has_item ?item) (~count))
			(> (~count) 0)
        )
        :effect 
        (and
			(increase (banked ?item) (~count))
			(decrease (inventory_has_item ?item) (~count))
            (increase (inventory_left) (~count))
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
