# AutoLFM - Automated LFM Broadcaster for WoW Vanilla 1.12 (TurtleWoW)
<p align="center">
  <img src="_Docs/AutoLFM.gif" alt="AutoLFM Illustration"/>
</p>

## 📜 Description
AutoLFM is a powerful World of Warcraft 1.12 (Vanilla) addon that automates the process of broadcasting "Looking For More" (LFM) messages for dungeons, raids, quests and more. This addon helps group leaders efficiently recruit party members without manual spam.

**🐢 Turtle WoW Specific**
- Specifically designed for Turtle WoW with content from that server (custom dungeons, raids, and features)
- Interface design matches Turtle WoW's native LFG system
- Works on any WoW 1.12 client

## 📖 Documentation
- **Users**: [Installation & Usage Guide](_Docs/Installation-Usage.md) - How to install and use AutoLFM
- **Developers**: [Developer Guide](_Docs/Dev/README.md) - Architecture, best practices, and component registry
- **Doc Structure**: [Documentation Structure](_Docs/Documentation-Structure.md) - Overview of all docs and how they relate

## ✨ Features
### 🎯 Content Selection
- Browse all Vanilla and Turtle WoW custom instances (dungeons and raids)
- Multi-selection support with smart filtering by level color
- Quest log integration: add quest/item/chat links via Shift+Click
- 5-tab navigation system with quick access via `/lfm` command or minimap button
- Variable group sizes for applicable raids (10-40 slider)

### 📢 Broadcasting & Messages
- Adjustable broadcast interval (30-120s) with multiple channel support
- Automatic start/stop based on group status
- Live message preview before broadcasting
- Role management: Tank/Healer/DPS visual selector with automatic formatting
- Real-time statistics: duration timer, message count, next broadcast countdown
- Custom message editor with smart message building

### 🎨 Interface & Controls
- Eye-catching broadcast animation with color indicators
- Draggable minimap button with position memory
- One-click clear all selections with smart detection
- Tooltip guidance throughout the interface
- Optional dark mode (ShaguTweaks integration)

### 🤖 Auto-Invite
- Automatically accept invites from players matching criteria
- Configurable class and level requirements
- Real-time filtering and invite management

## 🚀 Quick Start
1. **Install**: Extract into your WoW `Interface/AddOns/` folder
2. **Enable**: Type `/lfm` in-game to open the interface (or click minimap button)
3. **Select Content**: Navigate to Dungeons/Raids/Quests tabs and check desired content
4. **Choose Roles**: Click Tank/Healer/DPS icons (optional)
5. **Configure**: Select channels in "More" tab
6. **Start Broadcasting**: Click the "Start" button

For detailed instructions, see [Installation & Usage Guide](_Docs/Installation-Usage.md).

## 🏗️ Architecture
AutoLFM uses the **Maestro CQRS command bus system** for clean architecture:

- **Core/**: Framework (Maestro command bus, Events, Utils, Storage)
- **Components/**: System components
- **Logic/**: Business logic (Broadcaster, Content, Selection, State management)
- **UI/**: User interface (Templates, Content panels, Controls)

For detailed architecture, see [Developer Guide](_Docs/Dev/README.md).

## 💾 Configuration
Settings are automatically saved per character in `SavedVariables/AutoLFM.lua`:

- Broadcast interval and channels
- Minimap button position
- Dungeon level filters
- Dark mode preference
- Auto-Invite filters

## ℹ️ Information
- **WoW Version**: 1.12 (Interface 11200)
- **Lua Version**: 5.0
- **External Libraries**: None

## 🤝 Contributing
Contributions are welcome! Please feel free to submit issues or pull requests on [GitHub](https://github.com/FSuhas/AutoLFM/issues).
