(define (problem test_test)
    (:domain test)
    (:objects
        logs_area - area
        oak_area - area
        willow_area - area
        bank_area - bank
		sawmill_area - sawmill
    )
    (:init
        (at bank_area)
		
		(connected bank_area logs_area)
		(connected logs_area oak_area)
		(connected oak_area willow_area)
    )
    (:goal
        (and
			(at willow_area)
        )
    )
)