-- Setup
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
local version = "1.0"

-- Help texts
local pickaxe_longdesc = S("Pickaxes made from semi-rare stones like Andesite or Granite have slightly better stats than cobblestone pickaxes, but they will not mine any additional ores (use iron for that).")
local shovel_longdesc = S("Shovels made from semi-rare stones like Andesite or Granite have slightly better stats than cobblestone axes.")
local axe_longdesc = S("Axes made from semi-rare stones like Andesite or Granite have slightly better stats than cobblestone axes.")
local hoe_longdesc = S("Hoes made from semi-rare stones like Andesite or Granite have slightly better stats than cobblestone hoes.")

local wield_scale = mcl_vars.tool_wield_scale

-- Changes from base stone pickaxe:
-- enchantability up from 5 to 8 for all
-- punch_attack_uses up from 66 to 75 for all
-- uses up from 132 to 183 for all

-- Variant-specific changes:
-- Andesite gets range up from 4.0 to 4.5
-- Diorite gets speed up from 4 to 5
-- Granite gets punch_attack_uses up to 93 and uses up to 211
-- Deepslate gets speed up from 4 to 5, punch_attack_uses up to 104, and
--   uses up to 237

-- From:
-- https://stackoverflow.com/questions/2421695/first-character-uppercase-lua
function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end


-- TODO: This, the right way.
local function create_soil(pos, inv)
	if pos == nil then
		return false
	end
	local node = minetest.get_node(pos)
	local name = node.name
	local above = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z})
	if minetest.get_item_group(name, "cultivatable") == 2 then
		if above.name == "air" then
			node.name = "mcl_farming:soil"
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.5 }, true)
			return true
		end
	elseif minetest.get_item_group(name, "cultivatable") == 1 then
		if above.name == "air" then
			node.name = "mcl_core:dirt"
			minetest.set_node(pos, node)
			minetest.sound_play("default_dig_crumbly", { pos = pos, gain = 0.6 }, true)
			return true
		end
	end
	return false
end

local hoe_on_place_function = function(wear_divisor)
	return function(itemstack, user, pointed_thing)
		-- Call on_rightclick if the pointed node defines it
		local node = minetest.get_node(pointed_thing.under)
		if user and not user:get_player_control().sneak then
			if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
				return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
			end
		end

		if minetest.is_protected(pointed_thing.under, user:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.under, user:get_player_name())
			return itemstack
		end

		if create_soil(pointed_thing.under, user:get_inventory()) then
			if not minetest.is_creative_enabled(user:get_player_name()) then
				itemstack:add_wear(65535/wear_divisor)
			end
			return itemstack
		end
	end
end


-- Registers the tool + crafting recipe for pickaxe, axe, and shovel for
-- a specific material. Arguments control extra values for a few
-- parameters: range, speed, punches, uses.
local function make_tool_variant(mat, range, speed, punches, uses)
    local full_mat = 'mcl_core:' .. mat;
    range = 4.0 + range;
    speed = 4 + speed;
    punches = 72 + punches;
    uses = 174 + uses;

    minetest.register_tool('mcl_rocky_tools:pick_' .. mat, {
        description = S(firstToUpper(mat) .. ' Pickaxe'),
        _doc_items_longdesc = pickaxe_longdesc,
        inventory_image = 'mcl_rocky_tools_pickaxe_' .. mat .. '.png',
        wield_scale = wield_scale,
        -- Slightly longer-than-default range.
        range=range,
        groups = { tool=1, pickaxe=1, dig_speed_class=3, enchantability=8 },
        tool_capabilities = {
            -- 1/1.2
            full_punch_interval = 0.83333333,
            max_drop_level=3,
            damage_groups = {fleshy=3},
            punch_attack_uses = punches
        },
        sound = { breaks = 'default_tool_breaks' },
        _repair_material = full_mat,
        _mcl_toollike_wield = true,
        _mcl_diggroups = {
            pickaxey = { speed = speed, level = 3, uses = uses }
        },
    });

    minetest.register_tool("mcl_rocky_tools:shovel_" .. mat, {
        description = S(firstToUpper(mat) .. " Shovel"),
        _doc_items_longdesc = shovel_longdesc,
        _doc_items_usagehelp = shovel_use,
        inventory_image = 'mcl_rocky_tools_shovel_' .. mat .. '.png',
        wield_scale = wield_scale,
        groups = { tool=1, shovel=1, dig_speed_class=3, enchantability=8 },
        tool_capabilities = {
            full_punch_interval = 1,
            max_drop_level=3,
            damage_groups = {fleshy=3},
            punch_attack_uses = punches,
        },
        on_place = make_grass_path,
        sound = { breaks = "default_tool_breaks" },
        _repair_material = full_mat,
        _mcl_toollike_wield = true,
        _mcl_diggroups = {
            shovely = { speed = speed, level = 3, uses = uses }
        },
    });

    minetest.register_tool("mcl_rocky_tools:axe_" .. mat, {
        description = S(firstToUpper(mat) .. " Axe"),
        _doc_items_longdesc = axe_longdesc,
        inventory_image = 'mcl_rocky_tools_axe_' .. mat .. '.png',
        wield_scale = wield_scale,
        groups = { tool=1, axe=1, dig_speed_class=3, enchantability=8 },
        tool_capabilities = {
            full_punch_interval = 1.25,
            max_drop_level=3,
            damage_groups = {fleshy=9},
            punch_attack_uses = punches,
        },
        on_place = make_stripped_trunk,
        sound = { breaks = "default_tool_breaks" },
        _repair_material = full_mat,
        _mcl_toollike_wield = true,
        _mcl_diggroups = {
            axey = { speed = speed, level = 3, uses = uses }
        },
    });

    minetest.register_tool("mcl_rocky_tools:hoe_" .. mat, {
        description = S(firstToUpper(mat) .. " Hoe"),
        _tt_help = (
            S("Turns block into farmland")
         .. "\n"
         .. S("Uses: @1", uses)
        ),
        _doc_items_longdesc = hoe_longdesc,
        _doc_items_usagehelp = hoe_usagehelp,
        inventory_image = 'mcl_rocky_tools_hoe_' .. mat .. '.png',
        wield_scale = wield_scale,
        on_place = hoe_on_place_function(uses),
        groups = { tool=1, hoe=1, enchantability=8 },
        tool_capabilities = {
            full_punch_interval = 0.5,
            damage_groups = { fleshy = 1, },
            punch_attack_uses = punches,
        },
        _repair_material = full_mat,
        _mcl_toollike_wield = true,
        _mcl_diggroups = {
            hoey = { speed = speed, level = 3, uses = uses }
        },
    });

    -- Crafting
    minetest.register_craft({
        output = 'mcl_rocky_tools:pick_' .. mat,
        recipe = {
            {full_mat, full_mat, full_mat},
            {"", "mcl_core:stick", ""},
            {"", "mcl_core:stick", ""},
        }
    });

    minetest.register_craft({
        output = 'mcl_rocky_tools:shovel_' .. mat,
        recipe = {
            {"", full_mat, ""},
            {"", "mcl_core:stick", ""},
            {"", "mcl_core:stick", ""},
        }
    });

    minetest.register_craft({
        output = 'mcl_rocky_tools:axe_' .. mat,
        recipe = {
            {full_mat, full_mat, ""},
            {full_mat, "mcl_core:stick", ""},
            {"", "mcl_core:stick", ""},
        }
    });

    minetest.register_craft({
        output = 'mcl_rocky_tools:hoe_' .. mat,
        recipe = {
            {full_mat, full_mat, ""},
            {"", "mcl_core:stick", ""},
            {"", "mcl_core:stick", ""},
        }
    });
end

-- Actually create the variants:
make_tool_variant("andesite", 0.5, 0, 0, 0);
make_tool_variant("diorite", 0.0, 0.5, 0, 0);
make_tool_variant("granite", 0.0, 0, 18, 28);
make_tool_variant("deepslate", 0.0, 0.8, 29, 54);

-- Ideas:
-- Nethrerack pickaxe has a 5% chance to set the square on fire after
--   mining.
-- Sandstone pickaxe is just bad? Or also serves as a shovel?
--   Can be crafted without a crafting table?
-- Obsidan? Higher tier?
-- End Stone Pickaxe? What would it do?
-- Does MC2 have these?
--   Dripstone?
--   Basalt?
--   Calcite?
