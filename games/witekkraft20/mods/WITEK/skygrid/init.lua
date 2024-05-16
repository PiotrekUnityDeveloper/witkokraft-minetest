local list_of_nodes = {}
minetest.register_on_mods_loaded(function() -- Delay until all nodes are registered (mod loading complete)
	for name, def in pairs(minetest.registered_nodes) do
		if def
		and def.groups									-- Exclude nodes without a group, which usually means indestructible ones
		and def.groups.not_in_creative_inventory ~= 1	-- Exclude technical blocks.
		and def.groups.liquid == nil					-- This probably makes liquids unobtainable, but they update too easily and create massive messes.
		and not string.match(def.name, "stair")			-- Exclude stairs because it's a bit boring just having stair variants of nodes everywhere.
		and not string.match(def.name, "slab")			--		Same thing.
		and not string.match(def.name, "fence")			--		Same thing.
		and not string.match(def.name, "bed")			-- Tends to create a lot of ugly half-beds
		and not string.match(def.name, "door")			-- Exclude doors, but also fence gates and whatnot... Hopefully.
		then
			table.insert(list_of_nodes, name)
		end
	end
end)

-- Graciously borrowed from NodeCore
-- https://gitlab.com/sztest/nodecore/-/blob/master/mods/nc_api/util_misc.lua#L106-120
function seeded_rng(seed)
	seed = math.floor((seed - math.floor(seed)) * 2 ^ 32 - 2 ^ 31)
	local pcg = PcgRandom(seed)
	return function(a, b)
		if b then
			return pcg:next(a, b)
		elseif a then
			return pcg:next(1, a)
		end
		return (pcg:next() + 2 ^ 31) / 2 ^ 32
	end
end

local mapperlin
minetest.after(0, function()
	mapperlin = minetest.get_perlin(0, 1, 0, 1)
end)

local rng
local data = {}

if minetest.get_mapgen_setting('mg_name') == "singlenode" then
	minetest.register_on_generated(function(minp, maxp, blockseed)
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local area = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
		vm:get_data(data)

		local rng = seeded_rng(mapperlin:get_3d(minp))

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do
					if (x % 3 == 0) and (y % 4 == 0) and (z % 3 == 0) then
						data[area:index(x, y, z)] = minetest.get_content_id(list_of_nodes[rng(1, #list_of_nodes)])
					end
				end
			end
		end

		vm:set_data(data)
		vm:write_to_map()
	end)
else
	minetest.log("warning", "[skygrid] Skygrid mod enabled, but not singlenode mapgen. Please disable this mod.")
end

minetest.register_on_newplayer(function(player)
	player:set_velocity({ x = 0, y = 0, z = 0 })
	player:set_pos({ x = 0, y = 0, z = 0 })
end)
