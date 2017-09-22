#define isborg(A) (is_species(A, /datum/species/zombie))
#define ROLE_BORG "borg"

/datum/game_mode/borg
	name = "borg"
	config_tag = "borg"
	antag_flag = ROLE_BORG
	required_players = 7
	required_enemies = 1
	recommended_enemies = 1
	restricted_jobs = list("Cyborg", "AI")
	var/borgs_to_make = 1
	var/list/borgs = list()
	var/borgs_to_win = 0
	var/escaped_borg = 0
	var/players_per_borg = 7


/datum/game_mode/borg/pre_setup() //changing this to the aliens code to spawn a load in maint
	borgs_to_make = max(round(num_players()/players_per_borg, 1), 1)
	var/list/datum/mind/borgs = pick_candidate(amount = borgs_to_make)
	update_not_chosen_candidates()

	for(var/j in borgs)
		var/datum/mind/borg = j
		borgs += borg
		borg.special_role = "borg drone"
		log_game("[borg.key] (ckey) was selected as a borg drone.")
	return 1


/datum/game_mode/borg/announce()
	world << "<B>The current game mode is - Borg!</B>"
	world << "<B>Some crewmembers have gone missing recently, they have become mindless robotic drones! \
				You must destroy ALL the borg (your station cyborgs are fine however), borg: assimilate the station!</B>"


/datum/game_mode/borg/proc/greet_borg(datum/mind/borg)
	borg.current << "<font style = 3><B><span class = 'notice'>We are a borg, we live to serve the collective.</B></font>"
	borg.current << "<b>You were assimilated on your visit to <span class='warning'>installation 3469</span>.</b>"
	borg.current << "<b>We can communicate with the collective via :l, you are but a drone, the queen is your overseer </b>"
	borg.current << "<b> Our priority is the assimilation of <span class='warning'>Species 5618 (or humans)</span>, but subservient species such as <span class='warning'>species 4678 (or unathi)</span> and <span class='warning'>Species 4468 (or phytosians)</span>.</b>"
	borg.current << "<b>We have a borg tool, it can be used to <span class='warning'>assimilate</span> objects, and people.</b>"
	borg.current << "<b>Use it on a victim, and after 5 seconds you will inject borg nanites into their bloodstream, making them a <span class='warning'>half drone</span>, once they are a half drone (with grey skin) take them to a conversion table (buildable)</b>"
	borg.current << "<b>Buckle them into the conversion table and keep them down for 10 seconds, after this they will join the collective as a full drone</b>"
	borg.current << "<b>KEEP IN MIND, if we fail to fully assimilate the half drone, it will regain its identity (deconvert) after a few minutes.</b>"
	borg.current << "<b>Killing is an absolute last resort, a dead human cannot be assimilated.</b>"
	borg.current << "<b>We do not require food, but we must recharge ourselves with a <span class='warning'>specialized recharger (buildable)</span> </b>"
	borg.current << "<b>We must assimilate 70% of the station and 60% of the crew to ensure victory, spreading our seed to centcom is also considered a minor victory.</b>"
	borg.current << "<b>We can assimilate turfs (walls and floors) by clicking them with the borg tool on ASSIMILATE MODE.</b>"
/datum/game_mode/borg/post_setup()
	for(var/datum/mind/borg in borgs)
		greet_borg(borg)
		borgs += borg
//		var/obj/item/organ/body_egg/zombie_infection/Z = new(carriermind.current) only halfdrones use the organ
//		Z.Insert(carriermind.current)
	..()

/datum/game_mode/borg/check_finished()
	return check_borg_victory()

/datum/game_mode/borg/proc/check_borg_victory(roundend)
	var/total_humans = 0
	for(var/mob/living/carbon/human/H in living_mob_list)
		if(H.client && !isborg(H))
			total_humans++
	if(total_humans == 0)
		return 1
	else if(!roundend)
		return 0
	else // only happens in declare_completion()
		var/borgwin = FALSE
		for(var/mob/living/carbon/human/H in living_mob_list)
			if(H.z == ZLEVEL_CENTCOM)
				if(isborg(H))
					if(H.stat != DEAD)
						if(!borgwin)
							borgwin = TRUE
							break
		if(!borgwin)
			return 0
		else
			return 1

/datum/game_mode/proc/add_borg(datum/mind/borg_mind)
	if(!borg_mind)
		return

	borgs |= borg_mind
	borg_mind.special_role = "Borg Drone"

/datum/game_mode/proc/remove_borg(datum/mind/borg_mind)
	if(!borg_mind)
		return

	borgs.Remove(borg_mind)
	borg_mind.special_role = null


/datum/game_mode/borg/declare_completion()
	if(check_borg_victory(1))
		feedback_set_details("round_end_result","win - the borg win")
		feedback_set("round_end_result",escaped_borg)
		world << "<span class='userdanger'><FONT size = 3>The borg have assimilated the station and its crew!</FONT></span>"
	else
		feedback_set_details("round_end_result","loss - staff defeated the borg!")
		feedback_set("round_end_result",escaped_borg)
		world << "<span class='userdanger'><FONT size = 3>The staff managed contain the borg!</FONT></span>"
