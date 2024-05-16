
-- Adds a node to track, only if that node actually is a valid node
xray.add_node = function(nodename)
    if minetest.registered_nodes[nodename] then
        table.insert(xray.nodes, nodename)
    else
        minetest.log("action", "[oretracker-xray] Failed to add '"..nodename.."' as it is a unregistered node.")
    end
end

-- Swaps with one of the registered nodes that has the invisiblity factor
xray.add_pos = function(pname, pos)
    local current = minetest.get_node_or_nil(pos)
    if current == nil then
        minetest.log("action", "[oretracker-xray] Failed to obtain node at "..minetest.pos_to_string(pos).." for swap.")
    end
    current = current.name
    --minetest.log("action", "[oretracker-xray] Swapping "..current)
    local nps = xray.store[pname] or {}
    table.insert(nps, pos)
    -- Place a switch here to identify which kind of node would be best used here
    if current == "default:stone" then -- Returns cobble rather than itself!
        minetest.swap_node(pos, {name="xray:mtg_stone"})
        xray.store[pname] = nps
    elseif current == "mcl_core:stone" then -- Returns cobble rather than itself!
        minetest.swap_node(pos, {name="xray:mcl_stone"})
        xray.store[pname] = nps
    else
        -- Fix this so we can auto determine what to replace it with
        for _, n in ipairs(xray.nodes) do
            if string.sub(n, 0, 4) == "xray" then
                local nod = ItemStack(n.." 1"):get_definition()
                if nod.drop == current then
                    --minetest.log("action", "[oretracker-xray] Located '"..n.."' for replacement.")
                    minetest.swap_node(pos, {name=n})
                    xray.store[pname] = nps
                    break
                else
                    --minetest.log("action", "[oretracker-xray] '"..n.."' is not our current it's drop is '"..nod.drop.."'.")
                end
            end
        end
    end
    --[[
    if current == "default:stone" then
        minetest.swap_node(pos, {name="xray:mtg_stone"})
    elseif current == "default:desert_stone" then
        minetest.swap_node(pos, {name="xray:mtg_dstone"})
    elseif current == "default:sandstone" then
        minetest.swap_node(pos, {name="xray:mtg_sstone"})
    elseif current == "default:desert_sandstone" then
        minetest.swap_node(pos, {name="xray:mtg_dsstone"})
    elseif current == "default:silver_sandstone" then
        minetest.swap_node(pos, {name="xray:mtg_ssstone"})
    elseif current == "mcl_core:stone" then
        minetest.swap_node(pos, {name="xray:mcl_stone"})
    elseif current == "mcl_core:granite" then
        minetest.swap_node(pos, {name="xray:mcl_granite"})
    elseif current == "mcl_core:andesite" then
        minetest.swap_node(pos, {name="xray:mcl_andesite"})
    elseif current == "mcl_core:diorite" then
        minetest.swap_node(pos, {name="xray:mcl_diorite"})
    elseif current == "mcl_core:sandstone" then
        minetest.swap_node(pos, {name="xray:mcl_sstone"})
    elseif current == "mcl_core:redsandstone" then
        minetest.swap_node(pos, {name="xray:mcl_rsstone"})
    elseif current == "mcl_blackstone:blackstone" then
        minetest.swap_node(pos, {name="xray:mcl_bstone"})
    elseif current == "mcl_blackstone:basalt" then
        minetest.swap_node(pos, {name="xray:mcl_basalt"})
    elseif current == "mcl_nether:netherrack" then
        minetest.swap_node(pos, {name="xray:mcl_netherrack"})
    elseif current == "mcl_deepslate:deepslate" then
        minetest.swap_node(pos, {name="xray:mcl_deepslate"})
    elseif current == "nc_terrain:stone" then
        minetest.swap_node(pos, {name="xray:nc_stone"})
    end
    ]]
end

-- Clears all invisible nodes back to their originals (per player)
-- Not really needed since the nodes themselves will reset automagically
xray.clear_pos = function(pname)
    --local player = minetest.get_player_by_name(pname)
    local wps = xray.store[pname] or {}
    for i, v in ipairs(wps) do
        local node = minetest.get_node_or_nil(v)
        if node == nil then
            minetest.log("action", "[oretracker-xray] Failed to obtain node at "..minetest.pos_to_string(v).." for revert ("..i..")")
        end
        node = node.name
        --minetest.log("action", "[oretracker-xray] Reverting "..current)
        -- Place a switch here to identify what node should be put back here
        if node == "xray:mtg_stone" then -- Returns cobble rather than itself!
            minetest.swap_node(v, {name="default:stone"})
        elseif node == "xray:mcl_stone" then -- Returns cobble rather than itself!
            minetest.swap_node(v, {name="mcl_core:stone"})
        else
            -- Fix this so we can auto determine what to replace it with
            for _, n in ipairs(xray.nodes) do
                if string.sub(n, 0, 4) == "xray" then
                    local nod = ItemStack(n.." 1"):get_definition()
                    if n == node then
                        --minetest.log("action", "[oretracker-xray] Located '"..n.."' for replacement.")
                        minetest.swap_node(v, {name=nod.drop})
                    else
                        --minetest.log("action", "[oretracker-xray] '"..n.."' is not our current it's drop is '"..nod.drop.."'.")
                    end
                end
            end
        end
        --[[
        if node == "xray:mtg_stone" then
            minetest.swap_node(v, {name="default:stone"})
        elseif node == "xray:mtg_dstone" then
            minetest.swap_node(v, {name="default:desert_stone"})
        elseif node == "xray:mtg_sstone" then
            minetest.swap_node(v, {name="default:sandstone"})
        elseif node == "xray:mtg_dsstone" then
            minetest.swap_node(v, {name="default:desert_sandstone"})
        elseif node == "xray:mtg_ssstone" then
            minetest.swap_node(v, {name="default:silver_sandstone"})
        elseif node == "xray:mcl_stone" then
            minetest.swap_node(v, {name="mcl_core:stone"})
        elseif node == "xray:mcl_granite" then
            minetest.swap_node(v, {name="mcl_core:granite"})
        elseif node == "xray:mcl_andesite" then
            minetest.swap_node(v, {name="mcl_core:andesite"})
        elseif node == "xray:mcl_diorite" then
            minetest.swap_node(v, {name="mcl_core:diorite"})
        elseif node == "xray:mcl_sstone" then
            minetest.swap_node(v, {name="mcl_core:sandstone"})
        elseif node == "xray:mcl_rsstone" then
            minetest.swap_node(v, {name="mcl_core:redsandstone"})
        elseif node == "xray:mcl_bstone" then
            minetest.swap_node(v, {name="mcl_blackstone:blackstone"})
        elseif node == "xray:mcl_basalt" then
            minetest.swap_node(v, {name="mcl_blackstone:basalt"})
        elseif node == "xray:mcl_netherrack" then
            minetest.swap_node(v, {name="mcl_nether:netherrack"})
        elseif node == "xray:mcl_deepslate" then
            minetest.swap_node(v, {name="mcl_deepslate:deepslate"})
        elseif node == "xray:nc_stone" then
            minetest.swap_node(v, {name="nc_terrain:stone"})
        end
        ]]
    end
    xray.store[pname] = {}
end

-- Attempt to repair the damage to this node (In the process of development I found my system made a ball of unrepairable goo, invisible blocks)
-- Not really needed since the nodes themselves will reset automagically
xray.fix_pos = function (pos)
    local node = minetest.get_node_or_nil(pos)
    if node == nil then
        minetest.log("action", "[oretracker-xray] Failed to obtain node at "..minetest.pos_to_string(pos).." for revert (fix_pos)")
    end
    node = node.name
    -- Place a switch here to identify what node should be put back here
    if node == "xray:mtg_stone" then -- Returns cobble rather than itself!
        minetest.swap_node(v, {name="default:stone"})
    elseif node == "xray:mcl_stone" then -- Returns cobble rather than itself!
        minetest.swap_node(v, {name="mcl_core:stone"})
    else
        -- Fix this so we can auto determine what to replace it with
        for _, n in ipairs(xray.nodes) do
            if string.sub(n, 0, 4) == "xray" then
                local nod = ItemStack(n.." 1"):get_definition()
                if n == node then
                    --minetest.log("action", "[oretracker-xray] Located '"..n.."' for replacement.")
                    minetest.swap_node(pos, {name=nod.drop})
                else
                    --minetest.log("action", "[oretracker-xray] '"..n.."' is not our current it's drop is '"..nod.drop.."'.")
                end
            end
        end
    end
    --[[
    -- Fix this so we can auto determine what to replace it with
    if node == "xray:mtg_stone" then
        minetest.swap_node(pos, {name="default:stone"})
    elseif node == "xray:mtg_dstone" then
        minetest.swap_node(pos, {name="default:desert_stone"})
    elseif node == "xray:mtg_sstone" then
        minetest.swap_node(pos, {name="default:sandstone"})
    elseif node == "xray:mtg_dsstone" then
        minetest.swap_node(pos, {name="default:desert_sandstone"})
    elseif node == "xray:mtg_ssstone" then
        minetest.swap_node(pos, {name="default:silver_sandstone"})
    elseif node == "xray:mcl_stone" then
        minetest.swap_node(pos, {name="mcl_core:stone"})
    elseif node == "xray:mcl_granite" then
        minetest.swap_node(pos, {name="mcl_core:granite"})
    elseif node == "xray:mcl_andesite" then
        minetest.swap_node(pos, {name="mcl_core:andesite"})
    elseif node == "xray:mcl_diorite" then
        minetest.swap_node(pos, {name="mcl_core:diorite"})
    elseif node == "xray:mcl_sstone" then
        minetest.swap_node(pos, {name="mcl_core:sandstone"})
    elseif node == "xray:mcl_rsstone" then
        minetest.swap_node(pos, {name="mcl_core:redsandstone"})
    elseif node == "xray:mcl_bstone" then
        minetest.swap_node(pos, {name="mcl_blackstone:blackstone"})
    elseif node == "xray:mcl_basalt" then
        minetest.swap_node(pos, {name="mcl_blackstone:basalt"})
    elseif node == "xray:mcl_netherrack" then
        minetest.swap_node(pos, {name="mcl_nether:netherrack"})
    elseif node == "xray:mcl_deepslate" then
        minetest.swap_node(pos, {name="mcl_deepslate:deepslate"})
    elseif node == "xray:nc_stone" then
        minetest.swap_node(pos, {name="nc_terrain:stone"})
    end
    ]]
end