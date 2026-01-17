--=============================================================================
-- AutoLFM: Presets Logic
--   Save, load, and manage preset configurations
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Content = AutoLFM.Logic.Content or {}
AutoLFM.Logic.Content.Presets = {}

--=============================================================================
-- PRESET VALIDATION
--=============================================================================

--- Validates preset data structure before loading
--- Ensures all required fields exist and have correct types
--- @param presetData table - The preset data to validate
--- @return boolean, string - true if valid, false + error message if not
local function validatePresetData(presetData)
  if not presetData then
    return false, "Preset data is nil"
  end

  if type(presetData) ~= "table" then
    return false, "Preset data is not a table"
  end

  -- Validate dungeonNames (optional, but must be array if present)
  if presetData.dungeonNames then
    if type(presetData.dungeonNames) ~= "table" then
      return false, "dungeonNames must be a table"
    end
    -- Validate each dungeon name is a string
    for i = 1, table.getn(presetData.dungeonNames) do
      if type(presetData.dungeonNames[i]) ~= "string" then
        return false, "dungeonNames[" .. i .. "] must be a string"
      end
    end
  end

  -- Validate raidName (optional, but must be string if present)
  if presetData.raidName and type(presetData.raidName) ~= "string" then
    return false, "raidName must be a string"
  end

  -- Validate raidSize (optional, but must be number in valid range if present)
  if presetData.raidSize then
    if type(presetData.raidSize) ~= "number" then
      return false, "raidSize must be a number"
    end
    if presetData.raidSize < 10 or presetData.raidSize > 40 then
      return false, "raidSize must be between 10 and 40"
    end
  end

  -- Validate roles (optional, but must be array of valid role strings if present)
  if presetData.roles then
    if type(presetData.roles) ~= "table" then
      return false, "roles must be a table"
    end
    local validRoles = { TANK = true, HEAL = true, DPS = true }
    for i = 1, table.getn(presetData.roles) do
      local role = presetData.roles[i]
      if type(role) ~= "string" or not validRoles[role] then
        return false, "roles[" .. i .. "] must be TANK, HEAL, or DPS"
      end
    end
  end

  -- Validate customMessage (optional, but must be string if present)
  if presetData.customMessage and type(presetData.customMessage) ~= "string" then
    return false, "customMessage must be a string"
  end

  -- Validate detailsText (optional, but must be string if present)
  if presetData.detailsText and type(presetData.detailsText) ~= "string" then
    return false, "detailsText must be a string"
  end

  -- Validate customGroupSize (optional, but must be number in valid range if present)
  if presetData.customGroupSize then
    if type(presetData.customGroupSize) ~= "number" then
      return false, "customGroupSize must be a number"
    end
    if presetData.customGroupSize < 1 or presetData.customGroupSize > 40 then
      return false, "customGroupSize must be between 1 and 40"
    end
  end

  -- Validate activeChannels (optional, but must be array of strings if present)
  if presetData.activeChannels then
    if type(presetData.activeChannels) ~= "table" then
      return false, "activeChannels must be a table"
    end
    for i = 1, table.getn(presetData.activeChannels) do
      if type(presetData.activeChannels[i]) ~= "string" then
        return false, "activeChannels[" .. i .. "] must be a string"
      end
    end
  end

  -- Validate broadcastInterval (optional, but must be number in valid range if present)
  if presetData.broadcastInterval then
    if type(presetData.broadcastInterval) ~= "number" then
      return false, "broadcastInterval must be a number"
    end
    local minInterval = AutoLFM.Core.Constants.MIN_BROADCAST_INTERVAL or 30
    local maxInterval = AutoLFM.Core.Constants.MAX_BROADCAST_INTERVAL or 120
    if presetData.broadcastInterval < minInterval or presetData.broadcastInterval > maxInterval then
      return false, "broadcastInterval must be between " .. minInterval .. " and " .. maxInterval
    end
  end

  return true, ""
end

--=============================================================================
-- PRESET STATE CAPTURE AND RESTORE
--=============================================================================

--- Captures current state from Maestro for saving as preset
--- @return table - Current state data
local function captureCurrentState()
  local state = {}

  -- Capture selection states
  state.dungeonNames = AutoLFM.Core.Maestro.GetState("Selection.DungeonNames") or {}
  state.raidName = AutoLFM.Core.Maestro.GetState("Selection.RaidName")
  state.raidSize = AutoLFM.Core.Maestro.GetState("Selection.RaidSize") or 40
  state.roles = AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}
  state.customMessage = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage") or ""
  state.detailsText = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""
  state.customGroupSize = AutoLFM.Core.Maestro.GetState("Selection.CustomGroupSize") or 5

  -- Capture channels and interval
  state.activeChannels = AutoLFM.Core.Maestro.GetState("Channels.ActiveChannels") or {}
  state.broadcastInterval = AutoLFM.Core.Maestro.GetState("Broadcaster.Interval") or 60

  -- Deep copy arrays to avoid reference issues
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.DeepCopy then
    state.dungeonNames = AutoLFM.Core.Storage.DeepCopy(state.dungeonNames)
    state.roles = AutoLFM.Core.Storage.DeepCopy(state.roles)
    state.activeChannels = AutoLFM.Core.Storage.DeepCopy(state.activeChannels)
  end

  return state
end

--- Restores state from preset data to Maestro states
--- @param presetData table - Preset data to restore
local function restorePresetState(presetData)
  if not presetData then return end

  -- Clear current selections first
  AutoLFM.Core.Maestro.Dispatch("Selection.ClearAll")

  -- Restore dungeon names
  if presetData.dungeonNames and table.getn(presetData.dungeonNames) > 0 then
    AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", presetData.dungeonNames)
    AutoLFM.Core.Maestro.SetState("Selection.Mode", "dungeons")
  end

  -- Restore raid
  if presetData.raidName then
    AutoLFM.Core.Maestro.SetState("Selection.RaidName", presetData.raidName)
    AutoLFM.Core.Maestro.SetState("Selection.RaidSize", presetData.raidSize or 40)
    AutoLFM.Core.Maestro.SetState("Selection.Mode", "raid")
  end

  -- Restore roles
  if presetData.roles then
    AutoLFM.Core.Maestro.SetState("Selection.Roles", presetData.roles)
  end

  -- Restore custom message
  if presetData.customMessage and presetData.customMessage ~= "" then
    AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", presetData.customMessage)
    AutoLFM.Core.Maestro.SetState("Selection.Mode", "custom")
    -- Switch to custom mode in Messaging UI
    if AutoLFM.UI and AutoLFM.UI.Content and AutoLFM.UI.Content.Messaging then
      AutoLFM.UI.Content.Messaging.OnModeRadioClick("custom")
    end
  end

  -- Restore details text
  if presetData.detailsText then
    AutoLFM.Core.Maestro.SetState("Selection.DetailsText", presetData.detailsText)
    -- Switch to details mode in Messaging UI if no custom message
    if (not presetData.customMessage or presetData.customMessage == "") and AutoLFM.UI and AutoLFM.UI.Content and AutoLFM.UI.Content.Messaging then
      AutoLFM.UI.Content.Messaging.OnModeRadioClick("details")
    end
  end

  -- Restore custom group size
  if presetData.customGroupSize then
    AutoLFM.Core.Maestro.SetState("Selection.CustomGroupSize", presetData.customGroupSize)
  end

  -- Restore channels
  if presetData.activeChannels then
    AutoLFM.Core.Maestro.SetState("Channels.ActiveChannels", presetData.activeChannels)
  end

  -- Restore broadcast interval
  if presetData.broadcastInterval then
    AutoLFM.Core.Maestro.SetState("Broadcaster.Interval", presetData.broadcastInterval)
  end

  -- Notify that selection changed
  AutoLFM.Core.Maestro.Dispatch("Selection.Changed")
end

--=============================================================================
-- COMMANDS
--=============================================================================

--- Saves current state as a preset
AutoLFM.Core.Maestro.RegisterCommand("Presets.Save", function(presetName)
  if not presetName or presetName == "" then
    AutoLFM.Core.Utils.LogError("Presets.Save: Preset name cannot be empty")
    return
  end

  -- Check if preset already exists
  if AutoLFM.Core.Storage.PresetExists(presetName) then
    AutoLFM.Core.Utils.LogWarning("Presets.Save: Preset '%s' already exists, use Rename to overwrite", presetName)
    return
  end

  -- Capture current state
  local currentState = captureCurrentState()

  -- Save preset
  local success = AutoLFM.Core.Storage.SavePreset(presetName, currentState)

  if success then
    AutoLFM.Core.Utils.LogAction("Preset saved: " .. presetName)
    AutoLFM.Core.Maestro.Dispatch("Presets.Changed")
  else
    AutoLFM.Core.Utils.LogError("Presets.Save: Failed to save preset '%s' to storage", presetName)
  end
end, { id = "C19" })

--- Loads a preset and restores its state
AutoLFM.Core.Maestro.RegisterCommand("Presets.Load", function(presetName)
  if not presetName or presetName == "" then
    AutoLFM.Core.Utils.LogError("Presets.Load: Preset name cannot be empty")
    return
  end

  -- Get preset data
  local presets = AutoLFM.Core.Storage.GetPresets()
  local presetData = presets.data[presetName]

  if not presetData then
    AutoLFM.Core.Utils.LogError("Presets.Load: Preset '%s' not found (available: %d presets)", presetName, table.getn(presets.data))
    return
  end

  -- Validate preset data before loading
  local isValid, validationError = validatePresetData(presetData)
  if not isValid then
    AutoLFM.Core.Utils.LogError("Presets.Load: Invalid preset data for '%s': %s", presetName, validationError)
    AutoLFM.Core.Utils.PrintError("Preset '" .. presetName .. "' is corrupted: " .. validationError)
    return
  end

  -- Restore state
  restorePresetState(presetData)
  AutoLFM.Core.Utils.LogAction("Preset loaded: " .. presetName)
  AutoLFM.Core.Maestro.Dispatch("Presets.Loaded", presetName)
end, { id = "C18" })

--- Deletes a preset
AutoLFM.Core.Maestro.RegisterCommand("Presets.Delete", function(presetName)
  if not presetName or presetName == "" then
    AutoLFM.Core.Utils.LogError("Presets.Delete: Preset name cannot be empty")
    return
  end

  local success = AutoLFM.Core.Storage.DeletePreset(presetName)

  if success then
    AutoLFM.Core.Utils.LogAction("Preset deleted: " .. presetName)
    AutoLFM.Core.Maestro.Dispatch("Presets.Changed")
  else
    AutoLFM.Core.Utils.LogError("Presets.Delete: Failed to delete preset '%s' from storage", presetName)
  end
end, { id = "C17" })

--=============================================================================
-- EVENTS
--=============================================================================
AutoLFM.Core.Maestro.RegisterEvent("Presets.Changed", { id = "E05" })
AutoLFM.Core.Maestro.RegisterEvent("Presets.Loaded", { id = "E06" })

--=============================================================================
-- INITIALIZATION
--=============================================================================
AutoLFM.Core.SafeRegisterInit("Logic.Content.Presets", function()
end, {
  id = "I12",
  dependencies = { "Core.Storage", "Logic.Selection" }
})
