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
	
		;; quest xp requirements
		(push (quest_required_skill_xp dorics_quest) (mining 2411))
		
		(push (quest_required_skill_xp dragon_slayer) (defence 13363))
		(push (quest_required_skill_xp dragon_slayer) (range 37224))
		
		(push (quest_required_skill_xp the_knights_sword) (mining 1154))
		
		(push (quest_required_skill_xp vampire_slayer) (range 4470))
		
		
		
		;; quest requirements
		(push (quest_precondition_quests lunar_diplomacy) the_fremenik_trials)
		(push (quest_precondition_quests lunar_diplomacy) lost_city)
		(push (quest_precondition_quests lunar_diplomacy) shilo_village)
		(push (quest_precondition_quests lunar_diplomacy) rune_mysteries)
		
		(push (quest_precondition_quests shilo_village) jungle_potion)
		
		(push (quest_precondition_quests jungle_potion) druidic_ritual)
		
		
		
		
		;; quest xp rewards
		(push (quest_xp_rewards cooks_assistant) (cooking 300))
		
		(push (quest_xp_rewards dorics_quest) (mining 1300))
		
		(push (quest_xp_rewards dragon_slayer) (strength 18650))
		(push (quest_xp_rewards dragon_slayer) (defence 18650))
		
		(push (quest_xp_rewards goblin_diplomacy) (crafting 200))
		
		(push (quest_xp_rewards imp_catcher) (magic 875))
		
		(push (quest_xp_rewards the_knights_sword) (smithing 12725))
		
		(push (quest_xp_rewards sheep_shearer) (crafting 150))
		
		(push (quest_xp_rewards the_restless_ghost) (prayer 1125))
		
		(push (quest_xp_rewards vampire_slayer) (attack 4825))
		
		(push (quest_xp_rewards witches_potion) (magic 325))
		
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