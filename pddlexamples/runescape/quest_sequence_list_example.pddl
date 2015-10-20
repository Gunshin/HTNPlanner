(define (domain runescape)
    (:requirements :fluents :typing)
    (:types
        skill
		quest
    )
	(:lists
		(quest_xp_rewards ?quest - quest) - (?skill - skill ?xp - integer)
		(quest_required_skill_xp ?quest - quest) - (?skill - skill ?xp - integer)
		(quest_precondition_quests ?quest - quest) - quest
	)
    (:predicates
        (done ?quest - quest)
    )
    (:functions
        (skill_xp ?skill - skill)
    )
	(:constants 
		attack defence strength constitution magic range slayer prayer - skill
		mining smithing - skill
		woodcutting firemaking fletching - skill
		runecrafting farming crafting herblore thieving - skill
		fishing cooking agility construction hunter - skill
	)
    
	(:action Complete_Quest
		:parameters (?quest - quest)
		:precondition 
        (and
			(not (done ?quest))
			(forall (?skill - skill ?xp - integer) in (quest_required_skill_xp ?quest)
                (>= (skill_xp ?skill) (?xp) )
            )
			(forall (?quest_required - quest) in (quest_precondition_quests ?quest) ;; check to see if we have all the precondition quests
				(done ?quest_required)
            )
        )
        :effect 
        (and
            (done ?quest)
			(forall (?skill - skill ?xp - integer) in (quest_xp_rewards ?quest)
				(increase (skill_xp ?skill) ?xp)
			)
			(increase (total-time) 1)
        )
	)
	
	(:action Get_Minimum_XP
		:parameters (?skill - skill ?quest - quest)
		:precondition
		(and
			(exists (quest_required_skill_xp ?quest) (?skill _))
			(< 
				(skill_xp ?skill) ;; we need to have a lower amount of skill_xp than the target requirement (otherwise there is no point)
				
				;; since the second argument eg. the result from below returns a struct of (?skill - skill ?xp - integer) i need a way to select and return xp
				;; should be able to infer type from lower down the tree? maybe explicit?
				?xp <- 
					(get ;; this defines a search and return from list
						
						;; the input is a tuple that matches the length of the struct inside the list
						;; ?skill defines one search term, and since there are only two objects, the second being ?xp - integer
						;; i use "_" to define ignore
						(?skill _)
						
						;; the list to search
						(quest_required_skill_xp ?quest) 
						
						;; the returned value
						(?skill ?xp)
					)
			)
		)
		:effect
		(and
			(=
				(skill_xp ?skill)
				?xp <- 
					(get
						(?skill _)
						(quest_required_skill_xp ?quest) 
						(?skill ?xp)
					)
			)
			(increase 
				(total-time)
				(/ 
					30 
					(+ 
						1 
						(- 
							?xp <- 
								(get
									(?skill _)
									(quest_required_skill_xp ?quest) 
									(?skill ?xp)
								)
							(skill_xp ?skill)
						)
					)
				)
			)
		)
	)
)
