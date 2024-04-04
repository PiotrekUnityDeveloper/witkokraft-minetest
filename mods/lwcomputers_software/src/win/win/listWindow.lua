local private = ...



win.listWindow = win.window:base ()



function win.listWindow:constructor(parent, id, x, y, width, height)
	if not win.window.constructor (self, parent, id, x, y, width, height) then
		return nil
	end

	self.list__sel_index = 0
	self.list__click_time = -1
	self.list__click_x = -1
	self.list__click_y = -1
	self.list__colors = {
		text = self:get_colors ().wnd_text,
		back = self:get_colors ().wnd_back,
		focus = self:get_colors ().wnd_focus,
		selected_text = self:get_colors ().selected_text,
		selected_back = self:get_colors ().selected_back
	}
	self.list__items = {}

	self:set_color (self.list__colors.text)
	self:set_bg_color (self.list__colors.back)

	return self
end



function win.listWindow:set_colors (text, background, focus, selected_text, selected_back)
	self.list__colors.text = text
	self.list__colors.back = background
	self.list__colors.focus = focus
	self.list__colors.selected_text = selected_text
	self.list__colors.selected_back = selected_back

	self:set_color (text)
	self:set_bg_color ((self:get_focus () == self and focus) or background)
end



function win.listWindow:count ()
	return #self.list__items
end



function win.listWindow:add_string (str, data, index)
	local i = index

	if i == nil then
		i = self:count () + 1
	elseif i < 1 or i > (self:count () + 1) then
		i = self:count () + 1
	end

	table.insert (self.list__items, i, { tostring (str or ""), data })

	self:set_scroll_size (self.wnd__scroll_width, self:count ())
end



function win.listWindow:remove_string (index)
	if index == nil then
		return false
	elseif index < 1 or index > self:count () then
		return false
	end

	table.remove (self.list__items, index)

	self:set_scroll_size (self.wnd__scroll_width, self:count ())

	return true
end



function win.listWindow:reset_content ()
	self.list__items = { }
	self.list__sel_index = 0
	self:set_scroll_size (self.wnd__scroll_width, 0)
end



function win.listWindow:get_cur_sel ()
	if self.list__sel_index >= 0 and
			self.list__sel_index <= self:count () then
		return self.list__sel_index
	end

	return 0
end



function win.listWindow:set_cur_sel (index, make_visible)
	local i = index

	if i == nil then
		i = 0
	end

	if i > self:count () then
		i = self:count ()
	end

	if i >= 0 and i <= self:count () and
			i ~= self.list__sel_index then
		self.list__sel_index = i

		if make_visible ~= false then
			self:ensure_visible  ()
		end

		self:invalidate ()

		if self:get_parent () then
			self:get_parent ():send_event ("selection_change", self)
		end

		return true
	end

	return false
end



function win.listWindow:get_string (index)
	local i = index

	if i == nil then
		i = self:get_cur_sel ()
	end

	if i > 0 and i <= self:count () then
		return self.list__items[i][1]
	end

	return nil
end



function win.listWindow:get_data (index)
	local i = index

	if i == nil then
		i = self:get_cur_sel ()
	end

	if i > 0 and i <= self:count () then
		return self.list__items[i][2]
	end

	return nil
end



local function list_sorter_ascending (string1, string2)
	return (string1[1] < string2[1])
end



local function list_sorter_descending (string1, string2)
	return (string1[1] > string2[1])
end



function win.listWindow:sort (decending)
	if decending then
		table.sort (self.list__items, list_sorter_descending)
	else
		table.sort (self.list__items, list_sorter_ascending)
	end

	self:invalidate ()
end



function win.listWindow:ensure_visible (index)
	local top = index

	if top == nil then
		top = self:get_cur_sel ()
	end

	if top >= 1 and top <= self:count () then
		local width, height = self:get_client_size ()
		local orgX, orgY = self:get_scroll_org ()

		if top <= orgY then
			self:set_scroll_org (orgX, top - 1)
		elseif top > (orgY + height) then
			self:set_scroll_org (orgX, top - height)
		end
	end
end



function win.listWindow:find (str, from, exact)
	str = tostring (str or "")
	from = (tonumber (from) or 0) + 1

	for i = from, self:count (), 1 do
		local item = self:get_string (i)

		if not exact then
			item = item:sub (1, str:len ())
		end

		if str == item then
			return i
		end
	end

	return 0
end



function win.listWindow:set_string (str, index)
	local i = index

	if i == nil then
		i = self:get_cur_sel ()
	end

	if i > 0 and i <= self:count () then
		self.list__items[i][1] = tostring (str or "")
		self:invalidate ()

		return true
	end

	return false
end



function win.listWindow:set_data (data, index)
	local i = index

	if i == nil then
		i = self:get_cur_sel ()
	end

	if i > 0 and i <= self:count () then
		self.list__items[i][2] = data
		return true
	end

	return false
end



function win.listWindow:draw (gdi, bounds)
	local first, last;

	first = self.wnd__scroll_y + 1
	last = self:count ()

	if (last - first + 1) > self.height then
		last = first + self.height
	end

	for i = first, last, 1 do
		if i == self:get_cur_sel () then
			gdi:set_colors (self.list__colors.selected_text, self.list__colors.selected_back)
			gdi:clear (0, i - 1, self.width, 1)
		else
			gdi:set_colors (self:get_color (), self:get_bg_color ())
		end

		gdi:write (self:get_string (i), 0, i - 1)
	end
end



function win.listWindow:on_focus (blurred)
	self:hide_cursor ()
	self:set_bg_color (self.list__colors.focus)

	return false
end



function win.listWindow:on_blur (focused)
	self:set_bg_color (self.list__colors.back)

	return false
end



function win.listWindow:on_key (key, ctrl, alt, shift)
	if not ctrl and not alt and not shift then
		if key == keys.KEY_ENTER then
			if self:get_parent () then
				if (os.clock () - self.list__click_time) <= self:get_theme ().double_click and
					self.list__click_x == -2 and self.list__click_y == -2 then

					self.list__click_x = -1
					self.list__click_y = -1
					self.list__click_time = -1
					self:get_parent ():send_event ("list_double_click", self)
				else
					self.list__click_x = -2
					self.list__click_y = -2
					self.list__click_time = os.clock()
					self:get_parent ():send_event ("list_click", self)
				end
			end

			return true

		elseif key == keys.KEY_UP then
			if self:get_cur_sel () > 1 then
				self:set_cur_sel (self:get_cur_sel () - 1)
			end

			return true

		elseif key == keys.KEY_DOWN then
			self:set_cur_sel (self:get_cur_sel () + 1)

			return true

		elseif key == keys.KEY_PAGEUP then
			local width, height = self:get_client_size ()
			self:set_cur_sel (((self:get_cur_sel () - (height - 1)) < 1 and 1) or
									 (self:get_cur_sel () - (height - 1)))

			return true

		elseif key == keys.KEY_PAGEDOWN then
			local width, height = self:get_client_size ()
			self:set_cur_sel (self:get_cur_sel () + (height - 1))

			return true

		elseif key == keys.KEY_HOME then
			self:set_cur_sel (1)

			return true

		elseif key == keys.KEY_END then
			self:set_cur_sel (self:count ())

			return true

		end

	elseif ctrl and not alt and not shift then
		if key == keys.KEY_UP then
			self:send_event ("vbar_scroll", -1, false)

			return true

		elseif key == keys.KEY_DOWN then
			self:send_event ("vbar_scroll", 1, false)

			return true

		elseif key == keys.KEY_LEFT then
			self:send_event ("hbar_scroll", -1, false)

			return true

		elseif key == keys.KEY_RIGHT then
			self:send_event ("hbar_scroll", 1, false)

			return true

		elseif key == keys.KEY_PAGEUP then
			self:send_event ("vbar_scroll", -1, true)

			return true

		elseif key == keys.KEY_PAGEDOWN then
			self:send_event ("vbar_scroll", 1, true)

			return true

		elseif key == keys.KEY_HOME then
			self:set_scroll_org (0, 0)

			return true

		elseif key == keys.KEY_END then
			self:set_scroll_org (0, self:count ())

			return true
		end
	end

	return false
end



function win.listWindow:on_left_click (x, y, count)
	if win.window.on_left_click (self, x, y, count) then
		return true
	end

	local sx, sy = self:wnd_to_scroll (x, y)
	local item = sy + 1

	if item >= 1 and item <= self:count () then
		self:set_cur_sel (item)

		if self:get_parent () then
			if (os.clock() - self.list__click_time) <= self:get_theme ().double_click and
				self.list__click_x == sx and self.list__click_y == sy then

				self.list__click_x = -1
				self.list__click_y = -1
				self.list__click_time = -1
				self:get_parent ():send_event ("list_double_click", self)
			else
				self.list__click_x = sx
				self.list__click_y = sy
				self.list__click_time = os.clock()
				self:get_parent ():send_event ("list_click", self)
			end
		end
	end

	return true
end



function win.listWindow:on_touch (x, y)
	if win.window.on_touch (self, x, y) then
		return true
	end

	local sx, sy = self:wnd_to_scroll (x, y)
	local item = sy + 1

	if item >= 1 and item <= self:count () then
		self:set_cur_sel (item)

		if self:get_parent () then
			if (os.clock() - self.list__click_time) <= self:get_theme ().double_click and
				self.list__click_x == sx and self.list__click_y == sy then

				self.list__click_x = -1
				self.list__click_y = -1
				self.list__click_time = -1
				self:get_parent ():send_event ("list_double_click", self)
			else
				self.list__click_x = sx
				self.list__click_y = sy
				self.list__click_time = os.clock()
				self:get_parent ():send_event ("list_click", self)
			end
		end
	end

	return true
end
