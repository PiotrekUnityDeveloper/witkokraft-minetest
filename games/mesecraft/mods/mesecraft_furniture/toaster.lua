local S = mesecraft_furniture.intllib

--Toaster and Toast--
minetest.register_node("mesecraft_furniture:toaster", {
	description = S("Toaster (empty)"),
	tiles = {
		"mesecraft_furniture_toas_top.png",
		"mesecraft_furniture_toas_bottom.png",
		"mesecraft_furniture_toas_right.png",
		"mesecraft_furniture_toas_left.png",
		"mesecraft_furniture_toas_back.png",
		"mesecraft_furniture_toas_front.png"
	},
	walkable = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, furniture = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Toaster (empty)"))
	end,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, 0, 0.375, -0.0625, 0.3125},
			{-0.4375, -0.1875, 0.0625, -0.375, -0.125, 0.25},
		},
	},
	on_punch = function (pos, node, player, pointed_thing)
		local pname = player and player:get_player_name()
		if pname then
			minetest.chat_send_player(pname, "Place bread slices in toaster")
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack)
		if itemstack:get_name() == "mesecraft_furniture:breadslice" or itemstack:get_name() == "farming:bread_slice" then
			local pname = clicker and clicker:get_player_name()
			if minetest.is_protected(pos, pname) then
				minetest.record_protection_violation(pos, pname)
			else
				if itemstack:get_count() >= 2 then
					itemstack:take_item(2)
					minetest.set_node(pos, {name = "mesecraft_furniture:toaster_with_breadslice", param2 = node.param2})
				end
			end
		end
		return itemstack
	end,
})

if minetest.registered_items["farming:bread_slice"] then
	minetest.register_alias("mesecraft_furniture:breadslice", "farming:bread_slice")
else
	minetest.register_craftitem("mesecraft_furniture:breadslice", {
		description = S("Slice of Bread"),
		inventory_image = "mesecraft_furniture_breadslice.png",
		groups = {flammable = 2},
		on_use = breadslice_on_use,
	})
end

if minetest.registered_items["farming:toast"] then
	minetest.register_alias("mesecraft_furniture:toast", "farming:toast")
else
	minetest.register_craftitem("mesecraft_furniture:toast", {
		description = S("Toast"),
		inventory_image = "mesecraft_furniture_toast.png",
		on_use = minetest.item_eat(3),
		groups = {flammable = 2},
	})
end

minetest.register_node("mesecraft_furniture:toaster_with_breadslice", {
	description = S("Toaster (with bread)"),
	tiles = {
		"mesecraft_furniture_toas_top_bread.png",
		"mesecraft_furniture_toas_bottom.png",
		"mesecraft_furniture_toas_right_bread.png",
		"mesecraft_furniture_toas_left_bread.png",
		"mesecraft_furniture_toas_back_bread.png",
		"mesecraft_furniture_toas_front_bread.png"
	},
	walkable = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, furniture = 1, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Toaster (with bread)"))
	end,
	diggable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, 0, 0.375, -0.0625, 0.3125}, -- NodeBox1
			{-0.25, -0.0625, 0.0625, 0.25, 0.0625, 0.125}, -- NodeBox2
			{-0.25, -0.0625, 0.1875, 0.25, 0.0625, 0.25}, -- NodeBox3
			{-0.4375, -0.1875, 0.0625, -0.375, -0.125, 0.25}, -- NodeBox4
		},
	},
	on_punch = function(pos, node, clicker, itemstack, pointed_thing)
		local fdir = node.param2
		minetest.set_node(pos, { name = "mesecraft_furniture:toaster_toasting_breadslice", param2 = fdir })
		minetest.after(6, minetest.set_node, pos, { name = "mesecraft_furniture:toaster_with_toast", param2 = fdir })
		minetest.sound_play("toaster", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 5
		})
		return itemstack
	end
})

minetest.register_node("mesecraft_furniture:toaster_toasting_breadslice", {
	description = S("Toaster (toasting)"),
	tiles = {
		"mesecraft_furniture_toas_top_bread_on.png",
		"mesecraft_furniture_toas_bottom.png",
		"mesecraft_furniture_toas_right_bread.png",
		"mesecraft_furniture_toas_left_toast_side.png",
		"mesecraft_furniture_toas_back_side.png",
		"mesecraft_furniture_toas_front_side.png"
	},
	walkable = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, furniture = 1, not_in_creative_inventory = 1 },
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Toaster (toasting)"))
	end,
	diggable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, 0, 0.375, -0.0625, 0.3125}, -- NodeBox1
			{-0.4375, -0.375, 0.0625, -0.375, -0.3125, 0.25}, -- NodeBox4
		},
	},
})

minetest.register_node("mesecraft_furniture:toaster_with_toast", {
	description = S("Toaster (with toast)"),
		tiles = {
		"mesecraft_furniture_toas_top_toast.png",
		"mesecraft_furniture_toas_bottom.png",
		"mesecraft_furniture_toas_right_toast.png",
		"mesecraft_furniture_toas_left_toast.png",
		"mesecraft_furniture_toas_back_toast.png",
		"mesecraft_furniture_toas_front_toast.png"
	},
	walkable = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, furniture = 1, not_in_creative_inventory=1 },
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Toaster (with toast)"))
	end,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, 0, 0.375, -0.0625, 0.3125}, -- NodeBox1
			{-0.25, -0.0625, 0.0625, 0.25, 0.0625, 0.125}, -- NodeBox2
			{-0.25, -0.0625, 0.1875, 0.25, 0.0625, 0.25}, -- NodeBox3
			{-0.4375, -0.1875, 0.0625, -0.375, -0.125, 0.25}, -- NodeBox4
		},
	},
	on_punch = function (pos, node, player, pointed_thing)
		local inv = player:get_inventory()
		local left = inv:add_item("main", "mesecraft_furniture:toast 2")
		if left:is_empty() then
			minetest.set_node(pos, {name = "mesecraft_furniture:toaster", param2 = node.param2})
		end
	end
})

minetest.register_craft({
	output = 'mesecraft_furniture:toaster',
	recipe = {
	{'','','',},
	{'default:steel_ingot','default:mese_crystal','default:steel_ingot',},
	{'default:steel_ingot','default:steel_ingot','default:steel_ingot',},
	}
})
	
--Slice of Bread (only if not farming one used)
if not minetest.registered_items["farming:bread_slice"] then
	minetest.register_craft({
		output = 'mesecraft_furniture:breadslice 2',
		type = "shapeless",
		recipe = {"farming:bread"}
	})
end
