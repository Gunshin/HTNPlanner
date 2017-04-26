(define

;;@problem_name@v1_87291_nb_50_001
(problem v1_87291_nb_50_001)

(:domain motion_planning_v3)

(:objects 
          w_0 w_1 - waypoint
          r - rover )

(:init

    ;; @energy@["r", 20]
    (= (energy r) 20)
    ;; @max_energy@["r", 100]
    (= (max_energy r) 100)

    ;;@location@["r", [9, -10]]
    (= (x r) 9) (= (y r) -10)

    ;;@location@["w_0", [-25,0]]
    (= (x w_0) -25) (= (y w_0) 0)
    ;;@location@["w_1", [25,40]]
    (= (x w_1) 25) (= (y w_1) 40)

)
(:goal (and
            ;;@goal_location@[19, 43]
            (== (x r) 19) (== (y r) 43)
            (taken_picture w_0)
            (taken_picture w_1)
	     )
)
)
