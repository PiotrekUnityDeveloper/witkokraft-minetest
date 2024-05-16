# X Maps

This mod adds map items that show terrain in HUD.

The HUD shows a player position & direction marker.

Treasure maps are like normal maps that show a red X.

Maps can be placed in the world on the sides of nodes.

## In Minetest Game

A right click with a mapping kit creates a map of the area.

If you target a node, its position shows as a red X on a map.

With the X players can share coordinates or have treasure hunts.

## X Maps API

You can use `xmaps.create_map_item()` to create a treasure map:

```
local itemstack = xmaps.create_map_item(pos, { draw_x = true })
```

## Notes

`xmaps` is similar to `mcl_maps`, which is part of MineClone2.

All map items and placed maps have a TGA file in the metadata.

This enables items and placed maps to work in world downloads.

## TODO

* Align mapped area with mapblocks (for better performance)
* Add support for mods with nodes that can show bitmaps
* Make it possible to wield map item in player hand
* Add more icons to represent the terrain better
* Make maps update while player is moving
* Make it possible to combine maps
