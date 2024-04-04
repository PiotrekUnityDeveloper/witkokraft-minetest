local private = ...



win.menuWindow = win.listWindow:base ()



function win.menuWindow:constructor (parent)
	if not win.listWindow.constructor (self, parent, 0, 0, 0, 0, 0) then
		return nil
	end

	self:set_colors (self:get_colors ().menu_text,
						  self:get_colors ().menu_back,
						  self:get_colors ().menu_back,
						  self:get_colors ().menu_selected_text,
						  self:get_colors ().menu_selected_back)

	self:show (false)

	return self
end



function win.menuWindow:track (x, y)
	local width, height = 0, self:count ()
	local rt = (self:get_parent () and self:get_parent ():get_wnd_rect ()) or nil

	for i = 1, self:count (), 1 do
		local len = self.list__items[i][1]:len ()

		if len > width then
			width = len
		end
	end

	if rt then
		if height > rt.height then
			y = 0
			height = rt.height
			width = width + 1
		elseif (y + height) > rt.height then
			y = rt.height - height
		end

		if width > rt.width then
			x = 0
			width = rt.width
		elseif (x + width) > rt.width then
			x = rt.width - width
		end
	end

	self.list__colors.focus = self.list__colors.back
	self:move (x, y, width, height, win.WND_TOP)
	self:set_cur_sel (self:next_valid_item (0))
	self:show (true)
	self:set_focus ()
	self:capture_mouse ()
end



function win.menuWindow:add_string (str, data, index)
	win.listWindow.add_string (self, str, tonumber (data) or 0, index)
end



function win.menuWindow:set_cur_sel (index, make_visible)
	local i = index

	if i == nil then
		i = 0
	end

	if i > self:count () then
		i = self:count ()
	end

	if i >= 0 and i <= self:count () and i ~= self.list__sel_index then
		self.list__sel_index = i

		if make_visible ~= false then
			self:ensure_visible ()
		end

		self:invalidate ()

		return true
	end

	return false
end



function win.menuWindow:next_valid_item (from)
	from = tonumber (from) or 0

	for i = from + 1, self:count (), 1 do
		if (tonumber (self:get_data (i)) or 0) ~= 0 then
			return i
		end
	end

	return from
end



function win.menuWindow:prior_valid_item (from)
	from = tonumber (from) or 0

	for i = from - 1, 1, -1 do
		if (tonumber(self:get_data (i)) or 0) ~= 0 then
			return i
		end
	end

	return from
end



function win.menuWindow:on_blur (focused)
	self:destroy_wnd ()

	return true
end



function win.menuWindow:on_key (key, ctrl, alt, shift)
	if not ctrl and not alt and not shift then
		if key == keys.KEY_ENTER then
			local parent = self:get_parent ()

			self:destroy_wnd ()

			if parent then
				parent:send_event ("menu_cmd", self:get_data ())
			end

			return true
		end

		if key == keys.KEY_UP then
			self:set_cur_sel (self:prior_valid_item (self:get_cur_sel ()))

			return true
		end

		if key == keys.KEY_DOWN then
			self:set_cur_sel (self:next_valid_item (self:get_cur_sel ()))

			return true
		end

		if key == keys.KEY_HOME then
			self:set_cur_sel (self:next_valid_item (0))

			return true
		end

		if key == keys.KEY_END then
			self:set_cur_sel (self:prior_valid_item (self:count () + 1))

			return true
		end

	elseif not alt and not shift then
		if key == keys.KEY_CTRL then
			self:destroy_wnd ()

			return true
		end
	end

	return false
end



function win.menuWindow:on_left_click (x, y, count)
	if win.window.on_left_click (self, x, y, count) then
		return true
	end

	local rtWnd = win.rect:new (0, 0, self.width, self.height)

	if rtWnd:contains (x, y) then
		local sx, sy = self:wnd_to_scroll (x, y)

		if self:get_data (sy + 1) ~= 0 then
			local parent = self:get_parent ()

			self:set_cur_sel (sy + 1)

			self:destroy_wnd ()

			if parent then
				parent:send_event ("menu_cmd", self:get_data ())
			end
		end
	else
		self:destroy_wnd ()
	end

	return true
end



function win.menuWindow:on_touch (x, y)
	if win.window.on_touch (self, x, y) then
		return true
	end

	local rtWnd = win.rect:new (0, 0, self.width, self.height)

	if rtWnd:contains (x, y) then
		local sx, sy = self:wnd_to_scroll (x, y)

		if self:get_data (sy + 1) ~= 0 then
			local parent = self:get_parent ()

			self:set_cur_sel (sy + 1)

			self:destroy_wnd ()

			if parent then
				parent:send_event ("menu_cmd", self:get_data ())
			end
		end
	else
		self:destroy_wnd ()
	end

	return true
end
