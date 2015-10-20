(define (problem runescape_test)
    (:domain runescape)
    (:objects
        cooks_assistant black_knights_fortress demon_slayer - quest
		dorics_quest dragon_slayer ernest_the_chicken - quest
		goblin_diplomacy imp_catcher the_knights_sword - quest
		pirates_treasure prince_ali_rescue romeo_and_juliet - quest
		rune_mysteries sheep_shearer shield_of_arrav - quest
		the_restless_ghost vampire_slayer witches_potion - quest
		
		lunar_diplomacy the_fremenik_trials lost_city shilo_village - quest
		jungle_potion druidic_ritual - quest
		
    )
    (:init
		
		
		(skill_required_to_do_quest dorics_quest mining)
        (= (required_skill_xp dorics_quest mining) 2411)
		
		(skill_required_to_do_quest dragon_slayer defence)
		(= (required_skill_xp dragon_slayer defence) 13363)
		
		(skill_required_to_do_quest dragon_slayer range)
		(= (required_skill_xp dragon_slayer range) 37224)
		
		(skill_required_to_do_quest the_knights_sword mining)
		(= (required_skill_xp the_knights_sword mining) 1154)
		
		(skill_required_to_do_quest vampire_slayer range)
		(= (required_skill_xp vampire_slayer range) 4470)
		
		(quest_required_to_do_quest lunar_diplomacy the_fremenik_trials)
		(quest_required_to_do_quest lunar_diplomacy lost_city)
		(quest_required_to_do_quest lunar_diplomacy shilo_village)
		(quest_required_to_do_quest lunar_diplomacy rune_mysteries)
		
		(quest_required_to_do_quest shilo_village jungle_potion)
		
		(quest_required_to_do_quest jungle_potion druidic_ritual)
		
		(= (quest_reward_xp cooks_assistant cooking) 300)
		
		(= (quest_reward_xp dorics_quest mining) 1300)
		
		(= (quest_reward_xp dragon_slayer strength) 18650)
		(= (quest_reward_xp dragon_slayer defence) 18650)
		
		(= (quest_reward_xp goblin_diplomacy crafting) 200)
		
		(= (quest_reward_xp imp_catcher magic) 875)
		
		(= (quest_reward_xp the_knights_sword smithing) 12725)
		
		(= (quest_reward_xp sheep_shearer crafting) 150)
		
		(= (quest_reward_xp the_restless_ghost prayer) 1125)
		
		(= (quest_reward_xp vampire_slayer attack) 4825)
		
		(= (quest_reward_xp witches_potion magic) 325)
		
    )
    (:goal
        (and
            (done cooks_assistant)
			(done black_knights_fortress)
			(done dorics_quest)
			(done dragon_slayer)
			(done ernest_the_chicken)
			(done lunar_diplomacy)
        )
    )
	(:metric minimize (total-time))
)