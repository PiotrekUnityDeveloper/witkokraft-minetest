

cmndlg = { }


-- boolean validate(strInput) - return false to keep open

local inputClass = win.popupFrame:base ()



function inputClass:on_create (title, prompt, banner, init_text, validate, maxLen, bgcolor)
	self:dress (title)

	local width = math.floor (self:get_desktop ():get_work_area ().width * 0.8)

	if not bgcolor then
		bgcolor = self:get_colors ().popup_back
	end

	self.prompt = win.labelWindow:new (self, 2, 1, 2, prompt)

	self.entry = win.inputWindow:new (self, 3, 1, 3, width - 2, init_text, banner)
	self.entry:set_max_len (maxLen)
	self.entry:set_sel (0, -1)
	self.entry:set_focus ()

	self.ok = win.buttonWindow:new (self, 4, width - 5, 4, " Ok ")

	self.validate_func = validate
	self.result_ok = false
	self.user_input = nil

	self:set_bg_color (bgcolor)
	self.prompt:set_bg_color (bgcolor)

	self:move (nil, nil, width, 6)

	return true
end



function inputClass:on_close ()
	if self.validate_func and self.result_ok then
		if self.validate_func (self.entry:get_text ()) == false then
			self.result_ok = false
			self.entry:set_error (true)
			self.entry:set_sel (0, -1)
			self.entry:set_focus ()

			return true
		end
	end

	self.user_input = self.entry:get_text ()

	return false
end



function inputClass:on_event (event, p1, p2, p3, p4, p5, ...)
	if event == "btn_click" then
		if p1:get_id () == 4 then
			self.result_ok = true
			self:close (4)

			return true
		end
	end

	return false
end



function inputClass:on_move ()
	win.popupFrame.on_move (self)
	self.prompt:move (nil, nil, self.width - 2)
	self.entry:move (nil, nil, self.width - 2)
	self.ok:move (self.width - 5)
end



function cmndlg.input (owner_frame, title, prompt, init_text, banner, maxLen, validate, bgcolor)
	assert (owner_frame and owner_frame.on_frame_activate,
			  "cmndlg.input() must have an owner frame.")
	assert (owner_frame.wnd__popup == nil,
			  "cmndlg.input() owner frame already has popup.")

	local dlg = inputClass:new (owner_frame)
	if dlg then
		if dlg:do_modal (title, prompt, banner, init_text, validate, maxLen, bgcolor) == 4 then
			return dlg.user_input
		end
	end

	return nil
end






local confirmClass = win.popupFrame:base ()



function confirmClass:on_create (title, message, defaultOk, bgcolor)
	title = tostring (title or "")
	message = tostring (message or "")
	local rtWork = self:get_desktop ():get_work_area ()
	local maxWidth, maxHeight =
			math.floor (rtWork.width * 0.8), math.floor (rtWork.height * 0.8)
	local width, height = string.wrap_size (string.wrap (message, maxWidth - 2))

	if width == (maxWidth - 2) and height >= (maxHeight - 4) then
		width, height = string.wrap_size (string.wrap (message, maxWidth - 3))
	end

	width = width + 2
	height = height + 4

	if width < (title:len () + 3) then
		width = title:len () + 3
	end

	if height < 5 then
		height = 5
	elseif height > maxHeight then
		height = maxHeight
	end

	if not bgcolor then
		bgcolor = self:get_colors ().popup_back
	end

	self:dress (title)

	self.message = win.textWindow:new(self, 2, 1, 2, width - 2, height - 4, message)

	self.ok = win.buttonWindow:new(self, 3, math.floor ((width - 4) / 2), height - 2, " Ok ")
	if defaultOk then
		self.ok:set_focus ()
	end

	self:set_bg_color (bgcolor)
	self.message:set_bg_color (bgcolor)

	self:move (nil, nil, width, height)

	return true
end



function confirmClass:on_event (event, p1, p2, p3, p4, p5, ...)
	if event == "btn_click" then
		if p1:get_id () == 3 then
			self:close(3)

			return true
		end
	end

	return false
end



function confirmClass:on_move ()
	win.popupFrame.on_move (self)
	self.message:move (1, 2, self.width - 2, self.height - 4)
	self.ok:move (math.floor ((self.width - 4) / 2), self.height - 2)
end



function cmndlg.confirm (owner_frame, title, message, defaultOk, bgcolor)
	assert (owner_frame and owner_frame.on_frame_activate,
			  "cmndlg.confirm() must have an owner frame.")
	assert (owner_frame.wnd__popup == nil,
			  "cmndlg.confirm() owner frame already has popup.")

	local dlg = confirmClass:new (owner_frame)
	if dlg then
		if dlg:do_modal (title, message, defaultOk, bgcolor) == 3 then
			return true
		end
	end

	return false
end




-- boolean validate(strFullPath) - return false to keep open

local fileDlgClass = win.popupFrame:base ()



function fileDlgClass:on_create (title, init_path, prompt_overwrite,
											not_hidden, hide_new_dir,
											validate, bgcolor)
	local rtWork = self:get_desktop ():get_work_area ()
	local width, height = math.floor(rtWork.width * 0.8),
								 math.floor(rtWork.height * 0.8)

	init_path = tostring (init_path or "")

	local file_name = ""
	self.cur_dir = "/"

	if init_path:len () > 0 then
		file_name = fs.path_name (init_path)
		self.cur_dir = fs.path_folder (init_path)
	end

	if self.cur_dir:sub (-1, -1) ~= "/" then
		self.cur_dir = self.cur_dir.."/"
	end

	if not bgcolor then
		bgcolor = self:get_colors ().popup_back
	end

	self:dress (title)

	self.prompt_overwrite = prompt_overwrite
	self.not_hidden = not_hidden

	self.dir_label = win.labelWindow:new (self, 2, 1, 1, self.cur_dir)
	self.dir_label:move (nil, nil, width - 7)
	self.dir_label:set_bg_color (bgcolor)

	self.file_list = win.listWindow:new (self, 3, 1, 2, width - 2, height - 5)

	self.file_name = win.inputWindow:new (self, 4, 1, height - 2,
													  width - 6, file_name, "File name")
	self.file_name:set_sel (0, -1)
	self.file_name:set_focus ()

	self.ok = win.buttonWindow:new (self, 5, width - 5, height - 2, " Ok ")

	self.mkdir = win.buttonWindow:new (self, 6, width - 6, 1, " new ")
	self.mkdir:show (hide_new_dir ~= true)

	self.validate_func = validate
	self.result_ok = false
	self.full_path = nil

	self:set_bg_color (bgcolor)

	self:move (nil, nil, width, height)

	self:load_file_list ()

	return true
end



function fileDlgClass:new_dir ()
	local bgcolor = term.colors.orange

	if self:get_bg_color () == term.colors.orange then
		bgcolor = term.colors.yellow
	end

	local folder = cmndlg.input (self, "New Folder", "Enter new folder name.",
										  "Folder", "new", nil, nil, bgcolor)

	if folder then
		fs.mkdir (self.cur_dir..folder)
		self:load_file_list ()
	end
end



function fileDlgClass:check_overwrite ()
	if self.prompt_overwrite and fs.file_exists (self:get_full_path ()) then
		local bgcolor = term.colors.orange

		if self:get_bg_color () == term.colors.orange then
			bgcolor = term.colors.yellow
		end

		if not cmndlg.confirm	(self, "Overwrite",
										 "File \""..self:get_full_path ()..
											"\" already exists.\nOverwrite?",
										 false, bgcolor) then
			return
		end
	end

	self.result_ok = true
	self:close (5)
end



function fileDlgClass:get_full_path ()
	return self.cur_dir..self.file_name:get_text ()
end



function fileDlgClass:load_file_list ()
	local cur_dir = self.cur_dir

	if self.cur_dir ~= "/" then
		if fs.file_exists (self.cur_dir:sub (1, -2), true) then
			cur_dir = self.cur_dir:sub (1, -2)
		else
			self.cur_dir = "/"
			cur_dir = self.cur_dir
		end
	end

	self.file_list:reset_content ()

	if self.cur_dir:len () > 1 then
		self.file_list:add_string ("..", { id = 0, name = ".." })
	end

	local file_list = fs.ls (cur_dir, true)

	table.sort (file_list)

	for _, path in ipairs (file_list) do
		if path:sub (1, 1) ~= "." or not self.not_hidden then
			self.file_list:add_string ("/"..path, { id = 1, name = path })
		end
	end

	file_list = fs.ls (cur_dir, false)

	table.sort (file_list)

	for _, path in ipairs (file_list) do
		if path:sub (1, 1) ~= "." or not self.not_hidden then
			self.file_list:add_string (path, { id = 2, name = path })
		end
	end

	self.dir_label:set_text (self.cur_dir)
	self.dir_label:invalidate()
end



function fileDlgClass:on_close ()
	if self.validate_func and self.result_ok then
		if self.validate_func (self:get_full_path ()) == false then
			self.result_ok = false
			self.file_name:set_error (true)
			self.file_name:set_sel (0, -1)
			self.file_name:set_focus ()

			return true
		end
	end

	self.full_path = self:get_full_path ()

	return false
end



function fileDlgClass:on_event (event, p1, p2, p3, p4, p5, ...)
	if event == "btn_click" then
		if p1:get_id () == 5 then
			if self.file_name:get_text ():len() > 0 then
				self:check_overwrite ()
			end

			return true
		elseif p1:get_id () == 6 then
			self:new_dir ()

			return true
		end

	elseif event == "list_click" then
		if p1:get_id () == 3 then
			if self.file_list:get_data () then
				if self.file_list:get_data ().id == 2 then
					self.file_name:set_text (self.file_list:get_data ().name)
					self.file_name:set_sel (0, -1)
				end
			end

			return true
		end

	elseif event == "list_double_click" then
		if p1:get_id () == 3 then
			if self.file_list:get_data () then
				if self.file_list:get_data ().id == 0 then
					if self.cur_dir:len () > 1 then
						self.cur_dir = self.cur_dir:sub (1, -2)
						local last_dir = fs.path_name (self.cur_dir)
						self.cur_dir = self.cur_dir:sub (1, -(last_dir:len () + 1))
						self:load_file_list ()
					end

				elseif self.file_list:get_data ().id == 1 then
					self.cur_dir = self.cur_dir..self.file_list:get_data ().name.."/"
					self:load_file_list ()

				elseif self.file_list:get_data ().id == 2 then
					self.file_name:set_text (self.file_list:get_data ().name)
					self.file_name:set_sel (0, -1)
					self:check_overwrite ()

				end
			end

			return true
		end

	end

	return false
end



function fileDlgClass:on_resize ()
	local rtWork = self:get_desktop ():get_work_area ()
	self:move (nil, nil, math.floor (rtWork.width * 0.8), math.floor (rtWork.height * 0.8))
	win.popupFrame.on_resize (self)

	self.dir_label:move (nil, nil, self.width - 7)
	self.file_list:move (1, 2, self.width - 2, self.height - 5)
	self.file_name:move (1, self.height - 3, self.width - 6)
	self.ok:move (self.width - 5, self.height - 2)
	self.mkdir:move (self.width - 6)
end



function cmndlg.file (owner_frame, title, init_path, prompt_overwrite,
							 not_hidden, hide_new_dir, validate, bgcolor)
	assert (owner_frame and owner_frame.on_frame_activate,
			  "cmndlg.file() must have an owner frame.")
	assert (owner_frame.wnd__popup == nil,
			  "cmndlg.file() owner frame already has popup.")

	local dlg = fileDlgClass:new (owner_frame)
	if dlg then
		if dlg:do_modal (title, init_path, prompt_overwrite, not_hidden,
							  hide_new_dir, validate, bgcolor) == 5 then
			return dlg.full_path
		end
	end

	return nil
end





-- boolean validate(strFullPath) - return false to keep open

function cmndlg.save_file (owner_frame, init_path, not_hidden, validate, bgcolor)
	assert (owner_frame and owner_frame.on_frame_activate,
			  "cmndlg.save_file () must have an owner frame.")
	assert (owner_frame.wnd__popup == nil,
			  "cmndlg.save_file () owner frame already has popup.")

	return cmndlg.file (owner_frame, "Save File", init_path, true,
							  not_hidden, false, validate, bgcolor)
end





-- boolean validate(strFullPath) - return false to keep open

function cmndlg.open_file (owner_frame, init_path, not_hidden, validate, bgcolor)
	assert (owner_frame and owner_frame.on_frame_activate,
			  "cmndlg.open_file () must have an owner frame.")
	assert (owner_frame.wnd__popup == nil,
			  "cmndlg.open_file () owner frame already has popup.")

	local function validate_path (path)
		if not fs.file_exists (path) then
			return false
		end

		if validate then
			return validate (result, path)
		end

		return true
	end

	return cmndlg.file (owner_frame, "Open File", init_path, false,
							  not_hidden, true, validate_path, bgcolor)
end





local printDlgClass = win.popupFrame:base ()



function printDlgClass:on_create (total_pages, bgcolor)
	local width = math.floor (self:get_desktop ():get_work_area ().width * 0.8)

	if not bgcolor then
		bgcolor = self:get_colors ().popup_back
	end

	self:dress ("Print")

	self.prompt = win.labelWindow:new (self, 2, 1, 1, "Select printer")

	self.printers = win.listWindow:new (self, 3, 1, 2, width - 2, 4)
	self.printers:set_focus ()

	local printers = win.get_printers ()
	for i = 1, #printers, 1 do
		self.printers:add_string (printers[i])
	end

	self.pages_label = win.labelWindow:new (self, 4, 1, 6, "Pages")
	if total_pages then
		self.total_pages = tonumber (total_pages) or 0

		if self.total_pages > 0 then
			self.from_page = win.inputWindow:new (self, 5, 1, 7, 4, "1", "From")
			self.to_page = win.inputWindow:new (self, 6, 6, 7, 4,
															tostring (total_pages or ""), "To")
		else
			self.total_pages = 0
			self.from_page = win.inputWindow:new (self, 5, 1, 7, 4, "", "From")
			self.to_page = win.inputWindow:new (self, 6, 6, 7, 4, "", "To")
		end
	else
		self.total_pages = 0
		self.from_page = win.inputWindow:new (self, 5, 1, 7, 4, "", "From")
		self.to_page = win.inputWindow:new (self, 6, 6, 7, 4, "", "To")
		self.from_page:show (false)
		self.to_page:show (false)
		self.pages_label:show (false)
	end

	self.ok = win.buttonWindow:new (self, 7, width - 5, 7, " Ok ")

	self.result_ok = false
	self.printer_name = nil
	self.page_first = nil
	self.page_last = nil

	self:set_bg_color (bgcolor)
	self.prompt:set_bg_color (bgcolor)
	self.pages_label:set_bg_color (bgcolor)

	self:move (nil, nil, width, 9)

	return true
end



function printDlgClass:on_close ()
	self.printer_name = self.printers:get_string ()
	self.page_first = tonumber( self.from_page:get_text ()) or 0
	self.page_last = tonumber (self.to_page:get_text ()) or 0

	return false
end



function printDlgClass:on_event (event, p1, p2, p3, p4, p5, ...)
	if event == "btn_click" then
		if p1:get_id () == 7 then
			if self.printers:get_cur_sel () ~= 0 then
				self.result_ok = true
				self:close (7)
			else
				self.printers:set_focus ()
			end

			return true
		end

	elseif event == "input_change" then
		if p1:get_id () == 5 or p1:get_id () == 6 then
			local page = tonumber (p1:get_text ()) or 0

			if page < 1 then
				p1:set_text ("1")
				p1:invalidate ()
			elseif self.total_pages > 0 and page > self.total_pages then
				p1:set_text (tostring (self.total_pages))
				p1:invalidate ()
			end

			return true
		end

	end

	return false
end



function printDlgClass:on_move ()
	win.popupFrame.on_move (self)
	self.prompt:move (nil, nil, self.width - 2)
	self.printers:move (nil, nil, self.width - 2)
	self.ok:move (self.width - 5)
end



function cmndlg.print (owner_frame, total_pages, bgcolor)
	assert (owner_frame and owner_frame.on_frame_activate,
			  "cmndlg.print() must have an owner frame.")
	assert (owner_frame.wnd__popup == nil,
			  "cmndlg.print() owner frame already has popup.")

	local dlg = printDlgClass:new (owner_frame)
	if dlg then
		if dlg:do_modal (total_pages, bgcolor) == 7 then
			return dlg.printer_name, dlg.page_first, dlg.page_last
		end
	end

	return nil
end





local pickColorClass = win.popupFrame:base()


function pickColorClass:on_create (init_color, bgcolor)
	if not bgcolor then
		bgcolor = self:get_colors ().popup_back
	end

	self:dress ("Color")

	local color = term.colors.black
	for y = 2, 3, 1 do
		for x = 1, 8, 1 do
			local btn = win.buttonWindow:new (self, color, x, y, "#")
			btn:set_colors (color, term.colors.white, self:get_colors ().button_focus)
			color = color + 1
		end
	end

	if not init_color then
		init_color = term.colors.black
	end

	init_color = init_color % 16

	if not self:get_wnd_by_id (init_color) then
		init_color = term.colors.black
	end

	self:get_wnd_by_id (init_color):set_focus ()

	self.selected = win.labelWindow:new (self, 32770, 1, 5, "  ")
	self.selected:set_bg_color (init_color)

	self.ok = win.buttonWindow:new(self, 32771, 5, 5, " Ok ")

	self.result_ok = false
	self.user_color = nil

	self:set_bg_color (bgcolor)

	self:move (nil, nil, 10, 7)

	return true
end



function pickColorClass:on_close (result)
	self.user_color = self.selected:get_bg_color ()

	return false
end


function pickColorClass:on_event (event, p1, p2, p3, p4, p5, ...)
	if event == "btn_click" then
		if p1:get_id () == 32771 then
			self.result_ok = true
			self:close (32771)

			return true

		elseif p1:get_id () >= term.colors.white and p1:get_id () <= term.colors.black then
			self.selected:set_bg_color (p1:get_id ())

			return true
		end
	end

	return false
end



function cmndlg.color (owner_frame, init_color, bgcolor)
	assert (owner_frame and owner_frame.on_frame_activate,
			  "cmndlg.color() must have an owner frame.")
	assert (owner_frame.wnd__popup == nil,
			  "cmndlg.color() owner frame already has popup.")

	local dlg = pickColorClass:new (owner_frame)
	if dlg then
		if dlg:do_modal (init_color, bgcolor) == 32771 then
			return dlg.user_color
		end
	end

	return nil
end
