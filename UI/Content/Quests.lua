--=============================================================================
-- AutoLFM: Quests UI
--   UI handlers for quest selection (uses ContentPanel factory)
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.Content = AutoLFM.UI.Content or {}

--=============================================================================
-- PRIVATE: Row creation logic
--=============================================================================

--- Creates and updates quest rows in the scroll frame with zone tooltips
--- @param scrollChild frame - The scroll child frame to populate
local function CreateQuestRows(scrollChild)
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

--=============================================================================
-- PUBLIC API
--=============================================================================

-- Create panel using ContentPanel factory
-- Init Handler ID will be auto-assigned by ContentPanel factory
AutoLFM.UI.Content.Quests = AutoLFM.UI.CreateContentPanel({
  name = "Quests",
  rowTemplatePrefix = "AutoLFM_QuestRow",
  createRowsFunc = CreateQuestRows,
  clearCacheFunc = AutoLFM.Logic.Content.Quests.ClearCache,
  listeningEvent = "Selection.Changed",
  listenerDependencies = {},
  listenerId = "L10"
})

-- Additional command registration for QuestsList.Refresh (legacy support)
AutoLFM.Core.SafeRegisterInit("UI.Quests.Commands", function()
  AutoLFM.Core.Maestro.RegisterCommand("QuestsList.Refresh", AutoLFM.UI.Content.Quests.Refresh, { id = "C21" })
end, { id = "I19", dependencies = { "UI.Quests" } })
