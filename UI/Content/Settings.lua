--=============================================================================
-- AutoLFM: Settings UI
--   Visual handlers for the Settings panel
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.Content = AutoLFM.UI.Content or {}
AutoLFM.UI.Content.Settings = {}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local panel = nil
local defaultPanelDropdown = nil
local isRestoringState = false  -- Flag to prevent OnClick during restoration

-----------------------------------------------------------------------------
-- Private Helpers - UI Coloring
-----------------------------------------------------------------------------

--- Applies colors to filter checkboxes and labels
--- @param scrollChild frame - The scroll child container frame
local function applyColors(scrollChild)
  if not scrollChild or not AutoLFM.Core.Utils or not AutoLFM.Core.Constants then return end

  -- Color filter checkboxes from COLORS constant (priority 1-5 are dungeon filters)
  for _, color in ipairs(AutoLFM.Core.Constants.COLORS) do
    if color.priority >= 1 and color.priority <= 5 then
      local checkbox = getglobal(scrollChild:GetName().."_FiltersContainer_Filter"..color.name)
      if checkbox then
        AutoLFM.Core.Utils.SetCheckboxColorByName(checkbox, color.name)
      end
    end
  end

  -- Color labels
  AutoLFM.Core.Utils.SetTextColorByName(getglobal(scrollChild:GetName().."_DryRun_Label"), "YELLOW")
  AutoLFM.Core.Utils.SetTextColorByName(getglobal(scrollChild:GetName().."_Debug_Label"), "ORANGE")
end

-----------------------------------------------------------------------------
-- Private Helpers - UI State Restoration
-----------------------------------------------------------------------------

--- Restores a set of checkboxes from persistent data
--- @param scrollChild frame - The scroll child container frame
--- @param basePath string - The base path for checkbox widget names (e.g., "_FiltersContainer_Filter")
--- @param mapping table - Map of {dataKey = checkboxSuffix} pairs
--- @param dataSource function - Function that returns the persistent data table
local function restoreCheckboxes(scrollChild, basePath, mapping, dataSource)
  if not scrollChild then return end

  local data = dataSource()
  for key, checkboxSuffix in pairs(mapping) do
      local checkbox = getglobal(scrollChild:GetName() .. basePath .. checkboxSuffix)
      if checkbox then
          local value = data[key]
          if value == nil then value = true end  -- Default to enabled
          checkbox:SetChecked(value and 1 or nil)
      end
  end
end

--- Restores a radio button pair (on/off) from persistent data
--- @param scrollChild frame - The scroll child container frame
--- @param onPath string - Widget path for the "On" radio button (e.g., "_DarkUIContainer_OnRadio")
--- @param offPath string - Widget path for the "Off" radio button (e.g., "_DarkUIContainer_OffRadio")
--- @param getValue function - Function that returns the boolean value from persistent storage
local function restoreRadioPair(scrollChild, onPath, offPath, getValue)
  if not scrollChild then return end

  local value = getValue()
  local onRadio = getglobal(scrollChild:GetName() .. onPath)
  local offRadio = getglobal(scrollChild:GetName() .. offPath)

  if onRadio and offRadio then
      -- Force uncheck both first
      onRadio:SetChecked(nil)
      offRadio:SetChecked(nil)
      -- Then check the correct one
      if value then
          onRadio:SetChecked(1)
      else
          offRadio:SetChecked(1)
      end
  end
end

-----------------------------------------------------------------------------
-- OnLoad: Initialize the panel
-----------------------------------------------------------------------------
--- XML OnLoad callback - initializes the Settings panel UI
--- @param frame frame - The Settings panel frame
function AutoLFM.UI.Content.Settings.OnLoad(frame)
  panel = frame
  applyColors(AutoLFM.UI.RowList.GetScrollChild(panel))
  AutoLFM.UI.Content.Settings.CreateDefaultPanelDropdown()
end

-----------------------------------------------------------------------------
-- OnShow: Refresh the panel when shown
-----------------------------------------------------------------------------
--- XML OnShow callback - restores saved option states when panel is shown
--- @param frame frame - The Settings panel frame
function AutoLFM.UI.Content.Settings.OnShow(frame)
  applyColors(AutoLFM.UI.RowList.GetScrollChild(panel))
  AutoLFM.UI.Content.Settings.RestoreState()
end

-----------------------------------------------------------------------------
-- Create Default Panel Dropdown
-----------------------------------------------------------------------------
--- Creates the default panel dropdown menu using WoW's native dropdown system
--- Allows user to select which panel (Dungeons, Raids, Quests, Messaging, Presets) opens by default
function AutoLFM.UI.Content.Settings.CreateDefaultPanelDropdown()
  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  local placeholderFrame = getglobal(scrollChild:GetName().."_DefaultPanelContainer_DropdownPlaceholder")
  if not placeholderFrame then return end

  -- Create dropdown using WoW's native dropdown system
  defaultPanelDropdown = CreateFrame("Frame", panel:GetName().."_DefaultPanelDropdown", placeholderFrame, "UIDropDownMenuTemplate")
  defaultPanelDropdown:SetPoint("TOPLEFT", placeholderFrame, "TOPLEFT", 0, 0)
  UIDropDownMenu_SetWidth(135, defaultPanelDropdown)

  -- Initialize dropdown
  UIDropDownMenu_Initialize(defaultPanelDropdown, function(self)
      local items = {"Dungeons", "Raids", "Quests", "Messaging", "Presets"}
      for i = 1, table.getn(items) do
          local itemName = items[i]
          local info = {}
          info.text = itemName
          info.value = itemName
          info.func = function()
              UIDropDownMenu_SetSelectedValue(defaultPanelDropdown, itemName)
              UIDropDownMenu_SetText(itemName, defaultPanelDropdown)

              -- Save to persistent storage
              local internalName = string.lower(itemName)
              AutoLFM.Core.Persistent.SetDefaultPanel(internalName)

              -- Log the change
              AutoLFM.Core.Utils.LogInfo("Set default panel to " .. itemName)
          end
          info.checked = nil
          UIDropDownMenu_AddButton(info)
      end
  end)

  -- Set initial value from saved setting
  local defaultPanel = AutoLFM.Core.Persistent.GetDefaultPanel()
  if not defaultPanel then
      defaultPanel = "dungeons"
  end
  -- Capitalize first letter for display
  local displayName = string.upper(string.sub(defaultPanel, 1, 1)) .. string.sub(defaultPanel, 2)
  UIDropDownMenu_SetSelectedValue(defaultPanelDropdown, displayName)
  UIDropDownMenu_SetText(displayName, defaultPanelDropdown)
end

-----------------------------------------------------------------------------
-- Event Handlers - Dungeon Filters
-----------------------------------------------------------------------------
--- Handles dungeon filter checkbox toggle events
--- Saves to persistent storage and refreshes dungeon list UI
--- @param filterId string - Color filter ID (e.g., "GRAY", "GREEN", "YELLOW", "ORANGE", "RED")
--- @param isEnabled boolean - New state of the filter (true = enabled, false = disabled)
function AutoLFM.UI.Content.Settings.OnFilterToggle(filterId, isEnabled)
  if isRestoringState then return end

  -- Update local state in Logic layer
  if AutoLFM.Logic.Content.Settings and AutoLFM.Logic.Content.Settings.SetDungeonFilter then
      AutoLFM.Logic.Content.Settings.SetDungeonFilter(filterId, isEnabled)
  end

  -- Save to persistent storage
  if AutoLFM.Core.Persistent and AutoLFM.Core.Persistent.SetDungeonFilter then
      AutoLFM.Core.Persistent.SetDungeonFilter(filterId, isEnabled)
  end

  -- Clear dungeon cache to force rebuild with new filter
  if AutoLFM.Logic.Content.Dungeons and AutoLFM.Logic.Content.Dungeons.ClearCache then
      AutoLFM.Logic.Content.Dungeons.ClearCache()
  end

  -- Refresh dungeons UI if visible
  if AutoLFM.UI.Content.Dungeons and AutoLFM.UI.Content.Dungeons.Refresh then
      AutoLFM.UI.Content.Dungeons.Refresh()
  end
end

-----------------------------------------------------------------------------
-- Generic Radio Handler
--   Handles radio button pairs (on/off, show/hide, etc.)
-----------------------------------------------------------------------------

--- Handles radio button pair clicks (generic on/off handler)
--- @param radioButtons table - Table with { on = frame, off = frame }
--- @param isOn boolean - True to check 'on' radio, false to check 'off' radio
--- @param callback function|nil - Optional callback function to call with the boolean value
local function handleRadioClick(radioButtons, isOn, callback)
  if not radioButtons or not radioButtons.on or not radioButtons.off then return end

  if isOn then
  radioButtons.on:SetChecked(1)
  radioButtons.off:SetChecked(nil)
  else
  radioButtons.on:SetChecked(nil)
  radioButtons.off:SetChecked(1)
  end

  if callback then
  callback(isOn)
  end
end

-----------------------------------------------------------------------------
-- Event Handlers - Minimap Radio Buttons
-----------------------------------------------------------------------------
--- Handles minimap visibility radio button clicks (Show/Hide)
--- @param isShow boolean - True to show minimap button, false to hide
function AutoLFM.UI.Content.Settings.OnMinimapRadioClick(isShow)
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  local radios = {
  on = getglobal(scrollChild:GetName().."_MinimapContainer_ShowRadio"),
  off = getglobal(scrollChild:GetName().."_MinimapContainer_HideRadio")
  }

  handleRadioClick(radios, isShow, function(value)
  if AutoLFM.Logic.Content.Settings then
    AutoLFM.Logic.Content.Settings.ToggleMinimapVisibility(value)
  end
  end)
end

--- Handles minimap reset button click - resets minimap button to default position
function AutoLFM.UI.Content.Settings.OnMinimapResetClick()
  -- Delegate to Logic layer
  if AutoLFM.Logic.Content.Settings then
      AutoLFM.Logic.Content.Settings.ResetMinimapPosition()
  end
end

-----------------------------------------------------------------------------
-- Event Handlers - DarkUI Radio Buttons
-----------------------------------------------------------------------------
--- Handles dark mode radio button clicks (On/Off)
--- @param isEnabled boolean - True to enable dark mode, false to disable
function AutoLFM.UI.Content.Settings.OnDarkUIRadioClick(isEnabled)
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  local radios = {
  on = getglobal(scrollChild:GetName().."_DarkUIContainer_OnRadio"),
  off = getglobal(scrollChild:GetName().."_DarkUIContainer_OffRadio")
  }

  handleRadioClick(radios, isEnabled, function(value)
  if AutoLFM.Logic.Content.Settings then
    AutoLFM.Logic.Content.Settings.ToggleDarkMode(value)
  end
  end)
end

--- Handles reload button click - reloads the UI to apply dark mode changes
function AutoLFM.UI.Content.Settings.OnDarkUIReloadClick()
  ReloadUI()
end

-----------------------------------------------------------------------------
-- Event Handlers - Message Mode Radio Buttons
-----------------------------------------------------------------------------
--- Handles message mode radio button clicks (Details/Custom)
--- @param mode string - "details" for details mode, "custom" for custom mode
function AutoLFM.UI.Content.Settings.OnMessagingModeRadioClick(mode)
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  local isDetails = (mode == "details")
  local radios = {
  on = getglobal(scrollChild:GetName().."_MessagingModeContainer_SimpleRadio"),
  off = getglobal(scrollChild:GetName().."_MessagingModeContainer_CustomRadio")
  }

  handleRadioClick(radios, isDetails, function(value)
  local isCustom = not value
  if AutoLFM.Core.Persistent and AutoLFM.Core.Persistent.SetCustomInput then
    AutoLFM.Core.Persistent.SetCustomInput(isCustom)
    AutoLFM.Core.Utils.LogInfo("Set custom input mode to " .. tostring(isCustom))
  end
  end)
end

-----------------------------------------------------------------------------
-- Event Handlers - Preview Lines Radio Buttons
-----------------------------------------------------------------------------
--- Handles preview message lines radio button clicks (1 line / 2 lines)
--- @param lines number - 1 for single line, 2 for two lines
function AutoLFM.UI.Content.Settings.OnPreviewLinesRadioClick(lines)
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  local is1Line = (lines == 1)
  local radios = {
  on = getglobal(scrollChild:GetName().."_PreviewLinesContainer_1LineRadio"),
  off = getglobal(scrollChild:GetName().."_PreviewLinesContainer_2LinesRadio")
  }

  handleRadioClick(radios, is1Line, function(value)
  local lineCount = value and 1 or 2
  if AutoLFM.Core.Persistent and AutoLFM.Core.Persistent.SetPreviewMessageLines then
    AutoLFM.Core.Persistent.SetPreviewMessageLines(lineCount)
    AutoLFM.Core.Utils.LogInfo("Set preview message lines to " .. lineCount)

    -- Update the message preview immediately
    local currentMessage = AutoLFM.Core.Maestro.GetState("Message.ToBroadcast")
    if AutoLFM.UI.MainFrame and AutoLFM.UI.MainFrame.UpdateMessagePreview and currentMessage then
      AutoLFM.UI.MainFrame.UpdateMessagePreview(currentMessage)
    end
  end
  end)
end

-----------------------------------------------------------------------------
-- Event Handlers - Presets Radio Buttons
-----------------------------------------------------------------------------
--- Handles presets view mode radio button clicks (Condensed/Full)
--- @param isCondensed boolean - True for condensed view, false for full view
function AutoLFM.UI.Content.Settings.OnPresetsRadioClick(isCondensed)
  if isRestoringState then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  local radios = {
  on = getglobal(scrollChild:GetName().."_PresetsContainer_CondensedRadio"),
  off = getglobal(scrollChild:GetName().."_PresetsContainer_FullRadio")
  }

  handleRadioClick(radios, isCondensed, function(value)
  if AutoLFM.Logic.Content.Settings then
    AutoLFM.Logic.Content.Settings.TogglePresetsCondensed(value)
  end
  end)
end

-----------------------------------------------------------------------------
-- Event Handlers - Bottom Checkboxes
-----------------------------------------------------------------------------
--- Handles dry run checkbox toggle - enables/disables message simulation mode
--- @param isEnabled boolean - True to enable dry run mode, false to disable
function AutoLFM.UI.Content.Settings.OnDryRunToggle(isEnabled)
  -- Delegate to Logic layer
  if AutoLFM.Logic.Content.Settings then
      AutoLFM.Logic.Content.Settings.ToggleDryRun(isEnabled)
  end
end

--- Handles debug window checkbox toggle - shows/hides the debug console
--- @param isEnabled boolean - True to show debug window, false to hide
function AutoLFM.UI.Content.Settings.OnDebugToggle(isEnabled)
  if isRestoringState then return end

  -- Call Debug window show/hide directly
  if AutoLFM.Components.Debug then
      if isEnabled then
          AutoLFM.Components.Debug.Show()
      else
          AutoLFM.Components.Debug.Hide()
      end
  end
end

-----------------------------------------------------------------------------
-- Public API - Update Filter Checkbox (called directly by Logic layer)
-----------------------------------------------------------------------------
--- Updates a dungeon filter checkbox state (called by Logic layer)
--- @param colorId string - Color filter ID to update
--- @param isEnabled boolean - New state of the filter
function AutoLFM.UI.Content.Settings.UpdateFilterCheckbox(colorId, isEnabled)
  if not panel then return end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if not scrollChild then return end

  local checkbox = getglobal(scrollChild:GetName().."_FiltersContainer_Filter"..colorId)
  if checkbox then
      checkbox:SetChecked(isEnabled and 1 or nil)
  end
end

-----------------------------------------------------------------------------
-- Public API - Restore State (called by Logic layer)
-----------------------------------------------------------------------------
--- Restores all option states from persistent storage
--- Called when Settings panel is shown to sync UI with saved settings
function AutoLFM.UI.Content.Settings.RestoreState()
  if not panel then return end

  isRestoringState = true

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(panel)
  if scrollChild then
      -- Build filter mapping from COLORS constant (priority 1-5)
      local filterMapping = {}
      if AutoLFM.Core.Constants and AutoLFM.Core.Constants.COLORS then
        for _, color in ipairs(AutoLFM.Core.Constants.COLORS) do
          if color.priority >= 1 and color.priority <= 5 then
            filterMapping[color.name] = color.name
          end
        end
      end

      -- Restore dungeon filters using helper
      restoreCheckboxes(scrollChild, "_FiltersContainer_Filter", filterMapping, AutoLFM.Core.Persistent.GetDungeonFilters)

      -- Restore minimap visibility using helper
      restoreRadioPair(scrollChild, "_MinimapContainer_ShowRadio", "_MinimapContainer_HideRadio",
          function() return not AutoLFM.Core.Persistent.GetMinimapHidden() end)

      -- Restore DarkUI using helper
      restoreRadioPair(scrollChild, "_DarkUIContainer_OnRadio", "_DarkUIContainer_OffRadio",
          AutoLFM.Core.Persistent.GetDarkMode)

      -- Restore preview message lines using helper
      restoreRadioPair(scrollChild, "_PreviewLinesContainer_1LineRadio", "_PreviewLinesContainer_2LinesRadio",
          function() return AutoLFM.Core.Persistent.GetPreviewMessageLines() == 1 end)

      -- Restore messaging view using helper
      restoreRadioPair(scrollChild, "_MessagingModeContainer_SimpleRadio", "_MessagingModeContainer_CustomRadio",
          function() return not AutoLFM.Core.Persistent.GetCustomInput() end)

      -- Restore presets condensed using helper
      restoreRadioPair(scrollChild, "_PresetsContainer_CondensedRadio", "_PresetsContainer_FullRadio",
          AutoLFM.Core.Persistent.GetPresetsCondensed)

      -- Restore default panel dropdown
      local defaultPanel = AutoLFM.Core.Persistent.GetDefaultPanel()
      if defaultPanelDropdown and defaultPanel then
          -- Capitalize first letter for display
          local displayName = string.upper(string.sub(defaultPanel, 1, 1)) .. string.sub(defaultPanel, 2)
          UIDropDownMenu_SetSelectedValue(defaultPanelDropdown, displayName)
          UIDropDownMenu_SetText(displayName, defaultPanelDropdown)
      end

      -- Restore dry run
      local dryRun = AutoLFM.Core.Persistent.GetDryRun()
      local dryRunCheckbox = getglobal(scrollChild:GetName().."_DryRun")
      if dryRunCheckbox then dryRunCheckbox:SetChecked(dryRun and 1 or nil) end

      -- Restore debug (always false on load)
      local debugCheckbox = getglobal(scrollChild:GetName().."_Debug")
      if debugCheckbox then debugCheckbox:SetChecked(nil) end
  end

  isRestoringState = false
end
