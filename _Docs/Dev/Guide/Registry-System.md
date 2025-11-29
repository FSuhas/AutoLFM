# Registry and State Management Guide

## 🗂️ Component Registry System

The registry system tracks all Maestro components with unique IDs for organization, debugging, and execution order.

### ID Categories

| Category | Range | Purpose | Example |
|----------|-------|---------|---------|
| **Commands** | C01-C99 | User actions and API calls | C03: Selection.ToggleDungeon |
| **Events** | E01-E99 | System notifications | E01: Selection.Changed |
| **Listeners** | L01-L99 | Event handlers | L05: DungeonsUI.OnSelectionChanged |
| **States** | S01-S99 | Data storage | S01: Selection.Mode |
| **Init Handlers** | I01-I99 | Module initialization | I07: Logic.Selection |

### Registry Rules

1. **Unique IDs within category** - No duplicate C03, but C03 and E03 can coexist
2. **Sequential numbering** - Use next available ID (C01, C02, C03...)
3. **Descriptive names** - Use Module.Action format for clarity
4. **Immediate documentation** - Update COMPONENT_REGISTRY.md when adding components

### Registry Inspection

```lua
-- View all registered components
/lfm debug
-- Click "Registry" button

-- Example output:
COMMANDS (17 registered):
  [C02] Debug.Toggle
  [C03] Selection.ToggleDungeon
  [C04] Selection.ClearDungeons
  ...

EVENTS (5 registered):
  [E01] Selection.Changed
  [E02] Group.SizeChanged
  ...

LISTENERS (3 registered):
  [L02] Logic.Message.OnGroupSizeChanged -> Group.SizeChanged
  [L05] Logic.Message.OnSelectionChanged -> Selection.Changed
  ...
```

## 🏪 State Management System

### State Principles

#### 1. Single Source of Truth
```lua
-- ✅ CORRECT - One state, multiple readers
SafeRegisterState("Selection.DungeonNames", {}, { id = "S02" })

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

#### 1. Selection States (S01-S08)
User's current selections and preferences
```lua
SafeRegisterState("Selection.Mode", "none", { id = "S01" })           -- "none", "dungeons", "raid", "custom"
SafeRegisterState("Selection.Roles", {}, { id = "S02" })              -- Array: {"TANK", "HEAL", "DPS"}
SafeRegisterState("Selection.DungeonNames", {}, { id = "S03" })       -- Array of selected dungeon names
SafeRegisterState("Selection.RaidName", nil, { id = "S04" })          -- Selected raid name or nil
SafeRegisterState("Selection.RaidSize", 40, { id = "S05" })           -- Custom raid size (1-40)
SafeRegisterState("Selection.DetailsText", "", { id = "S06" })        -- Additional details text
SafeRegisterState("Selection.CustomMessage", "", { id = "S07" })      -- Custom broadcast text
SafeRegisterState("Selection.CustomGroupSize", 5, { id = "S08" })     -- Group size for custom messages
```

#### 2. Group & Message States (S10-S16)
WoW game state, group information, and message generation
```lua
SafeRegisterState("Group.Type", "solo", { id = "S10" })               -- "solo", "party", "raid"
SafeRegisterState("Group.Size", 1, { id = "S11" })                    -- Current group size (1-40)
SafeRegisterState("Group.IsLeader", false, { id = "S12" })            -- Is player party/raid leader
SafeRegisterState("Message.ToBroadcast", "", { id = "S15" })          -- Generated broadcast message
SafeRegisterState("Channels.ActiveChannels", {}, { id = "S16" })      -- Array of active channel names
```

#### 3. Broadcaster States (S20-S25)
Broadcasting system status and metrics
```lua
SafeRegisterState("Broadcaster.IsRunning", false, { id = "S20" })     -- Is broadcaster active
SafeRegisterState("Broadcaster.Interval", 60, { id = "S21" })         -- Broadcast interval (30-7200)
SafeRegisterState("Broadcaster.MessagesSent", 0, { id = "S22" })      -- Messages sent this session
SafeRegisterState("Broadcaster.SessionStartTime", 0, { id = "S23" })  -- GetTime() when started
SafeRegisterState("Broadcaster.LastBroadcastTime", 0, { id = "S24" }) -- GetTime() of last message
SafeRegisterState("Broadcaster.TimeRemaining", 0, { id = "S25" })     -- Seconds until next broadcast
```

#### 4. Settings States (S30+)
Application configuration and settings
```lua
SafeRegisterState("Settings.DryRun", false, { id = "S30" })           -- Dry run mode (test broadcasts)
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

### State Debugging

#### State Inspection
```lua
-- View all state values
/lfm debug
-- Click "State" button

-- Example output:
STATES (19 registered):
  [S01] Selection.Mode = "dungeons"
  [S02] Selection.DungeonNames = {"Deadmines", "Stockade"}
  [S03] Selection.RaidName = nil
  [S04] Selection.RaidSize = 40
  [S05] Selection.Roles = {"TANK", "DPS"}
  ...
```

#### State Change Logging
```lua
-- Enable state change logging (if implemented)
local originalSetState = SetState
SetState = function(key, value)
    local oldValue = GetState(key)
    LogInfo("State change: " .. key .. " = " .. tostring(oldValue) .. " -> " .. tostring(value))
    return originalSetState(key, value)
end
```

### Common State Patterns

#### Computed States
```lua
-- State that depends on other states
Listen("Message.OnSelectionChanged", "Selection.Changed", function()
    local mode = GetState("Selection.Mode")
    local dungeons = GetState("Selection.DungeonNames")
    local raidName = GetState("Selection.RaidName")
    local roles = GetState("Selection.Roles")

    local message = GenerateMessage(mode, dungeons, raidName, roles)
    SetState("Message.ToBroadcast", message)
    EmitEvent("Message.Generated")
end, { id = "L03" })
```

#### Temporary States
```lua
-- States for UI interaction (e.g., form data before submission)
SafeRegisterState("UI.TempCustomMessage", "", { id = "S25" })

-- Clear temporary state after use
RegisterCommand("Selection.ApplyCustomMessage", function()
    local tempMessage = GetState("UI.TempCustomMessage")
    SetState("Selection.CustomMessage", tempMessage)
    SetState("UI.TempCustomMessage", "")  -- Clear temp state
    EmitEvent("Selection.Changed")
end, { id = "C08" })
```

#### Collection States
```lua
-- Managing arrays/lists in state
RegisterCommand("Selection.AddRole", function(role)
    local roles = GetState("Selection.Roles")
    local newRoles = {}

    -- Copy existing roles
    for i = 1, table.getn(roles) do
        table.insert(newRoles, roles[i])
    end

    -- Add new role if not already present
    local found = false
    for i = 1, table.getn(newRoles) do
        if newRoles[i] == role then
            found = true
            break
        end
    end

    if not found then
        table.insert(newRoles, role)
    end

    SetState("Selection.Roles", newRoles)
    EmitEvent("Selection.Changed")
end, { id = "C06" })
```

---

**The registry and state system provides the foundation for predictable, debuggable, and maintainable component management in AutoLFM.**

[← Back to README](../README.md)
