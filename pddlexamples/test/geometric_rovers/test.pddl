(define

;;@problem_name@v1_87291_nb_50_001
(problem v1_87291_nb_50_001)

(:domain motion_planning_v3)

(:objects b_0 b_1 b_2 b_3 b_4 b_5 b_6 b_7 b_8 b_9 b_10 b_11 b_12 b_13 b_14 b_15 b_16 b_17 b_18 b_19 b_20 b_21 b_22
          b_23 b_24 b_25 b_26 b_27 b_28 b_29 b_30 b_31 b_32 b_33 b_34 b_35 b_36 b_37 b_38 b_39 b_40 b_41 b_42 b_43 b_44 b_45 b_46 b_47 b_48 b_49 - obstacle
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


    ;;@bounding_box@ {"coordinates": [[53.64261344365215, -49.448785459265075], [-52.41616327363562, -49.448785459265075], [-52.41616327363562, 49.76192381544372], [53.64261344365215, 49.76192381544372]]}
    (= (max_x) 53) (= (max_y) 49) (= (min_x) -52) (= (min_y) -49)

)
(:goal (and
            ;;@goal_location@[19, 43]
            (== (x r) 19) (== (y r) 43)
            (taken_picture w_0)
            (taken_picture w_1)
	     )
)
)
