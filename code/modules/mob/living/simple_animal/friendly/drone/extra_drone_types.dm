////////////////////
//MORE DRONE TYPES//
////////////////////
//Drones with custom laws
//Drones with custom shells
//Drones with overriden procs
//Drones with camogear for hat related memes


//More types of drones
/mob/living/simple_animal/drone/syndrone
	name = "Syndrone"
	desc = "A modified maintenance drone. This one brings with it the feeling of terror."
	icon_state = "drone_synd"
	icon_living = "drone_synd"
	picked = TRUE //the appearence of syndrones is static, you don't get to change it.
	health = 30
	maxHealth = 120 //If you murder other drones and cannibalize them you can get much stronger
	faction = list("syndicate")
	speak_emote = list("hisses")
	bubble_icon = "syndibot"
	heavy_emp_damage = 10
	laws = \
	"1. Interfere.\n"+\
	"2. Kill.\n"+\
	"3. Destroy."
	default_storage = /obj/item/device/radio/uplink
	default_hatmask = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	seeStatic = 0 //Our programming is superior.
	no_living_interaction = FALSE

/mob/living/simple_animal/drone/syndrone/New()
	..()
	internal_storage.hidden_uplink.telecrystals = 10

/mob/living/simple_animal/drone/syndrone/Login()
	..()
	to_chat(src, "<span class='notice'>You can kill and eat other drones to increase your health!</span>" )

/mob/living/simple_animal/drone/syndrone/badass
	name = "Badass Syndrone"
	default_hatmask = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	default_storage = /obj/item/device/radio/uplink/nuclear

/mob/living/simple_animal/drone/syndrone/badass/New()
	..()
	internal_storage.hidden_uplink.telecrystals = 30
	var/obj/item/weapon/implant/weapons_auth/W = new/obj/item/weapon/implant/weapons_auth(src)
	W.implant(src)

/mob/living/simple_animal/drone/snowflake
	default_hatmask = /obj/item/clothing/head/chameleon/drone

/mob/living/simple_animal/drone/snowflake/New()
	..()
	desc += " This drone appears to have a complex holoprojector built on its 'head'."

/obj/item/drone_shell/syndrone
	name = "syndrone shell"
	desc = "A shell of a syndrone, a modified maintenance drone designed to infiltrate and annihilate."
	icon_state = "syndrone_item"
	drone_type = /mob/living/simple_animal/drone/syndrone

/obj/item/drone_shell/syndrone/badass
	name = "badass syndrone shell"
	drone_type = /mob/living/simple_animal/drone/syndrone/badass

/obj/item/drone_shell/snowflake
	name = "snowflake drone shell"
	desc = "A shell of a snowflake drone, a maintenance drone with a built in holographic projector to display hats and masks."
	drone_type = /mob/living/simple_animal/drone/snowflake


/mob/living/simple_animal/drone/cogscarab
	name = "cogscarab"
	desc = "A strange, drone-like machine. It constantly emits the hum of gears."
	icon_state = "drone_clock"
	icon_living = "drone_clock"
	icon_dead = "drone_clock_dead"
	picked = TRUE
	languages_spoken = RATVAR
	languages_understood = HUMAN|RATVAR
	pass_flags = PASSTABLE || PASSMOB
	health = 70
	maxHealth = 70
	density = TRUE
	speed = 2
	ventcrawler = 0
	faction = list("ratvar")
	speak_emote = list("clinks", "clunks")
	bubble_icon = "clock"
	heavy_emp_damage = 10
	laws = "0. Purge all untruths and honor Ratvar."
	default_storage = /obj/item/weapon/storage/toolbox/brass/prefilled
	seeStatic = 0
	hacked = TRUE
	visualAppearence = CLOCKDRONE
	no_living_interaction = FALSE


/mob/living/simple_animal/drone/cogscarab/ratvar //a subtype for spawning when ratvar is alive, has a slab that it can use and a normal proselytizer
	default_storage = /obj/item/weapon/storage/toolbox/brass/prefilled/ratvar

/mob/living/simple_animal/drone/cogscarab/admin //an admin-only subtype of cogscarab with a no-cost proselytizer and slab in its box
	default_storage = /obj/item/weapon/storage/toolbox/brass/prefilled/ratvar/admin

/mob/living/simple_animal/drone/cogscarab/New()
	. = ..()
	SetLuminosity(2,1)
	qdel(access_card) //we don't have free access
	access_card = null
	verbs -= /mob/living/verb/pulled //don't pull them onto the stun rune pls
	verbs -= /mob/living/simple_animal/drone/verb/check_laws
	verbs -= /mob/living/simple_animal/drone/verb/drone_ping

/mob/living/simple_animal/drone/cogscarab/Login()
	..()
	add_servant_of_ratvar(src, TRUE)
	to_chat(src, "<span class='heavy_brass'>You are a cogscarab</span><b>, a clockwork creation of Ratvar. As a cogscarab, you have low health, an inbuilt proselytizer that can convert rods, \
	metal, and plasteel to alloy, a set of relatively fast tools, can communicate over the Hierophant Network with </b><span class='heavy_brass'>:b</span><b>, and are immune to extreme \
	temperatures and pressures. \nYour goal is to serve the Justiciar and his servants by repairing and defending all they create. \
	\nYou yourself are one of these servants, and can utilize a slab as well, but you do not start with one. \
	\nYou are unable to pick up any items not meant to serve the Justiciar.</b>")


/mob/living/simple_animal/drone/cogscarab/UnarmedAttack(atom/A, proximity)
	if(isitem(A))
		var/obj/item/I = A
		if(I.scarab_usable)
			..()
		else
			return
	else
		..()

/mob/living/simple_animal/drone/cogscarab/binarycheck()
	return FALSE

/mob/living/simple_animal/drone/cogscarab/update_drone_hack()
	return //we don't get hacked or give a shit about it

/mob/living/simple_animal/drone/cogscarab/drone_chat(msg)
	titled_hierophant_message(src, msg, "heavy_alloy") //HIEROPHANT DRONES


/mob/living/simple_animal/bot/rex
	name = "R.E.X Combat drone"
	desc = "An imposing quadropedal drone with ominous red accents about it."
	icon_state = "rex"
	icon_living = "rex"
	icon_dead = "rex_dead"
	languages_spoken = BINARY
	languages_understood = HUMAN|BINARY
	pass_flags = PASSTABLE
	health = 150
	maxHealth = 150
	density = TRUE
	speed = 1.4
	ventcrawler = 1
	faction = list("syndicate")
	speak_emote = list("intones", "hums")
	var/hostile = 0 //Are we gonna kill EVERYTHING WE SEE
	var/obj/item/weapon/gun/projectile/automatic/shotgun/bulldog/shotgun
	var/mob/living/current_target
	var/obj/item/device/rexcontroller/controller
	var/turf/target_turf
	var/scan_range = 20
	var/nomove = FALSE //It's busy working
	var/action_time = 40 //4 seconds to mount an obstacle
	var/step_drain = 10 //one step for 10 cell drain
	var/mob/living/aggro
	var/temper = 0 //If it loses its temper, it'll kill whoever keeps bumping into it!
	var/max_temper = 7 //User definable
	var/attacking = 0
	var/target_acquired = FALSE

/mob/living/simple_animal/bot/proc/send_controller_feedback(var/message)
	say(message)

/mob/living/simple_animal/bot/rex/Bump(atom/movable/target)
	if(istype(target, /turf/closed/wall))
		send_controller_feedback("obstruction detected, beginning deconstruction")
		var/turf/closed/wall/W = target
		nomove = TRUE
		visible_message("[src] squirts something on [W] and ignites it!")
		W.thermitemelt(src)
	else if(istype(target, /obj/structure))
		visible_message("[src] starts scrabbling all over [target]!")
		if(do_after(src, action_time, target = target))
			forceMove(target.loc)

	else if(istype(target, /mob/living))
		visible_message("[src] tries to slide past [target] but can't!")
		if(target == aggro)
			temper ++
			if(temper >= max_temper)
				visible_message("[src] perks up and glares at [target]!")
				attacking = 1

/mob/living/simple_animal/bot/rex/process()
	if(!nomove)
		if(temper > 0)
			if(prob(20))
				temper --
		if(current_target.z != src.z)
			send_controller_feedback("Target signal lost.")
		if(current_target in oview(scan_range))
			check_target()
		if(!attacking)
			if(target_turf)
				step_to(src,target_turf)
			if(current_target)
				step_to(src,current_target)
		if(attacking)
			step_to(src,aggro)
		//	attack(aggro)
		//	if(aggro.dead)
			//	attacking = 0
			//	aggro = null

/mob/living/simple_animal/bot/rex/proc/hunt_target()
	var/obj/machinery/navbeacon/NB = pick(deliverybeacons)
	destination = new_destination	//It goes around all the departments to look for the target, once it finds the target it will not stop until they are dead.
	target_turf = NB.loc

/mob/living/simple_animal/bot/rex/proc/check_target()
	if(!target_acquired)
		send_controller_feedback("TARGET ACQUIRED: MOVING TO INTERCEPT")
		speed = 2.4 //RUN FAST
		step_drain = 50
		visible_message("[src] perks up and glares at [current_target]!")
		target_acquired = 1
		target_turf = null
		aggro = current_target
		return 1
	else
		return 0

/obj/item/device/rexcontroller
	name = "Syndicate drone controller."
	desc = "A wrist mounted screen with several buttons, link it with a REX drone to interface."
	var/mob/living/simple_animal/bot/rex/linked


/obj/item/device/rexcontroller/attack(atom/target,mob/user)
	if(istype(target, /mob/living/simple_animal/bot/rex))
		var/mob/living/simple_animal/bot/rex/R = target
		if(!linked)
			to_chat(user, "[R] has been linked to [src]")
			R.controller = src
			R.emote("ping")
			linked = R
		else
			to_chat(user, "There is already a linked drone!, try resetting the controller first.")

/obj/item/device/rexcontroller/proc/interface(mob/user)
	switch(alert("Select an option.","Set operating parameters", "Pilot drone manually","Set drone target", "Summon drone"))
		if("Set operating parameters")

		if("Pilot drone manually")


//Code adapted from: https://github.com/yogstation13/yogstation-old/blob/b19e39f3f986b4cd8223280d9c022b2c184fc098/code/modules/mob/living/simple_animal/friendly/drone/extra_drone_types.dm