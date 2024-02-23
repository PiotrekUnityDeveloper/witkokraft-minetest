local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

mcl_armor.register_set({
	name = "emerald",
	description = "Emerald",
	durability = 560,
	enchantability = 10,
	points = {
		head = 3,
		torso = 8,
		legs = 6,
		feet = 3,
	},
	toughness = 3,
	craft_material = "mcl_core:emerald",
	upgradable = true,
})
