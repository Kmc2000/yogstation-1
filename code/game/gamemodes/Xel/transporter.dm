
/obj/machinery/computer/transporter_control
	name = "transporter control station"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "helm"
	dir = 4
	icon_keyboard = null
	icon_screen = null
	layer = 4.5
	var/list/retrievable = list()
	var/list/linked = list()

/obj/machinery/computer/transporter_control/New()
	. = ..()
	link_to()


/obj/machinery/computer/transporter_control/proc/link_to()
	var/thearea = get_area(src)
	for(var/obj/structure/trek/transporter/T in thearea)
		world << "linked a transporter"
		linked += T

/obj/machinery/computer/transporter_control/proc/activate_pads()
	for(var/obj/structure/trek/transporter/T in linked)
		T.icon_state = "transporter_on"
		T.get_things_on_pad()
		if(things_on_pad.len)
			for(var/atom/movable/M in things_on_pad)
						//	anim(meme.loc,meme,'icons/obj/machines/borg_decor.dmi',"transportout")
				M.alpha = 0
				M.forceMove(pick(L))
				T.animate(M)
				retrievable += M
				M.things_on_telepad -= M
			else
				T.icon_state = "transporter" //catch

/obj/machinery/computer/transporter_control/attack_hand(mob/user)
	var/A
	var/B
	B = input(user, "Mode:","Transporter Control",B) in list("send object","receieve away team member", "cancel")
	switch(B)
		if("send object")
			A = input(user, "Target", "Transporter Control", A) as null|anything in teleportlocs
			var/area/thearea = teleportlocs[A]
			if(!thearea)
				return
			playsound(src.loc, 'sound/borg/machines/transporter.ogg', 40, 4)
			var/list/L = list()
			for(var/turf/T in get_area_turfs(thearea.type))
				if(!T.density)
					var/clear = 1
					for(var/obj/O in T)
						if(O.density)
							clear = 0
							break
					if(clear)
						L+=T
			if(!L || !L.len)
				usr << "No area available."
			//end area select
			activate_pads()
			//	else
			//		T.icon_state = "transporter" //erroroneus meme!
				//	playsound(src.loc, 'sound/borg/machines/alert2.ogg', 40, 4)
				//	user << "Transport pattern buffer initialization failure."
				//meme = null
		if("receieve away team member")
			var/C = input(user, "Beam someone back", "Transporter Control") as anything in retrievable
			if(!C in retrievable)
				return
			var/atom/movable/target = C
			playsound(src.loc, 'sound/borg/machines/transporter.ogg', 40, 4)
			retrievable -= target
			for(var/obj/structure/trek/transporter/T in linked)
				var/obj/structure/trek/transporter/Z = pick(linked)
				target.forceMove(Z.loc)
				Z.rematerialize(target)
				anim(Z.loc,Z,'icons/obj/machines/borg_decor.dmi',,"transportin")
			//	Z.alpha = 255
				break
		if("cancel")
			return
/obj/machinery/computer/transporter_control/attackby()
	return 0


/obj/structure/trek/transporter
	name = "transporter pad"
	density = 0
	anchored = 1
	can_be_unanchored = 0
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "transporter"
	var/target_loc = list() //copied
	var/Target
	var/list/linked = list()
	var/list/things_on_telepad = list()

/obj/structure/trek/transporter/attackby(mob/user)
	return 0

//obj/structure/trek/transporter/proc/get_target()

/obj/structure/trek/transporter/proc/energize()	 //atom/movable
	Target = null
	icon_state = "transporter_on"
	var/turf/source = get_turf(src)
	for(var/atom/movable/M in source)
		if(M != src)
			Target = M
			if(ismob(M))
				var/mob/living/L = M
				L.Stun(3)
			M.dir = 1
			anim(ONPAD.loc,M,'icons/obj/machines/borg_decor.dmi',"transportout")
		//	REE.alpha = 0
			icon_state = "transporter"


/obj/structure/trek/transporter/proc/get_things_on_pad()
	var/list/things_on_telepad = list()
	for(var/atom/movable/M in get_turf(src))
		if(M != src)
			return things_on_telepad