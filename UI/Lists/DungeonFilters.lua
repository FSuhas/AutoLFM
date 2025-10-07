--------------------------------------------------
-- Dungeon Color Filters
--------------------------------------------------

local filterCheckboxes = {}
filterStates = {}
local filtersInitialized = false
local filterFrameLabelFrame = nil
local filterFrameLabelText = nil

--------------------------------------------------
-- Initialize Filter States
--------------------------------------------------
local function InitializeFilterStates()
  if filtersInitialized then return end
  
  -- Load saved filters first
  LoadColorFilterSettings()
  
  -- If still empty, set defaults
  if not filterStates or not next(filterStates) then
    filterStates = {}
    if PRIORITY_COLOR_SCHEME then
      for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
        if color and color.key then
          filterStates[color.key] = true
        end
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
  
  -- Ensure filters are initialized
  if not filtersInitialized then
    InitializeFilterStates()
  end
  
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
-- Create Filter Checkbox
--------------------------------------------------
local function CreateFilterCheckbox(parentFrame, colorData, index, xOffset)
  if not parentFrame or not colorData then return nil end
  
  -- Create checkbox
  local checkbox = CreateFrame("CheckButton", "DungeonFilter_" .. colorData.key, parentFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(20)
  checkbox:SetHeight(20)
  checkbox:SetPoint("LEFT", parentFrame, "LEFT", xOffset, 0)
  
  -- Apply color to checkbox textures
  local normalTexture = checkbox:GetNormalTexture()
  local checkedTexture = checkbox:GetCheckedTexture()
  local disabledCheckedTexture = checkbox:GetDisabledCheckedTexture()
  
  if normalTexture then
    normalTexture:SetVertexColor(colorData.r, colorData.g, colorData.b)
  end
  
  if checkedTexture then
    checkedTexture:SetVertexColor(colorData.r, colorData.g, colorData.b)
  end
  
  if disabledCheckedTexture then
    disabledCheckedTexture:SetVertexColor(colorData.r, colorData.g, colorData.b)
  end
  
  -- Initialize state from saved settings
  if filterStates[colorData.key] == nil then
    filterStates[colorData.key] = true
  end
  
  -- Set checked state
  checkbox:SetChecked(filterStates[colorData.key])
  
  -- Click handler
  checkbox:SetScript("OnClick", function()
    local currentKey = colorData.key
    filterStates[currentKey] = checkbox:GetChecked()
    
    -- Save and refresh
    SaveColorFilterSettings()
    RefreshDungeonDisplay()
  end)
  
  filterCheckboxes[colorData.key] = checkbox
  
  return checkbox
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

  -- Label "Filters:"
  filterFrameLabelFrame = CreateFrame("Button", nil, filterFrame)
  filterFrameLabelFrame:SetWidth(50)
  filterFrameLabelFrame:SetHeight(20)
  filterFrameLabelFrame:SetPoint("LEFT", filterFrame, "LEFT", 0, 0)
  
  filterFrameLabelText = filterFrameLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  filterFrameLabelText:SetPoint("LEFT", filterFrameLabelFrame, "LEFT", 0, 0)
  filterFrameLabelText:SetText("Filters:")
  filterFrameLabelText:SetTextColor(1, 1, 1)
  
  if not PRIORITY_COLOR_SCHEME then return filterFrame end
  
  -- Calculer la largeur du label pour décaler les boutons
  local labelWidth = filterFrameLabelText:GetStringWidth() + 15
  
  -- Ordre personnalisé : gris, vert, jaune, orange, rouge
  local customOrder = {"gray", "green", "yellow", "orange", "red"}
  local orderedColors = {}
  
  for _, key in ipairs(customOrder) do
    for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
      if color.key == key then
        table.insert(orderedColors, color)
        break
      end
    end
  end
  
  -- Créer les checkboxes dans l'ordre personnalisé
  for i, colorData in ipairs(orderedColors) do
    if colorData and colorData.key then
      local xOffset = labelWidth + (i - 1) * 30
      CreateFilterCheckbox(filterFrame, colorData, i, xOffset)
    end
  end
  
  return filterFrame
end

--------------------------------------------------
-- Update Filter UI from State
--------------------------------------------------
function UpdateFilterUI()
  if not filterCheckboxes then return end
  
  for colorKey, checkbox in pairs(filterCheckboxes) do
    if checkbox and checkbox.SetChecked and filterStates[colorKey] ~= nil then
      checkbox:SetChecked(filterStates[colorKey])
    end
  end
end