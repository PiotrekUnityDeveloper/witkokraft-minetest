local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

mcl_structures.register_structure("birch_forest_ruins",{
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	y_offset = function(pr) return -(pr:next(0,1)) end,
	chunk_probability = 200,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "BirchForest" },
	sidelen = 18,
	filenames = {
		modpath.."/schematics/mcl_extra_structures_birch_forest_ruins_1.mts",
		modpath.."/schematics/mcl_extra_structures_birch_forest_ruins_2.mts",
	},
	loot = {
		["mcl_chests:chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 16, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_core:gold_ingot", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 5, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:diamond", weight = 1, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_tools:sword_stone", weight = 15, },
				{ itemstring = "mcl_tools:pick_stone", weight = 15, },
				{ itemstring = "mcl_tools:shovel_stone", weight = 15, },
				{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 3, amount_max=7 },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_fire:flint_and_steel", weight = 1, amount_min = 1, amount_max=1 },
			}
		}}
	}
})
