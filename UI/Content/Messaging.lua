--=============================================================================
-- AutoLFM: Messaging UI
--   UI handlers for messaging configuration
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.Content = AutoLFM.UI.Content or {}
AutoLFM.UI.Content.Messaging = {}

--=============================================================================
-- CONSTANTS
--=============================================================================
local EDITBOX_WIDTH = 285
local EDITBOX_HEIGHT = 75
local CHAT_MESSAGE_MAX_LENGTH = 255
local EDITBOX_SPACING = 3
local GROUP_SIZE_MIN = 2
local GROUP_SIZE_MAX = 40
local GROUP_SIZE_DEFAULT = 5
local BROADCAST_INTERVAL_MIN = 30
local BROADCAST_INTERVAL_MAX = 120
local BROADCAST_INTERVAL_STEP = 10
local MODE_DETAILS = "details"
local MODE_CUSTOM = "custom"
local PLACEHOLDER_DETAILS = "Shift+Click to add links or items"
local PLACEHOLDER_CUSTOM = "See icon tooltip for variables usage"
local LABEL_DETAILS = "Add details after generated message:"
local LABEL_CUSTOM = "Create full custom message:"

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local uiFrame
local customMessageEditBox
local customMessagePlaceholder
local customMessageContainer
local broadcastIntervalSlider
local broadcastIntervalValue
local detailsRadio
local customRadio
local customMessageLabel
local usageIcon
local usageIconTexture
local usageIconHighlight
local groupSizeControl
local groupSizeSlider
local groupSizeControlEditBox

-- Session mode (persists between tab openings, initialized from saved preference at reload)
local sessionMode = nil

-- Flag to prevent OnTextChanged from dispatching during programmatic updates
local isRestoringFromState = false

--=============================================================================
-- HELPER FUNCTIONS
--=============================================================================

--- Clamps a value between min and max bounds
--- @param value number - Value to clamp
--- @param min number - Minimum bound
--- @param max number - Maximum bound
--- @return number - Clamped value
local function clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

--- Hides a slider's Low/High text labels
--- @param slider frame - Slider frame
local function hideSliderLabels(slider)
  if not slider then return end
  local name = slider:GetName()
  local low = getglobal(name .. "Low")
  local high = getglobal(name .. "High")
  if low then low:Hide() end
  if high then high:Hide() end
end

--- Sets up mousewheel scroll handling for a slider
--- @param slider frame - Slider frame
--- @param step number - Value change per scroll notch
--- @param min number - Minimum slider value
--- @param max number - Maximum slider value
local function setupSliderMouseWheel(slider, step, min, max)
  if not slider then return end
  slider:SetScript("OnMouseWheel", function()
    local value = this:GetValue()
    local delta = arg1 > 0 and step or -step
    this:SetValue(clamp(value + delta, min, max))
  end)
end

--- Returns current broadcast mode based on radio button state
--- @return string - MODE_CUSTOM or MODE_DETAILS
local function getCurrentMode()
  return (customRadio and customRadio:GetChecked()) and MODE_CUSTOM or MODE_DETAILS
end

--- Sets radio button checked states based on mode
--- @param mode string - MODE_DETAILS or MODE_CUSTOM
local function setRadioButtonStates(mode)
  local isDetails = (mode == MODE_DETAILS)
  if detailsRadio and customRadio then
  if isDetails then
    detailsRadio:SetChecked(1)
    customRadio:SetChecked(nil)
  else
    detailsRadio:SetChecked(nil)
    customRadio:SetChecked(1)
  end
  end
end

--- Gets a global UI element by name (wrapper for getglobal)
--- @param name string - Global frame name
--- @return frame|nil - Frame object or nil
local function getUIElement(name)
  return getglobal(name)
end

--- Applies a color to a label by name
--- @param labelName string - Global name of the label frame
--- @param colorName string - Color name (e.g., "GOLD", "WHITE")
local function applyColor(labelName, colorName)
  if not AutoLFM.Core.Utils then return end
  local label = getUIElement(labelName)
  if label then
    AutoLFM.Core.Utils.SetTextColorByName(label, colorName)
  end
end

--- Applies white color to a label (convenience wrapper)
--- @param labelName string - Global name of the label frame
local function applyWhiteColor(labelName)
  applyColor(labelName, "WHITE")
end

--- Applies gray color to a label (convenience wrapper)
--- @param labelName string - Global name of the label frame
local function applyGrayColor(labelName)
  applyColor(labelName, "GRAY")
end

--=============================================================================
-- EVENT HANDLERS
--=============================================================================
-----------------------------------------------------------------------------
-- Group Size Slider Load Handler
-----------------------------------------------------------------------------
--- XML OnLoad callback for group size slider - initializes slider properties
--- @param slider frame - The group size slider frame
function AutoLFM.UI.Content.Messaging.OnGroupSizeSliderLoad(slider)
  if not slider then return end

  slider:SetMinMaxValues(GROUP_SIZE_MIN, GROUP_SIZE_MAX)
  slider:SetValueStep(1)
  slider:SetValue(GROUP_SIZE_DEFAULT)
  slider:SetOrientation("HORIZONTAL")
  slider:EnableMouseWheel(true)
  hideSliderLabels(slider)
end

-----------------------------------------------------------------------------
-- Group Size Slider Enter Handler
-----------------------------------------------------------------------------
--- XML OnEnter callback for group size slider - focuses and highlights the editbox
--- Allows user to directly type a value when hovering over the slider
function AutoLFM.UI.Content.Messaging.OnGroupSizeSliderEnter()
  if groupSizeControlEditBox then
    groupSizeControlEditBox:SetFocus()
    groupSizeControlEditBox:HighlightText()
  end
end

-----------------------------------------------------------------------------
-- Group Size Slider Mouse Wheel Handler
-----------------------------------------------------------------------------
--- XML OnMouseWheel callback for group size slider - adjusts value by mouse wheel
--- @param slider frame - The group size slider frame
--- @param delta number - Mouse wheel direction (positive = scroll up, negative = scroll down)
function AutoLFM.UI.Content.Messaging.OnGroupSizeSliderMouseWheel(slider, delta)
  if not slider then return end
  local value = slider:GetValue()
  local step = delta > 0 and 1 or -1
  slider:SetValue(clamp(value + step, GROUP_SIZE_MIN, GROUP_SIZE_MAX))
end

-----------------------------------------------------------------------------
-- Group Size EditBox Commit Handler
-----------------------------------------------------------------------------
--- XML OnEnterPressed/OnEditFocusLost callback for group size editbox - validates and commits value
--- Ensures value stays within GROUP_SIZE_MIN to GROUP_SIZE_MAX range and syncs with slider
--- @param editBox frame - The group size editbox frame
function AutoLFM.UI.Content.Messaging.OnGroupSizeEditBoxCommit(editBox)
  if not editBox then return end

  local text = editBox:GetText()
  if text == "" then
    editBox:SetText(tostring(GROUP_SIZE_MIN))
    return
  end

  local value = tonumber(text)
  if value then
    value = clamp(value, GROUP_SIZE_MIN, GROUP_SIZE_MAX)

    -- Dispatch Command to update Maestro State
    AutoLFM.Core.Maestro.Dispatch("Selection.SetCustomGroupSize", value)

    if groupSizeSlider then
      groupSizeSlider:SetValue(value)
    end
    editBox:SetText(tostring(value))
  end
end

--=============================================================================
-- EDITBOX FUNCTIONS
--=============================================================================

--- Calculates the length of text with variables expanded
local function calculateExpandedLength(text)
  if not text or text == "" then return 0 end
  
  -- Replace variables with estimated max lengths
  local expanded = text
  expanded = string.gsub(expanded, "{ROL}", "Tank, Healer, DPS")  -- ~18 chars max
  expanded = string.gsub(expanded, "{CUR}", "40")  -- 2 chars max
  expanded = string.gsub(expanded, "{TAR}", "40")  -- 2 chars max
  expanded = string.gsub(expanded, "{MIS}", "40")  -- 2 chars max
  
  return string.len(expanded)
end

--- Updates editbox max letters based on generated message length
local function updateEditBoxMaxLetters()
  if not customMessageEditBox then return end
  
  local currentMode = getCurrentMode()
  local usedLength = 0
  
  if currentMode == MODE_DETAILS then
    -- Details mode: generated message + links
    local message = AutoLFM.Core.Maestro.GetState("Message.ToBroadcast") or ""
    local detailsText = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""
    usedLength = string.len(message) - string.len(detailsText)
  else
    -- Custom mode: calculate expanded variable length
    local customMessage = customMessageEditBox:GetText() or ""
    usedLength = calculateExpandedLength(customMessage) - string.len(customMessage)
  end
  
  local maxLetters = CHAT_MESSAGE_MAX_LENGTH - usedLength
  customMessageEditBox:SetMaxLetters(math.max(1, maxLetters))
end

--- Updates editbox placeholder visibility based on text content
local function updatePlaceholder()
  if not customMessageEditBox or not customMessagePlaceholder then return end
  if customMessageEditBox:GetText() == "" then
    customMessagePlaceholder:Show()
  else
    customMessagePlaceholder:Hide()
  end
end

--- Creates the custom message editbox with container, backdrop, and scripts
--- Sets up multiline editbox with placeholder text, auto-height adjustment, and text validation
--- @param scrollChild frame - Parent scroll child frame to anchor the editbox to
local function createEditBox(scrollChild)
  -- Create container frame
  customMessageContainer = CreateFrame("Frame", "AutoLFM_Content_Messaging_EditBox_Container", scrollChild)
  customMessageContainer:SetWidth(EDITBOX_WIDTH)
  customMessageContainer:SetHeight(EDITBOX_HEIGHT)
  customMessageContainer:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -55)
  customMessageContainer:SetFrameLevel(scrollChild:GetFrameLevel() + 1)

  -- Set backdrop
  customMessageContainer:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = false,
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
  })
  customMessageContainer:SetBackdropBorderColor(1, 0.82, 0, 0.8)

  -- Create background texture
  local bg = customMessageContainer:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetTexture(0, 0, 0, 0.6)

  -- Create editbox
  customMessageEditBox = CreateFrame("EditBox", customMessageContainer:GetName() .. "_EditBox", customMessageContainer)
  customMessageEditBox:SetWidth(290)
  customMessageEditBox:SetHeight(EDITBOX_HEIGHT)
  customMessageEditBox:SetPoint("TOPLEFT", customMessageContainer, "TOPLEFT")
  customMessageEditBox:SetAutoFocus(false)
  customMessageEditBox:SetMultiLine(true)
  customMessageEditBox:SetMaxLetters(CHAT_MESSAGE_MAX_LENGTH)
  customMessageEditBox:SetFontObject(GameFontNormalSmall)
  customMessageEditBox:SetTextInsets(5, 5, 5, 8)
  customMessageEditBox:SetSpacing(EDITBOX_SPACING)

  -- Set editbox scripts
  customMessageEditBox:SetScript("OnTextChanged", function()
    local text = this:GetText()
    if text and string.find(text, "\n") then
      this:SetText(string.gsub(text, "\n", ""))
    end
    updatePlaceholder()
    updateEditBoxMaxLetters()

    -- Skip dispatch if we're restoring from State (prevent loop)
    if isRestoringFromState then return end

    -- Dispatch appropriate command based on current mode
    if not text then text = "" end
    local currentMode = getCurrentMode()
    if currentMode == MODE_CUSTOM then
      -- Custom mode: full message with variables
      AutoLFM.Core.Maestro.Dispatch("Selection.SetCustomMessage", text)
    else
      -- Details mode: text appended to auto-generated message
      AutoLFM.Core.Maestro.Dispatch("Selection.SetDetailsText", text)
    end
  end)

  customMessageEditBox:SetScript("OnEscapePressed", function()
    this:ClearFocus()
  end)

  -- Create placeholder text
  customMessagePlaceholder = customMessageEditBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  customMessagePlaceholder:SetPoint("CENTER", customMessageEditBox, "CENTER")
  customMessagePlaceholder:SetText(PLACEHOLDER_DETAILS)

  updatePlaceholder()
end

--- Caches references to all Messaging panel UI elements for quick access
--- Retrieves and stores references to sliders, icons, radios, editboxes, and labels
local function initializeUIReferences()
  broadcastIntervalSlider = getUIElement("AutoLFM_Content_Messaging_BroadcastIntervalSlider")
  broadcastIntervalValue = getUIElement("AutoLFM_Content_Messaging_BroadcastIntervalSlider_Value")
  usageIcon = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_UsageIcon")
  usageIconTexture = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_UsageIcon_Texture")
  usageIconHighlight = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_UsageIcon_Highlight")
  groupSizeControl = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_GroupSizeControl")
  groupSizeSlider = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_GroupSizeControl_Slider")
  groupSizeControlEditBox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_GroupSizeControl_EditBox")
  detailsRadio = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_DetailsRadio")
  customRadio = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_CustomRadio")
  customMessageLabel = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_CustomMessageIcon_Label")
  customMessageEditBox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_EditBoxContainer_EditBox")
  customMessagePlaceholder = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_EditBoxContainer_Placeholder")
  customMessageContainer = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_EditBoxContainer")
end

--- Initializes the broadcast interval slider with mousewheel support
--- Hides default labels and configures mousewheel scrolling with min/max bounds
--- Loads the saved interval value from state
local function setupBroadcastIntervalSlider()
  hideSliderLabels(broadcastIntervalSlider)
  setupSliderMouseWheel(broadcastIntervalSlider, BROADCAST_INTERVAL_STEP, BROADCAST_INTERVAL_MIN, BROADCAST_INTERVAL_MAX)

  -- Load interval value from state (already loaded by Broadcaster init)
  if broadcastIntervalSlider and AutoLFM.Core.Maestro then
    local interval = AutoLFM.Core.Maestro.GetState("Broadcaster.Interval") or 60
    broadcastIntervalSlider:SetValue(interval)
    -- Update the display label
    if broadcastIntervalValue then
      broadcastIntervalValue:SetText(interval .. " secs")
    end
  end
end

--- Sets up group size slider and editbox with default values and positioning
--- Configures editbox styling, initializes slider value, and positions control relative to custom message container
local function setupGroupSizeControls()
  if groupSizeControlEditBox then
    groupSizeControlEditBox:SetJustifyH("CENTER")
    groupSizeControlEditBox:SetTextInsets(2, 2, 2, 2)
    groupSizeControlEditBox:SetText(tostring(GROUP_SIZE_DEFAULT))
    groupSizeControlEditBox:SetBackdropBorderColor(1, 0.82, 0, 0.8)
    groupSizeControlEditBox:EnableMouse(true)
  end

  if groupSizeSlider then
    groupSizeSlider:SetValue(GROUP_SIZE_DEFAULT)
  end

  if groupSizeControl and customMessageContainer then
    groupSizeControl:ClearAllPoints()
    groupSizeControl:SetPoint("TOPLEFT", customMessageContainer, "BOTTOMLEFT", 0, -8)
  end
end

--- Positions UI elements relative to the custom message container
--- Anchors channels icon below the custom message editbox
local function positionUIElements()
  local channelsIcon = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_ChannelsIcon")
  if channelsIcon and customMessageContainer then
    channelsIcon:ClearAllPoints()
    channelsIcon:SetPoint("TOPLEFT", customMessageContainer, "BOTTOMLEFT", 0, -10)
  end
end

--- Updates ScrollChild height based on content
local function updateScrollChildHeight()
  local scrollChild = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild")
  if not scrollChild then return end
  
  local totalHeight = 0
  
  -- Measure actual positions of elements
  local intervalSlider = getUIElement("AutoLFM_Content_Messaging_BroadcastIntervalSlider")
  if intervalSlider then
    local _, _, _, _, bottom = intervalSlider:GetPoint(1)
    totalHeight = math.abs(bottom) + 30  -- Add margin
  else
    -- Fallback calculation
    totalHeight = 240
    if groupSizeControl and groupSizeControl:IsShown() then
      totalHeight = totalHeight + 30
    end
  end
  
  scrollChild:SetHeight(totalHeight)
  
  -- Force scroll frame update like in Dungeons
  AutoLFM.UI.RowList.UpdateScrollFrame(scrollChild)
end

--- Applies color styling to all labels in the Messaging panel
--- Radio buttons and variable values use gold, static labels use white
local function applyLabelColors()
  -- Note: GOLD is the default color in WoW, so we only need to set non-GOLD colors

  -- Static labels in white
  applyWhiteColor("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_CustomMessageIcon_Label")
  applyWhiteColor("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_GroupSizeControl_Label")
  applyWhiteColor("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_ChannelsIcon_Label")
  applyWhiteColor("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_ChannelsIcon_StatsTitle")
  applyWhiteColor("AutoLFM_Content_Messaging_BroadcastIntervalSlider_Label")

  -- Stats labels in white
  applyWhiteColor("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_World_DurationLabel")
  applyWhiteColor("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_LookingForGroup_SentLabel")
  applyWhiteColor("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore_NextLabel")
end

--- Shows or hides a frame based on visibility flag
--- @param frame frame - The frame to show/hide
--- @param visible boolean - True to show, false to hide
local function setFrameVisibility(frame, visible)
  if not frame then return end
  if visible then
    frame:Show()
  else
    frame:Hide()
  end
end

--- Updates UI elements based on broadcast mode (Details vs Custom)
--- Adjusts labels, placeholder text, editbox content, and control visibility
--- Restores editbox content from State when refreshing display
--- @param isCustomMode boolean - True for Custom mode, false for Details mode
--- @param clearOnModeSwitch boolean - If true, clears editbox and State when switching modes
local function updateModeUI(isCustomMode, clearOnModeSwitch)
  if customMessageLabel then
    customMessageLabel:SetText(isCustomMode and LABEL_CUSTOM or LABEL_DETAILS)
  end
  if customMessagePlaceholder then
    customMessagePlaceholder:SetText(isCustomMode and PLACEHOLDER_CUSTOM or PLACEHOLDER_DETAILS)
  end

  if customMessageEditBox then
    if clearOnModeSwitch then
      -- Clear editbox and State when switching modes
      isRestoringFromState = true
      customMessageEditBox:SetText("")
      isRestoringFromState = false

      -- Clear the State we're switching FROM
      if isCustomMode then
        -- Switching TO custom → clear details text
        AutoLFM.Core.Maestro.Dispatch("Selection.SetDetailsText", "")
      else
        -- Switching TO details → clear custom message
        AutoLFM.Core.Maestro.Dispatch("Selection.SetCustomMessage", "")
      end
    else
      -- Restore editbox content from State when just refreshing display
      local text = ""
      if isCustomMode then
        text = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage") or ""
      else
        text = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""
      end

      isRestoringFromState = true
      customMessageEditBox:SetText(text)
      isRestoringFromState = false
    end
  end

  setFrameVisibility(usageIcon, isCustomMode)
  setFrameVisibility(groupSizeControl, isCustomMode)
  
  -- Update scroll after visibility changes
  updateScrollChildHeight()
end

--- Repositions the channels icon based on broadcast mode and control visibility
--- In Custom mode with visible group size control, anchors below control; otherwise anchors below editbox
--- @param isCustomMode boolean - True for Custom mode, false for Details mode
local function repositionChannelsIcon(isCustomMode)
  local channelsIcon = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_ChannelsIcon")
  if not channelsIcon or not customMessageContainer then return end

  channelsIcon:ClearAllPoints()
  if isCustomMode and groupSizeControl and groupSizeControl:IsShown() then
    channelsIcon:SetPoint("TOPLEFT", groupSizeControl, "BOTTOMLEFT", 0, -10)
  else
    channelsIcon:SetPoint("TOPLEFT", customMessageContainer, "BOTTOMLEFT", 0, -10)
  end
end

--- Updates Hardcore checkbox state and label color based on player's hardcore status
--- If player is hardcore: enables checkbox and shows white label
--- If player is not hardcore: disables checkbox, unchecks it, and shows gray label
local function updateHardcoreCheckboxState()
  local hardcoreCheckbox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore")
  local hardcoreLabel = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore_Label")

  if not hardcoreCheckbox then return end

  local isHardcore = false
  if AutoLFM.Core.Persistent and AutoLFM.Core.Persistent.GetIsHardcore then
    isHardcore = AutoLFM.Core.Persistent.GetIsHardcore()
  end

  if isHardcore then
    -- Player is hardcore: enable checkbox
    hardcoreCheckbox:Enable()
    applyWhiteColor("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore_Label")
  else
    -- Player is not hardcore: disable and uncheck checkbox
    hardcoreCheckbox:Disable()
    hardcoreCheckbox:SetChecked(false)
    applyGrayColor("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore_Label")
  end
end

--=============================================================================
-- LIFECYCLE
--=============================================================================

--- XML OnLoad callback - initializes the Messaging panel UI
--- Creates editbox, initializes sliders, sets up controls and applies styling
--- @param frame frame - The Messaging panel frame
function AutoLFM.UI.Content.Messaging.OnLoad(frame)
  uiFrame = frame
  initializeUIReferences()
  setupBroadcastIntervalSlider()
  setupGroupSizeControls()
  positionUIElements()
  setRadioButtonStates(MODE_DETAILS)
  if customMessageLabel then
    customMessageLabel:SetText(LABEL_DETAILS)
  end
  
  -- Apply gold border to main editbox container
  if customMessageContainer then
    customMessageContainer:SetBackdropBorderColor(1, 0.82, 0, 0.8)
  end
  
  applyLabelColors()
  updateScrollChildHeight()
end

--- XML OnShow callback - restores session mode when panel is shown
--- Session mode is initialized from saved preference only at first load (reload/login)
--- Manual toggles during session persist between tab openings but don't affect saved preference
--- @param frame frame - The Messaging panel frame
function AutoLFM.UI.Content.Messaging.OnShow(frame)
  -- Re-apply label colors
  applyLabelColors()

  -- Initialize sessionMode from saved preference only if not set (first load after reload)
  if not sessionMode then
    sessionMode = MODE_DETAILS
    if AutoLFM.Core.Persistent and AutoLFM.Core.Persistent.GetCustomInput then
      local isCustom = AutoLFM.Core.Persistent.GetCustomInput()
      sessionMode = isCustom and MODE_CUSTOM or MODE_DETAILS
    end
  end

  -- Use session mode (persists manual toggles between tab openings)
  setRadioButtonStates(sessionMode)
  AutoLFM.UI.Content.Messaging.UpdateModeDisplay(false)  -- Don't clear on tab display
  updateHardcoreCheckboxState()

  -- Sync channel checkboxes with saved state
  AutoLFM.UI.Content.Messaging.RefreshChannelCheckboxes()

  -- Refresh broadcast interval slider from state
  if broadcastIntervalSlider and AutoLFM.Core.Maestro then
    local interval = AutoLFM.Core.Maestro.GetState("Broadcaster.Interval") or 60
    broadcastIntervalSlider:SetValue(interval)
    if broadcastIntervalValue then
      broadcastIntervalValue:SetText(interval .. " secs")
    end
  end
end

--=============================================================================
-- UI EVENT HANDLERS (called from XML)
--=============================================================================

--- Handles editbox text changes from XML
--- @param editBox frame - The editbox frame
function AutoLFM.UI.Content.Messaging.OnEditBoxTextChanged(editBox)
  if not editBox then return end
  
  local text = editBox:GetText()
  if text and string.find(text, "\n") then
    editBox:SetText(string.gsub(text, "\n", ""))
  end
  
  -- Update placeholder and editbox
  customMessageEditBox = editBox
  customMessagePlaceholder = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_EditBoxContainer_Placeholder")
  updatePlaceholder()
  updateEditBoxMaxLetters()
  
  -- Skip dispatch if we're restoring from State
  if isRestoringFromState then return end
  
  -- Dispatch appropriate command based on current mode
  if not text then text = "" end
  local currentMode = getCurrentMode()
  if currentMode == MODE_CUSTOM then
    AutoLFM.Core.Maestro.Dispatch("Selection.SetCustomMessage", text)
  else
    AutoLFM.Core.Maestro.Dispatch("Selection.SetDetailsText", text)
  end
end

--- Handles broadcast interval slider value changes
--- Updates both the display label and saves the value to Broadcaster
--- @param slider frame - The broadcast interval slider
function AutoLFM.UI.Content.Messaging.OnBroadcastIntervalSliderChanged(slider)
  local value = math.floor(slider:GetValue())

  -- Update display label
  if broadcastIntervalValue then
    broadcastIntervalValue:SetText(value .. " secs")
  end

  -- Save to Broadcaster (which will save to persistent storage)
  if AutoLFM.Logic and AutoLFM.Logic.Broadcaster and AutoLFM.Logic.Broadcaster.SetInterval then
    AutoLFM.Logic.Broadcaster.SetInterval(value)
  end
end

--- Handles broadcast mode radio button clicks (Details/Custom)
--- Updates session mode (does NOT save to persistent storage during session)
--- @param mode string - The selected mode ("details" or "custom")
function AutoLFM.UI.Content.Messaging.OnModeRadioClick(mode)
  -- Update session mode (persists between tab openings, not saved to disk)
  sessionMode = mode

  setRadioButtonStates(mode)
  AutoLFM.UI.Content.Messaging.UpdateModeDisplay(true)  -- Clear on mode switch
end

--- Updates the UI display based on current broadcast mode (details vs custom)
--- Shows/hides appropriate UI elements and repositions the channels icon
--- @param clearOnModeSwitch boolean - If true, clears editbox when switching modes
function AutoLFM.UI.Content.Messaging.UpdateModeDisplay(clearOnModeSwitch)
  local currentMode = getCurrentMode()
  local isCustomMode = (currentMode == MODE_CUSTOM)

  updateModeUI(isCustomMode, clearOnModeSwitch)
  repositionChannelsIcon(isCustomMode)
  updateEditBoxMaxLetters()
end

--- Handles group size slider value changes - updates the editbox display
--- @param value number - The new slider value
function AutoLFM.UI.Content.Messaging.OnGroupSizeSliderChanged(value)
  local size = math.floor(value)
  local currentSize = AutoLFM.Core.Maestro.GetState("Selection.CustomGroupSize") or 5
  
  if size ~= currentSize then
    AutoLFM.Core.Maestro.Dispatch("Selection.SetCustomGroupSize", size)
  end

  if groupSizeControlEditBox and groupSizeControlEditBox:GetText() ~= tostring(size) then
    groupSizeControlEditBox:SetText(tostring(size))
    groupSizeControlEditBox:SetFocus()
    groupSizeControlEditBox:HighlightText()
  end
end

--- Handles usage icon mouse enter - shows tooltip with variable examples
--- @param frame frame - The usage icon frame
function AutoLFM.UI.Content.Messaging.OnUsageIconEnter(frame)
  -- Hide normal icon and show highlight texture
  if usageIconTexture then
    usageIconTexture:Hide()
  end
  if usageIconHighlight then
    usageIconHighlight:Show()
  end

  local goldColor = AutoLFM.Core.Utils.GetColor("GOLD")
  local whiteColor = AutoLFM.Core.Utils.GetColor("WHITE")

  local function colorText(text, colorName)
    return AutoLFM.Core.Utils.ColorText(text, colorName)
  end

  GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT", 0, 0)
  GameTooltip:ClearLines()
  GameTooltip:AddLine("Custom message variables:", goldColor.r, goldColor.g, goldColor.b)
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine(colorText("{ROL}", "CYAN") .. " - Required roles", whiteColor.r, whiteColor.g, whiteColor.b)
  GameTooltip:AddLine(colorText("{CUR}", "CYAN") .. " - Current group size", whiteColor.r, whiteColor.g, whiteColor.b)
  GameTooltip:AddLine(colorText("{TAR}", "CYAN") .. " - Target group size", whiteColor.r, whiteColor.g, whiteColor.b)
  GameTooltip:AddLine(colorText("{MIS}", "CYAN") .. " - Missing players", whiteColor.r, whiteColor.g, whiteColor.b)
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine("LF" .. colorText("{MIS}", "CYAN") .. "M Onyxia - " .. colorText("{ROL}", "CYAN") .. " - " .. colorText("{CUR}", "CYAN") .. "/" .. colorText("{TAR}", "CYAN") .. " - Head reserved", goldColor.r, goldColor.g, goldColor.b)
  GameTooltip:AddLine("LF5M Onyxia - Need Tank & DPS - 10/15 - Head reserved", whiteColor.r, whiteColor.g, whiteColor.b)
  GameTooltip:Show()
end

--- Handles usage icon mouse leave - hides tooltip
--- @param frame frame - The usage icon frame
function AutoLFM.UI.Content.Messaging.OnUsageIconLeave(frame)
  -- Show normal icon and hide highlight texture
  if usageIconTexture then
    usageIconTexture:Show()
  end
  if usageIconHighlight then
    usageIconHighlight:Hide()
  end

  GameTooltip:Hide()
end

--=============================================================================
-- CHANNEL CHECKBOX HANDLERS
--=============================================================================

--- Handles channel checkbox clicks - dispatches Maestro command
--- @param channelName string - The name of the channel
function AutoLFM.UI.Content.Messaging.OnChannelCheckboxClick(channelName)
  if AutoLFM.Core and AutoLFM.Core.Maestro then
    AutoLFM.Core.Maestro.Dispatch("Channels.ToggleChannel", channelName)
  end
end

--- Helper: Check if channel is selected (reads from Maestro State)
--- @param channelName string - The name of the channel to check
--- @return boolean - True if channel is in active channels list
local function isChannelSelected(channelName)
  local activeChannels = AutoLFM.Core.Maestro.GetState("Channels.ActiveChannels") or {}
  for _, name in ipairs(activeChannels) do
    if name == channelName then
      return true
    end
  end
  return false
end

--- Refreshes channel checkboxes to match current selection state
function AutoLFM.UI.Content.Messaging.RefreshChannelCheckboxes()
  -- Get channel checkboxes
  local WorldCheckbox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_World")
  local LookingForGroupCheckbox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_LookingForGroup")
  local hardcoreCheckbox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore")

  -- Sync checkbox states with Maestro State
  if WorldCheckbox then
    WorldCheckbox:SetChecked(isChannelSelected("World"))
  end
  if LookingForGroupCheckbox then
    LookingForGroupCheckbox:SetChecked(isChannelSelected("LookingForGroup"))
  end
  if hardcoreCheckbox then
    hardcoreCheckbox:SetChecked(isChannelSelected("Hardcore"))
  end
end

--=============================================================================
-- PUBLIC API
--=============================================================================

-----------------------------------------------------------------------------
-- Get Custom Message EditBox (for link integration)
-----------------------------------------------------------------------------
--- Returns the custom message editbox for external link integration
--- @return frame - The custom message editbox frame
function AutoLFM.UI.Content.Messaging.GetCustomMessageEditBox()
  return customMessageEditBox
end

--- Returns the current broadcast mode (details or custom)
--- @return string - "custom" or "details"
function AutoLFM.UI.Content.Messaging.GetCurrentMode()
  local mode = getCurrentMode()
  -- Convert internal constants to public strings
  if mode == MODE_CUSTOM then
    return "custom"
  else
    return "details"
  end
end

--=============================================================================
-- STATISTICS UPDATE
--=============================================================================

--- Updates the broadcast statistics display
--- Called every second while broadcaster is running
function AutoLFM.UI.Content.Messaging.UpdateStats()
  -- Get stats from broadcaster
  local isRunning = AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning") or false
  local messagesSent = AutoLFM.Core.Maestro.GetState("Broadcaster.MessagesSent") or 0
  local sessionStartTime = AutoLFM.Core.Maestro.GetState("Broadcaster.SessionStartTime") or 0
  local timeRemaining = AutoLFM.Core.Maestro.GetState("Broadcaster.TimeRemaining") or 0

  -- Get UI elements
  local durationValue = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_World_DurationValue")
  local sentValue = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_LookingForGroup_SentValue")
  local nextValue = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore_NextValue")

  -- Update Duration (session time)
  if durationValue then
    if isRunning and sessionStartTime > 0 then
      local currentTime = GetTime()
      local duration = math.floor(currentTime - sessionStartTime)
      local minutes = math.floor(duration / 60)
      local seconds = math.mod(duration, 60)

      if minutes > 0 then
        durationValue:SetText(string.format("%dm %ds", minutes, seconds))
      else
        durationValue:SetText(string.format("%ds", seconds))
      end
    else
      durationValue:SetText("0s")
    end
  end

  -- Update Messages Sent
  if sentValue then
    if isRunning then
      sentValue:SetText(tostring(messagesSent))
    else
      sentValue:SetText("0")
    end
  end

  -- Update Next Broadcast (time remaining)
  if nextValue then
    if isRunning then
      local seconds = math.floor(timeRemaining)
      if seconds > 0 then
        nextValue:SetText(string.format("%ds", seconds))
      else
        nextValue:SetText("Now")
      end
    else
      nextValue:SetText("0s")
    end
  end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

-- Timer for updating stats every second
local statsUpdateTimer = nil

--- Starts the stats update timer
local function startStatsUpdateTimer()
  if statsUpdateTimer then
    return -- Already running
  end

  statsUpdateTimer = CreateFrame("Frame", "AutoLFM_UI_Messaging_StatsTimer")
  statsUpdateTimer:SetScript("OnUpdate", function()
    if not this.lastUpdate or GetTime() - this.lastUpdate >= 1 then
      this.lastUpdate = GetTime()
      AutoLFM.UI.Content.Messaging.UpdateStats()
    end
  end)
end

--- Stops the stats update timer
local function stopStatsUpdateTimer()
  if statsUpdateTimer then
    statsUpdateTimer:SetScript("OnUpdate", nil)
    statsUpdateTimer = nil
  end
end

AutoLFM.Core.SafeRegisterInit("UI.Messaging", function()
  --- Listens to Channels.Changed to refresh checkbox states
  AutoLFM.Core.Maestro.Listen(
    "UI.Messaging.OnChannelsChanged",
    "Channels.Changed",
    function()
      AutoLFM.UI.Content.Messaging.RefreshChannelCheckboxes()
    end,
    { id = "L09" }
  )

  --- Listens to Selection.Changed to refresh editbox content and group size
  AutoLFM.Core.Maestro.Listen(
    "UI.Messaging.OnSelectionChanged",
    "Selection.Changed",
    function()
      if not customMessageEditBox then return end
      local currentMode = getCurrentMode()
      local text = ""
      if currentMode == MODE_CUSTOM then
        text = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage") or ""
      else
        text = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""
      end
      isRestoringFromState = true
      customMessageEditBox:SetText(text)
      isRestoringFromState = false
      
      -- Update group size slider and editbox (only if changed)
      local groupSize = AutoLFM.Core.Maestro.GetState("Selection.CustomGroupSize") or 5
      if groupSizeSlider and groupSizeSlider:GetValue() ~= groupSize then
        groupSizeSlider:SetValue(groupSize)
      end
      if groupSizeControlEditBox and groupSizeControlEditBox:GetText() ~= tostring(groupSize) then
        groupSizeControlEditBox:SetText(tostring(groupSize))
      end
    end,
    { id = "L10" }
  )

  --- Listens to Broadcaster state changes to update UI
  AutoLFM.Core.Maestro.SubscribeState("Broadcaster.IsRunning", function(newValue, oldValue)
    if newValue then
      startStatsUpdateTimer()
    else
      stopStatsUpdateTimer()
      -- Update stats one last time when stopping
      AutoLFM.UI.Content.Messaging.UpdateStats()
    end
  end)

  -- Start stats timer immediately if broadcaster is already running
  if AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning") then
    startStatsUpdateTimer()
  end

  -- Initial stats update
  AutoLFM.UI.Content.Messaging.UpdateStats()
  
  -- Hook ChatEdit_InsertLink to support shift-click links in editbox
  if ChatEdit_InsertLink then
    local originalInsertLink = ChatEdit_InsertLink
    ChatEdit_InsertLink = function(text)
      if customMessageEditBox and customMessageEditBox:IsVisible() and customMessageEditBox:HasFocus() then
        customMessageEditBox:Insert(text)
        return true
      end
      return originalInsertLink(text)
    end
  end
  
  -- Protect against missing ChatFrame dropdown function
  if not ChatFrame_Dropdown_Show then
    ChatFrame_Dropdown_Show = function() end
  end
end, {
  id = "I25",
  dependencies = { "Logic.Content.Messaging", "Logic.Broadcaster" }  -- Wait for Broadcaster to be initialized
})
