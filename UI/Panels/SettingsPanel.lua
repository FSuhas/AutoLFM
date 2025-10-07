--------------------------------------------------
-- Settings Panel (More Tab)
--------------------------------------------------
local settingsPanelFrame = nil
local customMessageEditBox = nil
local broadcastIntervalSlider = nil
local durationLabel = nil
local sentLabel = nil
local nextLabel = nil

--------------------------------------------------
-- Snap Slider Value to Step
--------------------------------------------------
local function SnapToStep(value)
  if not value then return BROADCAST_INTERVAL_STEP end
  local roundedValue = math.floor(value / BROADCAST_INTERVAL_STEP + 0.5) * BROADCAST_INTERVAL_STEP
  return roundedValue
end

--------------------------------------------------
-- Update Stats Display
--------------------------------------------------
local function UpdateStatsDisplay()
  if not durationLabel or not sentLabel or not nextLabel then return end
  
  -- Update duration
  local stats = GetBroadcastStats()
  if stats and stats.isActive and stats.searchStartTimestamp and stats.searchStartTimestamp > 0 then
    local duration = GetTime() - stats.searchStartTimestamp
    local minutes = math.floor(duration / 60)
    local seconds = math.floor(mod(duration, 60))
    durationLabel:SetText(string.format("Duration: %02d:%02d", minutes, seconds))
  else
    durationLabel:SetText("Duration: 00:00")
  end
  
  -- Update sent count
  if stats and stats.messageCount then
    sentLabel:SetText("Sent: " .. stats.messageCount)
  else
    sentLabel:SetText("Sent: 0")
  end
  
  -- Update next broadcast
  local timing = AutoLFM_API and AutoLFM_API.GetTiming()
  if timing and timing.timeUntilNext then
    local seconds = math.floor(timing.timeUntilNext)
    nextLabel:SetText("Next: " .. seconds .. "s")
  else
    nextLabel:SetText("Next: --")
  end
end

--------------------------------------------------
-- Create Custom Message EditBox
--------------------------------------------------
local function CreateCustomMessageEditBox(parentFrame)
  if not parentFrame then return nil end
  
  editboxIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  editboxIcon:SetTexture(TEXTURE_BASE_PATH .. "Icons\\send")
  editboxIcon:SetWidth(16)
  editboxIcon:SetHeight(16)
  editboxIcon:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -10)
  
  editboxLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  editboxLabel:SetText("Add details to your message:")
  editboxLabel:SetPoint("LEFT", editboxIcon, "RIGHT", 3, 0)

  customMessageEditBox = CreateFrame("EditBox", "AutoLFM_EditBox", parentFrame)
  customMessageEditBox:SetPoint("TOPLEFT", editboxIcon, "BOTTOMRIGHT", 0, -5)
  customMessageEditBox:SetWidth(250)
  customMessageEditBox:SetHeight(25)
  customMessageEditBox:SetAutoFocus(false)
  customMessageEditBox:SetFont("Fonts\\FRIZQT__.TTF", 12)
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
  
  -- Setup placeholder
  local placeholder = customMessageEditBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  placeholder:SetText("(optional)")
  placeholder:SetPoint("CENTER", customMessageEditBox, "CENTER", 0, 0)
  
  local function updatePlaceholder()
    if customMessageEditBox:GetText() == "" then
      placeholder:Show()
    else
      placeholder:Hide()
    end
  end
  
  customMessageEditBox:SetScript("OnEditFocusGained", function()
    placeholder:Hide()
    if UpdateEditBoxFocusState then
      UpdateEditBoxFocusState(true)
    end
  end)
  
  customMessageEditBox:SetScript("OnEditFocusLost", function()
    if UpdateEditBoxFocusState then
      UpdateEditBoxFocusState(false)
    end
    updatePlaceholder()
  end)
  
  customMessageEditBox:SetScript("OnTextChanged", function()
    SetCustomUserMessage(customMessageEditBox:GetText())
    updatePlaceholder()
  end)
  
  customMessageEditBox:SetScript("OnEnterPressed", function()
    customMessageEditBox:ClearFocus()
  end)
  
  customMessageEditBox:SetScript("OnEscapePressed", function()
    customMessageEditBox:ClearFocus()
  end)
  
  updatePlaceholder()
  
  return customMessageEditBox
end

--------------------------------------------------
-- Create Broadcast Interval Slider
--------------------------------------------------
local function CreateBroadcastIntervalSlider(parentFrame)
  if not parentFrame or not customMessageEditBox then return nil end
  
  local sliderIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  sliderIcon:SetTexture(TEXTURE_BASE_PATH .. "Icons\\tool")
  sliderIcon:SetWidth(16)
  sliderIcon:SetHeight(16)
  sliderIcon:SetPoint("TOPRIGHT", customMessageEditBox, "BOTTOMLEFT", 0, -10)
  
  local sliderLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sliderLabel:SetText("Interval:")
  sliderLabel:SetPoint("LEFT", sliderIcon, "RIGHT", 3, 0)
  
  broadcastIntervalSlider = CreateFrame("Slider", nil, parentFrame)
  broadcastIntervalSlider:SetWidth(145)
  broadcastIntervalSlider:SetHeight(17)
  broadcastIntervalSlider:SetPoint("LEFT", sliderLabel, "RIGHT", 10, 0)
  broadcastIntervalSlider:SetMinMaxValues(BROADCAST_INTERVAL_MIN, BROADCAST_INTERVAL_MAX)
  broadcastIntervalSlider:SetValue(DEFAULT_BROADCAST_INTERVAL)
  broadcastIntervalSlider:SetValueStep(BROADCAST_INTERVAL_STEP)
  broadcastIntervalSlider:SetOrientation("HORIZONTAL")
  broadcastIntervalSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
  broadcastIntervalSlider:SetBackdrop({
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = {left = 3, right = 3, top = 6, bottom = 6}
  })
  
  local sliderValue = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sliderValue:SetText(DEFAULT_BROADCAST_INTERVAL .. " secs")
  sliderValue:SetPoint("LEFT", broadcastIntervalSlider, "RIGHT", 10, 0)
  
  broadcastIntervalSlider:SetScript("OnValueChanged", function()
    local value = broadcastIntervalSlider:GetValue()
    if value then
      sliderValue:SetText(math.floor(value) .. " secs")
    end
  end)
  
  return sliderIcon
end

--------------------------------------------------
-- Create Channel Section
--------------------------------------------------
local function CreateChannelSection(parentFrame)
  if not parentFrame then return nil end
  
  -- Create channel selector (managed by ChannelSelector.lua)
  if CreateChannelSelector then
    local channelFrame = CreateChannelSelector(parentFrame)
    if channelFrame then
      channelFrame:ClearAllPoints()
      channelFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -95)
    end
  end
  
  return channelIcon
end

--------------------------------------------------
-- Create Stats Section
--------------------------------------------------
local function CreateStatsSection(parentFrame)
  if not parentFrame then return nil end
  
  local durationIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  durationIcon:SetTexture(TEXTURE_BASE_PATH .. "Icons\\bag")
  durationIcon:SetWidth(16)
  durationIcon:SetHeight(16)
  durationIcon:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -180)
  
  durationLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  durationLabel:SetText("Duration: 00:00")
  durationLabel:SetPoint("LEFT", durationIcon, "RIGHT", 3, 0)
  
  local sentIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  sentIcon:SetTexture(TEXTURE_BASE_PATH .. "Icons\\book")
  sentIcon:SetWidth(16)
  sentIcon:SetHeight(16)
  sentIcon:SetPoint("TOPLEFT", durationIcon, "BOTTOMLEFT", 0, -10)
  
  sentLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sentLabel:SetText("Sent: 0")
  sentLabel:SetPoint("LEFT", sentIcon, "RIGHT", 3, 0)
  
  local nextIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  nextIcon:SetTexture(TEXTURE_BASE_PATH .. "Icons\\chat")
  nextIcon:SetWidth(16)
  nextIcon:SetHeight(16)
  nextIcon:SetPoint("TOPLEFT", sentIcon, "BOTTOMLEFT", 0, -10)
  
  nextLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nextLabel:SetText("Next: --")
  nextLabel:SetPoint("LEFT", nextIcon, "RIGHT", 3, 0)
  
  return durationIcon
end

--------------------------------------------------
-- Create Questlog Section
--------------------------------------------------
local function CreateQuestlogSection(parentFrame)
  if not parentFrame then return nil end
  
  questlogLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  questlogLabel:SetText("QuestLog " .. ColorizeText("(WIP)", "gray"))
  questlogLabel:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -5, 7)

  local questlogIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  questlogIcon:SetTexture(TEXTURE_BASE_PATH .. "Icons\\quest1")
  questlogIcon:SetWidth(16)
  questlogIcon:SetHeight(16)
  questlogIcon:SetPoint("RIGHT", questlogLabel, "LEFT", -3, 0)
  
  return questlogIcon
end

--------------------------------------------------
-- Create Settings Panel (MAIN FRAME)
--------------------------------------------------
function CreateSettingsPanel(parentFrame)
  if not parentFrame then return nil end
  if settingsPanelFrame then return settingsPanelFrame end
  
  -- Main panel frame
  settingsPanelFrame = CreateFrame("Frame", nil, parentFrame)
  settingsPanelFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 25, -157)
  settingsPanelFrame:SetWidth(292)
  settingsPanelFrame:SetHeight(253)
  settingsPanelFrame:SetFrameStrata("HIGH")
  settingsPanelFrame:Hide()
  
  -- Create child components
  CreateCustomMessageEditBox(settingsPanelFrame)
  CreateBroadcastIntervalSlider(settingsPanelFrame)
  CreateChannelSection(settingsPanelFrame)
  CreateStatsSection(settingsPanelFrame)
  CreateQuestlogSection(settingsPanelFrame)
  
  -- Update loop for stats + slider snap
  local lastSliderUpdate = 0
  settingsPanelFrame:SetScript("OnUpdate", function()
    UpdateStatsDisplay()
    
    local now = GetTime()
    if now - lastSliderUpdate < UPDATE_THROTTLE_SLIDER then return end
    lastSliderUpdate = now
    
    if broadcastIntervalSlider then
      local currentValue = broadcastIntervalSlider:GetValue()
      if currentValue then
        local snappedValue = SnapToStep(currentValue)
        if currentValue ~= snappedValue then
          broadcastIntervalSlider:SetValue(snappedValue)
        end
      end
    end
  end)
  
  return settingsPanelFrame
end

--------------------------------------------------
-- Show Settings Panel
--------------------------------------------------
function ShowSettingsPanel()
  if settingsPanelFrame then
    settingsPanelFrame:Show()
  end
  
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
-- Getters
--------------------------------------------------
function GetSettingsPanelFrame()
  return settingsPanelFrame
end

function GetBroadcastToggleButton()
  return nil
end

function GetBroadcastIntervalSlider()
  return broadcastIntervalSlider
end

function GetCustomMessageEditBox()
  return customMessageEditBox
end