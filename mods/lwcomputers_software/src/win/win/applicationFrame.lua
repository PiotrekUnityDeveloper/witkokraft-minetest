local private = ...



win.printData = win.__classBase:base ()



function win.printData:constructor (printer, from_page, to_page, pages, title, user_data)
	self.printer = tostring (printer)
	self.from_page = tonumber(from_page) or 0
	self.to_page = tonumber (to_page) or 0
	self.pages = tonumber (pages) or 0
	self.title = tostring (title or "")
	self.data = user_data

	return self
end



win.applicationFrame = private.parentFrame:base ()



function win.applicationFrame:constructor (dir)
	local desktop = private.workspace:get_desktop (dir)
	local rtWork = desktop:get_work_area ()

	if not private.parentFrame.constructor (self, desktop, private.ID_FRAME, rtWork:unpack ()) then
		return nil
	end

	self.wnd__frame_class = private.FRAME_CLASS_APPLICATION
	self.appFrame__app_thread = nil
	self.appFrame__app_path = nil
	self.appFrame__yield_point = "modal"

	return self
end



function win.applicationFrame:on_create ()
	return true
end



function win.applicationFrame:get_app_path ()
	return self.appFrame__app_path
end



function win.applicationFrame:on_resize ()
	self:move (self:get_desktop ():get_work_area ():unpack ())

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



function win.applicationFrame:quit_app ()
	if self:on_quit () then
		return
	end

	self:end_modal (0)
end



function win.applicationFrame:on_quit ()
	return false
end



function win.applicationFrame:on_frame_close ()
	self:quit_app ()

	return true
end



function win.applicationFrame:dress (title)
	self:set_text (title)

	win.closeButtonWindow:new (self, self.width - 1, 0):set_focus ()

	local titlebar = win.labelWindow:new (self, win.ID_TITLEBAR,
													  math.floor((self.width - title:len()) / 2),
													  0, title)
	titlebar:set_bg_color (titlebar:get_colors ().title_back)
	titlebar:set_color (titlebar:get_colors ().title_text)
end



function win.applicationFrame:draw (gdi, bounds)
--	local cx, cy = gdi:get_cursor ()

	win.window.draw (self, gdi, bounds)

	if bounds.y < 1 then
		if self:get_wnd_by_id (win.ID_TITLEBAR) then
			gdi:set_colors (nil, self:get_colors ().title_back)
			gdi:clear (0, 0, self.width, 1)
		end
	end

--	gdi:set_cursor (cx, cy)
end



function win.applicationFrame:set_title (title)
	local text = self:get_wnd_by_id (win.ID_TITLEBAR)

	self:set_text (title)

	if text then
		text:set_text (title)
		text:move (nil, nil, text:get_text ():len ())
		self:on_resize ()
	end
end



function win.applicationFrame:run_app ()
	if self:on_create () then
		self:run_modal ()
	end

	self:get_desktop ():drop_app (self)
end



function win.applicationFrame:on_print_page (gdi, page, data)
	return false
end



local function get_printer_status (gdi)
	local status = gdi:get_status ()

	if not status then
		status = "not connected"
	end

	return status
end



function win.applicationFrame:print_loop (data)
	if data then
		local continue = true
		local page = math.max (1, data.from_page)
		local gdi = win.GDI:new_for_printer (data.printer)
		local title = ((page == 1) and data.title) or string.format("%s %d", data.title, page)

		assert (gdi, "Failed to create printer GDI for "..data.printer)

		while true do
			local status = get_printer_status (gdi)

			while status ~= "ready" do
				if not cmndlg.confirm (self, "Check Printer",
							"Check printer \""..gdi:get_dir ().."\" ("..
								tostring (status)..").\nPress Ok to continue.",
							true) then

					return
				end

				os.sleep (1.0)

				status = get_printer_status (gdi)
			end

			gdi:start_page (title, page)

			continue = self:on_print_page (gdi, page, data)

			page = page + 1

			gdi:end_page ()

			os.sleep (0.2)

			if not continue or (data.to_page > 0 and page > data.to_page) then
				return
			end
		end
	end
end



function win.applicationFrame:on_print_data (title, user_data, pages, bgcolor)
	local printer, from_page, to_page = cmndlg.print (self, pages, bgcolor)

	if printer then
		return win.printData:new (printer, from_page, to_page, pages, title, user_data)
	end

	return nil
end



function win.applicationFrame:print_doc ()
	self:print_loop (self:on_print_data ())
end



function win.applicationFrame:status ()
	local status = coroutine.status (self.appFrame__app_thread)

	if status == "suspended" then
		return self.appFrame__yield_point
	end

	return status
end



function win.applicationFrame:resume (wnd, ... )
	local status = self:status ()
	local params

	if status == "dead" then
		self:get_desktop ():msgbox ("Error",
											 self:get_text ().." was not responding.",
											 term.colors.red)
		self:get_desktop ():drop_app (self)

		return false

	elseif status == "modal" then
		params = { coroutine.resume (self.appFrame__app_thread, wnd, ... ) }
	else
		params = { coroutine.resume (self.appFrame__app_thread, ... ) }
	end

	local success = table.remove (params, 1)

	self.appFrame__yield_point = params[1]

	if success then
		if self.appFrame__yield_point == "modal" then
			return params[2]
		else
			return params
		end
	end

	return false
end
