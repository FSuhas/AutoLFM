--------------------------------------------------
-- Dungeon Color Filters
--------------------------------------------------
local filterCheckboxes = {}
local filterStates = {}

--------------------------------------------------
-- Initialize Filter States
--------------------------------------------------
local function InitializeFilterStates()
  if not filterStates or table.getn(filterStates) == 0 then
    filterStates = {}
    for _, color in ipairs(priorityColors or {}) do
      filterStates[color.key] = true
    end
  end
end

InitializeFilterStates()

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
  InitializeFilterStates()
  
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
  for _, color in ipairs(priorityColors or {}) do
    if color.priority == priority then
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
    AutoLFM_DungeonList.Display(contentFrame)
  end
end

--------------------------------------------------
-- Create Filter Checkboxes
--------------------------------------------------
function CreateDungeonFilterCheckboxes(parent)
  InitializeFilterStates()
  
  local filterFrame = CreateFrame("Frame", "DungeonFilterFrame", parent)
  filterFrame:SetPoint("BOTTOM", parent, "BOTTOM", -16, 75)
  filterFrame:SetWidth(300)
  filterFrame:SetHeight(30)
  
  for i, colorData in ipairs(priorityColors or {}) do
    local button = CreateFrame("Button", "DungeonFilter_"..colorData.key, filterFrame)
    button:SetWidth(20)
    button:SetHeight(20)
    button:SetPoint("LEFT", filterFrame, "LEFT", (i - 1) * 40, 0)
    
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", button, "CENTER", 0, 0)
    icon:SetVertexColor(colorData.r, colorData.g, colorData.b)
    
    if filterStates[colorData.key] == nil then
      filterStates[colorData.key] = true
    end
    
    -- Set initial texture based on filter state
    if filterStates[colorData.key] then
      icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    else
      icon:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
    end
    
    button.icon = icon
    button.color = {colorData.r, colorData.g, colorData.b}
    
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
  
  return filterFrame
end