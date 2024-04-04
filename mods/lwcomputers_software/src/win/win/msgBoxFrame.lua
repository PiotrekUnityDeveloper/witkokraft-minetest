local private = ...



private.msgBoxFrame = win.popupFrame:base ()



function private.msgBoxFrame:on_create (title, message)
	title = tostring (title or "")
	message = tostring (message or "")

	local desktop = self:get_desktop ()
	local rtWork = desktop:get_work_area ()

	local max_width, max_height = math.floor (rtWork.width * 0.8),
											math.floor (rtWork.height * 0.8)
	local width, height = string.wrap_size (string.wrap (message, max_width - 2))

	if width == (max_width - 2) and height >= (max_height - 3) then
		width, height = string.wrap_size (string.wrap (message, max_width - 3))
	end

	width = width + 2
	height = height + 3

	if width < (title:len () + 3) then
		width = title:len () + 3
	end

	if height < 4 then
		height = 4
	elseif height > max_height then
		height = max_height
	end

	self:dress (title)
	win.textWindow:new (self, private.ID_MSGBOX_MSG, 1, 2, width - 2, height - 3, message)

	self:set_bg_color (self:get_bg_color ())

	self:move (nil, nil, width, height)

	return true
end



function private.msgBoxFrame:on_resize ()
	win.popupFrame.on_resize (self)

	local msg = self:get_wnd_by_id (private.ID_MSGBOX_MSG)
	if msg then
		msg:move (1, 2, self.width - 2, self.height - 3)
	end

	return true
end



function private.msgBoxFrame:set_bg_color (color)
	win.popupFrame.set_bg_color (self, color)

	local msg = self:get_wnd_by_id (private.ID_MSGBOX_MSG)
	if msg then
		msg:set_bg_color (color)
	end
end
