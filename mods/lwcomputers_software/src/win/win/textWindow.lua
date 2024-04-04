local private = ...



win.textWindow = win.window:base ()



function win.textWindow:constructor (parent, id, x, y, width, height, label)
	if not win.window.constructor (self, parent, id, x, y, width, height) then
		return nil
	end

	self.txtWnd__lines = { }

	self:set_want_focus (false)
	self:set_color (self:get_colors ().frame_text)
	self:set_bg_color (self:get_colors ().frame_tack)
	self:set_text (label)

	return self
end



function win.textWindow:calc_size ()
	self.txtWnd__lines = string.wrap (self:get_text (), self.width)

	if #self.txtWnd__lines > self.height then
		self.txtWnd__lines = string.wrap (self:get_text (), self.width - 1)
		self:set_scroll_size (0, #self.txtWnd__lines)
	else
		self:set_scroll_size (0, 0)
	end
end



function win.textWindow:draw (gdi, bounds)
	local first, last;

	first = self.wnd__scroll_y + 1
	last = #self.txtWnd__lines

	if (last - first + 1) > self.height then
		last = first + self.height
	end

	gdi:set_colors (self:get_color (), self:get_bg_color ())

	for i = first, last, 1 do
		gdi:write (self.txtWnd__lines[i], 0, i - 1)
	end
end



function win.textWindow:on_move ()
	self:calc_size ()

	return false
end



function win.textWindow:set_text (text)
	win.window.set_text (self, text)
	self:calc_size ()
end
