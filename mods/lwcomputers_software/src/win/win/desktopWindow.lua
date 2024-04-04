local private = ...



private.desktopWindow = win.window:base ()



function private.desktopWindow:constructor (type, dir, width, channels)
	if not win.window.constructor (self, nil, win.ID_DESKTOP, 0, 0, 0, 0) then
		return nil
	end

	self.dt__taskbar = nil
	self.dt__home_page = nil
	self.dt__app_list = nil
	self.dt__lock_screen = nil
	self.dt__sys_msgbox = nil
	self.dt__keyboard = nil
	self.dt__keyboard_fullscreen = nil
	self.dt__capture_mouse_wnd = nil
	self.dt__drag_wnd = nil
	self.dt__lockable = true
	self.dt__clipboard_data = nil
	self.dt__clipboard_type = win.CB_EMPTY
	self.gdi = win.GDI:new (type, dir, self, width, channels)
	self.dt__theme = self:create_theme ()
	self:set_bg_color (self:get_colors ().desktop_back)
	self:set_text ("desktop "..dir)
	local width, height = self.gdi:get_size ()
	self:move (0, 0, width, height, nil)

	return self
end



function private.desktopWindow:get_theme ()
	return self.dt__theme
end



function private.desktopWindow:get_lockable ()
	return self.dt__lockable
end



function private.desktopWindow:set_lockable (lockable)
	self.dt__lockable = lockable ~= false

	self.dt__home_page.lock_btn:show (self:can_lock ())
end



function private.desktopWindow:get_taskbar_index ()
	for i = 1, self:children (), 1 do
		if self:get_child (i) == self.dt__taskbar then
			return i
		end
	end

	return 0
end



function private.desktopWindow:get_active_app_frame ()
	if self:children() > 0 then
		for i = self:get_taskbar_index () + 1, self:children (), 1 do
			local frame = self:get_child (i)

			if frame.wnd__frame_class == private.FRAME_CLASS_APPLICATION then
				return frame
			end
		end
	end

	return nil
end



function private.desktopWindow:get_active_frame ()
	if self:children () > 0 then
		return self:get_child (self:get_taskbar_index () + 1)
	end

	return nil
end



function private.desktopWindow:get_next_app_frame (frame)
	local start = self:child_index (frame)

	if start > 0 then
		for i = start + 1, self:children (), 1 do
			local top = self:get_child (i)

			if top.wnd__frame_class == private.FRAME_CLASS_APPLICATION then
				return top
			end
		end
	end

	return nil
end



function private.desktopWindow:get_focus_wnd ()
	local frame = self:get_active_frame ()

	if frame then
		return frame.pFrame__focused_wnd
	end

	return nil
end



function private.desktopWindow:set_active_frame (frame)
	local cur_frame = self:get_active_frame ()

	if frame and frame ~= cur_frame then
		self.dt__capture_mouse_wnd = nil
		self.dt__drag_wnd = nil

		local i = self:child_index (frame)

		if i > 0 then
			if cur_frame then
				local success, msg = pcall (cur_frame.on_frame_activate, cur_frame, false)
				if not success then
					win.syslog (cur_frame:get_text ().." on_frame_activate "..msg)
				end
				cur_frame:invalidate ()

				if cur_frame.pFrame__focused_wnd then
					cur_frame.pFrame__focused_wnd:send_event ("blur", nil)
				end
			end

			i = self:get_taskbar_index () - i + 1
			if i ~= 0 then
				win.window.move (frame, nil, nil, nil, nil, i)
			end

			frame:invalidate ()

			local focus = frame.pFrame__focused_wnd
			if not focus then
				focus = frame:next_wnd (nil, true)
			end

			if focus then
				frame.pFrame__focused_wnd = nil
				focus:set_focus ()
			end

			local success, msg = pcall (frame.on_frame_activate, frame, true)
			if not success then
				win.syslog (frame:get_text ().." on_frame_activate "..msg)
			end

			return true
		end
	end

	return (frame == cur_frame)
end



function private.desktopWindow:update (force)
	if force then
		self:invalidate ()
	end

	local rt_result = win.rect:new ()

	if not self.wnd__invalid:is_empty () then
		local first = self:children () + 1
		local rt = self:get_work_area ()
		rt.width = rt.width - 1
		rt.height = rt.height - 1

		self.gdi:store ()

		self.gdi:add_bounds (self.wnd__invalid)

		for i = 1, self:children (), 1 do
			local frame = self:get_child (i)
			local rtWnd = frame:get_screen_rect ()
			if rtWnd:contains (rt.x, rt.y) and
				rtWnd:contains (rt.x + rt.width - 1, rt.y + rt.height - 1) then

				first = i
				break
			end
		end

		if first > self:children () then
			first = self:children ()

			self.gdi:set_colors (self:get_color (), self:get_bg_color ())
			self.gdi:clear (self.wnd__invalid:unpack ())

			self:draw (self.gdi, win.rect:new (self.wnd__invalid:unpack ()))
		end

		for i = first, 1, -1 do
			local frame = self:get_child (i)

			if frame:get_screen_rect ():overlap (self.gdi:get_bounds ()) then
				self.gdi:add_bounds (frame:update (force or i < first))
			end
		end

		self.gdi:update ()
		rt_result = self.gdi:get_bounds (true)
		self:validate ()
		self.gdi:restore ()
	end

	return rt_result
end



function private.desktopWindow:do_idle (count)
	for i = 1, self:children (), 1 do
		self:get_child (i):send_event ("idle", count)
	end
end



function private.desktopWindow:load_app_list ()
	self.dt__app_list:load_list ()
end



function private.desktopWindow:run_app (path, ...)
	self:get_workspace ():run_app (self:get_dir (), path, unpack (win.parse_cmdline (...)))
	self:load_app_list ()
end



function private.desktopWindow:on_resize ()
	self:move (0, 0, self.gdi:get_size ())

	for i = 1, self:children (), 1 do
		self:get_child (i):send_event ("monitor_resize")
	end

	return true
end



function private.desktopWindow:get_fullscreen ()
	if self.dt__taskbar then
		return self.dt__taskbar.wnd__hidden ~= false
	end

	return false
end



function private.desktopWindow:set_fullscreen (fullscreen)
	if fullscreen == nil then
		fullscreen = not self:get_fullscreen ()
	end

	if fullscreen ~= self:get_fullscreen () then
		local focus_wnd = self:get_focus_wnd ()

		self.dt__taskbar:show (not fullscreen)
		self:on_resize ()

		if focus_wnd then
			pcall (focus_wnd.on_move, focus_wnd)
		end
	end
end



function private.desktopWindow:get_work_area ()
	local rt = win.rect:new (0, 0, self.gdi:get_size ())

	if not self:get_fullscreen () then
		rt.height = rt.height - 1
	end

	return rt
end



function private.desktopWindow:capture_mouse (wnd)
	self.dt__capture_mouse_wnd = wnd
end



function private.desktopWindow:captured_mouse ()
	return self.dt__capture_mouse_wnd
end



function private.desktopWindow:get_clipboard ()
	return self.dt__clipboard_type, self.dt__clipboard_data
end



function private.desktopWindow:set_clipboard (data, cbType)
	if data == nil then
		self.dt__clipboard_type = win.CB_EMPTY
		self.dt__clipboard_data = nil
	else
		self.dt__clipboard_data = data

		if cbType == nil then
			self.dt__clipboard_type = win.CB_TEXT
		else
			self.dt__clipboard_type = cbType
		end
	end
end



function private.desktopWindow:drop_app (frame)
	local app = self:get_active_frame ()
	if app then
		app = app:get_app_frame ()
	end

	if frame == app then
		local next_frame = self:get_next_app_frame (frame)

		if next_frame then
			next_frame:set_active_top_frame ()
		else
			self:show_home_page ()
		end
	end

	frame:destroy_wnd ()

	self:load_app_list ()
end



function private.desktopWindow:enum_apps (iterator)
	if iterator == nil then
		iterator = self:get_taskbar_index () + 1
	end

	local frame = self:get_child (iterator)
	while frame do
		if frame.wnd__frame_class == private.FRAME_CLASS_APPLICATION then
			iterator = iterator + 1
			return iterator, frame
		end

		iterator = iterator + 1
		frame = self:get_child (iterator)
	end

	return iterator, nil
end



function private.desktopWindow:set_text_scale (scale)
	if self.gdi:is_monitor () then
		self.gdi:set_scale (scale)

		self:on_resize ()
	end
end



function private.desktopWindow:show_home_page ()
	self.dt__home_page:set_active_top_frame ()
end



function private.desktopWindow:show_list_page ()
	self.dt__app_list:set_active_top_frame ()
end



function private.desktopWindow:show_lock_screen ()
	if self:get_password ():len() > 0 then
		self.dt__lock_screen:set_active_top_frame ()
	end
end



function private.desktopWindow:hide_lock_screen ()
	local app = self:get_active_frame ()
	if app then
		app = app:get_app_frame ()
	end

	if self.dt__lock_screen == app then
		local next_frame = self:get_next_app_frame (self.dt__lock_screen)
		if next_frame then
			next_frame:set_active_top_frame ()
		else
			self:show_home_page ()
		end
	end
end



function private.desktopWindow:save_theme (theme)
	local theme_path = "/win/devices/"..self:get_dir ().."/theme.ini"
	local result = false
	local file = io.open (theme_path, "w")

	if file then
		local data = utils.serialize (theme)

		if data then
			file:write (data)

			result = true
		end

		file:close()
	end

	return result
end



function private.desktopWindow:load_theme ()
	local theme_path = "/win/devices/"..self:get_dir ().."/theme.ini"
	local theme = nil

	if fs.file_exists (theme_path, false) then
		local file = io.open (theme_path, "r")

		if file then
			local data = file:read ("*a")

			if data then
				local success, th = pcall (utils.deserialize, data)

				if success then
					theme = th
				end
			end

			file:close()
		end
	end

	return theme
end



function private.desktopWindow:create_theme ()
	local theme = self:load_theme ()

	if not theme then
		theme = win.desktopTheme:new ()
		self:save_theme (theme)
	end

	if theme.keyboard_height < 5 then
		theme.keyboard_height = 5
	end

	theme.close_btn = tostring (theme.close_btn or "x")
	if theme.close_btn:len () > 1 then
		theme.close_btn = theme.close_btn:sub (1, 1)
	end

	return theme
end



function private.desktopWindow:do_keyboard (target_wnd)
	if not self.dt__keyboard then
		self.dt__keyboard = private.keyboardFrame:new (self:get_dir (), target_wnd)

		if self.dt__keyboard then
			self.dt__keyboard_fullscreen = self:get_fullscreen ()
			self:set_fullscreen (true)
			self.dt__keyboard.appFrame__app_thread = coroutine.create (self.dt__keyboard.run_app)

			if not self.dt__keyboard.appFrame__app_thread then
				self:set_fullscreen (self.dt__keyboard_fullscreen)

				error ("Failed to create ketboard frame", 1)
			end

			local success, msg = coroutine.resume (self.dt__keyboard.appFrame__app_thread, self.dt__keyboard)

			if not success then
				self:set_fullscreen (self.dt__keyboard_fullscreen)
				self.dt__keyboard = nil

				error ("Error initialising keyboard frame ".."\n"..msg, 1)
			end
		end
	end
end



function private.desktopWindow:dismiss_keyboard ()
	if self.dt__keyboard then
		self.dt__keyboard:dismiss ()
		self:set_fullscreen (self.dt__keyboard_fullscreen)
		self.dt__keyboard = nil
	end
end



function private.desktopWindow:create_bars ()
	local title;
	local ini = fs.load_ini ("/win/devices/"..self:get_dir ().."/startup.ini")

	if ini then
		title = ini:find ("home")
	end

	self.dt__taskbar = private.taskBarFrame:new (self:get_dir ())
	private.run_app_frame (self.dt__taskbar)

	self.dt__home_page = private.homePageFrame:new (self:get_dir (), title)
	private.run_app_frame (self.dt__home_page)

	self.dt__app_list = private.appListFrame:new (self:get_dir ())
	private.run_app_frame (self.dt__app_list)

	self.dt__lock_screen = private.lockScrnFrame:new (self:get_dir ())
	private.run_app_frame (self.dt__lock_screen)

	self.dt__sys_msgbox = private.sysMsgBoxFrame:new (self:get_dir ())
	private.run_app_frame (self.dt__sys_msgbox)

	self.dt__home_page:load_list ()
	self:show_home_page ()
end



function private.desktopWindow:msgbox (title, message, bgcolor)
	local app = self:get_active_frame ()

	if app ~= self.dt__sys_msgbox then
		self.dt__sys_msgbox:do_msgbox (title, message, bgcolor, app)
	end
end



function private.desktopWindow:hide_msgbox ()
	local app = self:get_active_frame ()
	if app then
		app = app:get_app_frame ()
	end

	if self.dt__sys_msgbox == app then
		local next_frame = self:get_next_app_frame (self.dt__sys_msgbox)

		if next_frame then
			next_frame:set_active_top_frame ()
		else
			self:show_home_page ()
		end
	end
end



function private.desktopWindow:lock_screen ()
	if not self:is_locked () and self.dt__lockable then
		self:show_lock_screen ()
	end
end



function private.desktopWindow:is_locked ()
	return self.dt__lock_screen == self:get_active_frame ()
end



function private.desktopWindow:can_lock ()
	return self.dt__lockable and private.get_password ():len() > 0
end



function private.desktopWindow:get_password ()
	return private.get_password ()
end



function private.desktopWindow:is_touch (channel, msg)
	return self.gdi:is_touch (channel, msg)
end
