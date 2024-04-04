local private = ...



win.desktopTheme = win.__classBase:base ()



function win.desktopTheme:constructor ()
   self.double_click = 0.5
   self.text_scale = 1.0
   self.keyboard_height = 5
   self.close_btn = "x"
   self.color =
   {
      desktop_back = term.colors.black,
      wnd_text = term.colors.black,
      wnd_back = term.colors.white,
      wnd_focus = term.colors.sky,
      frame_text = term.colors.black,
      frame_back = term.colors.silver,
      popup_text = term.colors.black,
      popup_back = term.colors.yellow,
      button_text = term.colors.black,
      button_back = term.colors.blue,
      button_focus = term.colors.cyan,
      input_text = term.colors.black,
      input_back = term.colors.white,
      input_focus = term.colors.sky,
      input_error = term.colors.pink,
      input_banner = term.colors.silver,
      selected_text = term.colors.white,
      selected_back = term.colors.blue,
      scroll_text = term.colors.silver,
      scroll_back = term.colors.gray,
      scroll_track = term.colors.silver,
      check_text = term.colors.green,
      check_back = term.colors.white,
      check_focus = term.colors.sky,
      task_text = term.colors.silver,
      task_back = term.colors.gray,
      home_text = term.colors.silver,
      home_back = term.colors.black,
      home_item_text = term.colors.blue,
      home_item_back = term.colors.black,
      home_item_selected_text = term.colors.sky,
      home_item_selected_back = term.colors.black,
      title_text = term.colors.white,
      title_back = term.colors.gray,
      close_text = term.colors.white,
      close_back = term.colors.red,
      close_focus = term.colors.purple,
      kb_text = term.colors.silver,
      kb_back = term.colors.black,
      kb_key = term.colors.black,
      kb_cmd = term.colors.blue,
      kb_cancel = term.colors.green,
      kb_toggle = term.colors.sky,
      menu_text = term.colors.black,
      menu_back = term.colors.sky,
      menu_selected_text = term.colors.white,
      menu_selected_back = term.colors.blue
   }

   return self
end


private.defaultTheme = win.desktopTheme:new ()
