/obj/machinery/reactor
	name = "reactor vessel"
	desc = "The reactor vessel"
	icon = 'icons/obj/reactor.dmi' //change as needed
	icon_state = "reactor-o"
	var/status = 0 //starts open //what the fuck you fucking fuckwit why was it "0" you absolute retard - modern KMC
	anchored = 1
	can_be_unanchored = 0
	density = 1
	var/Fuel1Num = 0 //how much uranium is in the reactor
	var/Heat = 0 //current temperature
	var/HeatRate = 0 //rate of heat adding
	var/Rod1Num = 0 //how many control rods are in?
	var/HeatInc = 1 //adding fuel makes it heat up more, can't have 0 or it will never heat up
	var/reacted = 0 //stop react() spam
	var/heat_effect = 0 //how much of an effect the rods have on heat
	var/running = 0 //doesnt start running, but is the reactor active?
	var/maxrods = 0 //we're gonna inherit this from each rod, but it needs to be defined
	var/depleted_effect = 0 //the fuel will say how much the depleted version affects the heat loss
	var/heat_deceffect = 0 //amount that will be subtracted from decayed fuel and control rods
	var/HeatDec = 0.01 //heat decay currently, setting to above 0
	var/Fuel1Rate = 0.05 //heatrate from fuel 1
	var/Fuel1Decay = 0.5//decay rate of uranium
	var/Rod1Rate = -0.1 //heat effect of standard rod
	var/DUNum = 0 //decayed fuekl amiunt





/obj/machinery/power/reactorturbine
	name = "steam turbine"
	desc = "A large turbine that runs with steam. Great when coupled with a nuclear reactor"
	icon = 'icons/obj/reactor.dmi' //change as needed
	icon_state = "turbine"

/obj/machinery/power/reactorturbine/process() //we need to figure out how we're adding power with the turbines
	add_avail(1) //add power to powernet, arbitrary for now

	//status list:
//Stat 0 is open, and off
//Stat 1 is closed, and off
//Stat 2 is closed and running

//Decayed uranium fuel slows the reaction

//Heat increase is basically heat_effect, it is the net total of the +heat from fuel and -heat from rods.


/obj/item/controlrod
	name = "control rod"
	desc = "A thick carbon rod, used to slow down reactions in a nuclear reactor"
	icon = 'icons/obj/reactor.dmi'
	icon_state = "rod"
	var/heat_effect = -0.1 //effect on heat, this will be subtracted every second
	var/maxrods = 10 //max amount of RODS you can insert into the reactor

/obj/item/controlrod/babysfirst
	name = "baby's first control rod"
	desc = "I got a grade C in math -Kmc"
	heat_effect = 1
	maxrods = 10


/obj/item/stack/sheet/mineral/uranium/babysfirst
	name = "baby's first uranium"
	desc = "I need big round numbers - Kmc"
	heat_effect = 1
	depleted_effect = 1

//temporary code, REEE


/obj/machinery/reactor/proc/reset()
	DUNum = 0
	Fuel1Num = 0
	Heat = 0
	HeatRate = 0
	HeatDec = 0
	HeatInc = 0
	src.say("Removed depleted fuel and fuel")





/obj/machinery/reactor/attackby(obj/item/I, mob/user, params)			//update: status is the problem cockblocking it. Investigate further
	if(istype(I, /obj/item/weapon/wrench))
		if(status == 0) //reactor open
			status = 1
			user << "<span class='notice'>You secure the external bolts on [src] and secure its lid.</span>"
			icon_state = "reactor"
		else if(status == 1) //reactor closed, but not on
			status = 0
			user << "<span class='notice'>You undo the external bolts on [src] and lift off the lid.</span>"
			icon_state = "reactor-o"

	else if(istype(I, /obj/item/stack/sheet/mineral/uranium))
		if(status == 0) //reactor open
			var/obj/item/stack/sheet/mineral/uranium/S = I
			Fuel1Rate = S.heat_effect*S.get_amount()
			user << "<span class='notice'>You insert the [I] into the [src], .</span>"
			Fuel1Num += S.get_amount()
			depleted_effect = (S.depleted_effect*S.get_amount())
			qdel(S)
			playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
			CheckHeatRate()

		else
			user << "<span class='notice'>Warning [src] is not open, you cannot add fuel.</span>"
			return

//RE add the max control rods later, testing for now
	else if(istype(I, /obj/item/controlrod)) //you can add rods at any state, but not if you hit the max number of rods
		var/obj/item/controlrod/C = I
		heat_deceffect += C.heat_effect
		user << "<span class='notice'>You insert the [I] into the [src], .</span>"
		qdel(I)
		Rod1Num += 1
		CheckHeatRate()

	else if(status == 2) //reactor is reacting
		user << "<span class='notice'>Warning [src] is operating, it must be shut-down before you can add more fuel or modify it! .</span>"
		return



//we WILL make it so you use a console, but for now, whack it to start it
/obj/machinery/reactor/attack_hand(mob/user)
	if(status == 1) //if status is 0 or one, it's not on
		status = 2
		running = 1 //start that sweet reaction baby
		icon_state = "reactor"
		src.say("Reaction started: WARNING.")
		Heat += 1

	else if(status == 2) //shut off the reaction, we'll simulate this later, for now it stops everything
		status = 1
		src.say("Reaction halted")
		icon_state = "reactor"

/obj/machinery/reactor/examine(mob/user)
	user << "[src] has [Rod1Num] control rods lowered, [Fuel1Num] bars of fuel left and is running at a temperature of [Heat]. [DUNum] bars of its fuel have decayed and are useless, heat is being increased at a rate of [HeatRate] "

/obj/machinery/reactor/proc/heatloss() //ok it's broken, temporary fix tm!
	if(Rod1Num > 0)
		Heat -= DUNum*Rod1Num*depleted_effect //depleted effect is the total effect of depletion, it should be under 1
	else if(Rod1Num == 0)
		Heat -= DUNum*depleted_effect

/obj/machinery/reactor/process()
	if(running)
		if(Heat + HeatRate <= 0) //If heat would reach 0 on this tick
			Heat = 0

			CheckHeatRate()
		else
			Heat += HeatRate //Changes heat by heatrate

			CheckHeatRate() //Adjusts interface based on heat

		if(Fuel1Num <= 0) //If reactor runs out of fuel
			src.say("The reactor ran out of fuel, it will now gradually lose heat.")
			heatloss()
			if(Heat + HeatRate <= 0)//If heat would reach 0 on this tick
				Heat = 0
				CheckHeatRate()
				running = 0
				src.say("The reactor ran out of heat and has turned off.")

		else if(Heat + HeatRate >= 100)//If heat would reach 100 this tick
			Heat = 0
			CheckHeatRate()
			Fuel1Num = 0 //Changes all fuel to DU
			DUNum = Fuel1Num
			CheckHeatRate()
			src.say("The reactor has overheated and exploded!")



		else //Otherwise, react normally for a tick
			Heat += HeatRate //'Changes heat by heatrate

			CheckHeatRate() //'Adjusts interface based on heat

      //      TotalFuelPast = TotalFuel 'Remembers how much fuel was present at the start of the tick
      //      DUNumPast = DUNum 'Remembers how much DU was present at the start of the tick

			if(Fuel1Num == 0) //If this fuel type is empty, do nothing
				return

			else if(Fuel1Num - Fuel1Decay <= 0)  //'Otherwise, if this fuel type would go to or below 0 this tick
				DUNum += Fuel1Num //Adds amount that is left to DU
				Fuel1Num = 0 //Then sets the fuel to 0

			else//'Otherwise
				Fuel1Num -= Fuel1Decay// 'Reduces fuel by its decay amount
				DUNum += Fuel1Decay //'//--Increases DU by that same amount

			CheckHeatRate() //'And heat rate

            //'And that's one tick of the reactor!



/obj/machinery/reactor/proc/CheckHeatRate()//'Called by other functions. Checks what the current heatrate should be and updates it. Call this every time you change fuel or rods
	HeatInc = (Fuel1Num * Fuel1Rate)// + (Fuel2Num * Fuel2Rate) + (Fuel3Num * Fuel3Rate) + (Fuel4Num * Fuel4Rate) + (Rod5Num * Rod5Rate) 'Sums up all positive effects


	HeatDec = (Rod1Num * Rod1Rate)// + (Rod2Num * Rod2Rate) + (Rod3Num * Rod3Rate) + (Rod4Num * Rod4Rate) + (DUNum * DURate) + Drain 'Sums up all negative effects


	HeatRate = HeatInc + HeatDec //'Sets HeatRate
