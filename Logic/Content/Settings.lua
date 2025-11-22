--=============================================================================
-- AutoLFM: Settings Logic
--   Business logic for settings management
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Content = AutoLFM.Logic.Content or {}
AutoLFM.Logic.Content.Settings = {}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
-- Initialize with default values (all filters enabled)
local dungeonFilters = {
  GRAY = true,
  GREEN = true,
  YELLOW = true,
  ORANGE = true,
  RED = true
}

-----------------------------------------------------------------------------
-- Load Settings from Persistent Storage
-----------------------------------------------------------------------------
--- Loads all setting values from persistent storage into local state
--- Called during initialization to restore saved settings (dungeon filters, etc.)
function AutoLFM.Logic.Content.Settings.LoadSettings()
  -- Load dungeon filters
  if AutoLFM.Core.Persistent and AutoLFM.Core.Persistent.GetDungeonFilters then
      local filters = AutoLFM.Core.Persistent.GetDungeonFilters()
      if filters then
          if AutoLFM.Core.Persistent.DeepCopy then
              dungeonFilters = AutoLFM.Core.Persistent.DeepCopy(filters)
          else
              dungeonFilters = filters
          end
      end
  end
end

-----------------------------------------------------------------------------
-- Initialize Commands
-----------------------------------------------------------------------------
--- Initializes settings logic (currently no commands to register)
function AutoLFM.Logic.Content.Settings.Init()
  -- No commands to register anymore
  -- Filter toggles are now handled directly by UI layer
end

-----------------------------------------------------------------------------
-- Public Getters
-----------------------------------------------------------------------------
--- Returns the current dungeon filter states for all difficulty colors
--- @return table - Table with color names as keys (GRAY, GREEN, YELLOW, ORANGE, RED) and boolean values
function AutoLFM.Logic.Content.Settings.GetDungeonFilters()
  return dungeonFilters
end

-----------------------------------------------------------------------------
-- Public Setters
-----------------------------------------------------------------------------
--- Updates a single dungeon filter state in local memory
--- @param colorId string - Color filter ID (e.g., "GRAY", "GREEN", "YELLOW", "ORANGE", "RED")
--- @param isEnabled boolean - New state of the filter (true = enabled, false = disabled)
function AutoLFM.Logic.Content.Settings.SetDungeonFilter(colorId, isEnabled)
  if dungeonFilters[colorId] ~= nil then
    dungeonFilters[colorId] = isEnabled
  end
end

-----------------------------------------------------------------------------
-- Minimap Management
-----------------------------------------------------------------------------
--- Toggles minimap button visibility and saves the setting
--- @param isShow boolean - True to show the minimap button, false to hide it
function AutoLFM.Logic.Content.Settings.ToggleMinimapVisibility(isShow)
  -- Save to persistent storage
  AutoLFM.Core.Persistent.SetMinimapHidden(not isShow)

  -- Log the change
  local action = isShow and "Show" or "Hide"
  AutoLFM.Core.Utils.LogInfo(action .. " minimap button")

  -- Update minimap button visibility
  if AutoLFM.Components.MinimapButton then
      if isShow then
          AutoLFM.Components.MinimapButton.Show()
      else
          AutoLFM.Components.MinimapButton.Hide()
      end
  end
end

--- Resets minimap button to its default position (left side of minimap)
--- Clears saved position from persistent storage and repositions the button
function AutoLFM.Logic.Content.Settings.ResetMinimapPosition()
  -- Clear saved position
  AutoLFM.Core.Persistent.SetMinimapPos(nil, nil)

  -- Reset minimap button to default position
  if AutoLFM.Components.MinimapButton and AutoLFM.Components.MinimapButton.ResetPosition then
      AutoLFM.Components.MinimapButton.ResetPosition()
      AutoLFM.Core.Utils.LogInfo("Reset minimap button position")
  end
end

-----------------------------------------------------------------------------
-- DarkUI Management
-----------------------------------------------------------------------------
--- Toggles dark mode theme and prompts user to reload UI
--- Changes require UI reload to take effect on all frames
--- @param isEnabled boolean - True to enable dark mode, false to disable
function AutoLFM.Logic.Content.Settings.ToggleDarkMode(isEnabled)
  -- Save to persistent storage
  AutoLFM.Core.Persistent.SetDarkMode(isEnabled)

  -- Log the change
  local action = isEnabled and "Enable" or "Disable"
  AutoLFM.Core.Utils.LogInfo(action .. " dark mode")

  -- Show reload message
  local reloadText = AutoLFM.Core.Utils.ColorText("Reload", "GREEN")
  if isEnabled then
      AutoLFM.Core.Utils.Print("Dark mode enabled. Click " .. reloadText .. " to apply changes.")
  else
      AutoLFM.Core.Utils.Print("Dark mode disabled. Click " .. reloadText .. " to apply changes.")
  end
end

-----------------------------------------------------------------------------
-- Presets Management
-----------------------------------------------------------------------------
--- Toggles between condensed and full presets view mode
--- Condensed mode shows compact preset list, full mode shows expanded details
--- @param isCondensed boolean - True for condensed view, false for full view
function AutoLFM.Logic.Content.Settings.TogglePresetsCondensed(isCondensed)
  -- Save to persistent storage
  AutoLFM.Core.Persistent.SetPresetsCondensed(isCondensed)

  -- Log the change
  local mode = isCondensed and "condensed" or "full"
  AutoLFM.Core.Utils.LogAction("Set presets view to " .. mode)
end

-----------------------------------------------------------------------------
-- Dry Run Management
-----------------------------------------------------------------------------
--- Toggles dry run mode for testing without actually sending messages
--- When enabled, addon simulates actions but doesn't perform actual chat/whisper operations
--- Session-only setting (not persisted between game sessions)
--- @param isEnabled boolean - True to enable dry run mode, false to disable
function AutoLFM.Logic.Content.Settings.ToggleDryRun(isEnabled)
  -- Update Maestro state (not persisted between sessions)
  AutoLFM.Core.Maestro.SetState("Settings.DryRun", isEnabled)

  -- Log the change
  local action = isEnabled and "Enabled" or "Disabled"
  AutoLFM.Core.Utils.LogInfo(action .. " dry run mode")
end

-----------------------------------------------------------------------------
-- State Declarations
-----------------------------------------------------------------------------
--- State: Dry run mode enabled/disabled
AutoLFM.Core.SafeRegisterState("Settings.DryRun", false, { id = "S20" })

-----------------------------------------------------------------------------
-- Auto-register initialization
-----------------------------------------------------------------------------
AutoLFM.Core.SafeRegisterInit("Logic.Content.Settings", function()
  AutoLFM.Logic.Content.Settings.LoadSettings()
  AutoLFM.Logic.Content.Settings.Init()

  -- Dry run state defaults to false (session-only, not persisted)
end, {
  id = "I15",
  dependencies = {"Core.Persistent"} -- Must run after Persistent
})
