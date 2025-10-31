--=============================================================================
-- AutoLFM: Dungeons Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.DungeonsPanel then AutoLFM.UI.DungeonsPanel = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local mainFrame = nil
local scrollFrame = nil
local contentFrame = nil
local filterFrame = nil
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
  if not priority then return true end
  
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
  
  filterStates[colorKey] = (isEnabled == true)
  
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
  if AutoLFM.UI.DungeonsPanel.Refresh then
    AutoLFM.UI.DungeonsPanel.Refresh()
  end
end

local function HasDisabledFilter()
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
  
  checkbox:SetChecked(AutoLFM.UI.DungeonsPanel.GetFilterState(colorData.key))
  
  checkbox:SetScript("OnClick", function()
    local isChecked = checkbox:GetChecked()
    AutoLFM.UI.DungeonsPanel.ToggleFilter(colorData.key, isChecked)
    RefreshDungeonDisplay()
    UpdateFilterLabelColor()
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
      checkbox:SetChecked(state)
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
  
  local r, g, b = AutoLFM.Logic.Content.GetColor(priority, true)
  local isChecked = false
  if AutoLFM.Logic.Content.IsDungeonSelected then
    isChecked = AutoLFM.Logic.Content.IsDungeonSelected(dungeon.tag)
  end
  
  local clickableFrame = AutoLFM.UI.PanelBuilder.CreateSelectableRow({
    parent = parent,
    frameName = "ClickableDungeonFrame" .. dungeon.tag,
    checkboxName = "DungeonCheckbox" .. dungeon.tag,
    yOffset = yOffset,
    mainText = dungeon.name,
    rightText = "(" .. dungeon.levelMin .. " - " .. dungeon.levelMax .. ")",
    color = {r = r, g = g, b = b},
    isChecked = isChecked,
    onCheckboxClick = function(checkbox, isChecked)
      OnDungeonCheckboxClick(checkbox, dungeon.tag)
    end,
    customProperties = {
      dungeonTag = dungeon.tag,
      priority = priority
    }
  })
  
  if clickableFrame then
    checkButtons[dungeon.tag] = clickableFrame.checkbox
    table.insert(clickableFrames, clickableFrame)
    dungeonRows[dungeon.tag] = clickableFrame
  end
  
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

function AutoLFM.UI.DungeonsPanel.Display(parent)
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

function AutoLFM.UI.DungeonsPanel.Refresh()
  UpdateRowVisibility()
  
  if scrollFrame and scrollFrame.UpdateScrollChildRect then
    scrollFrame:UpdateScrollChildRect()
  end
end

function AutoLFM.UI.DungeonsPanel.ClearSelection()
  if AutoLFM.Logic.Content.ClearDungeons then
    AutoLFM.Logic.Content.ClearDungeons()
  end
  
  AutoLFM.UI.PanelBuilder.ClearCheckboxes(checkButtons)
end

function AutoLFM.UI.DungeonsPanel.ClearBackdrops()
  AutoLFM.UI.PanelBuilder.ClearBackdrops(clickableFrames)
end

function AutoLFM.UI.DungeonsPanel.UpdateCheckboxes()
  if not AutoLFM.Logic.Content.IsDungeonSelected then return end
  AutoLFM.UI.PanelBuilder.UpdateCheckboxes(checkButtons, AutoLFM.Logic.Content.IsDungeonSelected)
end

function AutoLFM.UI.DungeonsPanel.UncheckDungeon(dungeonTag)
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
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.DungeonsPanel.Create(parentFrame)
  if not parentFrame then return nil end
  if mainFrame then return mainFrame end
  
  local panelData = AutoLFM.UI.PanelBuilder.CreatePanel(parentFrame, "AutoLFM_DungeonsPanel")
  if not panelData then return nil end
  
  mainFrame = panelData.panel
  mainFrame:Show()
  
  panelData = AutoLFM.UI.PanelBuilder.AddScrollFrame(panelData, "AutoLFM_ScrollFrame_Dungeons")
  scrollFrame = panelData.scrollFrame
  contentFrame = panelData.contentFrame
  
  if AutoLFM.UI.DungeonsPanel.Display then
    AutoLFM.UI.DungeonsPanel.Display(contentFrame)
    
    if scrollFrame.UpdateScrollChildRect then
      scrollFrame:UpdateScrollChildRect()
    end
  end
  
  filterFrame = CreateColorFilterUI(panelData.bottomZone)
  if filterFrame then
    filterFrame:Show()
  end
  
  return mainFrame
end

function AutoLFM.UI.DungeonsPanel.Show()
  AutoLFM.UI.PanelBuilder.ShowPanel(mainFrame, scrollFrame)
  
  if filterFrame then
    filterFrame:Show()
  end
  
  if AutoLFM.UI.RaidsPanel.HideSizeControls then
    AutoLFM.UI.RaidsPanel.HideSizeControls()
  end
  
  if AutoLFM.UI.RaidsPanel.ClearBackdrops then
    AutoLFM.UI.RaidsPanel.ClearBackdrops()
  end
end

function AutoLFM.UI.DungeonsPanel.Hide()
  AutoLFM.UI.PanelBuilder.HidePanel(mainFrame, scrollFrame)
  
  if filterFrame then
    filterFrame:Hide()
  end
end

function AutoLFM.UI.DungeonsPanel.GetFrame()
  return mainFrame
end

function AutoLFM.UI.DungeonsPanel.GetContentFrame()
  return contentFrame
end

function AutoLFM.UI.DungeonsPanel.GetScrollFrame()
  return scrollFrame
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
