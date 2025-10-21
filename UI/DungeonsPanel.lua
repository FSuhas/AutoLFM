--=============================================================================
-- AutoLFM: Dungeons Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.DungeonsPanel then AutoLFM.UI.DungeonsPanel = {} end
if not AutoLFM_DungeonList then AutoLFM_DungeonList = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local dungeonsPanelFrame = nil
local dungeonScrollFrame = nil
local dungeonListContentFrame = nil
local dungeonFilterFrame = nil
local filterCheckboxes = {}
local filterFrameLabelFrame = nil
local filterFrameLabelText = nil
local clickableFrames = {}
local checkButtons = {}
local dungeonRows = {}
local filterStates = {}

-----------------------------------------------------------------------------
-- Dungeon Filter Management
-----------------------------------------------------------------------------
function AutoLFM.UI.DungeonsPanel.InitFilters()
  if not AutoLFM.Logic.Content.COLORS then return end
  
  local savedFilters = AutoLFM.Core.Settings.LoadFilters()
  
  for i = 1, table.getn(AutoLFM.Logic.Content.COLORS) do
    local color = AutoLFM.Logic.Content.COLORS[i]
    if color and color.key then
      if savedFilters[color.key] == nil then
        filterStates[color.key] = true
      else
        filterStates[color.key] = savedFilters[color.key]
      end
    end
  end
end

function AutoLFM.UI.DungeonsPanel.ShouldShowDungeonPriority(priority)
  if not priority or not AutoLFM.Logic.Content.COLORS then return true end
  
  for i = 1, table.getn(AutoLFM.Logic.Content.COLORS) do
    local color = AutoLFM.Logic.Content.COLORS[i]
    if color and color.priority == priority and color.key then
      return filterStates[color.key] or false
    end
  end
  
  return true
end

function AutoLFM.UI.DungeonsPanel.ToggleFilter(colorKey, isEnabled)
  if not colorKey then return end
  
  filterStates[colorKey] = (isEnabled == true or isEnabled == 1)
  
  if AutoLFM.Core.Settings.SaveFilters then
    AutoLFM.Core.Settings.SaveFilters(filterStates)
  end
end

function AutoLFM.UI.DungeonsPanel.GetFilterState(colorKey)
  if not colorKey then return true end
  return filterStates[colorKey] or false
end

function AutoLFM.UI.DungeonsPanel.GetAllFilterStates()
  return filterStates
end

function AutoLFM.UI.DungeonsPanel.ResetFilters()
  if not AutoLFM.Logic.Content.COLORS then return end
  
  for i = 1, table.getn(AutoLFM.Logic.Content.COLORS) do
    local color = AutoLFM.Logic.Content.COLORS[i]
    if color and color.key then
      filterStates[color.key] = true
    end
  end
  
  if AutoLFM.Core.Settings.SaveFilters then
    AutoLFM.Core.Settings.SaveFilters(filterStates)
  end
end

-----------------------------------------------------------------------------
-- Filter System UI
-----------------------------------------------------------------------------
local function RefreshDungeonDisplay()
  if AutoLFM_DungeonList and AutoLFM_DungeonList.Refresh then
    AutoLFM_DungeonList.Refresh()
  end
end

local function HasDisabledFilter()
  if not AutoLFM.Logic.Content.COLORS then return false end
  for i = 1, table.getn(AutoLFM.Logic.Content.COLORS) do
    local color = AutoLFM.Logic.Content.COLORS[i]
    if color and color.key and not AutoLFM.UI.DungeonsPanel.GetFilterState(color.key) then
      return true
    end
  end
  return false
end

local function UpdateFilterLabelColor()
  if not filterFrameLabelText then return end
  
  if HasDisabledFilter() then
    filterFrameLabelText:SetTextColor(1, 0.82, 0)
  else
    filterFrameLabelText:SetTextColor(1, 1, 1)
  end
end

local function CreateFilterCheckbox(parentFrame, colorData, index, xOffset)
  if not parentFrame or not colorData then return nil end
  
  local checkbox = CreateFrame("CheckButton", "DungeonFilter_" .. colorData.key, parentFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.CHECKBOX_SIZE)
  checkbox:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.CHECKBOX_SIZE)
  checkbox:SetPoint("LEFT", parentFrame, "LEFT", xOffset, 0)
  
  local normalTexture = checkbox:GetNormalTexture()
  local checkedTexture = checkbox:GetCheckedTexture()
  local disabledCheckedTexture = checkbox:GetDisabledCheckedTexture()
  
  if normalTexture then
    normalTexture:SetVertexColor(colorData.r, colorData.g, colorData.b)
  end
  
  if checkedTexture then
    checkedTexture:SetVertexColor(colorData.r, colorData.g, colorData.b)
  end
  
  if disabledCheckedTexture then
    disabledCheckedTexture:SetVertexColor(colorData.r, colorData.g, colorData.b)
  end
  
  checkbox:SetChecked(AutoLFM.UI.DungeonsPanel.GetFilterState(colorData.key) == true)
  
  checkbox:SetScript("OnClick", function()
    pcall(function()
      local isChecked = checkbox:GetChecked()
      AutoLFM.UI.DungeonsPanel.ToggleFilter(colorData.key, isChecked)
      RefreshDungeonDisplay()
      UpdateFilterLabelColor()
    end)
  end)
  
  filterCheckboxes[colorData.key] = checkbox
  
  return checkbox
end

local function CreateColorFilterUI(bottomZone)
  if not bottomZone then return nil end
  
  local filterFrame = CreateFrame("Frame", "DungeonFilterFrame", bottomZone)
  filterFrame:SetAllPoints(bottomZone)

  filterFrameLabelFrame = CreateFrame("Button", nil, filterFrame)
  filterFrameLabelFrame:SetWidth(50)
  filterFrameLabelFrame:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.BUTTON_HEIGHT)
  filterFrameLabelFrame:SetPoint("LEFT", filterFrame, "LEFT", 0, 0)
  
  filterFrameLabelText = filterFrameLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  filterFrameLabelText:SetPoint("LEFT", filterFrameLabelFrame, "LEFT", 0, 0)
  filterFrameLabelText:SetText("Filters:")
  filterFrameLabelText:SetTextColor(1, 1, 1)
  
  filterFrameLabelFrame:SetScript("OnClick", function()
    if not HasDisabledFilter() then return end
    
    if not AutoLFM.Logic.Content.COLORS then return end
    for i = 1, table.getn(AutoLFM.Logic.Content.COLORS) do
      local color = AutoLFM.Logic.Content.COLORS[i]
      if color and color.key then
        AutoLFM.UI.DungeonsPanel.ToggleFilter(color.key, true)
        
        if filterCheckboxes[color.key] then
          filterCheckboxes[color.key]:SetChecked(true)
        end
      end
    end
    
    RefreshDungeonDisplay()
    UpdateFilterLabelColor()
  end)
  
  filterFrameLabelFrame:SetScript("OnEnter", function()
    if HasDisabledFilter() then
      filterFrameLabelText:SetTextColor(0.3, 0.6, 1)
      GameTooltip:SetOwner(this, "ANCHOR_NONE")
      GameTooltip:SetPoint("BOTTOMLEFT", filterFrame, "TOPLEFT", -10, -5)
      GameTooltip:SetText("Enable all filters", 1, 1, 1)
      GameTooltip:Show()
    end
  end)
  
  filterFrameLabelFrame:SetScript("OnLeave", function()
    UpdateFilterLabelColor()
    GameTooltip:Hide()
  end)
  
  UpdateFilterLabelColor()
  
  local labelWidth = filterFrameLabelText:GetStringWidth() + 15
  
  if AutoLFM.Logic.Content.COLORS then
    for i = 1, table.getn(AutoLFM.Logic.Content.COLORS) do
      local color = AutoLFM.Logic.Content.COLORS[i]
      if color then
        local xOffset = labelWidth + (i - 1) * 30
        CreateFilterCheckbox(filterFrame, color, i, xOffset)
      end
    end
  end
  
  return filterFrame
end

function AutoLFM.UI.DungeonsPanel.UpdateFilterUI()
  if not filterCheckboxes then return end
  
  for colorKey, checkbox in pairs(filterCheckboxes) do
    if checkbox and checkbox.SetChecked then
      local state = AutoLFM.UI.DungeonsPanel.GetFilterState(colorKey)
      checkbox:SetChecked(state == true)
    end
  end
  
  RefreshDungeonDisplay()
end

-----------------------------------------------------------------------------
-- Dungeon List
-----------------------------------------------------------------------------
local function OnDungeonCheckboxClick(checkbox, dungeonTag)
  if not checkbox or not dungeonTag then return end
  
  local isChecked = checkbox:GetChecked()
  if AutoLFM.Logic.Content.ToggleDungeon then
    AutoLFM.Logic.Content.ToggleDungeon(dungeonTag, isChecked)
  end
end

local function CreateDungeonRow(parent, dungeon, priority, yOffset)
  if not parent or not dungeon then return nil end
  
  local clickableFrame = CreateFrame("Button", "ClickableDungeonFrame" .. dungeon.tag, parent)
  clickableFrame:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ROW_HEIGHT)
  clickableFrame:SetWidth(300)
  clickableFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -yOffset)
  
  local checkbox = CreateFrame("CheckButton", "DungeonCheckbox" .. dungeon.tag, clickableFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.CHECKBOX_SIZE)
  checkbox:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.CHECKBOX_SIZE)
  checkbox:SetPoint("LEFT", clickableFrame, "LEFT", 0, 0)
  
  if AutoLFM.Logic.Content.IsDungeonSelected then
    checkbox:SetChecked(AutoLFM.Logic.Content.IsDungeonSelected(dungeon.tag))
  end
  
  checkButtons[dungeon.tag] = checkbox
  
  local levelLabel = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  levelLabel:SetPoint("RIGHT", clickableFrame, "RIGHT", -10, 0)
  levelLabel:SetText("(" .. dungeon.levelMin .. " - " .. dungeon.levelMax .. ")")
  
  local label = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
  label:SetText(dungeon.name)
  
  local r, g, b = AutoLFM.Logic.Content.GetColor(priority, true)
  label:SetTextColor(r, g, b)
  levelLabel:SetTextColor(r, g, b)
  
  AutoLFM.UI.PanelBuilder.SetupRowHover(
    clickableFrame,
    checkbox,
    label,
    levelLabel,
    {r = r, g = g, b = b}
  )
  
  AutoLFM.UI.PanelBuilder.SetupClickToToggle(
    clickableFrame,
    checkbox,
    function(isChecked)
      OnDungeonCheckboxClick(checkbox, dungeon.tag)
    end
  )
  
  AutoLFM.UI.PanelBuilder.SetupCheckboxClick(
    checkbox,
    function(isChecked)
      OnDungeonCheckboxClick(checkbox, dungeon.tag)
    end
  )
  
  clickableFrame.dungeonTag = dungeon.tag
  clickableFrame.priority = priority
  
  table.insert(clickableFrames, clickableFrame)
  dungeonRows[dungeon.tag] = clickableFrame
  
  return clickableFrame
end

local function UpdateRowVisibility()
  if not dungeonRows then return end
  if not AutoLFM.Logic.Content.GetSortedDungeons then return end
  
  local yOffset = 0
  local visibleCount = 0
  
  for i = 1, table.getn(AutoLFM.Logic.Content.GetSortedDungeons(UnitLevel("player"))) do
    local entry = AutoLFM.Logic.Content.GetSortedDungeons(UnitLevel("player"))[i]
    if entry and entry.dungeon then
      local dungeonTag = entry.dungeon.tag
      local priority = entry.priority
      local frame = dungeonRows[dungeonTag]
      
      if frame then
        if AutoLFM.UI.DungeonsPanel.ShouldShowDungeonPriority(priority) then
          frame:Show()
          frame:ClearAllPoints()
          frame:SetPoint("TOPLEFT", frame:GetParent(), "TOPLEFT", 0, -yOffset)
          yOffset = yOffset + AutoLFM.UI.PanelBuilder.CONSTANTS.ROW_HEIGHT
          visibleCount = visibleCount + 1
        else
          frame:Hide()
        end
      end
    end
  end
  
  local parent = nil
  for _, frame in pairs(dungeonRows) do
    if frame then
      parent = frame:GetParent()
      break
    end
  end
  
  if parent then
    AutoLFM.UI.PanelBuilder.UpdateScrollHeight(parent, visibleCount)
  end
end

function AutoLFM_DungeonList.Display(parent)
  if not parent then return end
  
  for i = 1, table.getn(clickableFrames) do
    if clickableFrames[i] then clickableFrames[i]:Hide() end
  end
  for _, frame in pairs(dungeonRows) do
    if frame then frame:Hide() end
  end
  
  clickableFrames = {}
  checkButtons = {}
  dungeonRows = {}
  
  local playerLevel = UnitLevel("player")
  if not playerLevel or playerLevel < 1 then
    playerLevel = 1
  end
  
  local sortedDungeons = AutoLFM.Logic.Content.GetSortedDungeons(playerLevel)
  local yOffset = 0
  local visibleCount = 0
  
  for i = 1, table.getn(sortedDungeons) do
    local entry = sortedDungeons[i]
    if entry and entry.dungeon then
      local frame = CreateDungeonRow(parent, entry.dungeon, entry.priority, yOffset)
      if frame then
        if AutoLFM.UI.DungeonsPanel.ShouldShowDungeonPriority(entry.priority) then
          yOffset = yOffset + AutoLFM.UI.PanelBuilder.CONSTANTS.ROW_HEIGHT
          visibleCount = visibleCount + 1
        else
          frame:Hide()
        end
      end
    end
  end
  
  if parent and parent.SetHeight then
    local contentHeight = visibleCount * AutoLFM.UI.PanelBuilder.CONSTANTS.ROW_HEIGHT
    parent:SetHeight(math.max(contentHeight, 1))
  end
end

function AutoLFM_DungeonList.Refresh()
  UpdateRowVisibility()
  
  if dungeonScrollFrame and dungeonScrollFrame.UpdateScrollChildRect then
    dungeonScrollFrame:UpdateScrollChildRect()
  end
end

function AutoLFM_DungeonList.ClearSelection()
  if AutoLFM.Logic.Content.ClearDungeons then
    AutoLFM.Logic.Content.ClearDungeons()
  end
  
  AutoLFM.UI.PanelBuilder.ClearCheckboxes(checkButtons)
end

function AutoLFM_DungeonList.ClearBackdrops()
  AutoLFM.UI.PanelBuilder.ClearBackdrops(clickableFrames)
end

function AutoLFM_DungeonList.UpdateCheckboxes()
  if not AutoLFM.Logic.Content.IsDungeonSelected then return end
  AutoLFM.UI.PanelBuilder.UpdateCheckboxes(checkButtons, AutoLFM.Logic.Content.IsDungeonSelected)
end

function AutoLFM_DungeonList.UncheckDungeon(dungeonTag)
  if not dungeonTag then return end
  if not checkButtons then return end
  
  local checkbox = checkButtons[dungeonTag]
  if checkbox and checkbox.SetChecked then
    checkbox:SetChecked(false)
    
    local frame = checkbox:GetParent()
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end

-----------------------------------------------------------------------------
-- Public API (accessible via namespace)
-----------------------------------------------------------------------------
function AutoLFM.UI.DungeonsPanel.DisplayList(parent)
  if AutoLFM_DungeonList and AutoLFM_DungeonList.Display then
    return AutoLFM_DungeonList.Display(parent)
  end
end

function AutoLFM.UI.DungeonsPanel.RefreshList()
  if AutoLFM_DungeonList and AutoLFM_DungeonList.Refresh then
    return AutoLFM_DungeonList.Refresh()
  end
end

function AutoLFM.UI.DungeonsPanel.ClearSelection()
  if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearSelection then
    return AutoLFM_DungeonList.ClearSelection()
  end
end

function AutoLFM.UI.DungeonsPanel.ClearBackdrops()
  if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearBackdrops then
    return AutoLFM_DungeonList.ClearBackdrops()
  end
end

function AutoLFM.UI.DungeonsPanel.UpdateCheckboxes()
  if AutoLFM_DungeonList and AutoLFM_DungeonList.UpdateCheckboxes then
    return AutoLFM_DungeonList.UpdateCheckboxes()
  end
end

function AutoLFM.UI.DungeonsPanel.UncheckDungeon(dungeonTag)
  if AutoLFM_DungeonList and AutoLFM_DungeonList.UncheckDungeon then
    return AutoLFM_DungeonList.UncheckDungeon(dungeonTag)
  end
end

-----------------------------------------------------------------------------
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.DungeonsPanel.Create(parentFrame)
  if not parentFrame then return nil end
  if dungeonsPanelFrame then return dungeonsPanelFrame end
  
  local panelData = AutoLFM.UI.PanelBuilder.CreatePanel(parentFrame, "AutoLFM_DungeonsPanel")
  if not panelData then return nil end
  
  dungeonsPanelFrame = panelData.panel
  dungeonsPanelFrame:Show()
  
  panelData = AutoLFM.UI.PanelBuilder.AddScrollFrame(panelData, "AutoLFM_ScrollFrame_Dungeons")
  dungeonScrollFrame = panelData.scrollFrame
  dungeonListContentFrame = panelData.contentFrame
  
  if AutoLFM.UI.DungeonsPanel.DisplayList then
    AutoLFM.UI.DungeonsPanel.DisplayList(dungeonListContentFrame)
    
    if dungeonScrollFrame.UpdateScrollChildRect then
      dungeonScrollFrame:UpdateScrollChildRect()
    end
  end
  
  dungeonFilterFrame = CreateColorFilterUI(panelData.bottomZone)
  if dungeonFilterFrame then
    dungeonFilterFrame:Show()
  end
  
  return dungeonsPanelFrame
end

function AutoLFM.UI.DungeonsPanel.Show()
  AutoLFM.UI.PanelBuilder.ShowPanel(dungeonsPanelFrame, dungeonScrollFrame)
  
  if dungeonFilterFrame then
    dungeonFilterFrame:Show()
  end
  
  if AutoLFM.UI.RaidsPanel.HideSizeControls then
    AutoLFM.UI.RaidsPanel.HideSizeControls()
  end
  
  if AutoLFM.UI.RaidsPanel.ClearBackdrops then
    AutoLFM.UI.RaidsPanel.ClearBackdrops()
  end
end

function AutoLFM.UI.DungeonsPanel.Hide()
  AutoLFM.UI.PanelBuilder.HidePanel(dungeonsPanelFrame, dungeonScrollFrame)
  
  if dungeonFilterFrame then
    dungeonFilterFrame:Hide()
  end
end

function AutoLFM.UI.DungeonsPanel.GetFrame()
  return dungeonsPanelFrame
end

function AutoLFM.UI.DungeonsPanel.GetContentFrame()
  return dungeonListContentFrame
end

function AutoLFM.UI.DungeonsPanel.GetScrollFrame()
  return dungeonScrollFrame
end

function AutoLFM.UI.DungeonsPanel.Register()
  AutoLFM.UI.TabNavigation.RegisterPanel("dungeons",
    AutoLFM.UI.DungeonsPanel.Show,
    AutoLFM.UI.DungeonsPanel.Hide,
    function()
      if AutoLFM.UI.RaidsPanel.HideSizeControls then
        AutoLFM.UI.RaidsPanel.HideSizeControls()
      end
      if AutoLFM.UI.RaidsPanel.ClearBackdrops then
        AutoLFM.UI.RaidsPanel.ClearBackdrops()
      end
    end
  )
end
