
--[[
    Instead of placing technic's uranium ore (Which releases radiation damage), let's make a fake that drops the same stuff
]]

--[[
minetest.register_node( ":technic:mineral_uranium", {
	description = S("Uranium Ore"),
	tiles = { "default_stone.png^technic_mineral_uranium.png" },
	is_ground_content = true,
	groups = {cracky=3, radioactive=1},
	sounds = default.node_sound_stone_defaults(),
	drop = "technic:uranium_lump",
})
]]

if oreveins.GAMEMODE == "MTG" then
    local default = rawget(_G, "default") or nil
    -- Not radioactive, thus safer
    minetest.register_node("oreveins:uranium_ore", {
        description = oreveins.S("Uranium Ore"),
        tiles = { "oreveins_stone.png^oreveins_uranium.png" },
        is_ground_content = true,
        groups = {cracky=3},
        sounds = default.node_sound_stone_defaults(),
        drop = "technic:uranium_lump"
    })
end
