(define (problem runescape_test)
    (:domain runescape)
    (:objects
        cooks_assistant black_knights_fortress demon_slayer - quest
		dorics_quest dragon_slayer ernest_the_chicken - quest
		goblin_diplomacy imp_catcher the_knights_sword - quest
		pirates_treasure prince_ali_rescue romeo_and_juliet - quest
		rune_mysteries sheep_shearer shield_of_arrav - quest
		the_restless_ghost vampire_slayer witches_potion - quest
    )
    (:init
        (= (required_skill_level dorics_quest mining) 15)
		
		(= (required_skill_level dragon_slayer defence) 30)
		(= (required_skill_level dragon_slayer range) 40)
		
		(= (required_skill_level the_knights_sword mining) 10)
		
		(= (required_skill_level vampire_slayer range) 20)
    )
    (:goal
        (and
            (done cooks_assistant)
			;;(done black_knights_fortress)
			;;(done dorics_quest)
			;;(done dragon_slayer)
			;;(done ernest_the_chicken)
        )
    )
	(:metric minimize (total-time))
)