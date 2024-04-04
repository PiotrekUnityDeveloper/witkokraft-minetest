local private = ...



function private.get_password ()
   local ini = fs.load_ini ("/win.ini")
   local password = ""

   if ini then
      password = tostring (ini:find ("password") or "")
   end

   return password
end



function private.safe_read (mask)
   local entered = ""

   mask = tostring (mask or ""):sub (1, 1)
   term.set_blink (true)

   while true do
      local event, param = os.get_event ()

      if event == "key" then
         if param == keys.KEY_ENTER then
            term.set_blink (false)

            return entered

         elseif param == keys.KEY_BACKSPACE then
            if entered:len () > 0 then
               local x, y = term.get_cursor ()

               entered = entered:sub (1, -2)

               term.set_cursor (x - 1, y)
               term.write (" ")
            end

         end
      elseif event == "char" then
			local x, y = term.get_cursor ()

         entered = entered..param

         if mask:len() == 1 then
            term.write (mask)
         else
            term.write (param)
         end

         term.set_cursor (x + 1, y)
      end
   end
end





function private.run_app_frame (frame)
   frame.appFrame__app_thread = coroutine.create (frame.run_app)

   if not frame.appFrame__app_thread then
      error ("Failed to create system frame", 2)
   end

   local success, msg = coroutine.resume (frame.appFrame__app_thread, frame)

   if not success then
      error ("Error initialising system frame ".."\n"..msg, 2)
   end
end



private.reboot = os.reboot
private.shutdown = os.shutdown


os.reboot = function ()
	private.workspace.ws__shutdown = 1
end


os.shutdown = function ()
	private.workspace.ws__shutdown = 2
end
