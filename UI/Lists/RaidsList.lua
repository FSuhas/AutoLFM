--------------------------------------------------
-- Raids List UI
--------------------------------------------------

if not AutoLFM_RaidList then
  AutoLFM_RaidList = {}
end

local clickableFrames = {}
local checkButtons = {}

-- Raid size controls
local raidSizeControlFrame = nil
local raidSizeSlider = nil
local raidSizeValueEditBox = nil
local raidSizeValueText = nil
local raidSizeLabelFrame = nil
local raidSizeLabelText = nil

--------------------------------------------------
-- Set Fixed Size State (10 players, disabled)
--------------------------------------------------
local function SetFixedSizeState()
  if not raidSizeSlider or not raidSizeValueEditBox or not raidSizeValueText then return end
  
  raidSizeSlider:Hide()
  raidSizeValueEditBox:Hide()
  
  raidSizeValueText:SetText("10")
  raidSizeValueText:SetTextColor(0.5, 0.5, 0.5)
  raidSizeValueText:Show()
  
  SetRaidGroupSize(10)
end

--------------------------------------------------
-- Set Variable Size State (slider + editbox)
--------------------------------------------------
local function SetVariableSizeState(raidTag)
  if not raidTag or not raidSizeSlider or not raidSizeValueEditBox or not raidSizeValueText then return end
  
  local minSize, maxSize = GetRaidSizeRange(raidTag)
  local currentSize = InitializeRaidSizeForTag(raidTag)
  
  raidSizeValueText:Hide()
  
  raidSizeSlider:SetMinMaxValues(minSize, maxSize)
  raidSizeSlider:SetValue(currentSize)
  raidSizeSlider:Show()
  
  raidSizeValueEditBox:SetText(tostring(currentSize))
  raidSizeValueEditBox:SetTextColor(1, 1, 0)
  raidSizeValueEditBox:Show()
  raidSizeValueEditBox:SetFocus()
  raidSizeValueEditBox:HighlightText()
end

--------------------------------------------------
-- Update Size Controls for Raid
--------------------------------------------------
local function UpdateSizeControlsForRaid(raidTag)
  if not raidTag then
    SetFixedSizeState()
    return
  end
  
  local raid = GetRaidByTag(raidTag)
  if not raid then
    SetFixedSizeState()
    return
  end
  
  local minSize, maxSize = GetRaidSizeRange(raidTag)
  local isFixed = (minSize == maxSize)
  
  if isFixed then
    SetFixedSizeState()
  else
    SetVariableSizeState(raidTag)
  end
end

--------------------------------------------------
-- Checkbox Click Handler
--------------------------------------------------
local function OnRaidCheckboxClick(checkbox, raidTag)
  if not checkbox or not raidTag then return end
  
  local isChecked = checkbox:GetChecked()
  
  if isChecked then
    -- Uncheck all other checkboxes (only one raid at a time)
    for tag, otherCheckbox in pairs(checkButtons) do
      if otherCheckbox ~= checkbox then
        otherCheckbox:SetChecked(false)
        -- Remove backdrop from unselected items
        local parentFrame = otherCheckbox:GetParent()
        if parentFrame then
          parentFrame:SetBackdrop(nil)
        end
      end
    end
    
    ToggleRaidSelection(raidTag, true)
    UpdateSizeControlsForRaid(raidTag)
  else
    ToggleRaidSelection(raidTag, false)
    SetFixedSizeState()
  end
  
  -- No backdrop for selected state
  checkbox:GetParent():SetBackdrop(nil)
end

--------------------------------------------------
-- Create Single Raid Row
--------------------------------------------------
local function CreateRaidRow(parent, raid, index, yOffset)
  if not parent or not raid then return nil end
  
  local clickableFrame = CreateFrame("Button", "ClickableRaidFrame" .. index, parent)
  clickableFrame:SetHeight(20)
  clickableFrame:SetWidth(300)
  clickableFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -yOffset)
  
  -- Checkbox
  local checkbox = CreateFrame("CheckButton", "RaidCheckbox" .. index, clickableFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(20)
  checkbox:SetHeight(20)
  checkbox:SetPoint("LEFT", clickableFrame, "LEFT", 0, 0)
  
  checkbox:SetChecked(IsRaidSelected(raid.tag))
  
  checkButtons[raid.tag] = checkbox
  
  -- Size label
  local sizeLabel = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sizeLabel:SetPoint("RIGHT", clickableFrame, "RIGHT", -10, 0)
  local sizeText = raid.sizeMin == raid.sizeMax and "(" .. raid.sizeMin .. ")" or "(" .. raid.sizeMin .. " - " .. raid.sizeMax .. ")"
  sizeLabel:SetText(sizeText)
  
  -- Name label
  local label = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
  label:SetText(raid.name)
  
  -- Store original colors
  local originalLabelR, originalLabelG, originalLabelB = label:GetTextColor()
  local originalSizeR, originalSizeG, originalSizeB = sizeLabel:GetTextColor()
  
  -- Frame click handler
  clickableFrame:SetScript("OnClick", function()
    checkbox:SetChecked(not checkbox:GetChecked())
    OnRaidCheckboxClick(checkbox, raid.tag)
  end)
  
  -- Hover handlers
  clickableFrame:SetScript("OnEnter", function()
    clickableFrame:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      insets = {left = 1, right = 1, top = 1, bottom = 1},
    })
    clickableFrame:SetBackdropColor(1, 0.82, 0, 0.3)
    label:SetTextColor(1, 1, 1)
    sizeLabel:SetTextColor(1, 1, 1)
    checkbox:LockHighlight()
  end)
  
  clickableFrame:SetScript("OnLeave", function()
    -- Always remove backdrop on leave (no persistent selection background)
    clickableFrame:SetBackdrop(nil)
    label:SetTextColor(originalLabelR, originalLabelG, originalLabelB)
    sizeLabel:SetTextColor(originalSizeR, originalSizeG, originalSizeB)
    checkbox:UnlockHighlight()
  end)
  
  -- Checkbox click handler
  checkbox:SetScript("OnClick", function()
    OnRaidCheckboxClick(checkbox, raid.tag)
  end)
  
  table.insert(clickableFrames, clickableFrame)
  
  return clickableFrame
end

--------------------------------------------------
-- Display All Raids
--------------------------------------------------
function AutoLFM_RaidList.Display(parent)
  if not parent then return end
  
  -- Hide all existing children
  for _, child in ipairs({parent:GetChildren()}) do
    child:Hide()
  end
  
  clickableFrames = {}
  checkButtons = {}
  
  local yOffset = 0
  
  for index, raid in ipairs(RAID_DATABASE or {}) do
    if raid then
      CreateRaidRow(parent, raid, index, yOffset)
      yOffset = yOffset + 20
    end
  end
end

--------------------------------------------------
-- Clear Selection UI
--------------------------------------------------
function AutoLFM_RaidList.ClearSelection()
  ClearRaidSelection()
  
  -- Update checkboxes
  for _, checkbox in pairs(checkButtons) do
    if checkbox and checkbox.SetChecked then
      checkbox:SetChecked(false)
    end
  end
  
  SetFixedSizeState()
end

--------------------------------------------------
-- Clear Backdrops
--------------------------------------------------
function AutoLFM_RaidList.ClearBackdrops()
  for _, frame in pairs(clickableFrames) do
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end

--------------------------------------------------
-- Update Checkboxes from State
--------------------------------------------------
function AutoLFM_RaidList.UpdateCheckboxes()
  for raidTag, checkbox in pairs(checkButtons) do
    if checkbox and checkbox.SetChecked then
      checkbox:SetChecked(IsRaidSelected(raidTag))
    end
  end
end

--------------------------------------------------
-- Show/Hide Size Controls
--------------------------------------------------
function AutoLFM_RaidList.ShowSizeControls()
  if raidSizeControlFrame then
    raidSizeControlFrame:Show()
  end
  
  -- Update based on current selection
  local selectedRaids = GetSelectedRaidsList()
  if selectedRaids and table.getn(selectedRaids) > 0 then
    UpdateSizeControlsForRaid(selectedRaids[1])
  else
    SetFixedSizeState()
  end
end

function AutoLFM_RaidList.HideSizeControls()
  if raidSizeControlFrame then
    raidSizeControlFrame:Hide()
  end
end

--------------------------------------------------
-- Create Raid Size Controls
--------------------------------------------------
function AutoLFM_RaidList.CreateSizeSlider(parentFrame)
  if not parentFrame then return end
  if raidSizeControlFrame then return end
  
  raidSizeControlFrame = CreateFrame("Frame", nil, parentFrame)
  raidSizeControlFrame:SetPoint("BOTTOM", parentFrame, "BOTTOM", -16, 75)
  raidSizeControlFrame:SetWidth(300)
  raidSizeControlFrame:SetHeight(30)
  raidSizeControlFrame:Hide()
  
  -- Label "Raid size:"
  raidSizeLabelFrame = CreateFrame("Button", nil, raidSizeControlFrame)
  raidSizeLabelFrame:SetWidth(65)
  raidSizeLabelFrame:SetHeight(20)
  raidSizeLabelFrame:SetPoint("LEFT", raidSizeControlFrame, "LEFT", 0, 0)
  
  raidSizeLabelText = raidSizeLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  raidSizeLabelText:SetPoint("LEFT", raidSizeLabelFrame, "LEFT", 0, 0)
  raidSizeLabelText:SetText("Raid size:")
  raidSizeLabelText:SetTextColor(1, 1, 1)
  
  -- Static text (for fixed size raids)
  raidSizeValueText = raidSizeControlFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  raidSizeValueText:SetPoint("LEFT", raidSizeLabelFrame, "RIGHT", -4, 0)
  raidSizeValueText:SetText("10")
  raidSizeValueText:SetTextColor(0.5, 0.5, 0.5)
  raidSizeValueText:Show()
  
  -- EditBox (for variable size raids)
  raidSizeValueEditBox = CreateFrame("EditBox", "AutoLFM_RaidSizeEditBox", raidSizeControlFrame)
  raidSizeValueEditBox:SetPoint("LEFT", raidSizeLabelFrame, "RIGHT", -4, 0)
  raidSizeValueEditBox:SetWidth(25)
  raidSizeValueEditBox:SetHeight(20)
  raidSizeValueEditBox:SetFont("Fonts\\FRIZQT__.TTF", 12)
  raidSizeValueEditBox:SetJustifyH("LEFT")
  raidSizeValueEditBox:SetAutoFocus(false)
  raidSizeValueEditBox:SetMaxLetters(2)
  raidSizeValueEditBox:SetText("10")
  raidSizeValueEditBox:SetTextColor(1, 1, 0)
  raidSizeValueEditBox:Hide()
  
  -- Slider (for variable size raids)
  raidSizeSlider = CreateFrame("Slider", "AutoLFM_RaidSizeSlider", raidSizeControlFrame)
  raidSizeSlider:SetPoint("LEFT", raidSizeValueEditBox, "RIGHT", 0, 0)
  raidSizeSlider:SetWidth(115)
  raidSizeSlider:SetHeight(17)
  raidSizeSlider:SetMinMaxValues(10, 10)
  raidSizeSlider:SetValue(10)
  raidSizeSlider:SetValueStep(1)
  raidSizeSlider:SetOrientation("HORIZONTAL")
  raidSizeSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
  raidSizeSlider:SetBackdrop({
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = {left = 3, right = 3, top = 6, bottom = 6}
  })
  raidSizeSlider:EnableMouse(true)
  raidSizeSlider:Hide()
  
  -- Label click focuses editbox
  raidSizeLabelFrame:SetScript("OnClick", function()
    if raidSizeValueEditBox and raidSizeValueEditBox:IsShown() then
      raidSizeValueEditBox:SetFocus()
      raidSizeValueEditBox:HighlightText()
    end
  end)
  
  -- EditBox handlers
  raidSizeValueEditBox:SetScript("OnEditFocusGained", function()
    raidSizeValueEditBox:HighlightText()
  end)
  
  raidSizeValueEditBox:SetScript("OnTextChanged", function()
    local value = tonumber(raidSizeValueEditBox:GetText())
    if value and raidSizeSlider and raidSizeSlider:IsShown() then
      local minVal, maxVal = raidSizeSlider:GetMinMaxValues()
      if value >= minVal and value <= maxVal then
        raidSizeSlider:SetValue(value)
      end
    end
  end)
  
  raidSizeValueEditBox:SetScript("OnEnterPressed", function()
    raidSizeValueEditBox:ClearFocus()
  end)
  
  raidSizeValueEditBox:SetScript("OnEscapePressed", function()
    raidSizeValueEditBox:ClearFocus()
  end)
  
  -- Slider handler
  raidSizeSlider:SetScript("OnValueChanged", function()
    local value = raidSizeSlider:GetValue()
    SetRaidGroupSize(value)
    
    if raidSizeValueEditBox then
      raidSizeValueEditBox:SetText(tostring(value))
    end
  end)
  
  SetFixedSizeState()
end