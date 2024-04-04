local private = ...



private.homePageFrame = win.applicationFrame:base ()



function private.homePageFrame:constructor (dir, title)
	if not win.applicationFrame.constructor (self, dir) then
		return nil
	end

	local rt = self:get_desktop ():get_work_area ()
	self.wnd__id = private.ID_MENUFRAME
	self.wnd__frame_class = private.FRAME_CLASS_SYSTEM
	self:set_color (self:get_colors ().home_text)
	self:set_bg_color (self:get_colors ().home_back)
	self:set_text ("home page")

	title = tostring (title or "")
	if title:len () < 1 then
		title = tostring (os.get_name () or "")
		if title:len () < 1 then
			title = "Home"
		end
	end

	self.title = win.labelWindow:new (self, 0, math.floor((rt.width - title:len()) / 2), 1, title)
	self.title:set_color (self:get_colors ().home_text)
	self.title:set_bg_color (self:get_colors ().home_back)

	self.list = win.listWindow:new (self, private.ID_MENULIST, 2, 3,
											  rt.width - 4, rt.height - 4)
	self.list:set_colors (self:get_colors ().home_item_text,
								 self:get_colors ().home_item_back,
								 self:get_colors ().home_item_back,
								 self:get_colors ().home_item_selected_text,
								 self:get_colors ().home_item_selected_back)

	self.lock_btn = win.buttonWindow:new (self, private.ID_HOMELOCK,
													  rt.width - 4, rt.height - 1, "lock")
	self.lock_btn:set_colors (self:get_colors ().home_text,
									  self:get_colors ().home_back,
									  self:get_colors ().scroll_back)
	self.lock_btn:show (self:get_desktop ():can_lock ())

	self.pFrame__focused_wnd = self.list

	return self
end



function private.homePageFrame:load_list ()
	self.list:reset_content ()

	local lines = { }
	local line, last_line;
	local file = io.open ("/win/devices/"..self:get_desktop ():get_dir ().."/desktop.ini", "r")

	if file then
		line = file:read ("*l")

		while line do
			lines[#lines + 1] = line
			line = file:read ("*l")
		end

		file:close ()

		last_line = math.floor (#lines / 5) * 5

		for line = 1, last_line, 5 do
			local app =
			{
				name = lines[line],
				path = lines[line + 1],
				arguments = lines[line + 2],
				dummy1 = lines[line + 3],
				dummy2 = lines[line + 4]
			}

			self.list:add_string (app.name, app)
		end
	end

	if self.list:count () > 0 then
		self.list:set_cur_sel (1)
	end
end



function private.homePageFrame:on_resize ()
	local rt = self:get_desktop ():get_work_area ()

	self:move (rt:unpack ())
	self.title:move (math.floor((rt.width - self.title:get_text ():len ()) / 2))
	self.lock_btn:move (rt.width - 4, rt.height - 1)
	self.list:move (2, 3, rt.width - 4, rt.height - 4)

	return true
end



function private.homePageFrame:on_event (event, p1, p2, p3, p4, p5, ...)
	if event == "list_click" then
		if p1:get_id () == private.ID_MENULIST then
			local app = self.list:get_data ()

			if app then
				self:get_desktop ():run_app (app.path, app.arguments)
			end

			return true
		end

	elseif event == "btn_click" then
		if p1:get_id () == private.ID_HOMELOCK then
			self:get_desktop ():lock_screen ()

			return true
		end

	end

	return false
end



function private.homePageFrame:on_quit ()
	return true
end



function private.homePageFrame:on_frame_activate (active)
	if active then
		self:load_list ()
		self.list:set_focus ()
		self.lock_btn:show (self:get_desktop ():can_lock ())
	end
end
