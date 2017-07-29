/mob/living/simple_animal/hostile/lag_witch
	name = "Lag witch"
	desc = "A witch the uses a switch to make you lag. Kill as soon as possible"
	health = 100
	var/id = 0 //id, to kill the lagspawns with
	icon = 'icons/mob/animal.dmi'
	icon_state = "lagwitch"
	var/allowed = 0 //start at 0 so it doenst instantly lag the server upon spawning
	gold_core_spawnable = 0


/mob/living/simple_animal/cockroach/lagspawn //spam these invisible horrors so you can barely move, and it'll spam the shit out of everything and lag to shit
	name = "lag spawn"
	desc = "oh no"
	icon = 'icons/mob/animal.dmi'
	alpha = 0
	var/id = 0

/mob/living/simple_animal/cockroach/lagspawn/New()
	for(var/mob/living/simple_animal/hostile/lag_witch/W)
		id = W.id


/mob/living/simple_animal/hostile/lag_witch/New()
	message_admins("Some greasy motherfucker spawned a lag witch , prepare for the server to DIE([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)you have 10 seconds to prevent this action by deleting it.")
	id = rand(1,100000000000000000000)
	sleep(100)
	allowed = 1

/mob/living/simple_animal/hostile/lag_witch/Life()
	if(allowed)
		x = rand(1,1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
		y = rand(1,9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000)
		x += y
		step_x = 33 //Lag the entire fucking server
		new /mob/living/simple_animal/cockroach/lagspawn(src.loc)
		for(var/mob/living/carbon/human/M in mob_list)
			shake_camera(M, 15, 1)
		src.say("REEEEEE!!!")


	if(!allowed)
		src.say("Get ready for freddy, it's lag city baby!!")


/mob/living/simple_animal/hostile/lag_witch/proc/prevent_lag()
	visible_message("<span class='name'>[src]</span> lets out a  high-pitched REEEEE as some of her horrible lag spells are undone..But not all.")
	for(var/mob/living/simple_animal/cockroach/lagspawn/W)
		if(W.id == id) //same ID, spawned by same witch
			qdel(W)
