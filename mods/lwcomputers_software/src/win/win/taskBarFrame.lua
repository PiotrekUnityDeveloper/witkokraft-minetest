local private = ...


--[[
local function formated_time ()
	local str = os.date ("%I:%M %p")

	if str:len () < 8 then
		str = " "..str
	end

	return str
end
]]


private.taskBarFrame = win.applicationFrame:base ()



function private.taskBarFrame:constructor (dir)
   if not win.applicationFrame.constructor (self, dir) then
      return nil
   end

   local width, height = self:get_desktop ().gdi:get_size ()

   self.wnd__id = private.ID_TASKBAR
   self.wnd__frame_class = private.FRAME_CLASS_SYSTEM
   self:set_want_focus (false)
   self:set_bg_color (self:get_colors ().task_back)
	self:set_text ("taskbar")
   self:move (0, height - 1, width, 1, win.WND_TOP)

   return self
end



function private.taskBarFrame:draw (gdi, bounds)
   local min_width = (self:comm_enabled () and 13) or 10
   local bar_text

   if self.width > min_width then
      bar_text = string.format ("[H] [L]%s%s[T]",
                                string.rep(" ", self.width - min_width),
                                (self:comm_enabled() and " @ ") or "")
   else
      bar_text = string.format ("[H] [L]%s[T]",
                                (self:comm_enabled() and " @ ") or "")
   end

   gdi:set_colors (self:get_colors ().task_text, self:get_colors ().task_back)
   gdi:write (bar_text, 0, 0)
end


--[[
function private.taskBarFrame:draw (gdi, bounds)
   local min_width = (self:comm_enabled () and 18) or 15
   local bar_text

   if self.width > min_width then
      bar_text = string.format ("[H] [L]%s%s%s",
                                string.rep(" ", self.width - min_width),
                                (self:comm_enabled() and " @ ") or "",
                                formated_time ())
   else
      bar_text = string.format ("[H] [L]%s%s",
                                (self:comm_enabled() and " @ ") or "",
                                formated_time ())
   end

   gdi:set_colors (self:get_colors ().task_text, self:get_colors ().task_back)
   gdi:write (bar_text, 0, 0)
end
]]


function private.taskBarFrame:on_left_click (x, y, count)
   if x >= 0 and x < 3 then
      self:get_desktop ():show_home_page ()
   elseif x >= 4 and x < 7 then
      self:get_desktop ():show_list_page ()
   elseif self.width > ((self:comm_enabled () and 13) or 10) and x >= (self.width - 3) then
      self:get_desktop ():msgbox ("Today", os.date ("%a %d %b %Y\n  %I:%M:%S %p"))
   end

   return true
end


--[[
function private.taskBarFrame:on_left_click (x, y, count)
   if x >= 0 and x < 3 then
      self:get_desktop ():show_home_page ()
   elseif x >= 4 and x < 7 then
      self:get_desktop ():show_list_page ()
   elseif self.width > ((self:comm_enabled () and 18) or 15) and x >= (self.width - 8) then
      self:get_desktop ():msgbox ("Today", os.date ("%a %d %b %Y\n  %I:%M:%S %p"))
   end

   return true
end
]]


function private.taskBarFrame:on_touch (x, y)
   if x >= 0 and x < 3 then
      self:get_desktop ():show_home_page ()
   elseif x >= 4 and x < 7 then
      self:get_desktop ():show_list_page ()
   elseif self.width > ((self:comm_enabled () and 13) or 10) and x >= (self.width - 3) then
      self:get_desktop ():msgbox ("Today", os.date ("%a %d %b %Y\n  %I:%M:%S %p"))
   end

   return true
end


--[[
function private.taskBarFrame:on_touch (x, y)
   if x >= 0 and x < 3 then
      self:get_desktop ():show_home_page ()
   elseif x >= 4 and x < 7 then
      self:get_desktop ():show_list_page ()
   elseif self.width > ((self:comm_enabled () and 18) or 15) and x >= (self.width - 8) then
      self:get_desktop ():msgbox ("Today", os.date ("%a %d %b %Y\n  %I:%M:%S %p"))
   end

   return true
end
]]


function private.taskBarFrame:on_resize()
   local width, height = self:get_desktop ().gdi:get_size ()
   self:move (0, height - 1, width, 1)

   return true
end


--[[
function private.taskBarFrame:on_idle (idle_count)
   if self:get_desktop ():get_taskbar_index () == 1 and self:is_shown () then
      if self.width > ((self:comm_enabled () and 17) or 14) then
         local gdi = self:get_GDI ()
         gdi:set_colors (self:get_colors ().task_text, self:get_colors ().task_back)
         gdi:write (formated_time (), (self.width - 8), 0)
         self:release_GDI ()
      end
   end

   return false
end
]]


function private.taskBarFrame:on_quit ()
   return true
end
