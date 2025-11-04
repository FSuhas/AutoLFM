--=============================================================================
-- AutoLFM: More Panel
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.MorePanel then AutoLFM.UI.MorePanel = {} end

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
local minimapRadioGroup = nil
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
  local roundedValue = math.floor(value / AutoLFM.Core.Constants.INTERVAL_STEP + 0.5) * AutoLFM.Core.Constants.INTERVAL_STEP
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
    bgFile = AutoLFM.Core.Constants.TEXTURE_PATH .. "tooltipBackground",
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
  local editboxIcon = AutoLFM.UI.PanelBuilder.CreateIconWithLabel({
    parent = mainFrame,
    texture = "Icons\\send",
    label = "Add details to your message:",
    labelColor = "white",
    point = {
      point = "TOPLEFT",
      relativeTo = mainFrame,
      relativePoint = "TOPLEFT",
      x = 5,
      y = -5
    }
  })

  customMessageEditBox = CreateFrame("EditBox", "AutoLFM_EditBox", mainFrame)
  customMessageEditBox:SetPoint("TOPLEFT", editboxIcon, "BOTTOMLEFT", 0, -5)
  customMessageEditBox:SetWidth(AutoLFM.Core.Constants.EDITBOX_WIDTH)
  customMessageEditBox:SetHeight(AutoLFM.Core.Constants.EDITBOX_HEIGHT)
  customMessageEditBox:SetAutoFocus(false)
  customMessageEditBox:SetFontObject(GameFontNormal)
  customMessageEditBox:SetMaxLetters(AutoLFM.Core.Constants.MAX_MESSAGE_LENGTH)
  customMessageEditBox:SetText("")
  customMessageEditBox:SetBackdrop({
    bgFile = AutoLFM.Core.Constants.TEXTURE_PATH .. "tooltipBackground",
    edgeFile = AutoLFM.Core.Constants.TEXTURE_PATH .. "tooltipBorder",
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
  local sliderIcon, sliderLabel = AutoLFM.UI.PanelBuilder.CreateIconWithLabel({
    parent = mainFrame,
    texture = "Icons\\tool",
    label = "Interval:",
    labelColor = "white",
    point = {
      point = "TOPLEFT",
      relativeTo = customMessageEditBox,
      relativePoint = "BOTTOMLEFT",
      x = 0,
      y = -10
    }
  })
  local savedInterval = AutoLFM.Core.Settings.LoadInterval()
  local sliderValue = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sliderValue:SetText(savedInterval .. " secs")
  broadcastIntervalSlider = AutoLFM.UI.PanelBuilder.CreateSlider({
    parent = mainFrame,
    width = 145,
    height = 17,
    minValue = AutoLFM.Core.Constants.INTERVAL_MIN,
    maxValue = AutoLFM.Core.Constants.INTERVAL_MAX,
    initialValue = savedInterval,
    valueStep = AutoLFM.Core.Constants.INTERVAL_STEP,
    point = {
      point = "LEFT",
      relativeTo = sliderLabel,
      relativePoint = "RIGHT",
      x = 10,
      y = 0
    },
    onValueChanged = function(value)
      sliderValue:SetText(math.floor(value) .. " secs")
      AutoLFM.Core.Settings.SaveInterval(value)
      if AutoLFM and AutoLFM.API and type(AutoLFM.API.NotifyDataChanged) == "function" then
        AutoLFM.API.NotifyDataChanged(AutoLFM.API.EVENTS.INTERVAL_CHANGED)
      end
    end
  })
  sliderValue:SetPoint("LEFT", broadcastIntervalSlider, "RIGHT", 10, 0)
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
  local durationIcon, durationLabel = AutoLFM.UI.PanelBuilder.CreateIconWithLabel({
    parent = mainFrame,
    texture = "Icons\\bag",
    label = "Duration: ",
    labelColor = "white",
    point = {
      point = "TOPLEFT",
      relativeTo = lastAnchor,
      relativePoint = "BOTTOMLEFT",
      x = 0,
      y = -7
    }
  })
  durationValueText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  durationValueText:SetText("00:00")
  durationValueText:SetPoint("LEFT", durationLabel, "RIGHT", 0, 0)
  local sentIcon, sentLabel = AutoLFM.UI.PanelBuilder.CreateIconWithLabel({
    parent = mainFrame,
    texture = "Icons\\book",
    label = "Sent: ",
    labelColor = "white",
    point = {
      point = "TOPLEFT",
      relativeTo = durationIcon,
      relativePoint = "BOTTOMLEFT",
      x = 0,
      y = -7
    }
  })
  sentValueText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  sentValueText:SetText("0")
  sentValueText:SetPoint("LEFT", sentLabel, "RIGHT", 0, 0)
  local nextIcon, nextLabel = AutoLFM.UI.PanelBuilder.CreateIconWithLabel({
    parent = mainFrame,
    texture = "Icons\\chat",
    label = "Next: ",
    labelColor = "white",
    point = {
      point = "TOPLEFT",
      relativeTo = sentIcon,
      relativePoint = "BOTTOMLEFT",
      x = 0,
      y = -7
    }
  })
  nextValueText = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nextValueText:SetText("--")
  nextValueText:SetPoint("LEFT", nextLabel, "RIGHT", 0, 0)
  return durationIcon, nextIcon
end

-----------------------------------------------------------------------------
-- Minimap Controls
-----------------------------------------------------------------------------
local function UpdateMinimapRadioButtons()
  if not minimapRadioGroup then return end
  if not AutoLFM_MinimapButton then return end

  local isVisible = AutoLFM_MinimapButton:IsShown()
  if isVisible then
    minimapRadioGroup.Update("show")
  else
    minimapRadioGroup.Update("hide")
  end
end

local function CreateMinimapList(lastAnchor)
  if not mainFrame or not lastAnchor then return end
  local minimapIcon = AutoLFM.UI.PanelBuilder.CreateIconWithLabel({
    parent = mainFrame,
    texture = "Icons\\minimap",
    label = "Minimap button:",
    labelColor = "white",
    point = {
      point = "TOPLEFT",
      relativeTo = lastAnchor,
      relativePoint = "BOTTOMLEFT",
      x = 0,
      y = -7
    }
  })

  local isVisible = AutoLFM_MinimapButton and AutoLFM_MinimapButton:IsShown()
  minimapRadioGroup = AutoLFM.UI.PanelBuilder.CreateRadioButtonGroup({
    parent = mainFrame,
    anchor = {
      point = "TOPLEFT",
      relativeTo = minimapIcon,
      relativePoint = "BOTTOMLEFT",
      x = 10,
      y = -5
    },
    buttons = {
      {
        key = "show",
        label = "Show",
        checked = isVisible,
        onClick = function()
          if AutoLFM_MinimapButton and not AutoLFM_MinimapButton:IsShown() then
            AutoLFM_MinimapButton:Show()
            AutoLFM.Core.Settings.SaveMinimapHidden(false)
          end
        end
      },
      {
        key = "hide",
        label = "Hide",
        checked = not isVisible,
        onClick = function()
          if AutoLFM_MinimapButton and AutoLFM_MinimapButton:IsShown() then
            AutoLFM_MinimapButton:Hide()
            AutoLFM.Core.Settings.SaveMinimapHidden(true)
          end
        end
      }
    },
    labelWidth = 55,
    labelColor = "gold",
    hoverColor = "blue",
    spacing = -4
  })
  if not minimapRadioGroup then return nil end

  local lastRadio = minimapRadioGroup.radioButtons["hide"]
  local resetButton = CreateFrame("Button", nil, mainFrame)
  resetButton:SetWidth(20)
  resetButton:SetHeight(20)
  resetButton:SetPoint("TOPLEFT", lastRadio, "BOTTOMLEFT", -2, -4)

  local resetIcon = resetButton:CreateTexture(nil, "ARTWORK")
  resetIcon:SetAllPoints(resetButton)
  resetIcon:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "Icons\\buttonRotationLeft")

  local resetHL = resetButton:CreateTexture(nil, "HIGHLIGHT")
  resetHL:SetAllPoints(resetButton)
  resetHL:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "Icons\\buttonHighlight")
  resetHL:SetBlendMode("ADD")

  local resetText = CreateFrame("Button", nil, mainFrame)
  resetText:SetPoint("LEFT", resetButton, "RIGHT", 0, 0)
  resetText:SetWidth(55)
  resetText:SetHeight(AutoLFM.Core.Constants.BUTTON_HEIGHT)

  local resetLabel = resetText:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  resetLabel:SetPoint("LEFT", resetText, "LEFT", 5, 0)
  resetLabel:SetText("Reset")
  AutoLFM.Core.Utils.SetFontColor(resetLabel, "gold")

  resetText:SetScript("OnClick", function()
    resetButton:Click()
  end)

  AutoLFM.UI.PanelBuilder.AttachLabelHighlight(resetText, resetLabel, "gold", "blue")
  AutoLFM.UI.PanelBuilder.AttachLabelHighlight(resetButton, resetLabel, "gold", "blue")

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
  button:SetWidth(AutoLFM.Core.Constants.ICON_SIZE)
  button:SetHeight(AutoLFM.Core.Constants.ICON_SIZE)
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
  AutoLFM.Core.Utils.SetFontColor(channelText, "gold")
  if not hasAccess then
    AutoLFM.Core.Utils.SetFontColor(channelText, "gray")
  end
  button:SetScript("OnEnter", function()
    if hasAccess then
      AutoLFM.Core.Utils.SetFontColor(channelText, "blue")
    end
  end)
  button:SetScript("OnLeave", function()
    if hasAccess then
      AutoLFM.Core.Utils.SetFontColor(channelText, "gold")
    else
      AutoLFM.Core.Utils.SetFontColor(channelText, "gray")
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
    bgFile = AutoLFM.Core.Constants.TEXTURE_PATH .. "tooltipBackground",
    tile = true,
    tileSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 0 }
  })
  channelsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.3)
  channelsFrame:SetPoint("TOPLEFT", lastAnchor, "TOPRIGHT", 130, 0)
  channelsFrame:Show()
  AutoLFM.UI.PanelBuilder.CreateIconWithLabel({
    parent = channelsFrame,
    texture = "Icons\\channel",
    label = "Channels:",
    labelColor = "white",
    point = {
      point = "TOPLEFT",
      relativeTo = channelsFrame,
      relativePoint = "TOPLEFT",
      x = 0,
      y = 0
    }
  })
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
    if now - lastSliderUpdate < AutoLFM.Core.Constants.UPDATE_THROTTLE then return end
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
