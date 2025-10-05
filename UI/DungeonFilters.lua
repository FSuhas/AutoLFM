--------------------------------------------------
-- Dungeon Color Filters
--------------------------------------------------
local filterCheckboxes = {}
local filterStates = {
  green = true,
  yellow = true,
  orange = true,
  red = true,
  gray = true
}

--------------------------------------------------
-- Save/Load Filter States
--------------------------------------------------
function SaveDungeonFilters()
  if not AutoLFM_SavedVariables or not uniqueIdentifier then return end
  if not AutoLFM_SavedVariables[uniqueIdentifier] then
    AutoLFM_SavedVariables[uniqueIdentifier] = {}
  end
  AutoLFM_SavedVariables[uniqueIdentifier].dungeonFilters = filterStates
end

function LoadDungeonFilters()
  if not filterStates then
    filterStates = {green = true, yellow = true, orange = true, red = true, gray = true}
  end
  
  if AutoLFM_SavedVariables and AutoLFM_SavedVariables[uniqueIdentifier] and AutoLFM_SavedVariables[uniqueIdentifier].dungeonFilters then
    for key, value in pairs(AutoLFM_SavedVariables[uniqueIdentifier].dungeonFilters) do
      filterStates[key] = value
    end
  else
    if AutoLFM_SavedVariables and AutoLFM_SavedVariables[uniqueIdentifier] then
      AutoLFM_SavedVariables[uniqueIdentifier].dungeonFilters = filterStates
    end
  end
end

--------------------------------------------------
-- Check if Priority Should Be Displayed
--------------------------------------------------
function ShouldDisplayPriority(priority)
  if priority == 1 then
    return filterStates.green
  elseif priority == 2 then
    return filterStates.yellow
  elseif priority == 3 then
    return filterStates.orange
  elseif priority == 4 then
    return filterStates.red
  elseif priority == 5 then
    return filterStates.gray
  end
  return true
end

--------------------------------------------------
-- Refresh Dungeon List
--------------------------------------------------
function RefreshDungeonList()
  if AutoLFM_DungeonList and contentFrame then
    AutoLFM_DungeonList.Display(contentFrame)
  end
end

--------------------------------------------------
-- Create Filter Checkboxes
--------------------------------------------------
function CreateDungeonFilterCheckboxes(parent)
  if not filterStates then
    filterStates = {green = true, yellow = true, orange = true, red = true, gray = true}
  end
  
  local filterFrame = CreateFrame("Frame", "DungeonFilterFrame", parent)
  filterFrame:SetPoint("BOTTOM", parent, "BOTTOM", -16, 75)
  filterFrame:SetWidth(300)
  filterFrame:SetHeight(30)
  
  local filters = {
    {
      key = "gray", 
      color = {0.5, 0.5, 0.5}, 
      x = 0,
      iconChecked = "Interface\\Buttons\\UI-CheckBox-Check",
      iconUnchecked = "Interface\\Buttons\\UI-CheckBox-Check-Disabled"
    },
    {
      key = "green", 
      color = {0.25, 0.75, 0.25}, 
      x = 40,
      iconChecked = "Interface\\Buttons\\UI-CheckBox-Check",
      iconUnchecked = "Interface\\Buttons\\UI-CheckBox-Check-Disabled"
    },
    {
      key = "yellow", 
      color = {1.0, 1.0, 0}, 
      x = 80,
      iconChecked = "Interface\\Buttons\\UI-CheckBox-Check",
      iconUnchecked = "Interface\\Buttons\\UI-CheckBox-Check-Disabled"
    },
    {
      key = "orange", 
      color = {1.0, 0.49, 0.04}, 
      x = 120,
      iconChecked = "Interface\\Buttons\\UI-CheckBox-Check",
      iconUnchecked = "Interface\\Buttons\\UI-CheckBox-Check-Disabled"
    },
    {
      key = "red", 
      color = {0.9, 0.1, 0.1}, 
      x = 160,
      iconChecked = "Interface\\Buttons\\UI-CheckBox-Check",
      iconUnchecked = "Interface\\Buttons\\UI-CheckBox-Check-Disabled"
    }
  }
  
  for _, filter in ipairs(filters) do
    local button = CreateFrame("Button", "DungeonFilter_"..filter.key, filterFrame)
    button:SetWidth(20)
    button:SetHeight(20)
    button:SetPoint("LEFT", filterFrame, "LEFT", filter.x, 0)
    
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    icon:SetVertexColor(filter.color[1], filter.color[2], filter.color[3])
    
    if filterStates[filter.key] == nil then
      filterStates[filter.key] = true
    end
    
    if filterStates[filter.key] then
      icon:SetTexture(filter.iconChecked)
    else
      icon:SetTexture(filter.iconUnchecked)
    end
    
    button.icon = icon
    button.iconChecked = filter.iconChecked
    button.iconUnchecked = filter.iconUnchecked
    button.color = filter.color
    
    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetWidth(24)
    highlight:SetHeight(24)
    highlight:SetPoint("CENTER", button, "CENTER", 0, 0)
    highlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    highlight:SetBlendMode("ADD")
    
    local currentKey = filter.key
    button:SetScript("OnClick", function()
      if not filterStates then
        filterStates = {green = true, yellow = true, orange = true, red = true, gray = true}
      end
      
      filterStates[currentKey] = not filterStates[currentKey]
      
      if filterStates[currentKey] then
        button.icon:SetTexture(button.iconChecked)
      else
        button.icon:SetTexture(button.iconUnchecked)
      end
      
      SaveDungeonFilters()
      RefreshDungeonList()
    end)
    
    filterCheckboxes[filter.key] = button
  end
  
  return filterFrame
end