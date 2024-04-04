local private = ...



win.window = win.__classBase:base ()



function win.window:constructor (parent, id, x, y, width, height)
	self.x = math.floor (tonumber (x) or 0)
	self.y = math.floor (tonumber (y) or 0)
	self.width = math.floor (tonumber (width) or 0)
	self.height = math.floor (tonumber (height) or 0)
	self.wnd__parent = nil
	self.wnd__owner = nil
	self.wnd__popup = nil
	self.wnd__frame_class = private.FRAME_CLASS_WINDOW
	self.wnd__id = tonumber (id) or 0
	self.wnd__color = term.colors.black
	self.wnd__bg_color = term.colors.white
	self.wnd__cursor_x = 0
	self.wnd__cursor_y = 0
	self.wnd__scroll_x = 0
	self.wnd__scroll_y = 0
	self.wnd__scroll_width = 0
	self.wnd__scroll_height = 0
	self.wnd__enabled = true
	self.wnd__hidden = false
	self.wnd__text = ""
	self.wnd__do_keyboard = true
	self.wnd__want_focus = true
	self.wnd__alive = true
	self.wnd__want_key_input = win.KEYINPUT_NONE
	self.gdi = nil
	self.wnd__nodes = { }
	self.wnd__invalid = win.rect:new ()

	self:set_parent (parent)

	return self
end



function win.window:invalidate (x, y, width, height)
	x = x or 0
	y = y or 0
	width = width or self.width
	height = height or self.height

	self.wnd__invalid:bound (win.rect:new (math.floor (x), math.floor (y),
									 math.floor (width), math.floor (height)))

	if self:get_parent () then
		local px, py = win.wnd_to_screen (self, self.wnd__invalid.x, self.wnd__invalid.y)
		px, py = win.screen_to_wnd (self:get_parent (), px, py)
		self:get_parent ():invalidate (px, py, self.wnd__invalid.width, self.wnd__invalid.height)
	end
end



function win.window:validate ()
	self.wnd__invalid = win.rect:new (0, 0, 0, 0)
end



function win.window:move (x, y, width, height, z)
	self:invalidate ()
	self:validate ()

	if x then
		self.x = math.floor (x)
	end

	if y then
		self.y = math.floor (y)
	end

	if width then
		self.width = math.floor (width)
	end

	if height then
		self.height = math.floor (height)
	end

	if z and self:get_parent () then
		local pos = self:get_parent ():child_index (self)
		local i = pos

		if i > 0 then
			if z == win.WND_TOP then
				pos = 1
			elseif z == win.WND_BOTTOM then
				pos = self:get_parent ():children ()
			else
				pos = pos + z
			end

			if pos < 1 then
				pos = 1
			elseif pos > self:get_parent ():children () then
				pos = self:get_parent ():children ()
			end

			table.insert (self:get_parent ().wnd__nodes, pos,
								table.remove (self:get_parent ().wnd__nodes, i))
		end
	end

	self:set_scroll_org (self:get_scroll_org ())
	self:invalidate ()

	local success, msg = pcall (self.on_move, self)
	if not success then
		win.syslog ("on_move "..msg)
	end
end



function win.window:get_GDI ()
	self.gdi:store ()

	return self.gdi
end



function win.window:release_GDI ()
	self.gdi:update ()
	self.gdi:restore ()
end



function win.window:set_id (id)
	self.wnd__id = tonumber (id) or 0
end



function win.window:get_id ()
	return self.wnd__id
end



function win.window:get_color ()
	return self.wnd__color
end



function win.window:set_color (color)
	self.wnd__color = tonumber (color) or term.colors.black
	self:invalidate ()
end



function win.window:get_bg_color ()
	return self.wnd__bg_color
end



function win.window:set_bg_color (color)
	self.wnd__bg_color = tonumber (color) or term.colors.white
	self:invalidate ()
end



function win.window:get_text ()
	return self.wnd__text
end



function win.window:set_text (text)
	self.wnd__text = tostring(text or "")
	self:invalidate ()
end



function win.window:get_want_focus ()
	return self.wnd__want_focus
end



function win.window:set_want_focus (want)
	self.wnd__want_focus = want
end



function win.window:get_want_key_input ()
	return self.wnd__want_key_input
end



function win.window:set_want_key_input (key_input)
	self.wnd__want_key_input = key_input
end



function win.window:set_suspend_keyboard (suspend)
	self.wnd__do_keyboard = suspend ~= true
end



function win.window:show (show)
	show = show ~= false

	if (not show) ~= self.wnd__hidden then
		if not show then
			if self:captured_mouse () == self then
				self:release_mouse ()
			end

			if self:get_focus () == self then
				local frame = self:get_parent_frame ()

				if frame then
					frame:set_focus_wnd (nil)
				end
			end
		end

		self.wnd__hidden = not show
		self:invalidate ()
	end
end



function win.window:is_shown ()
	if self.wnd__hidden then
		return false
	end

	if self:get_parent () then
		return self:get_parent ():is_shown ()
	end

	return true
end



function win.window:enable (enable)
	enable = enable ~= false

	if enable ~= self.wnd__enabled then
		if not enable then
			if self:captured_mouse () == self then
				self:release_mouse ()
			end

			if self:get_focus () == self then
				local frame = self:get_parent_frame ()

				if frame then
					frame:set_focus_wnd (nil)
				end
			end
		end

		self.wnd__enabled = enable
		self:invalidate ()
	end
end



function win.window:is_enabled ()
	if not self.wnd__enabled then
		return false
	end

	if self:get_parent () then
		return self:get_parent ():is_enabled ()
	end

	return true
end



function win.window:children ()
	return #self.wnd__nodes
end



function win.window:add_child (child)
	self.wnd__nodes[self:children () + 1] = child
end



function win.window:get_child (i)
	if i > 0 and i <= self:children () then
		return self.wnd__nodes[i]
	end

	return nil
end



function win.window:child_index (child)
	for i = 1, self:children (), 1 do
		if self.wnd__nodes[i] == child then
			return i
		end
	end

	return 0
end



function win.window:remove_child (child)
	local i = self:child_index (child)

	if i > 0 then
		table.remove(self.wnd__nodes, i)
		return true
	end

	return false
end



function win.window:get_parent ()
	return self.wnd__parent
end



function win.window:set_parent (parent)
	if parent then
		if parent:child_index (self) == 0 then
			if self.wnd__parent then
				self.wnd__parent:invalidate ()
				self.wnd__parent:remove_child (self)
			end

			self.wnd__parent = parent

			if not self.gdi then
				self.gdi = win.GDI:new (parent.gdi.gdi__device_type,
												parent.gdi.gdi__dir,
												self,
												parent.gdi.gdi__width,
												parent.gdi.gdi__channels)
			else
				self.gdi:from_GDI (parent.gdi, self)
			end

			parent:add_child (self)
			parent:invalidate ()
		end
	else
		if self.wnd__parent then
			self.wnd__parent:invalidate ()
			self.wnd__parent:remove_child (self)
			self.wnd__parent = nil
		end
	end
end



function win.window:destroy_wnd ()
	if self.wnd__alive then
		self.wnd__alive = false

		local success, msg = pcall (self.on_destroy_wnd, self)
		if not success then
			win.syslog ("on_destroy_wnd "..msg)
		end

		self:show (false)

		self:unwant_messages ()

		if self.wnd__popup then
			self.wnd__popup:destroy_wnd ()
		end

		if self.wnd__owner then
			self.wnd__owner.wnd__popup = nil
			self.wnd__owner:enable (true)
		end

		if self:captured_mouse () == self then
			self:release_mouse ()
		end

		if self:get_desktop () then
			if self:get_desktop ().dt__drag_wnd == self then
				self:get_desktop ().dt__drag_wnd = nil
			end
		end

		if self:get_focus () == self then
			local frame = self:get_parent_frame ()

			if frame then
				frame:set_focus_wnd (nil)
			end
		end

		self:get_workspace ():unwant_event (self, nil)
		self:get_workspace ():kill_timers (self)

		for i = self:children (), 1, -1 do
			local child = self:get_child (i)

			if child then
				child:destroy_wnd ()
			end
		end

		self:set_parent (nil)
	end
end



function win.window:get_workspace ()
	return private.workspace
end



function win.window:get_desktop ()
	return self:get_workspace ():get_desktop (self:get_dir ())
end



function win.window:get_parent_frame ()
	local parent = self:get_parent ()

	while parent do
		if parent.wnd__frame_class ~= private.FRAME_CLASS_WINDOW then
			return parent
		end

		parent = parent:get_parent ()
	end

	return nil
end



function win.window:get_app_frame ()
	local parent = self:get_parent ()
	local desktop = self:get_desktop ()

	if (self.wnd__frame_class == private.FRAME_CLASS_APPLICATION or
			self.wnd__frame_class == private.FRAME_CLASS_SYSTEM)
				and parent == desktop then
		return self
	end

	if self.wnd__owner then
		parent = self.wnd__owner
	end

	while parent do
		if (parent.wnd__frame_class == private.FRAME_CLASS_APPLICATION or
				parent.wnd__frame_class == private.FRAME_CLASS_SYSTEM)
					and parent:get_parent () == desktop then
			return parent
		end

		if parent.wnd__owner then
			parent = parent.wnd__owner
		else
			parent = parent:get_parent ()
		end
	end

	return nil
end



function win.window:get_theme ()
	if self:get_desktop () then
		return self:get_desktop ():get_theme ()
	end

	return private.defaultTheme
end



function win.window:get_colors ()
	return self:get_theme ().color
end



function win.window:get_dir ()
	if self.gdi then
		return self.gdi:get_dir ()
	end

	return ""
end



function win.window:has_scroll_bars ()
	local vert, horz, width, height =
					false, false, self.width, self.height

	if self.wnd__scroll_height > self.height then
		vert = true
		width = self.width - 1
	end

	if self.wnd__scroll_width > width then
		horz = true
		height = self.height - 1
	end

	vert = (self.wnd__scroll_height > height)

	return vert, horz
end



function win.window:get_client_size ()
	local vert, horz = self:has_scroll_bars ()
	local width, height = self.width, self.height

	if vert then
		width = self.width - 1
	end

	if horz then
		height = self.height - 1
	end

	return width, height
end



function win.window:get_scroll_org ()
	return self.wnd__scroll_x, self.wnd__scroll_y
end



function win.window:set_scroll_org (x, y)
	local width, height = self:get_client_size ()
	local tx, ty = x, y

	if (tx + width) > self.wnd__scroll_width then
		tx = self.wnd__scroll_width - width
	end

	if tx < 0 or self.wnd__scroll_width <= width then
		tx = 0
	end

	if (ty + height) > self.wnd__scroll_height then
		ty = self.wnd__scroll_height - height
	end

	if ty < 0 or self.wnd__scroll_height <= height then
		ty = 0
	end

	if tx ~= self.wnd__scroll_x or ty ~= self.wnd__scroll_y then
		self.wnd__scroll_x = tx
		self.wnd__scroll_y = ty
		self:invalidate ()

		local success, msg = pcall (self.on_scroll, self)
		if not success then
			syslog ("on_scroll "..msg)
		end
	end
end



function win.window:set_scroll_size (width, height)
	if self.wnd__scroll_width ~= width  or
			self.wnd__scroll_height ~= height  then
		self.wnd__scroll_width = width
		self.wnd__scroll_height = height

		if self.wnd__scroll_width < 0 then
			self.wnd__scroll_width = 0
		end

		if self.wnd__scroll_height < 0 then
			self.wnd__scroll_height = 0
		end

		self:set_scroll_org (self.wnd__scroll_x, self.wnd__scroll_y)
		self:invalidate ()
	end
end



function win.window:get_scroll_size ()
	return self.wnd__scroll_width, self.wnd__scroll_height
end



function win.window:scroll_lines (lines)
	self:set_scroll_org (self.wnd__scroll_x,
								self.wnd__scroll_y + lines)
end



function win.window:scroll_cols (cols)
	self:set_scroll_org (self.wnd__scroll_x + cols,
								self.wnd__scroll_y)
end



function win.window:get_wnd_rect ()
	return win.rect:new (self.x, self.y, self.width, self.height)
end



function win.window:get_screen_rect ()
	local x, y = self:wnd_to_screen (0, 0)

	return win.rect:new (x, y, self.width, self.height)
end



function win.window:wnd_at_point (x, y, disabled, hidden)
	if (self:is_shown () or hidden) and (self:is_enabled () or disabled) then
		local sx, sy = self:screen_to_wnd (math.floor (x), math.floor (y))
		local rt = win.rect:new (0, 0, self.width, self.height)

		if rt:contains (sx, sy) then
			for i = 1, self:children (), 1 do
				local wnd = self:get_child (i):wnd_at_point (x, y, disabled, hidden)

				if wnd then
					return wnd
				end
			end

			return self
		end
	end

	return nil
end



function win.window:wnd_from_point (x, y)
	local wnd = self:wnd_at_point (x, y, true, false)

	if wnd then
		if wnd:is_enabled () then
			return wnd
		end
	end

	return nil
end



function win.window:get_wnd_by_id (id, recursive)
	for i = 1, self:children (), 1 do
		if self:get_child (i):get_id () == id then
			return self:get_child (i)
		end
	end

	if recursive ~= false then
		for i = 1, self:children (), 1 do
			local wnd = self:get_child (i):get_wnd_by_id (id)

			if wnd then
				return wnd
			end
		end
	end

	return nil
end



function win.window:draw (gdi, bounds)
	gdi:set_colors (self:get_color (), self:get_bg_color ())
	gdi:clear (bounds:unpack ())
end



function win.window:update (force)
	local rt_result = win.rect:new ()

	if self:is_shown () then
		if force then
			self:invalidate ()
		end

		if not self.wnd__invalid:is_empty () then
			self.gdi:store ()
			local vert, horz = self:has_scroll_bars ()
			local zx, zy = self:get_client_size ()

			self.gdi:set_blink (false)

			if self:get_bg_color () > 0 then
				local rtErase = win.rect:new (0, 0, zx, zy)

				rtErase:clip (self.wnd__invalid)

				self.gdi:set_colors (nil, self:get_bg_color ())
				self.gdi:clear_wnd (rtErase:unpack ())
			else
				local rtBound = win.rect:new (self.wnd__invalid:unpack ())
				rtBound.x, rtBound.y = self:wnd_to_screen (rtBound.x, rtBound.y)
				self.gdi:add_bounds (rtBound)
			end

			self:draw (self.gdi, win.rect:new (self.wnd__invalid:unpack ()))

			for i = self:children (), 1, -1 do
				local child = self:get_child (i)

				if child:get_screen_rect ():overlap (self.gdi:get_bounds ()) then
					self.gdi:add_bounds (child:update (true))
				end
			end

			-- draw scroll bars
			if vert or horz then
				local vert_left = self.width - 1
				local vert_bottom = self.height - ((horz and 2) or 1)
				local horz_top = self.height - 1
				local horz_right = self.width - ((vert and 2) or 1)

				if vert then
					self.gdi:set_colors (self:get_colors ().scroll_text, self:get_colors ().scroll_back)
					self.gdi:write_wnd (string.char (14), vert_left, 0)
					self.gdi:write_wnd (string.char (15), vert_left, vert_bottom)
					self.gdi:set_colors (nil, self:get_colors ().scroll_track)
					for i = 1, vert_bottom - 1, 1 do
						self.gdi:write_wnd (" ", vert_left, i)
					end

					if vert_bottom > 3 then
						self.gdi:set_colors (nil, self:get_colors ().scroll_back)
						self.gdi:write_wnd (" ", vert_left,
	math.floor((self.wnd__scroll_y / (self.wnd__scroll_height - zy)) * (vert_bottom - 2)) + 1)
					end
				end

				if horz then
					self.gdi:set_colors (self:get_colors ().scroll_text, self:get_colors ().scroll_back)
					self.gdi:write_wnd (string.char (12), 0, horz_top)
					self.gdi:write_wnd (string.char (11), horz_right, horz_top)

					if horz_right > 1 then
						self.gdi:set_colors (nil, self:get_colors ().scroll_track)
						self.gdi:write_wnd (string.rep (" ", horz_right - 1), 1, horz_top)
					end

					if horz_right > 3 then
						self.gdi:set_colors (nil, self:get_colors ().scroll_back)
						self.gdi:write_wnd (" ",
	math.floor((self.wnd__scroll_x / (self.wnd__scroll_width - zx)) * (horz_right - 2)) + 1, horz_top)
					end
				end

				if vert and horz then
					local corner = self:get_colors ().scroll_track
					if self:get_parent () then
						if self:get_parent ():get_bg_color () ~= 0 then
							corner = self:get_parent ():get_bg_color ()
						end
					end
					self.gdi:set_colors (nil, corner)
					self.gdi:write_wnd (" ", vert_left, horz_top)
				end
			end

			rt_result = self.gdi:get_bounds (true)
			self:validate ()
			self.gdi:restore ()
		end
	end

	return rt_result
end



function win.window:print (gdi, children, hidden)
	if self:is_shown () or hidden then
		if self:get_bg_color () > 0 then
			gdi:set_colors (nil, self:get_bg_color ())
			gdi:clear (self:get_wnd_rect ())
		end

		self:draw (gdi, self:get_wnd_rect ())

		if children then
			for i = self:children (), 1, -1 do
				gdi:add_bounds (self:get_child (i):print (gdi, children, hidden))
			end
		end
	end
end



function win.window:wnd_to_screen (x, y)
	return win.wnd_to_screen (self, x, y)
end



function win.window:screen_to_wnd (x, y)
	return win.screen_to_wnd (self, x, y)
end



function win.window:wnd_to_scroll (x, y)
	return (x + self.wnd__scroll_x), (y + self.wnd__scroll_y)
end



function win.window:scroll_to_wnd (x, y)
	return (x - self.wnd__scroll_x), (y - self.wnd__scroll_y)
end



function win.window:get_cursor_pos ()
	return self.wnd__cursor_x, self.wnd__cursor_y
end



function win.window:set_cursor_pos (x, y)
	local width, height = self:get_client_size ()
	local desktop = self:get_desktop ()
	self.wnd__cursor_x = x
	self.wnd__cursor_y = y

	if (x - self.wnd__scroll_x) >= 0 and
		(x - self.wnd__scroll_x) < width and
		(y - self.wnd__scroll_y) >= 0 and
		(y - self.wnd__scroll_y) < height then

		if desktop and
				self:get_parent_frame () == desktop:get_active_frame () then
			self.gdi:set_cursor (self:wnd_to_screen (x - self.wnd__scroll_x,
																  y - self.wnd__scroll_y))
			self.gdi:set_blink (true)
		end
	else
		self.gdi:set_blink (false)
	end
end



function win.window:capture_mouse ()
	if self:get_desktop () then
		self:get_desktop ():capture_mouse (self)
	end
end



function win.window:release_mouse ()
	if self:get_desktop () then
		self:get_desktop ():capture_mouse (nil)
	end
end



function win.window:captured_mouse ()
	if self:get_desktop () then
		return self:get_desktop ():captured_mouse ()
	end

	return nil
end



function win.window:get_clipboard ()
	if self:get_desktop () then
		return self:get_desktop ():get_clipboard ()
	end

	return CB_EMPTY, nil
end



function win.window:set_clipboard (data, cbType)
	if self:get_desktop () then
		self:get_desktop ():set_clipboard (data, cbType)
	end
end



function win.window:set_cursor_blink (blink)
	local desktop = self:get_desktop ()


	if desktop and
			self:get_parent_frame () == desktop:get_active_frame () then
		self.gdi:set_blink (blink)
	end
end



function win.window:hide_cursor ()
	self.gdi:set_blink (false)
end



function win.window:show_cursor ()
   self:set_cursor_pos (self.wnd__cursor_x, self.wnd__cursor_y)
end



function win.window:start_timer (timeout)
	return self:get_workspace ():start_timer (self, timeout)
end



function win.window:kill_timer (timer_id)
	self:get_workspace ():kill_timer (self, timer_id)
end



function win.window:set_alarm (alarm_time)
	return self:get_workspace ():set_alarm (self, alarm_time)
end



function win.window:kill_alarm (alarm_id)
	self:get_workspace ():kill_alarm (self, alarm_id)
end



function win.window:get_focus ()
	if self:get_desktop () then
		return self:get_desktop ():get_focus_wnd ()
	end

	return nil
end



function win.window:set_focus ()
	if self == self:get_focus () then
		return true
	end

	local frame = self:get_parent_frame ()

	if frame then
		return frame:set_focus_wnd (self)
	end

	return false
end



function win.window:combo_keys (ctrl, alt, shift)
	return self:get_workspace ():combo_keys (ctrl, alt, shift)
end



function win.window:hit_test (x, y)
	x = math.floor (x)
	y = math.floor (y)
	if x >= 0 and y >= 0 and x < self.width and y < self.height then
		local vert, horz = self:has_scroll_bars ()

		if vert then
			local height = self.height - 1

			if horz then
				height = height - 1
			end

			if x == self.width - 1 then
				if y == 0 then
					return win.HT_LINEUP
				end

				if y == height then
					return win.HT_LINEDOWN
				end

				if y <= math.floor (height / 2) and y < height then
					return win.HT_PAGEUP
				end

				if y > math.floor (height / 2) and y > 0 then
					return win.HT_PAGEDOWN
				end
			end
		end

		if horz then
			local width = self.width - 1

			if vert then
				width = width - 1
			end

			if y == self.height - 1 then
				if x == 0 then
					return win.HT_LINELEFT
				end

				if x == width then
					return win.HT_LINERIGHT
				end

				if x <= math.floor (width / 2) and x < width then
					return win.HT_PAGELEFT
				end

				if x > math.floor (width / 2) and x > 0 then
					return win.HT_PAGERIGHT
				end
			end
		end

		return win.HT_CLIENT
	end

	return win.HT_NOWHERE
end



function win.window:comm_enabled ()
	return self:get_workspace ():comm_enabled ()
end



function win.window:send_message (recipient, application, context, data, name)
	return self:get_workspace ():comm_send (recipient, application, context, data, name)
end



function win.window:want_messages (application, name)
	return self:get_workspace ():comm_register (self, application, name)
end



function win.window:unwant_messages (application, name)
	return self:get_workspace ():comm_unregister (self, application, name)
end



function win.window:comm_find (name)
	return self:get_workspace ():comm_find (name)
end



function win.window:comm_open (name, timeout)
	return self:get_workspace ():comm_open (name, timeout)
end



function win.window:comm_close (name)
	return self:get_workspace ():comm_close (name)
end



function win.window:route_child_event (wnd, event, p1, p2, p3, p4, p5, ...)
	if event == "idle" then
		return false

	elseif event == "timer" then
		return false

	elseif event == "focus" then
		return self:on_child_focus (wnd, p1)

	elseif event == "blur" then
		return self:on_child_blur (wnd, p1)

	elseif event == "char" then
		return self:on_child_char (wnd, p1, p2)

	elseif event == "key" then
		return self:on_child_key (wnd, p1, p2, p3, p4)

	elseif event == "click" then
		if p4 == 2 then
			return self:on_child_right_click (wnd, p1, p2, p3)
		elseif p4 == 3 then
			return self:on_child_middle_click (wnd, p1, p2, p3)
		end

		return self:on_child_left_click (wnd, p1, p2, p3)

	elseif event == "monitor_touch" then
		return self:on_child_touch (wnd, p2, p3)

	elseif event == "alarm" then
		return false

	elseif event == "clipboard" then
		return self:on_child_clipboard (wnd, p1)

	elseif event == "frame_close" then
		return false

	elseif event == "monitor_resize" then
		return false

	elseif event == "key_up" then
		return self:on_child_key_up (wnd, p1)

	elseif event == "mouse_scroll" then
		return false

	elseif event == "mouse_drag" then
		if p3 == 2 then
			return self:on_child_right_drag (wnd, p1, p2)
		elseif p3 == 3 then
			return self:on_child_middle_drag (wnd, p1, p2)
		end

		return self:on_child_left_drag (wnd, p1, p2)

	elseif event == "mouse_up" then
		if p3 == 2 then
			return self:on_child_right_up (wnd, p1, p2)
		elseif p3 == 3 then
			return self:on_child_middle_up (wnd, p1, p2)
		end

		return self:on_child_left_up (wnd, p1, p2)

	end

	return self:on_child_event (wnd, event, p1, p2, p3, p4, p5, ...)
end



function win.window:route_wnd_event (event, p1, p2, p3, p4, p5, ...)
	if event == "idle" then
		return self:on_idle (p1)

	elseif event == "timer" then
		return self:on_timer (p1)

	elseif event == "vbar_scroll" then
		return self:on_v_scroll (p1, p2)

	elseif event == "hbar_scroll" then
		return self:on_h_scroll (p1, p2)

	elseif event == "focus" then
		return self:on_focus (p1)

	elseif event == "blur" then
		return self:on_blur (p1)

	elseif event == "char" then
		return self:on_char (p1, p2)

	elseif event == "key" then
		return self:on_key (p1, p2, p3, p4)

	elseif event == "click" then
		local x, y = self:screen_to_wnd (p1, p2)

		if p4 == 2 then
			return self:on_right_click (x, y, p3)
		elseif p4 == 3 then
			return self:on_middle_click (x, y, p3)
		end

		return self:on_left_click (x, y, p3)

	elseif event == "monitor_touch" then
		return self:on_touch (self:screen_to_wnd (p2, p3))

	elseif event == "alarm" then
		return self:on_alarm (p1)

	elseif event == "clipboard" then
		return self:on_clipboard (p1)

	elseif event == "frame_close" then
		return self:on_frame_close ()

	elseif event == "comm_receive" then
		return self:on_receive (p1)

	elseif event == "comm_sent" then
		return self:on_sent (p1, p2)

	elseif event == "monitor_resize" then
		return self:on_resize ()

	elseif event == "key_up" then
		return self:on_key_up (p1)

	elseif event == "mouse_scroll" then
		return self:on_scroll_wheel (p1, self:screen_to_wnd (p2, p3))

	elseif event == "mouse_drag" then
		if p3 == 2 then
			return self:on_right_drag (self:screen_to_wnd (p1, p2))
		elseif p3 == 3 then
			return self:on_middle_drag (self:screen_to_wnd (p1, p2))
		end

		return self:on_left_drag (self:screen_to_wnd (p1, p2))

	elseif event == "mouse_up" then
		if p3 == 2 then
			return self:on_right_up (self:screen_to_wnd (p1, p2))
		elseif p3 == 3 then
			return self:on_middle_up (self:screen_to_wnd (p1, p2))
		end

		return self:on_left_up (self:screen_to_wnd (p1, p2))

	end

	return self:on_event (event, p1, p2, p3, p4, p5, ...)
end



function win.window:route_event (wnd, event, ...)
	local success, result;

	if self == wnd then
		success, result = pcall (self.route_wnd_event, self, event, ...)
	else
		success, result = pcall (self.route_child_event, self, wnd, event, ...)
	end

	if success then
		return result
	end

	if self:get_app_frame () then
		local title = self:get_app_frame ():get_text ()

		if title:len() > 0 then
			result = title.."\n"..tostring (result or "")
		end
	end

	win.syslog (result)
	self:get_desktop ():msgbox ("Error", result, term.colors.red)

	return false
end



function win.window:send_event (event, ...)
	return self:route_event (self, event, ...)
end



function win.window:want_event (event)
	return self:get_workspace ():want_event (self, event)
end



function win.window:unwant_event (event)
	return self:get_workspace ():unwant_event (self, event)
end



function win.window:on_focus (blurred)
	self:hide_cursor ()

	return false
end



function win.window:on_blur (focused)
	self:hide_cursor ()

	return false
end



function win.window:on_idle (idleCount)
	return false
end



function win.window:on_left_click (x, y, count)
	if self:get_want_focus () then
		self:set_focus ()
	end

	local htPos = self:hit_test (x, y)

	if htPos > win.HT_CLIENT then
		if htPos == win.HT_LINEUP then
			return self:send_event ("vbar_scroll", -1, false)
		end

		if htPos == win.HT_LINEDOWN then
			return self:send_event ("vbar_scroll", 1, false)
		end

		if htPos == win.HT_PAGEUP then
			return self:send_event ("vbar_scroll", -1, true)
		end

		if htPos == win.HT_PAGEDOWN then
			return self:send_event ("vbar_scroll", 1, true)
		end

		if htPos == win.HT_LINELEFT then
			return self:send_event ("hbar_scroll", -1, false)
		end

		if htPos == win.HT_LINERIGHT then
			return self:send_event ("hbar_scroll", 1, false)
		end

		if htPos == win.HT_PAGELEFT then
			return self:send_event ("hbar_scroll", -1, true)
		end

		if htPos == win.HT_PAGERIGHT then
			return self:send_event ("hbar_scroll", 1, true)
		end
	end

	return false
end



function win.window:on_right_click (x, y, count)
	if self:get_want_focus () then
		self:set_focus ()
	end

	return false
end



function win.window:on_middle_click (x, y, count)
	if self:get_want_focus () then
		self:set_focus ()
	end

	return false
end



function win.window:on_left_up (x, y)
	return false
end



function win.window:on_right_up (x, y)
	return false
end



function win.window:on_middle_up (x, y)
	return false
end



function win.window:on_char (char, ascii)
	return false
end



function win.window:on_clipboard (text)
	return false
end



function win.window:on_key (key, ctrl, alt, shift)
	return false
end



function win.window:on_key_up (key)
	return false
end



function win.window:on_scroll_wheel (direction, x, y)
	local width, height = self:get_client_size ()

	if height < self.height and y == height then
		local cols = 3

		if width < 6 then
			cols = 1
		end

		self:scroll_cols (cols * direction)
	else
		local lines = 3

		if height < 6 then
			lines = 1
		end

		self:scroll_lines (lines * direction)
	end

	return true
end



function win.window:on_v_scroll (direction, page)
	local lines = 1
	local width, height = self:get_client_size ()

	if page then
		lines = height - 1

		if lines < 1 then
			lines = 1
		end
	end

	self:scroll_lines (lines * direction)

	return true
end



function win.window:on_h_scroll (direction, page)
	local lines = 1
	local width, height = self:get_client_size ()

	if page then
		lines = width - 1

		if lines < 1 then
			lines = 1
		end
	end

	self:scroll_cols (lines * direction)

	return true
end



function win.window:on_left_drag (x, y)
	return false
end



function win.window:on_right_drag (x, y)
	return false
end



function win.window:on_middle_drag (x, y)
	return false
end



function win.window:on_touch (x, y)
	if self:get_want_focus () then
		self:set_focus ()
	end

	local htPos = self:hit_test (x, y)

	if htPos > win.HT_CLIENT then
		if htPos == win.HT_LINEUP then
			return self:send_event ("vbar_scroll", -1, false)
		end

		if htPos == win.HT_LINEDOWN then
			return self:send_event ("vbar_scroll", 1, false)
		end

		if htPos == win.HT_PAGEUP then
			return self:send_event ("vbar_scroll", -1, true)
		end

		if htPos == win.HT_PAGEDOWN then
			return self:send_event ("vbar_scroll", 1, true)
		end

		if htPos == win.HT_LINELEFT then
			return self:send_event ("hbar_scroll", -1, false)
		end

		if htPos == win.HT_LINERIGHT then
			return self:send_event ("hbar_scroll", 1, false)
		end

		if htPos == win.HT_PAGELEFT then
			return self:send_event ("hbar_scroll", -1, true)
		end

		if htPos == win.HT_PAGERIGHT then
			return self:send_event ("hbar_scroll", 1, true)
		end
	end

	if self.wnd__do_keyboard and self:get_want_key_input () ~= win.KEYINPUT_NONE and
			self.gdi:is_monitor () and self:get_desktop () then
		self:get_desktop ():do_keyboard (self)
	end

	return false
end



function win.window:on_resize ()
	return false
end



function win.window:on_alarm (id)
	return false
end



function win.window:on_timer (id)
	return false
end



function win.window:on_move ()
	return false
end



function win.window:on_frame_close ()
	return false
end



function win.window:on_receive (msg)
	return false
end



function win.window:on_sent (msg, success)
	return false
end



function win.window:on_event (event, p1, p2, p3, p4, p5, ...)
	return false
end



function win.window:on_destroy_wnd ()
end



function win.window:on_scroll ()
end



function win.window:on_child_focus (wnd, blurred)
	return false
end



function win.window:on_child_blur (wnd, focused)
	return false
end



function win.window:on_child_left_click (wnd, x, y, count)
	return false
end



function win.window:on_child_right_click (wnd, x, y, count)
	return false
end



function win.window:on_child_middle_click (wnd, x, y, count)
	return false
end



function win.window:on_child_left_up (wnd, x, y)
	return false
end



function win.window:on_child_right_up (wnd, x, y)
	return false
end



function win.window:on_child_middle_up (wnd, x, y)
	return false
end



function win.window:on_child_char (wnd, char, ascii)
	return false
end



function win.window:on_child_clipboard (wnd, text)
	return false
end



function win.window:on_child_key (wnd, key, ctrl, alt, shift)
	return false
end



function win.window:on_child_key_up (wnd, key)
	return false
end



function win.window:on_child_left_drag (wnd, x, y)
	return false
end



function win.window:on_child_right_drag (wnd, x, y)
	return false
end



function win.window:on_child_middle_drag (wnd, x, y)
	return false
end



function win.window:on_child_touch (wnd, x, y)
	return false
end



function win.window:on_child_event (wnd, event, p1, p2, p3, p4, p5, ...)
	return false
end
