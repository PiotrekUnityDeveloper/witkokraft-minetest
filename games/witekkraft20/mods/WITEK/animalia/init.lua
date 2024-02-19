animalia = {}

local path = minetest.get_modpath("animalia")

local storage = dofile(path .. "/api/storage.lua")

animalia.spawn_points = storage.spawn_points
animalia.libri_font_size = storage.libri_font_size

animalia.pets = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	animalia.pets[name] = {}
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	animalia.pets[name] = nil
end)

-- Daytime Tracking

animalia.is_day = true

local function is_day()
	local time = (minetest.get_timeofday() or 0) * 24000
	animalia.is_day = time < 19500 and time > 4500
	minetest.after(10, is_day)
end

is_day()

-- Player Effects

animalia.player_effects = {}

local function player_effect_step()
	for player, data in pairs(animalia.player_effects) do
		if player then
			local timer = data.timer - 1
			animalia.player_effects[player].timer = timer
			local func = data.func
			func(minetest.get_player_by_name(player))
			if timer <= 0 then
				animalia.player_effects[player] = nil
			end
		end
	end
	minetest.after(1, player_effect_step)
end

player_effect_step()

function animalia.set_player_effect(player_name, effect, timer)
	animalia.player_effects[player_name] = {
		func = effect,
		timer = timer or 5
	}
end

-- Create lists of items for reuse

animalia.food_wheat = {}
animalia.food_seeds = {}
animalia.food_crops = {}
animalia.food_bear = {}

minetest.register_on_mods_loaded(function()
	if minetest.get_modpath("farming")
	and farming.registered_plants then
		for _, def in pairs(farming.registered_plants) do
			if def.crop then
				table.insert(animalia.food_crops, def.crop)
			end
		end
	end
	for name in pairs(minetest.registered_items) do
		if (name:match(":wheat")
		or minetest.get_item_group(name, "food_wheat") > 0)
		and not name:find("seed") then
			table.insert(animalia.food_wheat, name)
		end
		if name:match(":seed_")
		or name:match("_seed") then
			table.insert(animalia.food_seeds, name)
		end
		if (minetest.get_item_group(name, "food_berry") > 0
		and not name:find("seed"))
		or minetest.get_item_group(name, "food_fish") > 0 then
			table.insert(animalia.food_bear, name)
		end
	end
end)

-- Load Files

local function load_file(filepath, filename)
    if io.open(filepath .. "/" .. filename, "r") then
        dofile(filepath .. "/" .. filename)
    else
        minetest.log("action", "[Creatura] The file " .. filename .. " could not be loaded.")
    end
end

dofile(path.."/api/api.lua")
dofile(path.."/api/mob_ai.lua")
--dofile(path.."/api/lasso.lua")
dofile(path.."/craftitems.lua")

animalia.animals = {
	"animalia:cat",
	"animalia:fox",
	"animalia:frog",
	"animalia:owl",
	"animalia:rat",
}

dofile(path.."/api/api.lua")

load_file(path .. "/mobs", "cat.lua")
load_file(path .. "/mobs", "fox.lua")
load_file(path .. "/mobs", "frog.lua")
load_file(path .. "/mobs", "owl.lua")
load_file(path .. "/mobs", "rat.lua")


if minetest.settings:get_bool("spawn_mobs", true) then
	dofile(path.."/api/spawning.lua")
end

--dofile(path.."/api/libri.lua")

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_entities) do
		if def.logic
		or def.brainfunc
		or def.bh_tree
		or def._cmi_is_mob then
			local old_punch = def.on_punch
			if not old_punch then
				old_punch = function() end
			end
			local on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
				old_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
				local pos = self.object:get_pos()
				if not pos then return end
				local plyr_name = puncher:is_player() and puncher:get_player_name()
				local pets = (plyr_name and animalia.pets[plyr_name]) or {}
				for _, obj in ipairs(pets) do
					local ent = obj and obj:get_luaentity()
					if ent
					and ent.assist_owner then
						ent.owner_target = self
					end
				end
			end
			def.on_punch = on_punch
			minetest.register_entity(":" .. name, def)
		end
	end
end)
