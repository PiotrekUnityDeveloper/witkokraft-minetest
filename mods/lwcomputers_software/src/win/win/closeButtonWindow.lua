local private = ...



win.closeButtonWindow = win.buttonWindow:base ()



function win.closeButtonWindow:constructor (parent, x, y)
	local label = private.defaultTheme.close_btn
	if parent then
		label = parent:get_theme ().close_btn
	end

	if not win.buttonWindow.constructor (self, parent, win.ID_CLOSE, x, y, label) then
		return nil
	end

	self:set_colors(self:get_colors ().close_text,
						 self:get_colors ().close_back,
						 self:get_colors ().close_focus)

	return self
end



function win.closeButtonWindow:on_left_click (x, y, count)
	if win.window.on_left_click (self, x, y, count) then
		return true
	end

	if self:get_parent () then
		self:get_parent ():send_event ("frame_close")
	end

	return false
end



function win.closeButtonWindow:on_touch (x, y)
	if win.window.on_touch (self, x, y) then
		return true
	end

	if self:get_parent () then
		self:get_parent ():send_event ("frame_close")
	end

	return false
end
