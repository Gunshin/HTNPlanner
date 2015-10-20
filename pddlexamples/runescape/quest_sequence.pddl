(define (domain runescape)
    (:requirements :fluents :typing)
    (:types
        skill
		quest
    )
    (:predicates
        (done ?quest - quest)
		(quest_required_to_do_quest ?target_quest ?required_quest - quest)
		(skill_required_to_do_quest ?target_quest - quest ?skill - skill)
    )
    (:functions
        (skill_xp ?skill - skill)
		(required_skill_xp ?quest - quest ?skill - skill)
		(quest_reward_xp ?quest - quest ?skill - skill)
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
			(forall (?skill - skill) ;; check to see if we have all of the skill requirements
                (>= (skill_xp ?skill) (required_skill_xp ?quest ?skill) )
            )
			(forall (?quest_required - quest) ;; check to see if we have all the precondition quests
				(imply (quest_required_to_do_quest ?quest ?quest_required) (done ?quest_required))
            )
			
        )
        :effect 
        (and
            (done ?quest)
			(forall (?skill - skill)
				(increase (skill_xp ?skill) (quest_reward_xp ?quest ?skill))
			)
			(increase (total-time) 1)
        )
	)
	
	(:action Get_Minimum_XP
		:parameters (?skill - skill ?quest - quest)
		:precondition
		(and
			(skill_required_to_do_quest ?quest ?skill)
			(< (skill_xp ?skill) (required_skill_xp ?quest ?skill))
		)
		:effect
		(and
			(= (skill_xp ?skill) (required_skill_xp ?quest ?skill))
			(increase (total-time) (/ 30 (+ 1 (- (required_skill_xp ?quest ?skill) (skill_xp ?skill)))))
		)
	)
)
