local entity_stub = {
	on_activate = function(self)
		self.object:remove()
	end
}

minetest.register_entity(":mcl_itemframes:item_frame_item", entity_stub)
minetest.register_entity(":mcl_itemframes:item_frame_map", entity_stub)
minetest.register_entity(":mcl_itemframes:glow_item_frame_item", entity_stub)
minetest.register_entity(":mcl_itemframes:glow_item_frame_map", entity_stub)

minetest.register_alias("mcl_itemframes:item_frame", "mcl_itemframes:frame")
minetest.register_alias("mcl_itemframes:glow_item_frame", "mcl_itemframes:glow_frame")

minetest.register_lbm({
	label = "Convert old itemframes",
	name = ":mcl_itemframes:convert_old_itemframes",
	nodenames = { "mcl_itemframes:item_frame", "mcl_itemframes:glow_item_frame" },
	run_at_every_load = false,
	action = function(pos, node)
		--this check is to verify that the nodename is *actually* the old nodename not an alias since the LBM will trigger on both
		--this became necessary since the lbm was moved to this mod and adding the leading ":" to the name apparently makes it run again.
		local meta = minetest.get_meta(pos)
		if meta:get_string("mcl_itemframes:converted") ~= "" then
			return
		end
		node.name = node.name:gsub("item_","")
		node.param2 = minetest.dir_to_wallmounted(minetest.facedir_to_dir(node.param2))
		minetest.swap_node(pos, node)
		mcl_itemframes.remove_entity(pos)
		mcl_itemframes.update_entity(pos)
		meta:set_string("mcl_itemframes:converted", "yes")
	end
})
