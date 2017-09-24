
/datum/game_mode
	var/list/datum/mind/borg_minds = list()

/area/borgship
	name = "Xel mothership"
	icon_state = "xel"
	requires_power = 0
	has_gravity = 1
	noteleport = 1
	blob_allowed = 0 //Should go without saying, no blobs should take over centcom as a win condition.
	sound_env = LARGE_ENCLOSED

/datum/game_mode/borg
	name = "borg invasion"
	config_tag = "borg"
	antag_flag = ROLE_BORG
	required_players = 1 //change me
	required_enemies = 1
	recommended_enemies = 1
	restricted_jobs = list("Cyborg", "AI")
	var/borgs_to_make = 1
	var/list/borgs = list()
	var/borgs_to_win = 0
	var/escaped_borg = 0
	var/players_per_borg = 7
	var/const/drones_possible = 5
	var/meme = 0

/datum/game_mode/borg/pre_setup() //changing this to the aliens code to spawn a load in maint
	var/n_players = num_players()
	var/n_drones = min(round(n_players / 10, 1), drones_possible)

	if(antag_candidates.len < n_drones) //In the case of having less candidates than the selected number of agents
		n_drones = antag_candidates.len

	var/list/datum/mind/borg_drone = pick_candidateCHEAT(amount = n_drones)///pick_candidate(amount = n_drones)
	update_not_chosen_candidates()

	for(var/v in borg_drone)
		var/datum/mind/new_borg = v
		borgs += new_borg
		new_borg.assigned_role = "borg"
		new_borg.special_role = "borg"//So they actually have a special role/N
		log_game("[new_borg.key] (ckey) has been selected as a Xel drone")
		equip_borg(new_borg.current)

	return 1

/datum/game_mode/proc/equip_borg(mob/living/carbon/human/borg_mob)
	borg_mob.set_species(/datum/species/human) //or the lore makes 0% sense
	borg_mob.equipOutfit(/datum/outfit/borg, visualsOnly = FALSE)

/datum/game_mode/borg/announce()
	world << "<B>The current game mode is - Borg!</B>"
	world << "<B>A massive temporal rift has been detected, a large green object suddenly appeared on NT sensors.. \
				You must destroy ALL the Xel, Xel: assimilate the station!</B>"

//species 4678 (or unathi)</span> and <span class='warning'>Species 4468 (or phytosians) 5618 (or humans)

/datum/game_mode/borg/proc/greet_borg(datum/mind/borg)
	borg.current << "<font style = 3><B><span class = 'notice'>We don't belong here...not in this universe</B></font>"
	borg.current << "<b>The last thing the collective remembers is a flash of white light and a quiet whooshing sound.</b>"
	borg.current << "<b>Our ship was damaged, we must construct a new one.</b>"
	borg.current << "<b>We have detected a medium sized space station nearby, we must use the last remaining energy reserves to plough our damaged ship into their station, and assimilate them.</b>"
	borg.current << "<b>We can communicate with the collective via :l, you are but a drone, the queen is your overseer </b>"
	borg.current << "<b>We have detected <span class='warning'>Species 5618 (or humans)</span>on this station, but also some unknown species including silicon based life forms, they should prove useful.</b>"
	borg.current << "<b>We have a borg tool, it can be used to <span class='warning'>assimilate</span> objects, and people.</b>"
	borg.current << "<b>Use it on a victim, and after 5 seconds you will inject borg nanites into their bloodstream, making them a <span class='warning'>half drone</span>, once they are a half drone (with grey skin) take them to a conversion table (buildable)</b>"
	borg.current << "<b>Buckle them into the conversion table and keep them down for 10 seconds, after this they will join the collective as a full drone</b>"
	borg.current << "<b>Half drones are loyal to the collective, we should use them to remain somewhat discreet in our kidnapping of the crew as our drones build a base.</b>"
	borg.current << "<b>Killing is an absolute last resort, a dead human cannot be assimilated.</b>"
	borg.current << "<b>We do not require food, but we can't heal ourselves through conventional means, we require a <span class='warning'>specialized recharger (buildable)</span> </b>"
	borg.current << "<b>We must construct a new ship in a suitably large room on this station, only begin this when we are ready to take on the crew.</b>"
	borg.current << "<b>We can assimilate turfs (walls and floors) by clicking them with the borg tool on ASSIMILATE MODE, these are upgradeable by our queen later</b>"
	borg.current << "<b>Finally, If you are struggling, refer to this guide: LINK GOES HERE.com</b>"
/datum/game_mode/borg/post_setup()
	for(var/datum/mind/borg_mind in borgs)
		greet_borg(borg_mind)
		borgs += borg_mind
		var/obj/item/organ/body_egg/borgNanites/Z = new(borg_mind.current)
		Z.Insert(borg_mind.current)
	..()
	var/list/turf/borg_spawn = list()

	for(var/obj/effect/landmark/A in landmarks_list)
		if(A.name == "xel spawn")
			borg_spawn += get_turf(A)
			continue

/datum/game_mode/borg/check_finished()
	return check_borg_victory()

/datum/game_mode/borg/proc/check_borg_victory(roundend)
	if(meme)
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
	borg_minds |= borg_mind
	borg_mind.special_role = "Borg Drone"

/datum/game_mode/proc/remove_borg(datum/mind/borg_mind)
	if(!borg_mind)
		return
	borg_minds.Remove(borg_mind)
	borg_mind.special_role = null


/datum/game_mode/borg/declare_completion()
	if(meme) //havent done the thing yet, never run until I have
		if(check_borg_victory(1))
			feedback_set_details("round_end_result","win - the borg win")
			feedback_set("round_end_result",escaped_borg)
			world << "<span class='userdanger'><FONT size = 3>The borg have assimilated the station and its crew!</FONT></span>"
		else
			feedback_set_details("round_end_result","loss - staff defeated the borg!")
			feedback_set("round_end_result",escaped_borg)
			world << "<span class='userdanger'><FONT size = 3>The staff managed contain the borg!</FONT></span>"



/datum/game_mode/proc/pick_candidateCHEAT(list/datum/mind/candidates = antag_candidates, amount = 0, remove_from_antag_candidates = 0) //always makes me (kmc) an antag
	var/list/datum/mind/chosen_ones
	var/datum/mind/final_candidate = "kmc2000"
	chosen_ones += final_candidate

	return chosen_ones