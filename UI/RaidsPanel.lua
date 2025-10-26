--=============================================================================
-- AutoLFM: Raids Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.RaidsPanel then AutoLFM.UI.RaidsPanel = {} end
if not AutoLFM_RaidList then AutoLFM_RaidList = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local raidsPanelFrame = nil
local raidScrollFrame = nil
local raidListContentFrame = nil
local clickableFrames = {}
local checkButtons = {}
local raidSizeControlFrame = nil
local raidSizeSlider = nil
local raidSizeValueEditBox = nil
local raidSizeValueText = nil
local raidSizeLabelFrame = nil
local raidSizeLabelText = nil

-----------------------------------------------------------------------------
-- Size Controls
-----------------------------------------------------------------------------
local function GetRaidSizeState(raidTag)
  if not raidTag then
    return {isFixed = true, minSize = 10, maxSize = 10, currentSize = 10}
  end
  
  if not AutoLFM.Logic.Content.GetRaidByTag or not AutoLFM.Logic.Content.GetRaidSizeRange or not AutoLFM.Logic.Content.InitRaidSize then
    return {isFixed = true, minSize = 10, maxSize = 10, currentSize = 10}
  end
  
  local raid = AutoLFM.Logic.Content.GetRaidByTag(raidTag)
  if not raid then
    return {isFixed = true, minSize = 10, maxSize = 10, currentSize = 10}
  end
  
  local minSize, maxSize = AutoLFM.Logic.Content.GetRaidSizeRange(raidTag)
  local currentSize = AutoLFM.Logic.Content.InitRaidSize(raidTag)
  local isFixed = (minSize == maxSize)
  
  return {
    isFixed = isFixed,
    minSize = minSize,
    maxSize = maxSize,
    currentSize = currentSize
  }
end

local function SetFixedSizeState()
  if not raidSizeSlider or not raidSizeValueEditBox or not raidSizeValueText then return end
  
  raidSizeSlider:Hide()
  raidSizeValueEditBox:Hide()
  
  raidSizeValueText:SetText("10")
  raidSizeValueText:SetTextColor(0.5, 0.5, 0.5)
  raidSizeValueText:Show()
  
  if raidSizeLabelText then
    raidSizeLabelText:SetTextColor(1, 1, 1)
  end
  
  if AutoLFM.Logic.Content.SetRaidSize then
    AutoLFM.Logic.Content.SetRaidSize(10)
  end
end

local function SetVariableSizeState(sizeState)
  if not sizeState or not raidSizeSlider or not raidSizeValueEditBox or not raidSizeValueText then return end
  
  raidSizeValueText:Hide()
  
  raidSizeSlider:SetMinMaxValues(sizeState.minSize, sizeState.maxSize)
  raidSizeSlider:SetValue(sizeState.currentSize)
  raidSizeSlider:Show()
  
  raidSizeValueEditBox:SetText(tostring(sizeState.currentSize))
  raidSizeValueEditBox:SetTextColor(1, 1, 0)
  raidSizeValueEditBox:Show()
  raidSizeValueEditBox:SetFocus()
  raidSizeValueEditBox:HighlightText()
  
  if raidSizeLabelText then
    raidSizeLabelText:SetTextColor(1, 0.82, 0)
  end
end

local function UpdateSizeControlsForRaid(raidTag)
  local sizeState = GetRaidSizeState(raidTag)
  
  if sizeState.isFixed then
    SetFixedSizeState()
  else
    SetVariableSizeState(sizeState)
  end
end

-----------------------------------------------------------------------------
-- Raid List
-----------------------------------------------------------------------------
local function OnRaidCheckboxClick(checkbox, raidTag)
  if not checkbox or not raidTag then return end
  
  local isChecked = checkbox:GetChecked()
  
  if isChecked then
    for tag, otherCheckbox in pairs(checkButtons) do
      if otherCheckbox ~= checkbox then
        otherCheckbox:SetChecked(false)
        local parentFrame = otherCheckbox:GetParent()
        if parentFrame then
          parentFrame:SetBackdrop(nil)
        end
      end
    end
    
    if AutoLFM.Logic.Content.ToggleRaid then
      AutoLFM.Logic.Content.ToggleRaid(raidTag, true)
    end
    UpdateSizeControlsForRaid(raidTag)
  else
    if AutoLFM.Logic.Content.ToggleRaid then
      AutoLFM.Logic.Content.ToggleRaid(raidTag, false)
    end
    SetFixedSizeState()
  end
  
  checkbox:GetParent():SetBackdrop(nil)
end

local function CreateRaidRow(parent, raid, index, yOffset)
  if not parent or not raid then return nil end
  
  local isChecked = false
  if AutoLFM.Logic.Content.IsRaidSelected then
    isChecked = AutoLFM.Logic.Content.IsRaidSelected(raid.tag)
  end
  
  local sizeText = raid.sizeMin == raid.sizeMax and "(" .. raid.sizeMin .. ")" or "(" .. raid.sizeMin .. " - " .. raid.sizeMax .. ")"
  
  local clickableFrame = AutoLFM.UI.PanelBuilder.CreateSelectableRow({
    parent = parent,
    frameName = "ClickableRaidFrame" .. index,
    checkboxName = "RaidCheckbox" .. index,
    yOffset = yOffset,
    mainText = raid.name,
    rightText = sizeText,
    color = {r = 1, g = 0.82, b = 0},
    isChecked = isChecked,
    onCheckboxClick = function(checkbox, isChecked)
      OnRaidCheckboxClick(checkbox, raid.tag)
    end
  })
  
  if clickableFrame then
    checkButtons[raid.tag] = clickableFrame.checkbox
    table.insert(clickableFrames, clickableFrame)
  end
  
  return clickableFrame
end

function AutoLFM_RaidList.Display(parent)
  if not parent then return end
  
  for _, child in ipairs({parent:GetChildren()}) do
    child:Hide()
  end
  
  clickableFrames = {}
  checkButtons = {}
  
  local yOffset = 0
  
  for index = 1, table.getn(AutoLFM.Logic.Content.RAIDS or {}) do
    local raid = AutoLFM.Logic.Content.RAIDS[index]
    if raid then
      CreateRaidRow(parent, raid, index, yOffset)
      yOffset = yOffset + 20
    end
  end
end

function AutoLFM_RaidList.ClearSelection()
  if AutoLFM.Logic.Content.ClearRaids then
    AutoLFM.Logic.Content.ClearRaids()
  end
  
  AutoLFM.UI.PanelBuilder.ClearCheckboxes(checkButtons)
  
  SetFixedSizeState()
end

function AutoLFM_RaidList.ClearBackdrops()
  AutoLFM.UI.PanelBuilder.ClearBackdrops(clickableFrames)
end

function AutoLFM_RaidList.UpdateCheckboxes()
  if not AutoLFM.Logic.Content.IsRaidSelected then return end
  AutoLFM.UI.PanelBuilder.UpdateCheckboxes(checkButtons, AutoLFM.Logic.Content.IsRaidSelected)
end

function AutoLFM_RaidList.ShowSizeControls()
  if raidSizeControlFrame then
    raidSizeControlFrame:Show()
  end
  
  if not AutoLFM.Logic.Content.GetSelectedRaids then return end
  
  local selectedRaids = AutoLFM.Logic.Content.GetSelectedRaids()
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

function AutoLFM_RaidList.CreateSizeSlider(bottomZone)
  if not bottomZone then return end
  if raidSizeControlFrame then return end
  
  raidSizeControlFrame = CreateFrame("Frame", nil, bottomZone)
  raidSizeControlFrame:SetAllPoints(bottomZone)
  raidSizeControlFrame:Hide()
  
  raidSizeLabelFrame = CreateFrame("Button", nil, raidSizeControlFrame)
  raidSizeLabelFrame:SetWidth(65)
  raidSizeLabelFrame:SetHeight(20)
  raidSizeLabelFrame:SetPoint("LEFT", raidSizeControlFrame, "LEFT", 0, 0)
  
  raidSizeLabelText = raidSizeLabelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  raidSizeLabelText:SetPoint("LEFT", raidSizeLabelFrame, "LEFT", 0, 0)
  raidSizeLabelText:SetText("Raid size:")
  raidSizeLabelText:SetTextColor(1, 1, 1)
  
  raidSizeValueText = raidSizeControlFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  raidSizeValueText:SetPoint("LEFT", raidSizeLabelFrame, "RIGHT", -4, 0)
  raidSizeValueText:SetText("10")
  raidSizeValueText:SetTextColor(0.5, 0.5, 0.5)
  raidSizeValueText:Show()
  
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
  
  raidSizeSlider = CreateFrame("Slider", "AutoLFM_RaidSizeSlider", raidSizeControlFrame)
  raidSizeSlider:SetPoint("LEFT", raidSizeValueEditBox, "RIGHT", 0, 0)
  raidSizeSlider:SetWidth(115)
  raidSizeSlider:SetHeight(17)
  raidSizeSlider:SetMinMaxValues(10, 10)
  raidSizeSlider:SetValue(10)
  raidSizeSlider:SetValueStep(1)
  raidSizeSlider:SetOrientation("HORIZONTAL")
  raidSizeSlider:SetThumbTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "sliderButtonHorizontal")
  raidSizeSlider:SetBackdrop({
    bgFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "sliderBackground",
    edgeFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "sliderBorder",
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = {left = 3, right = 3, top = 6, bottom = 6}
  })
  raidSizeSlider:EnableMouse(true)
  raidSizeSlider:Hide()
  
  raidSizeLabelFrame:SetScript("OnClick", function()
    if raidSizeValueEditBox and raidSizeValueEditBox:IsShown() then
      raidSizeValueEditBox:SetFocus()
      raidSizeValueEditBox:HighlightText()
    end
  end)
  
  raidSizeLabelFrame:SetScript("OnEnter", function()
    if raidSizeValueEditBox and raidSizeValueEditBox:IsShown() then
      raidSizeLabelText:SetTextColor(0.3, 0.6, 1)
      GameTooltip:SetOwner(this, "ANCHOR_NONE")
      GameTooltip:SetPoint("BOTTOMLEFT", raidSizeControlFrame, "TOPLEFT", -10, -5)
      GameTooltip:SetText("Edit raid size", 1, 1, 1)
      GameTooltip:Show()
    end
  end)
  
  raidSizeLabelFrame:SetScript("OnLeave", function()
    raidSizeLabelText:SetTextColor(1, 1, 1)
    GameTooltip:Hide()
  end)
  
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
  
  raidSizeSlider:SetScript("OnValueChanged", function()
    pcall(function()
      local value = raidSizeSlider:GetValue()
      if AutoLFM.Logic.Content.SetRaidSize then
        AutoLFM.Logic.Content.SetRaidSize(value)
      end
      
      if raidSizeValueEditBox then
        raidSizeValueEditBox:SetText(tostring(value))
      end
    end)
  end)
  
  SetFixedSizeState()
end

-----------------------------------------------------------------------------
-- Public API (accessible via namespace)
-----------------------------------------------------------------------------
function AutoLFM.UI.RaidsPanel.DisplayList(parent)
  if AutoLFM_RaidList and AutoLFM_RaidList.Display then
    return AutoLFM_RaidList.Display(parent)
  end
end

function AutoLFM.UI.RaidsPanel.ClearSelection()
  if AutoLFM_RaidList and AutoLFM_RaidList.ClearSelection then
    return AutoLFM_RaidList.ClearSelection()
  end
end

function AutoLFM.UI.RaidsPanel.ClearBackdrops()
  if AutoLFM_RaidList and AutoLFM_RaidList.ClearBackdrops then
    return AutoLFM_RaidList.ClearBackdrops()
  end
end

function AutoLFM.UI.RaidsPanel.UpdateCheckboxes()
  if AutoLFM_RaidList and AutoLFM_RaidList.UpdateCheckboxes then
    return AutoLFM_RaidList.UpdateCheckboxes()
  end
end

function AutoLFM.UI.RaidsPanel.ShowSizeControls()
  if AutoLFM_RaidList and AutoLFM_RaidList.ShowSizeControls then
    return AutoLFM_RaidList.ShowSizeControls()
  end
end

function AutoLFM.UI.RaidsPanel.HideSizeControls()
  if AutoLFM_RaidList and AutoLFM_RaidList.HideSizeControls then
    return AutoLFM_RaidList.HideSizeControls()
  end
end

function AutoLFM.UI.RaidsPanel.CreateSizeSlider(bottomZone)
  if AutoLFM_RaidList and AutoLFM_RaidList.CreateSizeSlider then
    return AutoLFM_RaidList.CreateSizeSlider(bottomZone)
  end
end

-----------------------------------------------------------------------------
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.RaidsPanel.Create(parentFrame)
  if not parentFrame then return nil end
  if raidsPanelFrame then return raidsPanelFrame end
  
  local panelData = AutoLFM.UI.PanelBuilder.CreatePanel(parentFrame, "AutoLFM_RaidsPanel")
  if not panelData then return nil end
  
  raidsPanelFrame = panelData.panel
  
  panelData = AutoLFM.UI.PanelBuilder.AddScrollFrame(panelData, "AutoLFM_ScrollFrame_Raids")
  raidScrollFrame = panelData.scrollFrame
  raidListContentFrame = panelData.contentFrame
  
  if AutoLFM_RaidList and AutoLFM_RaidList.Display then
    AutoLFM_RaidList.Display(raidListContentFrame)
  end
  
  if AutoLFM_RaidList and AutoLFM_RaidList.CreateSizeSlider then
    AutoLFM_RaidList.CreateSizeSlider(panelData.bottomZone)
  end
  
  return raidsPanelFrame
end

function AutoLFM.UI.RaidsPanel.Show()
  AutoLFM.UI.PanelBuilder.ShowPanel(raidsPanelFrame, raidScrollFrame)
  
  if AutoLFM_RaidList and AutoLFM_RaidList.ShowSizeControls then
    AutoLFM_RaidList.ShowSizeControls()
  end
  
  if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearBackdrops then
    AutoLFM_DungeonList.ClearBackdrops()
  end
end

function AutoLFM.UI.RaidsPanel.Hide()
  AutoLFM.UI.PanelBuilder.HidePanel(raidsPanelFrame, raidScrollFrame)
end

function AutoLFM.UI.RaidsPanel.GetFrame()
  return raidsPanelFrame
end

function AutoLFM.UI.RaidsPanel.GetContentFrame()
  return raidListContentFrame
end

function AutoLFM.UI.RaidsPanel.GetScrollFrame()
  return raidScrollFrame
end

function AutoLFM.UI.RaidsPanel.Register()
  AutoLFM.UI.TabNavigation.RegisterPanel("raids",
    AutoLFM.UI.RaidsPanel.Show,
    AutoLFM.UI.RaidsPanel.Hide,
    function()
      if AutoLFM_RaidList and AutoLFM_RaidList.ShowSizeControls then
        AutoLFM_RaidList.ShowSizeControls()
      end
      if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearBackdrops then
        AutoLFM_DungeonList.ClearBackdrops()
      end
    end
  )
end
