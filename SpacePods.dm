


/obj/effect/overlay/temp/pod_trail
	name = "ion exhaust"
	icon_state = "ion_fade"
	duration = 10
	randomdir = 0



/obj/mecha/space/pod
	desc = "A basic space faring vehicle with light armour and basic equipment"
	name = "\improper Multi-purpose Pod"
	icon_state = "pod"
	step_in = 3 //make a step in 0.3 seconds
	dir_in = 1 //Facing North.
	health = 100
	deflect_chance = 5
	damage_absorption = list("brute"=0.3,"fire"=1,"bullet"=0.3,"laser"=0.3,"energy"=0.85,"bomb"=1)
	max_temperature = 25000
	infra_luminosity = 6
	wreckage = /obj/structure/mecha_wreckage/gygax //chanmge this when i get a chance
	internal_damage_threshold = 35
	max_equip = 3
	step_energy_drain = 2  //don't want a high drain in spess
	//For syndiepod, use bumpsmash to destroy walls when collidede with pod//
	stepsound = 'sound/spacepods/thrust.ogg'
	icon = 'icons/obj/spacepod.dmi'
	//need to add can equip for all the non mecha stuff
	var/engines = 1 //change this to False when i actually code the engines :p
	bound_width = 64
	bound_height = 64
	var/flying = 0
	turnsound = 'sound/spacepods/thrust.ogg'
	var/next_pod_move = 0 //used for move delays		//le copy paste meme :^)
	var/pod_move_delay = 2 //tick delay between movements, lower = faster, higher = slower

/obj/mecha/space/pod/loaded/New() //put the stuff that starts in any basic pod here ((thrusters and life support whatsits etc.)
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/teleporter
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)
	return


//use anchored = 1 //no pulling around. when we add the towing thing to el ripley//

//obj/mecha/space/pod/Move(NewLoc,Dir=0,step_x=0,step_y=0)		//DIRECTLY copied from goonstation's pods
	// check oversize bounds
//	flying = src.dir
//	var/turf/new_loc = get_turf(NewLoc)
//	if (flying == WEST && new_loc.x == 1)
//		return ..(NewLoc, Dir, step_x, step_y)
//	if (flying == SOUTH && new_loc.y == 1)
//		return ..(NewLoc, Dir, step_x, step_y)

//	var/turf/t1 = get_step(NewLoc, Dir)
//	var/turf/t2
//	var/turf/t3
//	switch(Dir)
//		if(NORTH, SOUTH)
//			t2 = get_step(t1, EAST)
//			t3 = get_step(t1, WEST)
//			PoolOrNew(/obj/effect/overlay/temp/pod_trail, list(loc))
//		if(EAST, WEST)
//			t2 = get_step(t1, NORTH)
//			t3 = get_step(t1, SOUTH)
//			PoolOrNew(/obj/effect/overlay/temp/pod_trail, list(loc))
//
//	if (!t1 || !t2 || !t3 || !t1.CanPass(src, t1) || !t2.CanPass(src, t2) || !t3.CanPass(src, t3))
//		if (t1) Bump(t1)
//		if (t2) Bump(t2)
//		if (t3) Bump(t3)
//		return 0

	// set return value to default
//	.=..(NewLoc,Dir,step_x,step_y)



//obj/mecha/space/pod/relaymove(mob/user, direction)
//	if(!Process_Spacemove(direction) || world.time < next_pod_move || !isturf(loc))
//		return
//	next_pod_move = world.time + pod_move_delay

//	step(src, direction)
