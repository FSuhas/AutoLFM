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
AutoLFM.Core.SafeRegisterState("Selection.DungeonNames", {}, { id = "S02" })
AutoLFM.Core.SafeRegisterState("Selection.RaidName", nil, { id = "S03" })
AutoLFM.Core.SafeRegisterState("Selection.RaidSize", 40, { id = "S04" })
AutoLFM.Core.SafeRegisterState("Selection.Roles", {}, { id = "S05" })
AutoLFM.Core.SafeRegisterState("Selection.CustomMessage", "", { id = "S06" })
AutoLFM.Core.SafeRegisterState("Selection.CustomGroupSize", 5, { id = "S07" })
AutoLFM.Core.SafeRegisterState("Selection.DetailsText", "", { id = "S08" })

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================

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

--- Checks if dungeon is selected by name
--- @param dungeonNames table - Array of selected dungeon names
--- @param name string - Name to check
--- @return boolean - True if dungeon is in array
local function isDungeonSelected(dungeonNames, name)
  for i = 1, table.getn(dungeonNames) do
    if dungeonNames[i] == name then
      return true
    end
  end
  return false
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

--=============================================================================
-- COMMANDS - DUNGEONS
--=============================================================================

--- Toggles dungeon selection with FIFO limit
AutoLFM.Core.Maestro.RegisterCommand("Selection.ToggleDungeon", function(index)
  if not index or type(index) ~= "number" then
    AutoLFM.Core.Utils.LogError("ToggleDungeon: invalid index")
    return
  end

  -- Verify dungeon exists and get its name
  local dungeon = AutoLFM.Core.Constants.DUNGEONS[index]
  if not dungeon then
    AutoLFM.Core.Utils.LogError("ToggleDungeon: dungeon " .. index .. " does not exist")
    return
  end

  local dungeonName = dungeon.name

  -- Check if dungeon is visible (not filtered by color)
  if not isDungeonVisible(index) then
    AutoLFM.Core.Utils.LogWarning("Cannot select dungeon: filtered out by color")
    return
  end

  -- Read current state
  local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")
  local dungeonNames = AutoLFM.Core.Maestro.GetState("Selection.DungeonNames") or {}

  -- Switch from custom/raid to dungeons mode
  if mode == "custom" then
    AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", "")
    mode = "dungeons"
  elseif mode == "raid" then
    AutoLFM.Core.Maestro.SetState("Selection.RaidName", nil)
    AutoLFM.Core.Maestro.SetState("Selection.RaidSize", 40)
    mode = "dungeons"
  end

  -- Toggle selection
  if isDungeonSelected(dungeonNames, dungeonName) then
    -- Deselect
    dungeonNames = removeDungeon(dungeonNames, dungeonName)
    AutoLFM.Core.Utils.LogAction("Deselected dungeon " .. dungeonName)

    -- If no more dungeons selected, reset mode
    if table.getn(dungeonNames) == 0 then
      mode = "none"
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
    mode = "dungeons"
    AutoLFM.Core.Utils.LogAction("Selected dungeon " .. dungeonName)
  end

  -- Update states
  AutoLFM.Core.Maestro.SetState("Selection.Mode", mode)
  AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", dungeonNames)

  -- Emit event
  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C06" })

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
end, { id = "C06" })

--=============================================================================
-- COMMANDS - RAIDS
--=============================================================================

--- Toggles raid selection (exclusive with dungeons)
AutoLFM.Core.Maestro.RegisterCommand("Selection.ToggleRaid", function(index)
  if not index or type(index) ~= "number" then
    AutoLFM.Core.Utils.LogError("ToggleRaid: invalid index")
    return
  end

  -- Verify raid exists and get its name
  local raid = AutoLFM.Core.Constants.RAIDS[index]
  if not raid then
    AutoLFM.Core.Utils.LogError("ToggleRaid: raid " .. index .. " does not exist")
    return
  end

  local raidName = raid.name

  -- Read current state
  local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")
  local selectedRaidName = AutoLFM.Core.Maestro.GetState("Selection.RaidName")

  -- Switch from custom/dungeons to raid mode
  if mode == "custom" then
    AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", "")
  elseif mode == "dungeons" then
    AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", {})
  end

  -- Toggle selection
  if selectedRaidName == raidName then
    -- Deselect
    AutoLFM.Core.Maestro.SetState("Selection.RaidName", nil)
    AutoLFM.Core.Maestro.SetState("Selection.RaidSize", 40)
    AutoLFM.Core.Maestro.SetState("Selection.Mode", "none")
    AutoLFM.Core.Utils.LogAction("Deselected raid " .. raidName)
  else
    -- Select
    -- Use minimum raid size as default (will be adjusted by SetRaidSize if needed)
    local raidSize = raid.raidSizeMin or 40

    AutoLFM.Core.Maestro.SetState("Selection.RaidName", raidName)
    AutoLFM.Core.Maestro.SetState("Selection.RaidSize", raidSize)
    AutoLFM.Core.Maestro.SetState("Selection.Mode", "raid")

    AutoLFM.Core.Utils.LogAction("Selected raid " .. raidName .. " (size: " .. raidSize .. ")")
  end

  -- Emit event
  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C07" })

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
    AutoLFM.Core.Utils.LogError("SetRaidSize: invalid size")
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
    AutoLFM.Core.Utils.LogError("SetRaidSize: raid '" .. selectedRaidName .. "' does not exist")
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
end, { id = "C08" })

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
end, { id = "C07" })

--=============================================================================
-- COMMANDS - ROLES
--=============================================================================

--- Toggles role selection
AutoLFM.Core.Maestro.RegisterCommand("Selection.ToggleRole", function(role)
  if not role or type(role) ~= "string" then
    AutoLFM.Core.Utils.LogError("ToggleRole: invalid role")
    return
  end

  -- Validate role
  local validRoles = { TANK = true, HEAL = true, DPS = true }
  if not validRoles[role] then
    AutoLFM.Core.Utils.LogError("ToggleRole: invalid role '" .. role .. "'")
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
end, { id = "C09" })

--- Clears all role selections
AutoLFM.Core.Maestro.RegisterCommand("Selection.ClearRoles", function()
  local selectedRoles = AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}

  if table.getn(selectedRoles) == 0 then
    return  -- Nothing to clear
  end

  AutoLFM.Core.Maestro.SetState("Selection.Roles", {})
  AutoLFM.Core.Utils.LogAction("Cleared all roles")

  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C09" })

--=============================================================================
-- COMMANDS - CUSTOM MESSAGE
--=============================================================================

--- Sets custom message (clears dungeons/raids)
AutoLFM.Core.Maestro.RegisterCommand("Selection.SetCustomMessage", function(text)
  if not text then
    text = ""
  end

  local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")

  -- If non-empty, switch to custom mode
  if text ~= "" then
    if mode == "dungeons" then
      AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", {})
    elseif mode == "raid" then
      AutoLFM.Core.Maestro.SetState("Selection.RaidName", nil)
      AutoLFM.Core.Maestro.SetState("Selection.RaidSize", 40)
    end

    AutoLFM.Core.Maestro.SetState("Selection.Mode", "custom")
    AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", text)
    AutoLFM.Core.Utils.LogAction("Set custom message")
  else
    -- If empty, clear custom mode
    if mode == "custom" then
      AutoLFM.Core.Maestro.SetState("Selection.Mode", "none")
    end
    AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", "")
  end

  -- Emit event
  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C10" })

--- Clears custom message
AutoLFM.Core.Maestro.RegisterCommand("Selection.ClearCustomMessage", function()
  local customMessage = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage")

  if customMessage == "" then
    return  -- Nothing to clear
  end

  local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")

  if mode == "custom" then
    AutoLFM.Core.Maestro.SetState("Selection.Mode", "none")
  end

  AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", "")
  AutoLFM.Core.Utils.LogAction("Cleared custom message")

  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end, { id = "C11" })

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
end, { id = "C12" })

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
end, { id = "C17" })

--=============================================================================
-- EVENT DECLARATIONS
--=============================================================================
AutoLFM.Core.Maestro.RegisterEvent("Selection.Changed", { id = "E01" })

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("Logic.Selection", function()
end, { id = "I12" })
