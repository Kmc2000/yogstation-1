/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"


/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = 1
	stun = 5
	weaken = 5
	stutter = 5
	jitter = 20
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 7
	makesBulletHoles = FALSE

/obj/item/projectile/energy/electrode/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
		sparks.set_up(1, 1, src)
		sparks.start()
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.dna && (C.dna.check_mutation(HULK) || C.dna.check_mutation(ACTIVE_HULK)))
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		else if(CANWEAKEN in C.status_flags)
			spawn(5)
				C.do_jitter_animation(jitter)

/obj/item/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	..()

/obj/item/projectile/energy/net
	name = "energy netting"
	icon_state = "e_netting"
	damage = 10
	damage_type = STAMINA
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 10
	makesBulletHoles = FALSE

/obj/item/projectile/energy/net/New()
	..()
	SpinAnimation()

/obj/item/projectile/energy/net/on_hit(atom/target, blocked = 0)
	if(isliving(target))
		var/turf/Tloc = get_turf(target)
		if(!locate(/obj/effect/nettingportal) in Tloc)
			new/obj/effect/nettingportal(Tloc)
	..()

/obj/item/projectile/energy/net/on_range()
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	..()

/obj/effect/nettingportal
	name = "DRAGnet teleportation field"
	desc = "A field of bluespace energy, locking on to teleport a target."
	icon = 'icons/effects/effects.dmi'
	icon_state = "dragnetfield"
	anchored = 1
	unacidable = 1

/obj/effect/nettingportal/New()
	..()
	SetLuminosity(3)
	var/obj/item/device/radio/beacon/teletarget = null
	for(var/obj/machinery/computer/teleporter/com in machines)
		if(com.target)
			if(com.power_station && com.power_station.teleporter_hub && com.power_station.engaged)
				teletarget = com.target
	if(teletarget)
		spawn(30)
			for(var/mob/living/L in get_turf(src))
				do_teleport(L, teletarget, 2)//teleport what's in the tile to the beacon
			qdel(src)
	else
		spawn(30)
			for(var/mob/living/L in get_turf(src))
				do_teleport(L, L, 15) //Otherwise it just warps you off somewhere.
			qdel(src)


/obj/item/projectile/energy/trap
	name = "energy snare"
	icon_state = "e_snare"
	nodamage = 1
	weaken = 1
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 4
	makesBulletHoles = FALSE

/obj/item/projectile/energy/trap/on_hit(atom/target, blocked = 0)
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - drop a trap
		new/obj/item/weapon/restraints/legcuffs/beartrap/energy(get_turf(loc))
	else if(iscarbon(target))
		var/obj/item/weapon/restraints/legcuffs/beartrap/B = new /obj/item/weapon/restraints/legcuffs/beartrap/energy(get_turf(target))
		B.Crossed(target)
	..()

/obj/item/projectile/energy/trap/on_range()
	new/obj/item/weapon/restraints/legcuffs/beartrap/energy(loc)
	..()

/obj/item/projectile/energy/trap/cyborg
	name = "Energy Bola"
	icon_state = "e_snare"
	nodamage = 1
	weaken = 0
	hitsound = 'sound/weapons/taserhit.ogg'
	range = 10
	makesBulletHoles = FALSE

/obj/item/projectile/energy/trap/cyborg/on_hit(atom/target, blocked = 0)
	if(!ismob(target) || blocked >= 100)
		var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
		sparks.set_up(1, 1, src)
		sparks.start()
		qdel(src)
	if(iscarbon(target))
		var/obj/item/weapon/restraints/legcuffs/beartrap/B = new /obj/item/weapon/restraints/legcuffs/beartrap/energy/cyborg(get_turf(target))
		B.Crossed(target)
	spawn(10)
		qdel(src)
	..()

/obj/item/projectile/energy/trap/cyborg/on_range()
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	qdel(src)

/obj/item/projectile/energy/declone
	name = "radiation beam"
	icon_state = "declone"
	damage = 20
	damage_type = CLONE
	irradiate = 10
	makesBulletHoles = FALSE

/obj/item/projectile/energy/dart //ninja throwing dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5
	range = 7
	makesBulletHoles = FALSE

/obj/item/projectile/energy/bolt //ebow bolts
	name = "bolt"
	icon_state = "cbbolt"
	damage = 20
	damage_type = TOX
	nodamage = 0
	stutter = 5
	irradiate = 35
	stun = 1

obj/item/projectile/energy/bolt/on_hit(target, blocked = 0)
	..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.confused)//if they've already been shot
			C.silent = 3 // if you can't hit another shot in 3 seconds you don't deserve the mute
		C.confused = 3

/obj/item/projectile/energy/bolt/large
	damage = 20

/obj/item/ammo_casing/energy/plasma
	projectile_type = /obj/item/projectile/plasma
	select_name = "plasma burst"
	fire_sound = 'sound/weapons/pulse.ogg'

/obj/item/ammo_casing/energy/plasma/adv
	projectile_type = /obj/item/projectile/plasma/adv

/obj/item/projectile/energy/shock_revolver
	name = "shock bolt"
	icon_state = "purple_laser"
	var/chain

/obj/item/ammo_casing/energy/shock_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/hook/P = BB
	spawn(1)
		P.chain = P.Beam(user,icon_state="purple_lightning",icon = 'icons/effects/effects.dmi',time=1000, maxdistance = 30)

/obj/item/projectile/energy/shock_revolver/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		tesla_zap(src, 3, 10000)
	qdel(chain)
