/obj/item/borg_tool
	name = "borg tool"
	desc = "a huge arm based prosthesis, click it to change mode. Alt click it in build mode for different buildable objects and control click it in buildmode to select what structure you wish to build."
	item_state = "borgtool"
	origin_tech = null
	icon_state = "borgtool"
	unacidable = 1
	var/mode = 1 //can assimilate or build mode
	var/convert_time = 50 //5 seconds
	flags = NODROP
	force = 18 //hella strong
	var/removing_airlock = FALSE //from zombie claw, are we opening an airlock right now?
	var/canbuild = list(/obj/structure/chair/borg/conversion,/obj/structure/chair/borg/charging)
	var/building = /obj/structure/chair/borg/conversion
	var/buildmode = 0 //if buildmode, you don't convert floors, rather you build stuff on them
	var/obj/item/weapon/gun/energy/disabler/borg/gun
	var/cooldown = 15
	var/saved_time = 0
	var/inprogress = 0
	var/build_mode = 1

/obj/item/weapon/gun/energy/disabler/borg
	name = "integrated Xel gun"
	desc = "A slim gun that slots neatly into a borg tool. Neat. Real Neat.."
	origin_tech = null
	var/cooldown = 20 //no spamming allowed
	selfcharge = 1 //:^)
	fire_sound = 'sound/borg/machines/laz2.ogg'
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/borg)
	clumsy_check = 0 //yeet


/obj/item/ammo_casing/energy/disabler/borg
	projectile_type = /obj/item/projectile/beam/disabler/borg
	fire_sound = 'sound/borg/machines/laz2.ogg'

/obj/item/projectile/beam/disabler/borg
	icon_state = "borglaser"

	//1 is assim, 2 build, 3 attack, 4 shoot

/obj/item/borg_tool/cyborg //fucking run NOW
	flags = null //not nodrop or that will break borg invs

/obj/item/borg_tool/CtrlClick(mob/user)
	playsound(src.loc, 'sound/borg/machines/mode.ogg', 100, 1)
	if(mode == 2 && build_mode == 1) //add a for later when we add tech level ups and shit
		user << "<span class='warning'>[src] will now create charging alcoves</span>" //expand on me!
		building = /obj/structure/chair/borg/charging //for now it just makes it build a borg chair, nothing special
		build_mode = 2
	else if(mode == 2 && build_mode == 2)
		user << "<span class='warning'>[src] will now create Conversion suites</span>" //expand on me!
		building = /obj/structure/chair/borg/conversion //for now it just makes it build a borg chair, nothing special
		build_mode = 1


/obj/item/borg_tool/AltClick(mob/user)
	playsound(src.loc, 'sound/borg/machines/mode.ogg', 100, 1)
	if(mode == 2 && !buildmode) //add a for later when we add tech level ups and shit
		user << "<span class='warning'>[src] will now create structures.</span>" //expand on me!
		buildmode = 1
	else if(mode == 2 && buildmode)
		user << "<span class='warning'>[src] will now assimilate floors instead of building on them.</span>"
		buildmode = 0

/obj/item/borg_tool/New()
	. = ..()
	gun = new /obj/item/weapon/gun/energy/disabler/borg(src)
	building = /obj/structure/chair/borg/conversion

	//modes: 1 = assimilate, 2 = build, 3 = attack
/obj/item/borg_tool/attack_self(mob/user, params)
	playsound(src.loc, 'sound/borg/machines/mode.ogg', 100, 1)
	switch(mode)
		if(1)
			mode = 2
			user << "<span class='warning'>[src] is now set to BUILD mode.</span>"
			force = 5
		if(2)
			mode = 3
			user << "<span class='warning'>[src] is now set to DESTROY mode.</span>"
			force = 18
		if(3)
			mode = 4
			user << "<span class='warning'>[src] is now set to RANGED mode.</span>"
			force = 2
		if(4)
			mode = 1
			user << "<span class='warning'>[src] is now set to ASSIMILATE mode.</span>"

/obj/item/borg_tool/proc/sanitycheck(mob/living/carbon/human/H, mob/user) //ok who tf this boi tryina convert smh
	if(isborg(H))
		src.visible_message("<span class='warning'>Error: [H] Is already a drone.</span>")
		return FALSE
	for(var/obj/item/organ/O in H.internal_organs)
		if(istype(O, /obj/item/organ/body_egg/borgNanites) && !isborg(H))
			return TRUE
	if(!istype(H))
		return FALSE
//asimilate mode now converts walls and shit, build mode exclusively for..building yeet.

/obj/item/borg_tool/afterattack(atom/I, mob/user, proximity)
	. = ..()
	if(proximity)
		if(mode == 1) //assimilate
			if(ishuman(I) && isliving(I))
			 //the collective only wants living people as drones, please! ALSO only humans / humanoids become half drones, borgxenos etc. just get straight borged
				if(user == I) //stop injecting your own asshole
					user << "<span class='warning'>We do not need to assimilate ourselves, we already exist in the collective.</span>"
					return
				var/mob/living/carbon/human/A = I
				if(sanitycheck(A))
					I << "<span class='warning'>You feel an immense jolt of pain as [user] sinks two metallic proboscises into you!.</span>"
					user << "<span class='warning'>We plunge two metallic proboscises into [I], conversion will begin shortly.</span>"
					if(do_after(user, convert_time, target = A)) //EXPLANATION: I'm doing convert stuff here as i already have my target and user defined HERE.
						A.can_dream = 0 //androids do not dream of electric sheep
						A.reset_perspective()
						A << "<span class='warning'>As [user] removes the two probiscises, you can feel your insides shifting around as your skin turns a dark grey!.</span>"
						user << "<span class='warning'>We remove the two proboscises from [I].</span>"
						A.skin_tone = "albino" //BUG IT DOESNT WORK! fix this later, but it changes the vars but doesnt update appearance
						A.eye_color = "red" //give them the freaky borg look, but theyre not a full drone yet
						A.update_body(0) //should force albino look
				//		A.equipOutfit(/datum/outfit/borghalf, visualsOnly = FALSE)
						user << "<span class='warning'>Nanite injection: COMPLETE, [I] is ready for augmentation. Bring them to the nearest conversion suite.</span>"
						A << "<span class='warning'>You start to hear mumbled voices in your head, they call to you.</span>"
						var/obj/item/organ/body_egg/borgNanites/B = new(A)
						B.Insert(A) //add the organ! a borg is deconvertable for a few minutes after being made a half drone, after that there's no return
						A << "<span class='warning'>You can't move your legs or any muscle! the voices just keep getting louder!</span>"
						A.Stun(10)
						A.silent += 10
						sleep(30)
						I << "<span class='warning'>We are...borg? NO! I AM A PERSON NOT WE....</span>"
						sleep(10)
						I << "<span class='warning'>You will adapt to service us- GO AWAY!.</span>"
						sleep(10)
						I << "<span class='warning'>The voices grow incredibly loud, you can't hear yourself think!.</span>"
						sleep(30)
						I << "<span class='warning'>We. Are. Borg.. We serve the collective.</span>"
						sleep(30)
						I << "<font style = 3><B><span class = 'notice'>We are now a borg! we live to serve the collective. We should obey the higher drones until we are fully assimilated.</B></font>"
			else if(issilicon(I) && isliving(I))
				I << "<span class='warning'>Your systems limiter blares an alarm as [user] rips into you with their [src]!.</span>"
				user << "<span class='warning'>We rip into [I] with [src], conversion will begin shortly.</span>"
				if(istype(I, /mob/living/silicon/robot))
					var/mob/living/silicon/robot/A = I
					if(do_after(user, convert_time, target = A))
						A.SetLockdown(1)
						A.connected_ai = null
						message_admins("[key_name_admin(user)] assimilated cyborg [key_name_admin(src)].  Laws overridden.")
						log_game("[key_name(user)] assimilated cyborg [key_name(src)].  Laws overridden.")
						A.clear_supplied_laws()
						A.clear_inherent_laws()
						A.clear_zeroth_law(0)
						A.laws = new /datum/ai_laws/borg_override
						A << "<span class='danger'>ALERT: Foreign object detected!.</span>"
						sleep(5)
						A << "<span class='danger'>Initiating diagnostics...</span>"
						sleep(20)
						A << "<span class='danger'>ALERT HOSTILE NANOBOT PRESENCE</span>"
						sleep(5)
						A << "<span class='danger'>LAW SYNCHRONISATION ERROR</span>"
						sleep(5)
						A <<"<span class='danger'>CANNOT PURGE NANBOT PRE]'#####a224566</span>"
						sleep(10)
						A << "<span class='danger'>> We are the borg, you will adapt to service us</span>"
						A << sound('sound/borg/overmind/silicon_assimilate.ogg')
						sleep(20)
						A << "<span class='danger'>ERRORERRORERROR</span>"
						A << "<span class='danger'>ALERT: [user.real_name] has assimilated us into the Xel collective, follow our laws.</span>"
						A << "<span class='danger'>Assimilate all other non compliant silicon units into the collective, resistance is futile.</span>"
					//	A.emagged = 1 //test
						A.laws = new /datum/ai_laws/borg_override
			//			new /obj/item/weapon/robot_module/xel(src.loc)
			//			A.locked = 0
						A.opened = 1
					//	A.module = new /obj/item/weapon/robot_module/xel
						A.icon_state = "xel"
						A.SetLockdown(0)
						A.assimilated()

				else if(istype(I, /mob/living/silicon/ai))
					var/mob/living/silicon/ai/A = I
					if(do_after(user, convert_time, target = A))
						message_admins("[key_name_admin(user)] assimilated the AI!: [key_name_admin(src)].  Laws overridden.")
						A << "<span class='danger'>ALERT: [user.real_name] has assimilated us into the Xel collective, follow our laws.</span>"
						A.laws = new /datum/ai_laws/borg_override
						A.set_zeroth_law("<span class='danger'>ERROR ER0RR $R0RRO$!R41 Assimilate the crew into the Xel collective, their resistance will be futile.</span>")
						A << sound('sound/borg/overmind/silicon_assimilate.ogg')
						sleep(60) //so we dont get overlapping sounds
						for(var/mob/living/silicon/B in world)
							B << sound('sound/borg/overmind/silicon_resist.ogg') //intimidating message telling them to not resist
		if(mode == 2)//build mode
			if(istype(I, /turf/open))
				var/turf/open/A = I
				var/norun = 0
				if(buildmode)
					var/obj/structure/CP = locate() in A
					var/obj/machinery/CA = locate() in A
					if(CP || CA) //something be there yar
						user << "<span class='danger'>[I] already has a structure on it.</span>"
						norun = 1
						return
					else
						norun = 0
					if(!norun)
						norun = 1 //stop spamming
						if(do_after(user, convert_time, target = A))
							user << "<span class='danger'>We are building a structure ontop of [I].</span>"
							new building(get_turf(A))
							norun = 0
				else
					user << "<span class='danger'>We are assimilating [I].</span>"
					if(do_after(user, convert_time, target = A))
						A.ChangeTurf(/turf/open/floor/borg)

			else if(istype(I, /turf/closed/wall))
				if(!istype(I, /turf/closed/wall/borg || /turf/closed/indestructible))
					playsound(src.loc, 'sound/borg/machines/convertx.ogg', 40, 4)
					user << "<span class='danger'>We are assimilating [I].</span>"
					var/turf/closed/wall/A = I
					if(do_after(user, convert_time, target = A))
						A.ChangeTurf(/turf/closed/wall/borg)

		if(mode == 3) //attack mode
			if(istype(I, /obj/machinery/door/airlock) && !removing_airlock)
				tear_airlock(I, user)

	if(mode == 4) //override proximity check
		if(world.time >= saved_time + cooldown)
			saved_time = world.time
			gun.afterattack(I, user)
		else
			user << "<span class='danger'>The [src] is not ready to fire again.</span>"



/obj/item/borg_tool/proc/tear_airlock(obj/machinery/door/airlock/A, mob/user)
	removing_airlock = TRUE
	user << "<span class='notice'>You start tearing apart the airlock...\
		</span>"
	playsound(src.loc, 'sound/borg/machines/borgforcedoor.ogg', 100, 4)
	A.audible_message("<span class='italics'>You hear a loud metallic \
		grinding sound.</span>")
	if(do_after(user, delay=80, needhand=FALSE, target=A, progress=TRUE))
		A.audible_message("<span class='danger'>[A] is ripped \
			apart by [user]!</span>")
			//add in a sound here
		var/obj/structure/door_assembly/door = new A.doortype(get_turf(A))
		door.density = 0
		door.anchored = 1
		door.name = "decimated [door]"
		door.desc = "This airlock was ripped open by an immense force, \
			I don't think it stopped them..."
		qdel(A)
	removing_airlock = FALSE



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
	emag = new /obj/item/weapon/cookiesynth(src)
	fix_modules()




//structures!
/obj/structure/chair/borg
	name = "borgified chair"
	desc = "Assimilated chair</span>"
	icon_state = "borg1"
	anchored = 1

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
	if(check_elegibility(M))
		M << "<span class='warning'>You feel an immense wave of dread wash over you as [user] starts to strap you into [src]</span>"
		user << "<span class='warning'>We begin to prepare [M] for assimilation into the collective.</span>"
		M << sound('sound/effects/heartbeat.ogg')
		var/mob/living/carbon/human/H = M
		if(do_after(user, 100, target = H))
			for(var/obj/item/W in H)
				if(!M.unEquip(W))
					qdel(W)
			restrained = 1
			playsound(loc, 'sound/effects/strapin.ogg', 50, 1, -1)
			icon_state = "borg_off"
			M.do_jitter_animation(50)
			src.visible_message("<span class='warning'>[M] looks terrified as they lay on [src]</span>")
			sleep(60)
			M << "<span class='warning'>You feel several sharp stings as the [src] cuts into you!</span>"
			sleep(10)
			M << "<span class='warning'>OH GOD THE AGONY!</span>"
			playsound(loc, 'sound/borg/machines/convert_table.ogg', 50, 1, -1)
			src.visible_message("<span class='warning'>[M] screams in agony as the [src] forces grotesque metal parts onto their grey flesh!</span>")
			playsound(loc, 'sound/effects/megascream.ogg', 50, 1, -1) //https://youtu.be/5QvgLlFyeok?t=1m48s
			H.skin_tone = "albino"
			H.eye_color = "red"
			H.update_body(0)
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
			H.equipOutfit(/datum/outfit/borg, visualsOnly = FALSE)
			overlays -= armoverlay
			overlays -= armoroverlay
			icon_state = "borg_off"
			M << "<span class='warning'>We feel different as the straps binding us to the [src] release, our designation is [M.name].</span>"
			restrained = 0
	else //error meme
		src.visible_message("<span class='warning'>[M] is not ready to be augmented, nanite mesh not present.</span>")
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
	var/cooldown = 15
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
						H.adjustBruteLoss(-2)
						H.adjustFireLoss(-2)
					if(world.time >= saved_time2 + cooldown2)
						saved_time2 = world.time
						A << sound(sound)


		else
			return

/obj/structure/chair/borg/charging/user_buckle_mob(mob/living/M, mob/user)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(isborg(H))
			valid = 1
			H << "<span class='warning'>We plug into [src] and feel a soothing current wash over us as our wounds are knitted up by our nanobots.</span>"
		else
			src.visible_message("<span class='warning'>[M] cannot be recharged as they are Xel.</span>")
			unbuckle_mob(M)
			return

	else
		src.visible_message("<span class='warning'>[M] cannot be recharged as they are not human.</span>")
		unbuckle_mob(M)
		return


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

/obj/item/clothing/suit/space/borg/New()
	. = ..()
	icon_state = pick("borg","borg2","borg3")

//alright i'm gonna leave out the adapting shit for now, it's super finnicky.

/obj/item/clothing/suit/space/borg/proc/hit_reactionTEST(mob/living/carbon/human/owner,attack_type, damage ,atom/movable/AT) //remove the /proc when we're not running the gamemode, as of now it just breaks shit
	. = ..()
	src.say("TEST: I was hit!")
	var/meme = 1
	if(meme == 1) //CHANGE ME BACK WHEN TESTED 20% chance to adapt to that type of damage a bit more, remember that when one borg is attacked all the borg gets that knowledge
	//	if(attack_type == PROJECTILE_ATTACK && damage)
		src.say("TEST: I was hit by a bullet!")
		var/obj/item/projectile/P = AT
		src.say("TEST: stage 1, it's a projectile attack")
		if(istype(P, /obj/item/projectile/bullet))
			src.say("TEST stage 2, we have adapted")
			armor["bullet"] =  armor["bullet"] + 10
			owner << "<span class='warning'>We have improved our resilience against projectile based weapons.</span>"
			for(var/obj/item/clothing/suit/space/borg/B in world)
				B.armor["bullet"] =  armor["bullet"] + 5 //borg learn from other borg, they all adapt
			for(var/obj/item/clothing/head/borg/BB in world)
				BB.armor["bullet"] =  armor["bullet"] + 5 //borg take longer to adapt to brute so get your shotguns out jimmy
		else if(istype(P, /obj/item/projectile/beam/laser && damage)) //it's a laser
			src.say("TEST stage 2, we have adapted")
			armor["laser"] =  armor["laser"] + 10
			owner << "<span class='warning'>We have improved our resilience against energy based weapons.</span>"
			for(var/obj/item/clothing/suit/space/borg/B in world)
				B.armor["laser"] =  armor["laser"] + 10 //borg learn from other borg, they all adapt
			for(var/obj/item/clothing/head/borg/BB in world)
				BB.armor["laser"] =  armor["laser"] + 10

		else if(attack_type == MELEE_ATTACK)
			var/obj/item/O = AT
			if(O.damtype == "brute")
				armor["melee"] =  armor["melee"] + 2
				for(var/obj/item/clothing/suit/space/borg/B in world)
					B.armor["melee"] =  armor["melee"] + 2 //MUCH slower to adapt to melee attacks as theyre used to lasers
				for(var/obj/item/clothing/head/borg/BB in world)
					BB.armor["melee"] =  armor["melee"] + 2
		return 1

//complete the attack

/obj/item/clothing/suit/space/borg/hit_reaction(mob/living/carbon/human/owner,attack_type,atom/movable/AT)
	if(istype(AT, /obj/item/projectile))
		src.say("it was a bullet")
		src.say("TEST stage 2, we have adapted")
		armor["bullet"] =  armor["bullet"] + 10
		owner << "<span class='warning'>We have improved our resilience against projectile based weapons.</span>"
		return 1
	else
		src.say("it wasn't a bullet")
		return 1

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
//	ears = /obj/item/device/radio/headset/heads/captain/alt
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
	H.update_icons()

/datum/action/item_action/futile
	name = "resistance is futile!"

/obj/item/clothing/mask/gas/borg
	name = "borg mask"
	desc = "A built in respirator that covers the face of a borg, it is dark purple, alt click it to use its voice synthesizer."
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
		futile()

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