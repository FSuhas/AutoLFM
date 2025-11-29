# AutoLFM Example Integration

This is a **complete, ready-to-use example addon** that demonstrates **ALL** AutoLFM API features with a comprehensive UI.

## 📦 Installation

Simply copy the entire `AutoLFM_Example` folder to your WoW `Interface\AddOns` directory:

```
WoW/Interface/AddOns/
├── AutoLFM/
└── AutoLFM_Example/  ← Copy this folder here
    ├── AutoLFM_Example.toc
    ├── AutoLFM_Example.lua
    └── README.md
```

## 🎮 Usage

1. **Install AutoLFM** (required dependency)
2. **Copy the `AutoLFM_Example` folder** to your `Interface\AddOns` directory
3. **Restart WoW** or `/reload`
4. Type `/lfmexample` or `/lfmex` to toggle the UI

## 🎨 UI Commands

```bash
/lfmexample         # Toggle main UI frame
/lfmex              # Short alias
/lfmex debug        # Show API debug info
/lfmex callbacks    # List registered callbacks
```

## ✨ Features Demonstrated

This example addon showcases **ALL** AutoLFM API features:

### 📊 Data Functions (11 functions)
- ✅ `GetVersion()` - API version display
- ✅ `IsAvailable()` - Availability check
- ✅ `GetGroupType()` - Current group type (dungeon/raid/other)
- ✅ `GetPlayerCount()` - Real-time player count
- ✅ `GetSelectedContent()` - Selected dungeons/raids with details
- ✅ `GetRolesNeeded()` - Selected roles (Tank/Heal/DPS)
- ✅ `GetMessage()` - Current broadcast message
- ✅ `GetSelectedChannels()` - Active broadcast channels
- ✅ `IsActive()` - Broadcasting status
- ✅ `GetBroadcastStats()` - Messages sent and duration
- ✅ `GetTiming()` - Interval and next broadcast timer
- ✅ `GetFullStatus()` - Complete status in one call

### 🔔 Event System (8 events)
- ✅ `BROADCAST_START` - Broadcast started
- ✅ `BROADCAST_STOP` - Broadcast stopped
- ✅ `MESSAGE_SENT` - Message sent to channels
- ✅ `CONTENT_CHANGED` - Content selection changed
- ✅ `ROLES_CHANGED` - Roles selection changed
- ✅ `CHANNELS_CHANGED` - Channels selection changed
- ✅ `INTERVAL_CHANGED` - Broadcast interval changed
- ✅ `PLAYER_COUNT_CHANGED` - Player count changed (requires `InitMonitoring()`)

### 🛠️ Callback System
- ✅ `RegisterCallback()` - Global callback registration
- ✅ `RegisterEventCallback()` - Event-specific callbacks (all 8 events)
- ✅ `InitMonitoring()` - Enable player count change detection
- ✅ Real-time UI updates on any data change

### 🐛 Debug Tools
- ✅ `/lfmex debug` - Complete API debug output
- ✅ `/lfmex callbacks` - List all registered addons

## 🔗 More Information

For complete API documentation, see: **[API/README.md](../README.md)**
