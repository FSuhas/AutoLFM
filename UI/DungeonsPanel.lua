--=============================================================================
-- AutoLFM: Dungeons Panel
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.DungeonsPanel = AutoLFM.UI.DungeonsPanel or {}
AutoLFM.UI.DungeonsPanel.Filters = AutoLFM.UI.DungeonsPanel.Filters or {}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local mainFrame, scrollFrame, contentFrame, filterFrame
local filterCheckboxes, clickableFrames, checkButtons, dungeonRows = {}, {}, {}, {}
local filterStates = {}
local filterLabelFrame, filterLabelText

-----------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------
local function EachColor(callback)
  local colors = AutoLFM.Core.Constants.PRIORITY_COLORS
  if colors then
    for i, color in ipairs(colors) do
      if color then callback(color, i) end
    end
  end
end

local function RefreshDisplay()
  if AutoLFM.UI.DungeonsPanel.Refresh then
    AutoLFM.UI.DungeonsPanel.Refresh()
  end
end

-----------------------------------------------------------------------------
-- Dungeon Filter Management
-----------------------------------------------------------------------------
function AutoLFM.UI.DungeonsPanel.Filters.Init()
  local saved = AutoLFM.Core.Settings.LoadFilters() or {}
  EachColor(function(c) filterStates[c.key] = saved[c.key] ~= false end)
end

function AutoLFM.UI.DungeonsPanel.ToggleFilter(key, enabled)
  if not key then return end
  local state = enabled == true or enabled == 1
  if filterStates[key] ~= state then
    filterStates[key] = state
    if AutoLFM.Core.Settings.SaveFilters then
      AutoLFM.Core.Settings.SaveFilters(filterStates)
    end
  end
end

function AutoLFM.UI.DungeonsPanel.ShouldShowDungeonPriority(priority)
  if not priority then return true end
  local colors = AutoLFM.Core.Constants.PRIORITY_COLORS or {}
  for _, c in ipairs(colors) do
    if c.priority == priority then return filterStates[c.key] or false end
  end
  return true
end

function AutoLFM.UI.DungeonsPanel.ResetFilters()
  EachColor(function(c) filterStates[c.key] = true end)
  if AutoLFM.Core.Settings.SaveFilters then AutoLFM.Core.Settings.SaveFilters(filterStates) end
end

local function HasDisabledFilter()
  local colors = AutoLFM.Core.Constants.PRIORITY_COLORS or {}
  for _, c in ipairs(colors) do
    if not filterStates[c.key] then return true end
  end
  return false
end

function AutoLFM.UI.DungeonsPanel.GetFilterState(key)
  return key and filterStates[key] or false
end

function AutoLFM.UI.DungeonsPanel.GetAllFilterStates()
  return filterStates
end

-----------------------------------------------------------------------------
-- Filter System UI
-----------------------------------------------------------------------------
local function UpdateFilterLabelColor()
  if filterLabelText then
    AutoLFM.Core.Utils.SetFontColor(filterLabelText, HasDisabledFilter() and "gold" or "white")
  end
end

local function CreateFilterCheckbox(parent, color, xOffset)
  local cb = CreateFrame("CheckButton", "DungeonFilter_" .. color.key, parent, "UICheckButtonTemplate")
  cb:SetWidth(AutoLFM.Core.Constants.CHECKBOX_SIZE)
  cb:SetHeight(AutoLFM.Core.Constants.CHECKBOX_SIZE)
  cb:SetPoint("LEFT", parent, "LEFT", xOffset, 0)

  local function tintTexture(tex)
    if tex then tex:SetVertexColor(color.r, color.g, color.b) end
  end
  tintTexture(cb:GetNormalTexture())
  tintTexture(cb:GetCheckedTexture())
  tintTexture(cb:GetDisabledCheckedTexture())

  cb:SetChecked(AutoLFM.UI.DungeonsPanel.GetFilterState(color.key))
  cb:SetScript("OnClick", function()
    AutoLFM.UI.DungeonsPanel.ToggleFilter(color.key, cb:GetChecked())
    RefreshDisplay()
    UpdateFilterLabelColor()
  end)

  filterCheckboxes[color.key] = cb
end

local function CreateColorFilterUI(parent)
  local frame = CreateFrame("Frame", "DungeonFilterFrame", parent)
  frame:SetAllPoints(parent)

  filterLabelFrame = CreateFrame("Button", nil, frame)
  filterLabelFrame:SetWidth(50)
  filterLabelFrame:SetHeight(AutoLFM.Core.Constants.BUTTON_HEIGHT)
  filterLabelFrame:SetPoint("LEFT", frame, "LEFT", 0, 0)

  filterLabelText = filterLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  filterLabelText:SetPoint("LEFT", filterLabelFrame, "LEFT", 0, 0)
  filterLabelText:SetText("Filters: ")
  AutoLFM.Core.Utils.SetFontColor(filterLabelText, "white")

  filterLabelFrame:SetScript("OnClick", function()
    if HasDisabledFilter() then
      EachColor(function(c)
        AutoLFM.UI.DungeonsPanel.ToggleFilter(c.key, true)
        if filterCheckboxes[c.key] then filterCheckboxes[c.key]:SetChecked(true) end
      end)
      RefreshDisplay()
      UpdateFilterLabelColor()
    end
  end)

  filterLabelFrame:SetScript("OnEnter", function()
    if HasDisabledFilter() then
      AutoLFM.Core.Utils.SetFontColor(filterLabelText, "blue")
      GameTooltip:SetOwner(this, "ANCHOR_NONE")
      GameTooltip:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -10, -5)
      GameTooltip:SetText("Enable all filters", 1, 1, 1)
      GameTooltip:Show()
    end
  end)

  filterLabelFrame:SetScript("OnLeave", function()
    UpdateFilterLabelColor()
    GameTooltip:Hide()
  end)

  local labelWidth = filterLabelText:GetStringWidth() + 15
  EachColor(function(c, i) CreateFilterCheckbox(frame, c, labelWidth + (i - 1) * 30) end)

  UpdateFilterLabelColor()
  return frame
end

function AutoLFM.UI.DungeonsPanel.UpdateFilterUI()
  for k, cb in pairs(filterCheckboxes) do
    if cb and cb.SetChecked then cb:SetChecked(filterStates[k]) end
  end
  RefreshDisplay()
end

-----------------------------------------------------------------------------
-- Dungeon List
-----------------------------------------------------------------------------
local function OnDungeonCheckboxClick(cb, tag)
  if cb and tag and AutoLFM.Logic.Content.ToggleDungeon then
    AutoLFM.Logic.Content.ToggleDungeon(tag, cb:GetChecked())
  end
end

local function CreateDungeonRow(parent, dungeon, priority, yOffset)
  if not parent or not dungeon then return end
  local r, g, b = AutoLFM.Logic.Content.GetColor(priority, true)
  local checked = AutoLFM.Logic.Content.IsDungeonSelected and AutoLFM.Logic.Content.IsDungeonSelected(dungeon.tag)
  
  local row = AutoLFM.UI.PanelBuilder.CreateSelectableRow({
    parent = parent,
    frameName = "ClickableDungeonFrame" .. dungeon.tag,
    checkboxName = "DungeonCheckbox" .. dungeon.tag,
    yOffset = yOffset,
    mainText = dungeon.name,
    rightText = "(" .. dungeon.levelMin .. " - " .. dungeon.levelMax .. ")",
    color = {r=r, g=g, b=b},
    isChecked = checked,
    onCheckboxClick = function(cb, _) OnDungeonCheckboxClick(cb, dungeon.tag) end,
    customProperties = {dungeonTag=dungeon.tag, priority=priority}
  })

  if row then
    checkButtons[dungeon.tag] = row.checkbox
    dungeonRows[dungeon.tag] = row
    table.insert(clickableFrames, row)
  end
  return row
end

local function UpdateRowVisibility()
  local playerLevel = UnitLevel("player") or 1
  local sorted = AutoLFM.Logic.Content.GetSortedDungeons and AutoLFM.Logic.Content.GetSortedDungeons(playerLevel)
  if not sorted then return end

  local yOffset, visible = 0, 0
  for _, e in ipairs(sorted) do
    local f = e and dungeonRows[e.dungeon.tag]
    if f then
      if AutoLFM.UI.DungeonsPanel.ShouldShowDungeonPriority(e.priority) then
        f:Show()
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", f:GetParent(), "TOPLEFT", 0, -yOffset)
        yOffset = yOffset + AutoLFM.Core.Constants.ROW_HEIGHT
        visible = visible + 1
      else
        f:Hide()
      end
    end
  end

  for _, f in pairs(dungeonRows) do
    if f then
      AutoLFM.UI.PanelBuilder.UpdateScrollHeight(f:GetParent(), visible)
      break
    end
  end
end

function AutoLFM.UI.DungeonsPanel.Display(parent)
  if not parent then return end
  for _, f in pairs(dungeonRows) do if f then f:Hide() end end
  clickableFrames, checkButtons, dungeonRows = {}, {}, {}

  local level = UnitLevel("player") or 1
  local sorted = AutoLFM.Logic.Content.GetSortedDungeons(level) or {}
  local yOffset, visible = 0, 0
  for _, e in ipairs(sorted) do
    if e and e.dungeon then
      local row = CreateDungeonRow(parent, e.dungeon, e.priority, yOffset)
      if row and AutoLFM.UI.DungeonsPanel.ShouldShowDungeonPriority(e.priority) then
        yOffset = yOffset + AutoLFM.Core.Constants.ROW_HEIGHT
        visible = visible + 1
      else
        row:Hide()
      end
    end
  end

  if parent.SetHeight then
    parent:SetHeight(math.max(visible * AutoLFM.Core.Constants.ROW_HEIGHT, 1))
  end
end

function AutoLFM.UI.DungeonsPanel.Refresh() UpdateRowVisibility() if scrollFrame and scrollFrame.UpdateScrollChildRect then scrollFrame:UpdateScrollChildRect() end end
function AutoLFM.UI.DungeonsPanel.ClearSelection() if AutoLFM.Logic.Content.ClearDungeons then AutoLFM.Logic.Content.ClearDungeons() end AutoLFM.UI.PanelBuilder.ClearCheckboxes(checkButtons) end
function AutoLFM.UI.DungeonsPanel.ClearBackdrops() AutoLFM.UI.PanelBuilder.ClearBackdrops(clickableFrames) end
function AutoLFM.UI.DungeonsPanel.UpdateCheckboxes() if AutoLFM.Logic.Content.IsDungeonSelected then AutoLFM.UI.PanelBuilder.UpdateCheckboxes(checkButtons, AutoLFM.Logic.Content.IsDungeonSelected) end end
function AutoLFM.UI.DungeonsPanel.UncheckDungeon(tag) local cb = tag and checkButtons[tag] if cb then cb:SetChecked(false) local f = cb:GetParent() if f and f.SetBackdrop then f:SetBackdrop(nil) end end end

-----------------------------------------------------------------------------
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.DungeonsPanel.Init()
  AutoLFM.UI.DungeonsPanel.Filters.Init()
  
  if mainFrame then return mainFrame end
  local parent = AutoLFM.UI.MainWindow.GetFrame()
  if not parent then return nil end
  local p = AutoLFM.UI.PanelBuilder.CreatePanel(parent, "AutoLFM_DungeonsPanel")
  if not p then return end
  mainFrame = p.panel
  mainFrame:Show()
  p = AutoLFM.UI.PanelBuilder.AddScrollFrame(p, "AutoLFM_ScrollFrame_Dungeons")
  scrollFrame, contentFrame = p.scrollFrame, p.contentFrame
  AutoLFM.UI.DungeonsPanel.Display(contentFrame)
  if scrollFrame.UpdateScrollChildRect then scrollFrame:UpdateScrollChildRect() end
  filterFrame = CreateColorFilterUI(p.bottomZone)
  filterFrame:Show()
  
  AutoLFM.UI.DarkUI.RegisterFrame(mainFrame)
  
  AutoLFM.UI.DungeonsPanel.Register()
end

local function clearRaidsPanelState()
  if AutoLFM.UI.RaidsPanel.HideSizeControls then AutoLFM.UI.RaidsPanel.HideSizeControls() end
  if AutoLFM.UI.RaidsPanel.ClearBackdrops then AutoLFM.UI.RaidsPanel.ClearBackdrops() end
end

function AutoLFM.UI.DungeonsPanel.Show()
  AutoLFM.UI.PanelBuilder.ShowPanel(mainFrame, scrollFrame)
  if filterFrame then filterFrame:Show() end
  clearRaidsPanelState()
end

function AutoLFM.UI.DungeonsPanel.Hide()
  AutoLFM.UI.PanelBuilder.HidePanel(mainFrame, scrollFrame)
  if filterFrame then filterFrame:Hide() end
end

function AutoLFM.UI.DungeonsPanel.Register()
  AutoLFM.UI.TabNavigation.RegisterPanel("dungeons",
    AutoLFM.UI.DungeonsPanel.Show,
    AutoLFM.UI.DungeonsPanel.Hide,
    clearRaidsPanelState
  )
end
