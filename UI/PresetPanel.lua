--=============================================================================
-- AutoLFM: Preset Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.PresetPanel then AutoLFM.UI.PresetPanel = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local mainFrame, scrollFrame, contentFrame
local presetRows = {}
local clickableFrames = {}

-----------------------------------------------------------------------------
-- Load Preset
-----------------------------------------------------------------------------
local function LoadPreset(presetData)
  if not presetData then return end

  -- Clear current selection
  if AutoLFM.Logic.Content.ClearDungeons then
    AutoLFM.Logic.Content.ClearDungeons()
  end
  if AutoLFM.Logic.Content.ClearRaids then
    AutoLFM.Logic.Content.ClearRaids()
  end
  if AutoLFM.Logic.Selection.ClearRoles then
    AutoLFM.Logic.Selection.ClearRoles()
  end

  -- Load dungeons
  if presetData.dungeons and AutoLFM.Logic.Content.ToggleDungeon then
    for i = 1, table.getn(presetData.dungeons) do
      AutoLFM.Logic.Content.ToggleDungeon(presetData.dungeons[i], true)
    end
  end

  -- Load raid size
  if presetData.raidSize and AutoLFM.Logic.Content.SetRaidSize then
    AutoLFM.Logic.Content.SetRaidSize(presetData.raidSize)
  end

  -- Load raids
  if presetData.raids and AutoLFM.Logic.Content.ToggleRaid then
    for i = 1, table.getn(presetData.raids) do
      AutoLFM.Logic.Content.ToggleRaid(presetData.raids[i], true)
    end
  end

  -- Load roles
  if presetData.roles and AutoLFM.Logic.Selection.ToggleRole then
    for i = 1, table.getn(presetData.roles) do
      AutoLFM.Logic.Selection.ToggleRole(presetData.roles[i], true)
    end
  end

  -- Load custom message
  if presetData.customMessage and AutoLFM.UI.MorePanel and AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
    local editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
    if editBox then
      editBox:SetText(presetData.customMessage)
      if AutoLFM.Logic.Broadcaster.SetCustomMessage then
        AutoLFM.Logic.Broadcaster.SetCustomMessage(presetData.customMessage)
      end
    end
  end

  -- Load broadcast interval
  if presetData.interval and AutoLFM.Core.Settings.SaveInterval then
    AutoLFM.Core.Settings.SaveInterval(presetData.interval)
    if AutoLFM.UI.MorePanel and AutoLFM.UI.MorePanel.UpdateIntervalUI then
      AutoLFM.UI.MorePanel.UpdateIntervalUI()
    end
  end

  -- Load selected channels
  if presetData.channels then
    if AutoLFM.Logic.Selection.ClearChannels then
      AutoLFM.Logic.Selection.ClearChannels()
    end
    for channelName, isSelected in pairs(presetData.channels) do
      if isSelected and AutoLFM.Logic.Selection.ToggleChannel then
        AutoLFM.Logic.Selection.ToggleChannel(channelName, true)
      end
    end
    if AutoLFM.UI.MorePanel and AutoLFM.UI.MorePanel.UpdateChannelCheckboxes then
      AutoLFM.UI.MorePanel.UpdateChannelCheckboxes()
    end
  end

  -- Update UI
  if AutoLFM.UI.DungeonsPanel and AutoLFM.UI.DungeonsPanel.UpdateCheckboxes then
    AutoLFM.UI.DungeonsPanel.UpdateCheckboxes()
  end
  if AutoLFM.UI.RaidsPanel and AutoLFM.UI.RaidsPanel.UpdateCheckboxes then
    AutoLFM.UI.RaidsPanel.UpdateCheckboxes()
  end
  if AutoLFM.UI.RaidsPanel and AutoLFM.UI.RaidsPanel.UpdateSizeControls then
    AutoLFM.UI.RaidsPanel.UpdateSizeControls()
  end
  if AutoLFM.UI.Components.MainWindow and AutoLFM.UI.Components.MainWindow.UpdateRoleCheckboxes then
    AutoLFM.UI.Components.MainWindow.UpdateRoleCheckboxes()
  end
  if AutoLFM.Logic.Broadcaster and AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
  if AutoLFM.UI.Components.MainWindow and AutoLFM.UI.Components.MainWindow.UpdateMessagePreview then
    AutoLFM.UI.Components.MainWindow.UpdateMessagePreview()
  end
  if AutoLFM.UI.Components.LineTabs and AutoLFM.UI.Components.LineTabs.UpdateActionIcons then
    AutoLFM.UI.Components.LineTabs.UpdateActionIcons()
  end
end

local function DeletePreset(presetName)
  if AutoLFM.Core.Settings.DeletePreset then
    local success = AutoLFM.Core.Settings.DeletePreset(presetName)
    if success then
      AutoLFM.Core.Utils.PrintSuccess("Preset deleted: " .. AutoLFM.Color(presetName, "yellow"))
      AutoLFM.UI.PresetPanel.Refresh()
    end
  end
end

-----------------------------------------------------------------------------
-- Preset Info Formatting
-----------------------------------------------------------------------------
local function FormatPresetContent(presetData)
  if not presetData then return "" end

  local content = {}

  -- Dungeons
  if presetData.dungeons and table.getn(presetData.dungeons) > 0 then
    local dungeonNames = {}
    for i = 1, table.getn(presetData.dungeons) do
      local dungeon = AutoLFM.Logic.Content.GetDungeonByTag(presetData.dungeons[i])
      if dungeon then
        table.insert(dungeonNames, dungeon.name)
      end
    end
    if table.getn(dungeonNames) > 0 then
      table.insert(content, table.concat(dungeonNames, ", "))
    end
  end

  -- Raids
  if presetData.raids and table.getn(presetData.raids) > 0 then
    local raidNames = {}
    for i = 1, table.getn(presetData.raids) do
      local raid = AutoLFM.Logic.Content.GetRaidByTag(presetData.raids[i])
      if raid then
        local raidName = raid.name
        if presetData.raidSize and presetData.raidSize > 0 then
          raidName = raidName .. " (" .. presetData.raidSize .. ")"
        end
        table.insert(raidNames, raidName)
      end
    end
    if table.getn(raidNames) > 0 then
      table.insert(content, table.concat(raidNames, ", "))
    end
  end

  if table.getn(content) > 0 then
    return table.concat(content, ", ")
  end
  return ""
end

local function FormatPresetRoles(presetData)
  if not presetData or not presetData.roles or table.getn(presetData.roles) == 0 then
    return ""
  end
  return "Roles: " .. table.concat(presetData.roles, ", ")
end

local function FormatPresetMessage(presetData)
  if not presetData or not presetData.customMessage or presetData.customMessage == "" then
    return ""
  end
  return presetData.customMessage
end

-----------------------------------------------------------------------------
-- Preset List Display
-----------------------------------------------------------------------------
local function CreatePresetRow(parent, presetName, presetData, yOffset)
  if not parent or not presetName then return end

  local contentStr = FormatPresetContent(presetData)
  local rolesStr = FormatPresetRoles(presetData)
  local messageStr = FormatPresetMessage(presetData)

  -- Create temporary frame to calculate text heights
  local tempFrame = CreateFrame("Frame", nil, parent)
  tempFrame:SetWidth(260)

  local nameHeight = 16
  local contentHeight = 0
  local messageHeight = 0
  local lineSpacing = 4

  -- Calculate content height
  if contentStr ~= "" then
    local tempText = tempFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tempText:SetWidth(260 - 50)
    tempText:SetJustifyH("LEFT")
    tempText:SetText(contentStr)
    contentHeight = tempText:GetHeight() or 14
    tempText:Hide()
  end

  -- Calculate message height
  if messageStr ~= "" then
    local tempText = tempFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tempText:SetWidth(260)
    tempText:SetJustifyH("LEFT")
    tempText:SetText(messageStr)
    messageHeight = tempText:GetHeight() or 14
    tempText:Hide()
  end

  tempFrame:Hide()

  local totalSpacing = lineSpacing
  if contentStr ~= "" then totalSpacing = totalSpacing + lineSpacing end
  if messageStr ~= "" then totalSpacing = totalSpacing + lineSpacing end

  local rowHeight = nameHeight + contentHeight + messageHeight + totalSpacing + 8

  local row = CreateFrame("Button", "ClickablePresetFrame" .. presetName, parent)
  row:SetWidth(300)
  row:SetHeight(rowHeight)
  row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -yOffset)

  local bg = row:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(row)
  bg:SetTexture(0, 0, 0, 0)

  -- Bottom border
  local border = row:CreateTexture(nil, "BORDER")
  border:SetTexture(0.3, 0.3, 0.3, 0.5)
  border:SetHeight(1)
  border:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 0, 0)
  border:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)

  local currentY = -4

  -- Name
  local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nameText:SetPoint("TOPLEFT", row, "TOPLEFT", 10, currentY)
  nameText:SetText(presetName)
  AutoLFM.Core.Utils.SetFontColor(nameText, "yellow")
  currentY = currentY - nameHeight - lineSpacing

  -- Roles icons on the left
  local rolesWidth = 0
  if presetData.roles and table.getn(presetData.roles) > 0 then
    local iconSize = 20
    local iconSpacing = -6
    local currentX = 10

    for i = 1, table.getn(presetData.roles) do
      local role = presetData.roles[i]
      local iconTexture = nil

      if role == "Tank" then
        iconTexture = AutoLFM.Core.Constants.TEXTURE_PATH .. "Icons\\tank"
      elseif role == "Heal" then
        iconTexture = AutoLFM.Core.Constants.TEXTURE_PATH .. "Icons\\heal"
      elseif role == "DPS" then
        iconTexture = AutoLFM.Core.Constants.TEXTURE_PATH .. "Icons\\dps"
      end

      if iconTexture then
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(iconTexture)
        icon:SetWidth(iconSize)
        icon:SetHeight(iconSize)
        icon:SetPoint("TOPLEFT", row, "TOPLEFT", currentX, currentY + 1)
        currentX = currentX + iconSize + iconSpacing
      end
    end

    rolesWidth = currentX - 10
  end

  -- Content (on same line as role icons)
  if contentStr ~= "" then
    local contentText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contentText:SetPoint("TOPLEFT", row, "TOPLEFT", 10 + rolesWidth + 5, currentY)
    contentText:SetWidth(260 - rolesWidth - 5)
    contentText:SetJustifyH("LEFT")
    contentText:SetText(contentStr)
    AutoLFM.Core.Utils.SetFontColor(contentText, "white")
    currentY = currentY - contentHeight - lineSpacing
  end

  -- Message (with same font as old Roles label)
  if messageStr ~= "" then
    local messageText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    messageText:SetPoint("TOPLEFT", row, "TOPLEFT", 10, currentY)
    messageText:SetWidth(260)
    messageText:SetJustifyH("LEFT")
    messageText:SetText(messageStr)
    AutoLFM.Core.Utils.SetFontColor(messageText, "gold")
  end

  local deleteBtn = CreateFrame("Button", nil, row)
  deleteBtn:SetWidth(16)
  deleteBtn:SetHeight(16)
  deleteBtn:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, -2)

  local deleteIcon = deleteBtn:CreateTexture(nil, "ARTWORK")
  deleteIcon:SetAllPoints(deleteBtn)
  deleteIcon:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "Icons\\close")

  local deleteHighlight = deleteBtn:CreateTexture(nil, "HIGHLIGHT")
  deleteHighlight:SetAllPoints(deleteBtn)
  deleteHighlight:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "Icons\\close")
  deleteHighlight:SetBlendMode("ADD")

  deleteBtn:SetScript("OnClick", function()
    DeletePreset(presetName)
  end)

  deleteBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:SetText("Delete preset")
    GameTooltip:Show()
  end)

  deleteBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  row:SetScript("OnClick", function()
    LoadPreset(presetData)
    AutoLFM.Core.Utils.PrintSuccess("Preset loaded: " .. AutoLFM.Color(presetName, "yellow"))
  end)

  row:SetScript("OnEnter", function()
    bg:SetTexture(0.2, 0.2, 0.2, 0.5)
    AutoLFM.Core.Utils.SetFontColor(nameText, "blue")
  end)

  row:SetScript("OnLeave", function()
    bg:SetTexture(0, 0, 0, 0)
    AutoLFM.Core.Utils.SetFontColor(nameText, "yellow")
  end)

  presetRows[presetName] = row
  table.insert(clickableFrames, row)
  row.rowHeight = rowHeight

  return row
end

function AutoLFM.UI.PresetPanel.Display(parent)
  if not parent then return end

  for _, f in pairs(presetRows) do
    if f then f:Hide() end
  end

  clickableFrames = {}
  presetRows = {}

  local presets = {}
  if AutoLFM.Core.Settings.LoadPresets then
    presets = AutoLFM.Core.Settings.LoadPresets()
  end

  local yOffset = 0
  local count = 0
  local totalHeight = 0

  for presetName, presetData in pairs(presets) do
    local row = CreatePresetRow(parent, presetName, presetData, yOffset)
    if row then
      local rowHeight = row.rowHeight or AutoLFM.Core.Constants.ROW_HEIGHT
      yOffset = yOffset + rowHeight + 2
      totalHeight = totalHeight + rowHeight + 2
      count = count + 1
    end
  end

  if parent.SetHeight then
    parent:SetHeight(math.max(totalHeight, 1))
  end
end

function AutoLFM.UI.PresetPanel.Refresh()
  if contentFrame then
    AutoLFM.UI.PresetPanel.Display(contentFrame)
  end
  if scrollFrame and scrollFrame.UpdateScrollChildRect then
    scrollFrame:UpdateScrollChildRect()
  end
end

function AutoLFM.UI.PresetPanel.ClearBackdrops()
  AutoLFM.UI.Components.PanelBuilder.ClearBackdrops(clickableFrames)
end

-----------------------------------------------------------------------------
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.PresetPanel.Init()
  if mainFrame then return mainFrame end

  local parent = AutoLFM.UI.Components.MainWindow.GetFrame()
  if not parent then return nil end

  local p = AutoLFM.UI.Components.PanelBuilder.CreatePanel(parent, "AutoLFM_PresetPanel")
  if not p then return end

  mainFrame = p.panel
  mainFrame:Hide()

  p = AutoLFM.UI.Components.PanelBuilder.AddScrollFrame(p, "AutoLFM_ScrollFrame_Preset")
  scrollFrame, contentFrame = p.scrollFrame, p.contentFrame

  AutoLFM.UI.PresetPanel.Display(contentFrame)

  if scrollFrame.UpdateScrollChildRect then
    scrollFrame:UpdateScrollChildRect()
  end

  AutoLFM.UI.Components.DarkUI.RegisterFrame(mainFrame)

  AutoLFM.UI.PresetPanel.Register()
  return mainFrame
end

function AutoLFM.UI.PresetPanel.Show()
  AutoLFM.UI.Components.PanelBuilder.ShowPanel(mainFrame, scrollFrame)
  AutoLFM.UI.PresetPanel.Refresh()
end

function AutoLFM.UI.PresetPanel.Hide()
  AutoLFM.UI.Components.PanelBuilder.HidePanel(mainFrame, scrollFrame)
end

function AutoLFM.UI.PresetPanel.Register()
  AutoLFM.UI.Components.TabNavigation.RegisterPanel("preset",
    AutoLFM.UI.PresetPanel.Show,
    AutoLFM.UI.PresetPanel.Hide
  )
end