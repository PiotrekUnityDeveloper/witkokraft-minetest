--[[

xmaps – Minetest mod that adds map items that show terrain in HUD
Copyright © 2022  Nils Dagsson Moskopp (erlehmann)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

Dieses Programm hat das Ziel, die Medienkompetenz der Leser zu
steigern. Gelegentlich packe ich sogar einen handfesten Buffer
Overflow oder eine Format String Vulnerability zwischen die anderen
Codezeilen und schreibe das auch nicht dran.

]]--

-- blit an icon into the image unless its rect overlaps pixels that
-- have any of the stop_colors, treating a nil pixel as transparent
function tga_encoder.image:blit_icon(icon, pos, stop_colors)
	local x = pos.x
	local z = pos.z
	local overlap = false
	for i_z = 1,#icon do
		for i_x = 1,#icon[i_z] do
			local color = self.pixels[z + i_z][x + i_x][1]
			if stop_colors[color] then
				overlap = true
				break
			end
		end
		if overlap then
			break
		end
	end
	if overlap then
		return
	end
	for i_z = 1,#icon do
		for i_x = 1,#icon[i_z] do
			local color = icon[i_z][i_x][1]
			if color then
				self.pixels[z + i_z][x + i_x] = { color }
			end
		end
	end
end

xmaps = {}

xmaps.dark = {} -- key: player name; value: is it dark?
xmaps.huds = {} -- key: player name; value: player huds
xmaps.maps = {} -- key: player name; value: map texture
xmaps.mark = {} -- key: player name; value: marker texture
xmaps.marx = {} -- key: player name; value: marker x offset
xmaps.mary = {} -- key: player name; value: marker y offset

xmaps.load = {} -- maps loaded by players
xmaps.sent = {} -- maps sent to players
xmaps.work = {} -- maps being created

local size = 80

local worldpath = minetest.get_worldpath()
local textures_dir = worldpath .. "/xmaps/"
minetest.mkdir(textures_dir)

xmaps.get_map_filename = function(map_id)
	return "xmaps_map_texture_" .. map_id .. ".tga"
end

xmaps.create_map_item = function(pos, properties)
	properties = properties or {}

	local itemstack = ItemStack("xmaps:map")
	local meta = itemstack:get_meta()

	local map_id = tostring(os.time() + math.random())
	meta:set_string("xmaps:id", map_id)

	local minp = vector.multiply(vector.floor(vector.divide(pos, size)), size)
	meta:set_string("xmaps:minp", minetest.pos_to_string(minp))

	local maxp = vector.add(minp, vector.new(size - 1, size - 1, size - 1))
	meta:set_string("xmaps:maxp", minetest.pos_to_string(maxp))

	if properties.draw_x then
		local xpos = vector.round(pos)
		meta:set_string("xmaps:xpos", minetest.pos_to_string(xpos))
	end

	local filename = xmaps.get_map_filename(map_id)
	xmaps.work[map_id] = true

	local emerge_callback = function(
		blockpos,
		action,
		calls_remaining
	)
		if calls_remaining > 0 then
			return
		end

		local pixels = {}
		local colormap = {
			{ 195, 175, 140 }, -- background checkerboard light
			{ 180, 160, 125 }, -- background checkerboard dark
			{  60,  35,  16 }, -- dark line
			{ 210, 170, 130 }, -- liquid light
			{ 135,  90,  40 }, -- liquid dark
			{ 150, 105,  55 }, -- more liquid
			{ 165, 120,  70 }, -- more liquid
			{ 150, 105,  55 }, -- more liquid
			{  60,  35,  16 }, -- tree outline
			{ 150, 105,  55 }, -- tree fill
		}
		for x = 1,size,1 do
			for z = 1,size,1 do
				local color = 0 + ( ( x + z ) % 2 )
				pixels[z] = pixels[z] or {}
				pixels[z][x] = { color }
			end
		end

		local positions = minetest.find_nodes_in_area_under_air(
			minp,
			maxp,
			"group:liquid"
		)
		for _, p in ipairs(positions) do
			if 14 == minetest.get_node_light(p, 0.5) then
				local z = p.z - minp.z + 1
				local x = p.x - minp.x + 1
				pixels[z][x] = { 3 }
			end
		end

		-- draw coastline
		for x = 1,size,1 do
			for z = 1,size,1 do
				if pixels[z][x][1] >= 3 then
					pixels[z][x] = { 3 + ( z % 2 ) } -- stripes
					if pixels[z][x][1] == 4 then
						local color = 4 + ( ( math.floor( x / 7 ) + math.floor( 1.3 * z * z ) ) % 4 )
						pixels[z][x] = { color }
					end
					if z > 1 and pixels[z-1][x][1] < 3 then
						pixels[z-1][x] = { 2 }
						pixels[z][x] = { 4 }
					end
					if z < size and pixels[z+1][x][1] < 3 then
						pixels[z+1][x] = { 2 }
						pixels[z][x] = { 4 }
					end
					if x > 1 and pixels[z][x-1][1] < 3 then
						pixels[z][x-1] = { 2 }
						pixels[z][x] = { 4 }
					end
					if x < size and pixels[z][x+1][1] < 3 then
						pixels[z][x+1] = { 2 }
						pixels[z][x] = { 4 }
					end
				end
			end
		end

		local image = tga_encoder.image(pixels)

		local positions = minetest.find_nodes_in_area(
			minp,
			maxp,
			"group:door"
		)
		for _, p in ipairs(positions) do
			local z = p.z - minp.z + 1
			local x = p.x - minp.x + 1
			local draw_house = (
				z > 1 and
				z < size - 7 and
				x > 4 and
				x < size - 4
			)
			if draw_house then
				local _ = { nil } -- transparent
				local O = { 8 } -- outline
				local F = { 9 } -- filling
				local house = {
					{ _, _, _, _, _, _, _ },
					{ _, O, O, O, O, O, _ },
					{ _, O, F, F, F, O, _ },
					{ _, O, F, F, F, O, _ },
					{ _, O, F, F, F, O, _ },
					{ _, _, O, F, O, _, _ },
					{ _, _, _, O, _, _, _ },
					{ _, _, _, _, _, _, _ },
				}
				image:blit_icon(
					house,
					{
						x = x - 5,
						z = z - 1,
					},
					{
						[4] = true,
						[5] = true,
						[6] = true,
						[7] = true,
						[8] = true,
						[9] = true,
					}
				)
			end
		end

		local positions = minetest.find_nodes_in_area_under_air(
			minp,
			maxp,
			{
				"group:leaves",
				"default:snow", -- snow-covered leaves
			}
		)
		for _, p in ipairs(positions) do
			local z = p.z - minp.z + 1
			local x = p.x - minp.x + 1
			local node = minetest.get_node({
				x=p.x,
				y=p.y - 4,
				z=p.z,
			})
			local draw_tree = (
				minetest.get_item_group(
				   node.name,
				   "tree"
			) > 0 ) and (
				z > 1 and
				z < size - 7 and
				x > 4 and
				x < size - 4
			)
			if draw_tree then
				local tree = {}
				local _ = { nil } -- transparent
				local O = { 8 } -- outline
				local F = { 9 } -- filling
				if nil ~= node.name:find("pine") then
					tree = {
						{ _, _, _, _, _, _, _ },
						{ _, _, _, O, _, _, _ },
						{ _, O, O, O, O, O, _ },
						{ _, O, F, F, F, O, _ },
						{ _, _, O, F, O, _, _ },
						{ _, _, O, F, O, _, _ },
						{ _, _, _, O, _, _, _ },
						{ _, _, _, _, _, _, _ },
					}
				else
					tree = {
						{ _, _, _, _, _, _, _ },
						{ _, _, _, O, _, _, _ },
						{ _, _, _, O, _, _, _ },
						{ _, _, O, O, O, _, _ },
						{ _, O, F, F, F, O, _ },
						{ _, O, F, F, F, O, _ },
						{ _, _, O, O, O, _, _ },
						{ _, _, _, _, _, _, _ },
					}
				end
				image:blit_icon(
					tree,
					{
						x = x - 4,
						z = z - 1,
					},
					{
						[4] = true,
						[5] = true,
						[6] = true,
						[7] = true,
						[8] = true,
						[9] = true,
					}
				)
			end
		end

		local positions = minetest.find_nodes_in_area_under_air(
			minp,
			maxp,
			"group:grass"
		)
		for _, p in ipairs(positions) do
			local z = p.z - minp.z + 1
			local x = p.x - minp.x + 1
			local draw_grass = (
				z > 1 and
				z < size - 4 and
				x > 4 and
				x < size - 4
			)
			if draw_grass then
				local _ = { nil } -- transparent
				local G = { 9 } -- line
				local grass = {
					{ _, _, _, _, _, _, _ },
					{ _, G, _, G, _, G, _ },
					{ _, G, _, G, _, G, _ },
					{ _, _, _, G, _, _, _ },
					{ _, _, _, _, _, _, _ },
				}
				image:blit_icon(
					grass,
					{
						x = x - 5,
						z = z - 1,
					},
					{
						[4] = true,
						[5] = true,
						[6] = true,
						[7] = true,
						[8] = true,
						[9] = true,
					}
				)
			end
		end

		local positions = minetest.find_nodes_in_area_under_air(
			minp,
			maxp,
			"group:flower"
		)
		for _, p in ipairs(positions) do
			local z = p.z - minp.z + 1
			local x = p.x - minp.x + 1
			local draw_flower = (
				z > 1 and
				z < size - 3 and
				x > 2 and
				x < size - 2
			)
			if draw_flower then
				local _ = { nil } -- transparent
				local F = { 9 } -- line
				local flower = {
					{ _, _, _, },
					{ _, F, _, },
					{ _, F, _, },
					{ _, _, _, },
				}
				image:blit_icon(
					flower,
					{
						x = x - 2,
						z = z - 1,
					},
					{
						[4] = true,
						[5] = true,
						[6] = true,
						[7] = true,
						[8] = true,
						[9] = true,
					}
				)
			end
		end

		local filepath = textures_dir .. filename
		image:save(
			filepath,
			{ colormap=colormap }
		)
		xmaps.work[map_id] = false
	end

	minetest.emerge_area(
		minp,
		maxp,
		emerge_callback
	)
	return itemstack
end

xmaps.load_map = function(map_id)
	assert( nil ~= map_id )
	if (
		"" == map_id or
		xmaps.work[map_id]
	) then
		return
	end

	local filename = xmaps.get_map_filename(map_id)

	if not xmaps.sent[map_id] then
		if not minetest.features.dynamic_add_media_table then
			-- minetest.dynamic_add_media() blocks in
			-- Minetest 5.3 and 5.4 until media loads
			minetest.dynamic_add_media(
				textures_dir .. filename,
				function() end
			)
			xmaps.load[map_id] = true
		else
			-- minetest.dynamic_add_media() never blocks
			-- in Minetest 5.5, callback runs after load
			minetest.dynamic_add_media(
				textures_dir .. filename,
				function()
					xmaps.load[map_id] = true
				end
			)
		end
		xmaps.sent[map_id] = true
	end

	if xmaps.load[map_id] then
		return filename
	end
end

xmaps.encode_map_item_meta = function(input)
	return minetest.encode_base64(
		minetest.compress(
			input,
			"deflate",
			9
		)
	)
end

xmaps.decode_map_item_meta = function(input)
	return minetest.decompress(
		minetest.decode_base64(input),
		"deflate",
		9
	)
end

result_original = "foo\0\01\02\x03\n\rbar"
result_roundtrip = xmaps.decode_map_item_meta(
	xmaps.encode_map_item_meta(result_original)
)
assert(
	result_original == result_roundtrip,
	"xmaps: mismatch between xmaps.encode_map_item_meta() and xmaps.decode_map_item_meta()"
)

xmaps.load_map_item = function(itemstack)
	local meta = itemstack:get_meta()
	local map_id = meta:get_string("xmaps:id")

	if (
	   not map_id or
	   "" == map_id or
	   xmaps.work[map_id]
	) then
		return
	end

	local texture_file_name = xmaps.get_map_filename(map_id)
	local texture_file_path = textures_dir .. texture_file_name

	-- does the texture file exist?
	local texture_file_handle_read = io.open(
	   texture_file_path,
	   "rb"
	)
	local texture_file_exists = true
	local texture_data_from_file
	if nil == texture_file_handle_read then
		texture_file_exists = false
	else
		texture_data_from_file = texture_file_handle_read:read("*a")
		texture_file_handle_read:close()
	end

	-- does the texture item meta exist?
	local tga_deflate_base64 = meta:get_string("xmaps:tga_deflate_base64")
	local texture_item_meta_exists = true
	if "" == tga_deflate_base64 then
		texture_item_meta_exists = false
	end

	if texture_file_exists and nil ~= texture_data_from_file then
		if texture_item_meta_exists then
			-- sanity check: do we have the same textures?
			-- if server-side texture has changed, take it
			if xmaps.decode_map_item_meta(tga_deflate_base64) ~= texture_data_from_file then
				minetest.log(
					"action",
					"xmaps: update item meta from file content for map " .. map_id
				)
				meta:set_string(
					"xmaps:tga_deflate_base64",
					xmaps.encode_map_item_meta(texture_data_from_file)
				)
			end
		else
			-- map items without meta should not exist, so
			-- we now write the file contents to item meta
			minetest.log(
				"action",
				"xmaps: create item meta from file content for map " .. map_id
			)
			meta:set_string(
				"xmaps:tga_deflate_base64",
				xmaps.encode_map_item_meta(texture_data_from_file)
			)
		end
	else
		-- no texture file → could be a world download
		-- so we look for missing texture in item meta
		-- and write that to the map texture file here
		if texture_item_meta_exists then
			minetest.log(
				"action",
				"xmaps: create file content from item meta for map " .. map_id
			)
			assert(
				minetest.safe_file_write(
					texture_file_path,
					xmaps.decode_map_item_meta(tga_deflate_base64)
				)
			)
		else
			minetest.log(
				"error",
				"no data for map " .. map_id
			)
			return
		end
	end

	local texture = xmaps.load_map(map_id)

	local meta_xpos = meta:get_string("xmaps:xpos")
	if texture and "" ~= meta_xpos then
		local meta_minp = meta:get_string("xmaps:minp")
		assert( "" ~= meta_minp )
		local minp = minetest.string_to_pos(meta_minp)

		local meta_maxp = meta:get_string("xmaps:maxp")
		assert( "" ~= meta_maxp )
		local maxp = minetest.string_to_pos(meta_maxp)

		local xpos = minetest.string_to_pos(meta_xpos)
		local x_x = xpos.x - minp.x - 4
		local x_z = maxp.z - xpos.z - 4
		local x_overlay = "^[combine:" ..
			size .. "x" .. size .. ":" ..
			x_x .. "," .. x_z .. "=xmaps_x.tga"
		texture = texture .. x_overlay
	end

	return texture, itemstack
end

minetest.register_on_joinplayer(
	function(player)
		local player_name = player:get_player_name()
		local map_def = {
			hud_elem_type = "image",
			text = "blank.png",
			position = { x = 0.15, y = 0.90 },
			alignment = { x = 0, y = -1 },
			offset = { x = 0, y = 0 },
			scale = { x = 4, y = 4 }
		}
		local pos_def = table.copy(map_def)
		xmaps.huds[player_name] = {
			map = player:hud_add(map_def),
			pos = player:hud_add(pos_def),
		}
	end
)

xmaps.show_map_hud = function(player)
	local wield_item = player:get_wielded_item()
	local texture, updated_wield_item = xmaps.load_map_item(wield_item)
	local player_pos = player:get_pos()
	local player_name = player:get_player_name()

	if not player_pos or not texture then
		if xmaps.maps[player_name] then
			player:hud_change(
				xmaps.huds[player_name].map,
				"text",
				"blank.png"
			)
			player:hud_change(
				xmaps.huds[player_name].pos,
				"text",
				"blank.png"
			)
			xmaps.maps[player_name] = nil
			xmaps.mark[player_name] = nil
		end
		return
	end

	if (
		texture ~= xmaps.maps[player_name] and
		updated_wield_item
	) then
		player:set_wielded_item(updated_wield_item)
	end

	local pos = vector.round(player_pos)
	local meta = wield_item:get_meta()

	local meta_minp = meta:get_string("xmaps:minp")
	assert( "" ~= meta_minp )
	local minp = minetest.string_to_pos(meta_minp)

	local meta_maxp = meta:get_string("xmaps:maxp")
	assert( "" ~= meta_maxp )
	local maxp = minetest.string_to_pos(meta_maxp)

	local light_level = minetest.get_node_light(pos) or 0
	local darkness = 255 - (light_level * 17)
	local light_level_overlay = "^[colorize:black:" .. darkness
	if (
		texture ~= xmaps.maps[player_name] or
		darkness ~= xmaps.dark[player_name]
	) then
		player:hud_change(
			xmaps.huds[player_name].map,
			"text",
			texture .. light_level_overlay
		)
		xmaps.maps[player_name] = texture
	end

	local marker
	local dot_large = "xmaps_dot_large.tga" .. "^[makealpha:1,1,1"
	local dot_small = "xmaps_dot_small.tga" .. "^[makealpha:1,1,1"
	local dot_tiny = "xmaps_dot_tiny.tga" .. "^[makealpha:1,1,1"

	if pos.x < minp.x then
		if minp.x - pos.x < size * 2 then
			marker = dot_large
		elseif minp.x - pos.x < size * 4 then
			marker = dot_small
		else
			marker = dot_tiny
		end
		pos.x = minp.x
	elseif pos.x > maxp.x then
		if pos.x - maxp.x < size * 2 then
			marker = dot_large
		elseif pos.x - maxp.x < size * 4 then
			marker = dot_small
		else
			marker = dot_tiny
		end
		pos.x = maxp.x
	end

	-- we never override a smaller marker
	-- yes, this is a literal corner case
	if pos.z < minp.z then
		if (
			minp.z - pos.z < size * 2 and
			marker ~= dot_small and
			marker ~= dot_tiny
		) then
			marker = dot_large
		elseif (
			minp.z - pos.z < size * 4 and
			marker ~= dot_tiny
		) then
			marker = dot_small
		else
			marker = dot_tiny
		end
		pos.z = minp.z
	elseif pos.z > maxp.z then
		if (
			pos.z - maxp.z < size * 2 and
			marker ~= dot_small and
			marker ~= dot_tiny
		) then
			marker = dot_large
		elseif (
			pos.z - maxp.z < size * 4 and
			marker ~= dot_tiny
		) then
			marker = dot_small
		else
			marker = dot_tiny
		end
		pos.z = maxp.z
	end

	if nil == marker then
		local yaw = (
			math.floor(
				player:get_look_horizontal()
				* 180 / math.pi / 45 + 0.5
			) % 8
		) * 45
		if (
			yaw == 0 or
			yaw == 90 or
			yaw == 180 or
			yaw == 270
		) then
			marker = "xmaps_arrow.tga" ..
				"^[makealpha:1,1,1" ..
				"^[transformR" ..
				yaw
		elseif (
			yaw == 45 or
			yaw == 135 or
			yaw == 225 or
			yaw == 315
		) then
			marker = "xmaps_arrow_diagonal.tga" ..
				"^[makealpha:1,1,1" ..
				"^[transformR" ..
				(yaw - 45)
		end
	end

	if marker and (
		marker ~= xmaps.mark[player_name] or
		darkness ~= xmaps.dark[player_name]
	) then
		player:hud_change(
			xmaps.huds[player_name].pos,
			"text",
			marker .. light_level_overlay
		)
		xmaps.mark[player_name] = marker
	end

	local marker_x = (pos.x - minp.x - (size/2)) * 4
	local marker_y = (maxp.z - pos.z - size + 3) * 4
	if (
		marker_x ~= xmaps.marx[player_name] or
		marker_y ~= xmaps.mary[player_name]
	) then
		player:hud_change(
			xmaps.huds[player_name].pos,
			"offset",
			{
				x = marker_x,
				y = marker_y,
			}
		)
		xmaps.marx[player_name] = marker_x
		xmaps.mary[player_name] = marker_y
	end

	xmaps.dark[player_name] = darkness
end

local time_elapsed = 0

minetest.register_globalstep(
	function(dtime)
		time_elapsed = time_elapsed + dtime
		if time_elapsed < ( 1 / 30 ) then
			return -- fps limiter
		end
		local players = minetest.get_connected_players()
		for _, player in pairs(players) do
			xmaps.show_map_hud(player)
		end
	end
)

minetest.register_entity(
	"xmaps:map",
	{
		visual = "upright_sprite",
		visual_size = { x = 1, y = 1 },
		physical = false,
		collide_with_objects = false,
		textures = { "xmaps_map.tga" },
		on_activate = function(self, staticdata)
			if (
				staticdata and
				"" ~= staticdata
			) then
				local data = minetest.deserialize(staticdata)
				if not data then
					return
				end

				self._wallmounted = data._wallmounted
				assert( self._wallmounted )

				self._itemstring = data._itemstring
				assert( self._itemstring )

				local min, max = -8/16, 8/16
				local len = 1/64
				local sbox
				if 2 == self._wallmounted then
					sbox = { -len, min, min, len, max, max }
				elseif 3 == self._wallmounted then
					sbox = { -len, min, min, len, max, max }
				elseif 4 == self._wallmounted then
					sbox = { min, min, -len, max, max, len }
				elseif 5 == self._wallmounted then
					sbox = { min, min, -len, max, max, len }
				end
				assert( sbox )

				self.object:set_properties({
				      selectionbox = sbox,
				      textures = { "blank.png" },
				})

				local yaw = minetest.dir_to_yaw(
					minetest.wallmounted_to_dir(
						self._wallmounted
					)
				)
				self.object:set_yaw(yaw)
			end
		end,
		on_step = function(self)
			if self._texture then
				return
			end
			local itemstack = ItemStack(self._itemstring)
			self._texture, itemstack = xmaps.load_map_item(itemstack)
			self._itemstring = itemstack:to_string()
			self.object:set_properties({
				textures = { self._texture }
			})
		end,
		get_staticdata = function(self)
			return minetest.serialize(
				{
					_wallmounted = self._wallmounted,
					_itemstring = self._itemstring,
				}
			)
		end,
		on_punch = function(self)
			-- TODO: implement protection
			local pos = self.object:get_pos()
			local itemstring = self._itemstring
			if pos and itemstring then
				minetest.add_item(
					pos,
					itemstring
				)
				self.object:remove()
			end
		end
	}
)

minetest.register_craftitem(
	"xmaps:map",
	{
		description = "Map",
		inventory_image = "xmaps_map.tga",
		groups = { not_in_creative_inventory = 1 },
		on_place = function(itemstack, player, pointed_thing)
			if "node" ~= pointed_thing.type then
				return
			end

			local player_pos = player:get_pos()
			if not player_pos then
				return
			end

			local node_pos = pointed_thing.under

			local direction = vector.normalize(
				vector.subtract(
					node_pos,
					player_pos
				)
			)
			local wallmounted = minetest.dir_to_wallmounted(
				direction
			)

			-- TODO: implement maps on floor or ceiling
			if wallmounted < 2 then
				return
			end

			direction = minetest.wallmounted_to_dir(
				wallmounted
			)
			local pos = vector.subtract(
				node_pos,
				vector.multiply(
					direction,
					1/2 + 1/256 -- avoid z-fighting
				)
			)
			local itemstring = itemstack:to_string()
			if pos and "" ~= itemstring then
				local staticdata = {
					_wallmounted = wallmounted,
					_itemstring = itemstring,
				}
				local obj = minetest.add_entity(
					pos,
					"xmaps:map",
					minetest.serialize(staticdata)
				)
				if obj then
					-- TODO: creative mode
					itemstack:take_item()
				end
			end
			return itemstack
		end
	}
)

if minetest.registered_items["map:mapping_kit"] then
	minetest.override_item(
		"map:mapping_kit",
		{
			on_place = function(itemstack, player, pointed_thing)
				local pos = pointed_thing.under
				if pos then
					local map = xmaps.create_map_item(
						pos,
						{ draw_x = true }
					)
					return map
				end
			end,
			on_secondary_use = function(itemstack, player, pointed_thing)
				local pos = player:get_pos()
				if pos then
					local map = xmaps.create_map_item(pos)
					return map
				end
			end,
		}
	)
end
