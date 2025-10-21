# AutoLFM API Documentation

## 📖 Overview

The **AutoLFM API** provides a comprehensive interface for external addons to interact with AutoLFM's broadcasting system. This allows developers to build integrations, gather statistics, and react to broadcast events.

**API Version:** v2.0  
**Compatible with:** AutoLFM v2.1.0+  

## 🔌 Quick Start

### Check Availability

Before using the API, always verify it's loaded:

```lua
if AutoLFM and AutoLFM.API and AutoLFM.API.IsAvailable() then
  -- Safe to use API
  local version = AutoLFM.API.GetVersion()
  DEFAULT_CHAT_FRAME:AddMessage("AutoLFM API " .. version .. " loaded")
end
```

### Get Current Status

```lua
local status = AutoLFM.API.GetFullStatus()

-- Access specific information
local groupType = status.groupType              -- "dungeon", "raid", or "other"
local isActive = status.broadcastStats.isActive -- true/false
local message = status.message.combined         -- Current broadcast message
local missing = status.playerCount.missing      -- Number of players needed
```

## 📚 API Reference

### Core Functions

#### `AutoLFM.API.GetVersion()`
Returns the API version string.

**Returns:** `string` - Version number (e.g., "v2.0")

**Example:**
```lua
local version = AutoLFM.API.GetVersion()
```

#### `AutoLFM.API.IsAvailable()`
Checks if the API is fully initialized and ready to use.

**Returns:** `boolean` - `true` if available, `false` otherwise

**Example:**
```lua
if AutoLFM.API.IsAvailable() then
  -- API is ready
end
```

### Group Information

#### `AutoLFM.API.GetGroupType()`
Returns the current group type based on selected content.

**Returns:** `string` - `"dungeon"`, `"raid"`, or `"other"`

**Example:**
```lua
local groupType = AutoLFM.API.GetGroupType()
if groupType == "raid" then
  -- Handle raid logic
end
```

#### `AutoLFM.API.GetPlayerCount()`
Returns information about player count in the group.

**Returns:** `table` with fields:
- `currentInGroup` (number) - Current players in group
- `desiredTotal` (number) - Target group size
- `missing` (number) - Players still needed

**Example:**
```lua
local count = AutoLFM.API.GetPlayerCount()
DEFAULT_CHAT_FRAME:AddMessage("Need " .. count.missing .. " more players")
```

### Selected Content

#### `AutoLFM.API.GetSelectedContent()`
Returns detailed information about selected dungeons/raids.

**Returns:** `table` with fields:
- `type` (string) - Content type ("dungeon", "raid", "other")
- `list` (table) - Array of content tags (e.g., {"BRD", "LBRS"})
- `details` (table) - Map of tag to detail objects

**Detail object structure:**
```lua
{
  name = "Blackrock Depths",
  tag = "BRD",
  levelMin = 52,    -- For dungeons
  levelMax = 60,    -- For dungeons
  sizeMin = 10,     -- For raids
  sizeMax = 40      -- For raids
}
```

**Example:**
```lua
local content = AutoLFM.API.GetSelectedContent()
for i = 1, table.getn(content.list) do
  local tag = content.list[i]
  local detail = content.details[tag]
  if detail then
    DEFAULT_CHAT_FRAME:AddMessage(detail.name .. " (" .. tag .. ")")
  end
end
```

#### `AutoLFM.API.GetRolesNeeded()`
Returns the list of selected roles.

**Returns:** `table` - Array of role strings (e.g., {"Tank", "Healer"})

**Example:**
```lua
local roles = AutoLFM.API.GetRolesNeeded()
if table.getn(roles) > 0 then
  DEFAULT_CHAT_FRAME:AddMessage("Looking for: " .. table.concat(roles, ", "))
end
```

### Message & Channels

#### `AutoLFM.API.GetMessage()`
Returns information about the broadcast message.

**Returns:** `table` with fields:
- `combined` (string) - Full formatted message
- `userInput` (string) - Custom user message
- `hasUserInput` (boolean) - `true` if user added custom text

**Example:**
```lua
local msg = AutoLFM.API.GetMessage()
if msg.hasUserInput then
  DEFAULT_CHAT_FRAME:AddMessage("Custom message: " .. msg.userInput)
end
```

#### `AutoLFM.API.GetSelectedChannels()`
Returns the list of channels where messages are broadcasted.

**Returns:** `table` - Array of channel names (e.g., {"LookingForGroup", "World"})

**Example:**
```lua
local channels = AutoLFM.API.GetSelectedChannels()
for i = 1, table.getn(channels) do
  DEFAULT_CHAT_FRAME:AddMessage("Broadcasting to: " .. channels[i])
end
```

### Broadcast Status

#### `AutoLFM.API.IsActive()`
Quick check if broadcasting is currently active.

**Returns:** `boolean` - `true` if broadcasting, `false` otherwise

**Example:**
```lua
if AutoLFM.API.IsActive() then
  -- Broadcasting is active
end
```

#### `AutoLFM.API.GetBroadcastStats()`
Returns detailed broadcast statistics.

**Returns:** `table` with fields:
- `isActive` (boolean) - Broadcasting status
- `messagesSent` (number) - Total messages sent
- `searchDuration` (number) - Seconds since broadcast started

**Example:**
```lua
local stats = AutoLFM.API.GetBroadcastStats()
DEFAULT_CHAT_FRAME:AddMessage("Messages sent: " .. stats.messagesSent)
DEFAULT_CHAT_FRAME:AddMessage("Duration: " .. math.floor(stats.searchDuration) .. "s")
```

#### `AutoLFM.API.GetTiming()`
Returns timing information about broadcasts.

**Returns:** `table` with fields:
- `intervalSeconds` (number) - Broadcast interval in seconds
- `timeUntilNext` (number) - Seconds until next broadcast

**Example:**
```lua
local timing = AutoLFM.API.GetTiming()
DEFAULT_CHAT_FRAME:AddMessage("Next message in " .. math.floor(timing.timeUntilNext) .. "s")
```

### Complete Status

#### `AutoLFM.API.GetFullStatus()`
Returns all information in a single call.

**Returns:** `table` containing all data from the above functions

**Example:**
```lua
local status = AutoLFM.API.GetFullStatus()
-- Contains: groupType, selectedContent, playerCount, rolesNeeded,
--           message, selectedChannels, broadcastStats, timing
```

## 🔔 Event System

### Available Events

AutoLFM provides event-based callbacks for real-time updates:

```lua
AutoLFM.API.EVENTS = {
  BROADCAST_START = "BROADCAST_START",
  BROADCAST_STOP = "BROADCAST_STOP",
  MESSAGE_SENT = "MESSAGE_SENT",
  CONTENT_CHANGED = "CONTENT_CHANGED",
  ROLES_CHANGED = "ROLES_CHANGED",
  CHANNELS_CHANGED = "CHANNELS_CHANGED",
  INTERVAL_CHANGED = "INTERVAL_CHANGED"
}
```

### Register a Global Callback

Called on **any** data change:

```lua
AutoLFM.API.RegisterCallback("MyAddon", function(status, eventType)
  DEFAULT_CHAT_FRAME:AddMessage("AutoLFM changed: " .. (eventType or "unknown"))
  -- status contains full status data
end)
```

### Register an Event-Specific Callback

Called only for a **specific event**:

```lua
AutoLFM.API.RegisterEventCallback(
  AutoLFM.API.EVENTS.BROADCAST_START,
  "MyAddon",
  function(status)
    DEFAULT_CHAT_FRAME:AddMessage("Broadcasting started!")
  end
)
```

### Unregister Callbacks

```lua
-- Remove global callback
AutoLFM.API.UnregisterCallback("MyAddon")

-- Remove event-specific callback
AutoLFM.API.UnregisterEventCallback(AutoLFM.API.EVENTS.BROADCAST_START, "MyAddon")
```

## 🛠️ Debug Tools

### Show Current API Status

```lua
/lfm api data
```

Outputs concise status:
- Group type
- Broadcasting status
- Player count
- Selected roles and channels
- Broadcast interval

### Print Detailed Debug Information

```lua
/lfm api debug
-- or in code:
AutoLFM.API.DebugPrint()
```

Outputs complete debug info:
- API version
- Group type and content
- Player count
- Selected roles
- Current message
- Channels
- Broadcasting status
- Statistics
- Callback count

### List Registered Callbacks

```lua
AutoLFM.API.ListCallbacks()
```

Shows all addons currently registered for callbacks.

### Get Callback Count

```lua
local count = AutoLFM.API.GetCallbackCount()
```

## 💡 Usage Examples

### Ready-to-Use Example Addon

A **complete, functional example addon** is provided in the `AutoLFM_Example/` folder. You can copy it directly to your WoW AddOns directory and use it immediately.

**📦 [Example Addon →](AutoLFM_Example/)**

The example addon demonstrates:
- API availability checks
- Real-time status monitoring
- Event callback registration
- Custom UI integration
- Safe error handling

See **[AutoLFM_Example/README.md](AutoLFM_Example/README.md)** for installation and usage instructions.

## ⚠️ Important Notes

### Thread Safety
- All API calls are safe to use from any WoW event handler or OnUpdate script

### Error Handling
- API functions return safe default values if AutoLFM is not loaded
- Always check `IsAvailable()` before relying on data

### Performance
- `GetFullStatus()` creates a new table each call - cache if needed
- Event callbacks are more efficient than polling for changes

## 🐛 Troubleshooting

### API Not Available
```lua
if not AutoLFM.API.IsAvailable() then
  DEFAULT_CHAT_FRAME:AddMessage("AutoLFM not loaded or still initializing")
end
```

### Callback Not Firing
- Ensure your addon name is unique
- Check that the callback function is valid
- Use `AutoLFM.API.ListCallbacks()` to verify registration

### Data Appears Empty
- Verify AutoLFM main window has been opened at least once
- Check that content/roles/channels are actually selected in AutoLFM UI

## 📝 Changelog

### v2.0 (Current)
- **Event System**: Added 7 event types (`BROADCAST_START`, `BROADCAST_STOP`, `MESSAGE_SENT`, `CONTENT_CHANGED`, `ROLES_CHANGED`, `CHANNELS_CHANGED`, `INTERVAL_CHANGED`)
- **New Functions**: `RegisterEventCallback()`, `UnregisterEventCallback()`, `IsActive()`, `DebugPrint()`, `GetCallbackCount()`, `ListCallbacks()`
- **Renamed**: `GetDynamicMessage()` → `GetMessage()` with improved structure
- **Improvements**: Better error handling with pcall, safe defaults when API unavailable, consistent return structures
- **Example Addon**: Complete functional example in `AutoLFM_Example/` folder
- **Fixed**: Callbacks fire properly, nil error prevention, better guards

### v1.0
- Initial release with core functions: `GetVersion()`, `IsAvailable()`, `GetGroupType()`, `GetSelectedContent()`, `GetPlayerCount()`, `GetRolesNeeded()`, `GetDynamicMessage()`, `GetSelectedChannels()`, `GetBroadcastStats()`, `GetTiming()`, `GetFullStatus()`, `RegisterCallback()`, `UnregisterCallback()`, `DataPrint()`
