/datum/miningpool
	var/name = "default pool"
	var/port = 3333
	var/complexity = 1.2 //1.2 being super easy, and then getting really hard and time consuming as the value of the coins go up.
	var/obj/structure/bitcoin_computer/members = list()
	var/coins_left_in_chain = 500 //Yeah this isn't how bitcoin works but it'll do for us! you chip away at these N coins, when they're all claimed, the chain gets harder to crack!
	var/datum/crypto_currency/currency_type

/datum/crypto_currency
	var/name = "KmCoin"
	var/value = "0.45" //0.45 credits per coin
	var/volatility_index = 0.1 //This affects how likely it is to rise in value, and fall. So you can mine for a nice safe coin
#define PSU 1
#define GPU 2
#define RAM 3
#define MOBO 4
#define CPU 5
#define LIQUID 6
#define FAN 7


/obj/structure/bitcoin_computer
	name = "Computrans multiplex computer."
	desc = "An old, extremely loud computer case, you can probably fit some basic parts in there."
	icon = 'icons/obj/bitcoin_mining.dmi'
	icon_state = "case_basic"
	var/hashrate = 0 //A computer case cannot crack bitcoins can it?
	var/operational = FALSE //It needs ALL the parts in there to work!
	var/TDP = 0 //Total amount of power drawn by all its components.
	var/obj/item/computer_component/power_supply/psu
//	var/obj/item/computer_component/graphics_card/gpus = list()
	var/obj/item/computer_component/graphics_card/gpu //FOR NOW NO MULTI GPUS, will add this later
	var/obj/item/computer_component/ram_stick/ram = list()
	var/obj/item/computer_component/motherboard/motherboard
	var/obj/item/computer_component/processor/cpu
	var/obj/item/computer_component/cooling/liquid_cooling/liquid_cooling
	var/obj/item/computer_component/cooling/fans = list()
	var/case_window_state = "case_basic"
	var/overall_cooling = 0 //Add up all the fans in the case etc.
	var/power_supplied = 0 //how good the PSU is
	var/ram_slots = 0 //How many ram slots? inherited from MOBO
	layer = 2.95
	var/list/current_overlays = list()
	var/ram_list = 0
	var/fans_list = 0
	var/fan_slots = 3 //Ok case, few fans. Bad cooling

/obj/structure/bitcoin_computer/proc/on_completion(var/upgrade_type)
	upgrade_type = "basic" //Change this! when you add advanced parts, call this with upgrade type of advanced or something.
	name = "Personal Computer"
	desc = "A [upgrade_type] personal computer, running a lin- GNU + LINUX based system, with a Linux kernal. You can use its computational power to crack complex algorithm to verify transactions based on the NanoCryptoNet, thus earning you your own CryptoCurrency coins. In other words it prints money"

/obj/structure/bitcoin_computer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/computer_component))
		var/obj/item/computer_component/C = I
		if(motherboard)
			switch(C.component_type)
				if(PSU)
					if(!psu)
						psu = C
						C.forceMove(src)
						var/obj/item/computer_component/power_supply/P = C //To get those specific vars
						power_supplied = P.power_supply
						C.our_system = src
						update_icons(C)
				if(GPU)
					if(!gpu)
						gpu = C
						C.forceMove(src)
						add_stats(C.hashrate_bonus, C.power_draw)
						C.our_system = src
						update_icons(C)
				if(RAM)
					if(ram_list < ram_slots)
						ram += C
						C.forceMove(src)
						add_stats(C.hashrate_bonus, C.power_draw)
						C.our_system = src
						update_icons(C)
				if(CPU)
					if(!cpu)
						cpu = C
						C.forceMove(src)
						add_stats(C.hashrate_bonus, C.power_draw)
						C.our_system = src
						update_icons(C)
				if(LIQUID)
					if(cpu)
						if(!liquid_cooling)
							liquid_cooling = C
							C.forceMove(src)
							var/obj/item/computer_component/cooling/liquid_cooling/F = C
							add_stats(C.power_draw,1,F.heat_reduction)
							F.our_system = src
							update_icons(C)
					else
						to_chat(user, "Install a cpu first!")
		else
			switch(C.component_type)
				if(MOBO)	//Mobo is the first thing to go in.
					if(!motherboard)
						motherboard = C
						C.forceMove(src)
						add_stats(C.hashrate_bonus, C.power_draw)
						C.our_system = src
						update_icons(C)
				if(FAN)
					if(fans_list < fan_slots)
						fans_list ++
						fans += C
						C.forceMove(src)
						var/obj/item/computer_component/cooling/F = C
						add_stats(C.power_draw,1,F.heat_reduction)
						F.our_system = src
						update_icons(C)
				else
					to_chat(user, "Install a motherboard first")

/obj/structure/bitcoin_computer/proc/add_stats(new_hashrate, new_power_draw, is_fan, fan_cooling_amount)
	hashrate += new_hashrate
	TDP += new_power_draw
	if(is_fan)
		overall_cooling += fan_cooling_amount
	return 1

/obj/structure/bitcoin_computer/proc/update_icons(obj/item/A, case_door)
	if(istype(A, /obj/item/computer_component))
		var/obj/item/computer_component/C = A
		C.forceMove(src)
		var/image/new_image = image(C.icon)
		new_image.layer = 3
		new_image.icon_state = C.part_state
	//	new_image.forceMove(src)
		new_image.name = C.component_type
		current_overlays += new_image //put it in a list that I can access for testing, overlays are horrid.
		overlays += new_image
	if(case_door)
		var/image/new_image =	image(icon)
		new_image.icon_state = case_window_state
		new_image.layer = 3.2

/obj/structure/bitcoin_computer/attack_hand(mob/user)
//	if(open)
//		to_chat(user, "You close [src]'s case.")
//		update_icons(null, 1)
//	else
//		to_chat(user, "You open up [src]")
//		update_icons
	return

/obj/item/computer_component
	name = "a computer part"
	icon = 'icons/obj/bitcoin_mining.dmi'
	var/hashrate_bonus = 10 //GPUs give better hashrates, but all parts carry a small bonus
	var/power_draw = 0
	var/temperature = 5 //Parts can heat up if you have inadequate cooling!
	var/heat_amplifier = 0.5 //How hot this thing gets, a good card will heat up REALLY quickly, a shit one will only need a tiny fan.
	var/obj/structure/bitcoin_computer/our_system //What system we are installed in
	var/warning_temperature = 60 //Working in degrees here, this is user defined, if things run too hot for too long, your parts may fry.
	var/active = FALSE //Are we turned on? if not, no point in getting hot is there?
	var/critical_temperature = 70 //70 degrees is pretty damn toasty, but not enough to murder it
	var/overclocked = FALSE
	var/overclock_heat_boost = 10 //A stock part that's overclocked will BURN UP IN A BALL OF FLAMES!
	var/reliability = 10 //How likely (%) it is to fail on a tick where its temperature is higher than safe limits.
	var/component_type = null
	var/part_state = null

/obj/item/computer_component/process()
	while(temperature > 0 && active)
		temperature += heat_amplifier
		temperature -= our_system.overall_cooling
		if(temperature >= critical_temperature)
			if(prob(reliability))
				fry()
		if(overclocked)
			temperature += overclock_heat_boost
		return
	STOP_PROCESSING(SSobj, src)

/obj/item/computer_component/proc/fry()
	return 0

/obj/item/computer_component/power_supply
	name = "KtTech 200W power supply"
	desc = "A very basic power supply, it can supply up to 200w of power!"
	icon_state = "powersupply_basic-component"
	var/power_supply = 200 //200 w
	heat_amplifier = 2 //This will heat up quite a bit without cooling
	component_type = PSU
	part_state = "powersupply_basic"

/obj/item/computer_component/graphics_card
	name = "Stallmantech HD graphics 4800"
	desc = "A graphics card with a tiny fan and a rudimentary 3d rendering of a female gaming character on its translucent blue cover."
	hashrate_bonus = 80 //ULTRA shit graphics card
	heat_amplifier = 1.5 //It's an extremely low powered GPU, the low hashrate means low heat output
	overclock_heat_boost = 20 //Don't....just don't...the fan can't take it!!!
	icon_state = "gpu_basic-component"
	component_type = GPU
	part_state = "gpu_basic"

/obj/item/computer_component/ram_stick
	name = "KtTech RAM++ module"
	desc = "A singular green stick of ram, the circuits are completely bare...I wouldn't overclock it if I were you."
	hashrate_bonus = 20 //Less of a bonus, more that you can't even boot a system with no RAM.
	heat_amplifier = 1.5 //It's an extremely low powered GPU, the low hashrate means low heat output
	overclock_heat_boost = 40 //YOU CAN OVERCLOCK RAM!??!?!? yeah not a good idea as it hasn't even got a heat spreader
	icon_state = "ram_basic-component"
	component_type = RAM
	part_state = "ram_basic"

/obj/item/computer_component/motherboard
	name = "Bios-Star UD1160 Rev 1.0 motherboard"
	desc = "A basic looking motherboard, if you had a computer as a kid, that motherboard was probably better than this."
	hashrate_bonus = 10 //Less of a bonus, more that you can't even boot a system with no MoBo
	heat_amplifier = 0.2 //Motherboards produce minimal heat by themselves
	overclock_heat_boost = 1 //>overclocking a motherboard...why not
	icon_state = "motherboard_basic-component"
	component_type = MOBO
	var/ram_slots = 2 //2 slots for ram
	part_state = "motherboard_basic"

/obj/item/computer_component/processor
	name = "Stallmantech Core 2 Mono"
	desc = "A single core CPU, it has a standard NTA-775 socket."
	hashrate_bonus = 50 //CPUs give a good boost, but they won't really help when the difficulty goes SUPER hard.
	heat_amplifier = 20 //CPUS get nice and toasty
	overclock_heat_boost = 30 //THE HEAAAAAT
	icon_state = "cpu_basic-component"
	component_type = CPU
	part_state = "cpu_basic"

/obj/item/computer_component/cooling
	name = "A fan of some sort"
	var/heat_reduction = 5 //How much heat to suck off whatever it's attached to.
	var/obj/item/computer_component/attached

/obj/item/computer_component/cooling/process()
	. = ..()
	while(active && attached.temperature > 0)
		attached.temperature -= heat_reduction

/obj/item/computer_component/cooling/liquid_cooling
	name = "NT-cooling Esketimo all-in-one"
	desc = "A large radiator and pump solution filled with water, this should really keep that CPU cool!."
	hashrate_bonus = 0 //CPUs give a good boost, but they won't really help when the difficulty goes SUPER hard.
	heat_amplifier = 0 //It doesn't generate its own heat, it instead sucks up the CPUs heat. It's only really worth liquid cooling a good CPU.
	overclock_heat_boost = 0
	icon_state = "liquidcooling_basic-component"
	heat_reduction = 40 //Huge heat reduction
	component_type = LIQUID
	part_state = "liquidcooling_basic"

/obj/item/computer_component/cooling/case_fan
	name = "Akrasha basic case fan"
	desc = "A basic case fan, it might cool your stuff down?...it's warranty went void when the wall was still up."
	hashrate_bonus = 0 //CPUs give a good boost, but they won't really help when the difficulty goes SUPER hard.
	heat_amplifier = 0 //It doesn't generate its own heat, it instead sucks up the CPUs heat. It's only really worth liquid cooling a good CPU.
	overclock_heat_boost = 0
	icon_state = "case_fan_basic-component"
	heat_reduction = 10 //OK heat reduction
	component_type = FAN
	part_state = "case_fan_basic"


#undef PSU
#undef GPU
#undef RAM
#undef MOBO
#undef CPU
#undef LIQUID
#undef FAN

//have a current calculation that is being worked on, each computer's hashrate adds up and chips away at the time left for it to break (which stays still if no one is mining), then weight computers on how much they contributed to that hash and split the cut.