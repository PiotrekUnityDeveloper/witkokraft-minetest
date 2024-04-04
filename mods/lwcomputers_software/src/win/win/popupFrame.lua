local private = ...



private.parentFrame = win.window:base ()
win.popupFrame = private.parentFrame:base ()



function win.popupFrame:constructor (owner_frame, width, height)
	assert (owner_frame, "win.popupFrame:new() must have an owner frame.")
	assert (owner_frame.on_frame_activate,
								"win.popupFrame:new() must have an owner frame.")
	assert (owner_frame.wnd__popup == nil,
								"win.popupFrame:new() owner frame already has popup.")

	width = tonumber (width) or 0
	height = tonumber (height) or 0
	local desktop = owner_frame:get_desktop ()
	local rtWork = desktop:get_work_area ()
	local popup_width, popup_height = width, height


	if width > rtWork.width then
		popup_width = rtWork.width
	end

	if height > rtWork.height then
		popup_height = rtWork.height
	end

	if not private.parentFrame.constructor (self, desktop, private.ID_DIALOG,
														 math.floor ((rtWork.width - popup_width) / 2),
														 math.floor ((rtWork.height - popup_height) / 2),
														 popup_width, popup_height) then
		return nil
	end

	self.wnd__owner = owner_frame
	owner_frame.wnd__popup = self
	self.wnd__frame_class = private.FRAME_CLASS_DIALOG
	self:set_color (desktop:get_colors ().popup_text)
	self:set_bg_color (desktop:get_colors ().popup_back)

	return self
end



function win.popupFrame:on_create (...)
	return true
end



function win.popupFrame:on_close ()
	return false
end



function win.popupFrame:close (result)
	if self:on_close () then
		return false
	end

	self:end_modal (result)

	return true
end



function win.popupFrame:on_resize ()
	self:move ()

	return true
end


function win.popupFrame:move (x, y, width, height)
	local rtWork = self:get_desktop ():get_work_area ()

	if not width then
		width = self.width
	end

	if width > rtWork.width then
		width = rtWork.width
	end

	if not height then
		height = self.height
	end

	if height > rtWork.height then
		height = rtWork.height
	end

	if not x then
		x = math.floor ((rtWork.width - width) / 2)
	end

	if not y then
		y = math.floor ((rtWork.height - height) / 2)
	end

	if x < rtWork.x then
		x = rtWork.x
	end

	if y < rtWork.y then
		y = rtWork.y
	end

	if (x + width) > (rtWork.x + rtWork.width) then
		x = (rtWork.x + rtWork.width) - width
	end

	if (y + height) > (rtWork.y + rtWork.height) then
		y = (rtWork.y + rtWork.height) - height
	end

	private.parentFrame.move (self, x, y, width, height)
end



function win.popupFrame:on_move ()
	private.parentFrame.on_move (self)

	local xbtn = self:get_wnd_by_id (win.ID_CLOSE)
	if xbtn then
		xbtn:move (self.width - 1)
	end

	return false
end



function win.popupFrame:on_frame_close ()
	self:close (win.ID_CLOSE)

	return true
end



function win.popupFrame:dress (title)
	self:set_text (title)

	win.closeButtonWindow:new (self, self.width - 1, 0):set_focus ()

	local titlebar = win.labelWindow:new(self, win.ID_TITLEBAR, 1, 0, title)
	titlebar:set_bg_color (titlebar:get_colors ().title_back)
	titlebar:set_color (titlebar:get_colors ().title_text)
end



function win.popupFrame:draw (gdi, bounds)
	if self:get_wnd_by_id (win.ID_TITLEBAR) then
		gdi:set_colors (nil, self:get_colors ().title_back)
		gdi:clear (0, 0, self.width, 1)

		if self.width > 2 and self.height > 2 then
			gdi:set_colors (self:get_colors ().title_back, self:get_bg_color ())
			gdi:write_wnd (string.char (25)..
									string.rep (string.char (29), self.width - 2)..
									string.char (26),
								0, self.height - 1)

			local edge = string.char (31)
			for l = 1, self.height - 2, 1 do
				gdi:write_wnd (edge, self.width - 1, l)
			end

			edge = string.char (30)
			for l = 1, self.height - 2, 1 do
				gdi:write_wnd (edge, 0, l)
			end
		end
	end
end



function win.popupFrame:set_title (title)
	local text = self:get_wnd_by_id (win.ID_TITLEBAR)

	self:set_text (title)

	if text then
		text:set_text (title)
		text:move (nil, nil, text:get_text ():len ())
	end
end



function win.popupFrame:do_modal (...)
	local result;
	local enabled = true
	local success, result = pcall (self.on_create, self, ...)

	if success then
		if result then
			enabled = self.wnd__owner:is_enabled ()
			self.wnd__owner:enable (false)

			self.wnd__owner:set_active_top_frame ()

			result = self:run_modal ()
		end
	end

	if self.wnd__owner then
		local owner = self.wnd__owner
		while owner do
			owner:invalidate ()
			owner = owner.wnd__owner
		end

		self.wnd__owner:enable (enabled)
		self.wnd__owner.wnd__popup = nil
		self.wnd__owner:set_active_top_frame ()
		self.wnd__owner.wnd__popup = self
	end

	self:destroy_wnd ()

	if not success then
		error (result, 0)
	end

	return result
end
