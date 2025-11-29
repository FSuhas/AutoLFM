--=============================================================================
-- AutoLFM: Quests UI
--   UI handlers for quest selection
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.Content = AutoLFM.UI.Content or {}
AutoLFM.UI.Content.Quests = {}

--=============================================================================
-- PUBLIC API
--   UI rendering functions for quest list
--=============================================================================

--- Creates and updates quest rows in the scroll frame with zone tooltips
--- @param scrollChild frame - The scroll child frame to populate
function AutoLFM.UI.Content.Quests.CreateRows(scrollChild)
  if not scrollChild then
    return
  end

  local sorted = AutoLFM.Logic.Content.Quests.GetSortedQuests()
  if not sorted then
    return
  end

  local rowHeight = AutoLFM.Core.Constants.ROW_HEIGHT
  local numRows = table.getn(sorted)

  scrollChild:SetHeight(AutoLFM.UI.RowList.CalculateScrollHeight(numRows, rowHeight))

  for i = 1, numRows do
    local entry = sorted[i]
    local color = entry.color
    local rowName = "AutoLFM_QuestRow" .. i

    -- Get or create row using factory
    local row = AutoLFM.UI.RowList.GetOrCreateRow(rowName, scrollChild, "AutoLFM_QuestRow_Template", i, rowHeight)
    if not row then
      return
    end
    row.questIndex = entry.index
    row.questZone = entry.zone

    local checkbox = getglobal(rowName .. "_CheckButton")
    local label = getglobal(rowName .. "_Label")
    local secondaryLabel = getglobal(rowName .. "_SecondaryLabel")

    if label then
      local mainText = "[" .. entry.level .. "] " .. entry.name
      label:SetText(mainText)
      label:SetTextColor(color.r, color.g, color.b)
    end

    if secondaryLabel then
      local rightText = ""
      if entry.tag then
        rightText = "(" .. entry.tag .. ")"
      end
      secondaryLabel:SetText(rightText)
      secondaryLabel:SetTextColor(color.r, color.g, color.b)
    end

    -- Setup hover effect with tooltip
    local elements = {}
    if label then table.insert(elements, label) end
    if secondaryLabel then table.insert(elements, secondaryLabel) end
    AutoLFM.UI.RowList.SetupHover(checkbox, row, color, elements, {
      tooltipZone = entry.zone
    })

    if checkbox then
      -- Sync checkbox state with custom message (check if quest link is present)
      local isSelected = AutoLFM.Logic.Content.Quests.IsQuestSelected(entry.index)
      checkbox:SetChecked(isSelected)

      checkbox:SetScript("OnClick", function()
        local parentRow = this:GetParent()
        if parentRow and parentRow.questIndex then
          -- Dispatch command to toggle quest link in custom message
          AutoLFM.Core.Maestro.Dispatch("Quests.Toggle", parentRow.questIndex)
        end
      end)
    end

    row:Show()
  end

  -- Force scroll frame update
  AutoLFM.UI.RowList.UpdateScrollFrame(scrollChild)
end

--- XML OnLoad callback - stores frame reference
--- @param frame frame - The quests content frame
function AutoLFM.UI.Content.Quests.OnLoad(frame)
  AutoLFM.UI.Content.Quests.frame = frame
end

--- XML OnShow callback - rebuilds quest rows when frame is shown
--- @param frame frame - The quests content frame
function AutoLFM.UI.Content.Quests.OnShow(frame)
  AutoLFM.UI.RowList.OnShowHandler(
    frame,
    AutoLFM.UI.Content.Quests.CreateRows,
    AutoLFM.Logic.Content.Quests.ClearCache,
    "AutoLFM_QuestRow"
  )
end

--- Refreshes the quest list display if frame is visible
--- Called by Maestro command "QuestsList.Refresh"
function AutoLFM.UI.Content.Quests.Refresh()
  if AutoLFM.UI.Content.Quests.frame and AutoLFM.UI.Content.Quests.frame:IsVisible() then
    AutoLFM.UI.Content.Quests.OnShow(AutoLFM.UI.Content.Quests.frame)
  end
end

-----------------------------------------------------------------------------
-- Auto-register commands and listeners
-----------------------------------------------------------------------------
if AutoLFM.Core.Maestro and AutoLFM.Core.Maestro.RegisterInit then
  AutoLFM.Core.Maestro.RegisterInit("UI.Quests", function()
    AutoLFM.Core.Maestro.RegisterCommand("QuestsList.Refresh", AutoLFM.UI.Content.Quests.Refresh, { id = "C27" })

    -- Listen to Selection.Changed to refresh checkboxes when custom message changes
    AutoLFM.Core.Maestro.Listen(
      "UI.Quests.OnSelectionChanged",
      "Selection.Changed",
      function()
        AutoLFM.UI.Content.Quests.Refresh()
      end,
      { id = "L08" }
    )
  end, { id = "I24" })
end
