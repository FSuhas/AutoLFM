--------------------------------------------------
-- Raid List UI
--------------------------------------------------
if not AutoLFM_RaidList then
  AutoLFM_RaidList = {
    clickableFrames = {},
    checkButtons = {}
  }
end

local raidSizeControlFrame = nil
local raidSizeValueEditBox = nil
local raidSizeValueText = nil
local raidSizeSlider = nil
local raidSizeLabelText = nil
local raidSizeLabelFrame = nil
local currentRaidTag = nil

--------------------------------------------------
-- Update Backdrop
--------------------------------------------------
local function UpdateRaidBackdrop(frame, checkbox)
  if checkbox:GetChecked() then
    frame:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      insets = {left = 1, right = 1, top = 1, bottom = 1},
    })
    frame:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
  else
    frame:SetBackdrop(nil)
  end
end

--------------------------------------------------
-- Reset To Default State (10, disabled)
--------------------------------------------------
local function ResetToDefaultState()
  if raidSizeSlider and raidSizeValueEditBox and raidSizeValueText and raidSizeLabelText then
    raidSizeSlider:Hide()
    raidSizeValueEditBox:Hide()
    
    raidSizeValueText:SetText("10")
    raidSizeValueText:SetTextColor(0.5, 0.5, 0.5)
    raidSizeValueText:Show()
    
    raidGroupSize = 10
  end
end

--------------------------------------------------
-- Show/Hide Size Controls
--------------------------------------------------
local function ShowSizeControls()
  if raidSizeControlFrame then
    raidSizeControlFrame:Show()
  end
  
  -- Si aucun raid sélectionné, afficher valeur par défaut 10 non modifiable
  if not currentRaidTag then
    ResetToDefaultState()
  end
end

local function HideSizeControls()
  if raidSizeControlFrame then
    raidSizeControlFrame:Hide()
  end
end

function AutoLFM_RaidList.ShowSizeControls()
  ShowSizeControls()
end

function AutoLFM_RaidList.HideSizeControls()
  HideSizeControls()
end

--------------------------------------------------
-- Update Size Slider Range
--------------------------------------------------
local function UpdateSizeSliderForRaid(raid)
  if not raid or not raidSizeSlider or not raidSizeValueEditBox or not raidSizeValueText or not raidSizeLabelText then return end
  
  currentRaidTag = raid.tag
  
  local minSize = raid.sizeMin or 10
  local maxSize = raid.sizeMax or 40
  
  raidGroupSize = minSize
  
  if raid.fixedSize or minSize == maxSize then
    -- Cas size fixe : texte statique gris, pas de slider ni editbox
    raidSizeSlider:Hide()
    raidSizeValueEditBox:Hide()
    
    raidSizeValueText:SetText(tostring(minSize))
    raidSizeValueText:SetTextColor(0.5, 0.5, 0.5)
    raidSizeValueText:Show()
  else
    -- Cas size variable : editbox + slider jaunes
    raidSizeValueText:Hide()
    
    if raidSizeSlider and raidSizeSlider.SetMinMaxValues then
      raidSizeSlider:SetMinMaxValues(minSize, maxSize)
      raidSizeSlider:SetValue(minSize)
      raidSizeSlider:Show()
      if raidSizeSlider.Enable then
        raidSizeSlider:Enable()
      end
    end
    
    if raidSizeValueEditBox and raidSizeValueEditBox.SetText then
      raidSizeValueEditBox:SetText(tostring(minSize))
      raidSizeValueEditBox:SetTextColor(1, 1, 0)
      raidSizeValueEditBox:Show()
      if raidSizeValueEditBox.Enable then
        raidSizeValueEditBox:Enable()
      end
      
      -- Focus + surlignage automatique
      raidSizeValueEditBox:SetFocus()
      raidSizeValueEditBox:HighlightText()
    end
  end
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Checkbox Click Handler
--------------------------------------------------
local function OnRaidCheckboxClick(checkbox, raidTag)
  local raid = nil
  
  if RAID_DATABASE then
    for _, r in ipairs(RAID_DATABASE) do
      if r and r.tag == raidTag then
        raid = r
        break
      end
    end
  end
  
  if checkbox:GetChecked() then
    for _, otherCheckbox in pairs(AutoLFM_RaidList.checkButtons) do
      if otherCheckbox ~= checkbox then
        otherCheckbox:SetChecked(false)
        otherCheckbox:GetParent():SetBackdrop(nil)
      end
    end
    
    if selectedRaidTags then
      selectedRaidTags = {raidTag}
    end
    
    if raid then
      UpdateSizeSliderForRaid(raid)
    end
  else
    if selectedRaidTags then
      selectedRaidTags = {}
    end
    currentRaidTag = nil
    
    -- Retour à l'état par défaut
    ResetToDefaultState()
  end
  
  UpdateRaidBackdrop(checkbox:GetParent(), checkbox)
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Create Single Raid Row
--------------------------------------------------
local function CreateRaidRow(parent, raid, index, yOffset)
  local clickableFrame = CreateFrame("Button", "ClickableRaidFrame" .. index, parent)
  clickableFrame:SetHeight(20)
  clickableFrame:SetWidth(300)
  clickableFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -yOffset)
  
  table.insert(AutoLFM_RaidList.clickableFrames, clickableFrame)
  
  local raidTag = raid.tag
  local raidName = raid.name
  
  local checkbox = CreateFrame("CheckButton", "RaidCheckbox" .. index, clickableFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(20)
  checkbox:SetHeight(20)
  checkbox:SetPoint("LEFT", clickableFrame, "LEFT", 0, 0)
  
  local sizeLabel = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sizeLabel:SetPoint("RIGHT", clickableFrame, "RIGHT", -10, 0)
  local sizeText = raid.sizeMin == raid.sizeMax and "(" .. raid.sizeMin .. ")" or "(" .. raid.sizeMin .. " - " .. raid.sizeMax .. ")"
  sizeLabel:SetText(sizeText)
  
  local label = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
  label:SetText(raidName)
  
  AutoLFM_RaidList.checkButtons[raidTag] = checkbox
  
  checkbox:SetScript("OnClick", function()
    OnRaidCheckboxClick(checkbox, raidTag)
  end)
  
  clickableFrame:SetScript("OnClick", function()
    checkbox:SetChecked(not checkbox:GetChecked())
    checkbox:GetScript("OnClick")()
  end)
  
  clickableFrame:SetScript("OnEnter", function()
    clickableFrame:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8X8",
      insets = {left = 1, right = 1, top = 1, bottom = 1},
    })
    clickableFrame:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
    checkbox:LockHighlight()
  end)
  
  clickableFrame:SetScript("OnLeave", function()
    if not checkbox:GetChecked() then
      clickableFrame:SetBackdrop(nil)
    else
      UpdateRaidBackdrop(clickableFrame, checkbox)
    end
    checkbox:UnlockHighlight()
  end)
  
  return clickableFrame
end

--------------------------------------------------
-- Display All Raids
--------------------------------------------------
function AutoLFM_RaidList.Display(parent)
  if not parent then return end
  
  for _, child in ipairs({parent:GetChildren()}) do
    child:Hide()
  end
  
  AutoLFM_RaidList.clickableFrames = {}
  
  local yOffset = 0
  
  for index, raid in ipairs(RAID_DATABASE or {}) do
    if raid then
      CreateRaidRow(parent, raid, index, yOffset)
      yOffset = yOffset + 20
    end
  end
end

--------------------------------------------------
-- Clear Selection
--------------------------------------------------
function AutoLFM_RaidList.ClearSelection()
  for _, checkbox in pairs(AutoLFM_RaidList.checkButtons) do
    checkbox:SetChecked(false)
  end
  if selectedRaidTags then
    selectedRaidTags = {}
  end
  currentRaidTag = nil
  
  -- Retour à l'état par défaut
  ResetToDefaultState()
end

--------------------------------------------------
-- Clear Backdrops
--------------------------------------------------
function AutoLFM_RaidList.ClearBackdrops()
  for _, frame in pairs(AutoLFM_RaidList.clickableFrames) do
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end

--------------------------------------------------
-- Create Raid Size Slider
--------------------------------------------------
function AutoLFM_RaidList.CreateSizeSlider(parentFrame)
  if not parentFrame then return end
  
  raidSizeControlFrame = CreateFrame("Frame", nil, parentFrame)
  raidSizeControlFrame:SetPoint("BOTTOM", parentFrame, "BOTTOM", -16, 75)
  raidSizeControlFrame:SetWidth(300)
  raidSizeControlFrame:SetHeight(30)
  raidSizeControlFrame:Hide()
  
  -- Label "Raid size:" (toujours blanc)
  raidSizeLabelFrame = CreateFrame("Button", nil, raidSizeControlFrame)
  raidSizeLabelFrame:SetWidth(65)
  raidSizeLabelFrame:SetHeight(20)
  raidSizeLabelFrame:SetPoint("LEFT", raidSizeControlFrame, "LEFT", 0, 0)
  
  raidSizeLabelText = raidSizeLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  raidSizeLabelText:SetPoint("LEFT", raidSizeLabelFrame, "LEFT", 0, 0)
  raidSizeLabelText:SetText("Raid size:")
  raidSizeLabelText:SetTextColor(1, 1, 1)
  
  -- Texte statique pour valeur fixe (gris, collé au label)
  raidSizeValueText = raidSizeControlFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  raidSizeValueText:SetPoint("LEFT", raidSizeLabelFrame, "RIGHT", -4, 0)
  raidSizeValueText:SetText("10")
  raidSizeValueText:SetTextColor(0.5, 0.5, 0.5)
  raidSizeValueText:Show()
  
  -- EditBox pour valeur variable (jaune, aligné sur le texte statique)
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
  
  -- Slider
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
  
  -- Clic sur le label "Raid size:" → sélectionne l'EditBox (si visible)
  raidSizeLabelFrame:SetScript("OnClick", function()
    if raidSizeValueEditBox and raidSizeValueEditBox:IsShown() then
      raidSizeValueEditBox:SetFocus()
      raidSizeValueEditBox:HighlightText()
    end
  end)
  
  -- Focus sur l'EditBox → sélectionne tout le texte
  raidSizeValueEditBox:SetScript("OnEditFocusGained", function()
    raidSizeValueEditBox:HighlightText()
  end)
  
  raidSizeSlider:SetScript("OnValueChanged", function()
    local value = raidSizeSlider:GetValue()
    raidGroupSize = value
    
    if raidSizeValueEditBox then
      raidSizeValueEditBox:SetText(tostring(value))
    end
    
    if UpdateDynamicMessage then
      UpdateDynamicMessage()
    end
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
  
  -- Initialiser à l'état désactivé APRÈS création complète
  ResetToDefaultState()
end

--------------------------------------------------
-- Get Current Raid Size
--------------------------------------------------
function AutoLFM_RaidList.GetSize()
  return raidGroupSize or 40
end