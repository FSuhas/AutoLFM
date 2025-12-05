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
local MODE_DETAILS = "details"
local MODE_CUSTOM = "custom"
local PLACEHOLDER_DETAILS = "Shift+Click to add links or items"
local PLACEHOLDER_CUSTOM = "See icon tooltip for variables usage"
local LABEL_DETAILS = "Add details after generated message:"
local LABEL_CUSTOM = "Create custom message:"

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local uiFrame
local customMessageEditBox
local customMessagePlaceholder
local customMessageContainer
local detailsRadio
local customRadio
local customMessageLabel
local usageIcon
local usageIconTexture
local usageIconHighlight
local varRButton
local varCButton
local varTButton
local varMButton
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

--- Updates editbox placeholder visibility based on text content and mode
local function updatePlaceholder()
  if not customMessageEditBox then return end

  local isTextEmpty = customMessageEditBox:GetText() == ""
  local currentMode = getCurrentMode()
  local isCustomMode = (currentMode == MODE_CUSTOM)

  -- Get placeholder elements
  local detailsPlaceholder = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_EditBoxContainer_Placeholder")
  local customPlaceholder = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_EditBoxContainer_PlaceholderCustom")

  -- Show/hide Details placeholder
  if detailsPlaceholder then
    if isTextEmpty and not isCustomMode then
      detailsPlaceholder:Show()
    else
      detailsPlaceholder:Hide()
    end
  end

  -- Show/hide Custom placeholder
  if customPlaceholder then
    if isTextEmpty and isCustomMode then
      -- Display placeholder with red icon symbol for custom mode
      customPlaceholder:SetText("See [|cffff0000?|r] tooltip for variables usage")
      customPlaceholder:Show()
    else
      customPlaceholder:Hide()
    end
  end
end

--- Caches references to all Messaging panel UI elements for quick access
--- Retrieves and stores references to sliders, icons, radios, editboxes, and labels
local function initializeUIReferences()
  usageIcon = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_UsageIcon")
  usageIconTexture = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_UsageIcon_Texture")
  usageIconHighlight = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_UsageIcon_Highlight")
  varRButton = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_VarRButton")
  varCButton = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_VarCButton")
  varTButton = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_VarTButton")
  varMButton = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_VarMButton")
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
    groupSizeControl:SetPoint("TOPLEFT", customMessageContainer, "BOTTOMLEFT", 0, -3)
  end
end


--- Updates ScrollChild height based on content
local function updateScrollChildHeight()
  local scrollChild = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild")
  if not scrollChild then return end

  -- Fixed height: ChannelsIcon at y=-150, 4 checkboxes (~84px) + padding
  -- Total: 150 + 84 + 15 = 249
  local totalHeight = 249

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

  -- Stats labels in white
  applyWhiteColor("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_General_IntervalLabel")
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

-- Constants for editbox heights
local EDITBOX_HEIGHT_DETAILS = 83
local EDITBOX_HEIGHT_CUSTOM = 63

--- Resizes the editbox container based on broadcast mode
--- In Custom mode: smaller to leave room for GroupSize control
--- @param isCustomMode boolean - True for Custom mode, false for Details mode
local function resizeEditBoxContainer(isCustomMode)
  if not customMessageContainer then return end

  local newHeight = isCustomMode and EDITBOX_HEIGHT_CUSTOM or EDITBOX_HEIGHT_DETAILS
  customMessageContainer:SetHeight(newHeight)

  -- Also resize the inner editbox
  if customMessageEditBox then
    customMessageEditBox:SetHeight(newHeight)
  end
end

--- Positions the channels icon at a fixed location
--- Always at the same Y position regardless of mode
--- Calculation: EditBox(y=-58, h=63) + gap(3) + GroupSize(h=20) + gap(6) = y=-150
local function positionChannelsIcon()
  local channelsIcon = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_ChannelsIcon")
  if not channelsIcon then return end

  channelsIcon:ClearAllPoints()
  -- Fixed position: below the GroupSizeControl area
  local scrollChild = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild")
  if scrollChild then
    channelsIcon:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -150)
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

  -- Update placeholder text based on mode
  if customMessagePlaceholder and not isCustomMode then
    customMessagePlaceholder:SetText(PLACEHOLDER_DETAILS)
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
  setFrameVisibility(varRButton, isCustomMode)
  setFrameVisibility(varCButton, isCustomMode)
  setFrameVisibility(varTButton, isCustomMode)
  setFrameVisibility(varMButton, isCustomMode)
  setFrameVisibility(groupSizeControl, isCustomMode)

  -- Resize editbox based on mode (smaller in custom to leave room for GroupSize)
  resizeEditBoxContainer(isCustomMode)

  -- Update scroll after visibility changes
  updateScrollChildHeight()
end


--- Updates Hardcore checkbox state and label color based on player's hardcore status
--- If player is hardcore: enables checkbox and shows white label
--- If player is not hardcore: disables checkbox, unchecks it, and shows gray label
local function updateHardcoreCheckboxState()
  local hardcoreCheckbox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore")
  local hardcoreLabel = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore_Label")

  if not hardcoreCheckbox then return end

  local isHardcore = false
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.GetIsHardcore then
    isHardcore = AutoLFM.Core.Storage.GetIsHardcore()
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
  setupGroupSizeControls()
  setRadioButtonStates(MODE_DETAILS)
  if customMessageLabel then
    customMessageLabel:SetText(LABEL_DETAILS)
  end

  -- Apply gold border to main editbox container
  if customMessageContainer then
    customMessageContainer:SetBackdropBorderColor(1, 0.82, 0, 0.8)
  end

  -- Initial positioning of channels icon (Details mode)
  positionChannelsIcon()

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
    if AutoLFM.Core.Storage and AutoLFM.Core.Storage.GetCustomInput then
      local isCustom = AutoLFM.Core.Storage.GetCustomInput()
      sessionMode = isCustom and MODE_CUSTOM or MODE_DETAILS
    end
  end

  -- Use session mode (persists manual toggles between tab openings)
  setRadioButtonStates(sessionMode)
  AutoLFM.UI.Content.Messaging.UpdateModeDisplay(false)  -- Don't clear on tab display
  updateHardcoreCheckboxState()

  -- Sync channel checkboxes with saved state
  AutoLFM.UI.Content.Messaging.RefreshChannelCheckboxes()
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
    text = editBox:GetText()
  end

  -- Update placeholder visibility
  customMessageEditBox = editBox
  updatePlaceholder()

  -- Skip dispatch if we're restoring from State
  if isRestoringFromState then return end

  -- Dispatch text to state
  if not text then text = "" end
  local currentMode = getCurrentMode()
  if currentMode == MODE_CUSTOM then
    AutoLFM.Core.Maestro.Dispatch("Selection.SetCustomMessage", text)
  else
    AutoLFM.Core.Maestro.Dispatch("Selection.SetDetailsText", text)
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
  -- Channels icon is at fixed position, no need to reposition
  updatePlaceholder()  -- Update placeholder visibility when mode changes
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
  -- Show highlight texture over the icon
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
  -- Hide highlight texture (keep icon visible)
  if usageIconHighlight then
    usageIconHighlight:Hide()
  end

  GameTooltip:Hide()
end

--- Handles variable button mouse enter - shows highlight
--- @param frame frame - The variable button frame
function AutoLFM.UI.Content.Messaging.OnVarButtonEnter(frame)
  local highlight = getUIElement(frame:GetName() .. "_Highlight")
  if highlight then
    highlight:Show()
  end

  -- Show tooltip with variable description
  local buttonName = frame:GetName()
  local variable = ""
  local description = ""

  if string.find(buttonName, "VarRButton", 1, true) then
    variable = "{ROL}"
    description = "Required roles"
  elseif string.find(buttonName, "VarCButton", 1, true) then
    variable = "{CUR}"
    description = "Current group size"
  elseif string.find(buttonName, "VarTButton", 1, true) then
    variable = "{TAR}"
    description = "Target group size"
  elseif string.find(buttonName, "VarMButton", 1, true) then
    variable = "{MIS}"
    description = "Missing players"
  end

  if variable ~= "" then
    local goldColor = AutoLFM.Core.Utils.GetColor("GOLD")
    local cyanColor = AutoLFM.Core.Utils.GetColor("CYAN")
    local whiteColor = AutoLFM.Core.Utils.GetColor("WHITE")

    local function colorText(text, colorName)
      return AutoLFM.Core.Utils.ColorText(text, colorName)
    end

    GameTooltip:SetOwner(frame, "ANCHOR_TOPRIGHT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:AddLine(colorText("Insert", "GOLD") .. " " .. colorText(variable, "CYAN") .. " " .. colorText("-", "WHITE") .. " " .. description, whiteColor.r, whiteColor.g, whiteColor.b)
    GameTooltip:Show()
  end
end

--- Handles variable button mouse leave - hides highlight and tooltip
--- @param frame frame - The variable button frame
function AutoLFM.UI.Content.Messaging.OnVarButtonLeave(frame)
  local highlight = getUIElement(frame:GetName() .. "_Highlight")
  if highlight then
    highlight:Hide()
  end

  -- Hide tooltip
  GameTooltip:Hide()
end

--- Handles variable button clicks - inserts variable into editbox
--- Maps button name to corresponding variable
--- @param frame frame - The variable button frame
function AutoLFM.UI.Content.Messaging.OnVarButtonClick(frame)
  -- Ensure customMessageEditBox is initialized
  if not customMessageEditBox then
    customMessageEditBox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_EditBoxContainer_EditBox")
  end
  
  if not customMessageEditBox then return end
  
  -- Map button name to variable
  local buttonName = frame:GetName()
  local variable = ""
  
  if string.find(buttonName, "VarRButton", 1, true) then
    variable = "{ROL}"
  elseif string.find(buttonName, "VarCButton", 1, true) then
    variable = "{CUR}"
  elseif string.find(buttonName, "VarTButton", 1, true) then
    variable = "{TAR}"
  elseif string.find(buttonName, "VarMButton", 1, true) then
    variable = "{MIS}"
  end
  
  if variable ~= "" then
    -- Get current text and append variable
    local currentText = customMessageEditBox:GetText()
    local newText = currentText .. variable
    customMessageEditBox:SetText(newText)
    customMessageEditBox:SetFocus()
  end
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
  local GeneralCheckbox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_General")
  local WorldCheckbox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_World")
  local LookingForGroupCheckbox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_LookingForGroup")
  local hardcoreCheckbox = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore")

  -- Sync checkbox states with Maestro State
  if GeneralCheckbox then
    GeneralCheckbox:SetChecked(isChannelSelected("General"))
  end
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
  local interval = AutoLFM.Core.Maestro.GetState("Broadcaster.Interval") or 60

  -- Get UI elements
  local intervalValue = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_General_IntervalValue")
  local durationValue = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_World_DurationValue")
  local sentValue = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_LookingForGroup_SentValue")
  local nextValue = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_Hardcore_NextValue")

  -- Update Interval (from settings)
  if intervalValue then
    intervalValue:SetText(tostring(interval) .. "s")
  end

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
    { id = "L07" }
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

  --- Listens to Broadcaster.Interval changes to update Interval stat immediately
  AutoLFM.Core.Maestro.SubscribeState("Broadcaster.Interval", function(newValue, oldValue)
    local intervalValue = getUIElement("AutoLFM_Content_Messaging_ScrollFrame_ScrollChild_General_IntervalValue")
    if intervalValue then
      intervalValue:SetText(tostring(newValue or 60) .. "s")
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
  id = "I15",
  dependencies = { "Logic.Content.Messaging", "Logic.Broadcaster" }  -- Wait for Broadcaster to be initialized
})

