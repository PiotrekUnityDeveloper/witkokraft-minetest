
-- The new register given id for orevein, nodelist containing itemstring and size and speed (Excluding upgrades)
oreveins.register_orevein = function(id, node_list, default_size, default_speed)
    -- Ensure it's a valid node
    for indx, val in ipairs(node_list) do
        if minetest.registered_nodes[val] == nil then
            return {success=false, errmsg="Invalid node '"..tostring(val).."'."}
        end
    end
    -- Add it or Update it
    if oreveins.tools.contains(id, ":") then
        id = oreveins.tools.split(id, ":")[2]
    end
    oreveins._internal.oreos[id] = {}
    oreveins._internal.oreos[id]["nodes"] = node_list
    oreveins._internal.oreos[id]["size"] = default_size or 1
    oreveins._internal.oreos[id]["speed"] = default_speed or 10
    -- Return all good
    return {success=true, errmsg=""}
end
