--------------------------------------------------
-- Dungeon Color Filters
--------------------------------------------------

local filterCheckboxes = {}
filterStates = {}
local filtersInitialized = false

--------------------------------------------------
-- Initialize Filter States
--------------------------------------------------
local function InitializeFilterStates()
  if filtersInitialized then return end
  
  filterStates = {}
  if PRIORITY_COLOR_SCHEME then
    for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
      if color and color.key then
        filterStates[color.key] = true
      end
    end
  end
  
  filtersInitialized = true
end

--------------------------------------------------
-- Check if Priority Should Be Displayed
--------------------------------------------------
function ShouldShowPriorityLevel(priority)
  if not priority then return true end
  if not PRIORITY_COLOR_SCHEME then return true end
  
  for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
    if color and color.priority == priority and color.key then
      return filterStates[color.key] or false
    end
  end
  
  return true
end

--------------------------------------------------
-- Refresh Dungeon List Display
--------------------------------------------------
function RefreshDungeonDisplay()
  if AutoLFM_DungeonList and AutoLFM_DungeonList.Refresh then
    AutoLFM_DungeonList.Refresh()
  end
end

--------------------------------------------------
-- Create Filter Button
--------------------------------------------------
local function CreateFilterButton(parentFrame, colorData, index)
  if not parentFrame or not colorData then return nil end
  
  local button = CreateFrame("Button", "DungeonFilter_" .. colorData.key, parentFrame)
  button:SetWidth(20)
  button:SetHeight(20)
  button:SetPoint("LEFT", parentFrame, "LEFT", (index - 1) * 40, 0)
  
  -- Icon
  local icon = button:CreateTexture(nil, "ARTWORK")
  icon:SetWidth(20)
  icon:SetHeight(20)
  icon:SetPoint("CENTER", button, "CENTER", 0, 0)
  
  if colorData.r and colorData.g and colorData.b then
    icon:SetVertexColor(colorData.r, colorData.g, colorData.b)
  end
  
  -- Initialize state
  if filterStates[colorData.key] == nil then
    filterStates[colorData.key] = true
  end
  
  -- Set initial texture
  if filterStates[colorData.key] then
    icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
  else
    icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
  end
  
  button.icon = icon
  button.colorKey = colorData.key
  
  -- Highlight
  local highlight = button:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetWidth(24)
  highlight:SetHeight(24)
  highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
  highlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
  highlight:SetBlendMode("ADD")
  
  -- Click handler
  button:SetScript("OnClick", function()
    InitializeFilterStates()
    
    local currentKey = button.colorKey
    filterStates[currentKey] = not filterStates[currentKey]
    
    if filterStates[currentKey] then
      button.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    else
      button.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
    end
    
    SaveColorFilterSettings()
    RefreshDungeonDisplay()
  end)
  
  filterCheckboxes[colorData.key] = button
  
  return button
end

--------------------------------------------------
-- Create Color Filter UI
--------------------------------------------------
function CreateColorFilterUI(parentFrame)
  if not parentFrame then return nil end
  
  InitializeFilterStates()
  
  local filterFrame = CreateFrame("Frame", "DungeonFilterFrame", parentFrame)
  filterFrame:SetPoint("BOTTOM", parentFrame, "BOTTOM", -16, 75)
  filterFrame:SetWidth(300)
  filterFrame:SetHeight(30)
  
  if not PRIORITY_COLOR_SCHEME then return filterFrame end
  
  for i, colorData in ipairs(PRIORITY_COLOR_SCHEME) do
    if colorData and colorData.key then
      CreateFilterButton(filterFrame, colorData, i)
    end
  end
  
  return filterFrame
end

--------------------------------------------------
-- Update Filter UI from State
--------------------------------------------------
function UpdateFilterUI()
  if not filterCheckboxes then return end
  
  for colorKey, button in pairs(filterCheckboxes) do
    if button and button.icon and filterStates[colorKey] ~= nil then
      if filterStates[colorKey] then
        button.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
      else
        button.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
      end
    end
  end
end