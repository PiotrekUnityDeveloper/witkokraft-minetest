
minetest.register_tool('mcl_multitool:multi_tool', {
	description = 'multi tool',
	inventory_image = 'default_tool_multitool.png',
	wield_scale = {x=1.3,y=1.4,z=2.0},
	
	tool_capabilities = {
		full_punch_interval = 0.8,
		groups = { tool=1, pickaxe=1, dig_speed_class=20},
			 { tool=1, shovel=1, dig_speed_class=20},
			 { tool=1, axe=1, dig_speed_class=20 },
			 { weapon=1, sword=1, dig_speed_class=32 },
		


-- DAMAGE
	   
			damage_groups = {fleshy=12},
		},

-- SOUND TOOLS
	sound = {breaks = "default_tool_breaks"},

-- MCL DIG GROUPS AND WIELD
	_repair_material = "mcl_core:diamond",
	_mcl_toollike_wield = true,
	_mcl_diggroups = {
		   
		   pickaxey = { speed =20, level = 7, uses = 6248 },
		   shovely = { speed = 20, level = 7, uses = 6248 },
		   axey = { speed = 20, level = 7, uses = 6248 },
		  swordy = { speed = 32, level = 7, uses = 6248 },
		  swordy_cobweb = { speed = 32, level = 7, uses = 6248 }
		  	
		-- pickaxey = { speed = 8, level = 5, uses = 1562 }
	},
})


-- CRAFT

minetest.register_craft({
	output = "mcl_multitool:multi_tool",
	recipe = {
		{"mcl_tools:axe_diamond", "mcl_tools:sword_diamond", "mcl_tools:pick_diamond"},
		{"", "mcl_tools:shovel_diamond", ""},
		{"", "mcl_core:gold_ingot", ""},
	}
})

