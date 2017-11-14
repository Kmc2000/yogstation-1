
/obj/machinery/computer/transporter_control
	name = "transporter control station"
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "helm"
	dir = 4
	icon_keyboard = null
	icon_screen = null
	layer = 4.5
	var/list/retrieveable = list()
	var/list/linked = list()
	var/list/tricorders = list()

/obj/machinery/computer/transporter_control/New()
	. = ..()
	link_to()

/obj/machinery/computer/transporter_control/proc/link_to()
	for(var/obj/structure/trek/transporter/T in get_area(src))
		world << "linked a transporter"
		src.linked += T
		T.transporter_controller = src

/obj/machinery/computer/transporter_control/proc/activate_pads(available_turfs)
	for(var/obj/structure/trek/transporter/T in linked)
		T.teleport_all(available_turfs)

/obj/machinery/computer/transporter_control/proc/get_available_turfs(var/area/A)
	if(!A)
		return
	var/list/available_turfs = list()
	for(var/turf/T in get_area_turfs(A.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				available_turfs += T


/obj/machinery/computer/transporter_control/attack_hand(mob/user)
	var/A
	var/B
	B = input(user, "Mode:","Transporter Control",B) in list("send object","receieve away team member", "cancel")
	switch(B)
		if("send object")
			A = input(user, "Target", "Transporter Control", A) as null|anything in teleportlocs
			playsound(src.loc, 'sound/borg/machines/transporter.ogg', 40, 4)
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
		//	var/list/available_turfs = get_available_turfs(teleportlocs[A])
		//	if(!available_turfs || !available_turfs.len)
		//		usr << "No area available."
			else
				activate_pads(L)

                        //                T.icon_state = "transporter" //erroroneus meme!
                                //        playsound(src.loc, 'sound/borg/machines/alert2.ogg', 40, 4)
                                //        user << "Transport pattern buffer initialization failure."
		if("receieve away team member")
			var/C = input(user, "Beam someone back", "Transporter Control") as anything in retrieveable
		//	if(!C in retrievable)
		//		return
			var/atom/movable/target = C
			playsound(src.loc, 'sound/borg/machines/transporter.ogg', 40, 4)
			retrieveable -= target
			for(var/obj/structure/trek/transporter/T in linked)
				anim(target.loc,target,'icons/obj/machines/borg_decor.dmi',"transportout")
				playsound(target.loc, 'sound/borg/machines/transporter2.ogg', 40, 4)
				playsound(src.loc, 'sound/borg/machines/transporter.ogg', 40, 4)
				var/obj/structure/trek/transporter/Z = pick(linked)
				target.forceMove(Z.loc)
				target.alpha = 255
			//	Z.rematerialize(target)
				anim(Z.loc,Z,'icons/obj/machines/borg_decor.dmi',"transportin")
                        //        Z.alpha = 255
				break
		if("cancel")
			return

/obj/machinery/computer/transporter_control/attackby(obj/I, mob/user)
	if(istype(I, /obj/item/device/tricorder))
		if(!I in tricorders)
			var/obj/item/device/tricorder/S = I
			S.transporter_controller = src
			tricorders += I
			user << "Successfully linked [I] to [src], you may now tag items for transportation"
		else
			user << "[I] is already linked to [src]!"
	else
		return 0


/obj/structure/trek/transporter
	name = "transporter pad"
	density = 0
	anchored = 1
	can_be_unanchored = 0
	icon = 'icons/obj/machines/borg_decor.dmi'
	icon_state = "transporter"
	var/target_loc = list() //copied
	var/obj/machinery/computer/transporter_control/transporter_controller = null

/obj/structure/trek/transporter/proc/teleport(var/atom/movable/M, available_turfs)
	anim(M.loc,M,'icons/obj/machines/borg_decor.dmi',"transportout")
	M.dir = 1
	if(!M in transporter_controller.retrieveable)
		transporter_controller.retrieveable += M
	M.alpha = 0
	M.forceMove(pick(available_turfs))
//	animate(M)
	if(ismob(M))
		var/mob/living/L = M
		L.Stun(3)
		anim(M.loc , M,'icons/obj/machines/borg_decor.dmi',"transportin")
	icon_state = "transporter"

/obj/structure/trek/transporter/proc/teleport_all(available_turfs)
	icon_state = "transporter_on"
	for(var/atom/movable/M in get_turf(src))
		if(M != src)
		//	anim(M.loc,'icons/obj/machines/borg_decor.dmi',"transportin")
			teleport(M, available_turfs)
			rematerialize(M)
	icon_state = "transporter"


/obj/structure/trek/transporter/proc/rematerialize(var/atom/movable/thing)
//	var/atom/movable/target = Target
	icon_state = "transporter_on"
	thing.alpha = 255
	playsound(thing.loc, 'sound/borg/machines/transporter2.ogg', 40, 4)
	icon_state = "transporter"