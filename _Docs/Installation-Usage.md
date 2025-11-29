# AutoLFM - Installation & Usage Guide

## Quick Links

- **Getting Started**: [Installation](#-installation) | [Basic Usage](#-basic-usage)
- **Developers**: [Dev Guide](Dev/README.md) | [Documentation Structure](#-documentation-1)
- **Support**: [Troubleshooting](#-troubleshooting) | [GitHub Issues](https://github.com/FSuhas/AutoLFM/issues/44)

---

## 📦 Installation

### Requirements
- World of Warcraft Vanilla 1.12 (TurtleWoW)
- AddOn compatible folder

### Step-by-Step Installation

1. **Download** the AutoLFM addon
2. **Extract** the folder to your World of Warcraft `Interface/AddOns/` directory
3. **Restart** World of Warcraft
4. **Verify**: You should see "AutoLFM" in your AddOns list at login

### Directory Structure
```
World of Warcraft/Interface/AddOns/
├── AutoLFM/
│   ├── AutoLFM.toc
│   ├── Core/
│   ├── Components/
│   ├── Logic/
│   ├── UI/
│   └── _Docs/
```

---

## 🎮 Basic Usage

### Opening AutoLFM
Type in chat:
```
/lfm
```

This opens the main AutoLFM interface.

### Main Features

#### 1. **Dungeon Selection**
- Click checkboxes to select dungeons you want to run
- Maximum 3 dungeons can be selected simultaneously
- Selected dungeons appear in your broadcast message

#### 2. **Message Customization**
- Click "Message" tab to edit your LFM broadcast
- Preview shows exactly what will be broadcast
- Click "Insert VAR" button to see available variables

#### 3. **Broadcasting**
- Click "Broadcast" button to send your LFM message to chat
- Use "Auto-Broadcast" for automatic periodic broadcasting
- Set broadcast frequency in settings

#### 4. **Auto-Invite**
- Configure auto-invite filters in the "Auto-Invite" tab
- Set class requirements, level requirements
- Automatically accept invites matching your criteria

### Debug Mode

For advanced users and developers:
```
/lfm debug
```

Shows internal component registry and state information.

---

## ⚙️ Configuration

### Settings Tab
- **Auto-Broadcast Interval**: How often to re-broadcast your message
- **Auto-Invite Filters**: Customize who gets auto-invited
- **Color Preferences**: Set custom UI colors

### Saving Configuration
All settings are automatically saved to your WoW SavedVariables.

---

## 🆘 Troubleshooting

### AutoLFM doesn't appear
- Verify addon is enabled in AddOns list
- Check addon folder is named exactly "AutoLFM"
- Restart WoW completely

### Broadcast not sending
- Verify dungeon is selected
- Check message is not empty
- Ensure you're not in restricted channels

### Auto-Invite not working
- Check filters are configured correctly
- Verify you're accepting invites
- Check chat log for any error messages

---

## 📚 Documentation

### For Users
Start here: This guide covers installation, basic usage, configuration, and troubleshooting.

### For Developers

**Quick Start:**
1. [Dev/README.md](Dev/README.md) - Developer overview and quick reference
2. [Dev/Guide/Maestro-Architecture.md](Dev/Guide/Maestro-Architecture.md) - Understand the CQRS command bus system
3. [Dev/Guide/Best-Practices.md](Dev/Guide/Best-Practices.md) - Lua 5.0 compatibility and coding standards
4. [Dev/Guide/Registry-System.md](Dev/Guide/Registry-System.md) - Component registration and state management
5. [Dev/Reference/Component-Registry.md](Dev/Reference/Component-Registry.md) - Complete list of all registered components

**Project Structure:**
```
AutoLFM/
├── README.md                          (Project overview)
├── _Docs/
│   ├── Installation-Usage.md          (This file)
│   └── Dev/
│       ├── README.md                  (Developer entry point)
│       ├── Guide/                     (Learning materials)
│       │   ├── Maestro-Architecture.md
│       │   ├── Best-Practices.md
│       │   └── Registry-System.md
│       └── Reference/                 (Component reference)
│           └── Component-Registry.md
├── Core/                              (Framework)
├── Components/                        (Reusable components)
├── Logic/                             (Business logic)
└── UI/                                (User interface)
```

---

## 📞 Support

Found a bug or have suggestions? Please report at:
[GitHub Issues - AutoLFM](https://github.com/FSuhas/AutoLFM/issues/44)

For development questions, see [Dev/README.md](Dev/README.md)
