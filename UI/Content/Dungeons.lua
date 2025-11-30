--=============================================================================
-- AutoLFM: Dungeons UI
--   UI handlers for dungeon selection (uses ContentPanel factory)
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.Content = AutoLFM.UI.Content or {}

--=============================================================================
-- PRIVATE: Row creation logic
--=============================================================================

--- Creates and updates dungeon rows in the scroll frame
--- Reuses existing row frames for performance
--- @param scrollChild frame - The scroll child frame to populate
local function CreateDungeonRows(scrollChild)
  if not scrollChild then
    return
  end

  local sorted = AutoLFM.Logic.Content.Dungeons.GetSortedDungeons()
  if not sorted then
    return
  end

  local rowHeight = AutoLFM.Core.Constants.ROW_HEIGHT
  local numRows = table.getn(sorted)
  local scrollHeight = AutoLFM.UI.RowList.CalculateScrollHeight(numRows, rowHeight)

  scrollChild:SetHeight(scrollHeight)

  for i = 1, numRows do
    local entry = sorted[i]
    local dungeon = entry.dungeon
    local color = entry.color
    local rowName = "AutoLFM_DungeonRow" .. i

    -- Get or create row using factory
    local row = AutoLFM.UI.RowList.GetOrCreateRow(rowName, scrollChild, "AutoLFM_DungeonRow_Template", i, rowHeight)
    if not row then
      return
    end
    row.dungeonIndex = entry.index

    local checkbox = getglobal(rowName .. "_CheckButton")
    local label = getglobal(rowName .. "_Label")
    local secondaryLabel = getglobal(rowName .. "_SecondaryLabel")

    if label then
      label:SetText(dungeon.name)
      label:SetTextColor(color.r, color.g, color.b)
    end

    if secondaryLabel then
      secondaryLabel:SetText("(" .. dungeon.levelMin .. " - " .. dungeon.levelMax .. ")")
      secondaryLabel:SetTextColor(color.r, color.g, color.b)
    end

    -- Setup hover effect
    local elements = {}
    if label then table.insert(elements, label) end
    if secondaryLabel then table.insert(elements, secondaryLabel) end
    AutoLFM.UI.RowList.SetupHover(checkbox, row, color, elements)

    if checkbox then
      local selectedDungeonNames = AutoLFM.Core.Maestro.GetState("Selection.DungeonNames") or {}
      local isSelected = false
      for j = 1, table.getn(selectedDungeonNames) do
        if selectedDungeonNames[j] == dungeon.name then
          isSelected = true
          break
        end
      end
      checkbox:SetChecked(isSelected)

      checkbox:SetScript("OnClick", function()
        AutoLFM.Core.Maestro.Dispatch("Selection.ToggleDungeon", row.dungeonIndex)
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
AutoLFM.UI.Content.Dungeons = AutoLFM.UI.CreateContentPanel({
  name = "Dungeons",
  rowTemplatePrefix = "AutoLFM_DungeonRow",
  createRowsFunc = CreateDungeonRows,
  clearCacheFunc = AutoLFM.Logic.Content.Dungeons.ClearCache,
  listeningEvent = "Selection.Changed",
  listenerDependencies = { "Logic.Selection" },
  listenerId = "L06"
})
