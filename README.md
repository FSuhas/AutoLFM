# AutoLFM - Automated LFM Broadcaster for WoW Vanilla 1.12 (TurtleWoW)

<p align="center">
  <img src="AutoLFM.png" alt="AutoLFM Illustration"/>
</p>

## 📜 Description

**AutoLFM** is a powerful World of Warcraft 1.12 (Vanilla) addon that automates the process of broadcasting "Looking For More" (LFM) messages for dungeons, raids, quests and more. This addon helps group leaders efficiently recruit party members without manual spam.

> **🐢 Turtle WoW Specific**  
 While this addon works on any WoW 1.12 client, it was specifically designed for Turtle WoW and includes content from that server (custom dungeons, raids, and features).  
The interface design is inspired by and matches Turtle WoW's native LFG system.

## ✨ Features

### 🎯 Content Selection

- Browse all Vanilla and Turtle WoW custom instances (dungeons and raids)
- Multi-selection dungeons support (up to 4) and variable group sizes for applicable raids (10-40 slider)
- Smart filtering by level color: auto-sorting by player level relevance with level ranges displayed
- Quest log integration: add quest/item/chat links via Shift+Click
- 5-tab navigation system with quick access via `/lfm` command or minimap button

### 📢 Broadcasting & Messages

- Adjustable broadcast interval (30-120s) with multiple channel support (LookingForGroup, World, etc.)
- Automatic start/stop based on group status with live message preview
- Role management: Tank/Healer/DPS visual selector with automatic message formatting
- Custom message editor: add personal text with smart message building from all selections
- Real-time statistics: duration timer, message count, next broadcast countdown

### 🎨 Interface & Controls

- Eye-catching broadcast animation with color indicators for selection status
- Draggable minimap button with position memory
- One-click clear all selections via Clear tab with smart detection
- Tooltip guidance throughout the interface

## 📥 Installation

Use Addon install system from TurtleWoW launcher.

Or, manually: download the latest release and extract the `AutoLFM` folder to your `Interface\AddOns` directory

## 🖱️ Usage

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
/lfm minimap            # Show minimap commands
/lfm misc               # Show misc commands
/lfm api                # Show api commands
```

## 📁 Architecture

```
AutoLFM/
├── API/                         # Public API for external addons
│   ├── AutoLFM_Example/         # Ready-to-use example addon
│   ├── API.lua                  # API implementation (v2.0)
│   ├── CHANGELOG.md             # API version history
│   └── README.md                # Complete API documentation
│
├── Core/                        # Core systems
│   ├── Commands.lua             # Slash commands system (/lfm)
│   ├── Constants.lua            # Centralized constants, paths, colors, and limits
│   ├── Events.lua               # WoW event handling (PARTY_MEMBERS_CHANGED, etc.)
│   ├── Settings.lua             # SavedVariables management per character
│   └── Utils.lua                # Utilities and chat output functions
│
├── Logic/                       # Business logic
│   ├── Broadcaster.lua          # Message building and broadcasting engine
│   ├── Content.lua              # Dungeon/Raid/Quest databases and management
│   └── Selection.lua            # Selection state (roles, channels, group)
│
├── Misc/                        # Optional utility modules
│   ├── AutoInvite.lua           # Auto-invite players on whisper keyword
│   ├── AutoMarker.lua           # Auto raid icon assignment
│   ├── EasterEgg.lua            # Fun hidden features
│   ├── FPSDisplay.lua           # FPS/latency display
│   ├── FuBarPlugin.lua          # FuBar integration plugin
│   ├── GuildSpam.lua            # Guild chat broadcaster
│   ├── RestedXP.lua             # Rested XP monitor
│   └── README.md                # Complete misc documentation
│
├── UI/                          # User interface
│   ├── Components/              # Reusable UI components
│   │   ├── IconAnimation.lua    # Eye animation during broadcast
│   │   ├── LinkIntegration.lua  # Quest/Item links integration (Shift+Click)
│   │   ├── MainWindow.lua       # Main frame, roles selector, preview
│   │   ├── MinimapButton.lua    # Draggable minimap button
│   │   ├── PanelBuilder.lua     # UI builder (panels, scrolls, checkboxes)
│   │   └── TabNavigation.lua    # Tab system (Dungeons/Raids/Quests/More/Clear)
│   ├── Sounds/                  # Audio files (.ogg)
│   ├── Textures/                # Visual assets (.blp)
│   ├── ClearTab.lua             # Clear all selections (action tab)
│   ├── DungeonsPanel.lua        # Dungeon list with level filters
│   ├── MorePanel.lua            # Settings (interval, channels, minimap, stats)
│   ├── QuestsPanel.lua          # Quest log integration panel
│   ├── RaidsPanel.lua           # Raid list with size controls
│   └── WelcomePopup.lua         # First-time welcome popup with typing animation
│
├── AutoLFM.png                  # Addon preview image
├── AutoLFM.toc                  # Addon manifest
├── CHANGELOG.md                 # Versioning history
├── Init.lua                     # Initialization and startup sequence
└── README.md                    # This file
```

## 🧩 Extensions

### 📦 Misc Modules
Optional utility modules.

**📖 [Complete Misc Modules Documentation →](Misc/README.md)**

### 🔌 Public API
AutoLFM exposes a comprehensive public API for integration with other addons.

**📖 [Complete API Documentation →](API/README.md)**

## 💾 Configuration
Settings are automatically saved per character in `SavedVariables/AutoLFM.lua`.

Configuration includes:
- Broadcast interval and channels
- Minimap button position
- Dungeon level filters
- Misc modules states and settings

## ℹ️ Information
- **WoW Version**: 1.12.1 (Interface 11200)
- **Lua Version**: 5.0
- **External Libraries**: None
- **Original Author**: Gondoleon

Contributions are welcome!
