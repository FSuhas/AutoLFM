--=============================================================================
-- AutoLFM: Line Tabs
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.Components then AutoLFM.UI.Components = {} end
if not AutoLFM.UI.Components.LineTabs then AutoLFM.UI.Components.LineTabs = {} end

local LineTabs = AutoLFM.UI.Components.LineTabs

-----------------------------------------------------------------------------
-- Configuration
-----------------------------------------------------------------------------
local LINE_TABS_CONFIG = {
  {id = 1, type = "panel", panelId = "preset", icon = "presets", tooltip = "Show presets", yOffset = -65},
  {id = 2, type = "action", icon = "addPreset", tooltip = "Save current preset", yOffset = -17},
  {id = 3, type = "action", icon = "clearAll", tooltip = "Clear all", yOffset = -17},
  {id = 4, type = "panel", panelId = "options", icon = "options", tooltip = "Options", yOffset = -194}
}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local lineTabs = {}
local actionIcons = {}
local actionButtons = {}

-----------------------------------------------------------------------------
-- Update Action Icons
-----------------------------------------------------------------------------
local function UpdateActionIcon(iconKey, hasContent)
  local icon = actionIcons[iconKey]
  if not icon then return end

  if hasContent then
    icon:SetVertexColor(1, 1, 1)
  else
    icon:SetVertexColor(0.5, 0.5, 0.5)
  end
end

function LineTabs.UpdateActionIcons()
  local hasClear = AutoLFM.Logic.ActionState and AutoLFM.Logic.ActionState.HasAnythingToClear and AutoLFM.Logic.ActionState.HasAnythingToClear() or false
  local hasSave = AutoLFM.Logic.ActionState and AutoLFM.Logic.ActionState.HasAnythingToSave and AutoLFM.Logic.ActionState.HasAnythingToSave() or false

  UpdateActionIcon("clearAll", hasClear)
  UpdateActionIcon("addPreset", hasSave)
end

-----------------------------------------------------------------------------
-- Setup Action Icon Behavior
-----------------------------------------------------------------------------
local function SetupActionIconBehavior(button, icon, iconKey, checkFunction, tooltipText)
  actionIcons[iconKey] = icon
  actionButtons[iconKey] = button

  button:SetScript("OnEnter", function()
    if checkFunction() then
      GameTooltip:SetOwner(button, "ANCHOR_NONE")
      GameTooltip:ClearAllPoints()
      GameTooltip:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 3, 1)
      GameTooltip:SetText(tooltipText, 1, 1, 1)
      GameTooltip:Show()
    end
  end)

  button:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

-----------------------------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------------------------
function LineTabs.UncheckAll()
  for i = 1, table.getn(lineTabs) do
    local tab = lineTabs[i]
    if tab and tab.checkButton and tab.type == "panel" then
      tab.checkButton:SetChecked(false)
    end
  end
end

-----------------------------------------------------------------------------
-- Tab Creation - Base Components
-----------------------------------------------------------------------------
local function CreateBaseFrame(parent, config, anchorTo, frameType)
  local tab = CreateFrame(frameType, "AutoLFMLineTab" .. config.id, parent)
  tab:SetWidth(32)
  tab:SetHeight(32)

  if anchorTo then
    tab:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, config.yOffset)
  else
    tab:SetPoint("TOPLEFT", parent, "TOPRIGHT", -32, config.yOffset)
  end
  tab:Show()

  return tab
end

local function CreateBaseTextures(tab, config, isCheckButton)
  local bg = tab:CreateTexture(nil, "BACKGROUND")
  bg:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "lineTab")
  bg:SetWidth(64)
  bg:SetHeight(64)
  bg:SetPoint("TOPLEFT", tab, "TOPLEFT", -3, 11)

  local normal = tab:CreateTexture(nil, "ARTWORK")
  tab:SetNormalTexture(normal)

  local icon = tab:CreateTexture(nil, isCheckButton and "BORDER" or "OVERLAY")
  icon:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. config.icon)
  icon:SetWidth(32)
  icon:SetHeight(32)
  icon:SetPoint("CENTER", tab, "CENTER", 0, 0)

  local highlight = tab:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "lineTabHilight")
  highlight:SetBlendMode("ADD")
  highlight:SetAllPoints(tab)

  return icon
end

local function SetupTooltips(tab, tooltip)
  tab:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_NONE")
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("BOTTOMRIGHT", this, "TOPRIGHT", 3, 1)
    GameTooltip:SetText(tooltip, 1, 1, 1)
    GameTooltip:Show()
  end)

  tab:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
end

-----------------------------------------------------------------------------
-- Tab Creation - Specific Types
-----------------------------------------------------------------------------
local function SetupActionBehavior(tab, config, icon)
  local clickTexture = tab:CreateTexture(nil, "HIGHLIGHT")
  clickTexture:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "lineTabClick")
  clickTexture:SetAllPoints(tab)
  clickTexture:SetBlendMode("BLEND")
  clickTexture:Hide()

  tab:SetScript("OnMouseDown", function()
    clickTexture:Show()
  end)

  tab:SetScript("OnMouseUp", function()
    clickTexture:Hide()
  end)

  tab:SetScript("OnClick", function()
    if config.icon == "clearAll" and AutoLFM.Logic.ActionState and AutoLFM.Logic.ActionState.ClearAll then
      AutoLFM.Logic.ActionState.ClearAll()
    elseif config.icon == "addPreset" and AutoLFM.Logic.ActionState and AutoLFM.Logic.ActionState.SavePreset then
      AutoLFM.Logic.ActionState.SavePreset()
    end
  end)

  if config.icon == "clearAll" then
    local checkFunc = function() return AutoLFM.Logic.ActionState and AutoLFM.Logic.ActionState.HasAnythingToClear and AutoLFM.Logic.ActionState.HasAnythingToClear() or false end
    SetupActionIconBehavior(tab, icon, "clearAll", checkFunc, "Clear all")
  elseif config.icon == "addPreset" then
    local checkFunc = function() return AutoLFM.Logic.ActionState and AutoLFM.Logic.ActionState.HasAnythingToSave and AutoLFM.Logic.ActionState.HasAnythingToSave() or false end
    SetupActionIconBehavior(tab, icon, "addPreset", checkFunc, "Save current preset")
  end
end

local function SetupPanelBehavior(tab, config)
  local pushed = tab:CreateTexture(nil, "OVERLAY")
  pushed:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "lineTabClick")
  pushed:SetAllPoints(tab)
  tab:SetPushedTexture(pushed)

  local checked = tab:CreateTexture(nil, "OVERLAY")
  checked:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "lineTabCheck")
  checked:SetBlendMode("ADD")
  checked:SetAllPoints(tab)
  tab:SetCheckedTexture(checked)

  tab:SetScript("OnClick", function()
    if AutoLFM.UI.Components.TabNavigation and AutoLFM.UI.Components.TabNavigation.UncheckAllTabs then
      AutoLFM.UI.Components.TabNavigation.UncheckAllTabs()
    end
    LineTabs.UncheckAll()
    tab:SetChecked(true)

    if AutoLFM.UI.Components.TabNavigation and AutoLFM.UI.Components.TabNavigation.ShowPanel then
      AutoLFM.UI.Components.TabNavigation.ShowPanel(config.panelId)
    end
  end)
end

local function CreateLineTab(parent, config, anchorTo)
  local isPanel = config.type == "panel"
  local frameType = isPanel and "CheckButton" or "Button"

  local tab = CreateBaseFrame(parent, config, anchorTo, frameType)
  local icon = CreateBaseTextures(tab, config, isPanel)

  if isPanel then
    SetupPanelBehavior(tab, config)
    SetupTooltips(tab, config.tooltip)
  else
    SetupActionBehavior(tab, config, icon)
  end

  return tab
end

-----------------------------------------------------------------------------
-- Main Creation
-----------------------------------------------------------------------------
function LineTabs.Create(parent)
  local tabs = {}
  local previousTab = nil

  for i = 1, table.getn(LINE_TABS_CONFIG) do
    local config = LINE_TABS_CONFIG[i]
    local tab = CreateLineTab(parent, config, previousTab)

    lineTabs[i] = {
      checkButton = tab,
      panelId = config.panelId,
      type = config.type
    }

    tabs[i] = tab
    previousTab = tab
  end

  return tabs
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function LineTabs.Init()
  if AutoLFM.Logic.ActionState and AutoLFM.Logic.ActionState.HasAnythingToClear and AutoLFM.Logic.ActionState.HasAnythingToSave then
    LineTabs.UpdateActionIcons()
  end
end