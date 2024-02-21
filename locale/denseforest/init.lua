
minetest.register_node("denseforest:portal", {
    description = "Dense Forest Portal",
    drawtype = "nodebox",
    paramtype = "light",
    sunlight_propagates = true,
    light_source = minetest.LIGHT_MAX - 1,  -- Set the light level (less than max for soft light)
    light_source_color = {r = 255, g = 0, b = 255},  -- Set the color to purple
    groups = {unbreakable = 1, not_in_creative_inventory = 1, non_pistonable = 1, not_in_craft_guide = 1},
    is_ground_content = false,
    sounds = mcl_sounds.node_sound_stone_defaults(),
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- This defines a half-slab
    },
    tiles = {{
        name = "portal_animation.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1.0,
        },
    }},
    on_construct = function(pos)
        -- Add animation logic here if needed
    end,
    on_destruct = function(pos)
        -- Clean up any resources or effects if needed
    end,
    walkable = false,  -- Set to false to allow walking through the node
    diggable = false,  -- Set to false to prevent digging the node
    drop = "",        -- Empty string to ensure it doesn't drop anything when broken
})

-- Define your custom dimension ID
--local custom_dimension_id = minetest.get_content_id("mineclone:podzol")

-- Define your portal block ID
local portal_block_id = minetest.get_content_id("denseforest:portal")

minetest.register_abm({
    nodenames = {"mineclone:water_source", "mineclone:water_flowing", },
    neighbors = {"air", "air", "air", "air"},
    interval = 10,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
		--minetest.debug("hello")
        -- Check if there are water blocks in a 2x2 area
        local is_water_portal = true
        for i = 1, 4 do
			if i > 2 then
				local p = {x = pos.x + (i - 1), y = pos.y, z = 0}
				local n = minetest.get_node(p)
				if n.name ~= "mineclone:water_source" and n.name ~= "mineclone:water_flowing" then
					is_water_portal = false
					break
				end
			else
				local p = {x = pos.x + (i - 1), y = pos.y, z = 1}
				local n = minetest.get_node(p)
				if n.name ~= "mineclone:water_source" and n.name ~= "mineclone:water_flowing" then
					is_water_portal = false
					break
				end
			end
        end

        -- Check if there is podzol around the portal area
        local is_podzol_around = true
        for i = 1, 4 do
            local p = {x = pos.x + (i - 1) % 2, y = pos.y - 1, z = pos.z + math.floor((i - 1) / 2)}
            local n = minetest.get_node(p)
            if n.name ~= "mineclone:podzol" then
                is_podzol_around = false
                break
            end
        end
		
		minetest.debug("podzol: " .. tostring(is_podzol_around))
		minetest.debug("water: " .. tostring(is_water_portal))

        if is_water_portal and is_podzol_around then
            for i = 1, 4 do
                local p = {x = pos.x + (i - 1) % 2, y = pos.y, z = pos.z + math.floor((i - 1) / 2)}
                minetest.set_node(p, {name = "denseforest:portal_block"})
            end
        else
            for i = 1, 4 do
                local p = {x = pos.x + (i - 1) % 2, y = pos.y, z = pos.z + math.floor((i - 1) / 2)}
                local node = minetest.get_node(p)
                -- Check the node
                if node and node.name == "denseforest:portal" then
                    minetest.set_node(p, {name = "air"})
                end
            end
        end
    end,
})


-- Register an ABM to handle dimension transition when the player enters the portal
minetest.register_abm({
    nodenames = {"denseforest:portal"},
    interval = 1,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
        -- Check if a player is standing on the portal block
        local players = minetest.get_objects_inside_radius(pos, 1)
        for _, player in ipairs(players) do
            if player:is_player() then
                -- Teleport the player to the custom dimension
                --player:setpos({x = 0, y = 50, z = 0})
            end
        end
    end,
})




