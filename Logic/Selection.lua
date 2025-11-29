--=============================================================================
-- AutoLFM: Selection Logic
--   Manages content selection with business rules (FIFO, exclusivity, etc.)
--   ARCHITECTURE: States are the ONLY source of truth (no private variables)
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Selection = {}

--=============================================================================
-- CONSTANTS
--=============================================================================
local MAX_DUNGEONS = AutoLFM.Core.Constants.MAX_DUNGEONS or 3

--=============================================================================
-- STATE DECLARATIONS (MUST BE FIRST)
--=============================================================================
AutoLFM.Core.SafeRegisterState("Selection.Mode", "none", { id = "S01" })
AutoLFM.Core.SafeRegisterState("Selection.Roles", {}, { id = "S02" })
AutoLFM.Core.SafeRegisterState("Selection.DungeonNames", {}, { id = "S03" })
AutoLFM.Core.SafeRegisterState("Selection.RaidName", nil, { id = "S04" })
AutoLFM.Core.SafeRegisterState("Selection.RaidSize", 40, { id = "S05" })
AutoLFM.Core.SafeRegisterState("Selection.DetailsText", "", { id = "S06" })
AutoLFM.Core.SafeRegisterState("Selection.CustomMessage", "", { id = "S07" })
AutoLFM.Core.SafeRegisterState("Selection.CustomGroupSize", 5, { id = "S08" })

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================

--- Cache for dungeon lookup tables (O(1) access after first call)
--- Key: serialized dungeon names, Value: lookup table
local dungeonLookupCache = {}
local CACHE_MAX_SIZE = 20  -- Prevent unbounded cache growth

--- Serializes dungeon names array to cache key
--- @param dungeonNames table - Array of dungeon names
--- @return string - Cache key
local function serializeDungeonNames(dungeonNames)
  if not dungeonNames or table.getn(dungeonNames) == 0 then
    return ""
  end
  return table.concat(dungeonNames, "|")
end

--- Enforces cache size limit by removing oldest entry (FIFO)
--- Prevents unbounded memory growth from cache accumulation
local function enforceCacheLimit()
  local cacheSize = 0
  for _ in pairs(dungeonLookupCache) do
    cacheSize = cacheSize + 1
  end

  if cacheSize > CACHE_MAX_SIZE then
    -- Remove first entry (oldest) - simple FIFO
    -- Note: Lua pairs() iteration order is undefined, but acceptable for cache eviction
    for key in pairs(dungeonLookupCache) do
      dungeonLookupCache[key] = nil
      break  -- Only remove one entry to stay just under limit
    end
  end
end

--- Checks if a dungeon is visible (not filtered by color)
--- @param index number - Dungeon index to check
--- @return boolean - True if dungeon appears in sorted (filtered) list
local function isDungeonVisible(index)
  if not AutoLFM.Logic.Content.Dungeons or not AutoLFM.Logic.Content.Dungeons.GetSortedDungeons then
    return true  -- If Dungeons module not loaded, assume visible
  end

  local sortedDungeons = AutoLFM.Logic.Content.Dungeons.GetSortedDungeons()
  for i = 1, table.getn(sortedDungeons) do
    if sortedDungeons[i].index == index then
      return true
    end
  end

  return false
end

--- Checks if dungeon is selected by name (O(1) with cached lookup table)
--- Uses closure cache to avoid rebuilding lookup table on every call
--- @param dungeonNames table - Array of selected dungeon names
--- @param name string - Name to check
--- @return boolean - True if dungeon is in array
local function isDungeonSelected(dungeonNames, name)
  if not dungeonNames or table.getn(dungeonNames) == 0 then
    return false
  end

  -- Build cache key from dungeon names
  local cacheKey = serializeDungeonNames(dungeonNames)

  -- Build or reuse cached lookup table
  if not dungeonLookupCache[cacheKey] then
    local lookupMap = {}
    for i = 1, table.getn(dungeonNames) do
      lookupMap[dungeonNames[i]] = true
    end
    dungeonLookupCache[cacheKey] = lookupMap
    enforceCacheLimit()  -- Keep cache size bounded
  end

  return dungeonLookupCache[cacheKey][name] or false
end

--- Removes a dungeon from the array
--- @param dungeonNames table - Array of selected dungeon names
--- @param name string - Name to remove
--- @return table - New array without the name
local function removeDungeon(dungeonNames, name)
  local newNames = {}
  for i = 1, table.getn(dungeonNames) do
    if dungeonNames[i] ~= name then
      table.insert(newNames, dungeonNames[i])
    end
  end
  return newNames
end

--- Sets the selection mode and clears incompatible selections
--- Ensures mutual exclusivity between dungeons, raids, custom, and quests modes
--- @param newMode string - The new mode to switch to ("dungeons", "raid", "custom", "quests", or "none")
local function setSelectionMode(newMode)
  -- Clear all modes except the new one (atomic operation)
  if newMode ~= "dungeons" then
    AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", {})
  end

  if newMode ~= "raid" then
    AutoLFM.Core.Maestro.SetState("Selection.RaidName", nil)
    AutoLFM.Core.Maestro.SetState("Selection.RaidSize", 40)
  end

  if newMode ~= "custom" then
    AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", "")
  end

  -- Set the new mode
  AutoLFM.Core.Maestro.SetState("Selection.Mode", newMode)
end

--=============================================================================
-- COMMANDS - DUNGEONS
--=============================================================================

--- Toggles dungeon selection with FIFO limit
AutoLFM.Core.Maestro.RegisterCommand("Selection.ToggleDungeon", function(index)
  if not index or type(index) ~= "number" then
    AutoLFM.Core.Utils.LogError("Selection.ToggleDungeon: Invalid index type %s (expected number)", type(index))
    return
  end

  -- Verify dungeon exists and get its name
  local dungeon = AutoLFM.Core.Constants.DUNGEONS[index]
  if not dungeon then
    AutoLFM.Core.Utils.LogError("Selection.ToggleDungeon: Dungeon at index %d does not exist (max: %d)", index, table.getn(AutoLFM.Core.Constants.DUNGEONS))
    return
  end

  local dungeonName = dungeon.name

  -- Check if dungeon is visible (not filtered by color)
  if not isDungeonVisible(index) then
    AutoLFM.Core.Utils.LogWarning("Cannot select dungeon: filtered out by color")
    return
  end

  -- Read current state
  local dungeonNames = AutoLFM.Core.Maestro.GetState("Selection.DungeonNames") or {}

  -- Toggle selection
  if isDungeonSelected(dungeonNames, dungeonName) then
    -- Deselect
    dungeonNames = removeDungeon(dungeonNames, dungeonName)
    AutoLFM.Core.Utils.LogAction("Deselected dungeon " .. dungeonName)

    -- If no more dungeons selected, reset mode
    if table.getn(dungeonNames) == 0 then
      setSelectionMode("none")
      AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", dungeonNames)
      AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
      return
    end
  else
    -- Check FIFO limit
    local count = table.getn(dungeonNames)

    if count >= MAX_DUNGEONS then
      -- Remove oldest (first element)
      local oldName = dungeonNames[1]
      table.remove(dungeonNames, 1)
      AutoLFM.Core.Utils.LogInfo("FIFO: Removed dungeon " .. oldName)
    end

    -- Select new
    table.insert(dungeonNames, dungeonName)
    AutoLFM.Core.Utils.LogAction("Selected dungeon " .. dungeonName)
  end

  -- Update states and ensure dungeons mode is active
  AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", dungeonNames)
  setSelectionMode("dungeons")

  -- Emit event
  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C03" })

--- Clears all dungeon selections
AutoLFM.Core.Maestro.RegisterCommand("Selection.ClearDungeons", function()
  local dungeonNames = AutoLFM.Core.Maestro.GetState("Selection.DungeonNames") or {}

  if table.getn(dungeonNames) == 0 then
    return  -- Nothing to clear
  end

  local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")

  if mode == "dungeons" then
    mode = "none"
    AutoLFM.Core.Maestro.SetState("Selection.Mode", mode)
  end

  AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", {})
  AutoLFM.Core.Utils.LogAction("Cleared all dungeons")

  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C11" })

--=============================================================================
-- COMMANDS - RAIDS
--=============================================================================

--- Toggles raid selection (exclusive with dungeons)
AutoLFM.Core.Maestro.RegisterCommand("Selection.ToggleRaid", function(index)
  if not index or type(index) ~= "number" then
    AutoLFM.Core.Utils.LogError("Selection.ToggleRaid: Invalid index type %s (expected number)", type(index))
    return
  end

  -- Verify raid exists and get its name
  local raid = AutoLFM.Core.Constants.RAIDS[index]
  if not raid then
    AutoLFM.Core.Utils.LogError("Selection.ToggleRaid: Raid at index %d does not exist (max: %d)", index, table.getn(AutoLFM.Core.Constants.RAIDS))
    return
  end

  local raidName = raid.name

  -- Read current state
  local selectedRaidName = AutoLFM.Core.Maestro.GetState("Selection.RaidName")

  -- Toggle selection
  if selectedRaidName == raidName then
    -- Deselect: clear raid and switch to none mode
    setSelectionMode("none")
    AutoLFM.Core.Utils.LogAction("Deselected raid " .. raidName)
  else
    -- Select: clear other modes and set raid
    setSelectionMode("raid")
    -- Use minimum raid size as default (will be adjusted by SetRaidSize if needed)
    local raidSize = raid.raidSizeMin or 40

    AutoLFM.Core.Maestro.SetState("Selection.RaidName", raidName)
    AutoLFM.Core.Maestro.SetState("Selection.RaidSize", raidSize)

    AutoLFM.Core.Utils.LogAction("Selected raid " .. raidName .. " (size: " .. raidSize .. ")")
  end

  -- Emit event
  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C04" })

--- Sets custom raid size
--- @param size number - The new raid size
--- @param silent boolean - If true, don't dispatch Selection.Changed event (for slider dragging)
AutoLFM.Core.Maestro.RegisterCommand("Selection.SetRaidSize", function(size, silent)
  local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")
  local selectedRaidName = AutoLFM.Core.Maestro.GetState("Selection.RaidName")

  if mode ~= "raid" or not selectedRaidName then
    AutoLFM.Core.Utils.LogWarning("Cannot set raid size: no raid selected")
    return
  end

  local newSize = tonumber(size)
  if not newSize then
    AutoLFM.Core.Utils.LogError("Selection.SetRaidSize: Invalid size value %s (expected number)", tostring(size))
    return
  end

  -- Find the selected raid by name to get its size bounds
  local raid = nil
  for i = 1, table.getn(AutoLFM.Core.Constants.RAIDS) do
    if AutoLFM.Core.Constants.RAIDS[i].name == selectedRaidName then
      raid = AutoLFM.Core.Constants.RAIDS[i]
      break
    end
  end

  if not raid then
    AutoLFM.Core.Utils.LogError("Selection.SetRaidSize: Selected raid '%s' not found in raid database", tostring(selectedRaidName))
    return
  end

  -- Clamp between raid's min/max size
  if newSize < raid.raidSizeMin then newSize = raid.raidSizeMin end
  if newSize > raid.raidSizeMax then newSize = raid.raidSizeMax end

  local oldSize = AutoLFM.Core.Maestro.GetState("Selection.RaidSize") or 40
  AutoLFM.Core.Maestro.SetState("Selection.RaidSize", newSize)
  
  if oldSize ~= newSize then
    AutoLFM.Core.Utils.LogAction("Set raid size to " .. newSize)
  end

  -- Emit event only if not silent
  if not silent then
    AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
  end
end, { id = "C05" })

--- Clears raid selection
AutoLFM.Core.Maestro.RegisterCommand("Selection.ClearRaid", function()
  local selectedRaidName = AutoLFM.Core.Maestro.GetState("Selection.RaidName")

  if not selectedRaidName then
    return  -- Nothing to clear
  end

  local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")

  if mode == "raid" then
    AutoLFM.Core.Maestro.SetState("Selection.Mode", "none")
  end

  AutoLFM.Core.Maestro.SetState("Selection.RaidName", nil)
  AutoLFM.Core.Maestro.SetState("Selection.RaidSize", 40)

  AutoLFM.Core.Utils.LogAction("Cleared raid")

  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C12" })

--=============================================================================
-- COMMANDS - ROLES
--=============================================================================

--- Toggles role selection
AutoLFM.Core.Maestro.RegisterCommand("Selection.ToggleRole", function(role)
  if not role or type(role) ~= "string" then
    AutoLFM.Core.Utils.LogError("Selection.ToggleRole: Invalid role type %s (expected string)", type(role))
    return
  end

  -- Validate role
  local validRoles = { TANK = true, HEAL = true, DPS = true }
  if not validRoles[role] then
    AutoLFM.Core.Utils.LogError("Selection.ToggleRole: Invalid role '%s' (valid: TANK, HEAL, DPS)", role)
    return
  end

  -- Read current roles
  local selectedRoles = AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}

  -- Toggle role
  local found = false
  local newRoles = {}

  for i = 1, table.getn(selectedRoles) do
    if selectedRoles[i] == role then
      found = true
      -- Don't add to newRoles (remove it)
    else
      table.insert(newRoles, selectedRoles[i])
    end
  end

  if found then
    AutoLFM.Core.Utils.LogAction("Deselected role " .. role)
  else
    table.insert(newRoles, role)
    AutoLFM.Core.Utils.LogAction("Selected role " .. role)
  end

  -- Update state
  AutoLFM.Core.Maestro.SetState("Selection.Roles", newRoles)

  -- Emit event
  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C06" })

--- Clears all role selections
AutoLFM.Core.Maestro.RegisterCommand("Selection.ClearRoles", function()
  local selectedRoles = AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}

  if table.getn(selectedRoles) == 0 then
    return  -- Nothing to clear
  end

  AutoLFM.Core.Maestro.SetState("Selection.Roles", {})
  AutoLFM.Core.Utils.LogAction("Cleared all roles")

  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C07" })

--=============================================================================
-- COMMANDS - CUSTOM MESSAGE
--=============================================================================

--- Sets custom message (clears dungeons/raids)
AutoLFM.Core.Maestro.RegisterCommand("Selection.SetCustomMessage", function(text)
  if not text then
    text = ""
  end

  -- If non-empty, switch to custom mode
  if text ~= "" then
    setSelectionMode("custom")
    AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", text)
    AutoLFM.Core.Utils.LogAction("Set custom message")
  else
    -- If empty, clear custom mode
    setSelectionMode("none")
    AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", "")
  end

  -- Emit event
  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C08" })

--- Clears custom message
AutoLFM.Core.Maestro.RegisterCommand("Selection.ClearCustomMessage", function()
  local customMessage = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage")

  if customMessage == "" then
    return  -- Nothing to clear
  end

  setSelectionMode("none")
  AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", "")
  AutoLFM.Core.Utils.LogAction("Cleared custom message")

  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C09" })

--- Sets custom group size for custom messages with variables
AutoLFM.Core.Maestro.RegisterCommand("Selection.SetCustomGroupSize", function(size)
  local newSize = tonumber(size)
  if not newSize then
    AutoLFM.Core.Utils.LogError("SetCustomGroupSize: invalid size")
    return
  end

  if newSize < 1 then newSize = 1 end
  if newSize > AutoLFM.Core.Constants.MAX_GROUP_SIZE then newSize = AutoLFM.Core.Constants.MAX_GROUP_SIZE end

  local oldSize = AutoLFM.Core.Maestro.GetState("Selection.CustomGroupSize") or 5
  if oldSize == newSize then return end

  AutoLFM.Core.Maestro.SetState("Selection.CustomGroupSize", newSize)
  AutoLFM.Core.Utils.LogAction("Set custom group size to " .. newSize)

  local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")
  local customMessage = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage") or ""
  if mode == "custom" and customMessage ~= "" then
    AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
  end
end, { id = "C10" })

--- Sets details text (appended to auto-generated message in details mode)
AutoLFM.Core.Maestro.RegisterCommand("Selection.SetDetailsText", function(text)
  if not text then
    text = ""
  end

  AutoLFM.Core.Maestro.SetState("Selection.DetailsText", text)

  -- Emit event to rebuild message
  -- In dungeons/raid mode: appends to auto-generated message
  -- In "none" mode: displays details text alone
  -- In custom mode: no effect (custom message is independent)
  local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")
  if mode ~= "custom" then
    AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
  end
end, { id = "C13" })

--=============================================================================
-- COMMANDS - GLOBAL
--=============================================================================

--- Checks if there are any selections to clear
--- @return boolean - True if there are any active selections
function AutoLFM.Logic.Selection.HasSelections()
  local dungeonNames = AutoLFM.Core.Maestro.GetState("Selection.DungeonNames") or {}
  local raidName = AutoLFM.Core.Maestro.GetState("Selection.RaidName")
  local roles = AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}
  local customMessage = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage") or ""
  local detailsText = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""

  return table.getn(dungeonNames) > 0
    or raidName ~= nil
    or table.getn(roles) > 0
    or customMessage ~= ""
    or detailsText ~= ""
end

--- Clears all selections (dungeons, raids, roles, custom, details text, group size)
--- NOTE: Does NOT clear channels and intervals
AutoLFM.Core.Maestro.RegisterCommand("Selection.ClearAll", function()
  AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", {})
  AutoLFM.Core.Maestro.SetState("Selection.RaidName", nil)
  AutoLFM.Core.Maestro.SetState("Selection.RaidSize", 40)
  AutoLFM.Core.Maestro.SetState("Selection.Roles", {})
  AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", "")
  AutoLFM.Core.Maestro.SetState("Selection.DetailsText", "")
  AutoLFM.Core.Maestro.SetState("Selection.CustomGroupSize", 5)
  AutoLFM.Core.Maestro.SetState("Selection.Mode", "none")

  AutoLFM.Core.Utils.LogAction("Cleared all selections")

  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C14" })

--=============================================================================
-- EVENT DECLARATIONS
--=============================================================================
AutoLFM.Core.Maestro.RegisterEvent("Selection.Changed", { id = "E01" })

--=============================================================================
-- INITIALIZATION
--=============================================================================
AutoLFM.Core.SafeRegisterInit("Logic.Selection", function()
  -- Clear the dungeon lookup cache whenever selection changes
  AutoLFM.Core.Maestro.Listen(
    "Selection.CacheInvalidation",
    "Selection.Changed",
    function()
      dungeonLookupCache = {}
    end,
    { id = "L02" }
  )
end, { id = "I05" })
