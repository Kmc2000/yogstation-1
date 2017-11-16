
//structures!
/obj/structure/chair/borg
	name = "borgified chair"
	desc = "Assimilated chair"
	icon_state = "borg1"
	anchored = 1

/obj/structure/chair/borg/attackby(obj/I,mob/user,proximity, params)
	. = ..()
	if(proximity)
		if(istype(I, /obj/item/weapon/wrench))
			to_chat(user, "<b>You begin to tear down [src] with your [I]</b>")
			if(do_after(user, 100))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				qdel(src)
				return

	else
		return

/obj/structure/chair/borg/conversion
	name = "assimilation bench"
	desc = "Looking at this thing sends chills down your spine, good thing you're not being put on it..right?</span>"
	icon_state = "borg_off"
	anchored = 1
	can_buckle = 1
	can_be_unanchored = 0
	max_buckled_mobs = 1
	burn_state = FIRE_PROOF
	buildstacktype = null
	item_chair = null // if null it can't be picked up
	creates_scraping_noise = FALSE
	var/restrained = 0 //can they unbuckle easily?

/obj/structure/chair/borg/conversion/proc/check_elegibility(mob/living/carbon/human/H)
	if(isborg(H))
		src.visible_message("<span class='warning'>Error: [H] Is already a drone.</span>")
		return FALSE
	for(var/obj/item/organ/I in H.internal_organs)
		if(istype(I, /obj/item/organ/body_egg/borgNanites) && !isborg(H))
			return TRUE
	if(!istype(H))
		return FALSE

/obj/structure/chair/borg/conversion/user_buckle_mob(mob/living/M, mob/user)
	. = ..()
	if(check_elegibility(M) && loc == M.loc)
		playsound(loc, 'sound/effects/strapin.ogg', 50, 1, -1)
		to_chat(M, "<span class='warning'>You feel an immense wave of dread wash over you as [user] starts to strap you into [src]</span>")
		to_chat(user, "<span class='warning'>We begin to prepare [M] for assimilation into the collective.</span>")
		M << sound('sound/effects/heartbeat.ogg')
		var/mob/living/carbon/human/H = M
		if(do_after(user, 100, target = H))
			for(var/obj/item/W in H)
				if(!M.unEquip(W))
					qdel(W)
			restrained = 1
			icon_state = "borg_off"
			M.do_jitter_animation(50)
			src.visible_message("<span class='warning'>[M] looks terrified as they lay on [src]</span>")
			sleep(60)
			to_chat(M, "<span class='warning'>You feel several sharp stings as the [src] cuts into you!</span>")
			sleep(10)
			to_chat(M, "<span class='warning'>OH GOD THE AGONY!</span>")
			playsound(loc, 'sound/borg/machines/convert_table.ogg', 50, 1, -1)
			src.visible_message("<span class='warning'>[M] screams in agony as the [src] forces grotesque metal parts onto their grey flesh!</span>")
			playsound(loc, 'sound/effects/megascream.ogg', 50, 1, -1) //https://youtu.be/5QvgLlFyeok?t=1m48s
			icon_state = "borg_on"
			var/image/armoverlay = image('icons/obj/chairs.dmi')
			armoverlay.icon_state = "borg_arms"
			armoverlay.layer = ABOVE_MOB_LAYER
			overlays += armoverlay
			var/image/armoroverlay = image('icons/obj/chairs.dmi')
			armoroverlay.icon_state = "borgarmour"
			armoroverlay.layer = ABOVE_MOB_LAYER
			overlays += armoroverlay
			sleep(40)
			playsound(loc, 'sound/borg/machines/convert_table2.ogg', 50, 1, -1)
			sleep(20)
			var/datum/mind/borg_mind = M.mind
			borg_mind.make_xel()
			overlays -= armoverlay
			overlays -= armoroverlay
			icon_state = "borg_off"
			to_chat(M, "<span class='warning'>We feel different as the straps binding us to the [src] release, our designation is [M.name].</span>")
			restrained = 0
	else //error meme
		src.visible_message("<span class='warning'>[M] is not ready to be augmented.</span>")
		restrained = 0

/obj/structure/chair/borg/conversion/user_unbuckle_mob(mob/living/buckled_mob/M)
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			if(restrained)
				return
			else
				unbuckle_mob(m)



/obj/structure/chair/borg/charging
	name = "recharging alcove"
	desc = "It hums with familiar sounds, a friend to the Xel."
	icon_state = "borgcharger"
	anchored = 1
	can_buckle = 1
	can_be_unanchored = 0
	max_buckled_mobs = 1
	burn_state = FIRE_PROOF
	buildstacktype = null
	item_chair = null // if null it can't be picked up
	creates_scraping_noise = FALSE
	var/cooldown = 12
	var/saved_time = 0
	var/cooldown2 = 120 //music loop cooldowns
	var/saved_time2 = 0
	var/valid = 0
	var/sound = 'sound/borg/machines/alcove.ogg'

/obj/structure/chair/borg/charging/New()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/chair/borg/charging/process()
	if(valid)
		if(world.time >= saved_time + cooldown)
			saved_time = world.time
			if(has_buckled_mobs())
				for(var/A in buckled_mobs)
					if(ishuman(A))
						var/mob/living/carbon/human/H = A
						H.adjustBruteLoss(-3)
						H.adjustFireLoss(-3)
					if(world.time >= saved_time2 + cooldown2)
						saved_time2 = world.time
						A << sound(sound)
		else
			return

/obj/structure/chair/borg/charging/user_buckle_mob(mob/living/M, mob/user)
	. = ..()
	if(ishuman(M) && M.loc == loc)
		var/mob/living/carbon/human/H = M
		if(isborg(H))
			valid = 1
			to_chat(H, "<span class='warning'>We plug into [src] and feel a soothing current wash over us as our wounds are knitted up by our nanobots.</span>")
		else
			src.visible_message("<span class='warning'>[M] cannot be recharged as they are not Xel.</span>")
			unbuckle_mob(M)
			return

	else
		src.visible_message("<span class='warning'>[M] cannot be recharged.</span>")
		unbuckle_mob(M)
		return


/obj/machinery/borg
	name = "massive xel thing"
	desc = "woa"
	icon = 'icons/obj/machines/borg.dmi'
	icon_state = "proto"
	anchored = 1
	density = 1
	can_be_unanchored = 0
	var/alreadyonehere = 0
	var/parts = list(
							/obj/item/weapon/stock_parts/borg/bin = 2,
							/obj/item/weapon/stock_parts/borg/capacitor = 2,
							/obj/item/weapon/stock_parts/borg/dilithium = 1)

/obj/machinery/borg/ftl
	name = "assimilated stellar drive"
	desc = "The green structure looms over you as it hums with a low purr. It carries ships far and wide, and in this case has been assimilated by the Xel."
	icon_state = "ftl"
	anchored = 1
	pixel_x = -32
	layer = 4.5
	parts = list(
							/obj/item/weapon/stock_parts/borg/bin = 2,
							/obj/item/weapon/stock_parts/borg/capacitor = 1,
							/obj/item/weapon/stock_parts/borg = 3)
/obj/machinery/borg/ftl/New()
	. = ..()
	var/area/A = get_area(src)
	if(ticker.mode.borg_machines_room_has_ftl == 0)
		if(istype(A, ticker.mode.borg_target_area))
			ticker.mode.borg_machines_room_has_ftl = 1
		//	src.say(ticker.mode.borg_machines_in_area)
		else
			src.say("not in the right area")
	else
		alreadyonehere = 1
		src.say("there is already one of those here")
		qdel(src)

/obj/machinery/borg/ftl/Destroy()
	. = ..()
	if(!alreadyonehere)
		ticker.mode.borg_machines_room_has_ftl = 0 //when you delete it, if there is already one, means that you cant make infinite ones.

/obj/machinery/borg/helm
	name = "xel cube helm control"
	desc = "Symbols flash on its holographic display as it constantly flickers and hums, used to fly ships it would seem."
	icon_state = "navicomp"
	anchored = 1
//	pixel_x = -32
	bound_width = 96
	layer = 4.5
	parts = list(
							/obj/item/weapon/stock_parts/borg/bin = 2,
							/obj/item/weapon/stock_parts/borg/capacitor = 1,
							/obj/item/weapon/stock_parts/borg = 3)

/obj/machinery/borg/helm/New()
	. = ..()
	var/area/A = get_area(src)
	if(ticker.mode.borg_machines_room_has_nav == 0)
		if(istype(A, ticker.mode.borg_target_area))
			ticker.mode.borg_machines_room_has_nav = 1
		//	src.say(ticker.mode.borg_machines_in_area)
		else
			src.say("not in the right area")
	else
		src.say("there is already one of those here")
		qdel(src)

/obj/machinery/borg/helm/Destroy()
	. = ..()
	if(!alreadyonehere)
		ticker.mode.borg_machines_room_has_nav = 0 //when you delete it, if there is already one, means that you cant make infinite ones.
/*

/obj/machinery/borg/throne
	name = "queen's throne"
	desc = "A massive structure fit for a queen"
	icon_state = "throne"
	anchored = 1
//	pixel_x = -32
	bound_width = 96
	layer = 4.5
	var/obj/machinery/computer/camera_advanced/borg/computer = null
	can_buckle = 1
	buckle_lying = 0
	max_buckled_mobs = 1
	parts = list(
							/obj/item/weapon/stock_parts/borg/bin = 2,
							/obj/item/weapon/stock_parts/borg/capacitor = 3,
							/obj/item/weapon/stock_parts/borg = 5)

/obj/machinery/borg/throne/user_unbuckle_mob(mob/living/buckled_mob/M)
	. = ..()
	for(var/m in buckled_mobs)
		var/mob/living/carbon/human/borgqueen/P = m
		unbuckle_mob(m)
		icon_state = "throne"
		P.alpha = 255

/obj/machinery/borg/throne/user_buckle_mob(mob/living/carbon/human/borgqueen/M, mob/user)
	. = ..()
	if(!istype(M, /mob/living/carbon/human/borgqueen))
		return
	if(!isborg(M))
		return
	var/mob/living/carbon/human/borgqueen/P = M
	P.alpha = 0 //:^)
	icon_state = "queenboltin"
	sleep(20)
	icon_state = "thronequeen"
	buckle_mob(P)
//	P.computer.attack_hand(user)



/obj/machinery/borg/throne/New()
	. = ..()
	var/area/A = get_area(src)
	if(ticker.mode.borg_machines_room_has_throne == 0)
		if(istype(A, ticker.mode.borg_target_area))
			computer = new(src) //obj/machinery/computer/camera_advanced/borg(src)
			ticker.mode.borg_machines_room_has_throne = 1
		//	src.say(ticker.mode.borg_machines_in_area)
		else
			src.say("not in the right area")
	else
		src.say("there is already one of those here")
		qdel(src)

/obj/machinery/borg/throne/Destroy()
	. = ..()
	if(!alreadyonehere)
		ticker.mode.borg_machines_room_has_throne = 0 //when you delete it, if there is already one, means that you cant make infinite ones.

//camera stuff, testing!

*/

/obj/machinery/computer/camera_advanced/borg/throne //:^)
	name = "queen's throne"
	desc = "A massive structure fit for a queen"
	icon_state = "throne"
	icon = 'icons/obj/machines/borg.dmi'
	icon_screen = null
	icon_keyboard = null
	anchored = 1
//	pixel_x = -32
	bound_width = 96
	layer = 4.5
	can_buckle = 1
	buckle_lying = 0
	var/alreadyonehere = 0
	max_buckled_mobs = 1
	/*
	parts = list(
							/obj/item/weapon/stock_parts/borg/bin = 2,
							/obj/item/weapon/stock_parts/borg/capacitor = 3,
							/obj/item/weapon/stock_parts/borg = 5) */

/obj/machinery/computer/camera_advanced/borg/throne/attack_hand(mob/living/carbon/human/borgqueen/M, mob/user)
	. = ..()
	if(!istype(M, /mob/living/carbon/human/borgqueen))
		return
	if(!isborg(M))
		return
	var/mob/living/carbon/human/borgqueen/P = M
	P.alpha = 0 //:^)
	icon_state = "queenboltin"
	sleep(20)
	icon_state = "thronequeen"
	buckle_mob(P)
//	P.computer.attack_hand(user)


/obj/machinery/computer/camera_advanced/borg/throne/New()
	. = ..()
	var/area/A = get_area(src)
	if(ticker.mode.borg_machines_room_has_throne == 0)
		if(istype(A, ticker.mode.borg_target_area))
			ticker.mode.borg_machines_room_has_throne = 1
		//	src.say(ticker.mode.borg_machines_in_area)
		else
			src.say("not in the right area")
	else
		src.say("there is already one of those here")
		qdel(src)

/obj/machinery/computer/camera_advanced/borg/throne/Destroy()
	. = ..()
	if(!alreadyonehere)
		ticker.mode.borg_machines_room_has_throne = 0 //when you delete it, if there is already one, means that you cant make infinite ones.


/obj/item/weapon/stock_parts/borg
	name = "gravimetric interspatial manifold field manipulator"
	desc = "oh, it's a gravimetric field interspatial manifold used to regenerate transphasic presequenced waves, DUH!"
	icon_state = "borg_mani"


/obj/item/weapon/stock_parts/borg/capacitor
	name = "transphasic autonomous regeneration sequencer"
	desc = "oh, it's an Intramolecular processor manifold used to harmonize interspacial transwarp waves, what else would it be?"
	icon_state = "borg_capacitor"

/obj/item/weapon/stock_parts/borg/bin
	name = "central plexonomic sequencer conduit"
	desc = "oh, it's mass storage device for gravimetric field waves converging around its hypercapacitation EPS matrix, what do you think it does?"
	icon_state = "borg_gravitron"

/obj/item/weapon/stock_parts/borg/dilithium
	name = "dilithium convergence module"
	desc = "oh, it's a big fucking lump of dilithium, what else would it be?"
	icon_state = "dilithium"

/obj/item/weapon/circuitboard/machine/borg/FTL
	name = "assimilated circuit-board (ftl drive)"
	build_path = /obj/machinery/borg/ftl
	origin_tech = "programming=10;engineering=8"
	req_components = list(
							/obj/item/weapon/stock_parts/borg/bin = 2,
							/obj/item/weapon/stock_parts/borg/capacitor = 2,
							/obj/item/weapon/stock_parts/borg/dilithium = 1)

/obj/item/weapon/circuitboard/machine/borg/navicomp
	name = "assimilated circuit-board (navigational computer)"
	build_path = /obj/machinery/borg/helm
	origin_tech = "programming=10;engineering=8"
	req_components = list(
							/obj/item/weapon/stock_parts/borg/bin = 2,
							/obj/item/weapon/stock_parts/borg/capacitor = 1,
							/obj/item/weapon/stock_parts/borg = 3)

/obj/item/weapon/circuitboard/machine/borg/throne
	name = "assimilated circuit-board (queen throne)"
	build_path = /obj/machinery/computer/camera_advanced/borg/throne
	origin_tech = "programming=10;engineering=8"
	req_components = list(
							/obj/item/weapon/stock_parts/borg/bin = 2,
							/obj/item/weapon/stock_parts/borg/capacitor = 1,
							/obj/item/weapon/stock_parts/borg = 3)

