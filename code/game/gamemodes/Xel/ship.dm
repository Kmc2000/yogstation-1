#define PHYSICAL 1

/obj/machinery/space_battle/shield_generator
	name = "shield generator"
	desc = "An advanced shield generator, producing fields of rapidly fluxing plasma-state phoron particles."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "ecm"
	use_power = 1
	var/list/shields = list()
	var/list/active_shields = list()
	var/list/inactive_shields = list()
	var/shields_maintained = 0
	var/inactivity_time = 0
	idle_power_usage = 200
	var/on = 0 // power me up daddy
	var/controller = null
	var/health = 1050 //charge them up
	var/maxhealth = 20000
	var/flux_rate = 100
	var/flux = 1
	var/heat = 0
	var/regen = 0

/obj/machinery/machinemachine
	name = "machine machine broke"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "ecm"
	density = 1
	var/health = 1050 //charge them up
	var/maxhealth = 20000
	var/flux_rate = 100
	var/flux = 1
	var/heat = 0
	var/regen = 0
/obj/machinery/machinemachine/attack_hand()
	world << "regen rate[regen]"
	world << "maxhealth: [maxhealth]"
	world << "health: [health]"
	world << "heat: [heat]"
	calculate()

/obj/machinery/machinemachine/proc/calculate()
	flux_rate = flux*100
	regen = (flux*flux_rate)
	//heat += 50
	health += regen
	world << "calculating:"
	world << "regen rate[regen]"
	world << "maxhealth: [maxhealth]"
	world << "health: [health]"
	world << "heat: [heat]"
	if(health >= maxhealth)
		regen += (flux*flux_rate)
/obj/machinery/machinemachine/AltClick()
	world << "damage! heat at:[heat]"
	health -= 500

/obj/machinery/machinemachine/CtrlClick()
	world << "reset!"
	health = 1050 //charge them up
	maxhealth = 20000
	flux_rate = 50
	flux = 1
	heat = 0
	regen = 0


/obj/machinery/space_battle/shield_generator/attack_hand(mob/user)
	toggle(user)

/obj/machinery/space_battle/shield_generator/proc/toggle(mob/user)
	if(on)
		user << "shields dropped"
		on = 0 //turn off
		for(var/obj/effect/adv_shield/S in shields)
			S.deactivate()
		return
	if(!on)
		var/sample
		for(var/obj/effect/adv_shield/S in shields)
			sample = S.health
		if(sample > 1000)
			user << "shields activated"
			on = 1
			for(var/obj/effect/adv_shield/S in shields)
				S.activate()
			return
		else
			on = 0
			user << "error, shields regenerating after an attack"
			return

/obj/machinery/space_battle/shield_generator/New()
	..()
	initialize()

/obj/machinery/space_battle/shield_generator/initialize()
	var/area/thearea = get_area(src)
	for(var/obj/effect/landmark/shield/marker in thearea)
		if(!marker in thearea)
			return
		if(marker.z == src.z)
			var/obj/effect/adv_shield/shield = new(src)
			shield.dir = marker.dir
			shield.forceMove(get_turf(marker))
			shield.generator = src
			shield.icon_state = "shieldwalloff"
			shields += shield

/obj/machinery/space_battle/shield_generator/take_damage(var/damage, damage_type = PHYSICAL)
	src.say("Shield taking damage: [damage] : [damage_type == PHYSICAL ? "PHYSICAL" : "ENERGY"]")
	var/obj/effect/adv_shield/S = pick(shields)
	if(!S.density)
		return 0
//	if(S.damage_taken + damage > flux_allocation)
	//	active_shields.Remove(S)
	///	inactive_shields.Add(S)
	//	S.damage_taken = 0
	//	S.density = 0
		//S.icon_state = "shieldwalloff"
	else
		S.health -= damage
	return 1


/obj/machinery/space_battle/shield_generator/process()
	flux_rate = flux*100
	regen = (flux*flux_rate)
	var/obj/effect/adv_shield/S = pick(shields)
	S.regen = regen
	S.calculate()
	world << "calculating:"
	world << "regen rate[regen]"
	world << "maxhealth: [S.maxhealth]"
	world << "health: [S.health]"
	world << "________________"


/obj/effect/landmark/shield
	name = "shield marker"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldwall"

/obj/effect/adv_shield
	name = "Flux Shield"
	desc = "A rapid flux field, you feel like touching it would end very badly."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldwalloff"
	density = 0
	anchored = 1
	var/obj/machinery/space_battle/shield_generator/generator
	var/health = 1050 //charge them up
	var/maxhealth = 20000
	var/in_dir = 2
	var/list/friendly = list() //friendly phasers that are linked, have this change ON DISMANTLE ok?
	var/regen = 0 //inherited from generator

/obj/effect/adv_shield/CanAtmosPass(turf/T)
	if(density)
		return 0
	else
		return 1

/obj/effect/adv_shield/New()
	. = ..()
	var/area/thearea = get_area(src)
	for(var/obj/machinery/power/ship/phaser/P in thearea)
		if(!P in thearea)
			return
		for(var/obj/item/weapon/gun/shipweapon/W in P.contents)
			if(!istype(W))
				return
			friendly += W //link a phaser in, these phasers can through shields
//	START_PROCESSING(SSobj, src)

/obj/effect/adv_shield/proc/activate()
	icon_state = "shieldwall"
	density = 1
	START_PROCESSING(SSobj,src)

/obj/effect/adv_shield/proc/deactivate(num)
	icon_state = "shieldwalloff"
	density = 0
	if(src in generator.active_shields)
		generator.active_shields.Remove(src)
		generator.inactive_shields.Add(src)
	if(num == 1) //safely powered down from shieldgen
		STOP_PROCESSING(SSobj,src)
	else
		return

/obj/effect/adv_shield/proc/calculate()
	for(var/obj/effect/adv_shield/S in generator.shields)
		S.health += regen
		if(S.health > maxhealth)
			S.health = maxhealth

/obj/effect/adv_shield/process()
	if(!density) //in otherwords, not active
		if(health <= 1000) //once they go down, they must charge back up a bit
			health += 50 //slowly recharge
		else
			activate()
	if(health < maxhealth)
		calculate()
	//	health += regen
	else
		return
	if(health <= 0)
		health = 0
		return deactivate()
//	calculate()

/obj/effect/adv_shield/proc/percentage(damage)
	var/counter
	var/percent = health
//	for(var/obj/effect/adv_shield/S in generator.shields)
//		percent += S.health
//		maxhealth += maxhealth
	counter = maxhealth
	percent = percent/counter
	percent = percent*100
	generator.say("Shields are buckling, absorbed: [damage]: Shields at [percent]%")
	playsound(src.loc, 'sound/borg/machines/bleep2.ogg', 100,1)
	return

/obj/effect/adv_shield/ex_act(severity)
	var/damage = 300*severity
	percentage(damage)
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	take_damage(damage)

/obj/effect/adv_shield/bullet_act(obj/item/projectile/P)
	. = ..()
	take_damage(P.damage)
	/*
	for(var/obj/effect/adv_shield/S in generator.shields)
		S.health -= P.damage //tank all shields
	percentage(P.damage)
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, src)
	s.start()
	return 1
	*/
//obj/effect/adv_shield/attackby(/obj/item/weapon/I)
//	. = ..()
//	var/obj/item/weapon/A = I
//	take_damage(A.force)

/obj/effect/adv_shield/proc/take_damage(amount)
//	if(!CanPass(mover))
//		return
	if(amount > 0)
		if(density)
			for(var/obj/effect/adv_shield/S in generator.shields)
				S.health -= amount //tank all shields
			percentage(amount)
			var/datum/effect_system/spark_spread/s = new
			s.set_up(2, 1, src)
			s.start()
			playsound(src.loc, 'sound/borg/machines/shieldhit.ogg', 100,1)
			return 1
		else
			return 0
	else
		return 0

/obj/effect/adv_shield/proc/pass_check(atom/movable/mover)
	if(mover in friendly)
		return 1
	else
		return 0

//obj/effect/adv_shield/Bump(atom/A) // Gets flung out.
//	if(pass_check(A))
//		continue
//	else
	//	return
//obj/effect/adv_shield/CanPass(atom/movable/mover, turf/target, height=0) // Shields are one-way: Shit can leave, but shit can't enter
//	if(density)
//		if(istype(loc, /turf/open/space/transit))
//			return 0
	//	if(get_dir(src, target) == in_dir)
	//		return 1
	//	return 0
//	else
	//	return 1


#undef PHYSICAL

//guns
//current_beam = new(user,current_target,time=6000,beam_icon_state="medbeam",btype=/obj/effect/ebeam/medical)




/obj/item/weapon/gun/shipweapon //guns go inside ship mounting things, like turrets
	name = "inner phaser array"
	desc = "I wouldn't stand in front of this if I were you..."
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	item_state = "chronogun"
	w_class = 3.0

	var/atom/current_target
	var/last_check = 0
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	var/max_range = 1000 //it's a ship gun after all
	var/active = 0
	var/datum/beam/current_beam = null
	var/mounted = 1 //Denotes if this is a handheld or mounted version
	var/damage = 1500
	var/cooldown = 20 //2 second beam duration
	var/saved_time = 0
	weapon_weight = WEAPON_MEDIUM
	var/list/fire_sounds = list('sound/borg/machines/phaser.ogg','sound/borg/machines/phaser2.ogg','sound/borg/machines/phaser3.ogg')

/obj/item/weapon/gun/shipweapon/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/gun/shipweapon/proc/losetarget()
	..()
	LoseTarget()


/obj/item/weapon/gun/shipweapon/attack_self(mob/user)
	user <<"<span class='notice'>You disable the beam.</span>"
	LoseTarget()

/obj/item/weapon/gun/shipweapon/proc/LoseTarget()
	if(active)
		qdel(current_beam)
		active = 0
		on_beam_release(current_target)
	current_target = null

/obj/item/weapon/gun/shipweapon/process_fire(atom/target as mob|obj|turf, atom/source as mob|obj, message = 0, params, zone_override)
	var/sound = pick(fire_sounds)
	playsound(src.loc, sound, 200,1)
	if(isliving(source))
		var/mob/living/L = source
		add_fingerprint(L)
	if(current_target)
		LoseTarget()
	current_target = target
	active = 1
	current_beam = new(source,current_target,time=6000,beam_icon_state="phaserbeam",maxdistance=5000,btype=/obj/effect/ebeam/phaser)
	spawn(0)
		current_beam.Start()

	//feedback_add_details("gun_fired","[src.type]")

/obj/item/weapon/gun/shipweapon/process()
	var/source = loc
	if(!mounted && !isliving(source))
		LoseTarget()
		return

	if(!current_target)
		LoseTarget()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

	if(get_dist(source, current_target)>max_range || !los_check(source, current_target))
		LoseTarget()
		if(ishuman(source))
			source << "<span class='warning'>You lose control of the beam!</span>"
		return
	if(current_target)
		on_beam_tick(current_target)
	if(world.time >= saved_time + cooldown)
		LoseTarget()
		saved_time = 0
		return

/obj/item/weapon/gun/shipweapon/proc/los_check(atom/movable/user, atom/target)
	var/turf/user_turf = user.loc
	if(mounted)
		user_turf = get_turf(user)
	else if(!istype(user_turf))
		return 0
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE //Grille/Glass so it can be used through common windows
	for(var/turf/turf in getline(user_turf,target))
		if(mounted && turf == user_turf)
			continue //Mechs are dense and thus fail the check
		for(var/atom/movable/AM in turf)
			if(!ismob(AM) && !isturf(AM))
				if(istype(AM, /obj/effect/adv_shield))
					var/obj/effect/adv_shield/S = AM
					if(S.pass_check(src)) ///pass check being it's ALLOWED to go through
						continue
					else //not a friendly bullet, no go thru!
						S.take_damage(damage)
						qdel(dummy) //oK so this called that's good!
						return 0
				if(!AM.CanPass(dummy,turf,1))
				//	explosion(AM.loc,1,1,1,2)
					qdel(dummy)
					AM.ex_act(1)
					return 0
			if(ismob(AM))
				var/mob/living/C = AM
				C.adjustBruteLoss(damage) //AAAAAA FUCK OUCH AAAA
				C.adjustFireLoss(damage)
				qdel(dummy)
				return 0
			else
				if(!AM.CanPass(dummy,turf,1))
					qdel(dummy)
					return 0
		if(turf.density)
			qdel(dummy)
			return 0
		for(var/obj/effect/ebeam/phaser/B in turf)// Don't cross the str-beams!
			if(B.owner != current_beam)
				explosion(B.loc,0,3,5,8)
				qdel(dummy)
				return 0
	qdel(dummy)
	return 1
/obj/item/weapon/gun/shipweapon/proc/on_beam_hit(var/atom/target)
	saved_time = world.time
	return


/obj/item/weapon/gun/shipweapon/proc/on_beam_tick(var/atom/target)
	//PoolOrNew(/obj/effect/overlay/temp/heal, list(get_turf(target), "#80F5FF"))
//	if(istype(target, /obj/effect/adv_shield))
	//	world << "it's a shield lol"
//		var/obj/effect/adv_shield/S = target
//		S.take_damage(damage)
	//	return
	if(isliving(target))
		var/mob/living/C = target
		C.adjustBruteLoss(damage) //AAAAAA FUCK OUCH AAAA
		C.adjustFireLoss(damage)
		return

/obj/item/weapon/gun/shipweapon/proc/on_beam_release(var/atom/target)
	return

/obj/effect/ebeam/phaser
	name = "high density photon beam"
//	max_distance = "5000"


/obj/item/weapon/circuitboard/machine/phase_cannon
	name = "phaser array circuit board"
	build_path = /obj/machinery/borg/ftl
	origin_tech = "programming=10;engineering=8"
	req_components = list(
							/obj/item/weapon/stock_parts/borg/bin = 2,
							/obj/item/weapon/stock_parts/borg/capacitor = 2)

	//cCREDIT : FTLSTATION ok butchered beyond belief, no credit for you
/obj/machinery/power/ship/phaser
	name = "phaser array"
	desc = "A powerful weapon designed to take down shields.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon = 'icons/obj/96x96.dmi'
	icon_state = "phaserarray"
	anchored = 1
	dir = 4
	density = 0
	pixel_x = -64
	var/charge = 10000 //current power levels
	var/charge_rate = 30000
	var/state = 1
	var/locked = 0
	var/obj/item/weapon/gun/shipweapon/phaser
	var/obj/structure/cable/attached		// the attached cable
	var/max_power = 1000		// max power it can hold
	var/fire_cost = 100
	var/percentage = 0 //percent charged
	var/list/shipareas = list()
	var/target = null

/obj/machinery/power/ship/phaser/opposite
	dir = 8
	pixel_x = 64

//obj/machinery/power/ship/phaser/attack_hand(mob/user)
//	user << "input now"
//	input_target(user)

/obj/machinery/power/ship/phaser/proc/input_target(mob/user) //unused now
	var/A
	A = input("Area to fire on", "Open Fire", A) as anything in shipareas
	var/area/thearea = shipareas[A]
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T
	var/location = pick(L)
	attempt_fire(location)

//	explosion(loc,2,5,11)

/*
	var/obj/ship_marker/A = shipcores[B]
	var/area/thearea = get_area(A)
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T
	var/loc = pick(L)
*/


/obj/machinery/power/ship/phaser/examine(mob/user)
	. = ..()
	percentage = (charge / max_power) * 100
	user << "it is [percentage]% full"

/obj/machinery/power/ship/phaser/process()
	if(!attached)
	//	state = 0
		return
	var/datum/powernet/PN = attached.powernet
	if(PN)
		SetLuminosity(5)
		// found a powernet, so drain up to max power from it
		percentage = (charge / max_power) * 100
		var/drained = min ( charge_rate, PN.avail )
		PN.load += drained
		charge += drained
		if(drained < charge_rate)
			for(var/obj/machinery/power/terminal/T in PN.nodes)
				if(istype(T.master, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/A = T.master
					if(A.operating && A.cell)
						A.cell.charge = max(0, A.cell.charge - 50)
						charge += 50
						if(A.charging == 2) // If the cell was full
							A.charging = 1 // It's no longer full

/obj/machinery/power/ship/phaser/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new /obj/item/weapon/circuitboard/machine/phase_cannon(null)
	B.apply_default_parts(src)
	RefreshParts()
	phaser = new /obj/item/weapon/gun/shipweapon(src)
	phaser.mounted = 1
	find_cores()

/obj/machinery/power/ship/phaser/proc/find_cores()
	var/area/thearea = get_area(src)
	for(var/area/AR in world)
		if(istype(AR, /area/ship)) //change me
			shipareas += AR.name
			shipareas[AR.name] = AR
	if(shipareas.len)
		src.say("Target located")
	else
		src.say("No warp signatures detected")
	for(var/obj/structure/fluff/helm/desk/tactical/T in thearea)
		if(T.z == src.z)
			if(!src in T.weapons)
				T.weapons += src

/obj/machinery/power/ship/phaser/proc/can_fire()
	if(state == 1)
		if(charge >= 200)
			return 1
		else
			return 0
	else
		return 0

/obj/machinery/power/ship/phaser/proc/attempt_fire(atom/target) //TEST remove /atom if no work
	if(can_fire())
		charge -= fire_cost
		phaser.losetarget()
		phaser.current_target = target
		phaser.process_fire(target = target,  source = src)
		var/obj/item/projectile/bullet/phasepulse/A = PoolOrNew(/obj/item/projectile/bullet/phasepulse,src.loc)
		world << A
	//ar/dir = get_dir(get_turf(src), get_turf(target))
	//.dir = dir
		A.source = phaser
		A.target = target
		A.starting = loc
		var/targloc = get_turf(target)
		A.preparePixelProjectile(target,targloc,src)
		A.fire()
	else
		src.say("error")
		return 0

/obj/item/projectile/bullet/phasepulse
	name ="phaser pulse"
	icon_state= "bolter"
	desc = "I wouldn't stand in front of this if I were you.."
	damage = 50
	alpha = 0
	var/source = null
	var/target = null

/obj/item/projectile/bullet/phasepulse/on_hit(atom/target, blocked = 0)
	if(istype(target, /obj/effect/adv_shield))
		var/obj/effect/adv_shield/S = target
		if(source in S.friendly)
			damage = 0
			var/obj/item/projectile/bullet/phasepulse/A = PoolOrNew(/obj/item/projectile/bullet/phasepulse,S.loc)
			A.source = source
			A.starting = S.loc
			A.fire(target,src)
			qdel(src)
			return 0
		if(S.density)
			damage = 0
		else
			return 0
	else
		explosion(target, 1, 3, 2)
		..()
		return 1
/obj/item/projectile/bullet/phasepulse/Destroy()
	. = ..()
	for(var/obj/effect/adv_shield/P in src.z)
		if(src in P.friendly)
			P.friendly -= src

//DEFINE TARGET

/area/ship
	name = "USS Cadaver"
	icon_state = "ship"
	requires_power = 0 //fix
	has_gravity = 1
	noteleport = 0
	blob_allowed = 0 //Should go without saying, no blobs should take over centcom as a win condition.
	sound_env = LARGE_ENCLOSED

/area/ship/bridge
	name = "A starship bridge"
	icon_state = "ship"

/area/ship/engineering
	name = "A starship engineering"
	icon_state = "ship"



/area/ship/target
	name = "USS adminbus"
	icon_state = "ship"




/obj/ship_marker
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/obj/device.dmi'
	//icon = 'icons/dirsquare.dmi'
	icon_state = "pinonfar"
	name = "ship core"
	unacidable = 1
	anchored = 1

/obj/ship_marker/bridge
	name = "bridge"

/obj/ship_marker/crew
	name = "crew quaters"


/obj/structure/fluff/helm/desk
	name = "desk computer"
	desc = "A generic deskbuilt computer"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "desk"
	anchored = TRUE
	density = 1 //SKREE
	opacity = 0
	layer = 4.5

/obj/structure/fluff/helm/desk/tactical
	name = "tactical"
	desc = "A computer built into a desk, showing ship manifests, weapons, tactical systems, anything you could want really, the manifest shows a long list but the 4961 irradiated haggis listing catches your eye..."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "desk"
	anchored = TRUE
	density = 1 //SKREE
	opacity = 0
	layer = 4.5
	var/list/weapons = list()
	var/list/redalertsounds = list('sound/borg/machines/redalert.ogg','sound/borg/machines/redalert2.ogg')
	var/target = null
	var/cooldown2 = 190 //18.5 second cooldown
	var/saved_time = 0
	var/list/shipareas = list()
	var/obj/machinery/space_battle/shield_generator/shieldgen
	var/REDALERT = 0
	var/redalertsound

/obj/structure/fluff/helm/desk/tactical/process()
	var/area/thearea = get_area(src)
	if(world.time >= saved_time + cooldown2)
		saved_time = world.time
		for(var/mob/M in thearea)
			M << redalertsound

/obj/structure/fluff/helm/desk/tactical/New()
	. = ..()
	get_weapons()
	var/area/thearea = get_area(src)
	for(var/area/AR in world)
		if(istype(AR, /area/ship)) //change me
			shipareas += AR.name
			shipareas[AR.name] = AR
	for(var/obj/machinery/space_battle/shield_generator/S in thearea)
		shieldgen = S
		S.controller = src

/obj/structure/fluff/helm/desk/tactical/proc/get_weapons()
	weapons = list()
	var/area/thearea = get_area(src)
	for(var/obj/machinery/power/ship/phaser/P in thearea)
		if(P.z == src.z)
			weapons += P


/obj/structure/fluff/helm/desk/tactical/attack_hand(mob/user)
	get_weapons()
	for(var/area/AR in world)
		if(istype(AR, /area/ship)) //change me
			if(!AR in shipareas)
				shipareas += AR.name
				shipareas[AR.name] = AR
	var/mode = input("Tactical console.", "Do what?")in list("choose target", "fire phasers", "shield control", "red alert siren")
	switch(mode)
		if("choose target")
			var/A
			A = input("Area to fire on", "Tactical Control", A) as anything in shipareas
			var/area/thearea = shipareas[A]
			var/list/L = list()
			for(var/turf/T in get_area_turfs(thearea.type))
				L+=T
			var/location = pick(L)
			target = location
			for(var/obj/machinery/power/ship/phaser/P in weapons)
				P.target = location
		if("fire phasers")
			playsound(src.loc, 'sound/borg/machines/bleep1.ogg', 100,1)
			var/area/thearea = get_area(target)
			var/list/L = list()
			for(var/turf/T in get_area_turfs(thearea.type))
				L+=T
			var/location = pick(L)
			target = location
			for(var/obj/machinery/power/ship/phaser/P in weapons)
				P.target = location
			if(target != null)
				for(var/obj/machinery/power/ship/phaser/P in weapons)
					P.attempt_fire(target)
			else
				user << "ERROR, no target selected"
		if("shield control")
			shieldgen.toggle(user)
		if("red alert siren")
			redalertsound = pick(redalertsounds)
			if(REDALERT)
				src.say("RED ALERT DEACTIVATED")
				REDALERT = 0
				STOP_PROCESSING(SSobj,src)
			else
				src.say("RED ALERT ACTIVATED")
				REDALERT = 1
				START_PROCESSING(SSobj,src)

//Par made some sick bridge sprites, nut on them and think of Par not me whilst you do

/obj/structure/fluff/ship
	name = "wall panel"
	desc = "a wall mounted screen"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "conduit"
	layer = 4.5
	anchored = 1
	density = 0
	can_be_unanchored = 0

/obj/structure/fluff/ship/panel
	name = "wall panel"
	desc = "a wall mounted screen"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "panel_both"
	layer = 4.5

/obj/structure/fluff/ship/panel/blank
	name = "wall panel"
	desc = "a wall mounted screen"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "panel_blank"

/obj/structure/fluff/ship/panel/frame
	name = "wall panel"
	desc = "a wall mounted screen"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "panel_frame"

/obj/structure/fluff/ship/panel/drawer
	name = "drawers"
	desc = "what could they contain?"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "drawer_two"

/obj/structure/fluff/ship/panel/drawer/single
	name = "drawer"
	desc = "what could it contain?"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "drawer"

/obj/structure/fluff/ship/sticker
	name = "red sticker"
	desc = "It reads: do not feed the clown"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "sticker_red"

/obj/structure/fluff/ship/panel/red
	name = "red panel"
	desc = "it hums lightly..."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "strip_both"

/obj/structure/fluff/ship/panel/type1
	name = "panel"
	desc = "it hums lightly..."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "panel_1"

/obj/structure/fluff/ship/panel/type2
	name = "panel"
	desc = "it hums lightly..."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "panel_2"

/obj/structure/fluff/ship/panel/type3
	name = "panel"
	desc = "it hums lightly..."
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "panelwall"

/obj/structure/fluff/ship/attackby(mob/user)
	return 0
/obj/structure/fluff/ship/ex_act(severity)
	return 0


/turf/closed/wall/ship
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "middle"

/turf/closed/wall/ship/light
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "lightleft"

/turf/closed/wall/ship/light/m
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "lightmiddle"

/turf/closed/wall/ship/light/c2
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "lightright"

/turf/closed/wall/ship/flat
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "middleflat"

/turf/closed/wall/ship/flat/c1
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "leftflatcorner"

/turf/closed/wall/ship/flat/m
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "middleflat"

/turf/closed/wall/ship/flat/c2
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "rightflatcorner"

/turf/closed/wall/ship/light/New()
	. = ..()
	SetLuminosity(1)

/turf/closed/wall/ship/c1
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "leftcorner"

/turf/closed/wall/ship/m
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "middlecorner"

/turf/closed/wall/ship/c2
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "rightcorner"


/turf/closed/wall/ship/horiz
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "horizsmooth"


/turf/closed/wall/ship/light/horiz
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "lightleftup"

/turf/closed/wall/ship/light/horiz2
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "lightmiddleup"

/turf/closed/wall/ship/light/horiz3
	name = "hull"
	desc = "it makes you feel like you're on a starship"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "lightrightup"

