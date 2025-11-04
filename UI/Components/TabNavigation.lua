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
  {id = 4, label = "More", panelId = "more"},
  {id = 5, icon = "close", panelId = "clear", isAction = true}
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
  
  if tab.isAction then
    return
  end
  
  local texture = isActive and "tabActive" or "tabInactive"
  local r, g, b = 1, isActive and 1 or 0.82, isActive and 1 or 0
  
  tab.bg:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. texture)
  
  if tab.text then
    tab.text:SetTextColor(r, g, b)
  end
  
  if tab.icon then
    tab.icon:SetVertexColor(r, g, b)
  end
  
  if isActive and tab.highlight then
    tab.highlight:Hide()
  end
end

local function CreateTab(tabConfig, index, anchorTo)
  if not tabConfig then return nil end
  
  local mainFrame = AutoLFM.UI.MainWindow.GetFrame()
  if not mainFrame then return nil end
  
  local tab = CreateFrame("Button", nil, mainFrame)
  
  if anchorTo then
    local offset = -6
    tab:SetPoint("LEFT", anchorTo, "RIGHT", offset, 0)
  else
    tab:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 18, 46)
  end
  
  local isIconTab = tabConfig.icon ~= nil
  
  if isIconTab then
    tab:SetWidth(40)
    tab:SetHeight(32)
  else
    tab:SetWidth(80)
    tab:SetHeight(32)
  end
  
  local bg = tab:CreateTexture(nil, "BACKGROUND")
  
  if isIconTab then
    bg:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "tabIcon")
  else
    bg:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. (index == 1 and "tabActive" or "tabInactive"))
  end
  
  bg:SetAllPoints()
  
  local highlight = nil
  
  if not isIconTab then
    highlight = tab:CreateTexture(nil, "BORDER")
    highlight:SetPoint("CENTER", tab, "CENTER", 0, 0)
    highlight:SetWidth(70)
    highlight:SetHeight(24)
    highlight:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "tabHighlight")
    highlight:Hide()
  end
  
  local text = nil
  local icon = nil
  
  if isIconTab then
    icon = tab:CreateTexture(nil, "OVERLAY")
    icon:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "Icons\\" .. tabConfig.icon)
    icon:SetWidth(24)
    icon:SetHeight(24)
    icon:SetPoint("CENTER", tab, "CENTER", 0, 0)
    icon:SetVertexColor(1, 0.82, 0)
    
    if AutoLFM.UI.ClearTab and AutoLFM.UI.ClearTab.SetIcon then
      AutoLFM.UI.ClearTab.SetIcon(icon)
    end
    if AutoLFM.UI.ClearTab and AutoLFM.UI.ClearTab.SetButton then
      AutoLFM.UI.ClearTab.SetButton(tab)
    end
  else
    text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER", tab, "CENTER", 0, 0)
    text:SetText(tabConfig.label)
    text:SetTextColor(1, index == 1 and 1 or 0.82, index == 1 and 1 or 0)
  end
  
  tabs[index] = {
    btn = tab,
    bg = bg,
    text = text,
    icon = icon,
    highlight = highlight,
    panelId = tabConfig.panelId,
    isAction = tabConfig.isAction or false
  }
  
  tab:SetScript("OnClick", function()
    if tabConfig.isAction then
      if AutoLFM.UI.ClearTab and AutoLFM.UI.ClearTab.OnTabClick then
        AutoLFM.UI.ClearTab.OnTabClick()
      end
    else
      AutoLFM.UI.TabNavigation.SwitchTo(index)
    end
  end)
  
  if not isIconTab then
    tab:SetScript("OnEnter", function()
      if currentTab ~= index then
        if highlight then
          highlight:Show()
        end
        if text then
          text:SetTextColor(1, 1, 1)
        end
        if icon and not isIconTab then
          icon:SetVertexColor(1, 1, 1)
        end
      end
    end)
    
    tab:SetScript("OnLeave", function()
      if highlight then
        highlight:Hide()
      end
      if currentTab ~= index then
        if text then
          text:SetTextColor(1, 0.82, 0)
        end
        if icon and not isIconTab then
          icon:SetVertexColor(1, 0.82, 0)
        end
      end
    end)
  end
  
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
