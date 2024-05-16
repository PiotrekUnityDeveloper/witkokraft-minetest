
-- extra doors mod
if minetest.get_modpath("extra_doors") then

	lucky_block:add_blocks({
		{"dro", {"default:steel_rod"}, 10},
		{"dro", {"extra_doors:door_woodpanel1"}, 1},
		{"dro", {"extra_doors:door_woodglass1"}, 1},
		{"dro", {"extra_doors:door_woodglass2"}, 1},
		{"dro", {"extra_doors:door_door_japanese"}, 1},
		{"dro", {"extra_doors:door_door_french"}, 1},
		{"dro", {"extra_doors:door_door_cottage1"}, 1},
		{"dro", {"extra_doors:door_door_cottage2"}, 1},
		{"dro", {"extra_doors:door_door_barn1"}, 1},
		{"lig"},
		{"dro", {"extra_doors:door_door_barn2"}, 1},
		{"dro", {"extra_doors:door_door_castle1"}, 1},
		{"dro", {"extra_doors:door_door_castle2"}, 1},
		{"dro", {"extra_doors:door_door_mansion1"}, 1},
		{"dro", {"extra_doors:door_door_mansion2"}, 1},
		{"dro", {"extra_doors:door_door_dungeon1"}, 1},
		{"dro", {"extra_doors:door_door_dungeon2"}, 1},
		{"dro", {"extra_doors:door_door_steelpanel1"}, 1},
		{"dro", {"extra_doors:door_door_steelglass1"}, 1},
		{"dro", {"extra_doors:door_door_steelglass2"}, 1}
	})
end

-- Home Decor mod
if minetest.get_modpath("homedecor") then

	lucky_block:add_blocks({
		{"nod", "homedecor:toilet", 0},
		{"nod", "homedecor:table", 0},
		{"nod", "homedecor:chair", 0},
		{"nod", "homedecor:table_lamp_off", 0},
		{"dro", {"homedecor:plastic_sheeting", "homedecor:plastic_base"}, 15},
		{"dro", {"homedecor:roof_tile_terracotta"}, 20},
		{"dro", {"homedecor:shutter_oak"}, 5},
		{"dro", {"homedecor:shutter_black"}, 5},
		{"dro", {"homedecor:shutter_dark_grey"}, 5},
		{"dro", {"homedecor:shutter_grey"}, 5},
		{"dro", {"homedecor:shutter_white"}, 5},
		{"dro", {"homedecor:shutter_mahogany"}, 5},
		{"dro", {"homedecor:shutter_yellow"}, 5},
		{"dro", {"homedecor:shutter_forest_green"}, 5},
		{"dro", {"homedecor:shutter_light_blue"}, 5},
		{"dro", {"homedecor:shutter_violet"}, 5},
		{"dro", {"homedecor:table_legs_wrought_iron", "homedecor:utility_table_legs"}, 5},
		{"dro", {"homedecor:pole_wrought_iron"}, 10},
		{"dro", {"homedecor:fence_picket_white"}, 20}
	})
end

-- Caverealms
if minetest.get_modpath("caverealms") then

	lucky_block:add_blocks({
		{"sch", "sandtrap", 1, true, {{"default:sand", "caverealms:coal_dust"}} },
		{"sch", "obsidiantrap", 1, true, {{"default:obsidian",
				"caverealms:glow_obsidian_brick_2"}} },
		{"flo", 5, {"caverealms:stone_with_moss"}, 2},
		{"flo", 5, {"caverealms:stone_with_lichen"}, 2},
		{"flo", 5, {"caverealms:stone_with_algae"}, 2},
	})
end

-- Moreblocks mod
if minetest.get_modpath("moreblocks") then

	local p = "moreblocks:"
	local lav = {name = "default:lava_source"}
	local air = {name = "air"}
	local trs = {name = p .. "trap_stone"}
	local trg = {name = p .. "trap_glow_glass"}
	local trapstone_trap = {
		size = {x = 3, y = 6, z = 3},
		data = {
			lav, lav, lav, air, air, air, air, air, air,
			air, air, air, air, air, air, trs, trs, trs,
			lav, lav, lav, air, air, air, air, air, air,
			air, air, air, air, trg, air, trs, air, trs,
			lav, lav, lav, air, air, air, air, air, air,
			air, air, air, air, air, air, trs, trs, trs
		}
	}

	lucky_block:add_schematics({
		{"trapstonetrap", trapstone_trap, {x = 1, y = 6, z = 1}}
	})

	lucky_block:add_blocks({
		{"dro", {p.."wood_tile"}, 10},
		{"dro", {p.."wood_tile_center"}, 10},
		{"dro", {p.."wood_tile_full"}, 10},
		{"dro", {p.."wood_tile_offset"}, 10},
		{"dro", {p.."circle_stone_bricks"}, 20},
		{"dro", {p.."grey_bricks"}, 20},
		{"dro", {p.."stone_tile"}, 10},
		{"dro", {p.."split_stone_tile"}, 10},
		{"dro", {p.."split_stone_tile_alt"}, 10},
		{"flo", 5, {"moreblocks:stone_tile", "moreblocks:split_stone_tile"}, 2},
		{"dro", {p.."tar", p.."cobble_compressed"}, 10},
		{"dro", {p.."cactus_brick"}, 10},
		{"dro", {p.."cactus_checker"}, 10},
		{"nod", {p.."empty_bookshelf"}, 0},
		{"dro", {p.."coal_stone"}, 10},
		{"dro", {p.."coal_checker"}, 10},
		{"dro", {p.."coal_stone_bricks"}, 10},
		{"dro", {p.."coal_glass"}, 10},
		{"exp", 3},
		{"dro", {p.."iron_stone"}, 10},
		{"dro", {p.."iron_checker"}, 10},
		{"dro", {p.."iron_stone_bricks"}, 10},
		{"dro", {p.."iron_glass"}, 10},
		{"dro", {p.."trap_obsidian"}, 10},
		{"dro", {p.."trap_sandstone"}, 10},
		{"dro", {p.."trap_desert_stone"}, 10},
		{"dro", {p.."trap_stone"}, 10},
		{"dro", {p.."trap_glass"}, 10},
		{"dro", {p.."trap_glow_glass"}, 10},
		{"dro", {p.."trap_obsidian_glass"}, 10},
		{"lig"},
		{"sch", "trapstonetrap", 0, true},
		{"dro", {p.."all_faces_tree"}, 10},
		{"dro", {p.."all_faces_jungle_tree"}, 10},
		{"dro", {p.."all_faces_pine_tree"}, 10},
		{"dro", {p.."all_faces_acacia_tree"}, 10},
		{"dro", {p.."all_faces_aspen_tree"}, 10},
		{"flo", 3, {p.."all_faces_acacia_tree"}, 1},
		{"dro", {p.."plankstone"}, 10},
		{"fal", {p.."all_faces_tree", p.."all_faces_tree", p.."all_faces_tree",
				p.."all_faces_tree", p.."all_faces_tree"}, 0},
		{"dro", {p.."glow_glass"}, 10},
		{"dro", {p.."super_glow_glass"}, 10},
		{"dro", {p.."clean_glass"}, 10},
		{"nod", "default:chest", 0, {
			{name = p.."rope", max = 10},
			{name = p.."sweeper", max = 1},
			{name = p.."circular_saw", max = 1},
			{name = p.."grey_bricks", max = 10},
			{name = p.."tar", max = 3}
		}},
		{"flo", 3, {"moreblocks:copperpatina"}, 1}
	})
end

-- worm farm mod
if minetest.get_modpath("worm_farm") then

	lucky_block:add_blocks({
		{"nod", "default:chest", 0, {
			{name = "ethereal:worm", max = 5},
			{name = "worm_farm:worm_tea", max = 5},
			{name = "ethereal:worm", max = 5},
			{name = "worm_farm:worm_farm", max = 1}
		}},
		{"cus", dropsy, {item = "ethereal:worm", msg = "Worm Attack!"}},
		{"dro", {"worm_farm:worm_farm"}, 1}
	})
end
