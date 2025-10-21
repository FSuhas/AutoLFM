--=============================================================================
-- AutoLFM: More Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.MorePanel then AutoLFM.UI.MorePanel = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.UI.MorePanel.MAX_MESSAGE_LENGTH = 150
AutoLFM.UI.MorePanel.UPDATE_THROTTLE = 0.1

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local morePanelFrame = nil
local leftFrame = nil
local rightFrame = nil
local customMessageEditBox = nil
local broadcastIntervalSlider = nil
local durationLabelText = nil
local durationValueText = nil
local sentLabelText = nil
local sentValueText = nil
local nextLabelText = nil
local nextValueText = nil
local channelsFrame = nil
local channelButtons = {}
local minimapControlsFrame = nil
local editBoxHasFocus = false

-----------------------------------------------------------------------------
-- EditBox Focus State
-----------------------------------------------------------------------------
function AutoLFM.UI.MorePanel.UpdateEditBoxFocus(hasFocus)
  editBoxHasFocus = hasFocus
end

function AutoLFM.UI.MorePanel.GetEditBoxFocus()
  return editBoxHasFocus
end

-----------------------------------------------------------------------------
-- Utilities
-----------------------------------------------------------------------------
local function SnapToStep(value)
  if not value then return AutoLFM.Logic.Broadcaster.INTERVAL_STEP end
  local roundedValue = math.floor(value / AutoLFM.Logic.Broadcaster.INTERVAL_STEP + 0.5) * AutoLFM.Logic.Broadcaster.INTERVAL_STEP
  return roundedValue
end

-----------------------------------------------------------------------------
-- Custom Message EditBox
-----------------------------------------------------------------------------
local function CreateCustomMessageEditBox(parentFrame)
  if not parentFrame then return nil, nil, nil end
  
  local editboxIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  editboxIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\send")
  editboxIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  editboxIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  editboxIcon:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -10)
  
  local editboxLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  editboxLabel:SetText("Add details to your message:")
  editboxLabel:SetPoint("LEFT", editboxIcon, "RIGHT", 3, 0)
  editboxLabel:SetTextColor(1, 1, 1)

  customMessageEditBox = CreateFrame("EditBox", "AutoLFM_EditBox", parentFrame)
  customMessageEditBox:SetPoint("TOPLEFT", editboxIcon, "BOTTOMRIGHT", -5, -5)
  customMessageEditBox:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.EDITBOX_WIDTH)
  customMessageEditBox:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.EDITBOX_HEIGHT)
  customMessageEditBox:SetAutoFocus(false)
  customMessageEditBox:SetFontObject(GameFontNormal)
  customMessageEditBox:SetMaxLetters(AutoLFM.UI.MorePanel.MAX_MESSAGE_LENGTH)
  customMessageEditBox:SetText("")
  customMessageEditBox:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 8,
    edgeSize = 16,
    insets = { left = 8, right = 2, top = 2, bottom = 2 }
  })
  customMessageEditBox:SetBackdropColor(0, 0, 0, 0.8)
  customMessageEditBox:SetBackdropBorderColor(1, 0.82, 0, 1)
  customMessageEditBox:SetJustifyH("CENTER")
  customMessageEditBox:SetTextInsets(10, 10, 5, 5)
  
  local placeholder = customMessageEditBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
  placeholder:SetText("(optional if dungeon or raid selected)")
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
    AutoLFM.UI.MorePanel.UpdateEditBoxFocus(true)
  end)
  
  customMessageEditBox:SetScript("OnEditFocusLost", function()
    AutoLFM.UI.MorePanel.UpdateEditBoxFocus(false)
    updatePlaceholder()
  end)
  
  customMessageEditBox:SetScript("OnTextChanged", function()
    if AutoLFM.Logic.Broadcaster.SetCustomMessage then
      AutoLFM.Logic.Broadcaster.SetCustomMessage(customMessageEditBox:GetText())
    end
    if AutoLFM.Logic.Broadcaster.UpdateMessage then
      AutoLFM.Logic.Broadcaster.UpdateMessage()
    end
    if AutoLFM.UI.MainWindow.UpdateMessagePreview then
      AutoLFM.UI.MainWindow.UpdateMessagePreview()
    end
    updatePlaceholder()
  end)
  
  customMessageEditBox:SetScript("OnEnterPressed", function()
    customMessageEditBox:ClearFocus()
  end)
  
  customMessageEditBox:SetScript("OnEscapePressed", function()
    customMessageEditBox:ClearFocus()
  end)
  
  local clearButton = CreateFrame("Button", nil, parentFrame)
  clearButton:SetWidth(60)
  clearButton:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.BUTTON_HEIGHT)
  clearButton:SetPoint("BOTTOMRIGHT", customMessageEditBox, "TOPRIGHT", 8, 2)
  clearButton:SetFrameLevel(parentFrame:GetFrameLevel() + 1)
  
  local clearIcon = clearButton:CreateTexture(nil, "ARTWORK")
  clearIcon:SetWidth(20)
  clearIcon:SetHeight(20)
  clearIcon:SetPoint("LEFT", clearButton, "LEFT", 0, 0)
  clearIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\close")
  
  local clearIconHL = clearButton:CreateTexture(nil, "HIGHLIGHT")
  clearIconHL:SetWidth(20)
  clearIconHL:SetHeight(20)
  clearIconHL:SetPoint("LEFT", clearButton, "LEFT", 0, 0)
  clearIconHL:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\close")
  clearIconHL:SetBlendMode("ADD")
  
  local clearText = clearButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  clearText:SetPoint("LEFT", clearIcon, "RIGHT", -1, 0)
  clearText:SetText("Clear")
  clearText:SetTextColor(1, 0, 0)
  
  clearButton:SetScript("OnClick", function()
    if customMessageEditBox then
      customMessageEditBox:SetText("")
      customMessageEditBox:ClearFocus()
    end
    if AutoLFM.Logic.Broadcaster.SetCustomMessage then
      AutoLFM.Logic.Broadcaster.SetCustomMessage("")
    end
    if AutoLFM.Logic.Broadcaster.UpdateMessage then
      AutoLFM.Logic.Broadcaster.UpdateMessage()
    end
    if AutoLFM.UI.MainWindow.UpdateMessagePreview then
      AutoLFM.UI.MainWindow.UpdateMessagePreview()
    end
  end)
  
  clearButton:SetScript("OnEnter", function()
    clearText:SetTextColor(1, 0.82, 0)
    clearIcon:SetVertexColor(1, 1, 1)
  end)
  
  clearButton:SetScript("OnLeave", function()
    clearText:SetTextColor(1, 0, 0)
    clearIcon:SetVertexColor(1, 1, 1)
  end)
  
  updatePlaceholder()
  
  return customMessageEditBox, editboxIcon, editboxLabel
end

-----------------------------------------------------------------------------
-- Broadcast Interval Slider
-----------------------------------------------------------------------------
local function CreateBroadcastIntervalSlider(parentFrame, editboxIcon)
  if not parentFrame then return nil, nil, nil end
  if not editboxIcon then return nil, nil, nil end
  
  local sliderIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  sliderIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\tool")
  sliderIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  sliderIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  sliderIcon:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 5, -70)
  
  local sliderLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sliderLabel:SetText("Interval:")
  sliderLabel:SetPoint("LEFT", sliderIcon, "RIGHT", 3, 0)
  sliderLabel:SetTextColor(1, 1, 1)
  
  broadcastIntervalSlider = CreateFrame("Slider", nil, parentFrame)
  broadcastIntervalSlider:SetWidth(145)
  broadcastIntervalSlider:SetHeight(17)
  broadcastIntervalSlider:SetPoint("LEFT", sliderLabel, "RIGHT", 10, 0)
  broadcastIntervalSlider:SetMinMaxValues(AutoLFM.Logic.Broadcaster.INTERVAL_MIN, AutoLFM.Logic.Broadcaster.INTERVAL_MAX)
  
  local savedInterval = AutoLFM.Core.Settings.LoadInterval()
  broadcastIntervalSlider:SetValue(savedInterval)
  
  broadcastIntervalSlider:SetValueStep(AutoLFM.Logic.Broadcaster.INTERVAL_STEP)
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
  sliderValue:SetText(savedInterval .. " secs")
  sliderValue:SetPoint("LEFT", broadcastIntervalSlider, "RIGHT", 10, 0)
  
  broadcastIntervalSlider:SetScript("OnValueChanged", function()
    local value = broadcastIntervalSlider:GetValue()
    if value then
      sliderValue:SetText(math.floor(value) .. " secs")
      AutoLFM.Core.Settings.SaveInterval(value)
      
      if AutoLFM and AutoLFM.API and type(AutoLFM.API.NotifyDataChanged) == "function" then
        AutoLFM.API.NotifyDataChanged(AutoLFM.API.EVENTS.INTERVAL_CHANGED)
      end
    end
  end)
  
  return sliderIcon, sliderLabel, sliderValue
end

-----------------------------------------------------------------------------
-- Channel Selector
-----------------------------------------------------------------------------
local function CreateChannelCheckbox(parentFrame, channel, lastButton)
  if not parentFrame or not channel then return nil end
  
  local hasAccess = true
  if channel.name == "Hardcore" then
    if AutoLFM.Logic.Selection.IsHardcoreMode then
      hasAccess = AutoLFM.Logic.Selection.IsHardcoreMode()
    else
      hasAccess = false
    end
  end
  
  local button = AutoLFM.UI.PanelBuilder.CreateCheckbox(parentFrame, nil, function()
    if not this then return end
    
    if not hasAccess then
      this:SetChecked(false)
      return
    end
    
    if not this.GetChecked then return end
    
    if AutoLFM.Logic.Selection.ToggleChannel then
      AutoLFM.Logic.Selection.ToggleChannel(channel.name, this:GetChecked())
    end
  end)
  
  if not button then return nil end
  
  button:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  button:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  
  if lastButton then
    button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -4)
  else
    button:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 12, -20)
  end
  
  if not hasAccess then
    button:Disable()
    button:SetAlpha(0.5)
  else
    button:Enable()
    button:SetAlpha(1.0)
  end
  
  local channelText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  channelText:SetPoint("LEFT", button, "RIGHT", 5, 0)
  channelText:SetText(channel.name)
  channelText:SetTextColor(1, 0.82, 0)
  
  if not hasAccess then
    channelText:SetTextColor(0.5, 0.5, 0.5)
  end
  
  button:SetScript("OnEnter", function()
    if hasAccess then
      channelText:SetTextColor(0.3, 0.6, 1)
    end
  end)
  
  button:SetScript("OnLeave", function()
    if hasAccess then
      channelText:SetTextColor(1, 0.82, 0)
    else
      channelText:SetTextColor(0.5, 0.5, 0.5)
    end
  end)
  
  if hasAccess and AutoLFM.Logic.Selection.IsChannelSelected then
    button:SetChecked(AutoLFM.Logic.Selection.IsChannelSelected(channel.name))
  else
    button:SetChecked(false)
  end
  
  channelButtons[channel.name] = button
  
  return button
end

local function CreateChannelCheckboxes()
  if not channelsFrame or not AutoLFM.Logic.Selection.FindAvailableChannels then return end
  
  for _, button in pairs(channelButtons) do
    if button then
      button:Hide()
    end
  end
  channelButtons = {}
  
  local foundChannels = AutoLFM.Logic.Selection.FindAvailableChannels()
  if not foundChannels or table.getn(foundChannels) == 0 then
    return
  end
  
  local lastButton = nil
  
  for _, channel in ipairs(foundChannels) do
    if channel and channel.name then
      lastButton = CreateChannelCheckbox(channelsFrame, channel, lastButton)
    end
  end
end

function AutoLFM.UI.MorePanel.RefreshChannelCheckboxes()
  CreateChannelCheckboxes()
end

function AutoLFM.UI.MorePanel.UpdateChannelCheckboxes()
  if not channelButtons or not AutoLFM.Logic.Selection.IsChannelSelected then return end
  AutoLFM.UI.PanelBuilder.BatchUpdateCheckboxes(channelButtons, AutoLFM.Logic.Selection.IsChannelSelected)
end

local function CreateChannelSelector(parentFrame)
  if not parentFrame then return nil end
  if channelsFrame then
    channelsFrame:SetParent(parentFrame)
    channelsFrame:Show()
    return channelsFrame
  end
  
  channelsFrame = CreateFrame("Frame", "AutoLFM_ChannelSelector", parentFrame)
  channelsFrame:SetWidth(135)
  channelsFrame:SetHeight(100)
  channelsFrame:Show()
  
  local channelIcon = channelsFrame:CreateTexture(nil, "OVERLAY")
  channelIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\channel")
  channelIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  channelIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  channelIcon:SetPoint("TOPLEFT", channelsFrame, "TOPLEFT", 0, 0)
  
  local titleText = channelsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  titleText:SetText("Channels:")
  titleText:SetPoint("LEFT", channelIcon, "RIGHT", 3, 0)
  titleText:SetTextColor(1, 1, 1)
  
  return channelsFrame
end

-----------------------------------------------------------------------------
-- Stats Display
-----------------------------------------------------------------------------
local function UpdateStatsDisplay()
  if not durationValueText or not sentValueText or not nextValueText then return end
  
  if AutoLFM.Logic.Broadcaster.FormatDuration then
    local formattedDuration = AutoLFM.Logic.Broadcaster.FormatDuration()
    durationValueText:SetText(formattedDuration)
  else
    durationValueText:SetText("00:00")
  end
  
  if AutoLFM.Logic.Broadcaster.GetStats then
    local stats = AutoLFM.Logic.Broadcaster.GetStats()
    if stats and stats.messageCount then
      sentValueText:SetText(tostring(stats.messageCount))
    else
      sentValueText:SetText("0")
    end
  else
    sentValueText:SetText("0")
  end
  
  local timing = nil
  if AutoLFM.API and AutoLFM.API.GetTiming then
    timing = AutoLFM.API.GetTiming()
  end
  
  if timing and timing.timeUntilNext then
    local seconds = math.floor(timing.timeUntilNext)
    nextValueText:SetText(seconds .. "s")
  else
    nextValueText:SetText("--")
  end
end

local function CreateStatsSection(parentFrame)
  if not parentFrame then return nil end
  
  local durationIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  durationIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\bag")
  durationIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  durationIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  durationIcon:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, 0)
  
  durationLabelText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  durationLabelText:SetText("Duration: ")
  durationLabelText:SetPoint("LEFT", durationIcon, "RIGHT", 3, 0)
  durationLabelText:SetTextColor(1, 1, 1)
  
  durationValueText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  durationValueText:SetText("00:00")
  durationValueText:SetPoint("LEFT", durationLabelText, "RIGHT", 0, 0)
  
  local sentIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  sentIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\book")
  sentIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  sentIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  sentIcon:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -26)
  
  sentLabelText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sentLabelText:SetText("Sent: ")
  sentLabelText:SetPoint("LEFT", sentIcon, "RIGHT", 3, 0)
  sentLabelText:SetTextColor(1, 1, 1)
  
  sentValueText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sentValueText:SetText("0")
  sentValueText:SetPoint("LEFT", sentLabelText, "RIGHT", 0, 0)
  
  local nextIcon = parentFrame:CreateTexture(nil, "OVERLAY")
  nextIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\chat")
  nextIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  nextIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  nextIcon:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, -52)
  
  nextLabelText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nextLabelText:SetText("Next: ")
  nextLabelText:SetPoint("LEFT", nextIcon, "RIGHT", 3, 0)
  nextLabelText:SetTextColor(1, 1, 1)
  
  nextValueText = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nextValueText:SetText("--")
  nextValueText:SetPoint("LEFT", nextLabelText, "RIGHT", 0, 0)
  
  return durationIcon
end

-----------------------------------------------------------------------------
-- Minimap Controls
-----------------------------------------------------------------------------
local function UpdateMinimapRadioButtons()
  if not minimapControlsFrame then return end
  if not AutoLFM_MinimapButton then return end
  
  local isVisible = AutoLFM_MinimapButton:IsShown()
  
  if minimapControlsFrame.showRadio then
    minimapControlsFrame.showRadio:SetChecked(isVisible)
  end
  
  if minimapControlsFrame.hideRadio then
    minimapControlsFrame.hideRadio:SetChecked(not isVisible)
  end
end

local function CreateMinimapRadioButton(parentFrame, label, isChecked, yOffset)
  if not parentFrame then return nil end
  
  local button = CreateFrame("CheckButton", nil, parentFrame, "UIRadioButtonTemplate")
  button:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  button:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  button:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 12, yOffset)
  button:SetChecked(isChecked)
  
  local textButton = CreateFrame("Button", nil, parentFrame)
  textButton:SetPoint("LEFT", button, "RIGHT", 0, 0)
  textButton:SetWidth(55)
  textButton:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.BUTTON_HEIGHT)
  
  local text = textButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  text:SetPoint("LEFT", textButton, "LEFT", 5, 0)
  text:SetText(label)
  text:SetTextColor(1, 0.82, 0)
  
  textButton:SetScript("OnClick", function()
    button:Click()
  end)
  
  textButton:SetScript("OnEnter", function()
    text:SetTextColor(0.3, 0.6, 1)
    button:LockHighlight()
  end)
  
  textButton:SetScript("OnLeave", function()
    text:SetTextColor(1, 0.82, 0)
    button:UnlockHighlight()
  end)
  
  button:SetScript("OnEnter", function()
    text:SetTextColor(0.3, 0.6, 1)
  end)
  
  button:SetScript("OnLeave", function()
    text:SetTextColor(1, 0.82, 0)
  end)
  
  button.textButton = textButton
  
  return button
end

local function CreateMinimapResetButton(parentFrame, yOffset)
  if not parentFrame then return nil end
  
  local resetButton = CreateFrame("Button", nil, parentFrame)
  resetButton:SetWidth(20)
  resetButton:SetHeight(20)
  resetButton:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, yOffset)
  
  local icon = resetButton:CreateTexture(nil, "ARTWORK")
  icon:SetAllPoints(resetButton)
  icon:SetTexture("Interface\\Buttons\\UI-RotationLeft-Button-Up")
  
  local highlight = resetButton:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetAllPoints(resetButton)
  highlight:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
  highlight:SetBlendMode("ADD")
  
  local textButton = CreateFrame("Button", nil, parentFrame)
  textButton:SetPoint("LEFT", resetButton, "RIGHT", 0, 0)
  textButton:SetWidth(55)
  textButton:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.BUTTON_HEIGHT)
  
  local text = textButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  text:SetPoint("LEFT", textButton, "LEFT", 5, 0)
  text:SetText("Reset")
  text:SetTextColor(1, 0.82, 0)
  
  textButton:SetScript("OnClick", function()
    resetButton:Click()
  end)
  
  textButton:SetScript("OnEnter", function()
    text:SetTextColor(0.3, 0.6, 1)
    resetButton:LockHighlight()
    GameTooltip:SetOwner(textButton, "ANCHOR_RIGHT")
    GameTooltip:SetText("Reset minimap button position", 1, 1, 1)
    GameTooltip:Show()
  end)
  
  textButton:SetScript("OnLeave", function()
    text:SetTextColor(1, 0.82, 0)
    resetButton:UnlockHighlight()
    GameTooltip:Hide()
  end)
  
  resetButton:SetScript("OnEnter", function()
    text:SetTextColor(0.3, 0.6, 1)
    GameTooltip:SetOwner(resetButton, "ANCHOR_RIGHT")
    GameTooltip:SetText("Reset minimap button position", 1, 1, 1)
    GameTooltip:Show()
  end)
  
  resetButton:SetScript("OnLeave", function()
    text:SetTextColor(1, 0.82, 0)
    GameTooltip:Hide()
  end)
  
  resetButton:SetScript("OnClick", function()
    local defaultAngle = 225
    
    AutoLFM.Core.Settings.SaveMinimapPos(defaultAngle)
    
    if AutoLFM_MinimapButton and AutoLFM.UI.MinimapButton.SetPosition then
      AutoLFM.UI.MinimapButton.SetPosition(defaultAngle)
      AutoLFM_MinimapButton:Show()
      AutoLFM.Core.Settings.SaveMinimapHidden(false)
    end
    
    UpdateMinimapRadioButtons()
  end)
  
  return resetButton
end

local function CreateMinimapControls(parentFrame)
  if not parentFrame then return nil end
  if minimapControlsFrame then
    minimapControlsFrame:SetParent(parentFrame)
    minimapControlsFrame:Show()
    return minimapControlsFrame
  end
  
  minimapControlsFrame = CreateFrame("Frame", "AutoLFM_MinimapControls", parentFrame)
  minimapControlsFrame:SetWidth(135)
  minimapControlsFrame:SetHeight(100)
  minimapControlsFrame:Show()
  
  local minimapIcon = minimapControlsFrame:CreateTexture(nil, "OVERLAY")
  minimapIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\minimap")
  minimapIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  minimapIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  minimapIcon:SetPoint("TOPLEFT", minimapControlsFrame, "TOPLEFT", 0, 0)
  
  local titleText = minimapControlsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  titleText:SetText("Minimap button:")
  titleText:SetPoint("LEFT", minimapIcon, "RIGHT", 3, 0)
  titleText:SetTextColor(1, 1, 1)
  
  local isVisible = AutoLFM_MinimapButton and AutoLFM_MinimapButton:IsShown()
  
  minimapControlsFrame.showRadio = CreateMinimapRadioButton(minimapControlsFrame, "Show", isVisible, -20)
  
  if minimapControlsFrame.showRadio then
    minimapControlsFrame.showRadio:SetScript("OnClick", function()
      if AutoLFM_MinimapButton and not AutoLFM_MinimapButton:IsShown() then
        AutoLFM_MinimapButton:Show()
        AutoLFM.Core.Settings.SaveMinimapHidden(false)
      end
      UpdateMinimapRadioButtons()
    end)
  end
  
  minimapControlsFrame.hideRadio = CreateMinimapRadioButton(minimapControlsFrame, "Hide", not isVisible, -40)
  
  if minimapControlsFrame.hideRadio then
    minimapControlsFrame.hideRadio:SetScript("OnClick", function()
      if AutoLFM_MinimapButton and AutoLFM_MinimapButton:IsShown() then
        AutoLFM_MinimapButton:Hide()
        AutoLFM.Core.Settings.SaveMinimapHidden(true)
      end
      UpdateMinimapRadioButtons()
    end)
  end
  
  minimapControlsFrame.resetButton = CreateMinimapResetButton(minimapControlsFrame, -60)
  
  UpdateMinimapRadioButtons()
  
  return minimapControlsFrame
end

-----------------------------------------------------------------------------
-- Clear All Button
-----------------------------------------------------------------------------
local function HasAnySelection()
  local hasDungeons = false
  if AutoLFM.Logic.Content.GetSelectedDungeons then
    local dungeons = AutoLFM.Logic.Content.GetSelectedDungeons()
    hasDungeons = dungeons and table.getn(dungeons) > 0
  end
  
  local hasRaids = false
  if AutoLFM.Logic.Content.GetSelectedRaids then
    local raids = AutoLFM.Logic.Content.GetSelectedRaids()
    hasRaids = raids and table.getn(raids) > 0
  end
  
  local hasRoles = false
  if AutoLFM.Logic.Selection.GetRoles then
    local roles = AutoLFM.Logic.Selection.GetRoles()
    hasRoles = roles and table.getn(roles) > 0
  end
  
  local hasQuests = false
  local editBox = nil
  if AutoLFM.UI.MorePanel.GetCustomMessageEditBox then
    editBox = AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  end
  if editBox then
    local text = editBox:GetText() or ""
    hasQuests = string.find(text, "|Hquest:") ~= nil
  end
  
  local hasCustomMessage = false
  if customMessageEditBox then
    local text = customMessageEditBox:GetText() or ""
    hasCustomMessage = text ~= ""
  end
  
  return hasDungeons or hasRaids or hasRoles or hasQuests or hasCustomMessage
end

local function CreateRemoveAllButton(panelData)
  if not panelData or not panelData.bottomZone then return nil end
  
  local removeAllButton = CreateFrame("Button", nil, panelData.bottomZone)
  removeAllButton:SetWidth(80)
  removeAllButton:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.BUTTON_HEIGHT)
  removeAllButton:SetPoint("LEFT", panelData.bottomZone, "LEFT", 16, -7)
  removeAllButton.isHovered = false
  
  local removeAllText = removeAllButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  removeAllText:SetPoint("LEFT", removeAllButton, "LEFT", 0, 0)
  removeAllText:SetText("Clear all")
  removeAllText:SetTextColor(0.5, 0.5, 0.5)
  
  local function UpdateRemoveAllState()
    if removeAllButton.isHovered then return end
    
    if HasAnySelection() then
      removeAllText:SetTextColor(1, 0.82, 0)
    else
      removeAllText:SetTextColor(0.5, 0.5, 0.5)
    end
  end
  
  removeAllButton:SetScript("OnClick", function()
    if not HasAnySelection() then return end
    
    if AutoLFM.Logic.Content.ClearDungeons then
      AutoLFM.Logic.Content.ClearDungeons()
    end
    
    if AutoLFM.UI.DungeonsPanel.ClearSelection then
      AutoLFM.UI.DungeonsPanel.ClearSelection()
    end
    
    if AutoLFM.Logic.Content.ClearRaids then
      AutoLFM.Logic.Content.ClearRaids()
    end
    
    if AutoLFM.UI.RaidsPanel.ClearSelection then
      AutoLFM.UI.RaidsPanel.ClearSelection()
    end
    
    if AutoLFM.UI.MainWindow.ClearRoleCheckboxes then
      AutoLFM.UI.MainWindow.ClearRoleCheckboxes()
    end
    
    if AutoLFM.Logic.Selection.ClearRoles then
      AutoLFM.Logic.Selection.ClearRoles()
    end
    
    if customMessageEditBox then
      customMessageEditBox:SetText("")
      customMessageEditBox:ClearFocus()
    end
    
    if AutoLFM.Logic.Broadcaster.SetCustomMessage then
      AutoLFM.Logic.Broadcaster.SetCustomMessage("")
    end
    
    if AutoLFM.Logic.Broadcaster.UpdateMessage then
      AutoLFM.Logic.Broadcaster.UpdateMessage()
    end
    
    if AutoLFM.UI.MainWindow.UpdateMessagePreview then
      AutoLFM.UI.MainWindow.UpdateMessagePreview()
    end
    
    UpdateRemoveAllState()
  end)
  
  removeAllButton:SetScript("OnEnter", function()
    removeAllButton.isHovered = true
    if HasAnySelection() then
      removeAllText:SetTextColor(1, 0, 0)
    end
  end)
  
  removeAllButton:SetScript("OnLeave", function()
    removeAllButton.isHovered = false
    UpdateRemoveAllState()
  end)
  
  return removeAllButton, UpdateRemoveAllState
end

-----------------------------------------------------------------------------
-- Panel Management
-----------------------------------------------------------------------------
function AutoLFM.UI.MorePanel.Create(parentFrame)
  if not parentFrame then return nil end
  if morePanelFrame then return morePanelFrame end
  
  local panelData = AutoLFM.UI.PanelBuilder.CreatePanel(parentFrame, "AutoLFM_MorePanel")
  if not panelData then return nil end
  
  morePanelFrame = panelData.panel
  morePanelFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 25, -150)
  morePanelFrame:SetWidth(292)
  morePanelFrame:SetHeight(253)
  
  local editBox, editboxIcon, editboxLabel = CreateCustomMessageEditBox(morePanelFrame)
  customMessageEditBox = editBox
  customMessageEditBox.editboxIcon = editboxIcon
  customMessageEditBox.editboxLabel = editboxLabel
  
  local sliderIcon, sliderLabel, sliderValue = CreateBroadcastIntervalSlider(morePanelFrame, editboxIcon)
  broadcastIntervalSlider.sliderIcon = sliderIcon
  broadcastIntervalSlider.sliderLabel = sliderLabel
  broadcastIntervalSlider.sliderValue = sliderValue
  
  leftFrame = CreateFrame("Frame", nil, morePanelFrame)
  leftFrame:SetPoint("TOPLEFT", sliderIcon, "BOTTOMLEFT", -4, -10)
  leftFrame:SetWidth(140)
  leftFrame:SetHeight(160)
  leftFrame:SetBackdrop({
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  
  rightFrame = CreateFrame("Frame", nil, morePanelFrame)
  rightFrame:SetPoint("TOPLEFT", leftFrame, "TOPRIGHT", 20, 0)
  rightFrame:SetWidth(140)
  rightFrame:SetHeight(160)
  rightFrame:SetBackdrop({
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  
  local channelFrame = CreateChannelSelector(leftFrame)
  if channelFrame then
    channelFrame:ClearAllPoints()
    channelFrame:SetPoint("TOPLEFT", leftFrame, "TOPLEFT", 5, -5)
  end
  
  local statsFrame = CreateFrame("Frame", nil, leftFrame)
  statsFrame:SetPoint("TOPLEFT", leftFrame, "TOPLEFT", 5, -90)
  statsFrame:SetWidth(130)
  statsFrame:SetHeight(90)
  CreateStatsSection(statsFrame)
  
  local minimapFrame = CreateMinimapControls(rightFrame)
  if minimapFrame then
    minimapFrame:ClearAllPoints()
    minimapFrame:SetPoint("TOPLEFT", rightFrame, "TOPLEFT", 5, -5)
  end
  
  local removeAllButton, UpdateRemoveAllState = CreateRemoveAllButton(panelData)
  
  local lastSliderUpdate = 0
  morePanelFrame:SetScript("OnUpdate", function()
    UpdateStatsDisplay()
    UpdateMinimapRadioButtons()
    if UpdateRemoveAllState then
      UpdateRemoveAllState()
    end
    
    local now = GetTime()
    if now - lastSliderUpdate < AutoLFM.UI.MorePanel.UPDATE_THROTTLE then return end
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
  
  return morePanelFrame
end

function AutoLFM.UI.MorePanel.Show()
  if morePanelFrame then
    morePanelFrame:Show()
  end
  
  AutoLFM.UI.MorePanel.RefreshChannelCheckboxes()
  UpdateMinimapRadioButtons()
end

function AutoLFM.UI.MorePanel.Hide()
  if morePanelFrame then
    morePanelFrame:Hide()
  end
end

function AutoLFM.UI.MorePanel.GetFrame()
  return morePanelFrame
end

function AutoLFM.UI.MorePanel.GetBroadcastToggleButton()
  return AutoLFM.UI.MainWindow.GetStartButton()
end

function AutoLFM.UI.MorePanel.GetBroadcastIntervalSlider()
  return broadcastIntervalSlider
end

function AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  return customMessageEditBox
end

function AutoLFM.UI.MorePanel.EnsureChannelUIExists()
  return channelsFrame ~= nil
end

function AutoLFM.UI.MorePanel.Register()
  AutoLFM.UI.TabNavigation.RegisterPanel("more",
    AutoLFM.UI.MorePanel.Show,
    AutoLFM.UI.MorePanel.Hide,
    function()
      AutoLFM.UI.MorePanel.RefreshChannelCheckboxes()
      if AutoLFM.UI.RaidsPanel.HideSizeControls then
        AutoLFM.UI.RaidsPanel.HideSizeControls()
      end
      if AutoLFM.UI.DungeonsPanel.ClearBackdrops then
        AutoLFM.UI.DungeonsPanel.ClearBackdrops()
      end
      if AutoLFM.UI.RaidsPanel.ClearBackdrops then
        AutoLFM.UI.RaidsPanel.ClearBackdrops()
      end
    end
  )
end
