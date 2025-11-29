# Maestro Command Bus Architecture

## 🎯 What is Maestro?

Maestro is a **command bus architecture** that implements the **CQRS pattern** (Command Query Responsibility Segregation) for AutoLFM. It provides centralized state management with event-driven communication between components.

## 🏗️ Core Concepts

### Command Bus Pattern
A command bus is a messaging pattern where:
- **Commands** represent user intentions or system actions
- **Handlers** execute the business logic
- **Events** notify the system of state changes
- **Listeners** react to events for side effects

### CQRS Implementation
- **Commands** (Write): Modify state, trigger side effects
- **Queries** (Read): Access state without modification
- **Events**: Notify components of changes
- **State**: Single source of truth

## 🔄 Data Flow

```
User Action → Command → Handler → State Change → Event → Listeners → UI Update
```

### Detailed Flow Example

1. **User clicks dungeon checkbox**
2. **UI dispatches command**: `Dispatch("Selection.ToggleDungeon", "Deadmines")`
3. **Command handler executes**: Modifies `Selection.DungeonNames` state
4. **State change triggers event**: `EmitEvent("Selection.Changed")`
5. **Multiple listeners react**:
   - UI listener refreshes dungeon list display
   - Message listener rebuilds broadcast text
   - Broadcaster listener updates message preview

## 🧩 Component Types

### Commands (C##)
**Purpose**: Represent user actions and system operations

```lua
-- Registration
RegisterCommand("Selection.ToggleDungeon", function(dungeonName)
    local dungeons = GetState("Selection.DungeonNames")

    -- Business logic
    if IsSelected(dungeons, dungeonName) then
        RemoveDungeon(dungeons, dungeonName)
    else
        AddDungeon(dungeons, dungeonName)  -- FIFO limit of 3
    end

    -- Update state
    SetState("Selection.DungeonNames", dungeons)

    -- Notify system
    EmitEvent("Selection.Changed")
end, { id = "C03" })

-- Usage
Dispatch("Selection.ToggleDungeon", "Deadmines")
```

**Command Characteristics**:
- **Imperative**: Express what should happen
- **Side effects**: Can modify state, emit events
- **Synchronous**: Execute immediately when dispatched
- **Idempotent**: Safe to call multiple times

### Events (E##)
**Purpose**: Notify system of state changes

```lua
-- Registration
RegisterEvent("Selection.Changed", { id = "E01" })

-- Emission (usually in command handlers)
EmitEvent("Selection.Changed", {
    mode = GetState("Selection.Mode"),
    dungeons = GetState("Selection.DungeonNames")
})
```

**Event Characteristics**:
- **Declarative**: Express what happened
- **Immutable**: Cannot be modified after emission
- **Asynchronous**: Listeners execute after emission
- **Broadcast**: All listeners receive the event

### States (S##)
**Purpose**: Centralized data store - single source of truth

```lua
-- Registration
SafeRegisterState("Selection.Mode", "none", { id = "S01" })
SafeRegisterState("Selection.DungeonNames", {}, { id = "S02" })

-- Read access (from anywhere)
local mode = GetState("Selection.Mode")
local dungeons = GetState("Selection.DungeonNames")

-- Write access (triggers events automatically)
SetState("Selection.Mode", "dungeons")
SetState("Selection.DungeonNames", {"Deadmines", "Stockade"})
```

**State Principles**:
- **Immutable**: Always replace, never mutate
- **Centralized**: One state, multiple consumers
- **Reactive**: Changes automatically emit events
- **Authoritative**: UI reflects state, never maintains own data

### Listeners (L##)
**Purpose**: React to events for UI updates and cross-module communication

```lua
-- Registration (ONLY in Init Handlers)
SafeRegisterInit("UI.Content.Dungeons", function()
    Listen("DungeonsUI.OnSelectionChanged", "Selection.Changed", function(eventData)
        RefreshDungeonCheckboxes()
        UpdateSelectionCounter()
    end, { id = "L01" })

    Listen("DungeonsUI.OnGroupSizeChanged", "Group.SizeChanged", function(eventData)
        UpdateAvailableDungeons()
    end, { id = "L07" })
end, { id = "I12", dependencies = { "Logic.Selection" } })
```

**Listener Rules**:
- **Init Handler only**: Never register at file load
- **Event-driven**: Only react to events, don't poll
- **Side effects**: Can dispatch commands, update UI
- **Decoupled**: Don't directly call other modules

### Init Handlers (I##)
**Purpose**: Module initialization with dependency management

```lua
SafeRegisterInit("Logic.Selection", function()
    -- Initialize module state
    InitializeDungeonData()

    -- Register listeners for cross-module communication
    Listen("Selection.OnGroupChange", "Group.SizeChanged", function(eventData)
        ValidateCurrentSelection()
    end, { id = "L03" })

    -- Setup periodic tasks
    SetupSelectionValidation()
end, { id = "I05", dependencies = { "Core.Events" } })
```

## 🔄 Communication Patterns

### 1. User Action Pattern
```
UI Click → Command → State → Event → UI Update
```

Example: Toggle dungeon selection
```lua
-- 1. UI handler
OnDungeonCheckboxClick = function(dungeonName)
    Dispatch("Selection.ToggleDungeon", dungeonName)
end

-- 2. Command handler
RegisterCommand("Selection.ToggleDungeon", function(dungeonName)
    -- Modify state
    local dungeons = GetState("Selection.DungeonNames")
    ToggleDungeonInList(dungeons, dungeonName)
    SetState("Selection.DungeonNames", dungeons)

    -- Emit event
    EmitEvent("Selection.Changed")
end, { id = "C03" })

-- 3. UI listener
Listen("DungeonsUI.OnChanged", "Selection.Changed", function()
    local dungeons = GetState("Selection.DungeonNames")
    UpdateCheckboxStates(dungeons)
end, { id = "L01" })
```

### 2. Cross-Module Communication
```
Module A → Event → Module B Listener → Module B Command
```

Example: Group size affects dungeon availability
```lua
-- Module A: Group size changes
EmitEvent("Group.SizeChanged", { size = newSize, type = groupType })

-- Module B: Selection reacts to group changes
Listen("Selection.OnGroupChange", "Group.SizeChanged", function(eventData)
    if eventData.size >= 5 then
        Dispatch("Selection.EnableRaids")
    else
        Dispatch("Selection.DisableRaids")
    end
end, { id = "L05" })
```

### 3. State Synchronization
```
Logic State ↔ UI Display (via Events)
```

Example: Message generation
```lua
-- Logic: Generate message when selection changes
Listen("Message.OnSelectionChanged", "Selection.Changed", function()
    local mode = GetState("Selection.Mode")
    local dungeons = GetState("Selection.DungeonNames")
    local message = GenerateMessage(mode, dungeons)
    SetState("Message.ToBroadcast", message)
    EmitEvent("Message.Generated")
end, { id = "L02" })

-- UI: Display message when generated
Listen("MessageUI.OnGenerated", "Message.Generated", function()
    local message = GetState("Message.ToBroadcast")
    messagePreview:SetText(message)
end, { id = "L06" })
```

## 🎯 Benefits of Command Bus

### 1. Decoupling
- Modules don't directly depend on each other
- Communication through events and commands
- Easy to add/remove features without breaking existing code

### 2. Testability
- Commands can be tested in isolation
- State changes are predictable
- Events can be mocked for testing

### 3. Debugging
- All commands and events are logged with IDs
- State changes are traceable
- Clear separation between read and write operations

### 4. Scalability
- New listeners can be added without modifying existing code
- Commands can be extended with additional side effects
- State structure can evolve independently

## 🚨 Anti-Patterns to Avoid

### ❌ Direct Module Access
```lua
-- BAD: Direct function call
AutoLFM.Logic.Selection.ToggleDungeon("Deadmines")

-- GOOD: Command dispatch
Dispatch("Selection.ToggleDungeon", "Deadmines")
```

### ❌ State Duplication
```lua
-- BAD: Caching state in UI
local cachedDungeons = GetState("Selection.DungeonNames")
MyUI.dungeonList = cachedDungeons

-- GOOD: Always read from state
local function RefreshUI()
    local dungeons = GetState("Selection.DungeonNames")
    UpdateDungeonList(dungeons)
end
```

### ❌ Listeners at File Load
```lua
-- BAD: Register at file load
Listen("BadListener", "SomeEvent", callback, { id = "L##" })

-- GOOD: Register in Init Handler
SafeRegisterInit("Module", function()
    Listen("GoodListener", "SomeEvent", callback, { id = "L##" })
end, { id = "I##" })
```

### ❌ Synchronous Dependencies
```lua
-- BAD: Direct module dependency
local otherModuleData = AutoLFM.OtherModule.GetData()

-- GOOD: Event-driven communication
EmitEvent("DataRequested")
-- Other module listens and provides data via state
```

## 🔍 Debugging Command Bus

### Registry Inspection
```lua
/lfm debug  -- Open debug window
-- Click "Registry" to see all registered components
-- Verify all C/E/L/S/I components appear with correct IDs
```

### Event Flow Tracing
- Commands show in logs with GRAY ID tags
- Events show emission and listener execution
- State changes are logged with before/after values

### Common Issues
1. **Missing listeners**: Event emitted but no UI update
2. **Circular dependencies**: Command triggers event that triggers same command
3. **State inconsistency**: Multiple sources trying to modify same state
4. **Performance**: Too many fine-grained events causing UI lag

---

**The command bus ensures predictable, testable, and maintainable code by enforcing clear separation between data (State), actions (Commands), and reactions (Events/Listeners).**

[← Back to README](../README.md)
