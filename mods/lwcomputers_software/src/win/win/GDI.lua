local private = ...



local function printer_interface (channel)
	local interface = { }

	interface.cursor_x = 0
	interface.cursor_y = 0
	interface.fg = term.colors.black
	interface.bg = term.colors.white


	function interface.get_size ()
		return printer.query_size (channel)
	end


	function interface.get_cursor ()
		return interface.cursor_x, interface.cursor_y
	end


	function interface.set_cursor (x, y)
		interface.cursor_x = x
		interface.cursor_y = y

		printer.position (channel, x, y)
	end


	function interface.set_colors (fg, bg)
		if not fg then
			fg = interface.fg
		else
			fg = tonumber (fg) or term.colors.black
		end

		if fg > 15 or fg < 0 then
			fg = term.colors.black
		end

		if not bg then
			bg = interface.bg
		else
			bg = tonumber (bg) or term.colors.white
		end

		if bg > 15 or bg < 0 then
			bg = term.colors.white
		end

		interface.fg = fg
		interface.bg = bg

		printer.color (channel, fg, bg)
	end


	function interface.get_colors ()
		return interface.fg, interface.bg
	end


	function interface.get_paper_level ()
		return printer.query_paper (channel)
	end


	function interface.start_page (title, pageno)
		printer.start_page (channel, title, pageno)
	end


	function interface.end_page ()
		printer.end_page (channel)
	end


	function interface.get_ink_level ()
		return printer.query_ink (channel)
	end


	function interface.get_status ()
		return printer.query_status (channel)
	end


	function interface.write (text)
		printer.write (channel, text)
	end


	return interface
end



local function monitor_interface (width, channels)
	local interface = { }

	if type (channels) == "table" and #channels > 1 then
		interface = monitor.multi_interface (width, #channels / width, unpack (channels))
	else
		interface = monitor.interface (
			(type (channels) == "table" and tostring (channels[1])) or tostring (channels))
	end


	local old_set_blink = interface.set_blink
	local old_write = interface.write


	function interface.set_blink (blink)
		old_set_blink (blink, true)
	end


	function interface.write (text)
		old_write (text, false)
	end


	return interface
end



win.GDI = win.__classBase:base ()



-- device_type == "term", "monitor" or "printer", channels - string or list
function win.GDI:constructor (device_type, dir, wnd, width, channels)
	self.gdi__channel = nil
	self.gdi__device = nil
	self.gdi__device_type = device_type
	self.gdi__type = 0
	self.gdi__width = 0
	self.gdi__channels = { }
	self.gdi__wnd = wnd

	self.gdi__x_org = 0
	self.gdi__y_org = 0
	self.gdi__bounds = win.rect:new ()

	self.gdi__stored_cursor_x = nil
	self.gdi__stored_cursor_y = nil
	self.gdi__stored_bounds = nil
	self.gdi__stored_x_org = nil
	self.gdi__stored_y_org = nil
	self.gdi__stored_fg_color = nil
	self.gdi__stored_bg_color = nil
	self.gdi__stored_blink = nil

	if not self:set_device (device_type, dir, width, channels) then
		return nil
	end

	return self
end



function win.GDI:set_device (device_type, dir, width, channels)
	if device_type == "term" then
		self.gdi__type = private.GDI_TERM
		self.gdi__dir = "term"
		self.gdi__width = 0
		self.gdi__channels = channels

		if self.gdi__wnd and self.gdi__wnd:get_parent () then
			self.gdi__device = self.gdi__wnd:get_parent ().gdi.gdi__device
		else
			self.gdi__device = term
		end

	elseif device_type == "monitor" then
		self.gdi__type = private.GDI_MONITOR
		self.gdi__dir = dir
		self.gdi__width = width or 1
		self.gdi__channels = channels

		if self.gdi__wnd and self.gdi__wnd:get_parent () then
			self.gdi__device = self.gdi__wnd:get_parent ().gdi.gdi__device
		else
			self.gdi__device = monitor_interface (width, channels)
		end

	elseif device_type == "printer" then
		self.gdi__type = private.GDI_PRINTER
		self.gdi__dir = dir
		self.gdi__device = printer_interface (self.gdi__dir)
		self.gdi__width = 0
		self.gdi__channels = channels

	else
		return false

	end

	return true
end



function win.GDI:new_for_printer (channel)
	return win.GDI:new ("printer", channel, nil, 0, { channel })
end



function win.GDI:from_GDI (gdi, wnd)
	if not gdi then
		return false
	end

	return self:set_device (gdi.gdi__device_type, gdi.gdi__dir, wnd, gdi.gdi__width, gdi.gdi__channels)
end



function win.GDI:get_dir ()
	return self.gdi__dir
end



function win.GDI:get_org ()
	return self.gdi__x_org, self.gdi__y_org
end



function win.GDI:set_org (x, y)
	self.gdi__x_org = x
	self.gdi__y_org = y
end



function win.GDI:get_bounds (clear)
	local rt = win.rect:new (self.gdi__bounds:unpack ())

	if clear then
		self.gdi__bounds:empty ()
	end

	return rt
end



function win.GDI:add_bounds (rt)
	self.gdi__bounds:bound (rt)
end



function win.GDI:is_printer ()
	return (self.gdi__type == private.GDI_PRINTER)
end



function win.GDI:is_monitor ()
	return (self.gdi__type == private.GDI_MONITOR)
end



function win.GDI:is_term ()
	return (self.gdi__type == private.GDI_TERM)
end



function win.GDI:get_size ()
	if self:is_term () or self:is_monitor () then
		return self.gdi__device.get_resolution ()
	elseif self:is_printer () then
		return self.gdi__device.get_size ()
	end

	return 0, 0
end



function win.GDI:get_cursor ()
	return self.gdi__device.get_cursor ()
end



function win.GDI:set_cursor (x, y)
	self.gdi__device.set_cursor (x, y)
end



function win.GDI:set_blink (blink)
	if self:is_term () or self:is_monitor () then
		self.gdi__device.set_blink (blink)
	end
end



function win.GDI:get_blink ()
	if self:is_term () or self:is_monitor () then
		return self.gdi__device.get_blink ()
	end

	return false
end



function win.GDI:store ()
	if not self.gdi__stored_cursor_x or not self.gdi__stored_cursor_y then
		self.gdi__stored_cursor_x, self.gdi__stored_cursor_y = self:get_cursor ()
		self.gdi__stored_bounds = win.rect:new (self.gdi__bounds:unpack ())
		self.gdi__stored_x_org = self.gdi__x_org
		self.gdi__stored_y_org = self.gdi__y_org
		self.gdi__stored_fg_color, self.gdi__stored_bg_color = self:get_colors ()
		self.gdi__stored_blink = self:get_blink ()
	end
end



function win.GDI:restore ()
	if self.gdi__stored_cursor_x and self.gdi__stored_cursor_y then
		self:set_cursor (self.gdi__stored_cursor_x, self.gdi__stored_cursor_y)
		self.gdi__bounds = self.gdi__stored_bounds
		self:set_colors (self.gdi__stored_fg_color, self.gdi__stored_bg_color)
		self.gdi__x_org = self.gdi__stored_x_org
		self.gdi__y_org = self.gdi__stored_y_org
		self:set_blink (self.gdi__stored_blink)

		self.gdi__stored_cursor_x = nil
		self.gdi__stored_cursor_y = nil
		self.gdi__stored_bounds = nil
		self.gdi__stored_x_org = nil
		self.gdi__stored_y_org = nil
		self.gdi__stored_fg_color = nil
		self.gdi__stored_bg_color = nil
		self.gdi__stored_blink = nil
	end
end



function win.GDI:set_colors (fg, bg)
	self.gdi__device.set_colors (fg, bg)
end



function win.GDI:get_colors ()
	return self.gdi__device.get_colors ()
end



function win.GDI:set_scale (scale)
	if self:is_monitor () then
		self.gdi__device.set_scale (scale)
	end
end



function win.GDI:clear_wnd (x, y, width, height)
	local rt = win.rect:new (x, y, width, height)

	if self.gdi__wnd then
		rt:clip (win.rect:new (0, 0, self.gdi__wnd.width, self.gdi__wnd.height))
		rt:offset (self.gdi__wnd:wnd_to_screen (0, 0))

		if self.gdi__wnd:get_parent () then
			rt:clip (self.gdi__wnd:get_parent ():get_screen_rect())
		end
	end

	rt:offset (self:get_org ())
	rt:clip (win.rect:new (0, 0, self:get_size ()))

	if not rt:is_empty () then
		local blank = string.rep (" ", rt.width)

		for i = 0, rt.height - 1, 1 do
			self:set_cursor (rt.x, rt.y + i)
			self.gdi__device.write (blank)
		end

		self:add_bounds (rt)
	end
end



function win.GDI:write_wnd (text, x, y)
	local cx, cy = self:get_cursor ()

	local rt
	local txt = tostring (text or "")

	if txt:len () then
		if self.gdi__wnd then
			rt = win.rect:new (x, y, txt:len (), 1)

			if rt.x < 0 then
				txt = txt:sub ((rt.x * -1) + 1)
			end

			rt:clip (win.rect:new (0, 0, self.gdi__wnd.width, self.gdi__wnd.height))
			rt:offset (self.gdi__wnd:wnd_to_screen (0, 0))

			local screen_x = rt.x

			if self.gdi__wnd:get_parent () then
				rt:clip (self.gdi__wnd:get_parent ():get_screen_rect ())
			end

			if screen_x < rt.x then
				txt = txt:sub ((rt.x - screen_x) + 1)
			end
		else
			if x < 0 then
				txt = txt:sub ((x * -1) + 1)
				x = 0
			end

			rt = win.rect:new (x, y, txt:len (), 1)
		end

		rt:offset (self:get_org ())
		rt:clip (win.rect:new (0, 0, self:get_size ()))

		if not rt:is_empty () then
			if txt:len () > rt.width then
				txt = txt:sub (1, rt.width)
			end

			self:set_cursor (rt.x, rt.y)
			self.gdi__device.write (txt)

			self:add_bounds (rt)
		end
	end

	self:set_cursor (cx, cy)
end



function win.GDI:clear (x, y, width, height)
	local rt

	if self.gdi__wnd then
		rt = win.rect:new (x - self.gdi__wnd.wnd__scroll_x,
								 y - self.gdi__wnd.wnd__scroll_y,
								 width, height)
		rt:clip (win.rect:new (0, 0, self.gdi__wnd:get_client_size ()))
		rt:offset (self.gdi__wnd:wnd_to_screen (0, 0))

		if self.gdi__wnd:get_parent () then
			rt:clip(self.gdi__wnd:get_parent ():get_screen_rect ())
		end
	else
		rt = win.rect:new (x, y, width, height)
	end

	rt:offset (self:get_org ())
	rt:clip (win.rect:new (0, 0, self:get_size ()))

	if not rt:is_empty () then
		local blank = string.rep (" ", rt.width)

		for i = 0, rt.height - 1, 1 do
			self:set_cursor (rt.x, rt.y + i)
			self.gdi__device.write (blank)
		end

		self:add_bounds (rt)
	end
end



function win.GDI:write (text, x, y)
	local cx, cy = self:get_cursor ()

	local rt = nil
	local txt = tostring (text or "")

	if txt:len () then
		if self.gdi__wnd then
			rt = win.rect:new (x - self.gdi__wnd.wnd__scroll_x,
									 y - self.gdi__wnd.wnd__scroll_y,
									 txt:len (), 1)

			if rt.x < 0 then
				txt = txt:sub ((rt.x * -1) + 1)
			end

			rt:clip (win.rect:new (0, 0, self.gdi__wnd:get_client_size ()))

			rt:offset (self.gdi__wnd:wnd_to_screen (0, 0))

			local screen_x = rt.x

			if self.gdi__wnd:get_parent () then
				rt:clip (self.gdi__wnd:get_parent ():get_screen_rect ())
			end

			if screen_x < rt.x then
				txt = txt:sub ((rt.x - screen_x) + 1)
			end
		else
			rt = win.rect:new (x, y, txt:len(), 1)

			if rt.x < 0 then
				txt = txt:sub ((rt.x * -1) + 1)
			end
		end

		rt:offset (self:get_org ())
		rt:clip (win.rect:new (0, 0, self:get_size ()))

		if not rt:is_empty () then
			if txt:len() > rt.width then
				txt = txt:sub (1, rt.width)
			end

			self:set_cursor (rt.x, rt.y)
			self.gdi__device.write (txt)

			self:add_bounds (rt)
		end
	end

	self:set_cursor (cx, cy)
end



function win.GDI:set_pixel_wnd (x, y, color)
	self:set_colors (nil, color)
	self:write_wnd (" ", x, y)
end



function win.GDI:set_pixel (x, y, color)
	self:set_colors (nil, color)
	self:write (" ", x, y)
end



function win.GDI:get_paper_level ()
	if self:is_printer () then
		return self.gdi__device.get_paper_level ()
	end

	return nil
end



function win.GDI:start_page (title, pageno)
	if self:is_printer () then
		self.gdi__device.start_page (title, pageno)
	end
end



function win.GDI:end_page ()
	if self:is_printer () then
		self.gdi__device.end_page ()
	end
end



function win.GDI:get_ink_level ()
	if self:is_printer () then
		return self.gdi__device.get_ink_level ()
	end

	return nil
end



function win.GDI:get_page_size ()
	if self:is_printer () then
		return self.gdi__device.get_size ()
	end

	return nil
end



function win.GDI:get_status ()
	if self:is_printer () then
		return self.gdi__device.get_status ()
	end

	return nil
end



function win.GDI:update ()
	if self:is_monitor () then
		self.gdi__device.update ()
	end
end



function win.GDI:is_touch (channel, msg)
	if self:is_monitor () then
		return self.gdi__device.is_touch (channel, msg)
	end

	return nil
end
