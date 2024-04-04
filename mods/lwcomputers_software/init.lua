local version = "0.1.0"



do
	local v = { }

	for n in string.gmatch (lwcomputers.version () or "", "%d+") do
		v[#v + 1] = tonumber (n) or 0
	end

	if not (v[1] >= 0 and v[2] >= 2 and v[3] >= 9) then
		minetest.log ("error", "lwcomputers_software requires lwcomputers version 0.2.9 or above")

		return
	end
end



lwcomputers_software = { }



function lwcomputers_software.version ()
	return version
end



local S = function (s) return s end

if minetest.get_translator and minetest.get_translator ("lwcomputers_software") then
	S = minetest.get_translator ("lwcomputers_software")
elseif minetest.global_exists ("intllib") then
   if intllib.make_gettext_pair then
      S = intllib.make_gettext_pair ()
   else
      S = intllib.Getter ()
   end
end



local modpath = minetest.get_modpath ("lwcomputers_software")



local function on_use (itemstack, user, pointed_thing)
	if itemstack and user and user:is_player () then
		local meta = itemstack:get_meta()

		if meta then
			local id = meta:get_int ("lwcomputer_id")
			local label = meta:get_string ("label")
			local sid = "ID:<not used>"

			if id > 0 then
				sid = "ID:"..tostring (id)
			end

			if label == "" then
				label = "Label:<no label>"
			else
				label = "Label:"..label
			end

			local formspec =
			"formspec_version[3]\n"..
			"size[6.0,4.0]\n"..
			"label[2.25,0.8;"..minetest.formspec_escape (sid).."]\n"..
			"label[2.0,1.8;"..minetest.formspec_escape (label).."]\n"..
			"button_exit[2.0,2.5;2.0,1.0;close;Close]"

			minetest.show_formspec (user:get_player_name (), "lwcomputers_software:floppy", formspec)
		end
	end

	return nil
end



lwcomputers.register_floppy_disk ("lwcomputers_software:floppy_win", "WIN", {
   description = S("WIN Installer"),
   short_description = S("WIN Installer"),
   inventory_image = "lwcomputers_software_floppy_win.png",
   on_use = on_use,
	groups = { floppy_disk = 1 },
	diskfiles = {
		{ source = modpath.."/res/win/boot", target = "/boot" },
		{ source = modpath.."/res/win/files/boot", target = "/files/boot" },
		{ source = modpath.."/res/win/files/license.txt", target = "/files/license.txt" },
		{ source = modpath.."/res/win/files/startup.cmd", target = "/files/startup.cmd" },
		{ source = modpath.."/res/win/files/win.ini", target = "/files/win.ini" },
		{ source = modpath.."/res/win/files/win/applicationFrame.lua", target = "/files/win/applicationFrame.lua" },
		{ source = modpath.."/res/win/files/win/appListFrame.lua", target = "/files/win/appListFrame.lua" },
		{ source = modpath.."/res/win/files/win/buttonWindow.lua", target = "/files/win/buttonWindow.lua" },
		{ source = modpath.."/res/win/files/win/checkWindow.lua", target = "/files/win/checkWindow.lua" },
		{ source = modpath.."/res/win/files/win/__classBase.lua", target = "/files/win/__classBase.lua" },
		{ source = modpath.."/res/win/files/win/closeButtonWindow.lua", target = "/files/win/closeButtonWindow.lua" },
		{ source = modpath.."/res/win/files/win/cmndlg.lua", target = "/files/win/cmndlg.lua" },
		{ source = modpath.."/res/win/files/win/comm.lua", target = "/files/win/comm.lua" },
		{ source = modpath.."/res/win/files/win/defs.lua", target = "/files/win/defs.lua" },
		{ source = modpath.."/res/win/files/win/desktopTheme.lua", target = "/files/win/desktopTheme.lua" },
		{ source = modpath.."/res/win/files/win/desktopWindow.lua", target = "/files/win/desktopWindow.lua" },
		{ source = modpath.."/res/win/files/win/editWindow.lua", target = "/files/win/editWindow.lua" },
		{ source = modpath.."/res/win/files/win/GDI.lua", target = "/files/win/GDI.lua" },
		{ source = modpath.."/res/win/files/win/globals.lua", target = "/files/win/globals.lua" },
		{ source = modpath.."/res/win/files/win/homePageFrame.lua", target = "/files/win/homePageFrame.lua" },
		{ source = modpath.."/res/win/files/win/inputWindow.lua", target = "/files/win/inputWindow.lua" },
		{ source = modpath.."/res/win/files/win/keyboardFrame.lua", target = "/files/win/keyboardFrame.lua" },
		{ source = modpath.."/res/win/files/win/labelWindow.lua", target = "/files/win/labelWindow.lua" },
		{ source = modpath.."/res/win/files/win/listWindow.lua", target = "/files/win/listWindow.lua" },
		{ source = modpath.."/res/win/files/win/lockScrnFrame.lua", target = "/files/win/lockScrnFrame.lua" },
		{ source = modpath.."/res/win/files/win/menuWindow.lua", target = "/files/win/menuWindow.lua" },
		{ source = modpath.."/res/win/files/win/msgBoxFrame.lua", target = "/files/win/msgBoxFrame.lua" },
		{ source = modpath.."/res/win/files/win/parentFrame.lua", target = "/files/win/parentFrame.lua" },
		{ source = modpath.."/res/win/files/win/popupFrame.lua", target = "/files/win/popupFrame.lua" },
		{ source = modpath.."/res/win/files/win/private.lua", target = "/files/win/private.lua" },
		{ source = modpath.."/res/win/files/win/rect.lua", target = "/files/win/rect.lua" },
		{ source = modpath.."/res/win/files/win/sysMsgBoxFrame.lua", target = "/files/win/sysMsgBoxFrame.lua" },
		{ source = modpath.."/res/win/files/win/taskBarFrame.lua", target = "/files/win/taskBarFrame.lua" },
		{ source = modpath.."/res/win/files/win/textWindow.lua", target = "/files/win/textWindow.lua" },
		{ source = modpath.."/res/win/files/win/win", target = "/files/win/win" },
		{ source = modpath.."/res/win/files/win/window.lua", target = "/files/win/window.lua" },
		{ source = modpath.."/res/win/files/win/workSpace.lua", target = "/files/win/workSpace.lua" },
		{ source = modpath.."/res/win/files/win/devices/desktops.lua", target = "/files/win/devices/desktops.lua" },
		{ source = modpath.."/res/win/files/win/devices/printers", target = "/files/win/devices/printers" },
		{ source = modpath.."/res/win/files/win/devices/term/desktop.ini", target = "/files/win/devices/term/desktop.ini" },
		{ source = modpath.."/res/win/files/win/devices/term/startup.ini", target = "/files/win/devices/term/startup.ini" },
		{ source = modpath.."/res/win/files/progs/lua", target = "/files/progs/lua" },
		{ source = modpath.."/res/win/files/apps/browse", target = "/files/apps/browse" },
		{ source = modpath.."/res/win/files/apps/browse.ini", target = "/files/apps/browse.ini" },
		{ source = modpath.."/res/win/files/apps/chat", target = "/files/apps/chat" },
		{ source = modpath.."/res/win/files/apps/cmd", target = "/files/apps/cmd" },
		{ source = modpath.."/res/win/files/apps/cmd_los", target = "/files/apps/cmd_los" },
		{ source = modpath.."/res/win/files/apps/email", target = "/files/apps/email" },
		{ source = modpath.."/res/win/files/apps/email.ini", target = "/files/apps/email.ini" },
		{ source = modpath.."/res/win/files/apps/emread", target = "/files/apps/emread" },
		{ source = modpath.."/res/win/files/apps/emwrite", target = "/files/apps/emwrite" },
		{ source = modpath.."/res/win/files/apps/fexplore", target = "/files/apps/fexplore" },
		{ source = modpath.."/res/win/files/apps/fexplore.asc", target = "/files/apps/fexplore.asc" },
		{ source = modpath.."/res/win/files/apps/manager", target = "/files/apps/manager" },
		{ source = modpath.."/res/win/files/apps/notepad", target = "/files/apps/notepad" },
		{ source = modpath.."/res/win/files/apps/notepad.ini", target = "/files/apps/notepad.ini" },
		{ source = modpath.."/res/win/files/apps/sadmin", target = "/files/apps/sadmin" },
		{ source = modpath.."/res/win/files/apps/sadmin.ini", target = "/files/apps/sadmin.ini" },
		{ source = modpath.."/res/win/files/apps/shutdown", target = "/files/apps/shutdown" },
		{ source = modpath.."/res/win/files/apis/html", target = "/files/apis/html" },
	}
})



lwcomputers.register_floppy_disk ("lwcomputers_software:floppy_server", "SERVER", {
   description = S("Server Installer"),
   short_description = S("Server Installer"),
   inventory_image = "lwcomputers_software_floppy_server.png",
   on_use = on_use,
	groups = { floppy_disk = 1 },
	diskfiles = {
		{ source = modpath.."/res/server/boot", target = "/boot" },
		{ source = modpath.."/res/server/boot_alone", target = "/boot_alone" },
		{ source = modpath.."/res/server/boot_system", target = "/boot_system" },
		{ source = modpath.."/res/server/license.txt", target = "/license.txt" },
		{ source = modpath.."/res/server/server", target = "/server" },
		{ source = modpath.."/res/server/server.cfg", target = "/server.cfg" },
	}
})



lwcomputers.register_floppy_disk ("lwcomputers_software:floppy_templates", "TEMPLATES", {
   description = S("App Templates"),
   short_description = S("App Templates"),
   inventory_image = "lwcomputers_software_floppy_templates.png",
   on_use = on_use,
	groups = { floppy_disk = 1 },
	diskfiles = {
		{ source = modpath.."/res/templates/license.txt", target = "/license.txt" },
		{ source = modpath.."/res/templates/menu", target = "/menu" },
		{ source = modpath.."/res/templates/minApp", target = "/minApp" },
		{ source = modpath.."/res/templates/popup", target = "/popup" },
		{ source = modpath.."/res/templates/single", target = "/single" },
		{ source = modpath.."/res/templates/starter", target = "/starter" },
	}
})



lwcomputers.register_floppy_disk ("lwcomputers_software:floppy_open", "OPEN", {
   description = S("Open Software"),
   short_description = S("Open Software"),
   inventory_image = "lwcomputers_software_floppy_open.png",
   on_use = on_use,
	groups = { floppy_disk = 1 },
	diskfiles = {
		{ source = modpath.."/res/open/boot", target = "/boot" },
		{ source = modpath.."/res/open/files/license.txt", target = "/files/license.txt" },
		{ source = modpath.."/res/open/files/public/advertise.html", target = "/files/public/advertise.html" },
		{ source = modpath.."/res/open/files/public/bank.html", target = "/files/public/bank.html" },
		{ source = modpath.."/res/open/files/public/banking.html", target = "/files/public/banking.html" },
		{ source = modpath.."/res/open/files/public/calculator.html", target = "/files/public/calculator.html" },
		{ source = modpath.."/res/open/files/public/codepad.html", target = "/files/public/codepad.html" },
		{ source = modpath.."/res/open/files/public/codewin.html", target = "/files/public/codewin.html" },
		{ source = modpath.."/res/open/files/public/index.html", target = "/files/public/index.html" },
		{ source = modpath.."/res/open/files/public/eshop.html", target = "/files/public/eshop.html" },
		{ source = modpath.."/res/open/files/public/estore.html", target = "/files/public/estore.html" },
		{ source = modpath.."/res/open/files/public/register.html", target = "/files/public/register.html" },
		{ source = modpath.."/res/open/files/public/downloads/advertise", target = "/files/public/downloads/advertise" },
		{ source = modpath.."/res/open/files/public/downloads/bank", target = "/files/public/downloads/bank" },
		{ source = modpath.."/res/open/files/public/downloads/bank.ini", target = "/files/public/downloads/bank.ini" },
		{ source = modpath.."/res/open/files/public/downloads/banking", target = "/files/public/downloads/banking" },
		{ source = modpath.."/res/open/files/public/downloads/banking.ini", target = "/files/public/downloads/banking.ini" },
		{ source = modpath.."/res/open/files/public/downloads/calculator", target = "/files/public/downloads/calculator" },
		{ source = modpath.."/res/open/files/public/downloads/codepad", target = "/files/public/downloads/codepad" },
		{ source = modpath.."/res/open/files/public/downloads/codepad.def", target = "/files/public/downloads/codepad.def" },
		{ source = modpath.."/res/open/files/public/downloads/codewin", target = "/files/public/downloads/codewin" },
		{ source = modpath.."/res/open/files/public/downloads/eshop", target = "/files/public/downloads/eshop" },
		{ source = modpath.."/res/open/files/public/downloads/eshop.ini", target = "/files/public/downloads/eshop.ini" },
		{ source = modpath.."/res/open/files/public/downloads/estore", target = "/files/public/downloads/estore" },
		{ source = modpath.."/res/open/files/public/downloads/estore.ini", target = "/files/public/downloads/estore.ini" },
		{ source = modpath.."/res/open/files/public/downloads/register", target = "/files/public/downloads/register" },
		{ source = modpath.."/res/open/files/public/downloads/register.dat", target = "/files/public/downloads/register.dat" },
		{ source = modpath.."/res/open/files/public/downloads/register.ini", target = "/files/public/downloads/register.ini" },
	}
})



minetest.register_craft ({
	output = "lwcomputers_software:floppy_win 1",
	recipe = {
		{ "lwcomputers:floppy_los", "default:book" },
		{ "default:book", "default:book" }
	}
})


minetest.register_craft ({
	output = "lwcomputers_software:floppy_server 1",
	recipe = {
		{ "lwcomputers:floppy_los", "default:book" },
		{ "default:book", "" }
	}
})


minetest.register_craft ({
	output = "lwcomputers_software:floppy_templates 1",
	recipe = {
		{ "lwcomputers:floppy_green", "default:paper" },
	}
})


minetest.register_craft ({
	output = "lwcomputers_software:floppy_open 1",
	recipe = {
		{ "lwcomputers:floppy_white", "default:paper" },
	}
})


--
