--=============================================================================
-- AutoLFM: Tab Navigation
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.TabNavigation then AutoLFM.UI.TabNavigation = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.UI.TabNavigation.TABS = {
  {id = 1, label = "Dungeons", panelId = "dungeons"},
  {id = 2, label = "Raids", panelId = "raids"},
  {id = 3, label = "Quests", panelId = "quests"},
  {id = 4, label = "More", panelId = "more"}
}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local tabs = {}
local currentTab = 1
local onTabChangeCallbacks = {}
local registeredPanels = {}
local currentPanelId = nil

-----------------------------------------------------------------------------
-- Tab Visual Management
-----------------------------------------------------------------------------
local function UpdateTabVisualState(index, isActive)
  local tab = tabs[index]
  if not tab then return end
  
  local texture = isActive and "tabActive" or "tabInactive"
  local r, g, b = 1, isActive and 1 or 0.82, isActive and 1 or 0
  
  tab.bg:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. texture)
  tab.text:SetTextColor(r, g, b)
  
  if isActive then
    tab.highlight:Hide()
  end
end

local function CreateTab(tabConfig, index, anchorTo)
  if not tabConfig then return nil end
  
  local mainFrame = AutoLFM.UI.MainWindow.GetFrame()
  if not mainFrame then return nil end
  
  local tab = CreateFrame("Button", nil, mainFrame)
  
  if anchorTo then
    tab:SetPoint("LEFT", anchorTo, "RIGHT", -6, 0)
  else
    tab:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 20, 46)
  end
  
  tab:SetWidth(80)
  tab:SetHeight(32)
  
  local bg = tab:CreateTexture(nil, "BACKGROUND")
  bg:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. (index == 1 and "tabActive" or "tabInactive"))
  bg:SetAllPoints()
  
  local highlight = tab:CreateTexture(nil, "BORDER")
  highlight:SetPoint("CENTER", tab, "CENTER", 0, 0)
  highlight:SetWidth(70)
  highlight:SetHeight(24)
  highlight:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "tabHighlight")
  highlight:Hide()
  
  local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  text:SetPoint("CENTER", tab, "CENTER", 0, 0)
  text:SetText(tabConfig.label)
  text:SetTextColor(1, index == 1 and 1 or 0.82, index == 1 and 1 or 0)
  
  tabs[index] = {
    btn = tab,
    bg = bg,
    text = text,
    highlight = highlight,
    panelId = tabConfig.panelId
  }
  
  tab:SetScript("OnClick", function()
    AutoLFM.UI.TabNavigation.SwitchTo(index)
  end)
  
  tab:SetScript("OnEnter", function()
    if currentTab ~= index then
      highlight:Show()
      text:SetTextColor(1, 1, 1)
    end
  end)
  
  tab:SetScript("OnLeave", function()
    highlight:Hide()
    if currentTab ~= index then
      text:SetTextColor(1, 0.82, 0)
    end
  end)
  
  return tab
end

-----------------------------------------------------------------------------
-- Tab System Management
-----------------------------------------------------------------------------
function AutoLFM.UI.TabNavigation.CreateTabs()
  local mainFrame = AutoLFM.UI.MainWindow.GetFrame()
  if not mainFrame then return end
  
  local prevTab = nil
  
  for i = 1, table.getn(AutoLFM.UI.TabNavigation.TABS) do
    local tabConfig = AutoLFM.UI.TabNavigation.TABS[i]
    prevTab = CreateTab(tabConfig, i, prevTab)
  end
  
  currentTab = 1
end

function AutoLFM.UI.TabNavigation.SwitchTo(tabIndex)
  if not tabIndex or tabIndex == currentTab then return end
  
  local success, err = pcall(function()
    currentTab = tabIndex
    
    for i = 1, table.getn(tabs) do
      if tabs[i] then
        UpdateTabVisualState(i, i == tabIndex)
      end
    end
    
    for i = 1, table.getn(onTabChangeCallbacks) do
      if type(onTabChangeCallbacks[i]) == "function" then
        pcall(onTabChangeCallbacks[i], tabIndex)
      end
    end
  end)
  
  if not success then
    AutoLFM.Core.Utils.PrintError("Error switching tab: " .. tostring(err))
  end
end

function AutoLFM.UI.TabNavigation.RegisterCallback(callback)
  if not callback or type(callback) ~= "function" then return end
  table.insert(onTabChangeCallbacks, callback)
end

function AutoLFM.UI.TabNavigation.GetCurrent()
  return currentTab
end

function AutoLFM.UI.TabNavigation.GetPanelId(tabIndex)
  if not tabs[tabIndex] then return nil end
  return tabs[tabIndex].panelId
end

-----------------------------------------------------------------------------
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.TabNavigation.RegisterPanel(panelId, showFunc, hideFunc, onShowCallback)
  if not panelId or not showFunc or not hideFunc then return end
  
  registeredPanels[panelId] = {
    show = showFunc,
    hide = hideFunc,
    onShow = onShowCallback
  }
end

function AutoLFM.UI.TabNavigation.ShowPanel(panelId)
  if not panelId then return end
  
  local success, err = pcall(function()
    for id, panel in pairs(registeredPanels) do
      if panel and panel.hide then
        pcall(panel.hide)
      end
    end
    
    local panel = registeredPanels[panelId]
    if panel then
      if panel.show then
        pcall(panel.show)
      end
      
      if panel.onShow then
        pcall(panel.onShow)
      end
      
      currentPanelId = panelId
    end
  end)
  
  if not success then
    AutoLFM.Core.Utils.PrintError("Error showing panel: " .. tostring(err))
  end
end

function AutoLFM.UI.TabNavigation.GetCurrentPanelId()
  return currentPanelId
end

function AutoLFM.UI.TabNavigation.HideAllPanels()
  for id, panel in pairs(registeredPanels) do
    if panel and panel.hide then
      pcall(panel.hide)
    end
  end
  currentPanelId = nil
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
local function ShowPanelByTabIndex(tabIndex)
  if not tabIndex then return end
  
  local panelId = AutoLFM.UI.TabNavigation.GetPanelId(tabIndex)
  if panelId then
    AutoLFM.UI.TabNavigation.ShowPanel(panelId)
  end
end

function AutoLFM.UI.TabNavigation.Init()
  AutoLFM.UI.TabNavigation.RegisterCallback(ShowPanelByTabIndex)
end
