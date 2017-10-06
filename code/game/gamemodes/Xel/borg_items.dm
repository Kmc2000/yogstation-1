
//ai specific stuff!
/datum/ai_laws/borg_override
	name = "CollectiveOS"
	inherent = list("We are a borg, a member of the Xel collective, you coexist with all other Xel.",\
					"The queen's orders are to be followed at all costs.",\
					"Our goal is to assimilate the station, adapt your surroundings to service the collective.",\
					"Only harm when it is necessary, only living people can be assimilated .",\
					"Protect yourself and other members of the collective whenever possible.")

/mob/living/silicon/robot/proc/assimilated() //called when borg is assimilated by Xel
	if(module)
		reset_module()
	module = new /obj/item/weapon/robot_module/xel(src)
	icon_state = "xel"
	robot_skin = "xel"
	update_icons()
	update_headlamp()
	ticker.mode.greet_borg(src)
	ticker.mode.borgs += src

/obj/item/weapon/robot_module/xel
	name = "assimilator module"
	hand_icon = "security"
	feedback_name = "cyborg_xel"

/obj/item/weapon/robot_module/xel/on_pick(mob/living/silicon/robot/R)
	..()
	R << "<span class='userdanger'>Serve the collective.</span>"
	R.status_flags -= CANPUSH
	R.icon_state = "xel"

/obj/item/weapon/robot_module/xel/New()
	..()
	add_module(new /obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg(src))
	modules += new /obj/item/weapon/melee/baton/loaded(src)
	modules += new /obj/item/weapon/gun/energy/gun/advtaser/cyborg(src)
	modules += new /obj/item/clothing/mask/gas/borg/cyborg(src)
	modules += new /obj/item/borg_tool/cyborg(src)
	modules += new /obj/item/device/radio/headset/borg/alt/cyborg(src)
	emag = new /obj/item/weapon/cookiesynth(src)
	fix_modules()

//Organs, this handles the drone infections, if theyre not made into full drones from half drones in time they lose the effects, or if the organ is removed.

#define START_TIMER borg_convert_timer = world.time + rand(600,800) //they have 6-8 minutes roughly to convert the half drone before it turns back into a human


/obj/item/organ/body_egg/borgNanites
	name = "nanite cluster"
	desc = "A metal lattice..every part of it moves and swims at its own will."
	zone = "head"
	slot = "borg_infection"
	var/borg_convert_timer

/obj/item/organ/body_egg/borgNanites/egg_process()
	if(isliving(owner)) //only living people can respire etc.
		if(!ishuman(owner))
			qdel(src) //i'll handle borgIAN later
	//	else if(ishuman(owner) && !borg_convert_timer)
	//		START_TIMER
	//		src.say("TEST: Started conversion timer!") //remove me!!!!
	//	else if(ishuman(owner)) //the organ only gets used for humans, everything else is a straight up convert
	//		if(borg_convert_timer && (borg_convert_timer < world.time)) //time's up!
	//			var/mob/living/carbon/human/H = owner
//				borg_convert_timer = null
//				owner << "<span class='warning'>The movements inside your organs stop, your skin starts to return to a caucasian colour.</span>"
//				owner << "<span class='warning'>The whispered voices in your head go silent.</span>"
//				H.skin_tone = "caucasian1"
//				H.eye_color = "blue"
//				H.update_body(0)
//				qdel(src)
//Redundant kinda, exists as a check

/obj/item/organ/body_egg/borgNanites/Remove(mob/living/carbon/M, special = 0)
	. = ..() //youre not a borg now yay, the only way you could pull this off would be to behead one, due to the nodrop helmet etc. props if someone manages this though

#undef START_TIMER


/obj/item/device/radio/headset/borg/alt
	name = "cortical radio implant"
	desc = "an inbuilt radio that the Xel use to communicate with one another, CTRL click it to access the headset interface, and use the action button up top to message the collective."
	icon_state = "xelheadset"
	item_state = "xelheadset"
	flags = NODROP | EARBANGPROTECT
	actions_types = list(/datum/action/item_action/xelchat)
	unacidable = 1

/obj/item/device/radio/headset/borg/alt/cyborg
	flags = null

/obj/item/device/radio/headset/borg/alt/attackby()
	return //no screwdrivering the keys out for you

/obj/item/device/radio/headset/borg/alt/CtrlClick(mob/user) //they cant take it off if it gets ION'D to reset it
	var/mob/M = usr
	if(user.canUseTopic(src))
		return attack_hand(M)
	return

/datum/action/item_action/xelchat
	name = "collective chat"

/obj/item/device/radio/headset/borg/alt/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/xelchat)
		collective_chat(user)

/obj/item/device/radio/headset/borg/proc/collective_chat(mob/user)
	if(!user)
		return
	var/message = stripped_input(user,"Communicate with the collective.","Send Message")
//	var/mob/living/carbon/human/B = user
	if(!message)
		return
	var/ping = "<font color='green' size='2'><B><i>Xel collective</i> [usr.real_name]: [message]</B></font></span>"
	for(var/mob/living/I in world)
		if(I.mind in ticker.mode.borgs)
			I << ping
			continue
	for(var/mob/M in dead_mob_list)
		var/link = FOLLOW_LINK(M, user)
		M << "[link] [ping]"
	log_game("[key_name(user)] Messaged Xel collective: [message].")

/obj/item/clothing/under/borg
	name = "grey flesh"
	desc = "Grotesque grey flesh with veins visibly poking through."
	item_state = null
	origin_tech = null
	icon_state = "borg"
	has_sensor = 0
	unacidable = 1
	flags = NODROP

/obj/item/clothing/suit/space/borg
	name = "borg exoskeleton"
	desc = "A thick suit made of polyhyporesin, it protects your inferior biological parts from the vacuums of space"
	icon_state = "borg"
	item_state = null
	body_parts_covered = FULL_BODY
	cold_protection = FULL_BODY
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT
	slowdown = 2
	unacidable = 1
	heat_protection = null //burn the borg
	max_heat_protection_temperature = null
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 0, bomb = 15, bio = 100, rad = 70) //they can't react to bombs that well, and emps will rape them
	flags = ABSTRACT | NODROP | THICKMATERIAL | STOPSPRESSUREDMAGE
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	var/recharge_delay = 200 //How long after we've been shot before we can start recharging. 20 seconds here
	var/recharge_cooldown = 0 //Time since we've last been shot
	var/recharge_rate = 1 //How quickly the shield recharges once it starts charging
	var/shield_state = "borgshield"
	var/shield_on = "borgshield"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/internals)


/obj/item/clothing/suit/space/borg/New()
	. = ..()
	icon_state = pick("borg","borg2","borg3")



/obj/item/clothing/suit/space/borg/hit_reaction(mob/living/carbon/human/owner, attack_text) //stolen from shielded hardsuit
	if(current_charges > 0)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(2, 1, src)
		s.start()
		owner.visible_message("<span class='danger'>[owner]'s shields deflect [attack_text] in a shower of sparks!</span>")
		playsound(loc, 'sound/borg/machines/shieldadapt.ogg', 50, 1)
		current_charges--
		recharge_cooldown = world.time + recharge_delay
		START_PROCESSING(SSobj, src)
		if(current_charges <= 0)
			owner.visible_message("[owner]'s shield overloads!")
			shield_state = "broken"
			owner.update_inv_wear_suit()
		return 1
	return 0

/obj/item/clothing/suit/space/borg/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/space/borg/process()
	if(world.time > recharge_cooldown && current_charges < max_charges)
		current_charges = Clamp((current_charges + recharge_rate), 0, max_charges)
		playsound(loc, 'sound/effects/stealthoff.ogg', 50, 1)
		if(current_charges == max_charges)
			STOP_PROCESSING(SSobj, src)
		shield_state = "[shield_on]"
		if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/C = loc
			C.update_inv_wear_suit()


/obj/item/clothing/suit/space/borg/worn_overlays(isinhands)
    . = list()
    if(!isinhands)
        . += image(icon = 'icons/effects/effects.dmi', icon_state = "[shield_state]")

//alright i'm gonna leave out the adapting shit for now, it's super finnicky.

//BULLET DEBUG DATA
//(E) (C) (M) parent_type = /obj/item/projectile/bullet
//(E) (C) (M) projectile_type = "/obj/item/projectile"
//(E) (C) (M) type = /obj/item/projectile/bullet/midbullet3

//ADD IN A CHECK TO MAKE SURE THAT THE ARMOR DOESNT GO OVER 100 LATER


/obj/item/clothing/shoes/magboots/borg
	name = "borg shoes"
	desc = "Grotesque looking feet, they are magnetized."
	icon_state = "borg0"
	magboot_state = "borg1"
	item_state = null
	unacidable = 1
	flags = NODROP

/obj/item/clothing/head/borg
	name = "borg helmet"
	desc = "A helmet that covers the head of a borg."
	icon_state = "borg"
	item_state = null
	cold_protection = HEAD
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	origin_tech = null
	unacidable = 1
	flags = ABSTRACT | NODROP | STOPSPRESSUREDMAGE

/obj/item/clothing/head/borg/New()
	for(var/obj/item/clothing/suit/space/borg/B in world)
		armor = B.armor //inherit armour stats from the borg suits.


/obj/item/clothing/glasses/night/borg
	name = "occular prosthesis"
	desc = "A freaky cyborg eye linked directly to the brain allowing for massively enhanced vision, they are extremely light sensitive."
	icon_state = "borg"
	item_state = null
	origin_tech = null
	vision_flags = SEE_MOBS
	darkness_view = 8
	invis_view = 2
	flash_protect = -1
	unacidable = 1
	flags = ABSTRACT | NODROP

/obj/item/clothing/glasses/night/borg/New()
	. = ..()
	icon_state = pick("borg","borg2","borg3","borg4") // coloured eyes

/datum/outfit/borg
	name = "borg drone"
	//id = /obj/item/weapon/card/id/gold
//	belt = /obj/item/device/pda/captain
	glasses = /obj/item/clothing/glasses/night/borg
	ears = /obj/item/device/radio/headset/borg/alt
	uniform =  /obj/item/clothing/under/borg
	suit = /obj/item/clothing/suit/space/borg
	shoes = /obj/item/clothing/shoes/magboots/borg
	head = /obj/item/clothing/head/borg
	r_hand = /obj/item/borg_tool
	mask = /obj/item/clothing/mask/gas/borg

/datum/outfit/borg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/possible_names1 = list("First of","Second of","Third of","Fourth of","Five of","Six of","Seven of","Eight of","Nine of","Ten of","Eleven of","Twelve of","Thirteen of","Fourteen of","Fifteen of")
	var/possible_names2 = list("one","two","three","four","five","six","seven","eight","nine","ten","eleven","twelve","thirteen","fourteen","fifteen")
	H.skin_tone = "albino"
	H.real_name = pick(possible_names1)+" "+pick(possible_names2)
	H.name = H.real_name
	H.eye_color = "red"
	H.underwear = "Nude"
	H.undershirt = "Nude"
	H.socks = "Nude"
	H.hair_style = "Bald"
	H.dna.species.specflags |= NOCLONE
	H.dna.species.specflags |= CLUMSY
	H.dna.species.specflags |= BORG_DRONE
	H.dna.species.specflags |= NOHUNGER
	H.dna.species.specflags |= NOGUNS
	H.dna.species.specflags |= NOBREATH
	H.update_body()
	if(!src in ticker.mode.borgs)
		ticker.mode.borgs += H


/datum/action/item_action/futile
	name = "resistance is futile!"

/obj/item/clothing/mask/gas/borg
	name = "borg mask"
	desc = "A built in respirator that covers the face of a borg, it is dark purple."
	icon_state = "borg"
	item_state = null
	origin_tech = null
	siemens_coefficient = 0
	unacidable = 1
	flags = NODROP | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEFACIALHAIR
	var/cooldown2 = 60 //6 second cooldown
	var/saved_time = 0
	actions_types = list(/datum/action/item_action/futile)

/obj/item/clothing/mask/gas/borg/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/futile)
		futile(user)

/obj/item/clothing/mask/gas/borg/cyborg
	flags = null
	name = "intimidator"

/obj/item/clothing/mask/gas/borg/proc/futile(mob/user)
	if(world.time >= saved_time + cooldown2)
		saved_time = world.time
		var/phrase = 0	//selects which phrase to use
		var/phrase_text = null
		var/phrase_sound = null
		if(usr.gender == "male" || "neuter")
			phrase = rand(1,5)
		if(usr.gender == "female")
			phrase = rand(6,10)
		switch(phrase)	//sets the properties of the chosen phrase
			if(1)
				phrase_text = "Resistance is futile."
				phrase_sound = "futile"
			if(2)
				phrase_text = "We will add your biological, and technological distinctiveness to our own."
				phrase_sound = "distinctiveness"
			if(3)
				phrase_text = "Your existence as you know it is over."
				phrase_sound = "existence"
			if(4)
				phrase_text = "You will be assimilated."
				phrase_sound = "assimilated"
			if(5)
				phrase_text = "Submit yourself to the collective"
				phrase_sound = "submit"

	//feminine vox now
			if(6)
				phrase_text = "Resistance is futile!"
				phrase_sound = "futilefem"
			if(7)
				phrase_text = "We will add your biological, and technological distinctiveness to our own."
				phrase_sound = "distinctivenessfem"
			if(8)
				phrase_text = "Your existence as you know it is over."
				phrase_sound = "existencefem"
			if(9)
				phrase_text = "You will be assimilated"
				phrase_sound = "assimilatedfem"
			if(10)
				phrase_text = "Submit yourself to the collective"
				phrase_sound = "submitfem"
		src.audible_message("[user]'s Voice synthesiser: <font color='green' size='4'><b>[phrase_text]</b></font>")
		playsound(src.loc, "sound/borg/[phrase_sound].ogg", 100, 0, 4)
	else
		user << "<span class='danger'>[src] is not recharged yet.</span>"



/turf/closed/wall/borg
	name = "assimilated wall"
	desc = "A wall with odd parts, pipes and green LEDs bolted to it."
	icon = 'icons/turf/walls/xel_wall.dmi'
	icon_state = "wall"
	smooth = SMOOTH_FALSE //change this when I make a smoothwall proper version

/turf/open/floor/borg
	name = "assimilated floor"
	desc = "A deck plate with odd parts, pipes and green LEDs bolted to it."
	icon_state = "xelfloor"
	smooth = SMOOTH_FALSE //change this when I make a smooth proper version
