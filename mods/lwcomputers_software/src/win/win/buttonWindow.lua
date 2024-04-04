local private = ...



win.buttonWindow = win.window:base ()



function win.buttonWindow:constructor (parent, id, x, y, label)
	if not win.window.constructor (self, parent, id, x, y,
											 tostring (label or ""):len (), 1) then
		return nil
	end

	self.btn__colors =
	{
		text = self:get_colors ().button_text,
		back = self:get_colors ().button_back,
		focus = self:get_colors ().button_focus
	}

	self:set_text (label)
	self:set_color (self.btn__colors.text)
	self:set_bg_color (self.btn__colors.back)

	return self
end



function win.buttonWindow:set_colors (text, background, focus)
	self.btn__colors.text = text
	self.btn__colors.back = background
	self.btn__colors.focus = focus

	self:set_color (text)
	self:set_bg_color ((self:get_focus () == self and focus) or background)
end



function win.buttonWindow:draw (gdi, bounds)
	gdi:set_colors (self:get_color (), self:get_bg_color ())
	gdi:write (self:get_text (), 0, 0)
end



function win.buttonWindow:on_focus (blurred)
	self:hide_cursor ()
	self:set_bg_color (self.btn__colors.focus)

	return false
end



function win.buttonWindow:on_blur (focused)
	self:set_bg_color (self.btn__colors.back)

	return false
end



function win.buttonWindow:on_key (key, ctrl, alt, shift)
	if not ctrl and not alt and not shift then
		if key == keys.KEY_ENTER then
			self:on_left_click (0, 0, 1)
		end
	end

	return true
end



function win.buttonWindow:on_left_click (x, y, count)
	if win.window.on_left_click (self, x, y, count) then
		return true
	end

	if self:get_parent () then
		self:get_parent ():send_event ("btn_click", self)
	end

	return false
end



function win.buttonWindow:on_touch (x, y)
	if win.window.on_touch (self, x, y) then
		return true
	end

	if self:get_parent () then
		self:get_parent ():send_event ("btn_click", self)
	end

	return false
end
