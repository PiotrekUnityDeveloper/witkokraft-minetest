local private = ...



private.appListFrame = win.applicationFrame:base ()



function private.appListFrame:constructor (dir)
   if not win.applicationFrame.constructor (self, dir) then
      return nil
   end

   local rt = self:get_desktop ():get_work_area ()
   self.wnd__id = private.ID_APPFRAME
   self.wnd__frame_class = private.FRAME_CLASS_SYSTEM
   self:set_color (self:get_colors ().home_text)
   self:set_bg_color (self:get_colors ().home_back)
	self:set_text ("app list")

   self.title = win.labelWindow:new (self, 0, math.floor((rt.width - 4) / 2), 1, "List")
   self.title:set_color (self:get_colors ().home_text)
   self.title:set_bg_color (self:get_colors ().home_back)

   self.list = win.listWindow:new (self, private.ID_APPLIST, 2, 3, rt.width - 4, rt.height - 4)
   self.list:set_colors (self:get_colors ().home_item_text,
								 self:get_colors ().home_item_back,
								 self:get_colors ().home_item_back,
								 self:get_colors ().home_item_selected_text,
								 self:get_colors ().home_item_selected_back)
   self.pFrame__focused_wnd = self.list

   return self
end



function private.appListFrame:load_list ()
   self.list:reset_content ()

   local iterator, app = self:get_desktop ():enum_apps ()
   while app do
      self.list:add_string (app:get_text (), app)
      iterator, app = self:get_desktop ():enum_apps (iterator)
   end

   if self.list:count() > 0 then
      self.list:set_cur_sel (1)
   end
end



function private.appListFrame:on_resize ()
   local rt = self:get_desktop ():get_work_area ()

   self:move (rt:unpack ())
   self.title:move (math.floor((rt.width - 4) / 2))
   self.list:move (2, 3, rt.width - 4, rt.height - 4)

   return true
end



function private.appListFrame:on_event (event, p1, p2, p3, p4, p5, ...)
   if event == "list_click" then
      if p1:get_id () == private.ID_APPLIST then
         local app = self.list:get_data ()

         if app then
            app:set_active_top_frame ()
         end

         return true
      end
   end

   return false
end



function private.appListFrame:on_quit ()
   return true
end



function private.appListFrame:on_frame_activate (active)
   if active then
      self:load_list ()
   end
end
