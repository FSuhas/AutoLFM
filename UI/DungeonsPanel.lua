--=============================================================================
-- AutoLFM: Dungeons Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.DungeonsPanel then AutoLFM.UI.DungeonsPanel = {} end

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
  if AutoLFM.Logic.Content.COLORS then
    for i, color in ipairs(AutoLFM.Logic.Content.COLORS) do
      if color then callback(color, i) end
    end
  end
end

local function TintTexture(tex, r, g, b)
  if tex then tex:SetVertexColor(r, g, b) end
end

local function RefreshDisplay()
  if AutoLFM.UI.DungeonsPanel.Refresh then
    AutoLFM.UI.DungeonsPanel.Refresh()
  end
end

-----------------------------------------------------------------------------
-- Dungeon Filter Management
-----------------------------------------------------------------------------

function AutoLFM.UI.DungeonsPanel.InitFilters()
  local saved = AutoLFM.Core.Settings.LoadFilters() or {}
  EachColor(function(c) filterStates[c.key] = saved[c.key] ~= false end)
end

function AutoLFM.UI.DungeonsPanel.ToggleFilter(key, enabled)
  if key then
    local state = enabled == true or enabled == 1
    if filterStates[key] ~= state then
      filterStates[key] = state
      if AutoLFM.Core.Settings.SaveFilters then
        AutoLFM.Core.Settings.SaveFilters(filterStates)
      end
    end
  end
end

function AutoLFM.UI.DungeonsPanel.ShouldShowDungeonPriority(priority)
  if not priority then return true end
  for _, c in ipairs(AutoLFM.Logic.Content.COLORS or {}) do
    if c.priority == priority then return filterStates[c.key] or false end
  end
  return true
end

function AutoLFM.UI.DungeonsPanel.ResetFilters()
  EachColor(function(c) filterStates[c.key] = true end)
  if AutoLFM.Core.Settings.SaveFilters then AutoLFM.Core.Settings.SaveFilters(filterStates) end
end

local function HasDisabledFilter()
  for _, c in ipairs(AutoLFM.Logic.Content.COLORS or {}) do
    if not filterStates[c.key] then return true end
  end
  return false
end

function AutoLFM.UI.DungeonsPanel.GetFilterState(key)
  return key and filterStates[key] or false
end

function AutoLFM.UI.DungeonsPanel.GetAllFilterStates() return filterStates end

-----------------------------------------------------------------------------
-- Filter System UI
-----------------------------------------------------------------------------

local function UpdateFilterLabelColor()
  if filterLabelText then
    local r, g, b = HasDisabledFilter() and 1 or 1, HasDisabledFilter() and 0.82 or 1, 0
    filterLabelText:SetTextColor(r, g, b)
  end
end

local function CreateFilterCheckbox(parent, color, xOffset)
  local cb = CreateFrame("CheckButton", "DungeonFilter_" .. color.key, parent, "UICheckButtonTemplate")
  cb:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.CHECKBOX_SIZE)
  cb:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.CHECKBOX_SIZE)
  cb:SetPoint("LEFT", parent, "LEFT", xOffset, 0)

  TintTexture(cb:GetNormalTexture(), color.r, color.g, color.b)
  TintTexture(cb:GetCheckedTexture(), color.r, color.g, color.b)
  TintTexture(cb:GetDisabledCheckedTexture(), color.r, color.g, color.b)

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
  filterLabelFrame:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.BUTTON_HEIGHT)
  filterLabelFrame:SetPoint("LEFT", frame, "LEFT", 0, 0)

  filterLabelText = filterLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  filterLabelText:SetPoint("LEFT", filterLabelFrame, "LEFT", 0, 0)
  filterLabelText:SetText("Filters:")
  filterLabelText:SetTextColor(1, 1, 1)

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
      filterLabelText:SetTextColor(0.3, 0.6, 1)
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
    local checked = cb:GetChecked()
    AutoLFM.Logic.Content.ToggleDungeon(tag, checked)
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
    color = {r=r,g=g,b=b},
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
        yOffset = yOffset + AutoLFM.UI.PanelBuilder.CONSTANTS.ROW_HEIGHT
        visible = visible + 1
      else f:Hide() end
    end
  end

  for _, f in pairs(dungeonRows) do
    if f then AutoLFM.UI.PanelBuilder.UpdateScrollHeight(f:GetParent(), visible) break end
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
        yOffset = yOffset + AutoLFM.UI.PanelBuilder.CONSTANTS.ROW_HEIGHT
        visible = visible + 1
      else row:Hide() end
    end
  end

  if parent.SetHeight then
    parent:SetHeight(math.max(visible * AutoLFM.UI.PanelBuilder.CONSTANTS.ROW_HEIGHT, 1))
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

function AutoLFM.UI.DungeonsPanel.Create(parent)
  if mainFrame then return mainFrame end
  local p = AutoLFM.UI.PanelBuilder.CreatePanel(parent, "AutoLFM_DungeonsPanel")
  if not p then return end
  mainFrame = p.panel mainFrame:Show()
  p = AutoLFM.UI.PanelBuilder.AddScrollFrame(p, "AutoLFM_ScrollFrame_Dungeons")
  scrollFrame, contentFrame = p.scrollFrame, p.contentFrame
  AutoLFM.UI.DungeonsPanel.Display(contentFrame)
  if scrollFrame.UpdateScrollChildRect then scrollFrame:UpdateScrollChildRect() end
  filterFrame = CreateColorFilterUI(p.bottomZone)
  filterFrame:Show()
  return mainFrame
end

function AutoLFM.UI.DungeonsPanel.Show()
  AutoLFM.UI.PanelBuilder.ShowPanel(mainFrame, scrollFrame)
  if filterFrame then filterFrame:Show() end
  if AutoLFM.UI.RaidsPanel.HideSizeControls then AutoLFM.UI.RaidsPanel.HideSizeControls() end
  if AutoLFM.UI.RaidsPanel.ClearBackdrops then AutoLFM.UI.RaidsPanel.ClearBackdrops() end
end

function AutoLFM.UI.DungeonsPanel.Hide()
  AutoLFM.UI.PanelBuilder.HidePanel(mainFrame, scrollFrame)
  if filterFrame then filterFrame:Hide() end
end

function AutoLFM.UI.DungeonsPanel.Register()
  AutoLFM.UI.TabNavigation.RegisterPanel("dungeons",
    AutoLFM.UI.DungeonsPanel.Show,
    AutoLFM.UI.DungeonsPanel.Hide,
    function()
      if AutoLFM.UI.RaidsPanel.HideSizeControls then AutoLFM.UI.RaidsPanel.HideSizeControls() end
      if AutoLFM.UI.RaidsPanel.ClearBackdrops then AutoLFM.UI.RaidsPanel.ClearBackdrops() end
    end
  )
end
