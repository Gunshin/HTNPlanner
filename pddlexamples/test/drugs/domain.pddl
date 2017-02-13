



;;One idea for the new domain (I seem to recall mentioning this one before) is "on-line shopping" (previously I said something about buying medicines). 
;;Where there are discrete units and combinations (savings of buying in bulk) to be costed against 
;;wastage if not used in time (sell by date) and limits on maximum that can be stored etc etc. 







(define (domain online_ordering) 
	(:requirements :fluents :typing :conditional-effects) 
	(:types
		drug
		store
		batch
	)
	(:predicates 
		(batches ?d - drug ?b - batch)
	)
	(:functions
		(stored ?loc - store ?d - drug)
		(target_storage ?loc - store ?d - drug)
		(drug_batch_count ?b - batch)
	) 
	
	(:action Order
		:parameters (?loc - store ?d - drug ?b - batch)
		:values (~count - integer-range)
		:precondition (and 
			(> (~count) 0)
			(< 
				(* (~count) (drug_batch_count ?b))
				(- (target_storage ?loc ?d) (stored ?loc ?d) )
			)
			(batches ?d ?b)
		)
		:effect (and
			(increase (stored ?loc ?d) (* (~count) (drug_batch_count ?b)))
		)
	)
	
	(:action Transport
		:parameters ()
		:values (~count - integer-range)
		:precondition (and 
			
		)
		:effect (and
			
		)
	)
	
	(:action 
		:parameters ()
		:values (~count - integer-range)
		:precondition (and 
			
		)
		:effect (and
			
		)
	)

)
