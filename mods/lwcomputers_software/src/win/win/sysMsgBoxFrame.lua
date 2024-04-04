local private = ...



private.sysMsgBoxFrame = win.applicationFrame:base ()



function private.sysMsgBoxFrame:constructor (dir)
	if not win.applicationFrame.constructor (self, dir) then
		return nil
	end

	local title = "No Error"
	local message = "No message"

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

	self.wnd__id = private.ID_SYSMSGBOX
	self.wnd__frame_class = private.FRAME_CLASS_SYSTEM

	self:dress (title)
	win.textWindow:new (self, private.ID_MSGBOX_MSG, 1, 2, width - 2, height - 3, message)

	self:set_bg_color (self:get_colors ().popup_back)

	self:move (nil, nil, width, height)

	return self
end



function private.sysMsgBoxFrame:on_resize ()
	local msg = self:get_wnd_by_id (private.ID_MSGBOX_MSG)
	if msg then
		msg:move (1, 2, self.width - 2, self.height - 3)
	end

	local text = self:get_wnd_by_id  (win.ID_TITLEBAR)
	if text then
		text:move (math.floor ((self.width - text:get_text ():len ()) / 2))
	end

	local xbtn = self:get_wnd_by_id (win.ID_CLOSE)
	if xbtn then
		xbtn:move (self.width - 1)
	end

	return true
end



function private.sysMsgBoxFrame:draw (gdi, bounds)
	win.applicationFrame.draw (self, gdi, bounds)

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



function private.sysMsgBoxFrame:set_bg_color (color)
	win.applicationFrame.set_bg_color (self, color)

	local msg = self:get_wnd_by_id (private.ID_MSGBOX_MSG)
	if msg then
		msg:set_bg_color (color)
	end
end



function private.sysMsgBoxFrame:on_frame_activate (active)
	local desktop = self:get_desktop ()

	if active then
		self.sysMsgBox__taskbar_enabled = desktop.dt__taskbar:is_enabled ()

		desktop.dt__taskbar:enable (false)

		if self.sysMsgBox__active_frame then
			self.sysMsgBox__active_frame_enabled = self.sysMsgBox__active_frame:is_enabled ()
			self.sysMsgBox__active_frame:enable (false)
		end
	else
		desktop.dt__taskbar:enable (self.sysMsgBox__taskbar_enabled)

		if self.sysMsgBox__active_frame then
			self.sysMsgBox__active_frame:enable (self.sysMsgBox__active_frame_enabled)
		end

		self.sysMsgBox__active_frame = nil
	end
end



function private.sysMsgBoxFrame:on_quit ()
	self:get_desktop ():hide_msgbox ()

	return true
end



function private.sysMsgBoxFrame:do_msgbox (title, message, bgcolor, active_frame)
	title = tostring (title or "")
	message = tostring (message or "")
	bgcolor = bgcolor or self:get_colors ().popup_back

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

	if width < (title:len() + 3) then
		width = title:len() + 3
	end

	if height < 4 then
		height = 4
	elseif height > max_height then
		height = max_height
	end

	local left, top = math.floor ((rtWork.width - width) / 2),
							math.floor ((rtWork.height - height) / 2)

	self.sysMsgBox__active_frame = active_frame

	self:set_title (title)
	self:set_bg_color (bgcolor)

	local msg = self:get_wnd_by_id (private.ID_MSGBOX_MSG)
	if msg then
		msg:set_text (message)
		msg:move (1, 2, width - 2, height - 3)
	end

	local text = self:get_wnd_by_id  (win.ID_TITLEBAR)
	if text then
		text:move (math.floor ((width - text:get_text ():len ()) / 2))
	end

	local xbtn = self:get_wnd_by_id (win.ID_CLOSE)
	if xbtn then
		xbtn:move (width - 1)
	end

	self:move (left, top, width, height)

	self:set_active_top_frame ()
end
