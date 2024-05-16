# Ore Tracker > Xray

Hides stone and stone varients from view.

## About this mod

This mod provides graphical counterparts for stone and stone varients to appear invisible.

Simply use `/xray` to enable or disable displaying the stone or stone varients around you.

> If your server crashes while any of your players are using xray it may cause residual invisible nodes... simply enable the fix_mode and then wander around the area they were at. (make sure you disable fix_mode in production, as it can overwrite other player's xray zones)

## How it works

When you issue `/xray` and it becomes active, it checks a cube like area around you, if within this scan area it detects stone for example it then swaps it with it's own stone node (Which simply is a transparent node, but the counterpart was made so I could replace particular stone varients without causing the player to only get stone and nothing else). Reverse the process for reverting the invisible counterpart back to the visible node.

> Yes you can see other player's xray's since there isn't a way to hide nodes just for one client but show them for other clients.

## Settings

### Detect Range

The distance at which nodes will be swapped. (Higher numbers means more blocks swapped but might increase server/client loads)

> Recommended detect_range of 6. (No more than 16)

### Scan Frequency

The rate at which nodes will be checked and swapped. (Lower numbers means more "updates" making it smoother to move around and see the environment change, but might increase server/client loads)

> Recommended scan_frequency of 1. (Use 0 or negative numbers for instantanious "updates", This number is in seconds)

### Light Level

The level that xray nodes emit light. (0 is minimum and 14 is maximum, dictated by minetest)

> Recommended level 4. (This makes xray a dark dull but if you don't mind players never using torches you could make this higher)

