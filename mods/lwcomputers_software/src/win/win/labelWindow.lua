local private = ...



win.labelWindow = win.window:base ()



function win.labelWindow:constructor(parent, id, x, y, label)
	if not win.window.constructor(self, parent, id, x, y,
											tostring (label or ""):len (), 1) then
		return nil
	end

	self:set_text (label)
	self:set_want_focus (false)
	self:set_color (self:get_colors ().frame_text)
	self:set_bg_color (self:get_colors ().frame_back)

	return self
end



function win.labelWindow:draw (gdi, bounds)
	gdi:set_colors (self:get_color (), self:get_bg_color ())
	gdi:write (self:get_text (), 0, 0)
end
