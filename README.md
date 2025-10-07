# AutoLFM
Automated LFM (Looking For More) message broadcaster for WoW 1.12.1 Vanilla.

## Installation
- Use `Add new addon` on TurtleWoW launcher: `https://github.com/FSuhas/AutoLFM`

Or

1. Clone or download this repository
2. Place the `AutoLFM` folder in `World of Warcraft\Interface\AddOns\`
3. Launch the game and enable the addon

## Usage
- `/lfm` - Open AutoLFM window
- `/lfm help` - Show all commands
- Click minimap button to toggle interface
- Select dungeons/raids, or custom message, (roles,) channels → click Start

## Architecture
```
AutoLFM/
├── Core/           # Constants, state, persistence
├── Utils/          # String, table, group utilities
├── Logic/          # Business logic (dungeons, raids, roles, channels, messages, broadcast)
├── API/            # Public API & slash commands
├── UI/             # Interface components, lists, panels
├── Misc/           # Optional modules
└── Init.lua        # Initialization orchestrator
```

## Features
- **Dungeons & Raids**: Auto-detect player level, priority coloring
- **Dynamic Messages**: "LF3M for RFC & WC Need Tank Heal"
- **Multi-Channel Broadcast**: WORLD, LookingForGroup, etc.
- **Smart Size Management**: Dungeon (5) / Raid (10-40)
- **Auto-Stop**: When group is full
- **API**: External addons can access AutoLFM data

## API Example
```lua
-- External addon integration
AutoLFM_API.RegisterCallback("MyAddon", function(status, eventType)
  local groupType = status.groupType  -- "dungeon", "raid", "other"
  local message = status.dynamicMessage.combined
  -- Do something with AutoLFM data
end)
```