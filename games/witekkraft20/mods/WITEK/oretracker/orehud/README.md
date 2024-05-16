# Ore Tracker > Ore hud

Displays ore position by using the HUD.

## About this mod

This mod provides a graphical HUD interface which displays a series of ores.

Simply use `/orehud` to enable or disable displaying the ores on your HUD.

## The ores

| Ore name | Text Shown | Color code (HEX) |
|----------|------------|------------------|
| Coal     | Coa        | 0xc8c8c8         |
| Iron     | Iro        | 0xaf644b         |
| Gold     | Gol        | 0xc8c84b         |
| Mese\*   | Mes        | 0xffff4b         |
| Diamond  | Dia        | 0x4bfafa         |
| Quartz\*\*| Qua       | 0xc8c8c8         |
| Copper\*\*\*| Cop     | 0xc86400         |
| Tin\*    | Tin        | 0xc8c8c8         |
| Ancient Debris\*\*| Deb | 0xaa644b       |
| Lapis | Lap | 0x4b4bc8 |
| Redstone\*\* | Red | 0xc81919 |
| Glowstone\*\* | Glo | 0xffff4b |

\* Only found in MTG.

\*\* Found in MCL5 or MCL2 with the proper mods.

\*\*\* Found in MTG and MCL5 or MCL2 with the proper mods.

## Settings

### Detect Range

The number of blocks away from the player the mod will scan/display for ores.

> Recommended 8 blocks with no more than 16 (Bigger numbers equals much higher loads on server and possibly client)

### Scan Frequency

The time in seconds till the mod updates ores it is indicating and if any new ores enter the scaning area (Dictated by Detect Range)

> Recommended no faster than 1 (for 1 second) (Lower numbers equals faster scans but can/will increase loads on server and possibly client)

> Use 0 or negative number to indicate instantanious (no delay) scans. (Not recommended)
