# Minetest Skygrid
Custom skygrid mapgen for Minetest.

As with all custom Lua mapgens, it overwrites the 'singlenode' mapgen. The node selection is based off the current world seed, but will change if mods containing nodes are enabled/disabled.

It generates a list of nodes from `minetest.registered_nodes`, so all mods and games should work with it, including its nodes into the list of potential nodes.