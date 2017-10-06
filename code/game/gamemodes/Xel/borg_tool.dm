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
	var/norun = 0 //stops infinite chair spam


/obj/item/borg_tool/New()
	. = ..()
	gun = new /obj/item/weapon/gun/energy/disabler/borg(src)
	building = /obj/structure/chair/borg/conversion

/obj/item/borg_checker
	name = "area checker"
	desc = "reee."
	item_state = "borgtool"
	origin_tech = null
	icon_state = "borgtool"
	var/locname
	var/announced = 0
	var/turfs_in_a = 0
	var/borg_turfs_in_target = 0 //used to calculate if the area is fully borg'd

/obj/item/borg_checker/New()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/borg_checker/CtrlClick(mob/user)
	borg_turfs_in_target = 0
	turfs_in_a = 0
	user << "we're checking eligibiliy!"
	var/area/A = get_area(src)
	locname = initial(A.name)
	if(istype(A, ticker.mode.borg_target_area))
		src.visible_message("A is the target area")
		for(var/turf/T in get_area_turfs(A))
			if(istype(T, /turf))
				user << "turfs in a: [turfs_in_a]" //turfs remaining
				turfs_in_a ++
			if(istype(T, /turf/open/floor/borg))
				borg_turfs_in_target ++
				turfs_in_a --
			if(istype(T, /turf/closed/wall/borg))
				borg_turfs_in_target ++
				turfs_in_a --
		user << "There are [turfs_in_a] remaining, un-assimilated turfs in [locname], and [borg_turfs_in_target] of those turfs are borg turfs."
	else
		user << "it's not the right area, the right area is [ticker.mode.borg_target_area], we are currently in [A]"

/obj/item/borg_checker/AltClick(mob/user)
	if(!announced)
		user << "stage 1"
		user << "borg turfs : [borg_turfs_in_target], other turfs: [turfs_in_a]"
		if(borg_turfs_in_target > turfs_in_a) //60% or more of the turfs are assimilated
			user << "stage 2"
			announced = 1
			var/message = "[locname] has been assimilated. Build ship components to complete area takeover."
			var/ping = "<font color='green' size='2'><B><i>Xel collective</i> HIVEMIND SUBSYSTEM: [message]</B></font></span>"
		//	user << "[ping]"
			ticker.mode.borg_completion_assimilation = 1
			for(var/mob/living/I in world)
				if(I.mind in ticker.mode.borgs)
					I << ping
					return
	if(borg_turfs_in_target < turfs_in_a && announced)
		var/message = "<font color='green' size='2'><B><i>Xel collective</i> HIVEMIND SUBSYSTEM: [locname] is no longer suitable, re-claim it by assimilating turfs.</B></font></span>"
		announced = 0
		for(var/mob/living/I in ticker.mode.borgs)
			I << message
			return


/obj/item/weapon/gun/energy/disabler/borg //NOGUNS BREAKS THIS FIX PLS
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
	if(!norun)
		user << sound('sound/borg/machines/mode.ogg')
		if(mode == 2 && build_mode == 1) //add a for later when we add tech level ups and shit
			user << "<span class='warning'>[src] will now create charging alcoves</span>" //expand on me!
			building = /obj/structure/chair/borg/charging //for now it just makes it build a borg chair, nothing special
			build_mode = 2
		else if(mode == 2 && build_mode == 2)
			user << "<span class='warning'>[src] will now create Conversion suites</span>" //expand on me!
			building = /obj/structure/chair/borg/conversion //for now it just makes it build a borg chair, nothing special
			build_mode = 1
	else
		user << "<span class='warning'>[src] is still building something!</span>"

/obj/item/borg_tool/AltClick(mob/user)
	if(!norun)
		user << sound('sound/borg/machines/mode.ogg')
		if(mode == 2 && !buildmode) //add a for later when we add tech level ups and shit
			user << "<span class='warning'>[src] will now create structures.</span>" //expand on me!
			buildmode = 1
		else if(mode == 2 && buildmode)
			user << "<span class='warning'>[src] will now assimilate floors instead of building on them.</span>"
			buildmode = 0
	//modes: 1 = assimilate, 2 = build, 3 = attack
/obj/item/borg_tool/attack_self(mob/user, params)
	user << sound('sound/borg/machines/mode.ogg')
	norun = 0
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
			force = 0

/obj/item/borg_tool/proc/sanitycheck(mob/living/carbon/human/H, mob/user) //ok who tf this boi tryina convert smh
	for(var/obj/item/organ/O in H.internal_organs)
		if(istype(O, /obj/item/organ/body_egg/borgNanites))
			return FALSE
		else
			return TRUE
	if(!istype(H))
		return FALSE
//asimilate mode now converts walls and shit, build mode exclusively for..building yeet.

/obj/item/borg_tool/afterattack(atom/I, mob/user, proximity)
	. = ..()
	if(proximity && !norun)
		if(mode == 1) //assimilate
			if(ishuman(I) && isliving(I))
			 //the collective only wants living people as drones, please! ALSO only humans / humanoids become half drones, borgxenos etc. just get straight borged
				if(user == I) //stop injecting your own asshole
					user << "<span class='warning'>We do not need to assimilate ourselves, we already exist in the collective.</span>"
					return
				var/mob/living/carbon/human/A = I
				if(!isborg(A))
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
						B.Insert(A) //add the organ
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
						var/datum/mind/oneofus = A.mind
						ticker.mode.greet_borg(oneofus)
						ticker.mode.borgs += oneofus //doing this here so that halfdrones are considered antags
						oneofus.special_role = "Xel"


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
						ticker.mode.greet_borg_from_bench(A)
						ticker.mode.borgs += A
						sleep(60) //so we dont get overlapping sounds
						for(var/mob/living/silicon/B in world)
							B << sound('sound/borg/overmind/silicon_resist.ogg') //intimidating message telling them to not resist
		if(mode == 2 && !norun)//build mode
			if(istype(I, /turf/open))
				var/turf/open/A = I
				norun = 0
				var/canrun = 0
				if(buildmode)
					var/obj/structure/CP = locate() in A
					var/obj/machinery/CA = locate() in A
					if(CP || CA) //something be there yar
						user << "<span class='danger'>[I] already has a structure on it.</span>"
						norun = 1
						A = null
						canrun = 0
						return
					else				//all tiles turn invalid if you click another tile before youre done with the first
						norun = 0
						canrun = 1
					if(canrun)
						norun = 1 //stop spamming
						user << "<span class='danger'>We are building a structure ontop of [I].</span>"
						if(do_after(user, convert_time, target = A))
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

		else
			user << "<span class='danger'>[src] bleeps softly: ERROR.</span>"

	if(mode == 4) //override proximity check
		var/mob/living/carbon/human/A = user
		A.dna.species.specflags -= NOGUNS //sue me
		if(world.time >= saved_time + cooldown)
			saved_time = world.time
			gun.afterattack(I, user)
			A.dna.species.specflags |= NOGUNS
		else
			A.dna.species.specflags |= NOGUNS
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


