(define (problem runescape_test)
    (:domain runescape)
    (:objects
        logs - wood
        oak - wood
        willow - wood
        
        logs_area - area
        oak_area - area
        willow_area - area
        bank_area - bank
    )
    (:init
        (= (inventory_max) 28)
        (= (inventory_left) 28)
		
        (at bank_area)
        
        (contains logs_area logs)
        (contains oak_area oak)
        (contains willow_area willow)
		
		(= (one) 1)
		(= (five) 5)
		(= (ten) 10)
		(= (twenty) 20)
    )
    (:goal
        (and
            (== (banked logs) 20)
			(== (banked willow) 20)
			(== (inventory_has_item logs) 10)
			(== (inventory_has_item willow) 10)
        )
    )
)