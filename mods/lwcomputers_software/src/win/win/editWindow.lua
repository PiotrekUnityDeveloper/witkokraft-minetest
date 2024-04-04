local private = ...



win.EU_REPLACE		= 0
win.EU_TYPE			= 1
win.EU_DELETE		= 2
win.EU_BACKSPACE	= 3



local editUndo = win.__classBase:base ()



function editUndo:constructor ()
	self.eu__cache = { }
	self.eu__index = 0

	return self
end



function editUndo:reset ()
	self.eu__cache = { }
	self.eu__index = 0
end



function editUndo:end_action ()
	if #self.eu__cache > 0 then
		self.eu__cache[#self.eu__cache].action = win.EU_REPLACE
	end
end



function editUndo:record (pos, inserted, removed, action)
	if action ~= win.EU_REPLACE and self.eu__index > 0 and
				self.eu__index == #self.eu__cache and
						self.eu__cache[self.eu__index].action == action then
		if action == win.EU_TYPE then
			local cache = self.eu__cache[self.eu__index].inserted
			cache[#cache] = cache[#cache]..inserted[1]
			for i = 2, #inserted, 1 do
				cache[#cache + 1] = inserted[i]
			end

			return

		elseif action == win.EU_DELETE then
			local cache = self.eu__cache[self.eu__index].removed
			cache[#cache] = cache[#cache]..removed[1]
			for i = 2, #removed, 1 do
				cache[#cache + 1] = removed[i]
			end

			return

		elseif action == win.EU_BACKSPACE then
			local cache = self.eu__cache[self.eu__index].removed
			cache[1] = removed[#removed]..cache[1]
			for i = 1, #removed - 1, 1 do
				table.insert (cache, 1, removed[i])
			end
			self.eu__cache[self.eu__index].pos = pos

			return

		end
	end

	while #self.eu__cache > self.eu__index do
		table.remove (self.eu__cache, #self.eu__cache)
	end

	self:end_action ()

	self.eu__index = #self.eu__cache + 1
	self.eu__cache[self.eu__index] =
	{
		pos = pos,
		inserted = inserted,
		removed = removed,
		action = action
	}
end



function editUndo:can_undo ()
	return self.eu__index > 0
end



function editUndo:can_redo ()
	return self.eu__index < #self.eu__cache
end



function editUndo:undo ()
	local data;

	if self:can_undo () then
		self:end_action ()
		data = self.eu__cache[self.eu__index]
		self.eu__index = self.eu__index - 1
	end

	return data
end



function editUndo:redo ()
	local data;

	if self:can_redo () then
		self:end_action ()
		self.eu__index = self.eu__index + 1
		data = self.eu__cache[self.eu__index]
	end

	return data
end



local function edit_find_eol (str, from)
	local cr = str:find ("\r", from)
	local nl = str:find ("\n", from)

	if cr then
		if nl then
			return math.min (cr, nl)
		end

		return cr
	end

	return nl
end



local function edit_text_to_table (text)
	local tab_text = { }
	local last = 1
	local pos = edit_find_eol (text, last)

	while pos do
		tab_text[#tab_text + 1] = text:sub (last, pos - 1)

		if text:byte (pos) == 13 then
			if text:byte (pos + 1) == 10 then
				pos = pos + 1
			end
		end

		last = pos + 1
		pos = edit_find_eol (text, last)
	end

	tab_text[#tab_text + 1] = text:sub (last)

	return tab_text
end




local function edit_table_to_text (tab_text, eol)
	local str;

	if type (tab_text[1]) == "table" then
		str = tab_text[1].str

		for line = 2, #tab_text, 1 do
			str = str..eol..tab_text[line].str
		end
	else
		str = tab_text[1]

		for line = 2, #tab_text, 1 do
			str = str..eol..tab_text[line]
		end
	end

	return str
end




local function edit_count_chars (tab_text, long_eol)
	local eol = (long_eol and 2) or 1
	local len = 0

	if type (tab_text[1]) == "table" then
		len = tab_text[1].len

		for line = 2, #tab_text, 1 do
			len = len + tab_text[line].len + eol
		end
	else
		len = tab_text[1]:len ()

		for line = 2, #tab_text, 1 do
			len = len + tab_text[line]:len() + eol
		end
	end

	return len
end



win.editWindow = win.window:base ()



function win.editWindow:constructor (parent, id, x, y, width, height, text, banner)
	if not win.window.constructor (self, parent, id, x, y, width, height) then
		return nil
	end

	self.edit__data = { { len = 0, str = "" } }
	self.edit__banner = ""
	self.edit__modified = false
	self.edit__error = false
	self.edit__end = 0
	self.edit__start = 0
	self.edit__tab = 0
	self.edit__cursor_col = 0
	self.edit__read_only = false
	self.edit__fire_events = false
	self.edit__undo = editUndo:new ()
	self.edit__colors =
	{
		text = self:get_colors ().input_text,
		back = self:get_colors ().input_back,
		focus = self:get_colors ().input_focus,
		error = self:get_colors ().input_error,
		banner = self:get_colors ().input_banner
	}

	self:set_color (self.edit__colors.text)
	self:set_bg_color (self.edit__colors.back)
	self:set_want_key_input (win.KEYINPUT_EDIT)
	self:set_banner (banner)
	self:set_text (text)
	self.edit__fire_events = true

	return self
end



function win.editWindow:set_colors (text, background, focus, banner, error_color)
	self.edit__colors.text = text
	self.edit__colors.back = background
	self.edit__colors.focus = focus
	self.edit__colors.error = error_color
	self.edit__colors.banner = banner

	self:set_color (text)
	self:set_bg_color ((self:get_focus () == self and focus) or background)
end



function win.editWindow:set_banner (banner)
	self.edit__banner = tostring (banner or "")
	self:invalidate ()
end



function win.editWindow:get_banner ()
	return self.edit__banner
end



function win.editWindow:get_error ()
	return self.edit__error
end



function win.editWindow:set_error (err)
	err = (err ~= false)

	if err ~= self.edit__error then
		self.edit__error = err

		self:set_bg_color ((self.edit__error and self.edit__colors.error) or
								 ((self:get_focus () == self and self.edit__colors.focus) or
								 self.edit__colors.back))
	end
end



function win.editWindow:set_modified (modified, fire_event)
	modified = (modified ~= false)

	if (modified and not self.edit__modified) or
		(self.edit__modified and not modified) then

		self.edit__modified = modified

		if fire_event ~= false then
			if self:get_parent () and self.edit__fire_events then
				self:get_parent ():send_event ("modified", self)
			end
		end
	end
end



function win.editWindow:get_modified ()
	return self.edit__modified
end



function win.editWindow:get_tab_width ()
	return self.edit__tab
end



function win.editWindow:set_tab_width (chars)
	self.edit__tab = math.floor (tonumber(chars) or 0)
end



function win.editWindow:get_read_only ()
	return self.edit__read_only
end



function win.editWindow:set_read_only (readOnly)
	self.edit__read_only = readOnly ~= false
end



function win.editWindow:lines ()
	return #self.edit__data
end



function win.editWindow:get_text_len (long_eol)
	return edit_count_chars (self.edit__data, long_eol)
end



function win.editWindow:line_index (line)
	local index = 0

	line = (line < 0 and 1) or (line + 1)

	if line > (#self.edit__data + 1) then
		line = #self.edit__data + 1
	end

	for i = 1, line - 1, 1 do
		index = index + self.edit__data[i].len + 1
	end

	if line == (#self.edit__data + 1) then
		index = index - 1
	end

	return index
end



function win.editWindow:line_from_char (char)
	local index, prior = 0, 0

	if char < 0 then
		char = 0
	end

	for line = 1, #self.edit__data, 1 do
		if char < index then
			return (line - 2), (char - prior)
		end

		prior = index
		index = index + self.edit__data[line].len + 1
	end

	char = char - prior
	if char > self.edit__data[#self.edit__data].len then
		char = self.edit__data[#self.edit__data].len
	end

	return (#self.edit__data - 1), char
end



function win.editWindow:char_from_point (x, y)
	local char, line = x, y + 1

	if line > #self.edit__data then
		line = #self.edit__data
	elseif line < 1 then
		line = 1
	end

	if char > self.edit__data[line].len then
		char = self.edit__data[line].len
	elseif char < 0 then
		char = 0
	end

	if line > 1 then
		char = char + self:line_index (line - 1)
	end

	return char
end



function win.editWindow:set_sel (sel_start, sel_end, auto_scroll)
	local strLen = self:get_text_len ()

	sel_start = tonumber (sel_start) or 0

	if sel_start == -1 then
		sel_start = strLen
	elseif sel_start < 0 then
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

	self.edit__end = sel_end
	self.edit__start = sel_start

	self:invalidate (0, 0, self:get_client_size ())

	if auto_scroll ~= false then
		local zx, zy = self:get_client_size ()
		local sx, sy = self:get_scroll_org ()
		local line, char = self:line_from_char (sel_end)

		if (char - sx) < 0 then
			sx = char - math.floor (zx / 4)
		elseif char >= (sx + zx) then
			sx = char - zx + 1
		end

		if (line - sy) < 0 then
			sy = line
		elseif line >= (sy + zy) then
			sy = line - zy + 1
		end

		self:set_scroll_org (sx, sy)
	end

	if self:get_focus () == self then
		local y, x = self:line_from_char (self.edit__end)
		self:set_cursor_pos (x, y)
	end

	if self:get_parent () and self.edit__fire_events then
		self:get_parent ():send_event ("selection_change", self)
	end
end



function win.editWindow:get_sel (normalise)
	if normalise then
		if self.edit__end < self.edit__start then
			return self.edit__end, self.edit__start
		end
	end

	return self.edit__start, self.edit__end
end



function win.editWindow:get_selection ()
	local sel = {}
	local ss, se = self:get_sel (true)

	if ss ~= se then
		local sline, schar = self:line_from_char (ss)
		local eline, echar = self:line_from_char (se)

		if sline == eline then
			sel[1] = self.edit__data[sline + 1].str:sub(schar + 1, echar)
		else
			sel[1] = self.edit__data[sline + 1].str:sub(schar + 1)

			for line = sline + 2, eline, 1 do
				sel[#sel + 1] = self.edit__data[line].str
			end

			sel[#sel + 1] = self.edit__data[eline + 1].str:sub(1, echar)
		end
	else
		sel[1] = ""
	end

	return sel
end



function win.editWindow:get_selected_text (eol)
	return edit_table_to_text (self:get_selection (), eol or "\n")
end



function win.editWindow:update_scroll_size ()
	local width = 0

	for i = 1, #self.edit__data, 1 do
		if self.edit__data[i].len >= width then
			width = self.edit__data[i].len + 1
		end
	end

	self:set_scroll_size (width, #self.edit__data)
end



function win.editWindow:replace_sel_tabled (insert, auto_scroll, undo_action)
	local ss, se = self:get_sel (true)
	local sline, schar = self:line_from_char (ss)
	local removed = { }
	local insert_chars = edit_count_chars (insert, false)

	if ss ~= se then
		local eline, echar = self:line_from_char (se)

		if sline == eline then
			removed[1] = self.edit__data[sline + 1].str:sub (schar + 1, echar)

			self.edit__data[sline + 1].str =
						self.edit__data[sline + 1].str:sub (1, schar)..
						self.edit__data[sline + 1].str:sub (echar + 1)

			self.edit__data[sline + 1].len = self.edit__data[sline + 1].str:len ()
		else
			removed[1] = self.edit__data[sline + 1].str:sub (schar + 1)

			self.edit__data[sline + 1].str =
						self.edit__data[sline + 1].str:sub (1, schar)

			for line = sline + 2, eline, 1 do
				removed[#removed + 1] = self.edit__data[sline + 2].str
				table.remove (self.edit__data, sline + 2)
			end

			removed[#removed + 1] = self.edit__data[sline + 2].str:sub (1, echar)

			self.edit__data[sline + 1].str =
						self.edit__data[sline + 1].str..
						self.edit__data[sline + 2].str:sub (echar + 1)
			table.remove (self.edit__data, sline + 2)

			self.edit__data[sline + 1].len = self.edit__data[sline + 1].str:len ()
		end
	else
		removed[1] = ""
	end


	if #insert == 1 then
		if insert[1]:len () > 0 then
			if insert[1]:len () == 1 then
				-- one char
				self.edit__data[sline + 1].str =
						self.edit__data[sline + 1].str:sub (1, schar)..
						insert[1]..
						self.edit__data[sline + 1].str:sub (schar + 1)

				self.edit__data[sline + 1].len = self.edit__data[sline + 1].len + 1
			else
				-- multi char
				self.edit__data[sline + 1].str =
						self.edit__data[sline + 1].str:sub (1, schar)..
						insert[1]..
						self.edit__data[sline + 1].str:sub (schar + 1)

				self.edit__data[sline + 1].len = self.edit__data[sline + 1].len + insert[1]:len ()
			end
		end
	else
		table.insert (self.edit__data, sline + 2,
				{ len = 0, str = (insert[#insert]..self.edit__data[sline + 1].str:sub (schar + 1)) })
		self.edit__data[sline + 2].len = self.edit__data[sline + 2].str:len ()

		self.edit__data[sline + 1].str =
				self.edit__data[sline + 1].str:sub (1, schar)..
				insert[1]
		self.edit__data[sline + 1].len = self.edit__data[sline + 1].str:len ()

		for line = 2, #insert - 1, 1 do
			table.insert (self.edit__data, sline + line, { len = insert[line]:len (), str = insert[line]})
		end
	end

	if undo_action then
		self.edit__undo:record(ss, insert, removed, undo_action)
	end

	self:update_scroll_size ()
	self:set_sel (ss + insert_chars, ss + insert_chars, auto_scroll)
	self:set_modified ()
	self.edit__cursor_col = self:get_cursor_pos ()
end



function win.editWindow:replace_sel (replace_text, auto_scroll)
	self:replace_sel_tabled (edit_text_to_table (tostring (replace_text or "")), auto_scroll, win.EU_REPLACE)
end



function win.editWindow:cut ()
	local str_sel = self:get_selected_text ()

	if str_sel:len () > 0 then
		self:set_clipboard (str_sel, win.CB_TEXT)
		self:replace_sel_tabled ({ "" }, nil, win.EU_REPLACE)
		self.edit__cursor_col = self:get_cursor_pos ()
	end
end



function win.editWindow:copy ()
	local str_sel = self:get_selected_text ()

	if str_sel:len() > 0 then
		self:set_clipboard (str_sel, win.CB_TEXT)
	end
end



function win.editWindow:paste ()
	local cbType, cbData = self:get_clipboard ()

	if cbType == win.CB_TEXT then
		self:replace_sel (cbData)
		self.edit__cursor_col = self:get_cursor_pos ()
	end
end



function win.editWindow:draw (gdi, bounds)
	if #self.edit__data == 1 and self.edit__data[1].len == 0 then
		if self:get_banner ():len () > 0 then
			gdi:set_colors (self.edit__colors.banner, self:get_bg_color ())
			gdi:write (self:get_banner (), 0, 0)
		end
	else
		local ss, se = self:get_sel (true)
		local last_line, first_line = self:wnd_to_scroll (bounds.x, bounds.y)
		last_line = first_line + bounds.height - 1

		if first_line < 0 then
			first_line = 0
		elseif first_line >= #self.edit__data then
			first_line = #self.edit__data - 1
		end

		if last_line < 0 then
			last_line = 0
		elseif last_line >= #self.edit__data then
			last_line = #self.edit__data - 1
		end

		if last_line >= first_line then
			if ss == se then
				gdi:set_colors (self:get_color (), self:get_bg_color ())

				for line = first_line, last_line, 1 do
					gdi:write (self.edit__data[line + 1].str, 0, line)
				end
			else
				local sline, schar = self:line_from_char (ss)
				local eline, echar = self:line_from_char (se)

				if sline == eline then
					for line = first_line, last_line, 1 do
						if line == sline then
							gdi:set_colors (self:get_color (), self:get_bg_color ())
							gdi:write (self.edit__data[line + 1].str:sub (1, schar), 0, line)

							gdi:set_colors (self:get_colors ().selected_text, self:get_colors ().selected_back)
							gdi:write (self.edit__data[line + 1].str:sub (schar + 1, echar), schar, line)

							gdi:set_colors (self:get_color (), self:get_bg_color ())
							gdi:write (self.edit__data[line + 1].str:sub (echar + 1), echar, line)
						else
							gdi:set_colors (self:get_color (), self:get_bg_color ())
							gdi:write (self.edit__data[line + 1].str, 0, line)
						end
					end
				else
					for line = first_line, last_line, 1 do
						if line == sline then
							gdi:set_colors (self:get_color (), self:get_bg_color ())
							gdi:write (self.edit__data[line + 1].str:sub (1, schar), 0, line)

							gdi:set_colors (self:get_colors ().selected_text, self:get_colors ().selected_back)
							gdi:write ((self.edit__data[line + 1].str.." "):sub (schar + 1), schar, line)
						elseif line == eline then
							gdi:set_colors (self:get_colors ().selected_text, self:get_colors ().selected_back)
							gdi:write (self.edit__data[line + 1].str:sub (1, echar), 0, line)

							gdi:set_colors (self:get_color (), self:get_bg_color ())
							gdi:write (self.edit__data[line + 1].str:sub(echar + 1), echar, line)
						else
							if line > sline and line < eline then
								gdi:set_colors (self:get_colors ().selected_text, self:get_colors ().selected_back)
								gdi:write (self.edit__data[line + 1].str.." ", 0, line)
							else
								gdi:set_colors (self:get_color (), self:get_bg_color ())
								gdi:write (self.edit__data[line + 1].str, 0, line)
							end
						end
					end
				end
			end
		end
	end
end



function win.editWindow:set_text (text)
	self:set_sel (0, -1, false)
	self:replace_sel (tostring (text or ""))
	self:set_sel (-1, -1)
	self:set_modified (false)
	self.edit__undo:reset ()
end



function win.editWindow:can_undo ()
	return self.edit__undo:can_undo ()
end



function win.editWindow:can_redo ()
	return self.edit__undo:can_redo ()
end



function win.editWindow:undo ()
	local data = self.edit__undo:undo ()
	if data then
		self:set_sel (data.pos, data.pos + edit_count_chars (data.inserted, false), false)
		self:replace_sel_tabled (data.removed)
		self.edit__cursor_col = self:get_cursor_pos ()
	end
end



function win.editWindow:redo ()
	local data = self.edit__undo:redo ()
	if data then
		self:set_sel (data.pos, data.pos + edit_count_chars (data.removed, false), false)
		self:replace_sel_tabled (data.inserted)
		self.edit__cursor_col = self:get_cursor_pos ()
	end
end



function win.editWindow:get_text (eol)
	return edit_table_to_text (self.edit__data, eol or "\n")
end



function win.editWindow:on_focus (blurred)
	self:set_bg_color ((self.edit__error and self.edit__colors.error) or
							 self.edit__colors.focus)

	self:show_cursor ()

	return false
end



function win.editWindow:on_blur (focused)
	self:hide_cursor ()
	self:set_bg_color ((self.edit__error and self.edit__colors.error) or
							 self.edit__colors.back)

	return false
end



function win.editWindow:on_key (key, ctrl, alt, shift)
	if not ctrl and not alt and not shift then
		local ss, se = self:get_sel (false)

		if key == keys.KEY_BACKSPACE then
			if not self:get_read_only () then
				if ss == se then
					if ss > 0 then
						self:set_sel (ss - 1, ss, false)
						self:replace_sel_tabled ({ "" }, nil, win.EU_BACKSPACE)
					end
				else
					self:replace_sel_tabled ({ "" }, nil, win.EU_BACKSPACE)
				end
			end

			return true

		elseif key == keys.KEY_DELETE then
			if not self:get_read_only () then
				if ss == se then
					self:set_sel (ss, ss + 1, false)
				end

				self:replace_sel_tabled ({ "" }, nil, win.EU_DELETE)
			end

			return true

		elseif key == keys.KEY_ENTER then
			if not self:get_read_only () then
				self:replace_sel_tabled ({ "", "" }, nil, win.EU_TYPE)
			end

			return true

		elseif key == keys.KEY_TAB then
			if not self:get_read_only () and self:get_tab_width () > 0 then
				local line, offset = self:line_from_char ((self:get_sel (true)))
				offset = self:get_tab_width () - math.fmod (offset, self:get_tab_width ())

				self:replace_sel_tabled ({ string.rep (" ", offset) }, nil, win.EU_TYPE)
			end

			return true

		elseif key == keys.KEY_LEFT then
			if se > 0 then
				self:set_sel (se - 1, se - 1)
				self.edit__undo:end_action ()
				self.edit__cursor_col = self:get_cursor_pos ()
			end

			return true

		elseif key == keys.KEY_RIGHT then
			self:set_sel (se + 1, se + 1)
			self.edit__undo:end_action ()
			self.edit__cursor_col = self:get_cursor_pos ()

			return true

		elseif key == keys.KEY_UP then
			local y, x = self:line_from_char (se)

			if y > 0 then
				y = self:char_from_point (self.edit__cursor_col, y - 1)
				self:set_sel (y, y)
				self.edit__undo:end_action ()
			end

			return true

		elseif key == keys.KEY_DOWN then
			local y, x = self:line_from_char (se)

			if y < self:lines() then
				y = self:char_from_point (self.edit__cursor_col, y + 1)
				self:set_sel (y, y)
				self.edit__undo:end_action ()
			end

			return true

		elseif key == keys.KEY_PAGEUP then
			local y, x = self:line_from_char (se)

			if y > 0 then
				local zx, zy = self:get_client_size ()

				y = y - zy + 1
				y = self:char_from_point (self.edit__cursor_col, (y < 0 and 0) or y)
				self:set_sel (y, y)
				self.edit__undo:end_action ()
			end

			return true

		elseif key == keys.KEY_PAGEDOWN then
			local y, x = self:line_from_char (se)

			if y < self:lines() then
				local zx, zy = self:get_client_size ()

				y = y + zy - 1
				y = self:char_from_point (self.edit__cursor_col, (y >= self:lines() and self:lines() - 1) or y)
				self:set_sel (y, y)
				self.edit__undo:end_action ()
			end

			return true

		elseif key == keys.KEY_HOME then
			se = self:line_index ((self:line_from_char (se)))
			self:set_sel (se, se)
			self.edit__undo:end_action ()
			self.edit__cursor_col = self:get_cursor_pos ()

			return true

		elseif key == keys.KEY_END then
			local line = self:line_from_char (se)

			se = self:line_index (line + 1)
			if line < (self:lines() - 1) then
				se = se - 1
			end

			self:set_sel (se, se)
			self.edit__undo:end_action ()
			self.edit__cursor_col = self:get_cursor_pos ()

			return true

		end

	elseif not ctrl and not alt and shift then
		local ss, se = self:get_sel (false)

		if key == keys.KEY_LEFT then
			if se > 0 then
				self:set_sel (ss, se - 1)
				self.edit__undo:end_action ()
				self.edit__cursor_col = self:get_cursor_pos ()
			end

			return true

		elseif key == keys.KEY_RIGHT then
			self:set_sel (ss, se + 1)
			self.edit__undo:end_action ()
			self.edit__cursor_col = self:get_cursor_pos ()

			return true

		elseif key == keys.KEY_UP then
			local y, x = self:line_from_char (se)

			if y > 0 then
				self:set_sel (ss, self:char_from_point (self.edit__cursor_col, y - 1))
				self.edit__undo:end_action ()
			end

			return true

		elseif key == keys.KEY_DOWN then
			local y, x = self:line_from_char (se)

			if y < self:lines() then
				self:set_sel (ss, self:char_from_point (self.edit__cursor_col, y + 1))
				self.edit__undo:end_action ()
			end

			return true

		elseif key == keys.KEY_PAGEUP then
			local y, x = self:line_from_char (se)

			if y > 0 then
				local zx, zy = self:get_client_size ()

				y = y - zy + 1
				self:set_sel (ss, self:char_from_point (self.edit__cursor_col, (y < 0 and 0) or y))
				self.edit__undo:end_action ()
			end

			return true

		elseif key == keys.KEY_PAGEDOWN then
			local y, x = self:line_from_char (se)

			if y < self:lines() then
				local zx, zy = self:get_client_size ()

				y = y + zy - 1
				self:set_sel (ss, self:char_from_point (self.edit__cursor_col,
																	 (y >= self:lines() and self:lines() - 1) or y))
				self.edit__undo:end_action ()
			end

			return true

		elseif key == keys.KEY_HOME then
			self:set_sel (ss, self:line_index ((self:line_from_char (se))))
			self.edit__undo:end_action ()
			self.edit__cursor_col = self:get_cursor_pos ()

			return true

		elseif key == keys.KEY_END then
			local line = self:line_from_char (se)

			se = self:line_index (line + 1)
			if line < (self:lines() - 1) then
				se = se - 1
			end

			self:set_sel (ss, se)
			self.edit__undo:end_action ()
			self.edit__cursor_col = self:get_cursor_pos ()

			return true

		end

	elseif ctrl and not alt and not shift then
		if key == keys.KEY_X then
			if not self:get_read_only () then
				self:cut ()
			end

			return true

		elseif key == keys.KEY_C then
			self:copy ()

			return true

		elseif key == keys.KEY_V then
			if not self:get_read_only () then
				self:paste ()
			end

			return true

		elseif key == keys.KEY_Z then
			if not self:get_read_only () then
				self:undo ()
			end

			return true

		elseif key == keys.KEY_Y then
			if not self:get_read_only () then
				self:redo ()
			end

			return true

		elseif key == keys.KEY_A then
			self:set_sel (0, -1, false)
			self.edit__undo:end_action ()
			self.edit__cursor_col = self:get_cursor_pos ()

			return true

		elseif key == keys.KEY_UP then
			self:send_event ("vbar_scroll", -1, false)

			return true

		elseif key == keys.KEY_DOWN then
			self:send_event ("vbar_scroll", 1, false)

			return true

		elseif key == keys.KEY_LEFT then
			self:send_event ("hbar_scroll", -1, false)

			return true

		elseif key == keys.KEY_RIGHT then
			self:send_event ("hbar_scroll", 1, false)

			return true

		elseif key == keys.KEY_PAGEUP then
			self:send_event ("vbar_scroll", -1, true)

			return true

		elseif key == keys.KEY_PAGEDOWN then
			self:send_event ("vbar_scroll", 1, true)

			return true

		elseif key == keys.KEY_HOME then
			self:set_scroll_org (0, 0)

			return true

		elseif key == keys.KEY_END then
			self:set_scroll_org (0, self:lines())

			return true
		end
	end

	return false
end



function win.editWindow:on_char (char, ascii)
	if not self:get_read_only () then
		if ascii ~= keys.KEY_BACKSPACE and
				ascii ~= keys.KEY_ESCAPE and
				ascii ~= keys.KEY_TAB and
				ascii ~= keys.KEY_ENTER then
			self:replace_sel_tabled ({ char }, nil, win.EU_TYPE)
		end
	end

	return true
end



function win.editWindow:on_left_click (x, y, count)
	if win.window.on_left_click (self, x, y, count) then
		return true
	end

	local shift = os.key_state (keys.KEY_SHIFT)
	local char = self:char_from_point (self:wnd_to_scroll (x, y))

	if shift then
		self:set_sel ((self:get_sel (false)), char)
	else
		self:set_sel (char, char)
	end

	self.edit__undo:end_action ()
	self.edit__cursor_col = self:get_cursor_pos ()

	return true
end



function win.editWindow:on_left_drag (x, y)
	local ss, se = self:get_sel (false)
	self:set_sel (ss, self:char_from_point (self:wnd_to_scroll (x, y)))
	self.edit__undo:end_action ()
	self.edit__cursor_col = self:get_cursor_pos ()

	return true
end



function win.editWindow:on_touch (x, y)
	if win.window.on_touch (self, x, y) then
		return true
	end

	local shift = os.key_state (keys.KEY_SHIFT)
	local char = self:char_from_point (self:wnd_to_scroll (x, y))

	if shift then
		self:set_sel ((self:get_sel (false)), char)
	else
		self:set_sel (char, char)
	end

	self.edit__undo:end_action ()
	self.edit__cursor_col = self:get_cursor_pos ()

	return true
end



function win.editWindow:on_move ()
	if self:get_focus () == self then
		self:show_cursor ()
	end

	return false
end



function win.editWindow:on_clipboard (text)
	if tostring (text or ""):len () > 0 then
		if not self:get_read_only () then
			self:replace_sel (tostring (text or ""))
		end
	end

	return true
end



function win.editWindow:on_scroll ()
	if self:get_focus () == self then
		self:show_cursor ()
	end
end
