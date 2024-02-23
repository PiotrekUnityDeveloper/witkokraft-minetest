local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

mcl_structures.register_structure("desert_oasis",{
	place_on = {"group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	y_offset = function(pr) return -(pr:next(2,3)) end,
	chunk_probability = 200,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Desert" },
	sidelen = 18,
	filenames = {
		modpath.."/schematics/mcl_extra_structures_desert_oasis_1.mts",
		modpath.."/schematics/mcl_extra_structures_desert_oasis_2.mts",
	},
	loot = {
		["mcl_barrels:barrel_closed" ] ={{
			stacks_min = 2,
			stacks_max = 2,
			items = {
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 16, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_mobitems:saddle", weight = 3, },
				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 1, },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
			}
		},
		{
			stacks_min = 2,
			stacks_max = 2,
			items = {
				{ itemstring = "mcl_core:tree", weight = 1, amount_min = 4, amount_max=6 },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_buckets:bucket_water", weight = 1, amount_min = 1, amount_max=1 },
			}
		}}
	}
})
