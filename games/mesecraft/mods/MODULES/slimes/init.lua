slimes = {}
slimes.path = minetest.get_modpath("slimes").."/slimes/"
slimes.colors = {}


minetest.register_craftitem("slimes:live_nucleus", {
	description = "Living Nucleus",
	inventory_image = "slime_nucleus.png"
})

slimes.add_slime = function(string, aquatic) 
	local proper_name = string.upper(string.sub(string,1,1))..string.sub(string,2,-1)
	minetest.register_craftitem("slimes:"..string.."_goo", {
		inventory_image = "slime_goo.png^[colorize:"..slimes.colors[string],
		description = proper_name.." Goo",
		groups = {slime = 1},
	})

	minetest.register_node("slimes:"..string.."_goo_block", {
		tiles = {"slime_goo_block.png^[colorize:"..slimes.colors[string].."^[colorize:#0000:25"},
		description = proper_name.." Goo Block",
		drawtype = "allfaces_optional",
		use_texture_alpha = "blend",
		groups = {slippery = 2, crumbly=3, oddly_breakable_by_hand = 1, fall_damage_add_percent=-80, bouncy=90},
		sounds = default.node_sound_snow_defaults(),
	})
	local goo = "slimes:"..string.."_goo"
	minetest.register_craft({
		output = "slimes:"..string.."_goo_block",
		recipe = {
			{goo,goo,goo},
			{goo,goo,goo},
			{goo,goo,goo}
		}
	})
	
	dofile(slimes.path..string..".lua")
	mobs:register_egg("slimes:"..string.."_slime", proper_name.." Slime", "slime_".."inventory.png^[colorize:"..slimes.colors[string]..
		(aquatic and "^(slime_aquatic_inventory.png^[colorize:"..slimes.colors[string].."^[colorize:#FFF:96)" or ""), 
	0)
	minetest.register_craft({
		output = "slimes:"..string.."_slime",
		recipe = {
			{goo,goo,goo},
			{goo,"slimes:live_nucleus",goo},
			{goo,goo,goo}
		}
	})
	
end
slimes.weak_dmg   = 1
slimes.medium_dmg = 5
slimes.strong_dmg = 10
slimes.deadly_dmg = 50

slimes.pervasive = 5000
slimes.common    = 10000
slimes.uncommon  = 15000
slimes.rare      = 25000

slimes.pervasive_max = 8
slimes.common_max    = 6
slimes.uncommon_max  = 4
slimes.rare_max      = 2

slimes.absorb_nearby_items = function(ent)
	local pos = ent.object:get_pos()
	for _,obj in pairs(minetest.get_objects_inside_radius(pos, 1.25)) do
		local oent = obj:get_luaentity()
		if oent and oent.name == "__builtin:item" then
			if not ent.stomach then ent.stomach = {} end
			if #ent.stomach >= 24 then break end
			table.insert(ent.stomach, oent.itemstring)
			obj:remove()
			minetest.sound_play("mobs_monster_slime_slurp", {pos = pos, max_hear_distance = 10, gain = 0.7})
			ent.lifetimer = (ent.lifetimer and ent.lifetimer > 20000) and ent.lifetimer + 7200 or 27200
			 -- Keep this slime around even after unload for at least another 2 hours per item picked up, 
			 -- so slimes don't just grab killed players' items and despawn.
			 
			break --Pick up only one item per step
		end
	end
end

slimes.drop_items = function(self, pos)
	if self.stomach then
		for _,item in ipairs(self.stomach) do
			minetest.add_item({x=pos.x + math.random()/2,y=pos.y+0.5,z=pos.z+math.random()/2}, item)
		end
	end
end

slimes.animate = function(ent)
	if not (ent and minetest.registered_entities[ent.name] and ent.object) then return end
	local pos = ent.object:get_pos()
	local velocity = ent.object:get_velocity()
	local is_liquid_below = ((minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y-0.5,z=pos.z}).name] or {liquidtype = "none"}).liquidtype == "none")
	local land_movement = (minetest.registered_entities[ent.name].mesh == "slime_land.b3d") or not is_liquid_below
	if velocity.y ~= 0 then
		if not land_movement and (math.abs(velocity.x) > math.abs(velocity.y) or math.abs(velocity.z) > math.abs(velocity.y)) then
			mobs.set_animation(ent, "move")
			return
		end
		if velocity.y > 0 then
			mobs:set_animation(ent, "jump")
			return
		else
			mobs:set_animation(ent, "fall")
			return
		end
	end
	if velocity.x ~= 0 or velocity.z ~= 0 then
		mobs:set_animation(ent, "move")
		return
	end
	mobs:set_animation(ent, "idle")
end

--Land model
slimes.colors["poisonous"] = "#205:200"
slimes.add_slime("poisonous")
slimes.colors["jungle"] = "#0A1:180"
slimes.add_slime("jungle")
slimes.colors["savannah"] = "#204004:200"
slimes.add_slime("savannah")
slimes.colors["icy"] = "#8BF:160"
slimes.add_slime("icy")

--Land model (underground)

slimes.colors["mineral"] = "#584000:225"
slimes.add_slime("mineral")
slimes.colors["dark"] = "#000:220"
slimes.add_slime("dark")

if minetest.get_modpath("other_worlds") then
	slimes.colors["alien"] = "#800:220"
	slimes.add_slime("alien", true)
end

--Liquid model

slimes.colors["cloud"] = "#EEF:180"
slimes.add_slime("cloud", true)

slimes.colors["algae"] = "#0C9:180"
slimes.add_slime("algae", true)

slimes.colors["ocean"] = "#00C:200"
slimes.add_slime("ocean", true)

slimes.colors["lava"] = "#F80:190"
slimes.add_slime("lava", true)

minetest.register_craft({
	output = "slimes:live_nucleus",
	recipe = {"slimes:lava_goo","slimes:ocean_goo","slimes:mineral_goo"},
	type="shapeless"
})


slimes.colors["uber"] = "#FD0:200"
dofile(slimes.path.."uber.lua")

minetest.register_abm({
	nodenames = {"group:harmful_slime"},
	interval = 2,
	chance = 1,
	action = function(pos, node)
		local dmg = minetest.registered_nodes[node.name].groups.harmful_slime
		for _,ent in pairs(minetest.get_objects_inside_radius(pos, 1.75)) do
			if ent:is_player() then
				ent:punch(ent, nil, {damage_groups={fleshy=dmg}}, nil)
			else
				local luaent = ent:get_luaentity()
				if luaent and 
					luaent._cmi_is_mob and 
					not string.find(node.name, string.sub(luaent.name, 11, -7).."_goo")
				then
					ent:punch(ent, nil, {damage_groups={fleshy=dmg}}, nil)
				end
			end 
		end
	end
})
