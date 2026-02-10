--=============================================================================
-- AutoLFM: Presets Logic
--   Save, load, and manage preset configurations
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Content = AutoLFM.Logic.Content or {}
AutoLFM.Logic.Content.Presets = {}

--=============================================================================
-- PRESET VALIDATION SCHEMA
--=============================================================================

--- Validation schema for preset fields
--- Each field defines: type, optional validator function, and whether to use default on invalid
local PRESET_SCHEMA = {
  dungeonNames = {
    type = "table",
    validator = function(value)
      for i = 1, table.getn(value) do
        if type(value[i]) ~= "string" then
          return false, "dungeonNames[" .. i .. "] must be a string"
        end
      end
      return true
    end
  },
  raidName = {
    type = "string",
    nullable = true
  },
  raidSize = {
    type = "number",
    validator = function(value)
      local min = AutoLFM.Core.Constants.PRESET_RAID_SIZE_MIN or 10
      local max = AutoLFM.Core.Constants.PRESET_RAID_SIZE_MAX or 40
      if value < min or value > max then
        return false, "raidSize must be between " .. min .. " and " .. max
      end
      return true
    end
  },
  roles = {
    type = "table",
    validator = function(value)
      local validRoles = AutoLFM.Core.Constants.VALID_ROLES or { TANK = true, HEAL = true, DPS = true }
      for i = 1, table.getn(value) do
        local role = value[i]
        if type(role) ~= "string" or not validRoles[role] then
          return false, "roles[" .. i .. "] must be TANK, HEAL, or DPS"
        end
      end
      return true
    end
  },
  customMessage = {
    type = "string"
  },
  detailsText = {
    type = "string"
  },
  customGroupSize = {
    type = "number",
    validator = function(value)
      local min = AutoLFM.Core.Constants.PRESET_GROUP_SIZE_MIN or 1
      local max = AutoLFM.Core.Constants.PRESET_GROUP_SIZE_MAX or 40
      if value < min or value > max then
        return false, "customGroupSize must be between " .. min .. " and " .. max
      end
      return true
    end
  },
  activeChannels = {
    type = "table",
    validator = function(value)
      for i = 1, table.getn(value) do
        if type(value[i]) ~= "string" then
          return false, "activeChannels[" .. i .. "] must be a string"
        end
      end
      return true
    end
  },
  broadcastInterval = {
    type = "number",
    validator = function(value)
      local min = AutoLFM.Core.Constants.MIN_BROADCAST_INTERVAL or 30
      local max = AutoLFM.Core.Constants.MAX_BROADCAST_INTERVAL or 120
      if value < min or value > max then
        return false, "broadcastInterval must be between " .. min .. " and " .. max
      end
      return true
    end
  }
}

--=============================================================================
-- PRESET VALIDATION
--=============================================================================

--- Validates a single field against its schema definition
--- @param fieldName string - Name of the field being validated
--- @param value any - Value to validate
--- @param schema table - Schema definition for the field
--- @return boolean, string - true if valid, false + error message if not
local function validateField(fieldName, value, schema)
  -- Check if field is nil/missing
  if value == nil then
    if schema.nullable then
      return true, ""
    end
    -- Missing fields will use defaults, not an error
    return true, ""
  end

  -- Check type
  if type(value) ~= schema.type then
    return false, fieldName .. " must be a " .. schema.type .. ", got " .. type(value)
  end

  -- Run custom validator if present
  if schema.validator then
    local isValid, err = schema.validator(value)
    if not isValid then
      return false, err or (fieldName .. " failed validation")
    end
  end

  return true, ""
end

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

  -- Validate each field against schema
  for fieldName, schema in pairs(PRESET_SCHEMA) do
    local isValid, err = validateField(fieldName, presetData[fieldName], schema)
    if not isValid then
      return false, err
    end
  end

  return true, ""
end

--- Sanitizes preset data by applying defaults for missing or invalid fields
--- This allows loading partially corrupted presets with best-effort recovery
--- @param presetData table - The preset data to sanitize
--- @return table - Sanitized preset data with defaults applied
local function sanitizePresetData(presetData)
  if not presetData or type(presetData) ~= "table" then
    -- Return complete defaults if data is completely invalid
    local defaults = AutoLFM.Core.Constants.PRESET_DEFAULTS
    local result = {}
    for k, v in pairs(defaults) do
      if type(v) == "table" then
        result[k] = {}
        for i = 1, table.getn(v) do
          result[k][i] = v[i]
        end
      else
        result[k] = v
      end
    end
    return result
  end

  local defaults = AutoLFM.Core.Constants.PRESET_DEFAULTS
  local sanitized = {}

  -- Process each field in schema
  for fieldName, schema in pairs(PRESET_SCHEMA) do
    local value = presetData[fieldName]
    local defaultValue = defaults[fieldName]

    -- Check if value is valid
    local isValid = true
    if value ~= nil then
      if type(value) ~= schema.type then
        isValid = false
      elseif schema.validator then
        isValid = schema.validator(value)
      end
    end

    -- Use value if valid, otherwise use default
    if isValid and value ~= nil then
      -- Deep copy tables to avoid reference issues
      if type(value) == "table" then
        sanitized[fieldName] = {}
        for i = 1, table.getn(value) do
          sanitized[fieldName][i] = value[i]
        end
      else
        sanitized[fieldName] = value
      end
    else
      -- Apply default
      if type(defaultValue) == "table" then
        sanitized[fieldName] = {}
        for i = 1, table.getn(defaultValue) do
          sanitized[fieldName][i] = defaultValue[i]
        end
      else
        sanitized[fieldName] = defaultValue
      end

      if value ~= nil then
        AutoLFM.Core.Utils.LogWarning("Preset field '" .. fieldName .. "' was invalid, using default")
      end
    end
  end

  return sanitized
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

  -- Restore dungeon names (filter out any that no longer exist)
  if presetData.dungeonNames and table.getn(presetData.dungeonNames) > 0 then
    local validNames = {}
    for i = 1, table.getn(presetData.dungeonNames) do
      if AutoLFM.Core.Utils.GetDungeonIndexByName(presetData.dungeonNames[i]) then
        table.insert(validNames, presetData.dungeonNames[i])
      end
    end
    if table.getn(validNames) > 0 then
      AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", validNames)
      AutoLFM.Core.Maestro.SetState("Selection.Mode", "dungeons")
    end
  end

  -- Restore raid (validate it still exists)
  if presetData.raidName then
    if AutoLFM.Core.Utils.GetRaidIndexByName(presetData.raidName) then
      AutoLFM.Core.Maestro.SetState("Selection.RaidName", presetData.raidName)
      AutoLFM.Core.Maestro.SetState("Selection.RaidSize", presetData.raidSize or 40)
      AutoLFM.Core.Maestro.SetState("Selection.Mode", "raid")
    end
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
--- Uses sanitization to recover from partially corrupted presets
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

  -- If validation fails, try to sanitize and recover
  local dataToLoad = presetData
  if not isValid then
    AutoLFM.Core.Utils.LogWarning("Presets.Load: Preset '%s' has issues: %s - attempting recovery", presetName, validationError)
    AutoLFM.Core.Utils.PrintWarning("Preset '" .. presetName .. "' was partially corrupted, loading with defaults for invalid fields")
    dataToLoad = sanitizePresetData(presetData)
  end

  -- Restore state
  restorePresetState(dataToLoad)
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
