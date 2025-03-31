# AzerothCore - Dynamic Teleporter NPC & Item

A custom Lua script for AzerothCore that provides a **unified teleporter** via **NPC** and/or **Item**, complete with:

- Multiple menu categories
- Per-faction filtering (Alliance/Horde)
- Teleport cost with confirmation
- Item-based free teleportation
- Icon support in menus

---

## 💡 Features

- Supports both **NPC** and **item** interactions
- Multi-level menu system
- Gold cost with confirmation window
- Zero cost if teleported via item
- Full support for icon display in gossip menus
- Faction filtering (`Alliance`, `Horde`, `Both`)
- Easily expandable with custom destinations

---

## 🧱 Structure

The menu data is defined in a Lua table like this:

```lua
local T = {
  [1] = { "Menu Title", TeamRestriction,
    {"Display text", mapId, x, y, z, orientation, costInCopper},
  },
  [2] = { "Another Menu", TeamRestriction,
    {"Another location", mapId, x, y, z, o, cost},
  },
}


0 = Alliance only

1 = Horde only

2 = Both

### Author
- **Slavomir Strnad** - *Lead Developer* - [GitHub Profile](https://github.com/Rimovals2)

### Special Thanks
- Thanks to the AzerothCore community for their invaluable support and contributions to open-source development.