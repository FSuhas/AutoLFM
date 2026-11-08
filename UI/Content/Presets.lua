--=============================================================================
-- AutoLFM: Presets UI
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.Content = AutoLFM.UI.Content or {}
AutoLFM.UI.Content.Presets = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local contentFrame = nil
local scrollChild = nil
local presetRows = {}
local isCondensed = false

--=============================================================================
-- HELPERS
--=============================================================================
local measureFrame, measureFontString
--- Measures the rendered height of a text string at a given width
--- @param text string - The text to measure
--- @param width number - The available width for wrapping
--- @return number - The computed text height in pixels
local function measureTextHeight(text, width)
  if not measureFrame then
    measureFrame = CreateFrame("Frame", nil, UIParent)
    measureFrame:Hide()
    measureFontString = measureFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  end
  measureFrame:SetWidth(width)
  measureFontString:SetWidth(width)
  measureFontString:SetJustifyH("LEFT")
  measureFontString:SetText(text)
  return measureFontString:GetHeight()
end

--- Captures the current selection state from Maestro into a snapshot table
--- @return table - Snapshot containing dungeonNames, raidName, raidSize, roles, customMessage, detailsText, customGroupSize, mode
local function saveSelectionState()
  return {
    dungeonNames = AutoLFM.Core.Maestro.GetState("Selection.DungeonNames"),
    raidName = AutoLFM.Core.Maestro.GetState("Selection.RaidName"),
    raidSize = AutoLFM.Core.Maestro.GetState("Selection.RaidSize"),
    roles = AutoLFM.Core.Maestro.GetState("Selection.Roles"),
    customMessage = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage"),
    detailsText = AutoLFM.Core.Maestro.GetState("Selection.DetailsText"),
    customGroupSize = AutoLFM.Core.Maestro.GetState("Selection.CustomGroupSize"),
    mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")
  }
end

--- Restores a previously saved selection state snapshot back into Maestro
--- @param state table - The snapshot table returned by saveSelectionState
local function restoreSelectionState(state)
  AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", state.dungeonNames)
  AutoLFM.Core.Maestro.SetState("Selection.RaidName", state.raidName)
  AutoLFM.Core.Maestro.SetState("Selection.RaidSize", state.raidSize)
  AutoLFM.Core.Maestro.SetState("Selection.Roles", state.roles)
  AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", state.customMessage)
  AutoLFM.Core.Maestro.SetState("Selection.DetailsText", state.detailsText)
  AutoLFM.Core.Maestro.SetState("Selection.CustomGroupSize", state.customGroupSize)
  AutoLFM.Core.Maestro.SetState("Selection.Mode", state.mode)
end

--- Applies preset data fields to the current Maestro selection state and sets the mode
--- @param presetData table - The preset's stored data (dungeonNames, raidName, roles, etc.)
--- @param presetType string - The resolved preset type: "Custom", "Dungeons", or "Raid"
local function applyPresetData(presetData, presetType)
  if presetData.dungeonNames then AutoLFM.Core.Maestro.SetState("Selection.DungeonNames", presetData.dungeonNames) end
  if presetData.raidName then 
    AutoLFM.Core.Maestro.SetState("Selection.RaidName", presetData.raidName)
    AutoLFM.Core.Maestro.SetState("Selection.RaidSize", presetData.raidSize or 40)
  end
  if presetData.roles then AutoLFM.Core.Maestro.SetState("Selection.Roles", presetData.roles) end
  if presetData.customMessage then AutoLFM.Core.Maestro.SetState("Selection.CustomMessage", presetData.customMessage) end
  if presetData.detailsText then AutoLFM.Core.Maestro.SetState("Selection.DetailsText", presetData.detailsText) end
  if presetData.customGroupSize then AutoLFM.Core.Maestro.SetState("Selection.CustomGroupSize", presetData.customGroupSize) end
  
  if presetType == "Custom" then
    AutoLFM.Core.Maestro.SetState("Selection.Mode", "custom")
  elseif presetType == "Dungeons" then
    AutoLFM.Core.Maestro.SetState("Selection.Mode", "dungeons")
  elseif presetType == "Raid" then
    AutoLFM.Core.Maestro.SetState("Selection.Mode", "raid")
  end
end

--=============================================================================
-- FRAME LIFECYCLE
--=============================================================================
--- Initializes the presets content frame, resolves scroll child, and loads condensed preference
--- @param frame frame - The presets content frame
function AutoLFM.UI.Content.Presets.OnLoad(frame)
  contentFrame = frame
  local scrollFrame = getglobal(frame:GetName() .. "_ScrollFrame")
  if scrollFrame then
    scrollChild = getglobal(scrollFrame:GetName() .. "_ScrollChild")
  end
  
  isCondensed = AutoLFM.Core.Storage.GetPresetsCondensed()
end

--- Handles the presets frame becoming visible; refreshes condensed state and redraws rows
--- @param frame frame - The presets content frame
function AutoLFM.UI.Content.Presets.OnShow(frame)
  isCondensed = AutoLFM.Core.Storage.GetPresetsCondensed()
  AutoLFM.UI.Content.Presets.Refresh()
end

--- Handles the presets frame being hidden; hides reusable preset rows
--- @param frame frame - The presets content frame
function AutoLFM.UI.Content.Presets.OnHide(frame)
  AutoLFM.UI.Content.Presets.ClearRows()
end

--=============================================================================
-- ROW MANAGEMENT
--=============================================================================
--- Hides preset row frames while retaining them for reuse
function AutoLFM.UI.Content.Presets.ClearRows()
  for i = 1, table.getn(presetRows) do
    presetRows[i]:Hide()
  end
end

--- Reuses a row's text region and resets its anchors before updating it
local function getRowText(row, key, font)
  local text = row.regions[key]
  if not text then
    text = row:CreateFontString(nil, "OVERLAY", font)
    row.regions[key] = text
  end
  text:ClearAllPoints()
  text:Show()
  return text
end

--- Reuses a row's role icon
local function getRoleIcon(row, index)
  local key = "roleIcon" .. index
  local icon = row.regions[key]
  if not icon then
    icon = row:CreateTexture(nil, "ARTWORK")
    row.regions[key] = icon
  end
  icon:ClearAllPoints()
  icon:Show()
  return icon
end

--- Creates each row action button and its textures only once
local function getActionButton(row, key, iconName)
  local button = row[key]
  if not button then
    button = CreateFrame("Button", nil, row)
    button:SetWidth(20)
    button:SetHeight(20)
    local texture = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\Icons\\" .. iconName
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexture(texture)
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetTexture(texture)
    highlight:SetBlendMode("ADD")
    row[key] = button
  end
  button:ClearAllPoints()
  button:Show()
  return button
end

--- Creates a clickable preset row with name, type tag, content preview, and action buttons
--- @param index number - The 1-based index used for unique frame naming
--- @param presetName string - The display name of the preset
--- @param presetData table - The preset's stored configuration data
--- @param isFirst boolean - Whether this is the first row (hides up button)
--- @param isLast boolean - Whether this is the last row (hides down button)
--- @param yOffset number - The vertical offset from the top of the scroll child
--- @return frame - The created preset row button frame
local function createPresetRow(index, presetName, presetData, isFirst, isLast, yOffset)
  -- Ensure lookup tables are built for dungeon/raid lookups
  if AutoLFM.Core.Utils then
    AutoLFM.Core.Utils.EnsureLookupTables()
  end

  local presetType = "Custom"
  if presetData.dungeonNames and table.getn(presetData.dungeonNames) > 0 then
    presetType = "Dungeons"
  elseif presetData.raidName then
    presetType = "Raid"
  end
  
  local rowHeight = 38
  
  local row = presetRows[index]
  if not row then
    row = CreateFrame("Button", "AutoLFM_PresetRow" .. index, scrollChild)
    row.regions = {}
    presetRows[index] = row

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    row.bg = bg

    local border = row:CreateTexture(nil, "BORDER")
    border:SetTexture(0.3, 0.3, 0.3, 0.5)
    border:SetHeight(1)
    border:SetWidth(295)
    border:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
  end
  for _, region in pairs(row.regions) do
    region:Hide()
  end
  if row.upBtn then row.upBtn:Hide() end
  if row.downBtn then row.downBtn:Hide() end
  if row.deleteBtn then row.deleteBtn:Hide() end

  row:SetWidth(295)
  row:SetHeight(rowHeight)
  row:ClearAllPoints()
  row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset)
  row.rowHeight = rowHeight
  
  local bg = row.bg
  bg:SetTexture(0, 0, 0, 0)
  
  if isCondensed then
    local oldState = saveSelectionState()
    applyPresetData(presetData, presetType)
    AutoLFM.Logic.Message.RebuildMessage()
    local previewMsg = AutoLFM.Core.Maestro.GetState("Message.ToBroadcast") or ""
    restoreSelectionState(oldState)
    AutoLFM.Logic.Message.RebuildMessage()
    
    local msgHeight = measureTextHeight(previewMsg, 230)
    rowHeight = 26 + msgHeight
    row:SetHeight(rowHeight)
    row.rowHeight = rowHeight
    
    local nameLabel = getRowText(row, "nameLabel", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", row, "TOPLEFT", 5, -6)
    nameLabel:SetText(presetName)
    nameLabel:SetTextColor(1, 0.82, 0)
    row.nameLabel = nameLabel
    
    local previewText = getRowText(row, "previewText", "GameFontNormalSmall")
    previewText:SetPoint("TOPLEFT", row, "TOPLEFT", 5, -20)
    previewText:SetWidth(230)
    previewText:SetJustifyH("LEFT")
    previewText:SetTextColor(1, 1, 1)
    previewText:SetText(previewMsg)
  else
    local typeTag = getRowText(row, "typeTag", "GameFontNormalSmall")
    typeTag:SetPoint("TOPLEFT", row, "TOPLEFT", 5, -6)
    typeTag:SetText("[" .. presetType .. "]")
    typeTag:SetTextColor(1, 1, 1)
    
    local nameLabel = getRowText(row, "nameLabel", "GameFontNormal")
    nameLabel:SetPoint("LEFT", typeTag, "RIGHT", 4, 0)
    nameLabel:SetText(presetName)
    nameLabel:SetTextColor(1, 0.82, 0)
    row.nameLabel = nameLabel
    
    local xOffset = 5
    local iconSize = 16
    
    if presetData.roles and table.getn(presetData.roles) > 0 then
      local roleTextures = {
        TANK = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\Icons\\Tank",
        HEAL = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\Icons\\Heal",
        DPS = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\Icons\\Dps"
      }
      for i = 1, table.getn(presetData.roles) do
        local role = presetData.roles[i]
        local texture = roleTextures[role]
        if texture then
          local icon = getRoleIcon(row, i)
          icon:SetWidth(iconSize)
          icon:SetHeight(iconSize)
          icon:SetPoint("TOPLEFT", row, "TOPLEFT", xOffset, -20)
          icon:SetTexture(texture)
          xOffset = xOffset + iconSize - 2
        end
      end
      xOffset = xOffset + 3
    end
    
    local contentText = getRowText(row, "contentText", "GameFontNormalSmall")
    contentText:SetPoint("TOPLEFT", row, "TOPLEFT", xOffset, -20)
    contentText:SetWidth(200)
    contentText:SetJustifyH("LEFT")
    
    if presetType == "Custom" then
      local groupSize = presetData.customGroupSize or 5
      local customMsg = AutoLFM.Logic.Message.ReplaceVariables(presetData.customMessage or "", 1, groupSize, presetData.roles)
      local customHeight = measureTextHeight(customMsg, 200)
      rowHeight = 26 + customHeight
      row:SetHeight(rowHeight)
      row.rowHeight = rowHeight
      
      contentText:SetTextColor(1, 0.82, 0)
      contentText:SetText(customMsg)
    else
      contentText:SetTextColor(0.8, 0.8, 0.8)
      local tagsText = ""
      if presetData.dungeonNames and table.getn(presetData.dungeonNames) > 0 then
        local tags = {}
        for i = 1, table.getn(presetData.dungeonNames) do
          local dungeonName = presetData.dungeonNames[i]
          local dungeonInfo = AutoLFM.Core.Constants.DUNGEONS_BY_NAME[dungeonName]
          if dungeonInfo then
            table.insert(tags, dungeonInfo.data.tag)
          end
        end
        tagsText = table.concat(tags, ", ")
      elseif presetData.raidName then
        local raidInfo = AutoLFM.Core.Constants.RAIDS_BY_NAME[presetData.raidName]
        if raidInfo then
          tagsText = raidInfo.data.tag
          if presetData.raidSize then
            tagsText = tagsText .. " (" .. presetData.raidSize .. ")"
          end
        end
      end
      contentText:SetText(tagsText)
    end
    
    if presetType ~= "Custom" and presetData.detailsText and presetData.detailsText ~= "" then
      local detailsHeight = measureTextHeight(presetData.detailsText, 230)
      rowHeight = 40 + detailsHeight
      row:SetHeight(rowHeight)
      row.rowHeight = rowHeight
      
      local detailsMsg = getRowText(row, "detailsMsg", "GameFontNormalSmall")
      detailsMsg:SetPoint("TOPLEFT", row, "TOPLEFT", 5, -34)
      detailsMsg:SetWidth(230)
      detailsMsg:SetJustifyH("LEFT")
      detailsMsg:SetTextColor(1, 0.82, 0)
      detailsMsg:SetText(presetData.detailsText)
    end
  end
  
  local btnY = 0
  local btnSpacing = 15
  
  if not isFirst then
    local upBtn = getActionButton(row, "upBtn", "Up")
    local upBtnOffset = isLast and (-2 - btnSpacing) or (-2 - (btnSpacing * 2))
    upBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", upBtnOffset, btnY)
    upBtn:SetScript("OnClick", function()
      if AutoLFM.Core.Storage.MovePresetUp(presetName) then
        AutoLFM.UI.Content.Presets.Refresh()
      end
    end)
  end
  
  if not isLast then
    local downBtn = getActionButton(row, "downBtn", "Down")
    downBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", -1 - btnSpacing, btnY)
    downBtn:SetScript("OnClick", function()
      if AutoLFM.Core.Storage.MovePresetDown(presetName) then
        AutoLFM.UI.Content.Presets.Refresh()
      end
    end)
  end
  
  local deleteBtn = getActionButton(row, "deleteBtn", "Close")
  deleteBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, btnY)
  deleteBtn:SetScript("OnClick", function()
    AutoLFM.Core.Maestro.Dispatch("Presets.Delete", presetName)
  end)
  
  row:SetScript("OnClick", function()
    AutoLFM.Core.Maestro.Dispatch("Presets.Load", presetName)
  end)
  
  row:SetScript("OnEnter", function()
    bg:SetTexture(0.2, 0.2, 0.2, 0.2)
    local blueColor = AutoLFM.Core.Utils.GetColor("BLUE")
    if blueColor then
      row.nameLabel:SetTextColor(blueColor.r, blueColor.g, blueColor.b)
    end
  end)
  
  row:SetScript("OnLeave", function()
    bg:SetTexture(0, 0, 0, 0)
    row.nameLabel:SetTextColor(1, 0.82, 0)
  end)
  
  row:Show()
  return row
end

--- Updates the preset list using reusable rows, hiding unused entries
function AutoLFM.UI.Content.Presets.Refresh()
  AutoLFM.UI.Content.Presets.ClearRows()
  
  local presets = AutoLFM.Core.Storage.GetPresets()
  if not presets or not presets.order then return end
  
  local totalPresets = table.getn(presets.order)
  local yOffset = 0
  for i = 1, totalPresets do
    local presetName = presets.order[i]
    local presetData = presets.data[presetName]
    if presetData then
      local isFirst = (i == 1)
      local isLast = (i == totalPresets)
      local row = createPresetRow(i, presetName, presetData, isFirst, isLast, yOffset)
      yOffset = yOffset + (row.rowHeight or 0)
    end
  end
  
  scrollChild:SetHeight(yOffset)
  AutoLFM.UI.RowList.UpdateScrollFrame(scrollChild)
end

--=============================================================================
-- SAVE POPUP
--=============================================================================
--- Opens the save preset popup, clears previous input and error state, and focuses the name field
function AutoLFM.UI.Content.Presets.ShowSavePopup()
  local popup = getglobal("AutoLFM_SavePresetPopup")
  if not popup then return end
  
  local errorText = getglobal("AutoLFM_SavePresetPopup_ErrorText")
  if errorText then errorText:Hide() end
  
  local input = getglobal("AutoLFM_SavePresetPopup_NameInput")
  if input then
    input:SetText("")
    input:SetFocus()
  end
  
  popup:Show()
end

--- Validates the preset name input and dispatches a save action, or shows an error if the name already exists
function AutoLFM.UI.Content.Presets.OnSaveConfirm()
  local input = getglobal("AutoLFM_SavePresetPopup_NameInput")
  if not input then return end

  local presetName = input:GetText()
  if presetName and presetName ~= "" then
    local presets = AutoLFM.Core.Storage.GetPresets()
    if presets and presets.data and presets.data[presetName] then
      local errorText = getglobal("AutoLFM_SavePresetPopup_ErrorText")
      if errorText then
        errorText:SetText("Preset already exists")
        errorText:Show()
      end
      return
    end
    AutoLFM.Core.Maestro.Dispatch("Presets.Save", presetName)
    getglobal("AutoLFM_SavePresetPopup"):Hide()
  end
end

--- Closes the save preset popup without saving
function AutoLFM.UI.Content.Presets.OnSaveCancel()
  local popup = getglobal("AutoLFM_SavePresetPopup")
  if popup then popup:Hide() end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================
AutoLFM.Core.SafeRegisterInit("UI.Content.Presets", function()
  AutoLFM.Core.Maestro.Listen(
    "UI.Presets.OnChanged",
    "Presets.Changed",
    function()
      if contentFrame and contentFrame:IsVisible() then
        AutoLFM.UI.Content.Presets.Refresh()
      end
    end,
    { id = "L05" }
  )
end, {
  id = "I17",
  dependencies = { "Logic.Content.Presets" }
})
