local private = ...



win.inputWindow = win.window:base ()



function win.inputWindow:constructor (parent, id, x, y, width, text, banner)
	if not win.window.constructor (self, parent, id, x, y, width, 1) then
		return nil
	end

	self.input__banner = ""
	self.input__old_text = ""
	self.input__mask_char = ""
	self.input__error = false
	self.input__hOrg = 0
	self.input__end = 0
	self.input__start = 0
	self.input__maxLen = 0
	self.input__colors =
	{
		text = self:get_colors ().input_text,
		back = self:get_colors ().input_back,
		focus = self:get_colors ().input_focus,
		error = self:get_colors ().input_error,
		banner = self:get_colors ().input_banner
	}

	self:set_color (self.input__colors.text)
	self:set_bg_color (self.input__colors.back)
	self:set_want_key_input (win.KEYINPUT_LINE)
	self:set_banner (banner)
	self:set_text (text)

	return self
end



function win.inputWindow:set_colors (text, background, focus, banner, errorColor)
	self.input__colors.text = text
	self.input__colors.back = background
	self.input__colors.focus = focus
	self.input__colors.error = errorColor
	self.input__colors.banner = banner

	self:set_color (text)
	self:set_bg_color ((self:get_focus () == self and focus) or background)
end



function win.inputWindow:set_banner (banner)
	self.input__banner = tostring (banner or "")
	self:invalidate ()
end



function win.inputWindow:set_mask_char (char)
	self.input__mask_char = tostring (char or "")
	self:invalidate ()
end



function win.inputWindow:get_mask_char ()
	return self.input__mask_char
end



function win.inputWindow:get_banner ()
	return self.input__banner
end



function win.inputWindow:get_error ()
	return self.input__error
end



function win.inputWindow:set_error (err)
	err = (err ~= false)

	if err ~= self.input__error then
		self.input__error = err

		self:set_bg_color ((self.input__error and self.input__colors.error) or
								  ((self:get_focus () == self and self.input__colors.focus) or
									self.input__colors.back))
	end
end



function win.inputWindow:set_max_len (maxLen)
	self.input__maxLen = tonumber (maxLen) or 0

	if self.input__maxLen < 1 then
		self.input__maxLen = 0
	end
end



function win.inputWindow:get_max_len ()
	return self.input__maxLen
end



function win.inputWindow:set_sel (sel_start, sel_end, auto_scroll)
	local strLen = self:get_text ():len ()

	sel_start = tonumber (sel_start) or 0

	if sel_start < 0 then
		sel_start = 0
	elseif sel_start > strLen then
		sel_start = strLen
	end

	if sel_end == nil then
		sel_end = sel_start
	elseif sel_end == -1 then
		sel_end = strLen
	elseif sel_end < 0 then
		sel_end = 0
	elseif sel_end > strLen then
		sel_end = strLen
	end

	self.input__end = sel_end
	self.input__start = sel_start

	if auto_scroll ~= false then
		if (self.input__end - self.input__hOrg) <= 0 then
			self.input__hOrg = self.input__end - math.floor (self.width / 2)

			if self.input__hOrg < 0 then
				self.input__hOrg = 0
			end
		end

		if (self.input__end - self.input__hOrg) >= self.width then
			self.input__hOrg = self.input__end - self.width + 1
		end
	end

	self:invalidate ()

	if self:get_focus () == self then
		self:set_cursor_pos (self.input__end - self.input__hOrg, 0)
	end
end



function win.inputWindow:get_sel (normalise)
	if normalise then
		if self.input__end < self.input__start then
			return self.input__end, self.input__start
		end
	end

	return self.input__start, self.input__end
end



function win.inputWindow:replace_sel (replaceText, auto_scroll)
	local ss, se = self:get_sel (true)
	local str = self:get_text ():sub (1, ss)..tostring (replaceText or "")..
								self:get_text ():sub (se + 1)

	if self.input__maxLen > 0 then
		if str:len () > self.input__maxLen then
			str = str:sub (1, self.input__maxLen)
		end
	end

	self:set_text (str)
	se = ss + tostring (replaceText or ""):len ()
	self:set_sel (se, se, auto_scroll)
end



function win.inputWindow:get_selection ()
	local ss, se = self:get_sel (true)

	return self:get_text ():sub ((ss + 1), se)
end



function win.inputWindow:cut ()
	local strSel = self:get_selection ()

	if strSel:len() > 0 then
		self:set_clipboard (strSel, win.CB_TEXT)
		self:replace_sel ("")
	end
end



function win.inputWindow:copy ()
	local strSel = self:get_selection ()

	if strSel:len() > 0 then
		self:set_clipboard (strSel, win.CB_TEXT)
	end
end



function win.inputWindow:paste ()
	local cbType, cbData = self:get_clipboard ()

	if cbType == win.CB_TEXT then
		self:replace_sel (cbData)
	end
end



function win.inputWindow:draw (gdi, bounds)
	gdi:set_colors (nil, self:get_bg_color ())

	if self:get_text ():len () == 0 then
		if self:get_banner ():len () > 0 then
			gdi:set_colors (self.input__colors.banner)
			gdi:write (self:get_banner (), 0, 0)
		end
	else
		local displayText;
		local ss, se = self:get_sel (true)

		if self.input__mask_char:len () > 0 then
			displayText = string.rep (self.input__mask_char, self:get_text ():len ())
		else
			displayText = self:get_text ()
		end

		if ss == se then
			gdi:set_colors (self:get_color ())
			gdi:write (displayText, (self.input__hOrg * -1), 0)
		else
			local left = (self.input__hOrg * -1)
			local strPre, strSel, strPost =
				displayText:sub (1, ss),
				displayText:sub (ss + 1, se),
				displayText:sub (se + 1)

			gdi:set_colors (self:get_color ())
			gdi:write (strPre, left, 0)
			left = left + strPre:len ()

			gdi:set_colors (self:get_colors ().selected_text, self:get_colors ().selected_back)
			gdi:write (strSel, left, 0)
			left = left + strSel:len ()

			gdi:set_colors (self:get_color (), self:get_bg_color ())
			gdi:write (strPost, left, 0)
		end
	end
end



function win.inputWindow:set_text (text)
	win.window.set_text (self, text)

	local ss, se = self:get_sel (false)
	local strLen = self:get_text ():len ()

	if ss > strLen then
		ss = strLen
	end

	if se > strLen then
		se = strLen
	end

	self:set_sel (ss, se)
end



function win.inputWindow:on_focus (blurred)
	self:set_bg_color ((self.input__error and self.input__colors.error) or
							  self.input__colors.focus)

	self:set_cursor_pos (self.input__end - self.input__hOrg, 0)

	self.input__old_text = self:get_text ()

	return false
end



function win.inputWindow:on_blur (focused)
	self:hide_cursor ()
	self:set_bg_color ((self.input__error and self.input__colors.error) or
							  self.input__colors.back)

	if self.input__old_text ~= self:get_text () then
		if self:get_parent () then
			self:get_parent ():send_event ("input_change", self)
		end
	end

	return false
end



function win.inputWindow:on_key (key, ctrl, alt, shift)
	if not ctrl and not alt and not shift then
		local ss, se = self:get_sel (false)

		if key == keys.KEY_BACKSPACE then
			if ss == se then
				self:set_sel (ss - 1, ss, false)
			end

			self:replace_sel ("")

			return true

		elseif key == keys.KEY_DELETE then
			if ss == se then
				self:set_sel (ss, ss + 1, false)
			end

			self:replace_sel ("")

			return true

		elseif key == keys.KEY_LEFT then
			if se >= 1 then
				self:set_sel (se - 1, se - 1)
			end

			return true

		elseif key == keys.KEY_RIGHT then
			self:set_sel (se + 1, se + 1)

			return true

		elseif key == keys.KEY_HOME then
			self:set_sel (0, 0)

			return true

		elseif key == keys.KEY_END then
			self:set_sel (self:get_text ():len (), -1)

			return true

		end

	elseif not ctrl and not alt and shift then
		local ss, se = self:get_sel (false)

		if key == keys.KEY_LEFT then
			if se >= 1 then
				self:set_sel (ss, se - 1)
			end

			return true

		elseif key == keys.KEY_RIGHT then
			self:set_sel (ss, se + 1)

			return true

		elseif key == keys.KEY_HOME then
			self:set_sel (ss, 0)

			return true
		elseif key == keys.KEY_END then
			self:set_sel (ss, -1)

			return true

		end

	elseif ctrl and not alt and not shift then
		if key == keys.KEY_X then
			self:cut ()

			return true

		elseif key == keys.KEY_C then
			self:copy ()

			return true

		elseif key == keys.KEY_V then
			self:paste ()

			return true

		elseif key == keys.KEY_A then
			self:set_sel (0, -1)

			return true
		end
	end

	return false
end



function win.inputWindow:on_char (char, ascii)
	if ascii >= keys.KEY_SPACE and ascii <= keys.KEY_TILDE then
		self:replace_sel (char)
	end

	return true
end



function win.inputWindow:on_left_click (x, y, count)
	if win.window.on_left_click (self, x, y, count) then
		return true
	end

	local shift = os.key_state (keys.KEY_SHIFT)

	if shift then
		local ss, se = self:get_sel (false)
		self:set_sel (ss, x + self.input__hOrg)
	else
		self:set_sel (x + self.input__hOrg, x + self.input__hOrg)
	end

	return true
end



function win.inputWindow:on_left_drag (x, y)
	local ss, se = self:get_sel (false)
	self:set_sel (ss, x + self.input__hOrg)

	return true
end



function win.inputWindow:on_touch (x, y)
	if win.window.on_touch (self, x, y) then
		return true
	end

	local shift = os.key_state (keys.KEY_SHIFT)

	if shift then
		local ss, se = self:get_sel (false)
		self:set_sel (ss, x + self.input__hOrg)
	else
		self:set_sel (x + self.input__hOrg, x + self.input__hOrg)
	end

	return true
end



function win.inputWindow:on_move ()
	if self:get_focus () == self then
		self:show_cursor ()
	end

	return false
end



function win.inputWindow:on_clipboard (text)
	if tostring (text or ""):len () > 0 then
		self:replace_sel (tostring (text or ""))
	end

	return true
end
