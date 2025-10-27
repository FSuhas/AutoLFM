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
local mainFrame = nil
local customMessageEditBox = nil
local broadcastIntervalSlider = nil
local channelsFrame = nil
local editBoxHasFocus = false
local lastSliderUpdate = 0
local durationValueText = nil
local sentValueText = nil
local nextValueText = nil
local showRadio = nil
local hideRadio = nil
local channelButtons = {}

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
  local roundedValue = math.floor(value / AutoLFM.Logic.Broadcaster.INTERVAL_STEP + 0.5) * AutoLFM.Logic.Broadcaster.INTERVAL_STEP
  return roundedValue
end

-----------------------------------------------------------------------------
-- Main Panel
-----------------------------------------------------------------------------
local function CreateMainPanel(parentFrame)
  if not parentFrame then return nil end
  
  local panelData = AutoLFM.UI.PanelBuilder.CreatePanel(parentFrame, "AutoLFM_MorePanel")
  if not panelData then return nil end
  
  mainFrame = panelData.panel
  mainFrame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 25, -155)
  mainFrame:SetWidth(292)
  mainFrame:SetHeight(253)
  mainFrame:SetBackdrop({
    bgFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "tooltipBackground",
    tile = true,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  mainFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.5)
  
  return mainFrame
end

-----------------------------------------------------------------------------
-- Custom Message EditBox
-----------------------------------------------------------------------------
local function CreateCustomMessageEditBox()
  if not mainFrame then return end
  
  local editboxIcon = mainFrame:CreateTexture(nil, "OVERLAY")
  editboxIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\send")
  editboxIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  editboxIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  editboxIcon:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 5, -5)
  
  local editboxLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  editboxLabel:SetText("Add details to your message:")
  editboxLabel:SetPoint("LEFT", editboxIcon, "RIGHT", 3, 0)
  editboxLabel:SetTextColor(1, 1, 1)

  customMessageEditBox = CreateFrame("EditBox", "AutoLFM_EditBox", mainFrame)
  customMessageEditBox:SetPoint("TOPLEFT", editboxIcon, "BOTTOMLEFT", 0, -5)
  customMessageEditBox:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.EDITBOX_WIDTH)
  customMessageEditBox:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.EDITBOX_HEIGHT)
  customMessageEditBox:SetAutoFocus(false)
  customMessageEditBox:SetFontObject(GameFontNormal)
  customMessageEditBox:SetMaxLetters(AutoLFM.UI.MorePanel.MAX_MESSAGE_LENGTH)
  customMessageEditBox:SetText("")
  customMessageEditBox:SetBackdrop({
    bgFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "tooltipBackground",
    edgeFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "tooltipBorder",
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
  
  updatePlaceholder()
  
  return customMessageEditBox
end

-----------------------------------------------------------------------------
-- Broadcast Interval Slider
-----------------------------------------------------------------------------
local function CreateBroadcastIntervalSlider()
  if not mainFrame or not customMessageEditBox then return end
  
  local sliderIcon = mainFrame:CreateTexture(nil, "OVERLAY")
  sliderIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\tool")
  sliderIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  sliderIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  sliderIcon:SetPoint("TOPLEFT", customMessageEditBox, "BOTTOMLEFT", 0, -10)
  
  local sliderLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sliderLabel:SetText("Interval:")
  sliderLabel:SetPoint("LEFT", sliderIcon, "RIGHT", 3, 0)
  sliderLabel:SetTextColor(1, 1, 1)
  
  broadcastIntervalSlider = CreateFrame("Slider", nil, mainFrame)
  broadcastIntervalSlider:SetWidth(145)
  broadcastIntervalSlider:SetHeight(17)
  broadcastIntervalSlider:SetPoint("LEFT", sliderLabel, "RIGHT", 10, 0)
  broadcastIntervalSlider:SetMinMaxValues(AutoLFM.Logic.Broadcaster.INTERVAL_MIN, AutoLFM.Logic.Broadcaster.INTERVAL_MAX)
  
  local savedInterval = AutoLFM.Core.Settings.LoadInterval()
  broadcastIntervalSlider:SetValue(savedInterval)
  
  broadcastIntervalSlider:SetValueStep(AutoLFM.Logic.Broadcaster.INTERVAL_STEP)
  broadcastIntervalSlider:SetOrientation("HORIZONTAL")
  broadcastIntervalSlider:SetThumbTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "sliderButtonHorizontal")
  broadcastIntervalSlider:SetBackdrop({
    bgFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "sliderBackground",
    edgeFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "sliderBorder",
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = {left = 3, right = 3, top = 6, bottom = 6}
  })
  
  local sliderValue = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
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
  
  return sliderIcon
end

-----------------------------------------------------------------------------
-- Statistics Display
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

local function CreateStatsList(lastAnchor)
  if not mainFrame or not lastAnchor then return end
  
  local durationIcon = mainFrame:CreateTexture(nil, "OVERLAY")
  durationIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\bag")
  durationIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  durationIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  durationIcon:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -7)
  
  local durationLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  durationLabel:SetText("Duration: ")
  durationLabel:SetPoint("LEFT", durationIcon, "RIGHT", 3, 0)
  durationLabel:SetTextColor(1, 1, 1)
  
  durationValueText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  durationValueText:SetText("00:00")
  durationValueText:SetPoint("LEFT", durationLabel, "RIGHT", 0, 0)
  
  local sentIcon = mainFrame:CreateTexture(nil, "OVERLAY")
  sentIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\book")
  sentIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  sentIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  sentIcon:SetPoint("TOPLEFT", durationIcon, "BOTTOMLEFT", 0, -7)
  
  local sentLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sentLabel:SetText("Sent: ")
  sentLabel:SetPoint("LEFT", sentIcon, "RIGHT", 3, 0)
  sentLabel:SetTextColor(1, 1, 1)
  
  sentValueText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sentValueText:SetText("0")
  sentValueText:SetPoint("LEFT", sentLabel, "RIGHT", 0, 0)
  
  local nextIcon = mainFrame:CreateTexture(nil, "OVERLAY")
  nextIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\chat")
  nextIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  nextIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  nextIcon:SetPoint("TOPLEFT", sentIcon, "BOTTOMLEFT", 0, -7)
  
  local nextLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nextLabel:SetText("Next: ")
  nextLabel:SetPoint("LEFT", nextIcon, "RIGHT", 3, 0)
  nextLabel:SetTextColor(1, 1, 1)
  
  nextValueText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nextValueText:SetText("--")
  nextValueText:SetPoint("LEFT", nextLabel, "RIGHT", 0, 0)
  
  return durationIcon, nextIcon
end

-----------------------------------------------------------------------------
-- Minimap Controls
-----------------------------------------------------------------------------
local function UpdateMinimapRadioButtons()
  if not showRadio or not hideRadio then return end
  if not AutoLFM_MinimapButton then return end
  
  local isVisible = AutoLFM_MinimapButton:IsShown()
  showRadio:SetChecked(isVisible)
  hideRadio:SetChecked(not isVisible)
end

local function CreateMinimapList(lastAnchor)
  if not mainFrame or not lastAnchor then return end
  
  local minimapIcon = mainFrame:CreateTexture(nil, "OVERLAY")
  minimapIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\minimap")
  minimapIcon:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  minimapIcon:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  minimapIcon:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -7)
  
  local minimapTitle = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  minimapTitle:SetText("Minimap button:")
  minimapTitle:SetPoint("LEFT", minimapIcon, "RIGHT", 3, 0)
  minimapTitle:SetTextColor(1, 1, 1)
  
  local isVisible = AutoLFM_MinimapButton and AutoLFM_MinimapButton:IsShown()
  
  showRadio = CreateFrame("CheckButton", nil, mainFrame, "UIRadioButtonTemplate")
  showRadio:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  showRadio:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  showRadio:SetPoint("TOPLEFT", minimapIcon, "BOTTOMLEFT", 10, -5)
  showRadio:SetChecked(isVisible)
  
  local showText = CreateFrame("Button", nil, mainFrame)
  showText:SetPoint("LEFT", showRadio, "RIGHT", 0, 0)
  showText:SetWidth(55)
  showText:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.BUTTON_HEIGHT)
  
  local showLabel = showText:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  showLabel:SetPoint("LEFT", showText, "LEFT", 5, 0)
  showLabel:SetText("Show")
  showLabel:SetTextColor(1, 0.82, 0)
  
  showText:SetScript("OnClick", function()
    showRadio:Click()
  end)
  
  showText:SetScript("OnEnter", function()
    showLabel:SetTextColor(0.3, 0.6, 1)
    showRadio:LockHighlight()
  end)
  
  showText:SetScript("OnLeave", function()
    showLabel:SetTextColor(1, 0.82, 0)
    showRadio:UnlockHighlight()
  end)
  
  showRadio:SetScript("OnEnter", function()
    showLabel:SetTextColor(0.3, 0.6, 1)
  end)
  
  showRadio:SetScript("OnLeave", function()
    showLabel:SetTextColor(1, 0.82, 0)
  end)
  
  showRadio:SetScript("OnClick", function()
    if AutoLFM_MinimapButton and not AutoLFM_MinimapButton:IsShown() then
      AutoLFM_MinimapButton:Show()
      AutoLFM.Core.Settings.SaveMinimapHidden(false)
    end
    UpdateMinimapRadioButtons()
  end)
  
  hideRadio = CreateFrame("CheckButton", nil, mainFrame, "UIRadioButtonTemplate")
  hideRadio:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  hideRadio:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  hideRadio:SetPoint("TOPLEFT", showRadio, "BOTTOMLEFT", 0, -4)
  hideRadio:SetChecked(not isVisible)
  
  local hideText = CreateFrame("Button", nil, mainFrame)
  hideText:SetPoint("LEFT", hideRadio, "RIGHT", 0, 0)
  hideText:SetWidth(55)
  hideText:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.BUTTON_HEIGHT)
  
  local hideLabel = hideText:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  hideLabel:SetPoint("LEFT", hideText, "LEFT", 5, 0)
  hideLabel:SetText("Hide")
  hideLabel:SetTextColor(1, 0.82, 0)
  
  hideText:SetScript("OnClick", function()
    hideRadio:Click()
  end)
  
  hideText:SetScript("OnEnter", function()
    hideLabel:SetTextColor(0.3, 0.6, 1)
    hideRadio:LockHighlight()
  end)
  
  hideText:SetScript("OnLeave", function()
    hideLabel:SetTextColor(1, 0.82, 0)
    hideRadio:UnlockHighlight()
  end)
  
  hideRadio:SetScript("OnEnter", function()
    hideLabel:SetTextColor(0.3, 0.6, 1)
  end)
  
  hideRadio:SetScript("OnLeave", function()
    hideLabel:SetTextColor(1, 0.82, 0)
  end)
  
  hideRadio:SetScript("OnClick", function()
    if AutoLFM_MinimapButton and AutoLFM_MinimapButton:IsShown() then
      AutoLFM_MinimapButton:Hide()
      AutoLFM.Core.Settings.SaveMinimapHidden(true)
    end
    UpdateMinimapRadioButtons()
  end)
  
  local resetButton = CreateFrame("Button", nil, mainFrame)
  resetButton:SetWidth(20)
  resetButton:SetHeight(20)
  resetButton:SetPoint("TOPLEFT", hideRadio, "BOTTOMLEFT", -2, -4)
  
  local resetIcon = resetButton:CreateTexture(nil, "ARTWORK")
  resetIcon:SetAllPoints(resetButton)
  resetIcon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\buttonRotationLeft")
  
  local resetHL = resetButton:CreateTexture(nil, "HIGHLIGHT")
  resetHL:SetAllPoints(resetButton)
  resetHL:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Icons\\buttonHighlight")
  resetHL:SetBlendMode("ADD")
  
  local resetText = CreateFrame("Button", nil, mainFrame)
  resetText:SetPoint("LEFT", resetButton, "RIGHT", 0, 0)
  resetText:SetWidth(55)
  resetText:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.BUTTON_HEIGHT)
  
  local resetLabel = resetText:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  resetLabel:SetPoint("LEFT", resetText, "LEFT", 5, 0)
  resetLabel:SetText("Reset")
  resetLabel:SetTextColor(1, 0.82, 0)
  
  resetText:SetScript("OnClick", function()
    resetButton:Click()
  end)
  
  resetText:SetScript("OnEnter", function()
    resetLabel:SetTextColor(0.3, 0.6, 1)
    resetButton:LockHighlight()
    GameTooltip:SetOwner(resetText, "ANCHOR_RIGHT")
    GameTooltip:SetText("Reset minimap button position", 1, 1, 1)
    GameTooltip:Show()
  end)
  
  resetText:SetScript("OnLeave", function()
    resetLabel:SetTextColor(1, 0.82, 0)
    resetButton:UnlockHighlight()
    GameTooltip:Hide()
  end)
  
  resetButton:SetScript("OnEnter", function()
    resetLabel:SetTextColor(0.3, 0.6, 1)
    GameTooltip:SetOwner(resetButton, "ANCHOR_RIGHT")
    GameTooltip:SetText("Reset minimap button position", 1, 1, 1)
    GameTooltip:Show()
  end)
  
  resetButton:SetScript("OnLeave", function()
    resetLabel:SetTextColor(1, 0.82, 0)
    GameTooltip:Hide()
  end)
  
  resetButton:SetScript("OnClick", function()
    AutoLFM.Core.Settings.ResetMinimapPos()
    
    if AutoLFM_MinimapButton and AutoLFM.UI.MinimapButton.ResetPosition then
      AutoLFM.UI.MinimapButton.ResetPosition()
      AutoLFM_MinimapButton:Show()
      AutoLFM.Core.Settings.SaveMinimapHidden(false)
    end
    
    UpdateMinimapRadioButtons()
  end)
  
  UpdateMinimapRadioButtons()
  
  return minimapIcon
end

-----------------------------------------------------------------------------
-- Channel Selector (Independent Frame)
-----------------------------------------------------------------------------
local function CreateChannelCheckbox(parentFrame, channelName, lastButton)
  if not parentFrame or not channelName then return nil end
  
  local hasAccess = true
  if channelName == "Hardcore" then
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
      AutoLFM.Logic.Selection.ToggleChannel(channelName, this:GetChecked())
    end
  end)
  
  if not button then return nil end
  
  button:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  button:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
  
  if lastButton then
    button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT", 0, -4)
  else
    button:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 10, -20)
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
  channelText:SetText(channelName)
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
    button:SetChecked(AutoLFM.Logic.Selection.IsChannelSelected(channelName))
  else
    button:SetChecked(false)
  end
  
  channelButtons[channelName] = button
  
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
  
  for _, channelName in ipairs(foundChannels) do
    if channelName then
      lastButton = CreateChannelCheckbox(channelsFrame, channelName, lastButton)
    end
  end
end

local function CreateChannelsFrame(lastAnchor)
  if not mainFrame or not lastAnchor then return end
  if channelsFrame then
    channelsFrame:SetParent(mainFrame)
    channelsFrame:Show()
    return
  end
  
  channelsFrame = CreateFrame("Frame", "AutoLFM_ChannelSelector", mainFrame)
  channelsFrame:SetWidth(135)
  channelsFrame:SetHeight(100)
  channelsFrame:SetBackdrop({
    bgFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "tooltipBackground",
    tile = true,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 0 }
  })
  channelsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.3)
  channelsFrame:SetPoint("TOPLEFT", lastAnchor, "TOPRIGHT", 130, 0)
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
end

-----------------------------------------------------------------------------
-- Public Functions
-----------------------------------------------------------------------------
function AutoLFM.UI.MorePanel.Create(parentFrame)
  if not parentFrame then return nil end
  if mainFrame then return mainFrame end
  
  CreateMainPanel(parentFrame)
  CreateCustomMessageEditBox()
  local sliderAnchor = CreateBroadcastIntervalSlider()
  local durationAnchor, minimapAnchor = CreateStatsList(sliderAnchor)
  CreateChannelsFrame(durationAnchor)
  CreateMinimapList(minimapAnchor)
  
  mainFrame:SetScript("OnUpdate", function()
    UpdateStatsDisplay()
    UpdateMinimapRadioButtons()
    
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
  
  return mainFrame
end

function AutoLFM.UI.MorePanel.Show()
  if mainFrame then
    mainFrame:Show()
  end
  
  AutoLFM.UI.MorePanel.RefreshChannelCheckboxes()
  UpdateMinimapRadioButtons()
end

function AutoLFM.UI.MorePanel.Hide()
  if mainFrame then
    mainFrame:Hide()
  end
end

function AutoLFM.UI.MorePanel.GetFrame()
  return mainFrame
end

function AutoLFM.UI.MorePanel.GetBroadcastIntervalSlider()
  return broadcastIntervalSlider
end

function AutoLFM.UI.MorePanel.GetCustomMessageEditBox()
  return customMessageEditBox
end

function AutoLFM.UI.MorePanel.RefreshChannelCheckboxes()
  CreateChannelCheckboxes()
end

function AutoLFM.UI.MorePanel.UpdateChannelCheckboxes()
  if not channelButtons or not AutoLFM.Logic.Selection.IsChannelSelected then return end
  AutoLFM.UI.PanelBuilder.BatchUpdateCheckboxes(channelButtons, AutoLFM.Logic.Selection.IsChannelSelected)
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
