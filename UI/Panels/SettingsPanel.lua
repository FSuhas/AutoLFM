--------------------------------------------------
-- Settings Panel (More Tab)
--------------------------------------------------

local settingsPanelFrame = nil
local customMessageEditBox = nil
local broadcastIntervalFrame = nil
local broadcastIntervalSlider = nil
local broadcastToggleButton = nil

--------------------------------------------------
-- Setup Placeholder for EditBox
--------------------------------------------------
local function SetupPlaceholder(editBox, placeholderText)
  if not editBox or not placeholderText then return end
  
  local placeholder = editBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  placeholder:SetText(placeholderText)
  placeholder:SetPoint("CENTER", editBox, "CENTER", 0, 0)
  
  local function updatePlaceholder()
    if editBox:GetText() == "" then
      placeholder:Show()
    else
      placeholder:Hide()
    end
  end
  
  editBox:SetScript("OnEditFocusGained", function()
    placeholder:Hide()
    if UpdateEditBoxFocusState then
      UpdateEditBoxFocusState(true)
    end
  end)
  
  editBox:SetScript("OnEditFocusLost", function()
    if UpdateEditBoxFocusState then
      UpdateEditBoxFocusState(false)
    end
    updatePlaceholder()
  end)
  
  editBox:SetScript("OnTextChanged", function()
    SetCustomUserMessage(editBox:GetText())
    updatePlaceholder()
  end)
  
  editBox:SetScript("OnEnterPressed", function()
    editBox:ClearFocus()
  end)
  
  editBox:SetScript("OnEscapePressed", function()
    editBox:ClearFocus()
  end)
  
  updatePlaceholder()
end

--------------------------------------------------
-- Snap Slider Value to Step
--------------------------------------------------
local function SnapToStep(value)
  if not value then return BROADCAST_INTERVAL_STEP end
  local roundedValue = math.floor(value / BROADCAST_INTERVAL_STEP + 0.5) * BROADCAST_INTERVAL_STEP
  return roundedValue
end

--------------------------------------------------
-- Create Custom Message EditBox
--------------------------------------------------
local function CreateCustomMessageEditBox(parentFrame)
  if not parentFrame then return nil end
  
  customMessageEditBox = CreateFrame("EditBox", "AutoLFM_EditBox", parentFrame)
  customMessageEditBox:SetPoint("TOP", parentFrame, "TOP", 0, -10)
  customMessageEditBox:SetWidth(270)
  customMessageEditBox:SetHeight(30)
  customMessageEditBox:SetAutoFocus(false)
  customMessageEditBox:SetFont("Fonts\\FRIZQT__.TTF", 14)
  customMessageEditBox:SetMaxLetters(MAX_CUSTOM_MESSAGE_LENGTH)
  customMessageEditBox:SetText("")
  customMessageEditBox:SetTextColor(1, 1, 1)
  customMessageEditBox:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 8,
    edgeSize = 16,
    insets = { left = 8, right = 2, top = 2, bottom = 2 }
  })
  customMessageEditBox:SetBackdropColor(0, 0, 0, 0.8)
  customMessageEditBox:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
  customMessageEditBox:SetJustifyH("CENTER")
  customMessageEditBox:SetTextInsets(10, 10, 5, 5)
  
  SetupPlaceholder(customMessageEditBox, "Add message details (optional)")
  
  return customMessageEditBox
end

--------------------------------------------------
-- Create Broadcast Interval Slider
--------------------------------------------------
local function CreateBroadcastIntervalSlider(parentFrame)
  if not parentFrame then return nil end
  
  broadcastIntervalFrame = CreateFrame("Frame", nil, parentFrame)
  broadcastIntervalFrame:SetPoint("TOP", customMessageEditBox, "BOTTOM", 0, -30)
  broadcastIntervalFrame:SetWidth(250)
  broadcastIntervalFrame:SetHeight(50)
  broadcastIntervalFrame:SetBackdrop({
    bgFile = nil,
    edgeSize = 16,
    insets = { left = 4, right = 2, top = 4, bottom = 4 },
  })
  broadcastIntervalFrame:SetBackdropColor(1, 1, 1, 0.3)
  broadcastIntervalFrame:SetBackdropBorderColor(1, 1, 1, 1)
  
  broadcastIntervalSlider = CreateFrame("Slider", nil, broadcastIntervalFrame, "OptionsSliderTemplate")
  broadcastIntervalSlider:SetWidth(200)
  broadcastIntervalSlider:SetHeight(20)
  broadcastIntervalSlider:SetPoint("CENTER", broadcastIntervalFrame, "CENTER", 0, 0)
  broadcastIntervalSlider:SetMinMaxValues(BROADCAST_INTERVAL_MIN, BROADCAST_INTERVAL_MAX)
  broadcastIntervalSlider:SetValue(DEFAULT_BROADCAST_INTERVAL)
  broadcastIntervalSlider:SetValueStep(BROADCAST_INTERVAL_STEP)
  
  local valueText = broadcastIntervalSlider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  valueText:SetPoint("BOTTOM", broadcastIntervalSlider, "TOP", 0, 5)
  valueText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
  valueText:SetText("Dispense every " .. DEFAULT_BROADCAST_INTERVAL .. " seconds")
  
  broadcastIntervalSlider:SetScript("OnValueChanged", function()
    local value = broadcastIntervalSlider:GetValue()
    if value then
      valueText:SetText("Dispense every " .. value .. " seconds")
    end
  end)
  
  -- Throttled snap to step
  local lastSliderUpdate = 0
  broadcastIntervalFrame:SetScript("OnUpdate", function()
    local now = GetTime()
    if now - lastSliderUpdate < UPDATE_THROTTLE_SLIDER then return end
    lastSliderUpdate = now
    
    local currentValue = broadcastIntervalSlider:GetValue()
    if currentValue then
      local snappedValue = SnapToStep(currentValue)
      if currentValue ~= snappedValue then
        broadcastIntervalSlider:SetValue(snappedValue)
      end
    end
  end)
  
  return broadcastIntervalFrame
end

--------------------------------------------------
-- Create Broadcast Toggle Button
--------------------------------------------------
local function CreateBroadcastToggleButton(parentFrame)
  if not parentFrame then return nil end
  
  broadcastToggleButton = CreateFrame("Button", "ToggleButton", parentFrame, "UIPanelButtonTemplate")
  broadcastToggleButton:SetPoint("BOTTOM", parentFrame, "BOTTOM", 97, 80)
  broadcastToggleButton:SetWidth(110)
  broadcastToggleButton:SetHeight(21)
  broadcastToggleButton:SetText("Start")
  
  broadcastToggleButton:SetScript("OnClick", function()
    if IsBroadcastActive() then
      -- Stop broadcast
      StopBroadcast()
      broadcastToggleButton:SetText("Start")
      PlaySoundFile(SOUND_BASE_PATH .. SOUND_BROADCAST_STOP)
    else
      -- Start broadcast
      if EnsureChannelUIExists then
        EnsureChannelUIExists()
      end
      
      local success = StartBroadcast()
      
      if success then
        broadcastToggleButton:SetText("Stop")
        PlaySoundFile(SOUND_BASE_PATH .. SOUND_BROADCAST_START)
      end
    end
  end)
  
  return broadcastToggleButton
end

--------------------------------------------------
-- Create Settings Panel
--------------------------------------------------
function CreateSettingsPanel(parentFrame)
  if not parentFrame then return nil end
  if settingsPanelFrame then return settingsPanelFrame end
  
  -- Main panel frame
  settingsPanelFrame = CreateFrame("Frame", nil, parentFrame)
  settingsPanelFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 25, -157)
  settingsPanelFrame:SetWidth(295)
  settingsPanelFrame:SetHeight(253)
  settingsPanelFrame:SetFrameStrata("HIGH")
  settingsPanelFrame:Hide()
  
  -- Create components
  CreateCustomMessageEditBox(settingsPanelFrame)
  CreateBroadcastIntervalSlider(settingsPanelFrame)
  
  -- Create channel selector
  if CreateChannelSelector then
    CreateChannelSelector(settingsPanelFrame)
  end
  
  return settingsPanelFrame
end

--------------------------------------------------
-- Show Settings Panel
--------------------------------------------------
function ShowSettingsPanel()
  if settingsPanelFrame then
    settingsPanelFrame:Show()
  end
  
  -- Ensure channel UI exists
  if RefreshChannelCheckboxes then
    RefreshChannelCheckboxes()
  end
end

--------------------------------------------------
-- Hide Settings Panel
--------------------------------------------------
function HideSettingsPanel()
  if settingsPanelFrame then
    settingsPanelFrame:Hide()
  end
end

--------------------------------------------------
-- Get Settings Panel Frame
--------------------------------------------------
function GetSettingsPanelFrame()
  return settingsPanelFrame
end

--------------------------------------------------
-- Get Broadcast Toggle Button (for external access)
--------------------------------------------------
function GetBroadcastToggleButton()
  return broadcastToggleButton
end

--------------------------------------------------
-- Get Broadcast Interval Slider (for external access)
--------------------------------------------------
function GetBroadcastIntervalSlider()
  return broadcastIntervalSlider
end

--------------------------------------------------
-- Get Custom Message EditBox (for external access)
--------------------------------------------------
function GetCustomMessageEditBox()
  return customMessageEditBox
end