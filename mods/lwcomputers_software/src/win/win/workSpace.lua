local private = ...



private.workSpace = win.__classBase:base()



function private.workSpace:constructor ()
	self.ws__desktops = {}
	self.ws__last_update = -1
	self.ws__app_thread = nil
	self.ws__app_dir = nil
	self.ws__app_path = nil
	self.ws__app_frame = nil
	self.ws__syscomms = 0
	self.ws__comms = {}
	self.ws__timers = {}
	self.ws__wnd_events = {}
	self.ws__shutdown = 0

	return self
end



function private.workSpace:comm_enabled ()
	return (self.ws__syscomms > 0)
end



function private.workSpace:comm_find (name)
	if name then
		for i = 1, #self.ws__comms, 1 do
			if name == self.ws__comms[i]:get_name () then
				return self.ws__comms[i]
			end
		end

		return nil
	end

	return self.ws__comms[1]
end



function private.workSpace:comm_open (name, timeout)
	if not name then
		local count = 0
		repeat
			name = "comm_"..tostring (count)
			count = count + 1
		until not self:comm_find (name)
	end

	local com = win.comm:new (name, timeout)
	self.ws__comms[#self.ws__comms + 1] = com

	return com
end



function private.workSpace:comm_close (name)
	if name then
		local index;

		for i = self.ws__syscomms + 1, 1, -1 do
			if name == self.ws__comms[i]:get_name () then
				index = i
				break
			end
		end

		if index then
			table.remove (self.ws__comms, index)

			return true
		end
	end

	return false
end



function private.workSpace:comm_register (wnd, application, name)
	local com = self:comm_find (name)
	if com then
		com:register (wnd, application)
		return true
	end

	return false
end



function private.workSpace:comm_unregister (wnd, application, name)
	if name then
		local com = self:comm_find (name)
		if com then
			com:unregister (wnd, application)
			return true
		end
	else
		for i = 1, #self.ws__comms, 1 do
			self.ws__comms[i]:unregister (wnd, application)
		end

		return true
	end

	return false
end



function private.workSpace:comm_send (recipient, application, context, data, name)
	local com = self:comm_find (name)
	if com then
		return com:send (recipient, application, context, data)
	end

	return nil
end



function private.workSpace:get_desktop (dir)
	return self.ws__desktops[tostring (dir or "")]
end



function private.workSpace:desktops ()
	local dirs = { }

	for dir, desktop in pairs(self.ws__desktops) do
		dirs[#dirs + 1] = dir
	end

	return dirs
end



function private.workSpace:get_focus_wnd (dir)
	if self:get_desktop (dir) then
		return self:get_desktop (dir):get_focus_wnd ()
	end

	return nil
end



function private.workSpace:start_timer (wnd, timeout)
	local id = 0
	timeout = tonumber (timeout) or 0

	if timeout > 0 then
		id = os.start_timer (timeout)

		self.ws__timers[#self.ws__timers + 1] = { id, wnd, "timer" }
	end

	return id
end



function private.workSpace:kill_timer (wnd, timer_id)
	for i = #self.ws__timers, 1, -1 do
		if self.ws__timers[i][1] == timer_id and
				self.ws__timers[i][2] == wnd  and
				self.ws__timers[i][3] == "timer" then
			os.kill_timer (self.ws__timers[i][1])

			table.remove (self.ws__timers, i)

			break
		end
	end
end



function private.workSpace:set_alarm (wnd, time)
	local id = 0
	local timeout = (tonumber(time) or 0) - os.time ()

	if timeout > 0 then
		id = os.start_timer (timeout)

		self.ws__timers[#self.ws__timers + 1] = { id, wnd, "alarm" }
	end

	return id
end



function private.workSpace:kill_alarm (wnd, alarm_id)
	for i = #self.ws__timers, 1, -1 do
		if self.ws__timers[i][1] == alarm_id and
				self.ws__timers[i][2] == wnd  and
				self.ws__timers[i][3] == "alarm" then
			os.kill_timer (self.ws__timers[i][1])

			table.remove (self.ws__timers, i)

			break
		end
	end
end



function private.workSpace:kill_timers (wnd)
	for i = #self.ws__timers, 1, -1 do
		if self.ws__timers[i][2] == wnd then
			os.kill_timer (self.ws__timers[i][1])

			table.remove (self.ws__timers, i)
		end
	end
end



function private.workSpace:want_event (wnd, event)
	event = tostring (event or "")

	for i = 1, #self.ws__wnd_events, 1 do
		if self.ws__wnd_events[i][1] == wnd and
				(self.ws__wnd_events[i][2] == event or
					self.ws__wnd_events[i][2] == "*" or event == "*") then
			return false
		end
	end

	self.ws__wnd_events[#self.ws__wnd_events + 1] = { wnd, event }

	return true
end



function private.workSpace:unwant_event (wnd, event)
	event = tostring (event or "")

	if event:len() > 0 then
		for i = 1, #self.ws__wnd_events, 1 do
			if self.ws__wnd_events[i][1] == wnd and
					self.ws__wnd_events[i][2] == event then
				table.remove (self.ws__wnd_events, i)

				return true
			end
		end
	else
		local count = 0

		for i = #self.ws__wnd_events, 1, -1 do
			if self.ws__wnd_events[i][1] == wnd then
				table.remove(self.ws__wnd_events, i)
				count = count + 1
			end
		end

		return (count > 0)
	end

	return false
end



function private.workSpace:run_app (dir, path, ...)
	local result, msg = loadfile (path)

	if not result then
		error ("Failed to load program "..path.."\n"..msg, 0)
	end

	self.ws__app_thread = coroutine.create (result)

	if not self.ws__app_thread then
		error ("Failed to create application "..fs.path_name (path), 0)
	end

	self.ws__app_dir = dir
	self.ws__app_path = path
	result, msg = coroutine.resume (self.ws__app_thread, ...)

	if not result then
		if self.ws__app_frame then
			msg = self.ws__app_frame:get_text ().."\n"..msg
			self:get_desktop (dir):drop_app (self.ws__app_frame)
			self.ws__app_frame = nil
		end

		error (msg, 0)
	end

	self.ws__app_frame = nil
end



function private.workSpace:ctrlkey ()
	return os.key_state (keys.KEY_CTRL)
end



function private.workSpace:altkey ()
	return os.key_state (keys.KEY_ALT)
end



function private.workSpace:shiftkey ()
	return os.key_state (keys.KEY_SHIFT)
end



function private.workSpace:combo_keys (ctrl, alt, shift)
	local bCtrl, bAlt, bShift;

	if ctrl then
		bCtrl = self:ctrlkey ()
	else
		bCtrl = not self:ctrlkey ()
	end

	if alt then
		bAlt = self:altkey ()
	else
		bAlt = not self:altkey ()
	end

	if shift then
		bShift = self:shiftkey ()
	else
		bShift = not self:shiftkey ()
	end

	return (bCtrl and bAlt and bShift)
end



function private.workSpace:create_desktop (type, dir, width, channels)
	local desktop_file = "/win/devices/"..dir.."/desktop.ini"

	if fs.file_exists (desktop_file, false) then
		if type == "term" then
			return private.desktopWindow:new (type, dir, width, channels)
		end

		local desktop = private.desktopWindow:new (type, dir, width, channels)

		if desktop then
			desktop:set_text_scale (desktop:get_theme ().text_scale)
		end

		return desktop
	end

	return nil
end



function private.workSpace:desktop_startup (dir)
	local desktop = self:get_desktop (dir)

	if desktop then
		local ini = fs.load_ini ("/win/devices/"..dir.."/startup.ini")

		if ini then
			if tostring (ini:find ("nolock") or "false") == "true" then
				desktop:set_lockable (false)
			end

			if tostring (ini:find ("fullscreen") or "false") == "true" then
				desktop:set_fullscreen (true)
			end

			for path in ini:next ("run") do
				if path:len () > 0 then
					self:run_app (dir, unpack (win.parse_cmdline (path)))
					os.sleep (0.1)
				end
			end

			desktop:load_app_list ()
		end
	end
end



function private.workSpace:create_desktops ()
	local file = io.open ("/win/devices/desktops.lua", "r")

	if not file then
		win.syslog ("Could not open desktops.lua")

		return
	end

	local contents = file:read ("*a")
	file:close ()

	if not contents then
		win.syslog ("Could not read desktops.lua")

		return
	end

	local result, desktops = pcall (utils.deserialize, contents)

	if not result or type (desktops) ~= "table" then
		win.syslog ("Could not read desktops.lua")

		return
	end

	local dts = { }
	for _, dt in ipairs (desktops) do
		if dt.type == "term" then
			if not dts["term"] then
				dts["term"] = dt
			end

		elseif dt.type == "monitor" and type (dt.dir) == "string" and dt.channels then
			if not dts[dt.dir] then
				dts[dt.dir] = dt

				if dt.channels then
					local channels = dt.channels

					if type (channels) ~= "table" then
						channels = { dt.channels }
					end

					dts[dt.dir].channels = channels
				end
			end
		end
	end

	for dir, dt in pairs (dts) do
		self.ws__desktops[dir] = self:create_desktop (dt.type, dir, dt.width, dt.channels)

		if self.ws__desktops[dir] then
			self.ws__desktops[dir]:create_bars ()
		end
	end

	for dir, dt in pairs (dts) do
		self:desktop_startup (dir)
	end
end



function private.workSpace:pump_event (wnd, ... )
	if wnd then
		local app = wnd:get_app_frame ()

		if app then
			local params = app:resume (wnd, ... )

			if type (params) == "table" then
				while true do
					if #params < 1 then
						return false
					end

					params = app:resume (wnd, coroutine.yield (unpack (params)))

					if type (params) ~= "table" then
						break
					end
				end
			end

			return params
		end
	end

	return false
end



function private.workSpace:startup ()
	local had_key = false
	local timer_id;
	local do_lock_screen = false
	local ini = fs.load_ini ("/win.ini")

	term.set_colors (term.colors.white, term.colors.black)
	term.clear ()
	term.set_cursor (0, 0)
	print ("Starting ")
	term.set_colors (term.colors.yellow, term.colors.black)
	print ("WIN\nversion %s\n", tostring (win.version ()))

	os.sleep (0.1)

	if ini then
		local pw = tostring (ini:find ("password") or "")
		local err = false

		if pw:len () > 0 then
			do_lock_screen = true
		end

		for path in ini:next ("pre") do
			if path:len () > 0 then
				local success, func, msg

				fxn, msg = loadfile (path)

				if not fxn then
					local errstr = string.format ("%s (%s)\n", msg, path)
					win.syslog (errstr)
					term.set_colors (term.colors.red, term.colors.black)
					print ("%s\n", errstr)
					err = true
				else
					success, msg = pcall (fxn)

					if not success then
						local errstr = string.format ("%s (%s)\n", msg, path)
						win.syslog (errstr)
						term.set_colors (term.colors.red, term.colors.black)
						print ("%s\n", errstr)
						err = true
					end
				end
			end
		end

		for path in ini:next ("api") do
			if path:len () > 0 then
				local success, msg = win.load_api (path, true)

				if not success then
					local errstr = string.format ("%s (%s)", msg, path)
					win.syslog (errstr)
					term.set_colors (term.colors.red, term.colors.black)
					print ("%s\n", errstr)
					err = true
				end
			end
		end

		for name in ini:next ("comm") do
			local timeout = tonumber (ini:find (name.."timeout") or 5) or 5

			if self:comm_open (name, timeout) then
				self.ws__syscomms = self.ws__syscomms + 1
			else
				local errstr = string.format ("Could not open comm %s", name)
				win.syslog (errstr)
				term.set_colors (term.colors.red, term.colors.black)
				print ("%s\n", errstr)
				err = true
			end
		end

		if err then
			term.set_colors (term.colors.silver, term.colors.black)
			print ("Press key...")
			while (os.get_event ()) ~= "key" do
			end
		end
	end

	self:create_desktops()

	if not self.ws__desktops.term then
		term.clear ()
		term.set_cursor (0, 0)
		term.set_colors (term.colors.yellow, term.colors.black)
		print ("WIN "..tostring (win.version ()))
		term.set_colors (term.colors.white, term.colors.black)
		print (" running")
	end

	term.set_blink (false)

	self.ws__last_update = os.clock () - 1

	fs.mkdir ("/tmp")
   local file = io.open ("/win.log", (fs.file_exists ("/win.log") and "a") or "w")
   if file then
      file:close ()
   end

	for k, desktop in pairs (self.ws__desktops) do
		if desktop then
			if do_lock_screen then
				desktop:lock_screen ()
			end

			if not desktop:update (false):is_empty () then
				self.ws__last_update = os.clock ()
			end
		end
	end

	os.sleep (0.1)
end



function private.workSpace:dispatch_event (event, p1, p2, p3, p4, p5, ...)
	local wnd;

	if event == "digilines" then
		for dir, dt in pairs (self.ws__desktops) do
			local x, y = dt:is_touch (p2, p1)

			if x then
				event = "monitor_touch"
				p1 = dir
				p2 = x
				p3 = y

				break
			end
		end
	end

	if event == "timer" then
		for i = 1, #self.ws__timers, 1 do
			if self.ws__timers[i][1] == p1 then
				wnd = self.ws__timers[i][2]
				event = self.ws__timers[i][3]
				table.remove(self.ws__timers, i)

				break
			end
		end

		if not wnd then
			for i = 1, #self.ws__wnd_events, 1 do
				if self.ws__wnd_events[i][2] == event or self.ws__wnd_events[i][2] == "*" then
					self:pump_event (self.ws__wnd_events[i][1], event, p1, p2, p3, p4, p5, ...)
				end
			end
		end

	elseif event == "click" then
		if self.ws__desktops.term then
			p1 = tonumber (p1) or 0
			p2 = tonumber (p2) or 0
			p3 = tonumber (p3) or 0
			p4 = 1 -- left click only

			if self.ws__desktops.term:captured_mouse () then
				wnd = self.ws__desktops.term:captured_mouse ()
			else
				wnd = self.ws__desktops.term:wnd_from_point (p1, p2)
			end

			self.ws__desktops.term.dt__dragWnd = wnd
		end

	elseif event == "mouse_up" then
		if self.ws__desktops.term then
			p1 = tonumber (p1) or 0
			p2 = tonumber (p2) or 0
			p3 = 1 -- left click only

			if self.ws__desktops.term:captured_mouse () then
				wnd = self.ws__desktops.term:captured_mouse ()
			else
				wnd = self.ws__desktops.term:wnd_from_point (p2, p3)
			end

			self.ws__desktops.term.dt__dragWnd = wnd
		end

	elseif event == "mouse_drag" then
		if self.ws__desktops.term then
			p1 = tonumber (p1) or 0
			p2 = tonumber (p2) or 0
			p3 = 1 -- left click only

			if self.ws__desktops.term:captured_mouse () then
				wnd = self.ws__desktops.term:captured_mouse ()
			else
				wnd = self.ws__desktops.term.dt__dragWnd
			end
		end

	elseif event == "monitor_touch" then
		local desktop = self:get_desktop (p1)
		if desktop then
			p2 = tonumber (p2) or 0
			p3 = tonumber (p3) or 0

			if desktop:captured_mouse () then
				wnd = desktop:captured_mouse ()
			else
				wnd = desktop:wnd_from_point (p2, p3)
			end
		end

	elseif event == "char" or event == "clipboard" then
		if self.ws__desktops.term then
			wnd = self.ws__desktops.term:get_focus_wnd ()
		end

	elseif event == "key" then
		if self.ws__desktops.term ~= nil then
			if p1 == keys.KEY_X and self:combo_keys (true, true, false) then
				wnd = self.ws__desktops.term:get_active_frame ()

				if wnd then
					event = "frame_close"
					p1 = nil
				end
			elseif p1 == keys.KEY_H and self:combo_keys (false, true, false) then
				if self.ws__desktops.term.dt__taskbar:is_enabled () then
					self.ws__desktops.term:show_home_page ()
				end
			elseif p1 == keys.KEY_L and self:combo_keys (false, true, false) then
				if self.ws__desktops.term.dt__taskbar:is_enabled () then
					self.ws__desktops.term:show_list_page ()
				end
			elseif p1 == keys.KEY_K and self:combo_keys (true, true, false) then
				if self.ws__desktops.term.dt__taskbar:is_enabled () then
					self.ws__desktops.term:lock_screen ()
				end
			elseif p1 == keys.KEY_F10 and self:combo_keys (false, false, false) then
				self.ws__desktops.term:set_fullscreen ()
			else
				wnd = self.ws__desktops.term:get_focus_wnd ()

				p2 = self:ctrlkey ()
				p3 = self:altkey ()
				p4 = self:shiftkey ()
			end
		end

	elseif event == "key_up" then
		wnd = self.ws__desktops.term:get_focus_wnd ()

	elseif event == "mouse_scroll" then
		if self.ws__desktops.term then
			-- p1 is delta
			p2 = tonumber (p2) or 0
			p3 = tonumber (p3) or 0

			if self.ws__desktops.term:captured_mouse () then
				wnd = self.ws__desktops.term:captured_mouse ()
			else
				wnd = self.ws__desktops.term:wnd_from_point (p2, p3)
			end
		end

	elseif event == "monitor_resize" or event == "term_resize" then
		if self:get_desktop (p1) then
			self:get_desktop (p1):send_event (event, p1, p2, p3, p4, p5)
		end

	else
		if event == "wireless" then
			for i = 1, #self.ws__comms, 1 do
				self.ws__comms[i]:receive (p1, p2, p3)
			end
		end

		for i = 1, #self.ws__wnd_events, 1 do
			if self.ws__wnd_events[i][2] == event or self.ws__wnd_events[i][2] == "*" then
				self:pump_event (self.ws__wnd_events[i][1], event, p1, p2, p3, p4, p5, ...)
			end
		end

	end

	self:pump_event (wnd, event, p1, p2, p3, p4, p5, ...)

	if self.ws__shutdown > 0 then
		if self.ws__shutdown == 1 then
			private.reboot ()
		elseif self.ws__shutdown == 2 then
			private.shutdown ()
		end
	end

	for k, desktop in pairs (self.ws__desktops) do
		if desktop then
			if not desktop:update (false):is_empty () then
				self.ws__last_update = os.clock ()
			end
		end
	end
end



function private.workSpace:run ()
	local idle_count = 0
	local last_event_time = 0
	local comm_timer = nil

	while true do
		local event = { os.peek_event () }

		if #event > 0 then
			if event[1] == "timer" and event[2] == comm_timer then
				for i = 1, #self.ws__comms, 1 do
					self.ws__comms[i]:process ()
				end

				comm_timer = nil

				os.remove_event ()
			else
				idle_count = 0
				last_event_time = os.clock ()

				self:dispatch_event (os.remove_event ())
			end
		elseif (os.clock () - last_event_time) > 0.3 then
			idle_count = idle_count + 1
			last_event_time = os.clock ()

			for k, desktop in pairs (self.ws__desktops) do
				if desktop then
					desktop:do_idle (idle_count)
				end
			end

			for k, desktop in pairs (self.ws__desktops) do
				if desktop then
					if not desktop:update (false):is_empty () then
						self.ws__last_update = os.clock ()
					end
				end
			end
		end

		if not comm_timer and not (os.peek_event ()) then
			for i = 1, #self.ws__comms, 1 do
				if self.ws__comms[i]:is_processing () then
					comm_timer = os.start_timer (0.5)

					break
				end
			end
		end

		os.sleep (os.clock_speed () - 0.02)
	end
end
