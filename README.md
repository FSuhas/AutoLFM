# AutoLFM - Automated LFM Broadcaster for WoW Vanilla 1.12 (TurtleWoW)

<p align="center">
  <img src="AutoLFM.png" alt="AutoLFM Interface" width="600"/>
</p>


## 📖 Description

**AutoLFM** is a powerful World of Warcraft 1.12 (Vanilla) addon that automates the process of broadcasting "Looking For More" (LFM) messages for dungeons, raids, quests and more. This addon helps group leaders efficiently recruit party members without manual spam.


## 🐢 Turtle WoW Specific
> **Note**: While this addon works on any WoW 1.12 client, it was specifically designed for Turtle WoW and includes content from that server (custom dungeons, raids, and features).

The interface design is inspired by and matches Turtle WoW's native LFG system:
- Color scheme matches Turtle WoW aesthetics
- Icon styling consistent with server UI elements
- Familiar user experience for Turtle WoW players


## ✨ Features

- 🎯 **Smart Content Selection**
  - Browse and select from all Vanilla and customs dungeons/raids
  - Add quest links directly from your quest log
  - Color-coded level filtering

- 🎭 **Role Management**
  - Tank, Healer, DPS role indicators
  - Visual role selector with icons
  - Automatic message formatting

- ⚙️ **Customizable Broadcasting**
  - Adjustable broadcast interval (30-120 seconds)
  - Multiple channel support (LookingForGroup, World, etc.)
  - Custom message additions
  - Live message preview

- 🎨 **Intuitive Interface**
  - Clean tabbed navigation (Dungeons/Raids/Quests/More)
  - Minimap button with draggable positioning
  - Eye-catching broadcast animation

- 📊 **Statistics Tracking**
  - Broadcast duration timer
  - Message count
  - Next message countdown


## 📥 Installation
Use Addon install system from TurtleWoW launcher.

Or, manually:
1. Download the latest release
2. Extract the `AutoLFM` folder to your `Interface\AddOns` directory
3. Restart WoW or reload UI (`/reload`)
4. Type `/lfm` to open the interface


## 🎮 Usage

### Quick Start

1. **Open the interface**: `/lfm` or click the minimap button
2. **Select content**: 
   - Navigate to Dungeons/Raids/Quests tabs
   - Check the content you want to recruit for
3. **Choose roles**: Click Tank/Healer/DPS icons (optional)
4. **Select channels**: Go to "More" tab, check desired channels
5. **Start broadcasting**: Click the "Start" button

### Commands

```bash
/lfm                    # Toggle main window
/lfm help               # Show all commands

# Minimap button
/lfm minimap show       # Show minimap button
/lfm minimap hide       # Hide minimap button
/lfm minimap reset      # Reset button position

# Misc modules
/lfm misc status        # Show module status
/lfm misc fps on/off    # Toggle FPS display
/lfm misc rested on/off # Toggle Rested XP monitor

# API (for developers)
/lfm api status         # Check API availability
/lfm api data           # Show current API data
```


## 🏗️ Architecture

```
AutoLFM/
├── Core/                        # Core systems
│   ├── Utils.lua                # Utilities, constants, colors, chat output
│   ├── Settings.lua             # SavedVariables management per character
│   ├── Events.lua               # WoW event handling (PARTY_MEMBERS_CHANGED, etc.)
│   └── Commands.lua             # Slash commands system (/lfm)
│
├── Logic/                       # Business logic
│   ├── Content.lua              # Dungeon/Raid/Quest databases and management
│   ├── Selection.lua            # Selection state (roles, channels, group)
│   ├── Broadcaster.lua          # Message building and broadcasting engine
│   └── API.lua                  # Public API for external addons
│
├── UI/                          # User interface
│   ├── Components/              # Reusable UI components
│   │   ├── MainWindow.lua       # Main frame, roles selector, preview
│   │   ├── TabNavigation.lua    # Tab system (Dungeons/Raids/Quests/More)
│   │   ├── MinimapButton.lua    # Draggable minimap button
│   │   ├── PanelBuilder.lua     # UI builder (panels, scrolls, checkboxes)
│   │   ├── IconAnimation.lua    # Eye animation during broadcast
│   │   └── LinkIntegration.lua  # Quest/Item links integration (Shift+Click)
│   ├── DungeonsPanel.lua        # Dungeon list with level filters
│   ├── RaidsPanel.lua           # Raid list with size controls
│   ├── QuestsPanel.lua          # Quest log integration panel
│   └── MorePanel.lua            # Settings (interval, channels, minimap, stats)
│
├── Misc/                        # Optional modules
│   ├── FPSDisplay.lua           # Toggle FPS display
│   ├── RestedXP.lua             # Rested XP monitor
│   ├── GuildSpam.lua            # Guild spam helper
│   └── EasterEgg.lua            # Fun hidden features
│
├── UI/Textures/                 # Visual assets
│   ├── Eyes/                    # Animation frames (eye01-16.blp)
│   ├── Icons/                   # UI icons (chat, quest, tool, etc.)
│   ├── mainFrame.blp            # Main window background
│   ├── preview.blp              # Message preview background
│   ├── roles*.blp               # Role selector graphics
│   └── tab*.blp                 # Tab button graphics
│
├── UI/Sounds/                   # Audio files
│   ├── LFG_RoleCheck.ogg        # Role check sound
│   ├── LFG_Denied.ogg           # Error sound
│   └── fumier.ogg               # Easter egg sound
│
├── Init.lua                     # Initialization and startup sequence
├── AutoLFM.toc                  # Addon manifest
├── Changelog.txt                # Versioning history
└── README.md                    # Documentation
```

## 🎨 Features Detail

### Dungeon Panel
- **Smart filtering** by level color (gray/green/yellow/orange/red)
- **Auto-sorting** by player level relevance
- **Multi-selection** (up to 4 dungeons)
- **Level ranges** displayed for each dungeon

### Raid Panel
- **Single selection** (one raid at a time)
- **Variable group sizes** for applicable raids
- **Dynamic slider** for 10-40 player raids
- **Fixed sizes** for specific content

### Quest Panel
- **Direct integration** with quest log
- **Shift+Click** to add quest links
- **Item links** from bags (Shift+Click)
- **Chat links** from chat frame (Shift+Click)

### More Panel
- **Interval control** with visual slider
- **Channel management** with checkboxes
- **Statistics display** (duration, sent, next)
- **Minimap controls** (show/hide/reset)
- **Custom message** editor

## 🔌 API (For Developers)

AutoLFM exposes a public API for integration with other addons:

```lua
-- Check API availability
if AutoLFM.API and AutoLFM.API.IsAvailable() then
    -- Get current state
    local data = AutoLFM.API.GetData()
    
    -- Access specific info
    local message = data.message          -- Current broadcast message
    local isActive = data.isActive        -- Broadcasting status
    local channels = data.channels        -- Selected channels
    local roles = data.roles              -- Selected roles
    local dungeons = data.dungeons        -- Selected dungeons
    local raids = data.raids              -- Selected raids
    
    -- Subscribe to changes
    AutoLFM.API.OnDataChange(function()
        -- Called when any data changes
    end)
end
```

## ⚙️ Configuration

Settings are automatically saved per character in `SavedVariables/AutoLFM.lua`.

Configuration includes:
- Broadcast interval
- Channel preferences
- Minimap button position
- Dungeon level filters
- Module states (FPS, Rested XP)

## 🐛 Known Issues & TODO

### Issues
- You tell me.

### UI Improvements
- [ ] Add "Clear All" button on main frame (next to close button)
- [ ] Fix preview message sizing (sometimes too large)
- [ ] Align all UI elements consistently
- [ ] Replace magic numbers with named constants

### Engine Improvements
- [ ] Integrate FuBar module support
- [ ] Rework on API


## 📝 Informations

- WoW Version: 1.12.1 (Interface 11200)
- Lua Version: 5.0
- External Libraries: None
- Original Author: Gondoleon

Contributions are welcome!