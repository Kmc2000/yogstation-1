//Basic space pod

//NOTE: These icons will be here; 	icon = 'icons/mecha/mech_construct.dmi' as it's a child of mecha parts, be aware of that future me.//

/obj/item/mecha_parts/chassis/pod
	name = "\improper Space Pod Frame"

/obj/item/mecha_parts/chassis/pod/New()
	..()
	construct = new /datum/construction/mecha/ripley_chassis(src)

/obj/item/mecha_parts/part/pod_plates
	name = "\improper Space Pod Plates"
	desc = "Heavy metal plates used to line space pod interiors for fire resistance"
	icon_state = "podplates"
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"

/obj/item/mecha_parts/part/pod_armour
	name = "\improper Space Pod outer armour"
	desc = "Large steel plates that provide damage resistance to the outer shell of a space pod"
	icon_state = "pod_armour"

/obj/item/mecha_parts/part/helm
	name = "\improper Ripley right arm"
	desc = "The helm of a space pod, the pilot will sit here to control the pod as it flies"
	icon_state = "pod_helm"

/obj/item/mecha_parts/part/thruster
	name = "\improper Pod Thruster"
	desc = "Ion thrusters used in pods and all shuttlecrafts made by nanotrasen"
	icon_state = "ion_thruster"

/obj/item/mecha_parts/part/cabin
	name = "\improper Pod Cabin"
	desc = "The main seating area of the pod, it's quite cramped and has many slots for wires to fill"
	icon_state = "cabin"

//Other pods go here//

//Boards//
/obj/item/weapon/circuitboard/mecha/pod
	origin_tech = "programming=2" //you can get this quite early on, subject to balance change etc.

/obj/item/weapon/circuitboard/mecha/pod/peripherals
	name = "circuit board (Starship Pod Periphorals Control Module)"
	icon_state = "mcontroller"

/obj/item/weapon/circuitboard/mecha/pod/targeting
	name = "circuit board (Starship Pod Weapon Control and Targeting module)"
	icon_state = "mcontroller"

/obj/item/weapon/circuitboard/mecha/pod/main
	name = "circuit board (Starship Central Control module)"



//DESIRED construction
//Chassis//
//add all parts, wrench after each part added//
//Add cables to wire it up//
//fit all pod control systems IE circuits, screwdriver after each new system fitted//
//Welder to weld outer plates together//
//Screwdriver to screw in inner plates//
//Multitool to sync up computer systems in pod//
//add metal//
//wrench//
//welder to weld metal plates to the outer sheath//
//wrench to tighten anchoring bolts//
//Crowbar to shift the thrusters into their block//
//Wrench to attach thrusters//
//Cables to connect all secondary pod systems//
//Screwdriver to finish//