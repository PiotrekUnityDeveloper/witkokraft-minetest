
oreveins = {}
oreveins._internal = {}

oreveins.S = minetest.get_translator("oreveins")
oreveins.MODPATH = minetest.get_modpath("oreveins")

dofile(oreveins.MODPATH.."/settings.lua")
dofile(oreveins.MODPATH.."/tool_belt.lua")

-- This attempts to detect the gamemode
if not minetest.registered_nodes["default:stone"] then
    if not minetest.registered_nodes["mcl_core:stone"] then
        oreveins.GAMEMODE = "N/A"
    else
        -- Attempt to determine if it's MCL5 or MCL2
        if not minetest.registered_nodes["mcl_deepslate:deepslate"] then
            oreveins.GAMEMODE = "MCL2"
        else
            oreveins.GAMEMODE = "MCL5"
        end
    end
else
    oreveins.GAMEMODE = "MTG"
end

oreveins.tools.log("Gamemode: "..oreveins.GAMEMODE)

-- Make temp area for ids and nodes it can place
oreveins._internal.oreos = {}
--[[ I.E.
    oreveins._internal.oreos["default_ores"] = {
        "nodes" = {
            "default:stone",
            "default:stone_with_coal",
            "default:stone_with_iron",
            "default:stone_with_copper",
            "default:stone_with_tin",
            "default:stone_with_gold",
            "default:stone_with_mese",
            "default:stone_with_diamond"
        },
        "size" = 16,
        "speed" = 10
    }
]]

-- If item_replicators is avalible do we block replicating oreveins?
oreveins.ir = nil
if minetest.get_modpath("item_replicators") ~= nil then
    local ir = rawget(_G, "item_replicators") or nil
    if ir then
        oreveins.ir = ir
    end
end

dofile(oreveins.MODPATH.."/api.lua")
dofile(oreveins.MODPATH.."/register.lua")

-- oreveins.register_orevein("id", {"nodes", "nodes"}, size, speed)

-- Now register the ores
if oreveins.GAMEMODE == "MTG" then
    oreveins.register_orevein("default:stone_with_coal", {"default:stone_with_coal"}, 1, 15)
    oreveins.register_orevein("default:stone_with_iron", {"default:stone_with_iron"}, 1, 20)
    oreveins.register_orevein("default:stone_with_copper", {"default:stone_with_copper"}, 1, 25)
    oreveins.register_orevein("default:stone_with_tin", {"default:stone_with_tin"}, 1, 30)
    oreveins.register_orevein("default:stone_with_gold", {"default:stone_with_gold"}, 1, 30)
    oreveins.register_orevein("default:stone_with_mese", {"default:stone_with_mese"}, 1, 45)
    oreveins.register_orevein("default:stone_with_diamond", {"default:stone_with_diamond"}, 1, 50)
    oreveins.register_orevein("orepack", {
            "default:stone_with_coal",
            "default:stone_with_iron",
            "default:stone_with_copper",
            "default:stone_with_tin",
            "default:stone_with_gold",
            "default:stone_with_mese",
            "default:stone_with_diamond"
        },
        2,
        15
    )
    if minetest.get_modpath("technic") ~= nil then
        oreveins.register_orevein("technic:mineral_zinc", {"technic:mineral_zinc"}, 1, 45)
        oreveins.register_orevein("technic:mineral_lead", {"technic:mineral_lead"}, 1, 45)
        oreveins.register_orevein("technic:mineral_chromium", {"technic:mineral_chromium"}, 1, 50)
        oreveins.register_orevein("technic:mineral_uranium", {"technic:mineral_uranium"}, 1, 70)
        dofile(oreveins.MODPATH.."/safety.lua")
        oreveins.register_orevein("technic:mineral_sulfur", {"technic:mineral_sulfur"}, 1, 55)
        oreveins.register_orevein("orepack", {
                "default:stone_with_coal",
                "default:stone_with_iron",
                "default:stone_with_copper",
                "default:stone_with_tin",
                "default:stone_with_gold",
                "default:stone_with_mese",
                "default:stone_with_diamond",
                "technic:mineral_zinc",
                "technic:mineral_lead",
                "technic:mineral_chromium",
                "technic:mineral_uranium",
                "technic:mineral_sulfur"
            },
            2,
            15
        )
    end
    if minetest.get_modpath("moreores") ~= nil then
        oreveins.register_orevein("moreores:mineral_silver", {"moreores:mineral_silver"}, 1, 45)
        oreveins.register_orevein("moreores:mineral_mithril", {"moreores:mineral_mithril"}, 1, 55)
        oreveins.register_orevein("moreores:mineral_tin", {"moreores:mineral_tin"}, 1, 45)
        if minetest.get_modpath("technic") ~= nil then
            oreveins.register_orevein("orepack", {
                    "default:stone_with_coal",
                    "default:stone_with_iron",
                    "default:stone_with_copper",
                    "default:stone_with_tin",
                    "default:stone_with_gold",
                    "default:stone_with_mese",
                    "default:stone_with_diamond",
                    "technic:mineral_zinc",
                    "technic:mineral_lead",
                    "technic:mineral_chromium",
                    "technic:mineral_uranium",
                    "technic:mineral_sulfur",
                    "moreores:mineral_silver",
                    "moreores:mineral_mithril",
                    "moreores:mineral_tin"
                },
                2,
                15
            )
        else
            oreveins.register_orevein("orepack", {
                    "default:stone_with_coal",
                    "default:stone_with_iron",
                    "default:stone_with_copper",
                    "default:stone_with_tin",
                    "default:stone_with_gold",
                    "default:stone_with_mese",
                    "default:stone_with_diamond",
                    "moreores:mineral_silver",
                    "moreores:mineral_mithril",
                    "moreores:mineral_tin"
                },
                2,
                15
            )
        end
    end
elseif oreveins.GAMEMODE == "MCL5" or oreveins.GAMEMODE == "MCL2" then
    oreveins.register_orevein("mcl_core:stone_with_coal", {"mcl_core:stone_with_coal"}, 1, 15)
    oreveins.register_orevein("mcl_core:stone_with_iron", {"mcl_core:stone_with_iron"}, 1, 20) -- In MCL2 iron ore drops itself, thus in MCL2 the orevein is actually quite cheap
    oreveins.register_orevein("mcl_core:stone_with_gold", {"mcl_core:stone_with_gold"}, 1, 25) -- In MCL2 gold ore drops itself, thus in MCL2 the orevein is actually quite cheap
    oreveins.register_orevein("mcl_core:stone_with_lapis", {"mcl_core:stone_with_lapis"}, 1, 35)
    oreveins.register_orevein("mcl_core:stone_with_redstone", {"mcl_core:stone_with_redstone"}, 1, 35)
    oreveins.register_orevein("mcl_core:stone_with_diamond", {"mcl_core:stone_with_diamond"}, 1, 60)
    oreveins.register_orevein("mcl_core:stone_with_emerald", {"mcl_core:stone_with_emerald"}, 1, 60)
    if minetest.get_modpath("mcl_copper") ~= nil then
        oreveins.register_orevein("mcl_copper:stone_with_copper", {"mcl_copper:stone_with_copper"}, 1, 30)
        oreveins.register_orevein("orepack", {
                "mcl_core:stone_with_coal",
                "mcl_core:stone_with_iron",
                "mcl_core:stone_with_gold",
                "mcl_core:stone_with_lapis",
                "mcl_core:stone_with_redstone",
                "mcl_core:stone_with_diamond",
                "mcl_core:stone_with_emerald",
                "mcl_copper:stone_with_copper",
            },
            2,
            15
        )
    else
        oreveins.register_orevein("orepack", {
                "mcl_core:stone_with_coal",
                "mcl_core:stone_with_iron",
                "mcl_core:stone_with_gold",
                "mcl_core:stone_with_lapis",
                "mcl_core:stone_with_redstone",
                "mcl_core:stone_with_diamond",
                "mcl_core:stone_with_emerald",
            },
            2,
            15
        )
    end
end

oreveins.tools.log("Making Veins...")
oreveins.make_veins()
