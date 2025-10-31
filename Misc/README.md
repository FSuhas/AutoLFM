# AutoLFM - Misc Modules

Optional utility modules.

## 📦 Available Modules

| Module | Description | Commands |
|--------|-------------|----------|
| **FPS Display** | Real-time FPS/latency monitor | `/lfm misc fps` or <kbd>CTRL+R</kbd> |
| **Rested XP** | Alert when rested XP reaches max | `/lfm misc rested` |
| **Auto Invite** | Auto-invite on whisper keyword | `/lfm misc autoinv` |
| **Guild Spam** | Automated guild chat broadcaster | `/lfm misc gspam` |
| **Auto Marker** | Automatic raid icon assignment | `/lfm misc marker` |

---

## 🎮 Quick Reference

```bash
/lfm misc status    # Show all modules status
/lfm misc help      # List available commands
```

## 📺 FPS Display

Displays real-time FPS and latency in a movable overlay.
```bash
/lfm misc fps on/off/status
```

## ⭐ Rested XP Monitor

Alerts when rested XP reaches maximum (150% of level bar).
```bash
/lfm misc rested on/off/status
```

## 💌 Auto Invite

Automatically invites players who whisper a keyword.
```bash
/lfm misc autoinv on/off                  # Toggle
/lfm misc autoinv keyword <word>          # Change keyword
/lfm misc autoinv confirm                 # Toggle confirmation whisper
/lfm misc autoinv status                  # Show settings
```

## 🏰 Guild Spam

Broadcasts messages in guild chat at regular intervals.
```bash
/lfm misc gspam start <message>          # Start broadcasting
/lfm misc gspam stop                     # Stop
/lfm misc gspam interval <seconds>       # Change interval (min 30s)
/lfm misc gspam status                   # Show settings
```

## 🎯 Auto Marker

Automatically assigns raid icons to specific players.

```bash
/lfm misc marker on/off                  # Toggle
/lfm misc marker add <name> <icon>       # Track player (1=Star...8=Skull)
/lfm misc marker del <name>              # Remove player
/lfm misc marker list                    # Show tracked players
/lfm misc marker clear                   # Clear all marks
```

## 🔄 Legacy Commands

All legacy commands still work for backward compatibility:

| Module | Modern | Legacy |
|--------|--------|--------|
| Auto Invite | `/lfm misc autoinv` | `/ainv` |
| Guild Spam | `/lfm misc gspam` | `/mg` |
| Auto Marker | `/lfm misc marker` | `/am` |
| Rested XP | `/lfm misc rested` | `/rested` |

## 💾 Settings

All settings are saved per character in `SavedVariables/AutoLFM.lua`:
- Module enabled/disabled states
- Auto Invite keyword and confirmation
- Guild Spam message and interval
- Auto Marker tracked players list

Settings persist across sessions and characters.
