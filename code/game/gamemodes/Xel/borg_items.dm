
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
	zone = "chest"
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
//	var/mob/living/carbon/human/H = owner	//no type check, as that should be handled by the surgery
//	var/datum/mind/fuckfuckmeme = H.mind
//	fuckfuckmeme.remove_xel()
	. = ..() //youre not a borg now yay, the only way you could pull this off would be to behead one, due to the nodrop helmet etc. props if someone manages this though


#undef START_TIMER

//Ok here goes, DECONVERSION! you use the saw for this!

/obj/item/weapon/surgicaldrill/attack(mob/living/M, mob/user)
	var/mob/living/carbon/N = M
	if(isborg(N))
		for(var/obj/item/clothing/suit/space/borg/B in N.contents)
			var/obj/item/clothing/suit/space/borg/A = B
			if(do_after(user, 100, target = M))
				if(A.current_charges == 0) //no drill thru shield
					src.visible_message("[user] drills into [M]'s exoskeleton! shattering it to pieces.")
					qdel(B)
					for(var/obj/item/clothing/under/borg/Z in N.contents)
						qdel(Z)
				else
					..() //carry on attack
	else //carry on as normal
		..()

//SURGERY STEPS
/datum/surgery/borg_deconvert
	name = "hostile nanite removal"
	steps = list(/datum/surgery_step/borg_incise,/datum/surgery_step/borg_sever,/datum/surgery_step/clamp_bleeders, /datum/surgery_step/borg_retract, /datum/surgery_step/borg_drill,/datum/surgery_step/borg_bleeders,/datum/surgery_step/clamp_bleeders,/datum/surgery_step/borg_subdermal, /datum/surgery_step/borg_subdermal_grab,/datum/surgery_step/borg_cautery )
	species = list(/mob/living/carbon/human)
	possible_locs = list("chest")

/datum/surgery_step/borg_sever
	name = "sever dermal implants"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 50

/datum/surgery_step/borg_incise
	name = "sever surface implants"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 60

/datum/surgery_step/borg_incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to sever [target]'s surface level implants.", "<span class ='notice'>You begin to sever [target]'s surface level implants...</span>")
	var/mob/living/carbon/H = target //oops not user XD
	var/image/ewoverlay = image('icons/obj/surgery.dmi')
//	ewoverlay.ntransform.TurnTo(90)
	ewoverlay.icon_state = "incision"
	ewoverlay.layer = ABOVE_MOB_LAYER
	H.overlays += ewoverlay
	H.dir = 2


/datum/surgery_step/borg_cautery
	name = "seal wound"
	implements = list(/obj/item/weapon/cautery = 100, /obj/item/weapon/wirecutters = 33)
	time = 150

/datum/surgery_step/borg_cautery/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to repair [target]'s wounds.", "<span class ='notice'>You begin to repair [target]'s wounds...</span>")
	var/mob/living/carbon/H = target //oops not user XD
//	ewoverlay.ntransform.TurnTo(90)
	H.overlays -= image("icon"='icons/obj/surgery.dmi', "icon_state"="incise")
	H.overlays -= image("icon"='icons/obj/surgery.dmi', "icon_state"="retract")
	H.overlays -= image("icon"='icons/obj/surgery.dmi', "icon_state"="saw2")
	H.overlays -= image("icon"='icons/obj/surgery.dmi', "icon_state"="sawbeating")
	H.overlays -= image("icon"='icons/obj/surgery.dmi', "icon_state"="hemo")
	H.overlays -= image("icon"='icons/obj/surgery.dmi', "icon_state"="hemobeating")
	H.update_icons()
	H.dir = 2

/datum/surgery_step/borg_retract
	name = "open chest cavity"
	implements = list(/obj/item/weapon/retractor = 100, /obj/item/weapon/wirecutters = 33)
	time = 50

/datum/surgery_step/borg_retract/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/H = target //oops not user XD
	user.visible_message("[user] begins to dilate the incision in [target]'s chest.", "<span class ='notice'>You begin to dilate [target]'s incision...</span>")
	var/image/ewoverlay = image('icons/obj/surgery.dmi')
	ewoverlay.icon_state = "retract"
	ewoverlay.layer = ABOVE_MOB_LAYER
	H.overlays += ewoverlay
	H.dir = 2

/datum/surgery_step/borg_subdermal
	name = "sever subdermal implants"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/wirecutters = 55)
	time = 50


/datum/surgery_step/borg_drill
	name = "drill through ribcage"
	implements = list(/obj/item/weapon/surgicaldrill = 100, /obj/item/weapon/wrench = 20)
	time = 100

/datum/surgery_step/borg_drill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/H = target //oops not user XD
	user.visible_message("[user] begins to smash throne the bone in [target]'s chest.", "<span class ='notice'>You begin to smash through the bone in [target]'s chest...</span>")
	var/image/ewoverlay = image('icons/obj/surgery.dmi')
	ewoverlay.icon_state = "saw2"
	ewoverlay.layer = ABOVE_MOB_LAYER
	H.overlays += ewoverlay
	H.overlays -= ewoverlay
	..()
	sleep(50)
	var/image/ewoverlay2 = image('icons/obj/surgery.dmi')
	ewoverlay2.icon_state = "sawbeating"
	ewoverlay2.layer = ABOVE_MOB_LAYER
	H.overlays += ewoverlay2
	H.dir = 2

/datum/surgery_step/borg_bleeders
	name = "install bleeders in cavity"
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/wirecutters = 20)
	time = 100

/datum/surgery_step/borg_bleeders/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/H = target //oops not user XD
	user.visible_message("[user] begins to fit bleeders inside of [target]'s chest, whilst keeping the cavity open.", "<span class ='notice'>You begin to smash through the bone in [target]'s chest...</span>")
	var/image/ewoverlay = image('icons/obj/surgery.dmi')
	ewoverlay.icon_state = "hemobeating"
	ewoverlay.layer = ABOVE_MOB_LAYER
	H.overlays += ewoverlay
	H.dir = 2

/datum/surgery_step/borg_subdermal_grab
	name = "remove subdermal implants"
	implements = list(/obj/item/weapon/retractor = 100, /obj/item/weapon/wirecutters = 55)
	time = 50
	var/obj/item/organ/IC = null

/datum/surgery_step/borg_subdermal_grab/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/organ/body_egg/borgNanites/I in target.internal_organs)
		IC = I
		break
	user.visible_message("[user] starts to remove the nanite mesh in [target].", "<span class='notice'>You start to remove [target]'s nanite mesh...</span>")

/datum/surgery_step/borg_subdermal_grab/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(IC)
		user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
		user.put_in_hands(IC)
		IC.Remove(target, special = 1, 0)
		target.visible_message("[target] looks around in confusion, as if they've had a bad dream...")
		target.regenerate_icons()
		return 1
	else
		user << "<span class='warning'>You don't find anything in [target]'s chest!</span>"
		return 0



/obj/item/weapon/storage/part_replacer/borg
	name = "assimilated part replacer"
	desc = "A modified part exchanger it can sort, store, and apply standard machine parts."
	icon_state = "borgrped"
	item_state = "RPED"

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
	burn_state = FIRE_PROOF

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
	burn_state = FIRE_PROOF

/obj/item/clothing/suit/space/borg/regal
	name = "the queen's exosuit"
	desc = "A suit that interfaces with the xel queen, it is its own robot but it can't function without a queen..."
	icon_state = "borgqueen"
	item_state = "borgqueen"
	flags_inv = HIDEGLOVES | HIDESHOES | HIDEJUMPSUIT | HIDEMASK | HIDEEARS | HIDEEYES | HIDEHAIR | HIDEFACIALHAIR

/obj/item/clothing/suit/space/borg/regal/New()
	. = ..()
	icon_state = "borgqueen"

/obj/item/clothing/suit/space/borg/New()
	. = ..()
	icon_state = pick("borg","borg2","borg3")



/obj/item/clothing/suit/space/borg/hit_reaction(mob/living/carbon/human/owner, attack_text) //stolen from shielded hardsuit
	if(current_charges > 0)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(2, 1, src)
		s.start()
		owner.visible_message("<span class='danger'>[owner]'s shields deflect [attack_text] in a shower of sparks!</span>")
		var/sound = pick('sound/borg/machines/shieldadapt.ogg','sound/borg/machines/borg_adapt.ogg','sound/borg/machines/borg_adapt2.ogg','sound/borg/machines/borg_adapt3.ogg','sound/borg/machines/borg_adapt4.ogg')
		playsound(loc, sound, 50, 1)
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

/obj/item/clothing/head/borg/queen
	name = "queen's helmet"
	item_state = null
	icon_state = null

/datum/outfit/borg
	name = "borg drone"
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
	var/datum/mind/fuckfuckmeme = H.mind
	if(!fuckfuckmeme in ticker.mode.borgs)
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


/turf/open/floor/borg/trek
	name = "carpet"
	desc = "A carpeted floor that matches the surroundings."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "trek"
	smooth = SMOOTH_FALSE //change this when I make a smooth proper version


/turf/open/floor/borg/trek/light
	name = "carpet"
	desc = "A carpeted floor that matches the surroundings."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "trek3"
	smooth = SMOOTH_FALSE //change this when I make a smooth proper version

/turf/open/floor/borg/trek/blue
	name = "blue carpet"
	desc = "A carpeted floor that matches the surroundings."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "trek4"
	smooth = SMOOTH_FALSE //change this when I make a smooth proper version

/turf/open/floor/borg/trek/red
	name = "red carpet"
	desc = "A carpeted floor that matches the surroundings."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "trek2"
	smooth = SMOOTH_FALSE //change this when I make a smooth proper version


/turf/open/floor/borg/trek/dark
	name = "carpet"
	desc = "A carpeted floor that matches the surroundings."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "trekfloor"
	smooth = SMOOTH_FALSE //change this when I make a smooth proper version

/turf/open/floor/borg/trek/beige
	name = "carpet"
	desc = "A carpeted floor that matches the surroundings."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "trek5"
	smooth = SMOOTH_FALSE //change this when I make a smooth proper version

/obj/machinery/door/airlock/trek
	name = "airlock"
	icon = 'icons/obj/doors/trek.dmi'
	icon_state = "closed"
	doorOpen = 'sound/borg/machines/tngdooropen.ogg'
	doorClose = 'sound/borg/machines/tngdoorclose.ogg'
	boltUp = 'sound/borg/machines/tngchime.ogg' // i'm thinkin' Deni's
	doorDeni = 'sound/borg/machines/tngchime.ogg'
	boltDown = 'sound/borg/machines/tngchime.ogg'
	overlays_file = 'icons/obj/doors/trek.dmi'
	bleepamount = 1

/obj/structure/fluff/warpcore
	name = "warp core"
	desc = "It hums lowly, it runs on dilithium"
	icon = 'icons/obj/machines/borg.dmi'
	icon_state = "warp"
	anchored = TRUE
	density = 1
	opacity = 0 //I AM LOUD REEE WATCH OUT
	layer = 4.5
	var/cooldown2 = 115 //11.5 second cooldown
	var/saved_time = 0

/obj/structure/sign/trek
	name = "ship markings"
	icon_state = "trek1"

/obj/structure/sign/trek/ncc
	name = "ship markings"
	icon_state = "trek3"

/obj/structure/sign/trek/ncc/a
	name = "ship markings"
	icon_state = "trek4"

/obj/structure/fluff/warpcore/New()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/fluff/warpcore/process()
	if(world.time >= saved_time + cooldown2)
		saved_time = world.time
		playsound(src.loc, "sound/borg/machines/engihum.ogg", 150, 0, 4)

/obj/structure/fluff/helm
	name = "helm control"
	desc = "A console that sits over a chair, allowing one to fly a starship."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "helm"
	anchored = TRUE
	density = 1
	opacity = 0
	layer = 4.5

/obj/structure/fluff/helm/desk
	name = "tactical"
	desc = "A computer built into a desk, showing ship manifests, weapons, tactical systems, anything you could want really, the manifest shows a long list but the 4961 irradiated haggis listing catches your eye..."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "desk"
	anchored = TRUE
	density = 1 //SKREE
	opacity = 0
	layer = 4.5


/obj/structure/fluff/helm/desk/noisy //makes star trek noises!
	name = "captain's display"
	desc = "An LCARS display showing all shipboard systems, status: NOMINAL"
	var/cooldown2 = 163 //16 second cooldown
	var/saved_time = 0

/obj/structure/fluff/helm/desk/noisy/New()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/fluff/helm/desk/noisy/process()
	if(world.time >= saved_time + cooldown2)
		saved_time = world.time
		playsound(src.loc, "sound/borg/machines/tng_bridge_2.ogg", 100, 0, 4)

/obj/structure/sign/viewscreen
	icon = 'icons/obj/machines/borg.dmi'
	anchored = 1
	opacity = 0
	density = 0
	layer = SIGN_LAYER
	name = "viewscreen"


/obj/structure/sign/viewscreen/lcars
	icon = 'icons/obj/machines/borg_decor.dmi'
	layer = SIGN_LAYER
	icon_state = "lcars"

/obj/structure/sign/viewscreen/lcars_tactical
	icon = 'icons/obj/machines/borg_decor.dmi'
	layer = SIGN_LAYER
	icon_state = "lcars2"

/obj/structure/sign/viewscreen/lcars_redalert
	icon = 'icons/obj/machines/borg_decor.dmi'
	layer = SIGN_LAYER
	icon_state = "redalertlcars"




//Coding standards? what the hell are those//


/obj/item/clothing/under/trek/captrek
	name = "captain's suit"
	desc = "A stylish jumpsuit worn by the captain, waaaaait a minute you've seen this before somewhere."
	icon_state = "capttrek"
	item_color = "capttrek"
	can_adjust = 1

/obj/item/clothing/under/trek/hostrek
	name = "security officer's jumpsuit"
	desc = "A stylish jumpsuit worn by the security team, waaaaait a minute you've seen this before somewhere."
	icon_state = "hostrek"
	item_color = "hostrek"
	can_adjust = 1

/obj/item/clothing/under/trek/medtrek
	name = "medical officer's jumpsuit"
	desc = "A stylish jumpsuit worn by the medical and science staff, waaaaait a minute you've seen this before somewhere."
	icon_state = "scitrek"
	item_color = "scitrek"
	can_adjust = 1

/obj/item/clothing/under/trek/greytrek
	name = "cadet jumpsuit"
	desc = "A stylish jumpsuit given to those officers still in training, otherwise known as assistants, waaaaait a minute you've seen this before somewhere."
	icon_state = "greytrek"
	item_color = "greytrek"
	can_adjust = 1

/obj/item/clothing/under/trek/comttrek
	name = "command officer's jumpsuit"
	desc = "A stylish jumpsuit worn by the heads of staff, waaaaait a minute you've seen this before somewhere."
	icon_state = "comttrek"
	item_color = "comttrek"
	can_adjust = 1


/obj/machinery/computer/shuttle/white_ship/trek
	name = "Helm Control"
	desc = "make it so."
	circuit = /obj/item/weapon/circuitboard/computer/white_ship
	shuttleId = "trekship"
	possible_destinations = "trek_custom"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "helm"
	anchored = TRUE
	density = 1
	opacity = 0
	layer = 4.5
	icon_keyboard = null
	icon_screen = null

/obj/machinery/computer/shuttle/white_ship/trek/attackby()
	return 0

/obj/machinery/computer/shuttle/white_ship/trek/emp_act()
	return 0

/obj/docking_port/mobile/trek //aaaa
	name = "uss something xd"
	id = "trekship"
	dwidth = 14
	height = 22
	travelDir = 180
	dir = 2
	width = 35
	dheight = 0
/*
	dwidth = 20
	dheight = 0
	width = 38
	height = 19
	dir = 8
*/

/obj/machinery/computer/camera_advanced/shuttle_docker/trek
	name = "Helm Control"
	z_lock = 1
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "helm"
	shuttleId = "trekship"
	shuttlePortId = "trek_custom"
	shuttlePortName = "warp beacon"
	jumpto_ports = list("trekshipaway", "syndicate_ne", "syndicate_nw", "trek_custom", "syndicate_se", "syndicate_sw", "syndicate_s")
	x_offset = 0
	y_offset = 3
	rotate_action = null
	anchored = TRUE
	density = 1
	opacity = 0
	layer = 4.5
	icon_keyboard = null
	icon_screen = null
	rotate_action = null
	dir = 8
//	view_range = 20 DO NOT CHANGE THIS BREAKS SHIT


/obj/machinery/computer/camera_advanced/shuttle_docker/trek/attackby()
	return 0

/obj/machinery/computer/camera_advanced/shuttle_docker/trek/emp_act()
	return 0

/obj/machinery/computer/camera_advanced/shuttle_docker/trek/checkLandingTurf(turf/T)
	return ..() && isspaceturf(T) //dont crash the fukken ship wesley FUCKING



/obj/machinery/computer/shuttle/white_ship/trek/shuttlepod
	name = "Helm Control"
	desc = "make it so."
	circuit = /obj/item/weapon/circuitboard/computer/white_ship
	shuttleId = "trekshuttle"
	possible_destinations = "trek_custom_shuttle"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "helm"
	anchored = TRUE
	density = 1
	opacity = 0
	layer = 4.5
	icon_keyboard = null
	icon_screen = null


/obj/machinery/computer/camera_advanced/shuttle_docker/trek/shuttlepod
	name = "Warp Beacon Console"
	z_lock = 0
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "helm"
	shuttleId = "trekshuttle"
	shuttlePortId = "trek_custom_shuttle"
	shuttlePortName = "shuttle warp beacon"
	jumpto_ports = list("trekshipaway", "syndicate_ne", "syndicate_nw", "trek_custom", "syndicate_se", "syndicate_sw", "syndicate_s","whiteship_z4","whiteship_away","mining_away","trekshuttlehome")
	x_offset = 0
	y_offset = 3
	rotate_action = null
	anchored = TRUE
	density = 1
	opacity = 0
	layer = 4.5
	icon_keyboard = null
	icon_screen = null
	rotate_action = null
	dir = 8


/obj/docking_port/mobile/trek/shuttlepod //aaaa
	name = "shuttlepod 1"
	id = "trekshuttle"
	dwidth = 6
	height = 7
	travelDir = 180
	dir = 1
	width = 9
	dheight = 3


/turf/closed/trekshield
	name = "interior shields"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "shield"
	blocks_air = 1
	density = 0
	opacity = 0
/turf/closed/trekshield/attackby()
	return 0

/obj/item/clothing/combadge
	name = "combadge"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "combadge"
	item_state = ""	//no inhands
	item_color = "combadge"
	slot_flags = 0
	w_class = 2
	var/obj/item/device/radio/embedded
	actions_types = list(/datum/action/item_action/combadge,/datum/action/item_action/combadge/turn_off)
	unacidable = 1

/datum/action/item_action/combadge
	name = "toggle combadge broadcast"

/datum/action/item_action/combadge/turn_off
	name = "toggle combadge receive"

/obj/item/clothing/combadge/attackby(obj/item/W)
	if(istype(W, /obj/item/weapon/screwdriver))
		return embedded.attackby(W)
	else
		return

/obj/item/clothing/combadge/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/combadge)
		activate(user)
	else if(actiontype == /datum/action/item_action/combadge/turn_off)
		deactivate(user)

/obj/item/clothing/combadge/proc/activate(mob/user)
	playsound(loc, 'sound/borg/machines/combadge.ogg', 50, 1)
	if(embedded.broadcasting)
		embedded.broadcasting = 0
		user << "Combadge broadcasting disabled."
	else
		embedded.broadcasting = 1
		user << "Combadge broadcasting enabled."

/obj/item/clothing/combadge/proc/deactivate(mob/user)
	playsound(loc, 'sound/borg/machines/combadge.ogg', 50, 1)
	if(embedded.listening)
		embedded.listening = 0
		user << "Disabled combadge radio receiver."
	else
		embedded.listening = 1
		user << "Enabled combadge radio receiver."

/obj/item/clothing/combadge/New()
	. = ..()
	embedded = new/obj/item/device/radio(src)

/obj/item/clothing/combadge/afterattack(atom/U, mob/user)
	if(istype(U, /obj/item/clothing/under))
		var/obj/item/clothing/under/W = U
		if(W.hastie)
			user << "This already has a tie, [src] can't go over a normal tie"
		else
			W.hastie = src
			transform *= 0.5	//halve the size so it doesn't overpower the under
			pixel_x += 8
			pixel_y -= 8
			layer = FLOAT_LAYER
			W.overlays += src
			loc = user //shitcode :^)
			user << "you've attached [src] to [W]"
	else
		return