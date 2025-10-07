--------------------------------------------------
-- Tab System Component
--------------------------------------------------

local tabs = {}
local currentTab = 1
local onTabChangeCallbacks = {}

--------------------------------------------------
-- Create Single Tab
--------------------------------------------------
local function CreateTab(parentFrame, index, label, anchorTo)
  if not parentFrame then return nil end
  
  local tab = CreateFrame("Button", nil, parentFrame)
  
  if anchorTo then
    tab:SetPoint("LEFT", anchorTo, "RIGHT", -5, 0)
  else
    tab:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", 20, 46)
  end
  
  tab:SetWidth(90)
  tab:SetHeight(32)
  
  -- Background texture
  local bg = tab:CreateTexture(nil, "BACKGROUND")
  bg:SetTexture(TEXTURE_BASE_PATH .. (index == 1 and "tabActive" or "tabInactive"))
  bg:SetAllPoints()
  
  -- Highlight texture
  local highlight = tab:CreateTexture(nil, "BORDER")
  highlight:SetPoint("CENTER", tab, "CENTER", 0, 0)
  highlight:SetWidth(70)
  highlight:SetHeight(24)
  highlight:SetTexture(TEXTURE_BASE_PATH .. "tabHighlight")
  highlight:Hide()
  
  -- Text
  local text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  text:SetPoint("CENTER", tab, "CENTER", 0, 0)
  text:SetText(label)
  text:SetTextColor(1, index == 1 and 1 or 0.82, index == 1 and 1 or 0)
  
  tabs[index] = {
    btn = tab,
    bg = bg,
    text = text,
    highlight = highlight
  }
  
  -- Click handler
  tab:SetScript("OnClick", function()
    SwitchToTab(index)
  end)
  
  -- Hover handlers
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

--------------------------------------------------
-- Switch to Tab
--------------------------------------------------
function SwitchToTab(tabIndex)
  if not tabIndex then return end
  if tabIndex == currentTab then return end
  
  currentTab = tabIndex
  
  -- Update tab visuals
  for i = 1, table.getn(tabs) do
    if tabs[i] then
      local isActive = i == tabIndex
      tabs[i].bg:SetTexture(TEXTURE_BASE_PATH .. (isActive and "tabActive" or "tabInactive"))
      tabs[i].text:SetTextColor(1, isActive and 1 or 0.82, isActive and 1 or 0)
      if isActive then
        tabs[i].highlight:Hide()
      end
    end
  end
  
  -- Notify callbacks
  for _, callback in ipairs(onTabChangeCallbacks) do
    if type(callback) == "function" then
      callback(tabIndex)
    end
  end
end

--------------------------------------------------
-- Initialize Tab System
--------------------------------------------------
function InitializeTabSystem(parentFrame)
  if not parentFrame then return end
  
  local prevTab = nil
  local labels = {"Dungeons", "Raids", "More"}
  
  for i = 1, 3 do
    prevTab = CreateTab(parentFrame, i, labels[i], prevTab)
  end
  
  currentTab = 1
end

--------------------------------------------------
-- Register Tab Change Callback
--------------------------------------------------
function RegisterTabChangeCallback(callback)
  if not callback or type(callback) ~= "function" then return end
  table.insert(onTabChangeCallbacks, callback)
end

--------------------------------------------------
-- Get Current Tab Index
--------------------------------------------------
function GetCurrentTab()
  return currentTab
end