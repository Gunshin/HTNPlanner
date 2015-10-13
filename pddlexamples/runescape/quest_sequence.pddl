(define (domain runescape)
    (:requirements :fluents :typing)
    (:types
        skill
		quest
    )
    (:predicates
        (done ?quest - quest)
		(quest_required_to_do_quest ?target_quest ?required_quest - quest)
    )
    (:functions
        (skill_level ?skill - skill)
		(required_skill_level ?quest - quest ?skill - skill)
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
			;;(forall (?skill - skill) ;; check to see if we have all of the skill requirements
                ;;(>= (skill_level ?skill) (required_skill_level ?quest ?skill) )
            ;;)
			(forall (?quest_required - quest) ;; check to see if we have all the precondition quests
				(and 
					(quest_required_to_do_quest ?quest ?quest_required) ;; if we need to do the ?quest_required, then check with below to make sure it has been done
					(done ?quest_required)
				)
            )
			
        )
        :effect 
        (and
            (done ?quest)
			(increase (total-time) 1)
        )
	)
	
	;;(:action Get_XP
		;;:parameters (?skill - skill)
		;;:values (~count - integer-range)
		;;:precondition
		;;(and
			;;(> (~count) 0)
			;;(<= (~count) (- 99 (skill_level ?skill)))
		;;)
		;;:effect
		;;(and
			;;(increase (skill_level ?skill) ~count)
			;;(increase (total-time) (~count))
		;;)
	;;)
	
)
