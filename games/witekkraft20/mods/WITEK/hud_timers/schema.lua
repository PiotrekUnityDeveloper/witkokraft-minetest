return {
	type = "table",
	entries = {
		hud_timers_max = {
			type = "number",
			range = {min = 0, max = 100},
			default = 10,
			description = "How many timers(maximum) may exist at a time."
		},
		hud_pos = {
			type = "table",
			children = {
				x = {type = "number"},
				y = {type = "number"}
			},
			default = {x = 0.1, y = 0.9},
			description = "Screen coordinates where the timer stack should start."
		},
		globalstep = {
			type = "number",
			range = { min = 0 },
			default = 0.1,
			description = "How often timers should be updated (interval duration in seconds)."
		},
		format = {
			type = "string",
			default = "%s: %s s",
			description = "The format for the timer label - first string is timer name, second one is seconds left."
		}
	}
}