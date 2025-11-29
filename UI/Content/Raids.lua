--=============================================================================
-- AutoLFM: Raids UI
--   UI handlers and dynamic elements for raid selection
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.Content = AutoLFM.UI.Content or {}
AutoLFM.UI.Content.Raids = {}

--=============================================================================
-- CONSTANTS
--=============================================================================

local RAID_COLOR = AutoLFM.Core.Utils.GetColor("GOLD")

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================
-- Note: Slider/EditBox creation now handled by SizeControl component

--=============================================================================
-- PUBLIC API
--   UI rendering functions for raid list with variable size controls
--=============================================================================

--- Creates and updates raid rows with size sliders for variable-size raids
--- Handles complex UI: checkboxes, sliders, editboxes with synchronized values
--- @param scrollChild frame - The scroll child frame to populate
function AutoLFM.UI.Content.Raids.CreateRows(scrollChild)
  if not scrollChild then
  return
  end

  local raids = AutoLFM.Logic.Content.Raids.GetRaids()
  if not raids then
  return
  end

  local rowHeight = AutoLFM.Core.Utils.ROW_HEIGHT
  local numRows = table.getn(raids)

  scrollChild:SetHeight(AutoLFM.UI.RowList.CalculateScrollHeight(numRows, rowHeight))

  for i = 1, numRows do
  local raid = raids[i]
  local rowName = "AutoLFM_RaidRow" .. i

  -- Get or create row using factory
  local row = AutoLFM.UI.RowList.GetOrCreateRow(rowName, scrollChild, "AutoLFM_RaidRow_Template", i, rowHeight)
  if not row then
    return
  end
  row.raidIndex = i

  local checkbox = getglobal(rowName .. "_CheckButton")
  local label = getglobal(rowName .. "_Label")
  local secondaryLabel = getglobal(rowName .. "_SecondaryLabel")

  if label then
    label:SetText(raid.name)
    -- Note: GOLD is the default WoW color, so we don't set it explicitly
  end

  if secondaryLabel then
    local sizeText
    if raid.raidSizeMin == raid.raidSizeMax then
      sizeText = "(" .. raid.raidSizeMin .. ")"
    else
      sizeText = "(" .. raid.raidSizeMin .. " - " .. raid.raidSizeMax .. ")"
    end
    secondaryLabel:SetText(sizeText)
    -- Note: GOLD is the default WoW color, so we don't set it explicitly
    row.sizeLabel = secondaryLabel
  end

  local isVariableSize = raid.raidSizeMin ~= raid.raidSizeMax
  if isVariableSize then
    -- Read current size from Maestro State (only if this raid is selected)
    local selectedRaidName = AutoLFM.Core.Maestro.GetState("Selection.RaidName")
    local currentSize = raid.raidSizeMin
    if selectedRaidName == raid.name then
      currentSize = AutoLFM.Core.Maestro.GetState("Selection.RaidSize") or raid.raidSizeMin
    end

    -- Create size control using component
    local hoverElements = {}
    if label then table.insert(hoverElements, label) end

    local sizeControl = AutoLFM.UI.SizeControl.Create({
      id = "Raid" .. i,
      parent = row,
      minSize = raid.raidSizeMin,
      maxSize = raid.raidSizeMax,
      currentSize = currentSize,
      color = RAID_COLOR,
      hoverElements = hoverElements,
      onValueChanged = function(value, silent)
        AutoLFM.Core.Maestro.Dispatch("Selection.SetRaidSize", value, silent)
      end
    })

    if not sizeControl then
      AutoLFM.Core.Utils.LogError("Failed to create size control for raid " .. i)
      return
    end

    -- Store references on row
    row.sizeControl = sizeControl
    row.sizeSlider = sizeControl.slider
    row.sizeEditBox = sizeControl.editBox
    row.isVariableSize = true
  end

  -- Setup hover effect on checkbox
  -- Note: Pass nil for color to keep default GOLD text color
  local checkboxElements = {}
  if label then table.insert(checkboxElements, label) end
  if secondaryLabel then table.insert(checkboxElements, secondaryLabel) end
  if row.sizeEditBox then table.insert(checkboxElements, row.sizeEditBox) end
  AutoLFM.UI.RowList.SetupHover(checkbox, row, nil, checkboxElements)

  if checkbox then
    -- Sync checkbox state with selection (read from Maestro State)
    local selectedRaidName = AutoLFM.Core.Maestro.GetState("Selection.RaidName")
    local isSelected = (selectedRaidName == raid.name)
    checkbox:SetChecked(isSelected)

    -- Show/hide size controls based on selection state (from Maestro State, not checkbox)
    if isVariableSize then
      if isSelected then
        if row.sizeControl then row.sizeControl.Show() end
        if secondaryLabel then secondaryLabel:Hide() end
      else
        if row.sizeControl then row.sizeControl.Hide() end
        if secondaryLabel then secondaryLabel:Show() end
      end
    end

    checkbox:SetScript("OnClick", function()
      local isChecked = this:GetChecked()
      local parentRow = this:GetParent()

      -- Dispatch Command to toggle raid selection
      AutoLFM.Core.Maestro.Dispatch("Selection.ToggleRaid", parentRow.raidIndex)

      if parentRow.isVariableSize then
        if isChecked then
          if parentRow.sizeLabel then parentRow.sizeLabel:Hide() end
          if parentRow.sizeControl then
            parentRow.sizeControl.Show()
            parentRow.sizeEditBox:SetFocus()
            parentRow.sizeEditBox:HighlightText()
          end
        else
          if parentRow.sizeControl then
            parentRow.sizeEditBox:ClearFocus()
            parentRow.sizeControl.Hide()
          end
          if parentRow.sizeLabel then parentRow.sizeLabel:Show() end
        end
      end
    end)
  end

  row:Show()
  end

  -- Force scroll frame update
  AutoLFM.UI.RowList.UpdateScrollFrame(scrollChild)
end

--- XML OnLoad callback - stores frame reference
--- @param frame frame - The raids content frame
function AutoLFM.UI.Content.Raids.OnLoad(frame)
  AutoLFM.UI.Content.Raids.frame = frame
end

--- XML OnShow callback - rebuilds raid rows when frame is shown
--- @param frame frame - The raids content frame
function AutoLFM.UI.Content.Raids.OnShow(frame)
  AutoLFM.UI.RowList.OnShowHandler(
  frame,
  AutoLFM.UI.Content.Raids.CreateRows,
  nil,  -- No cache to clear for raids
  "AutoLFM_RaidRow"
  )
end

--- Refreshes the raid list display
--- Rebuilds the list to sync checkbox states with Maestro States
function AutoLFM.UI.Content.Raids.Refresh()
  if AutoLFM.UI.Content.Raids.frame then
  AutoLFM.UI.Content.Raids.OnShow(AutoLFM.UI.Content.Raids.frame)
  end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("UI.Raids", function()
  --- Listens to Selection.Changed to refresh checkbox states
  AutoLFM.Core.Maestro.Listen(
    "UI.Raids.OnSelectionChanged",
    "Selection.Changed",
    function()
      AutoLFM.UI.Content.Raids.Refresh()
    end,
    { id = "L07" }
  )
end, { id = "I23", dependencies = { "Logic.Selection" } })
