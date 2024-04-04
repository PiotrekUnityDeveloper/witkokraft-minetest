local private = ...



-- forward declared in popupFrame.lua
-- private.parentFrame = window:base()



function private.parentFrame:constructor (desktop, id, x, y, width, height)
	if not win.window.constructor (self, desktop, id, x, y, width, height) then
		return nil
	end

	self.pFrame__focused_wnd = nil
	self.pFrame__continue_modal = false
	self.pFrame__modal_result = nil


	self.pFrame__tabbed_win = nil
	self.pFrame__tabbed_time = 0

	self:set_want_focus (false)
	self:set_color (self:get_colors ().frame_text)
	self:set_bg_color (self:get_colors ().frame_back)

	return self
end



function private.parentFrame:get_owner ()
	if self.wnd__owner then
		return self.wnd__owner
	end

	return self
end



function private.parentFrame:get_popup ()
	return self.wnd__popup
end



function private.parentFrame:get_active_frame ()
	local frame = self

	while frame:get_popup () do
		frame = frame:get_popup ()
	end

	return frame
end



function private.parentFrame:set_active_top_frame ()
	if self:get_desktop ():set_active_frame (self) then
		if self:get_popup () then
			return self:get_popup ():set_active_top_frame ()
		end

		return true
	end

	return false
end



function private.parentFrame:on_frame_activate (active)
end



function private.parentFrame:set_focus_wnd (wnd)
	local desktop = self:get_desktop ()

	if wnd then
		if not wnd:is_enabled () or not wnd:is_shown () then
			return false
		end
	end

	if desktop then
		if desktop:get_active_frame () ~= self then
			local focus_wnd = wnd

			if not focus_wnd then
				focus_wnd = self:next_wnd (nil, true)
			end

			self.pFrame__focused_wnd = focus_wnd

			return true
		else
			local focus_wnd = wnd

			if not focus_wnd then
				if self.pFrame__focused_wnd then
					focus_wnd = self:prior_wnd (self.pFrame__focused_wnd, true)

					if focus_wnd == self.pFrame__focused_wnd then
						focus_wnd = nil
					end
				else
					focus_wnd = self:next_wnd (nil, true)
				end
			end

			if self.pFrame__focused_wnd then
				if not self:route_event (self.pFrame__focused_wnd, "blur", focus_wnd) then
					self.pFrame__focused_wnd:send_event ("blur", focus_wnd)
				end

				self.pFrame__focused_wnd:invalidate ()
			end

			if focus_wnd then
				if not self:route_event (focus_wnd, "focus", self.pFrame__focused_wnd) then
					focus_wnd:send_event ("focus", self.pFrame__focused_wnd)
				end

				focus_wnd:invalidate ()
			end

			self.pFrame__focused_wnd = focus_wnd

			return true
		end
	end

	return false
end



function private.parentFrame:next_wnd (wnd, focusable)
	for i = self:child_index (wnd) + 1, self:children (), 1 do
		local next_wnd = self:get_child (i)

		if next_wnd then
			if (next_wnd:get_want_focus () and next_wnd:is_shown () and next_wnd:is_enabled ())
					or (not focusable) then
				return next_wnd
			end
		end
	end

	for i = 1, self:children (), 1 do
		local next_wnd = self:get_child (i)

		if next_wnd then
			if (next_wnd:get_want_focus () and next_wnd:is_shown () and next_wnd:is_enabled ())
					or (not focusable) then
				return next_wnd
			end
		end
	end

	return nil
end



function private.parentFrame:prior_wnd (wnd, focusable)
	for i = self:child_index (wnd) - 1, 1, -1 do
		local next_wnd = self:get_child (i)

		if next_wnd then
			if (next_wnd:get_want_focus () and next_wnd:is_shown () and next_wnd:is_enabled ())
					or (not focusable) then
				return next_wnd
			end
		end
	end

	for i = self:children (), 1, -1 do
		local next_wnd = self:get_child (i)

		if next_wnd then
			if (next_wnd:get_want_focus () and next_wnd:is_shown () and next_wnd:is_enabled ())
					or (not focusable) then
				return next_wnd
			end
		end
	end

	return nil
end



function private.parentFrame:on_child_key (wnd, key, ctrl, alt, shift)
	self.pFrame__tabbed_win = nil
	self.pFrame__tabbed_time = 0

	if not alt and not ctrl then
		if shift then
			if key == keys.KEY_TAB then
				local next_wnd = self:prior_wnd (self.pFrame__focused_wnd, true)

				if next_wnd and next_wnd ~= self.pFrame__focused_wnd then
					self.pFrame__tabbed_win = next_wnd
					self.pFrame__tabbed_time = os.clock ()

					next_wnd:set_focus ()
				end

				return true
			end
		else
			if key == keys.KEY_TAB then
				local next_wnd = self:next_wnd (self.pFrame__focused_wnd, true)

				if next_wnd and next_wnd ~= self.pFrame__focused_wnd then
					self.pFrame__tabbed_win = next_wnd
					self.pFrame__tabbed_time = os.clock ()

					next_wnd:set_focus ()
				end

				return true
			end
		end
	end

	return false
end



function private.parentFrame:on_child_char (wnd, char, ascii)
	if ascii == keys.KEY_TAB and wnd == self.pFrame__tabbed_win and
			(os.clock () - self.pFrame__tabbed_time) < 0.5 then
		return true
	end

	return false
end



function private.parentFrame:msgbox (title, message, bg_color)
	local msgbox = private.msgBoxFrame:new (self)

	if bg_color then
		msgbox:set_bg_color (tonumber (bg_color) or 0)
	end

	msgbox:do_modal (title, message)
end



function private.parentFrame:run_modal ()
	local last_result = true
	self.pFrame__continue_modal = true

	while self.pFrame__continue_modal do
		local event = { coroutine.yield ("modal", last_result) }

		last_result = true
		if event[1] then
			local frame = event[1]:get_parent_frame ()

			if frame and (event[1] ~= frame) then
				if frame:route_event (unpack (event)) then
					event[1] = nil
				end
			end

			if event[1] then
				last_result = event[1]:route_event (unpack (event))
			end
		else
			last_result = false
		end
	end

	return self.pFrame__modal_result
end



function private.parentFrame:end_modal (result)
	self.pFrame__modal_result = result
	self.pFrame__continue_modal = false
end



function private.parentFrame:create_popup (width, height)
	if self.wnd__popup then
		return nil
	end

	return win.popupFrame:new (self, width, height)
end
