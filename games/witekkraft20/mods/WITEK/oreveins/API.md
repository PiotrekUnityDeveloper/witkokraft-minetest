# oreveins > API

## register_orevein

Given itemstring of a node, also given maxtime (every x seconds when it places a node of itemstring kind)

```lua
-- I.E.
local ov = rawget(_G, "oreveins") or nil
if ov then
    ov.register_orevein("default:stone_with_coal", 15)
    -- Make a Ore vein which produces stone_with_coal (so a Coal Vein essentially) which places a node every 15 seconds
end
```
