local private = ...



win.checkWindow = win.window:base ()



function win.checkWindow:constructor (parent, id, x, y, label, checked)
	if not win.window.constructor (self, parent, id, x, y,
											 tostring (label or ""):len () + 2, 1) then
		return nil
	end

	self.check__checked = (checked == true)
	self.check__colors = {
		text = self:get_colors ().frame_text,
		back = self:get_colors ().frame_back,
		focus = self:get_colors ().frame_back,
		check_text = self:get_colors ().check_text,
		check_back = self:get_colors ().check_back,
		check_focus = self:get_colors ().check_focus
	}

	self:set_text (label)
	self:set_color (self.check__colors.text)
	self:set_bg_color (self.check__colors.back)

	return self
end



function win.checkWindow:set_colors (text, background, focus, check_text, check_back, check_focus)
	self.check__colors.text = text
	self.check__colors.back = background
	self.check__colors.focus = focus
	self.check__colors.check_text = check_text
	self.check__colors.check_back = check_back
	self.check__colors.check_focus = check_focus

	self:set_color (text)
	self:set_bg_color ((self:get_focus () == self and focus) or background)
end



function win.checkWindow:get_checked ()
	return self.check__checked
end



function win.checkWindow:set_checked (check)
	check = (check ~= false)

	if self.check__checked ~= check then
		self.check__checked = check

		if self:get_parent () then
			self:get_parent ():send_event ("check_change", self)
		end

		self:invalidate ()
	end
end



function win.checkWindow:draw (gdi, bounds)
	if self == self:get_focus () then
		gdi:set_colors (nil, self.check__colors.check_focus)
	else
		gdi:set_colors (nil, self.check__colors.check_back)
	end

	gdi:set_colors (self.check__colors.check_text)

	if self:get_checked () then
		gdi:write ("x", 0, 0)
	else
		gdi:write (" ", 0, 0)
	end

	gdi:set_colors (self:get_color (), self:get_bg_color ())
	gdi:write (" ", 1, 0)
	gdi:write (self:get_text (), 2, 0)
end



function win.checkWindow:on_focus (blurred)
	self:hide_cursor ()
	self:set_bg_color (self.check__colors.focus)

	return false
end



function win.checkWindow:on_blur (focused)
	self:set_bg_color (self.check__colors.back)

	return false
end



function win.checkWindow:on_key (key, ctrl, alt, shift)
	if not ctrl and not alt and not shift then
		if key == keys.KEY_ENTER then
			self:on_left_click (0, 0, 1)
		end

		return true
	end

	return false
end



function win.checkWindow:on_left_click (x, y, count)
	if win.window.on_left_click (self, x, y, count) then
		return true
	end

	self:set_checked (not self:get_checked ())

	return true
end



function win.checkWindow:on_touch (x, y)
	if win.window.on_touch (self, x, y) then
		return true
	end

	self:set_checked (not self:get_checked ())

	return true
end
