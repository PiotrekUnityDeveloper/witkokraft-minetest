local private = ...



local kb_maps = { full = { }, brief = { } }



private.keyboardFrame = win.applicationFrame:base ()



function private.keyboardFrame:constructor (dir, target_wnd)
	if not win.applicationFrame.constructor (self, dir) then
		return nil
	end

	self.wnd__id = private.ID_KEYBOARD
	self.wnd__frame_class = private.FRAME_CLASS_SYSTEM
	self.kb_text_color = self:get_colors ().kb_text
	self.kb_bg_color = self:get_colors ().kb_back
	self.std_color = self:get_colors ().kb_key
	self.cmd_color = self:get_colors ().kb_cmd
	self.cancel_color = self:get_colors ().kb_cancel
	self.toggle_color = self:get_colors ().kb_toggle
	self.caps_state = false
	self.shift_state = false
	self.ctrl_state = false
	self.alt_state = false
	self.keys_left = 0
	self.keys_top = 0

	self.target_wnd = nil
	self.target_parent = nil
	self.target_parent_frame = nil
	self.target_rect = nil
	self.target_z = nil

	if target_wnd then
		self.target_wnd = target_wnd
		self.target_parent = target_wnd:get_parent ()
		self.target_rect = target_wnd:get_wnd_rect ()
		self.target_parent_frame = target_wnd:get_parent_frame ()

		if target_wnd:get_parent () then
			self.target_z = target_wnd:get_parent ():child_index (target_wnd)
		end
	end

	self:set_text ("keyboard")

	return self
end



function private.keyboardFrame:std_key_color ()
	return self.std_color
end



function private.keyboardFrame:no_key_color ()
	return self.kb_bg_color
end



function private.keyboardFrame:cmd_key_color ()
	return self.cmd_color
end



function private.keyboardFrame:cancel_key_color ()
	return self.cancel_color
end



function private.keyboardFrame:ctrl_key_color ()
	if self.ctrl_state then
		return self.toggle_color
	end

	return self.cmd_color
end



function private.keyboardFrame:shift_key_color ()
	if self.shift_state then
		return self.toggle_color
	end

	return self.cmd_color
end



function private.keyboardFrame:caps_key_color ()
	if self.caps_state then
		return self.toggle_color
	end

	return self.cmd_color
end



function private.keyboardFrame:alt_key_color ()
	if self.alt_state then
		return self.toggle_color
	end

	return self.cmd_color
end


function private.keyboardFrame:get_key_def (x, y)
	local cx, cy = x - self.keys_left + 1, y - self.keys_top + 1

	if cy > 0 and cy <= table.maxn (self.key_map) and
			cx > 0 and cx <= table.maxn (self.key_map[1]) then
		local kd = self.key_map[cy][cx]
		local result =
		{
			char_event = kd.char_event,
			color = kd.color
		}

		if kd.code >= keys.KEY_A and kd.code <= keys.KEY_Z then
			if self.caps_state then
				if self.shift_state then
					result.code = kd.code
				else
					result.code = kd.alt_code
				end
			elseif self.shift_state then
				result.code = kd.alt_code
			else
				result.code = kd.code
			end

			if not self.ctrl_state and not self.alt_state and kd.char_event then
				if self.caps_state then
					if self.shift_state then
						result.char = kd.shift_caps_char
					else
						result.char = kd.caps_char
					end
				elseif self.shift_state then
					result.char = kd.shift_char
				else
					result.char = kd.char
				end
			end

		else
			if self.shift_state then
				result.code = kd.alt_code
			else
				result.code = kd.code
			end

			if not self.ctrl_state and not self.alt_state and kd.char_event then
				if self.caps_state then
					if self.shift_state then
						result.char = kd.shift_caps_char
					else
						result.char = kd.caps_char
					end
				elseif self.shift_state then
					result.char = kd.shift_char
				else
					result.char = kd.char
				end
			end
		end

		return result
	end

	return nil
end



function private.keyboardFrame:dismiss ()
	self:quit_app ()
end



function private.keyboardFrame:draw (gdi, bounds)
	gdi:set_colors (self.kb_text_color, self.kb_bg_color)

	gdi:clear (0, 0, self:get_client_size ())

	for y = 1, table.maxn (self.key_map), 1 do
		for x = 1, table.maxn (self.key_map[y]), 1 do
			local kd = self.key_map[y][x]

			gdi:set_colors (nil, kd.color (self))

			if self.caps_state then
				if self.shift_state then
					gdi:write (kd.shift_caps_char, self.keys_left + x - 1, self.keys_top + y - 1)
				else
					gdi:write (kd.caps_char, self.keys_left + x - 1, self.keys_top + y - 1)
				end
			else
				if self.shift_state then
					gdi:write (kd.shift_char, self.keys_left + x - 1, self.keys_top + y - 1)
				else
					gdi:write (kd.char, self.keys_left + x - 1, self.keys_top + y - 1)
				end
			end
		end
	end
end



function private.keyboardFrame:on_touch (x, y)
	local kd = self:get_key_def (x, y)

	self.target_wnd:set_focus ()

	if kd then
		if kd.code ~= 0 then
			if kd.code == keys.KEY_ALT then
				if self.alt_state then
					self.alt_state = false
				else
					self.alt_state = true
					self.target_wnd:send_event ("key", kd.code, self.ctrl_state,
														 self.alt_state, self.shift_state)
				end

				self:invalidate ()
				return true

			elseif kd.code == keys.KEY_CTRL then
				if self.ctrl_state then
					self.ctrl_state = false
				else
					self.ctrl_state = true
					self.target_wnd:send_event ("key", kd.code, self.ctrl_state,
														 self.alt_state, self.shift_state)
				end

				self:invalidate ()
				return true

			elseif kd.code == keys.KEY_SHIFT then
				if self.shift_state then
					self.shift_state = false
				else
					self.shift_state = true
					self.target_wnd:send_event ("key", kd.code, self.ctrl_state,
														 self.alt_state, self.shift_state)
				end

				self:invalidate ()
				return true

			elseif kd.code == keys.KEY_CAPS then
				if self.caps_state then
					self.caps_state = false
				else
					self.caps_state = true
					self.target_wnd:send_event ("key", kd.code, self.ctrl_state,
														 self.alt_state, self.shift_state)
				end

				self:invalidate ()
				return true

			end

			if kd.code ~= 300 then
				self.target_wnd:send_event ("key", kd.code, self.ctrl_state,
													  self.alt_state, self.shift_state)

				if kd.char then
					self.target_wnd:send_event ("char", kd.char, kd.code)
				end

				if kd.char_event then
					if self.ctrl_state or self.alt_state or self.shift_state then
						self.ctrl_state = false
						self.alt_state = false
						self.shift_state = false
						self:invalidate ()

						return true
					end
				end
			end

			if kd.code == 300 then
				if self:get_desktop () then
					self:get_desktop ():dismiss_keyboard ()
				end

				return true

			elseif kd.code == keys.KEY_ENTER then
				if self.target_wnd:get_want_key_input () == win.KEYINPUT_LINE then
					if self:get_desktop () then
						self:get_desktop ():dismiss_keyboard ()
					end

					return true
				end
			end

		end
	end

	return true
end



function private.keyboardFrame:on_resize ()
	local szWidth, szHeight = self.gdi:get_size ()
	local tLeft, tTop, tWidth, tHeight = self.target_rect:unpack ()

	self.key_map = (szWidth < 20 and kb_maps.brief) or kb_maps.full
	self.keys_left = math.floor ((szWidth - ((szWidth < 20 and 15) or 20)) / 2)
	self.keys_top = ((szHeight - self:get_theme ().keyboard_height) < 4 and 4) or
									(szHeight - self:get_theme ().keyboard_height)

	tHeight = ((tHeight > (self.keys_top - 2)) and (self.keys_top - 2)) or tHeight
	tWidth = ((tWidth > szWidth) and szWidth) or tWidth
	tLeft = math.floor ((szWidth - tWidth) / 2)
	tTop = self.keys_top - tHeight - 1

	self:move (0, 0, szWidth, szHeight)

	if self.target_wnd then
		self.target_wnd:move (tLeft, tTop, tWidth, tHeight)
	end

	return true
end



function private.keyboardFrame:on_event (event, p1, p2, p3, p4, p5, ...)
	if p1 == self.target_wnd then
		if self.target_parent then
			self.target_parent:send_event (event, p1, p2, p3, p4, p5)
		end
	end

	return true
end



function private.keyboardFrame:on_create ()
	self:set_color (self.kb_text_color)
	self:set_bg_color (self.kb_bg_color)
	self.key_map = kb_maps.full

	if self.target_wnd then
		self.target_wnd:set_parent (self)

		self.target_wnd:set_suspend_keyboard (true)

		if self.target_parent_frame then
			self.target_parent_frame:set_focus_wnd (nil)
		end

		self.target_wnd:set_focus ()
	end

	self:set_active_top_frame ()

	self:on_resize ()

	return true
end



function private.keyboardFrame:on_quit ()
	if self.target_wnd then
		local tZ;

		self.target_wnd:set_parent (self.target_parent)
		self:set_focus_wnd (nil)

		if self.target_parent and self.target_z then
			tZ = (self.target_z - self.target_parent:child_index (self.target_wnd))
			tZ = ((tZ == 0) and nil) or tZ
		end

		self.target_wnd:move (self.target_rect.x, self.target_rect.y,
									 self.target_rect.width, self.target_rect.height, tZ)

		self.target_wnd:set_suspend_keyboard (false)
		self.target_wnd:set_focus ()
		self.target_wnd = nil

		if self.target_parent_frame then
			self.target_parent_frame:set_active_top_frame ()
		end
	end

	return false
end



local function kbKeydef (char_event, code, alt_code, char, shift_char,
								 caps_char, shift_caps_char, color_func)
	return
	{
		char_event = char_event,
		code = code,
		alt_code = alt_code,
		char = char,
		shift_char = shift_char,
		caps_char = caps_char,
		shift_caps_char = shift_caps_char,
		color = color_func
	}
end



kb_maps.full =
{
	{
		kbKeydef (false, 300, 300, "x", "x", "x", "x", private.keyboardFrame.cancel_key_color),
		kbKeydef (true, keys.KEY_TILDE, keys.KEY_TILDE, "~", "~", "~", "~", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_1, keys.KEY_EXCLAIM, "1", "!", "1", "!", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_2, keys.KEY_AT, "2", "@", "2", "@", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_3, keys.KEY_HASH, "3", "#", "3", "#", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_4, keys.KEY_CURRENCY, "4", "$", "4", "$", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_5, keys.KEY_PERCENT, "5", "%", "5", "%", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_6, keys.KEY_CARET, "6", "^", "6", "^", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_7, keys.KEY_AMP, "7", "&", "7", "&", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_8, keys.KEY_MULTIPLY, "8", "*", "8", "*", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_9, keys.KEY_OPENPAREN, "9", "(", "9", "(", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_0, keys.KEY_CLOSEPAREN, "0", ")", "0", ")", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SUBTRACT, keys.KEY_UNDERSCORE, "-", "_", "-", "_", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_EQUAL, keys.KEY_ADD, "=", "+", "=", "+", private.keyboardFrame.std_key_color),
		kbKeydef (false, keys.KEY_BACKSPACE, keys.KEY_BACKSPACE, "b", "b", "b", "b", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_BACKSPACE, keys.KEY_BACKSPACE, "s", "s", "s", "s", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (false, keys.KEY_INSERT, keys.KEY_INSERT, "I", "I", "I", "I", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_HOME, keys.KEY_HOME, "H", "H", "H", "H", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_PAGEUP, keys.KEY_PAGEUP, "P", "P", "P", "P", private.keyboardFrame.cmd_key_color)
	},
	{
		kbKeydef (false, keys.KEY_TAB, keys.KEY_TAB, "t", "t", "t", "t", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_TAB, keys.KEY_TAB, "b", "b", "b", "b", private.keyboardFrame.cmd_key_color),
		kbKeydef (true, keys.KEY_Q, keys.KEY_Q, "q", "Q", "Q", "q", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_W, keys.KEY_W, "w", "W", "W", "w", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_E, keys.KEY_E, "e", "E", "E", "e", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_R, keys.KEY_R, "r", "R", "R", "r", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_T, keys.KEY_T, "t", "T", "T", "t", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_Y, keys.KEY_Y, "y", "Y", "Y", "y", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_U, keys.KEY_U, "u", "U", "U", "u", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_I, keys.KEY_I, "i", "I", "I", "i", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_O, keys.KEY_O, "o", "O", "O", "o", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_P, keys.KEY_P, "p", "P", "P", "p", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_OPENSQUARE, keys.KEY_OPENBRACE, "[", "{", "[", "{", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_CLOSESQUARE, keys.KEY_CLOSEBRACE, "]", "}", "]", "}", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SLASH, keys.KEY_BAR, "\\", "|", "\\", "|", private.keyboardFrame.std_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (false, keys.KEY_DELETE, keys.KEY_DELETE, "D", "D", "D", "D", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_END, keys.KEY_END, "E", "E", "E", "E", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_PAGEDOWN, keys.KEY_PAGEDOWN, "N", "N", "N", "N", private.keyboardFrame.cmd_key_color)
	},
	{
		kbKeydef (false, keys.KEY_CAPS, keys.KEY_CAPS, "c", "c", "c", "c", private.keyboardFrame.caps_key_color),
		kbKeydef (false, keys.KEY_CAPS, keys.KEY_CAPS, "l", "l", "l", "l", private.keyboardFrame.caps_key_color),
		kbKeydef (true, keys.KEY_A, keys.KEY_A, "a", "A", "A", "a", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_S, keys.KEY_S, "s", "S", "S", "s", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_D, keys.KEY_D, "d", "D", "D", "d", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_F, keys.KEY_F, "f", "F", "F", "f", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_G, keys.KEY_G, "g", "G", "G", "g", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_H, keys.KEY_H, "h", "H", "H", "h", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_J, keys.KEY_J, "j", "J", "J", "j", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_K, keys.KEY_K, "k", "K", "K", "k", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_L, keys.KEY_L, "l", "L", "L", "l", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SEMICOLON, keys.KEY_COLON, ";", ":", ";", ":", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_APOSTROPHE, keys.KEY_QUOTE, "'", "\"", "'", "\"", private.keyboardFrame.std_key_color),
		kbKeydef (false, keys.KEY_ENTER, keys.KEY_ENTER, "e", "e", "e", "e", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_ENTER, keys.KEY_ENTER, "n", "n", "n", "n", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_ENTER, keys.KEY_ENTER, "t", "t", "t", "t", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
	},
	{
		kbKeydef (false, keys.KEY_SHIFT, keys.KEY_SHIFT, "s", "s", "s", "s", private.keyboardFrame.shift_key_color),
		kbKeydef (false, keys.KEY_SHIFT, keys.KEY_SHIFT, "f", "f", "f", "f", private.keyboardFrame.shift_key_color),
		kbKeydef (false, keys.KEY_SHIFT, keys.KEY_SHIFT, "t", "t", "t", "t", private.keyboardFrame.shift_key_color),
		kbKeydef (true, keys.KEY_Z, keys.KEY_Z, "z", "Z", "Z", "z", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_X, keys.KEY_X, "x", "X", "X", "x", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_C, keys.KEY_C, "c", "C", "C", "c", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_V, keys.KEY_V, "v", "V", "V", "v", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_B, keys.KEY_B, "b", "B", "B", "b", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_N, keys.KEY_N, "n", "N", "N", "n", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_M, keys.KEY_M, "m", "M", "M", "m", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_COMMA, keys.KEY_LESS, ",", "<", ",", "<", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_DOT, keys.KEY_GREATER, ".", ">", ".", ">", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_DIVIDE, keys.KEY_QUESTION, "/", "?", "/", "?", private.keyboardFrame.std_key_color),
		kbKeydef (false, keys.KEY_SHIFT, keys.KEY_SHIFT, "s", "s", "s", "s", private.keyboardFrame.shift_key_color),
		kbKeydef (false, keys.KEY_SHIFT, keys.KEY_SHIFT, "f", "f", "f", "f", private.keyboardFrame.shift_key_color),
		kbKeydef (false, keys.KEY_SHIFT, keys.KEY_SHIFT, "t", "t", "t", "t", private.keyboardFrame.shift_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (false, keys.KEY_UP, keys.KEY_UP, "^", "^", "^", "^", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color)
	},
	{
		kbKeydef (false, keys.KEY_CTRL, keys.KEY_CTRL, "c", "c", "c", "c", private.keyboardFrame.ctrl_key_color),
		kbKeydef (false, keys.KEY_CTRL, keys.KEY_CTRL, "t", "t", "t", "t", private.keyboardFrame.ctrl_key_color),
		kbKeydef (false, keys.KEY_CTRL, keys.KEY_CTRL, "l", "l", "l", "l", private.keyboardFrame.ctrl_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (false, keys.KEY_ALT, keys.KEY_ALT, "a", "a", "a", "a", private.keyboardFrame.alt_key_color),
		kbKeydef (false, keys.KEY_ALT, keys.KEY_ALT, "l", "l", "l", "l", private.keyboardFrame.alt_key_color),
		kbKeydef (false, keys.KEY_ALT, keys.KEY_ALT, "t", "t", "t", "t", private.keyboardFrame.alt_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (false, keys.KEY_LEFT, keys.KEY_LEFT, "<", "<", "<", "<", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_DOWN, keys.KEY_DOWN, "v", "v", "v", "v", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_RIGHT, keys.KEY_RIGHT, ">", ">", ">", ">", private.keyboardFrame.cmd_key_color)
	}
}



kb_maps.brief =
{
	{
		kbKeydef (true, keys.KEY_TILDE, keys.KEY_TILDE, "~", "~", "~", "~", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_1, keys.KEY_EXCLAIM, "1", "!", "1", "!", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_2, keys.KEY_AT, "2", "@", "2", "@", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_3, keys.KEY_HASH, "3", "#", "3", "#", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_4, keys.KEY_CURRENCY, "4", "$", "4", "$", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_5, keys.KEY_PERCENT, "5", "%", "5", "%", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_6, keys.KEY_CARET, "6", "^", "6", "^", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_7, keys.KEY_AMP, "7", "&", "7", "&", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_8, keys.KEY_MULTIPLY, "8", "*", "8", "*", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_9, keys.KEY_OPENPAREN, "9", "(", "9", "(", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_0, keys.KEY_CLOSEPAREN, "0", ")", "0", ")", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SUBTRACT, keys.KEY_UNDERSCORE, "-", "_", "-", "_", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_EQUAL, keys.KEY_ADD, "=", "+", "=", "+", private.keyboardFrame.std_key_color),
		kbKeydef (false, keys.KEY_BACKSPACE, keys.KEY_BACKSPACE, "b", "b", "b", "b", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_BACKSPACE, keys.KEY_BACKSPACE, "s", "s", "s", "s", private.keyboardFrame.cmd_key_color)
	},
	{
		kbKeydef (false, 300, 300, "x", "x", "x", "x", private.keyboardFrame.cancel_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (true, keys.KEY_Q, keys.KEY_Q, "q", "Q", "Q", "q", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_W, keys.KEY_W, "w", "W", "W", "w", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_E, keys.KEY_E, "e", "E", "E", "e", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_R, keys.KEY_R, "r", "R", "R", "r", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_T, keys.KEY_T, "t", "T", "T", "t", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_Y, keys.KEY_Y, "y", "Y", "Y", "y", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_U, keys.KEY_U, "u", "U", "U", "u", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_I, keys.KEY_I, "i", "I", "I", "i", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_O, keys.KEY_O, "o", "O", "O", "o", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_P, keys.KEY_P, "p", "P", "P", "p", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_OPENSQUARE, keys.KEY_OPENBRACE, "[", "{", "[", "{", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SLASH, keys.KEY_BAR, "]", "}", "]", "}", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_CLOSESQUARE, keys.KEY_CLOSEBRACE, "\\", "|", "\\", "|", private.keyboardFrame.std_key_color)
	},
	{
		kbKeydef (false, keys.KEY_CAPS, keys.KEY_CAPS, "c", "c", "c", "c", private.keyboardFrame.caps_key_color),
		kbKeydef (false, keys.KEY_CAPS, keys.KEY_CAPS, "l", "l", "l", "l", private.keyboardFrame.caps_key_color),
		kbKeydef (true, keys.KEY_A, keys.KEY_A, "a", "A", "A", "a", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_S, keys.KEY_S, "s", "S", "S", "s", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_D, keys.KEY_D, "d", "D", "D", "d", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_F, keys.KEY_F, "f", "F", "F", "f", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_G, keys.KEY_G, "g", "G", "G", "g", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_H, keys.KEY_H, "h", "H", "H", "h", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_J, keys.KEY_J, "j", "J", "J", "j", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_K, keys.KEY_K, "k", "K", "K", "k", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_L, keys.KEY_L, "l", "L", "L", "l", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SEMICOLON, keys.KEY_COLON, ";", ":", ";", ":", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_APOSTROPHE, keys.KEY_QUOTE, "'", "\"", "'", "\"", private.keyboardFrame.std_key_color),
		kbKeydef (false, keys.KEY_ENTER, keys.KEY_ENTER, "e", "e", "e", "e", private.keyboardFrame.cmd_key_color),
		kbKeydef (false, keys.KEY_ENTER, keys.KEY_ENTER, "n", "n", "n", "n", private.keyboardFrame.cmd_key_color)
	},
	{
		kbKeydef (false, keys.KEY_SHIFT, keys.KEY_SHIFT, "s", "s", "s", "s", private.keyboardFrame.shift_key_color),
		kbKeydef (false, keys.KEY_SHIFT, keys.KEY_SHIFT, "h", "h", "h", "h", private.keyboardFrame.shift_key_color),
		kbKeydef (true, keys.KEY_Z, keys.KEY_Z, "z", "Z", "Z", "z", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_X, keys.KEY_X, "x", "X", "X", "x", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_C, keys.KEY_C, "c", "C", "C", "c", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_V, keys.KEY_V, "v", "V", "V", "v", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_B, keys.KEY_B, "b", "B", "B", "b", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_N, keys.KEY_N, "n", "N", "N", "n", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_M, keys.KEY_M, "m", "M", "M", "m", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_COMMA, keys.KEY_LESS, ",", "<", ",", "<", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_DOT, keys.KEY_GREATER, ".", ">", ".", ">", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_DIVIDE, keys.KEY_QUESTION, "/", "?", "/", "?", private.keyboardFrame.std_key_color),
		kbKeydef (false, 0, 0, " ", " ", " ", " ", private.keyboardFrame.no_key_color),
		kbKeydef (false, keys.KEY_SHIFT, keys.KEY_SHIFT, "s", "s", "s", "s", private.keyboardFrame.shift_key_color),
		kbKeydef (false, keys.KEY_SHIFT, keys.KEY_SHIFT, "h", "h", "h", "h", private.keyboardFrame.shift_key_color)
	},
	{
		kbKeydef (false, 0, 0, "[", "[", "[", "[", private.keyboardFrame.no_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (true, keys.KEY_SPACE, keys.KEY_SPACE, " ", " ", " ", " ", private.keyboardFrame.std_key_color),
		kbKeydef (false, 0, 0, "]", "]", "]", "]", private.keyboardFrame.no_key_color)
	}
}
