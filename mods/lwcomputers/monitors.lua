local lwcomp = ...
local S = lwcomp.S



if lwcomp.digilines_supported then



local function formatCharater (ascii, fg, bg)
	ascii = tonumber (ascii or 0) % 256
	fg = tonumber (fg or 15) % 16
	bg = tonumber (bg or 15) % 16

	return ((fg * 4096) + (bg * 256) + ascii)
end



local function unformatCharacter (character)
	local colors, ascii = math.modf ((character or 0) / 256)
	local fg, bg = math.modf (colors / 16)

	return (ascii * 256), fg, (bg * 16)
end



lwcomputers.format_character = formatCharater
lwcomputers.unformat_character = unformatCharacter



-- scale  0.3  0.6   1    2     3     4     5
--        3x2  6x4  9x6 18x12 27x18 36x24 45x30



local function fixScale (scale)
	local s = string.format ("%0.1f", scale)

	if s == "0.3" then
		return 30
	elseif s == "0.6" then
		return 60
	elseif s == "2.0" then
		return 2
	elseif s == "3.0" then
		return 3
	elseif s == "4.0" then
		return 4
	elseif s == "5.0" then
		return 5
	end

	return 1
end


local function getScaleResolution (scale)
	if scale == 30 then
		return 3, 2, 42
	elseif scale == 60 then
		return 6, 4, 84
	elseif scale == 2 then
		return 18, 12, 252
	elseif scale == 3 then
		return 27, 18, 378
	elseif scale == 4 then
		return 35, 24, 504
	elseif scale == 5 then
		return 45, 30, 630
	end

	return 9, 6, 126
end



-- this code is based on cheapie's digiscreen mod


local function removeEntity (pos)
	local entitiesNearby = minetest.get_objects_inside_radius (pos, 0.5)
	for _,i in pairs (entitiesNearby) do
		if i:get_luaentity () and i:get_luaentity ().name == "lwcomputers:monitorimage" then
			i:remove ()
		end
	end
end




local function generateTexture (pos, serdata, scale, color)
	--The data *should* always be valid, but it pays to double-check anyway
	-- due to how easily this could crash if something did go wrong
	if type (serdata) ~= "string" then
		minetest.log ("error",
						  "[lwcomputers:monitor] Serialized display data appears to be missing at "..
						  minetest.pos_to_string (pos, 0))

		return
	end

	local data = minetest.deserialize (serdata)
	if type (data) ~= "table" then
		minetest.log ("error", "[lwcomputers:monitor] Failed to deserialize display data at "..
									  minetest.pos_to_string (pos, 0))

		return
	end

	local sx, sy, sc = getScaleResolution (scale)

	local texture = string.format ("[combine:%dx%d", sc, sc)

	for y = 1, sy, 1 do
		if type (data[y]) ~= "table" then
			minetest.log ("error", "[lwcomputers:monitor] Invalid row "..y..
										  " at "..minetest.pos_to_string (pos, 0))
			return
		end

		local line = ""

		for x = 1, sx, 3 do
			local dline = data[y]
			local ascii1, fg1, bg1 = unformatCharacter (dline[x])
			local ascii2, fg2, bg2 = unformatCharacter (dline[x + 1])
			local ascii3, fg3, bg3 = unformatCharacter (dline[x + 2])

			line = line..
					string.format (":%d,%d=(%02d%02d.png\\^[verticalframe\\:256\\:%d)"..
										":%d,%d=(%02d%02d.png\\^[verticalframe\\:256\\:%d)"..
										":%d,%d=(%02d%02d.png\\^[verticalframe\\:256\\:%d)",
										(x - 1) * 14, (y - 1) * 21, fg1, bg1, ascii1,
										(x) * 14, (y - 1) * 21, fg2, bg2, ascii2,
										(x + 1) * 14, (y - 1) * 21, fg3, bg3, ascii3)
		end

		texture = texture..line
	end

	return texture
end



local function updateDisplay (pos)
	removeEntity (pos)
	local node = minetest.get_node (pos)
	local def = minetest.registered_nodes[node.name]
	local meta = minetest.get_meta (pos)
	local data = meta:get_string ("data")
	local scale = meta:get_int ("scale") or 1
	local color = meta:get_string ("color") or "sb"
	local entity = minetest.add_entity (pos, "lwcomputers:monitorimage")
	local fdir = minetest.facedir_to_dir (node.param2)
	local etex = "lwdspx.png"
	etex = generateTexture (pos, data, scale, color) or etex
	entity:set_properties ({ textures = { etex } })
	entity:set_yaw ((fdir.x ~= 0) and math.pi / 2 or 0)
	entity:set_pos (vector.add (pos, vector.multiply (fdir, def._display_offset)))
end



minetest.register_entity ("lwcomputers:monitorimage", {
	initial_properties = {
		visual = "upright_sprite",
		physical = false,
		collisionbox = { 0, 0, 0, 0, 0, 0, },
		textures = { "lwdspx.png", },
	},
})



local function on_construct (pos)
	local meta = minetest.get_meta (pos)
	meta:set_string ("formspec", "field[channel;Channel;${channel}]")
	meta:set_int ("scale", 1)
	meta:set_string ("color", "sb")

	local disp = { }
	for y = 1, 6, 1 do
		disp[y] = { }

		for x = 1, 9, 1 do
			disp[y][x] = 0
		end
	end

	meta:set_string ("data", minetest.serialize (disp))
	updateDisplay (pos)
end



local function on_receive_fields (pos, formname, fields, sender)
	local name = sender:get_player_name ()

	if not fields.channel then
		return
	end

	if minetest.is_protected (pos, name) and
		not minetest.check_player_privs (name, "protection_bypass") then

		minetest.record_protection_violation (pos, name)

		return
	end

	local meta = minetest.get_meta (pos)
	meta:set_string ("channel", fields.channel)

	-- cancel after set for right clicks
	meta:set_string ("formspec", "")
end



local function on_rightclick (pos, node, clicker, itemstack, pointed_thing)
	local meta = minetest.get_meta (pos)
	local formspec = meta:get_string ("formspec")

	if formspec == "" then
		local hit = minetest.pointed_thing_to_face_pos(clicker, pointed_thing)
		local scale = meta:get_int ("scale")
		local hx = math.max (math.min (hit.x - pos.x + 0.5, 1), 0)
		local hz = math.max (math.min (hit.z - pos.z + 0.5, 1), 0)
		local hy = math.max (math.min (hit.y - pos.y + 0.5, 1), 0)
		local sx, sy = getScaleResolution (scale)
		local y = math.floor ((1 - hy) * sy)

		if node.param2 == 0 then
			if hit.z == (pos.z - 0.5) then
				local x = math.floor (hx * sx)

				digilines.receptor_send (pos,
												 digiline.rules.default,
												 meta:get_string ("channel"),
												 string.format ("touch:%d,%d", x, y))

			else
				meta:set_string ("formspec", "field[channel;Channel;${channel}]")
			end

		elseif node.param2 == 1 then
			if hit.x == (pos.x - 0.5) then
				local x = math.floor ((1 - hz) * sx)

				digilines.receptor_send (pos,
												 digiline.rules.default,
												 meta:get_string ("channel"),
												 string.format ("touch:%d,%d", x, y))

			else
				meta:set_string ("formspec", "field[channel;Channel;${channel}]")
			end

		elseif node.param2 == 2 then
			if hit.z == (pos.z + 0.5) then
				local x = math.floor ((1 - hx) * sx)

				digilines.receptor_send (pos,
												 digiline.rules.default,
												 meta:get_string ("channel"),
												 string.format ("touch:%d,%d", x, y))

			else
				meta:set_string ("formspec", "field[channel;Channel;${channel}]")
			end

		elseif node.param2 == 3 then
			if hit.x == (pos.x + 0.5) then
				local x = math.floor (hz * sx)

				digilines.receptor_send (pos,
												 digiline.rules.default,
												 meta:get_string ("channel"),
												 string.format ("touch:%d,%d", x, y))

			else
				meta:set_string ("formspec", "field[channel;Channel;${channel}]")
			end

		end
	end
end



local function effector_action (pos, node, channel, msg)
	local meta = minetest.get_meta (pos)
	local setchan = meta:get_string ("channel")

	if setchan ~= channel then
		return

	elseif type (msg) == "string" then
		if msg:sub (1, 6) == "scale:" then
			local scale = fixScale (tonumber (msg:sub (7, -1)) or 1)
			local old = minetest.deserialize (meta:get_string ("data") or "return { }")
			local sx, sy = getScaleResolution (scale)

			local data = { }
			for y = 1, sy, 1 do
				data[y] = { }

				if type(old[y]) ~= "table" then
					old[y] = { }
				end

				for x = 1, sx, 1 do
					data[y][x] = tonumber (old[y][x]) or 0
				end
			end

			meta:set_string ("data", minetest.serialize (data))
			meta:set_int ("scale", scale)

		elseif msg == "position" then
			digilines.receptor_send (pos,
											 digiline.rules.default,
											 setchan,
											 string.format ("position:%d,%d,%d", pos.x, pos.y, pos.z))

		else
			return

		end

	elseif type (msg) == "table" then
		local scale = meta:get_int ("scale")
		local sx, sy = getScaleResolution (scale)

		local data = { }
		for y = 1, sy, 1 do
			data[y] = { }

			if type(msg[y]) ~= "table" then
				msg[y] = { }
			end

			for x = 1, sx, 1 do
				data[y][x] = tonumber (msg[y][x]) or 0
			end
		end

		meta:set_string ("data", minetest.serialize (data))

	else
		return
	end

	updateDisplay (pos)
end



local function registerNode (name, description, box, display_offset)
	minetest.register_node (name, {
		description = description,
		tiles = { "lwcomputers_monitor.png", "lwcomputers_monitor.png", "lwcomputers_monitor.png",
					 "lwcomputers_monitor.png", "lwcomputers_monitor.png", "lwcomputers_monitor_face.png" },
		groups = { cracky = 2, oddly_breakable_by_hand = 2 },
		paramtype = "light",
		paramtype2 = "facedir",
		on_rotate = minetest.global_exists ("screwdriver") and screwdriver.rotate_simple,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = box,
		},
		_digistuff_channelcopier_fieldname = "channel",
		_display_offset = display_offset,

		on_construct = on_construct,

		on_destruct = removeEntity,

		on_receive_fields = on_receive_fields,

		on_rightclick = on_rightclick,

		digiline = {
			wire = {
				rules = digiline.rules.default,
			},

			effector = {
				action = effector_action,
			},
		},
	})
end



registerNode (
	"lwcomputers:monitor",
	S("Monitor Display"),
	{ -0.5, -0.5, -0.499, 0.5, 0.5, 0.5 },
	-0.5
)



minetest.register_lbm ({
	name = "lwcomputers:monitorrespawn",
	label = "Respawn lwcomputers monitor entities",
	nodenames = {
		"lwcomputers:monitor"
	},
	run_at_every_load = true,
	action = updateDisplay,
})



end
