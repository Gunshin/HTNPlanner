(define (domain civ) 
  (:requirements :fluents :typing :conditional-effects) 
  (:types place vehicle - store 
	  resource) 
  (:predicates 
   (connected-by-land ?p1 - place ?p2 - place) 
   (connected-by-rail ?p1 - place ?p2 - place) 
   (connected-by-sea ?p1 - place ?p2 - place) 
   (woodland ?p - place) 
   (mountain ?p - place) 
   (metalliferous ?p - place) 
   (by-coast ?p - place) 
 
   (has-cabin ?p - place) 
   (has-coal-stack ?p - place) 
   (has-quarry ?p - place) 
   (has-mine ?p - place) 
   (has-sawmill ?p - place) 
   (has-ironworks ?p - place) 
   (has-docks ?p - place) 
   (has-wharf ?p - place) 
   (is-cart ?v - vehicle) 
   (is-train ?v - vehicle) 
   (is-ship ?v - vehicle) 
   (is-at ?v - vehicle ?p - place) 

   (potential ?v - vehicle)
   ) 
  (:functions 
   (available ?r - resource ?s - store)
   (space-in ?v - vehicle) 
	(labour)
	(resource-use)
	(pollution)
	(housing ?p - place)
   ) 
  (:constants timber wood coal stone iron ore - resource)
 
  ;; B.1: Building structures. 
 
  (:action build-cabin 
   :parameters (?p - place) 
   :precondition (woodland ?p) 
   :effect (and (increase (labour) 1) (has-cabin ?p)) )
 
  (:action build-coal-stack 
   :parameters (?p - place) 
   :precondition (>= (available timber ?p) 1) 
   :effect (and (increase (labour) 2) 
		(decrease (available timber ?p) 1) 
		(has-coal-stack ?p))) 
 
  ;; C.1: Obtaining raw resources. 
 
  (:action fell-timber 
   :parameters (?p - place) 
   :precondition (has-cabin ?p) 
   :effect (and (increase (available timber ?p) 1)
		(increase (labour) 1))
   )
 
)
