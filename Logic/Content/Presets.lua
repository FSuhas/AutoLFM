--=============================================================================
-- AutoLFM: Presets Logic
--   Save, load, and manage preset configurations
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Content = AutoLFM.Logic.Content or {}
AutoLFM.Logic.Content.Presets = {}

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
    AutoLFM.Core.Utils.LogError("Preset name cannot be empty")
    return
  end

  -- Check if preset already exists
  if AutoLFM.Core.Storage.PresetExists(presetName) then
    AutoLFM.Core.Utils.LogWarning("Preset '" .. presetName .. "' already exists")
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
    AutoLFM.Core.Utils.LogError("Failed to save preset")
  end
end, { id = "C28" })

--- Loads a preset and restores its state
AutoLFM.Core.Maestro.RegisterCommand("Presets.Load", function(presetName)
  if not presetName or presetName == "" then
    AutoLFM.Core.Utils.LogError("Preset name cannot be empty")
    return
  end

  -- Get preset data
  local presets = AutoLFM.Core.Storage.GetPresets()
  local presetData = presets.data[presetName]

  if not presetData then
    AutoLFM.Core.Utils.LogError("Preset not found: " .. presetName)
    return
  end

  -- Restore state
  restorePresetState(presetData)
  AutoLFM.Core.Utils.LogAction("Preset loaded: " .. presetName)
  AutoLFM.Core.Maestro.Dispatch("Presets.Loaded", presetName)
end, { id = "C29" })

--- Deletes a preset
AutoLFM.Core.Maestro.RegisterCommand("Presets.Delete", function(presetName)
  if not presetName or presetName == "" then
    AutoLFM.Core.Utils.LogError("Preset name cannot be empty")
    return
  end

  local success = AutoLFM.Core.Storage.DeletePreset(presetName)

  if success then
    AutoLFM.Core.Utils.LogAction("Preset deleted: " .. presetName)
    AutoLFM.Core.Maestro.Dispatch("Presets.Changed")
  else
    AutoLFM.Core.Utils.LogError("Failed to delete preset")
  end
end, { id = "C30" })

--=============================================================================
-- EVENTS
--=============================================================================
AutoLFM.Core.Maestro.RegisterEvent("Presets.Changed", { id = "E07" })
AutoLFM.Core.Maestro.RegisterEvent("Presets.Loaded", { id = "E08" })

--=============================================================================
-- INITIALIZATION
--=============================================================================
AutoLFM.Core.SafeRegisterInit("Logic.Content.Presets", function()
end, {
  id = "I17",
  dependencies = { "Core.Storage", "Logic.Selection" }
})
