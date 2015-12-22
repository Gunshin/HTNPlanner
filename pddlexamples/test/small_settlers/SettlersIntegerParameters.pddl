(define (domain civ) 
  (:requirements :fluents :typing :conditional-effects) 
  (:types place vehicle - store 
	  resource) 
  (:predicates 
   (woodland ?p - place) 
   (mountain ?p - place) 
   (metalliferous ?p - place) 
 
   (has-cabin ?p - place) 
   (has-coal-stack ?p - place) 
   (has-quarry ?p - place) 
   (has-mine ?p - place) 
   (has-sawmill ?p - place) 
   (has-ironworks ?p - place) 

   ) 
  (:functions 
   (available ?r - resource ?s - store)
	(labour)
	(resource-use)
	(pollution)
	(housing ?p - place)
   ) 
  (:constants timber wood coal stone iron ore - resource)
 
  (:action build-cabin 
   :parameters (?p - place) 
   :precondition (and
					(woodland ?p)
					(not (has-cabin ?p))
				)
   :effect (and (increase (labour) 1) (has-cabin ?p)) )
 
  (:action build-quarry 
   :parameters (?p - place) 
   :precondition (and 
					(mountain ?p)
					(not (has-quarry ?p))
				)
   :effect (and (increase (labour) 2) (has-quarry ?p)))
 
  (:action build-coal-stack 
   :parameters (?p - place) 
   :precondition (and 
					(>= (available timber ?p) 1)
					(not (has-coal-stack ?p))
				)
   :effect (and (increase (labour) 2) 
		(decrease (available timber ?p) 1) 
		(has-coal-stack ?p))) 
 
  (:action build-sawmill 
   :parameters (?p - place) 
   :precondition (and 
					(>= (available timber ?p) 2)
					(not (has-sawmill ?p))
				)
   :effect (and (increase (labour) 2)
		(decrease (available timber ?p) 2) 
		(has-sawmill ?p))) 
 
  (:action build-mine 
   :parameters (?p - place) 
   :precondition (and
					(metalliferous ?p) 
					(>= (available wood ?p) 2)
					(not (has-mine ?p))
				)
   :effect (and (increase (labour) 3)
		(decrease (available wood ?p) 2) 
		(has-mine ?p))) 
 
  (:action build-ironworks 
   :parameters (?p - place) 
   :precondition (and
					(>= (available stone ?p) 2) 
					(>= (available wood ?p) 2)
					(not (has-ironworks ?p))
			  ) 
   :effect (and (increase (labour) 3)
		(decrease (available stone ?p) 2) 
		(decrease (available wood ?p) 2) 
		(has-ironworks ?p))) 
	
  (:action build-house
   :parameters (?p - place)
   :values (~count - integer-range)
   :precondition (and 
					(>= (available wood ?p) 1)
					(>= (available stone ?p) 1)
					(> (~count) 0)
					(<= (~count) (available wood ?p))
					(<= (~count) (available stone ?p))
				)
   :effect (and (increase (housing ?p) (~count))
		(decrease (available wood ?p) (~count))
		(decrease (available stone ?p) (~count))))
	
  (:action fell-timber 
   :parameters (?p - place) 
   :values (~count - integer-range)
   :precondition (and
					(has-cabin ?p)
					(> (~count) 0)
					(<= (~count) 10)
				)
   :effect (and (increase (available timber ?p) (~count))
		(increase (labour) 1))
   ) 
 
  (:action break-stone 
   :parameters (?p - place) 
   :values (~count - integer-range)
   :precondition (and
					(has-quarry ?p)
					(> (~count) 0)
					(<= (~count) 10)
				)
   :effect (and (increase (available stone ?p) (~count))
		(increase (labour) 1)
		(increase (resource-use) 1)
		)) 
 
  (:action mine-ore 
   :parameters (?p - place)
   :values (~count - integer-range)
   :precondition (and
					(has-mine ?p)
					(> (~count) 0)
					(<= (~count) 10)
				)
   :effect (and (increase (available ore ?p) (~count))
		(increase (resource-use) 2)
	)) 
 
  ;; C.1: Refining resources. 
 
  (:action burn-coal 
   :parameters (?p - place)
   :values (~count - integer-range)
   :precondition (and 
					(has-coal-stack ?p)
					(>= (available timber ?p) 1)
					(> (~count) 0)
					(<= (~count) 10)
					(<= (~count) (available timber ?p))
				)
   :effect (and (decrease (available timber ?p) (~count)) 
		(increase (available coal ?p) (~count))
		(increase (pollution) 1))) 
 
  (:action saw-wood 
   :parameters (?p - place)
   :values (~count - integer-range)
   :precondition (and 
					(has-sawmill ?p)
					(>= (available timber ?p) 1)
					(> (~count) 0)
					(<= (~count) 10)
					(<= (~count) (available timber ?p))
				)
   :effect (and (decrease (available timber ?p) (~count)) 
		(increase (available wood ?p) (~count)))) 
 
  (:action make-iron 
   :parameters (?p - place)
   :values (~count - integer-range)
   :precondition (and 
					(has-ironworks ?p)
					(>= (available ore ?p) 1) 
					(>= (available coal ?p) 2)
					(> (~count) 0)
					(<= (~count) 10)
					(<= (~count) (available ore ?p))
					(<= (~count) (* (available coal ?p) 2))
				) 
   :effect (and (decrease (available ore ?p) 1) 
		(decrease (available coal ?p) (* (~count) 2)) 
		(increase (available iron ?p) (~count))
		(increase (pollution) 2))) 
 
   ) 
