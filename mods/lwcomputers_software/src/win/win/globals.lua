local private = ...



function win.version ()
   return 1.0
end



function string:trim_left (char)
   str = tostring (self or "")
   char = tostring (char or " ")

   if char:len () > 0 then
      while str:sub (1, char:len ()) == char do
         str = str:sub (char:len () + 1)
      end
   end

   return str
end



function string:trim_right (char)
   str = tostring (self or "")
   char = tostring (char or " ")

   if char:len() > 0 then
      while str:sub (-1, -(char:len ())) == char do
         str = str:sub (1, -(char:len () + 1))
      end
   end

   return str
end



function string:trim (char)
   return string.trim_right (string.trim_left (self, char), char)
end



local function string_find_eol (str)
	local cr = (str:find ("\r")) or (str:len () + 1)
	local nl = (str:find ("\n")) or (str:len () + 1)

	return math.min (cr, nl)
end



function string:splice (len)
   str = tostring (self or "")
   len = tonumber (len or 0) or 0

   if len > 0 then
      local eol = string_find_eol (str)
      local nextLine = eol + 1

      if (eol - 1) <= len and eol <= str:len () then
         if str:byte (eol) == 13 and eol < str:len () then
            if str:byte (eol + 1) == 10 then
               nextLine = nextLine + 1
            end
         end

         return str:sub (1, eol - 1), (str:sub (nextLine) or ""), true, false
      end

      if str:len () <= len then
         return str, nil, false, false
      end

      for pos = len + 1, 1, -1 do
         if str:byte (pos) == 32 then
            return str:sub (1, pos - 1), (str:sub (pos + 1) or ""), true, false
         end
      end

      return str:sub (1, len), (str:sub (len + 1) or ""), true, true
   end

   return str, nil, false, false
end



function string:wrap (maxWidth)
   local wrapped = { }

   str = tostring (self or "")
   maxWidth = tonumber (maxWidth or 0) or 0

   repeat
      wrapped[#wrapped + 1], str = string.splice (str, maxWidth)
   until not str

   return wrapped
end



function string.wrap_size (wrapStr)
   local width = 0
   local height = 0

   if type (wrapStr) == "table" then
      height = #wrapStr

      for i = 1, height, 1 do
         if type (wrapStr[i]) ~= "string" then
            return 0, 0
         end

         if wrapStr[i]:len () > width then
            width = wrapStr[i]:len ()
         end
      end
   end

   return width, height
end



function fs.load_ini (path)
   local ini;

   path = tostring (path or "")

   if fs.file_exists (path, false) then
      local file = io.open (path, "r")

      if file then
         local content = file:read ("*a")

         if content then
            ini = { }

            for line in content:gmatch ("([^\r\n]*)[\r\n]*") do
               local comment, name, value = line:match ("(;*)([^=]*)=(.*)")

               if comment and comment:len () == 0 then
                  name = string.trim (name)

                  if name:len () > 0 then
                     ini[#ini + 1] =
                     {
                        name = name,
                        value = value
                     }
                  end
               end
            end


            function ini:find (key)
               for i = 1, #self, 1 do
                  if self[i].name == key then
                     return self[i].value
                  end
               end

               return nil
            end


            function ini:next (key)
               local init = 1

               return function ()
                  for i = init, #self, 1 do
                     if self[i].name == key then
                        init = i + 1
                        return self[i].value
                     end
                  end

                  init = #self + 1

                  return nil
               end
            end


         end

         file:close()
      end
   end

   return ini
end



function fs.tmpfile (prefix)
   local path;
   local counter = 0

   repeat
      path = "/tmp/"..tostring (prefix or "tmp")..tostring (counter)
      counter = counter + 1
   until not (fs.file_exists (path))

   return path
end



local function rm_dir (path)
	local removed = 0
	local list = fs.ls (path)

	if not list then
		return false, removed, msg
	end

	for i = 1, #list do
		local full = path.."/"..list[i]

		if fs.file_type (full) == "dir" then
			local result, count, msg = rm_dir (full)

			removed = removed + count

			if not result then
				return false, removed, msg
			end
		end

		local result, msg = fs.remove (full)

		if not result then
			return false, removed, msg
		end

		removed = removed + 1
	end

	return true, removed
end



function fs.rm (path, recurse)
	path = tostring (path or "")

	local mounts, msg = fs.ls ()

	if not mounts then
		return false, 0, msg
	end

	for i = 1, #mounts do
		if path == mounts[i] then
			if i == 1 then
				return false, 0, "can't remove root"
			else
				return false, 0, "can't remove mount"
			end
		end
	end

	if path:sub (-1) == "/" then
		return false, 0, "invalid path ("..path..")"
	end

	if not fs.file_exists (path) then
		return false, 0, "not found ("..path..")"
	end


	if fs.file_type (path) == "file" then
		local result, msg = fs.remove (path)

		if not result then
			return false, 0, msg
		end

		return true, 1
	end

	if fs.file_type (path) == "dir" then
		local removed = 0

		if recurse then
			local result, count, msg = rm_dir (path)

			removed = removed + count

			if not result then
				return false, removed, msg
			end
		end

		local result, msg = fs.remove (path)

		if not result then
			return false, removed, msg
		end

		removed = removed + 1

		return true, removed
	end

	return false, 0, "invalid path ("..path..")"
end



function fs.is_sub_of (parent, sub)
	if parent:sub (-1, -1) == "/" then
		parent = parent:sub (1, -2)
	end

	if sub:sub (-1, -1) == "/" then
		sub = sub:sub (1, -2)
	end

	while sub:len () > 0 and sub ~= "/" do
		if sub == parent then
			return true
		end

		sub = fs.path_folder (sub)
	end

	return false
end



local function copy_dir (srcpath, destpath, recurse)
	local copied = 0
	local list = fs.ls (srcpath)

	if not list then
		return false, 0, "read error"
	end

	for i = 1, #list do
		local srcfull = srcpath.."/"..list[i]
		local destfull = destpath.."/"..list[i]

		if fs.file_type (srcfull) == "file" then
			local result, msg = fs.copy_file (srcfull, destfull)

			if not result then
				return false, copied, msg
			end

			copied = copied + 1

		elseif fs.file_type (srcfull) == "dir" then
			if not fs.mkdir (destfull) then
				return false, copied, "dir error"
			end

			copied = copied + 1

			if recurse then
				local result, count, msg = copy_dir (srcfull, destfull, true)

				copied = copied + count

				if not result then
					return alse, copied, msg
				end
			end
		end
	end

	return true, copied
end



function fs.cp (srcpath, destpath, recurse)
	srcpath = tostring (srcpath or "")
	destpath = tostring (destpath or "")

	if srcpath:sub (-1) == "/" then
		return false, 0, "invalid path ("..srcpath..")"
	end

	if destpath:sub (-1) == "/" then
		destpath = destpath:sub (1, -2)
	end

	if srcpath == destpath then
		return false, 0, "invalid paths"
	end

	-- cant copy parent folder to sub folder - recursive
	if fs.is_sub_of (srcpath, destpath) and fs.file_type (srcpath) == "dir" then
		return false, 0, "invalid paths"
	end

	-- cant copy to parent folder of same name - deletes source
	if fs.is_sub_of (destpath, srcpath) then
		return false, 0, "invalid paths"
	end

	if fs.file_type (srcpath) == "file" then
		if fs.file_type (destpath) == "dir" then
			destpath = destpath.."/"..fs.path_name (srcpath)
		end

		local result, msg = fs.copy_file (srcpath, destpath)

		if not result then
			return false, 0, msg
		end

		return true, 1
	end

	if fs.file_type (srcpath) == "dir" then
		if not fs.mkdir (destpath) then
			return false, 0, "dir error ("..destpath..")"
		end

		local result, copied, msg = copy_dir (srcpath, destpath, recurse)

		copied = copied + 1

		if not result then
			return false, copied, msg
		end

		return true, copied
	end

	return false, 0, "invalid path ("..srcpath..")"
end



function win.syslog (entry)
   local file = io.open ("/win.log", (fs.file_exists ("/win.log") and "a") or "w")

   if file then
      file:write (entry.."\n\n")
      file:close ()
   end
end



function win.parse_cmdline (...)
   local line = table.concat ({...}, " ")
   local args = { }
   local quoted = false

   for match in (line.."\""):gmatch ("(.-)\"") do
      if quoted then
         args[#args + 1] = match
      else
         for arg in match:gmatch ("[^ \t]+") do
            args[#args + 1] = arg
         end
      end

      quoted = not quoted
   end

   return args
end



-- https://stackoverflow.com/questions/9540732/loadfile-without-polluting-global-environment
function win.load_api (path, perm)
   local name = fs.path_title (path)
   local refCount = perm and -1 or 1
	local result, fxn, msg
	local api = { }

	setmetatable (api, { __index = _G })

   if not perm and _G[name] and _G[name].__api_refCount then
      refCount = _G[name].__api_refCount

      if refCount >= 0 then
         refCount = refCount + 1
      end
   end

	fxn, msg = loadfile (path)

	if not fxn then
		return false, msg
	end

	setfenv (fxn, api)

	result, msg = pcall (fxn)

	if not result then
		return false, msg
	end

	api.__api_refCount = refCount

	_G[name] = api

   return true
end



function win.unload_api (path)
   local name = fs.path_title (path)

   if _G[name] and _G[name].__api_refCount then
      if _G[name].__api_refCount < 0 then

         return
      elseif _G[name].__api_refCount > 1 then
         _G[name].__api_refCount = _G[name].__api_refCount - 1

         return
      end
   end

   _G[name] = nil
end



function win.wnd_to_screen (wnd, x, y)
   local _wnd = wnd
   local rx = x
   local ry = y

   while _wnd do
      rx = rx + _wnd.x
      ry = ry + _wnd.y
      _wnd = _wnd.wnd__parent
   end

   return rx, ry
end



function win.screen_to_wnd (wnd, x, y)
   local _wnd = wnd
   local rx = x
   local ry = y

   while _wnd do
      rx = rx - _wnd.x
      ry = ry - _wnd.y
      _wnd = _wnd.wnd__parent
   end

   return rx, ry
end



function win.get_printers ()
	local file = io.open ("/win/devices/printers", "r")
	local printers = { }

	if file then
		local channel = file:read ("*l")

		while channel do
			if channel:trim ():len () > 0 then
				printers[#printers + 1] = channel
			end

			channel = file:read ("*l")
		end

		file:close ()
	end

	return printers
end



function win.create_app_frame ()
	local app_name = fs.path_title (private.workspace.ws__app_path)
	private.workspace.ws__app_frame = win.applicationFrame:new (private.workspace.ws__app_dir)

	if not private.workspace.ws__app_frame then
		error ("Failed to create main frame in "..app_name, 0)
	end

	private.workspace.ws__app_frame:set_text (appName)

	private.workspace.ws__app_frame.appFrame__app_thread = private.workspace.ws__app_thread
	private.workspace.ws__app_frame.appFrame__app_path = private.workspace.ws__app_path
	private.workspace.ws__app_thread = nil
	private.workspace.ws__app_dir = nil
	private.workspace.ws__app_path = nil

	return private.workspace.ws__app_frame
end



function win.start ()
	if not private.workspace then
		private.workspace = private.workSpace:new ()
	end

	if private.workspace then
		private.workspace:startup ()
		private.workspace:run ()
	end

	term.set_colors (term.colors.red, term.colors.black)
	print ("\nSystem halted")
end












































--
