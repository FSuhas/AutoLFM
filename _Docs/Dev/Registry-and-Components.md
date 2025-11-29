# Registry and Component System

Complete guide to the Maestro registry system, component tracking, and state management in AutoLFM.

---

## 🗂️ Component Registry Overview

The registry system tracks all Maestro components with unique IDs organized by functional domains for clarity, debugging, and execution order.

### ID Categories & Quick Reference

| Category | Range | Count | Purpose |
|----------|-------|-------|---------|
| **Commands** | C01-C31 | 24 | User actions and system operations |
| **Events** | E01-E10 | 10 | System notifications and state changes |
| **Listeners** | L01-L15 | 15 | Event handlers and cross-module communication |
| **States** | S01-S21 | 21 | Data storage and system state |
| **Init Handlers** | I01-I24 | 24 | Module initialization and dependency management |

### Registry Rules

1. **Unique IDs within category** - No duplicate C03, but C03 and E03 can coexist
2. **Sequential numbering** - IDs are continuous within each category (C01, C02, C03...)
3. **Organized by domain** - IDs grouped by functional areas (Core, Selection, Broadcasting, etc.)
4. **Descriptive names** - Use Module.Action format for clarity
5. **Immediate documentation** - Update this file when adding components

### Registry Inspection

```lua
-- View all registered components
/lfm debug
-- Click "Registry" button

-- Example output:
COMMANDS (24 registered):
  [C01] MainFrame.Toggle
  [C02] Debug.Toggle
  [C03] Selection.ToggleDungeon
  ...

EVENTS (10 registered):
  [E01] Selection.Changed
  [E02] Group.SizeChanged
  ...
```

---

## 📋 Complete Component Registry

### Commands (C01-C31)

| ID | Name | Module | Purpose |
|----|------|--------|---------|
| **C01** | `MainFrame.Toggle` | Logic.MainFrame | Toggle main window visibility |
| **C02** | `Debug.Toggle` | Components.Debug | Toggle debug window visibility |
| **C03** | `Selection.ToggleDungeon` | Logic.Selection | Toggle dungeon selection (FIFO max 3) |
| **C04** | `Selection.ToggleRaid` | Logic.Selection | Toggle raid selection (exclusive) |
| **C05** | `Selection.SetRaidSize` | Logic.Selection | Set custom raid size (1-40) |
| **C06** | `Selection.ToggleRole` | Logic.Selection | Toggle role selection (TANK/HEAL/DPS) |
| **C07** | `Selection.ClearRoles` | Logic.Selection | Clear all role selections |
| **C08** | `Selection.SetCustomMessage` | Logic.Selection | Set custom broadcast message |
| **C09** | `Selection.ClearCustomMessage` | Logic.Selection | Clear custom message |
| **C10** | `Selection.SetCustomGroupSize` | Logic.Selection | Set custom group size (1-40) |
| **C11** | `Selection.ClearDungeons` | Logic.Selection | Clear all dungeon selections |
| **C12** | `Selection.ClearRaid` | Logic.Selection | Clear raid selection |
| **C13** | `Selection.SetDetailsText` | Logic.Selection | Set details text (appended to messages) |
| **C14** | `Selection.ClearAll` | Logic.Selection | Clear all selections |
| **C15** | `Message.Generate` | Logic.Message | Generate broadcast message from current state |
| **C16** | `Group.RequestSync` | Logic.Group | Request group state synchronization |
| **C17** | `Group.UpdateSize` | Logic.Group | Update group size state |
| **C18** | `Broadcaster.Toggle` | Logic.Broadcaster | Toggle broadcasting on/off |
| **C19** | `Broadcaster.SetInterval` | Logic.Broadcaster | Set broadcast interval (30-7200 seconds) |
| **C20** | `Channels.ToggleChannel` | Logic.Content.Messaging | Toggle channel selection |
| **C21** | `Channels.SetChannels` | Logic.Content.Messaging | Set multiple channels at once |
| **C22** | `Quests.Toggle` | UI.Content.Quests | Toggle quests panel visibility |
| **C23** | `QuestsList.Refresh` | UI.Content.Quests | Refresh quests list display |
| **C24** | `Presets.Save` | Logic.Content.Presets | Save current selection as preset |
| **C25** | `Presets.Load` | Logic.Content.Presets | Load a saved preset |
| **C26** | `Presets.Delete` | Logic.Content.Presets | Delete a saved preset |
| **C27** | `Settings.ToggleDryRun` | Logic.Content.Settings | Toggle dry run mode |
| **C28** | `Settings.SetBroadcastInterval` | Logic.Content.Settings | Set default broadcast interval |
| **C29** | `AutoInvite.Enable` | Logic.AutoInvite | Enable auto-invite |
| **C30** | `AutoInvite.Disable` | Logic.AutoInvite | Disable auto-invite |
| **C31** | `AutoInvite.SetKeywords` | Logic.AutoInvite | Set auto-invite keywords |

---

### Events (E01-E10)

| ID | Name | Module | Emitted When |
|----|------|--------|-------------|
| **E01** | `Selection.Changed` | Logic.Selection | Any selection modified (dungeons/raids/roles/custom) |
| **E02** | `Group.SizeChanged` | Core.Events | PARTY_MEMBERS_CHANGED or RAID_ROSTER_UPDATE |
| **E03** | `Group.LeaderChanged` | Core.Events | PARTY_LEADER_CHANGED |
| **E04** | `Channels.Changed` | Logic.Content.Messaging | Any channel toggled |
| **E05** | `Presets.Changed` | Logic.Content.Presets | Preset saved or deleted |
| **E06** | `Presets.Loaded` | Logic.Content.Presets | User loads a preset |
| **E07** | `Message.Generated` | Logic.Message | Message successfully generated |
| **E08** | `Settings.Changed` | Logic.Content.Settings | Settings modified |
| **E09** | `Chat.WhisperReceived` | Core.Events | CHAT_MSG_WHISPER (for Auto Invite) |
| **E10** | `AutoInvite.Changed` | Logic.AutoInvite | Settings modified |

---

### States (S01-S21)

| ID | Name | Module | Type | Default |
|----|------|--------|------|---------|
| **S01** | `Selection.Mode` | Logic.Selection | string | "none" |
| **S02** | `Selection.Roles` | Logic.Selection | table | {} |
| **S03** | `Selection.DungeonNames` | Logic.Selection | table | {} |
| **S04** | `Selection.RaidName` | Logic.Selection | string/nil | nil |
| **S05** | `Selection.RaidSize` | Logic.Selection | number | 40 |
| **S06** | `Selection.DetailsText` | Logic.Selection | string | "" |
| **S07** | `Selection.CustomMessage` | Logic.Selection | string | "" |
| **S08** | `Selection.CustomGroupSize` | Logic.Selection | number | 5 |
| **S09** | `Group.Type` | Logic.Group | string | "solo" |
| **S10** | `Group.Size` | Logic.Group | number | 1 |
| **S11** | `Group.IsLeader` | Logic.Group | boolean | false |
| **S12** | `Message.ToBroadcast` | Logic.Message | string | "" |
| **S13** | `Broadcaster.IsRunning` | Logic.Broadcaster | boolean | false |
| **S14** | `Broadcaster.Interval` | Logic.Broadcaster | number | 60 |
| **S15** | `Broadcaster.MessagesSent` | Logic.Broadcaster | number | 0 |
| **S16** | `Broadcaster.SessionStartTime` | Logic.Broadcaster | number | 0 |
| **S17** | `Broadcaster.LastBroadcastTime` | Logic.Broadcaster | number | 0 |
| **S18** | `Channels.ActiveChannels` | Logic.Content.Messaging | table | {} |
| **S19** | `Broadcaster.TimeRemaining` | Logic.Broadcaster | number | 0 |
| **S20** | `Settings.DryRun` | Logic.Content.Settings | boolean | false |
| **S21** | `Presets.SavedPresets` | Logic.Content.Presets | table | {} |

---

### Listeners (L01-L15)

| ID | Name | Listens To | Module | Purpose |
|----|------|------------|--------|---------|
| **L01** | `UI.Dungeons.OnSelectionChanged` | E01 | UI.Content.Dungeons | Update dungeons UI when selection changes |
| **L02** | `Logic.Message.OnSelectionChanged` | E01 | Logic.Message | Rebuild message when selection changes |
| **L03** | `Logic.Message.OnGroupSizeChanged` | E02 | Logic.Message | Rebuild message when group size changes |
| **L04** | `UI.Raids.OnSelectionChanged` | E01 | UI.Content.Raids | Update raids UI when selection changes |
| **L05** | `Logic.Broadcaster.OnGroupSizeChanged` | E02 | Logic.Broadcaster | Handle group changes, convert to raid, auto-stop |
| **L06** | `UI.Messaging.OnSelectionChanged` | E01 | UI.Content.Messaging | Update messaging UI when selection changes |
| **L07** | `UI.Quests.OnSelectionChanged` | E01 | UI.Content.Quests | Update quests UI when selection changes |
| **L08** | `UI.Messaging.OnChannelsChanged` | E04 | UI.Content.Messaging | Update messaging UI when channels change |
| **L09** | `UI.Quests.OnSelectionChanged` | E01 | UI.Content.Quests | Update quests UI when selection changes |
| **L10** | `UI.Content.Messaging.OnInit` | E04 | UI.Content.Messaging | Initialize messaging UI state |
| **L11** | `UI.Presets.OnChanged` | E05 | UI.Content.Presets | Update presets UI when presets list changes |
| **L12** | `UI.Content.Presets.OnLoaded` | E06 | UI.Content.Presets | Update UI when preset is loaded |
| **L13** | `UI.Settings.OnChanged` | E08 | UI.Content.Settings | Update settings UI when settings change |
| **L14** | `AutoInvite.OnWhisper` | E09 | Logic.AutoInvite | Process whispers for auto-invite |
| **L15** | `AutoInvite.OnLeaderChanged` | E03 | Logic.AutoInvite | Handle leader changes for auto-invite |

---

### Init Handlers (I01-I24)

| ID | Name | Module | Dependencies | Purpose |
|----|------|--------|--------------|---------|
| **I01** | `Core.Events` | Core.Events | - | Initialize WoW event listeners, register events |
| **I02** | `Core.Storage` | Core.Storage | - | Initialize SavedVariables |
| **I03** | `Core.API` | Core.API | - | Initialize API module |
| **I04** | `Core.Utils` | Core.Utils | - | Initialize utility functions |
| **I05** | `Logic.Selection` | Logic.Selection | - | Register selection commands and events |
| **I06** | `Logic.Content.Dungeons` | Logic.Content.Dungeons | - | Initialize dungeons cache |
| **I07** | `Logic.Group` | Logic.Group | Core.Events | Initialize group tracking |
| **I08** | `Logic.Message` | Logic.Message | Logic.Selection, Logic.Group, Core.Events | Initialize message builder |
| **I09** | `Logic.Broadcaster` | Logic.Broadcaster | Logic.Message, Logic.Content.Messaging, Core.Events | Initialize broadcaster system |
| **I10** | `Logic.Content.Messaging` | Logic.Content.Messaging | Core.Storage | Initialize messaging system |
| **I11** | `UI.MainFrame` | UI.MainFrame | - | Initialize main frame UI |
| **I12** | `UI.Content.Dungeons` | UI.Content.Dungeons | - | Initialize dungeons UI |
| **I13** | `UI.Content.Raids` | UI.Content.Raids | - | Initialize raids UI |
| **I14** | `UI.Content.Quests` | UI.Content.Quests | - | Initialize quests UI |
| **I15** | `UI.Content.Messaging` | UI.Content.Messaging | Logic.Content.Messaging, Logic.Broadcaster | Initialize messaging UI |
| **I16** | `Logic.AutoInvite` | Logic.AutoInvite | Core.Events | Initialize auto-invite system |
| **I17** | `Components.Debug` | Components.Debug | - | Register debug interface |
| **I18** | `Components.Minimap` | Components.Minimap | - | Initialize minimap button |
| **I19** | `Components.DarkUI` | Components.DarkUI | - | Initialize dark UI theme |
| **I20** | `Components.WelcomePopup` | Components.WelcomePopup | - | Initialize welcome popup |
| **I21** | `Components.EyeAnimation` | Components.EyeAnimation | Logic.Broadcaster | Initialize eye animation |
| **I22** | `UI.Content.Presets` | UI.Content.Presets | Logic.Content.Presets | Initialize presets UI |
| **I23** | `Logic.Content.Settings` | Logic.Content.Settings | Core.Storage | Initialize settings panel |
| **I24** | `Logic.Content.Presets` | Logic.Content.Presets | Core.Storage, Logic.Selection | Initialize presets system |

---

## 🏪 State Management System

### State Principles

#### 1. Single Source of Truth
```lua
-- ✅ CORRECT - One state, multiple readers
SafeRegisterState("Selection.DungeonNames", {}, { id = "S03" })

-- UI reads from state
local dungeons = GetState("Selection.DungeonNames")
UpdateCheckboxes(dungeons)

-- Logic reads from state
local dungeons = GetState("Selection.DungeonNames")
local message = GenerateMessage(dungeons)

-- ❌ WRONG - Duplicating data
local uiDungeonCache = GetState("Selection.DungeonNames")  -- Don't cache
local logicDungeonCopy = dungeons  -- Don't copy
```

#### 2. Immutable Updates
```lua
-- ✅ CORRECT - Replace entire state
local dungeons = GetState("Selection.DungeonNames")
local newDungeons = {}
for i = 1, table.getn(dungeons) do
    if dungeons[i] ~= dungeonToRemove then
        table.insert(newDungeons, dungeons[i])
    end
end
SetState("Selection.DungeonNames", newDungeons)

-- ❌ WRONG - Mutating state directly
local dungeons = GetState("Selection.DungeonNames")
table.remove(dungeons, index)  -- Don't mutate the returned table
```

#### 3. Command-Only Writes
```lua
-- ✅ CORRECT - State changes through commands
RegisterCommand("Selection.AddDungeon", function(dungeonName)
    local dungeons = GetState("Selection.DungeonNames")
    local newDungeons = CopyTable(dungeons)
    table.insert(newDungeons, dungeonName)
    SetState("Selection.DungeonNames", newDungeons)
    EmitEvent("Selection.Changed")
end, { id = "C03" })

-- Usage
Dispatch("Selection.AddDungeon", "Deadmines")

-- ❌ WRONG - Direct state modification from UI
function OnDungeonClick(dungeonName)
    local dungeons = GetState("Selection.DungeonNames")
    table.insert(dungeons, dungeonName)  -- Don't modify directly
    SetState("Selection.DungeonNames", dungeons)  -- Don't call from UI
end
```

### State Categories

#### Selection States (S01-S08)
User's current selections and preferences
```lua
SafeRegisterState("Selection.Mode", "none", { id = "S01" })           -- "none", "dungeons", "raid", "custom"
SafeRegisterState("Selection.Roles", {}, { id = "S02" })              -- Array: {"TANK", "HEAL", "DPS"}
SafeRegisterState("Selection.DungeonNames", {}, { id = "S03" })       -- Array of selected dungeon names
SafeRegisterState("Selection.RaidName", nil, { id = "S04" })          -- Selected raid name or nil (exclusive)
SafeRegisterState("Selection.RaidSize", 40, { id = "S05" })           -- Custom raid size (1-40)
SafeRegisterState("Selection.DetailsText", "", { id = "S06" })        -- Additional details text
SafeRegisterState("Selection.CustomMessage", "", { id = "S07" })      -- Custom broadcast text
SafeRegisterState("Selection.CustomGroupSize", 5, { id = "S08" })     -- Group size for custom messages
```

#### Group & Message States (S09-S12)
WoW game state, group information, and message generation
```lua
SafeRegisterState("Group.Type", "solo", { id = "S09" })               -- "solo", "party", "raid"
SafeRegisterState("Group.Size", 1, { id = "S10" })                    -- Current group size (1-40)
SafeRegisterState("Group.IsLeader", false, { id = "S11" })            -- Is player party/raid leader
SafeRegisterState("Message.ToBroadcast", "", { id = "S12" })          -- Generated broadcast message
```

#### Broadcaster States (S13-S19)
Broadcasting system status and metrics
```lua
SafeRegisterState("Broadcaster.IsRunning", false, { id = "S13" })     -- Is broadcaster active
SafeRegisterState("Broadcaster.Interval", 60, { id = "S14" })         -- Broadcast interval (30-7200)
SafeRegisterState("Broadcaster.MessagesSent", 0, { id = "S15" })      -- Messages sent this session
SafeRegisterState("Broadcaster.SessionStartTime", 0, { id = "S16" })  -- GetTime() when started
SafeRegisterState("Broadcaster.LastBroadcastTime", 0, { id = "S17" }) -- GetTime() of last message
SafeRegisterState("Channels.ActiveChannels", {}, { id = "S18" })      -- Array of active channel names
SafeRegisterState("Broadcaster.TimeRemaining", 0, { id = "S19" })     -- Seconds until next broadcast
```

#### Settings & Content States (S20-S21)
Application configuration and content management
```lua
SafeRegisterState("Settings.DryRun", false, { id = "S20" })           -- Dry run mode (test broadcasts)
SafeRegisterState("Presets.SavedPresets", {}, { id = "S21" })         -- Array of saved presets
```

### State Access Patterns

#### Reading State
```lua
-- Simple read
local mode = GetState("Selection.Mode")

-- Conditional read
local dungeons = GetState("Selection.DungeonNames")
if table.getn(dungeons) > 0 then
    -- Process dungeons
end

-- Multiple state reads (cache locally for performance)
local function RefreshUI()
    local mode = GetState("Selection.Mode")
    local dungeons = GetState("Selection.DungeonNames")
    local roles = GetState("Selection.Roles")

    UpdateModeDisplay(mode)
    UpdateDungeonList(dungeons)
    UpdateRoleButtons(roles)
end
```

#### Writing State
```lua
-- Always through commands
RegisterCommand("Selection.SetMode", function(newMode)
    -- Validate input
    if not IsValidMode(newMode) then
        LogError("Invalid mode: " .. tostring(newMode))
        return
    end

    -- Update state
    SetState("Selection.Mode", newMode)

    -- Clear incompatible selections
    if newMode == "dungeons" then
        SetState("Selection.RaidName", nil)
    elseif newMode == "raid" then
        SetState("Selection.DungeonNames", {})
    end

    -- Notify system
    EmitEvent("Selection.Changed")
end, { id = "C03" })
```

### State Validation

#### Type Checking
```lua
local function ValidateSelectionState()
    local mode = GetState("Selection.Mode")
    local dungeons = GetState("Selection.DungeonNames")
    local raidName = GetState("Selection.RaidName")

    -- Check types
    if type(mode) ~= "string" then
        LogError("Selection.Mode must be string, got " .. type(mode))
        return false
    end

    if type(dungeons) ~= "table" then
        LogError("Selection.DungeonNames must be table, got " .. type(dungeons))
        return false
    end

    -- Check consistency
    if mode == "dungeons" and table.getn(dungeons) == 0 then
        LogWarning("Dungeon mode active but no dungeons selected")
    end

    if mode == "raid" and not raidName then
        LogWarning("Raid mode active but no raid selected")
    end

    return true
end
```

#### State Constraints
```lua
RegisterCommand("Selection.SetRaidSize", function(size)
    -- Validate range
    if type(size) ~= "number" or size < 1 or size > 40 then
        LogError("Raid size must be number between 1-40, got " .. tostring(size))
        return
    end

    -- Apply constraint
    SetState("Selection.RaidSize", size)
    EmitEvent("Selection.Changed")
end, { id = "C05" })
```

---

## 🔍 Domain Organization

### Functional Domains

The registry is organized into these functional domains:

**Core Foundation (I01-I04, C01-C02)**
- Essential systems all other modules depend on

**Selection System (I05-I06, C03-C14, E01, S01-S08, L01-L04)**
- User selections (dungeons, raids, roles, custom settings)

**Group & Message (I07-I08, C15-C17, E02-E03, S09-S12, L05-L07)**
- WoW group state and message generation

**Broadcasting (I09-I10, C18-C21, E04, S13-S19, L08-L10)**
- Channel management and message broadcasting

**UI & Content (I11-I15, C22-C28, E05-E08, S20-S21, L11-L13)**
- UI panels, presets, and configuration

**Auto Invite (I16, C29-C31, E09-E10, L14-L15)**
- Automated whisper-based invitations

**Components & Utils (I17-I24)**
- Visual components, animations, and utilities

---

## Key Principles

1. **IDs are immutable** - Once assigned, never change an ID after it's been used
2. **Sequential within category** - All IDs are continuous: C01-C31, E01-E10, L01-L15, S01-S21, I01-I24
3. **Organized by domain** - IDs grouped by functional areas for logical understanding
4. **Each category has its own namespace** - C03 and E03 can coexist without conflict
5. **Init handler order matters** - Handlers execute roughly in numerical order with dependencies resolved

---

## Adding New Components

When adding new Commands, Events, Listeners, States, or Init Handlers:

1. Identify which domain the component belongs to
2. Find the next available ID in that domain's range
3. Update this file with the new entry in the appropriate section
4. Update documentation as needed
5. Use the ID in your registration: `{ id = "C32" }`

Example:
```lua
RegisterCommand("MyModule.DoSomething", function()
    -- Implementation
end, { id = "C32" })
```

---

## Related Documentation

- [Maestro-Architecture.md](./Maestro-Architecture.md) - System design and patterns
- [Best-Practices.md](./Best-Practices.md) - Development guidelines
- [API.md](./API.md) - Public API for external addons

---

[← Back to Dev Documentation](../README.md)
