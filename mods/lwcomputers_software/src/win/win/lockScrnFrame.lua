local private = ...



private.lockScrnFrame = win.applicationFrame:base ()



function private.lockScrnFrame:constructor (dir)
	if not win.applicationFrame.constructor (self, dir) then
		return nil
	end

	local rtWork = self:get_desktop ():get_work_area ()
	local pwWidth = (rtWork.width < 20 and rtWork.width - 2) or 20
	local pwLeft = math.floor ((rtWork.width - pwWidth) / 2)
	local pwTop = math.floor (rtWork.height / 2)

	self.wnd__id = private.ID_LOCKSCRN
	self.wnd__frame_class = private.FRAME_CLASS_SYSTEM

	self:set_color (self:get_colors ().home_text)
	self:set_bg_color (self:get_colors ().home_back)
	self:set_text ("lock screen")

	self.title = win.labelWindow:new (self, 0, math.floor((rtWork.width - 6) / 2),
												 pwTop - 2, "Locked")
	self.title:set_color (self:get_colors ().home_text)
	self.title:set_bg_color (self:get_colors ().home_back)

	self.password = win.inputWindow:new (self, private.ID_LOCKPW, pwLeft, pwTop,
													 pwWidth, "", "Password")
	self.password:set_mask_char ("*")

	self.ok = win.buttonWindow:new (self, private.ID_LOCKOK, pwLeft + pwWidth - 4,
											  pwTop + 2, " Ok ")

	self.password:set_focus ()

	self:move (rtWork:unpack ())

	return self
end



function private.lockScrnFrame:on_resize ()
	local rtWork = self:get_desktop ():get_work_area ()
	local pwWidth = (rtWork.width < 20 and rtWork.width - 2) or 20
	local pwLeft = math.floor ((rtWork.width - pwWidth) / 2)
	local pwTop = math.floor (rtWork.height / 2)

	self:move (rtWork:unpack ())

	self.title:move (math.floor((rtWork.width - 6) / 2), pwTop - 2)
	self.password:move (pwLeft, pwTop, pwWidth)
	self.ok:move (pwLeft + pwWidth - 4, pwTop + 2)

	return true
end



function private.lockScrnFrame:on_frame_activate (active)
	if active then
		local desktop = self:get_desktop ()

		self.lockScrn__fullscreen = desktop:get_fullscreen ()
		self.lockScrn__taskbar_enabled = desktop.dt__taskbar:is_enabled ()

		desktop:dismiss_keyboard ()
		desktop.dt__taskbar:enable (false)
		desktop:set_fullscreen (true)

		self.password:set_focus ()
	end
end



function private.lockScrnFrame:on_quit ()
	return true
end



function private.lockScrnFrame:on_event (event, p1, p2, p3, p4, p5, ...)
	if event == "btn_click" then
		if p1:get_id () == private.ID_LOCKOK then
			if self.password:get_text () == self:get_desktop ():get_password () then
				local desktop = self:get_desktop ()

				self.password:set_text ("")
				self.password:set_error (false)
				desktop:set_fullscreen (self.lockScrn__fullscreen)
				desktop.dt__taskbar:enable (self.lockScrn__taskbar_enabled)
				desktop:hide_lock_screen ()
			else
				self.password:set_text ("")
				self.password:set_error (true)
				self.password:invalidate ()
				self.password:set_focus ()
			end

			return true
		end
	end

	return false
end



function private.lockScrnFrame:on_child_key (wnd, key, ctrl, alt, shift)
	if win.popupFrame.on_child_key (self, wnd, key, ctrl, alt, shift) then
		return true
	end

	if not ctrl and not alt and not shift then
		if key == keys.KEY_ENTER then
			self:send_event ("btn_click", self.ok)

			return true
		end
	end

	return false
end
