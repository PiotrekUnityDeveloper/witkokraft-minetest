-- https://rubenwardy.com/minetest_modding_book/en/map/timers.html#active-block-modifiers
-- An ABM seems slow, but this is a great feature for cleaning up those crashs

-- MTG
minetest.register_abm({
    nodenames = {"xray:mtg_stone"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "default:stone"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mtg_dstone"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "default:desert_stone"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mtg_sstone"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "default:sandstone"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mtg_dsstone"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "default:desert_sandstone"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mtg_ssstone"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "default:silver_sandstone"})
    end
})

-- MCL (2 and 5)
minetest.register_abm({
    nodenames = {"xray:mcl_stone"},
    interval = xray.scan_frequency / 2, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_core:stone"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mcl_granite"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_core:granite"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mcl_andesite"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_core:andesite"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mcl_diorite"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_core:diorite"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mcl_sstone"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_core:sandstone"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mcl_rsstone"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_core:redsandstone"})
    end
})

-- MCL (5 only)
minetest.register_abm({
    nodenames = {"xray:mcl_bstone"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_blackstone:blackstone"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mcl_basalt"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_blackstone:basalt"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mcl_netherrack"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_nether:netherrack"})
    end
})
minetest.register_abm({
    nodenames = {"xray:mcl_deepslate"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "mcl_deepslate:deepslate"})
    end
})

-- NC
minetest.register_abm({
    nodenames = {"xray:nc_stone"},
    interval = 1, -- Run every X seconds
    action = function(pos, node, active_object_count,
            active_object_count_wider)
        minetest.set_node(pos, {name = "nc_terrain:stone"})
    end
})