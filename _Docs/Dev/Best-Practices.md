# AutoLFM Development Best Practices

## 📝 Documentation Standards

### LuaDoc Format
Document all public functions with LuaDoc comments:

```lua
--- Toggle dungeon selection with FIFO limit of 3
-- @param dungeonName string The dungeon name to toggle
-- @return boolean true if dungeon was added, false if removed
function ToggleDungeon(dungeonName)
    -- Implementation
end

--- Register a new command in the Maestro system
-- @param commandKey string Unique command identifier (e.g., "Selection.ToggleDungeon")
-- @param handler function Function to execute when command is dispatched
-- @param options table Configuration options with id field
-- @usage RegisterCommand("MyModule.DoSomething", handler, { id = "C25" })
function RegisterCommand(commandKey, handler, options)
    -- Implementation
end
```

### Documentation Guidelines
- **Always document public APIs** - any function exposed to other modules
- **Include @param and @return** - specify types and descriptions
- **Add @usage examples** - show how to call the function
- **Document side effects** - mention state changes, events emitted
- **Keep comments concise** - focus on what, not how

## 🔧 Lua 5.0 Compatibility

### Table Operations
```lua
-- ✅ DO
local count = table.getn(myTable)
table.insert(myTable, value)

-- ❌ DON'T (Lua 5.1+)
local count = #myTable
myTable[#myTable+1] = value
```

### String Functions
```lua
-- ✅ DO
for match in string.gfind(text, pattern) do
    -- process match
end
local pos = string.find(text, "pattern")
local sub = string.sub(text, 1, 5)
local lower = string.lower(text)

-- ❌ DON'T (Lua 5.1+)
for match in string.gmatch(text, pattern) do end
local pos = text:find("pattern")
local sub = text:sub(1, 5)
local lower = text:lower()
```

### Varargs Handling
```lua
-- ✅ DO
function MyFunction(...)
    local argCount = arg.n
    local firstArg = arg[1]
    SomeOtherFunction(unpack(arg))
end

-- ❌ DON'T (Lua 5.1+)
function MyFunction(...)
    local argCount = select("#", ...)
    local firstArg = ...
end
```

### Loop Control
```lua
-- ✅ DO - No continue statement exists
for i = 1, table.getn(items) do
    if not shouldProcess(items[i]) then
        -- Use inverted condition instead of continue
    else
        processItem(items[i])
    end
end

-- ❌ DON'T
for i = 1, table.getn(items) do
    if not shouldProcess(items[i]) then
        continue  -- Does not exist in Lua 5.0
    end
    processItem(items[i])
end
```

## 🛡️ Error Handling

### Use pcall for Risky Operations
```lua
-- ✅ DO - Use pcall for error handling
local success, result = pcall(function()
    return riskyOperation()
end)
if not success then
    print("Error: " .. result)
end
```

### Parameter Validation
```lua
-- ✅ DO - Validate parameters
function MyFunction(param)
    if type(param) ~= "string" then
        error("Expected string, got " .. type(param))
    end
    if param == "" then
        error("Parameter cannot be empty")
    end
end
```

### Graceful Degradation
```lua
-- ✅ DO - Handle missing dependencies gracefully
local function SafeGetAddonData()
    if not IsAddOnLoaded("SomeAddon") then
        return nil, "Addon not loaded"
    end

    local success, data = pcall(SomeAddon.GetData)
    if not success then
        return nil, "Failed to get data: " .. data
    end

    return data
end
```

## ⚡ Performance Optimization

### Cache Frequently Used Values
```lua
-- ✅ DO - Cache table.getn() in loops
local count = table.getn(items)
for i = 1, count do
    processItem(items[i])
end

-- ✅ DO - Use local variables for frequently accessed globals
local GetState = GetState
local SetState = SetState
local string_find = string.find

-- ❌ DON'T - Call table.getn() repeatedly
for i = 1, table.getn(items) do  -- Recalculates each iteration
    processItem(items[i])
end
```

### Minimize State Access
```lua
-- ✅ DO - Read state once, use locally
local function RefreshUI()
    local dungeons = GetState("Selection.DungeonNames")
    local mode = GetState("Selection.Mode")

    UpdateDungeonList(dungeons)
    UpdateModeDisplay(mode)
end

-- ❌ DON'T - Multiple state reads
local function RefreshUI()
    UpdateDungeonList(GetState("Selection.DungeonNames"))
    if GetState("Selection.Mode") == "dungeons" then
        ShowDungeonPanel()
    end
    SetTitle("Mode: " .. GetState("Selection.Mode"))
end
```

### Efficient String Operations
```lua
-- ✅ DO - Use table.concat for multiple concatenations
local parts = {}
table.insert(parts, "LF")
table.insert(parts, tostring(needed))
table.insert(parts, "M ")
table.insert(parts, dungeonName)
local message = table.concat(parts)

-- ❌ DON'T - Multiple string concatenations
local message = "LF" .. tostring(needed) .. "M " .. dungeonName
```

## 🏗️ Code Organization

### File Structure
```lua
--[[
    AutoLFM - Selection Logic
    Handles dungeon/raid selection with FIFO limits
    Dependencies: Core.Events, Core.Maestro
]]

-- Local references at top
local GetState = GetState
local SetState = SetState
local EmitEvent = EmitEvent

-- Constants
local MAX_DUNGEONS = 3
local DEFAULT_RAID_SIZE = 40

-- Private functions
local function validateDungeonName(name)
    return type(name) == "string" and name ~= ""
end

-- Public module
local Selection = {}

-- Module functions
function Selection.SomePublicFunction()
    -- Implementation
end

-- Registration at bottom
SafeRegisterInit("Logic.Selection", function()
    -- Initialize module
end, { id = "I05" })

-- Export
AutoLFM.Logic.Selection = Selection
```

### Naming Conventions
- **Modules**: PascalCase (`Selection`, `MainFrame`)
- **Functions**: PascalCase (`ToggleDungeon`, `RefreshUI`)
- **Variables**: camelCase (`dungeonName`, `isActive`)
- **Constants**: UPPER_CASE (`MAX_DUNGEONS`, `DEFAULT_SIZE`)
- **Private functions**: camelCase with local (`validateInput`)
- **Event names**: Module.PastTense (`Selection.Changed`, `Group.SizeChanged`)
- **Command names**: Module.Verb (`Selection.ToggleDungeon`, `MainFrame.Show`)

### Module Boundaries
```lua
-- ✅ DO - Clear module responsibilities
-- Logic/Selection.lua - Business rules for selection
-- UI/Content/Dungeons.lua - UI for dungeon selection
-- Logic/Message.lua - Message generation from selection

-- ❌ DON'T - Mixed responsibilities
-- Selection.lua containing UI code and message generation
```

## 🧪 Testing and Debugging

### Debug Helpers
```lua
-- Add debug helpers for testing
if AutoLFM.DEBUG then
    Selection.Debug = {
        GetInternalState = function() return privateData end,
        ResetState = function() privateData = {} end,
        SimulateEvent = function(eventName, data)
            EmitEvent(eventName, data)
        end
    }
end
```

### Logging Best Practices
```lua
-- ✅ DO - Use appropriate log levels
LogAction("User selected dungeon: " .. dungeonName)  -- User actions
LogInfo("Initialized selection module")              -- Informational
LogWarning("Player level too low for " .. dungeonName) -- Warnings
LogError("Failed to load dungeon data")              -- Errors

-- ✅ DO - Include context in logs
LogAction("Dungeon toggled", {
    dungeon = dungeonName,
    action = wasSelected and "removed" or "added",
    totalSelected = table.getn(GetState("Selection.DungeonNames"))
})
```

### Validation Functions
```lua
-- ✅ DO - Create validation helpers
local function validateSelectionState()
    local dungeons = GetState("Selection.DungeonNames")
    local mode = GetState("Selection.Mode")

    if mode == "dungeons" and table.getn(dungeons) == 0 then
        LogWarning("Dungeon mode active but no dungeons selected")
        return false
    end

    return true
end
```

## 🔒 Security and Safety

### Input Sanitization
```lua
-- ✅ DO - Sanitize user input
local function sanitizeDungeonName(name)
    if type(name) ~= "string" then
        return nil
    end

    -- Remove dangerous characters
    name = string.gsub(name, "[<>\"'&]", "")

    -- Limit length
    if string.len(name) > 50 then
        name = string.sub(name, 1, 50)
    end

    return name
end
```

### State Protection
```lua
-- ✅ DO - Validate state changes
RegisterCommand("Selection.SetCustomSize", function(size)
    if type(size) ~= "number" then
        LogError("Invalid size type: " .. type(size))
        return
    end

    if size < 1 or size > 40 then
        LogError("Size out of range: " .. size)
        return
    end

    SetState("Selection.CustomGroupSize", size)
    EmitEvent("Selection.Changed")
end, { id = "C11" })
```

## 📋 Code Review Checklist

### Before Committing
- [ ] All public functions documented with LuaDoc
- [ ] Lua 5.0 compatibility verified (no modern syntax)
- [ ] Error handling implemented for risky operations
- [ ] Performance optimizations applied (cached values, local references)
- [ ] Naming conventions followed consistently
- [ ] Module boundaries respected (no cross-module direct calls)
- [ ] Debug helpers added for complex logic
- [ ] Input validation implemented
- [ ] Appropriate logging added
- [ ] COMPONENT_REGISTRY.md updated with new IDs

### Testing
- [ ] Manual testing of all new functionality
- [ ] Debug window shows all components registered
- [ ] No error messages in chat during normal operation
- [ ] Performance acceptable (no frame drops)
- [ ] Edge cases handled gracefully

---

**Following these practices ensures maintainable, performant, and reliable code that integrates well with the Maestro architecture.**

[← Back to README](../README.md)
