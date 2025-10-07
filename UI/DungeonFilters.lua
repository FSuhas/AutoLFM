--------------------------------------------------
-- Dungeon Color Filters
--------------------------------------------------
local filterCheckboxes = {}
local filterStates = {}
local filtersInitialized = false

--------------------------------------------------
-- Initialize Filter States
--------------------------------------------------
local function InitializeFilterStates()
  if filtersInitialized then return end
  
  filterStates = {}
  if colors then
    for _, color in ipairs(colors) do
      if color and color.key then
        filterStates[color.key] = true
      end
    end
  end
  
  filtersInitialized = true
end

--------------------------------------------------
-- Save/Load Filter States
--------------------------------------------------
function SaveDungeonFilters()
  if not AutoLFM_SavedVariables then return end
  if not uniqueIdentifier then return end
  if not AutoLFM_SavedVariables[uniqueIdentifier] then
    AutoLFM_SavedVariables[uniqueIdentifier] = {}
  end
  AutoLFM_SavedVariables[uniqueIdentifier].dungeonFilters = filterStates
end

function LoadDungeonFilters()
  if not AutoLFM_SavedVariables then return end
  if not uniqueIdentifier then return end
  if not AutoLFM_SavedVariables[uniqueIdentifier] then
    AutoLFM_SavedVariables[uniqueIdentifier] = {}
  end
  
  if AutoLFM_SavedVariables[uniqueIdentifier].dungeonFilters then
    for key, value in pairs(AutoLFM_SavedVariables[uniqueIdentifier].dungeonFilters) do
      filterStates[key] = value
    end
  else
    AutoLFM_SavedVariables[uniqueIdentifier].dungeonFilters = filterStates
  end
end

--------------------------------------------------
-- Check if Priority Should Be Displayed
--------------------------------------------------
function ShouldDisplayPriority(priority)
  if not priority then return true end
  if not colors then return true end
  
  for _, color in ipairs(colors) do
    if color and color.priority == priority and color.key then
      return filterStates[color.key] or false
    end
  end
  return true
end

--------------------------------------------------
-- Refresh Dungeon List
--------------------------------------------------
function RefreshDungeonList()
  if AutoLFM_DungeonList and contentFrame then
    if type(AutoLFM_DungeonList.Display) == "function" then
      AutoLFM_DungeonList.Display(contentFrame)
    end
  end
end

--------------------------------------------------
-- Create Filter Checkboxes
--------------------------------------------------
function CreateDungeonFilterCheckboxes(parent)
  if not parent then return nil end
  
  InitializeFilterStates()
  
  local filterFrame = CreateFrame("Frame", "DungeonFilterFrame", parent)
  filterFrame:SetPoint("BOTTOM", parent, "BOTTOM", -16, 75)
  filterFrame:SetWidth(300)
  filterFrame:SetHeight(30)
  
  if not colors then return filterFrame end
  
  for i, colorData in ipairs(colors) do
    if colorData and colorData.key then
      local button = CreateFrame("Button", "DungeonFilter_"..colorData.key, filterFrame)
      button:SetWidth(20)
      button:SetHeight(20)
      button:SetPoint("LEFT", filterFrame, "LEFT", (i - 1) * 40, 0)
      
      local icon = button:CreateTexture(nil, "ARTWORK")
      icon:SetWidth(20)
      icon:SetHeight(20)
      icon:SetPoint("CENTER", button, "CENTER", 0, 0)
      if colorData.r and colorData.g and colorData.b then
        icon:SetVertexColor(colorData.r, colorData.g, colorData.b)
      end
      
      if filterStates[colorData.key] == nil then
        filterStates[colorData.key] = true
      end
      
      if filterStates[colorData.key] then
        icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
      else
        icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
      end
      
      button.icon = icon
      button.color = {colorData.r or 0.5, colorData.g or 0.5, colorData.b or 0.5}
      
      local highlight = button:CreateTexture(nil, "HIGHLIGHT")
      highlight:SetWidth(24)
      highlight:SetHeight(24)
      highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
      highlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
      highlight:SetBlendMode("ADD")
      
      local currentKey = colorData.key
      button:SetScript("OnClick", function()
        InitializeFilterStates()
        
        filterStates[currentKey] = not filterStates[currentKey]
        
        if filterStates[currentKey] then
          button.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        else
          button.icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
        end
        
        SaveDungeonFilters()
        RefreshDungeonList()
      end)
      
      filterCheckboxes[colorData.key] = button
    end
  end
  
  return filterFrame
end