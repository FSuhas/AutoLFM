--=============================================================================
-- AutoLFM: Size Control
--   Reusable slider + editbox component for numeric input (1-40)
--   Used for raid sizes, custom group sizes, etc.
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.SizeControl = {}

--=============================================================================
-- UI CONSTANTS
--=============================================================================
local SLIDER_WIDTH = 80
local SLIDER_HEIGHT = 15
local EDITBOX_WIDTH = 30
local EDITBOX_HEIGHT = 20
local EDITBOX_RIGHT_OFFSET = -5
local SLIDER_RIGHT_OFFSET = -40

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================

--- Creates or retrieves a size slider with mousewheel support
--- @param config table - Configuration: {id, parent, minSize, maxSize, currentSize, color}
--- @return frame - The configured slider frame
local function createSlider(config)
  local sliderName = "AutoLFM_SizeSlider_" .. config.id
  local slider = getglobal(sliderName)

  if not slider then
    slider = CreateFrame("Slider", sliderName, config.parent)
    slider:SetFrameStrata("MEDIUM")
    slider:SetFrameLevel(config.parent:GetFrameLevel() + 3)
    slider:SetWidth(SLIDER_WIDTH)
    slider:SetHeight(SLIDER_HEIGHT)
    slider:SetOrientation("HORIZONTAL")
    slider:SetBackdrop({
      bgFile = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\SliderBackground",
      edgeFile = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\SliderBorder",
      tile = true,
      tileSize = 8,
      edgeSize = 8,
      insets = { left = 3, right = 3, top = 6, bottom = 6 }
    })
    slider:SetThumbTexture("Interface\\AddOns\\AutoLFM\\UI\\Textures\\SliderButton")
    slider:EnableMouseWheel(true)
  end

  slider:SetMinMaxValues(config.minSize, config.maxSize)
  slider:SetValueStep(1)
  slider:SetPoint("RIGHT", config.parent, "RIGHT", SLIDER_RIGHT_OFFSET, 0)

  -- Update OnMouseWheel with current min/max values
  slider:SetScript("OnMouseWheel", function()
    local value = this:GetValue()
    if arg1 > 0 then
      this:SetValue(math.min(value + 1, this.maxSize))
    else
      this:SetValue(math.max(value - 1, this.minSize))
    end
  end)

  -- Store current min/max for OnMouseWheel
  slider.minSize = config.minSize
  slider.maxSize = config.maxSize

  return slider
end

--- Creates or retrieves a size editbox with text selection and validation
--- @param config table - Configuration: {id, parent, currentSize, color}
--- @return frame - The configured editbox frame
local function createEditBox(config)
  local editBoxName = "AutoLFM_SizeEditBox_" .. config.id
  local editBox = getglobal(editBoxName)

  if not editBox then
    editBox = CreateFrame("EditBox", editBoxName, config.parent)
    editBox:SetFrameStrata("MEDIUM")
    editBox:SetFrameLevel(config.parent:GetFrameLevel() + 3)
    editBox:SetWidth(EDITBOX_WIDTH)
    editBox:SetHeight(EDITBOX_HEIGHT)
    editBox:SetMaxLetters(2)
    editBox:SetNumeric(true)
    editBox:SetAutoFocus(false)
    editBox:SetJustifyH("CENTER")
    editBox:SetFontObject(GameFontNormal)
    editBox:SetTextInsets(2, 2, 2, 2)
    editBox:SetBackdrop({
      edgeFile = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\TooltipBorder",
      tile = false,
      edgeSize = 12,
      insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    editBox:EnableMouse(true)

    -- Select all text on click
    editBox:SetScript("OnMouseDown", function()
      this:HighlightText()
    end)
    editBox:SetScript("OnEditFocusGained", function()
      this:HighlightText()
    end)
  end

  editBox:SetText(tostring(config.currentSize))
  editBox:SetPoint("RIGHT", config.parent, "RIGHT", EDITBOX_RIGHT_OFFSET, 0)

  -- Apply color if provided
  if config.color then
    editBox:SetBackdropBorderColor(config.color.r, config.color.g, config.color.b, 1)
  end

  return editBox
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Creates a complete size control (slider + editbox) with synchronized values
--- @param config table - Configuration object
---   Required: {id, parent, minSize, maxSize, currentSize, onValueChanged}
---   Optional: {color, hoverElements}
--- @return table - Control object {slider, editBox, SetValue, GetValue, Show, Hide}
function AutoLFM.UI.SizeControl.Create(config)
  -- Validate required parameters
  if not config.id or not config.parent or not config.minSize or not config.maxSize or not config.currentSize then
    AutoLFM.Core.Utils.LogError("SizeControl.Create: missing required parameters")
    return nil
  end

  -- Create slider and editbox
  local slider = createSlider(config)
  local editBox = createEditBox(config)

  -- Store configuration
  slider.controlId = config.id
  editBox.controlId = config.id
  editBox.minSize = config.minSize
  editBox.maxSize = config.maxSize

  -- Setup synchronized callbacks (only if not already configured)
  if not slider.scriptsConfigured then
    local isUpdatingFromSlider = false

    slider:SetScript("OnValueChanged", function()
      if this.isInitializing or isUpdatingFromSlider then return end

      local value = math.floor(this:GetValue())

      -- Call user callback (silent mode during drag)
      if config.onValueChanged then
        config.onValueChanged(value, true)
      end

      isUpdatingFromSlider = true
      local eb = getglobal("AutoLFM_SizeEditBox_" .. this.controlId)
      if eb then
        eb:SetText(tostring(value))
      end
      isUpdatingFromSlider = false
    end)

    slider:SetScript("OnMouseUp", function()
      local value = math.floor(this:GetValue())

      -- Call user callback (final update)
      if config.onValueChanged then
        config.onValueChanged(value, false)
      end

      local eb = getglobal("AutoLFM_SizeEditBox_" .. this.controlId)
      if eb then
        eb:SetFocus()
        eb:HighlightText()
      end
    end)

    slider.scriptsConfigured = true
  end

  -- Setup editbox callbacks (only if not already configured)
  if not editBox.scriptsConfigured then
    local isUpdatingFromEditBox = false

    local function CommitEditBoxValue(eb)
      local text = eb:GetText()
      if text == "" then
        eb:SetText(tostring(eb.minSize))
        return
      end

      local value = tonumber(text)
      if value then
        if value < eb.minSize then
          value = eb.minSize
        elseif value > eb.maxSize then
          value = eb.maxSize
        end

        isUpdatingFromEditBox = true

        -- Call user callback
        if config.onValueChanged then
          config.onValueChanged(value, false)
        end

        local sl = getglobal("AutoLFM_SizeSlider_" .. eb.controlId)
        if sl then
          sl.isInitializing = true
          sl:SetValue(value)
          sl.isInitializing = false
        end
        eb:SetText(tostring(value))
        isUpdatingFromEditBox = false
      end
    end

    editBox:SetScript("OnEditFocusGained", function()
      this:HighlightText()
    end)

    editBox:SetScript("OnEditFocusLost", function()
      if not isUpdatingFromEditBox then
        CommitEditBoxValue(this)
      end
    end)

    editBox:SetScript("OnMouseDown", function()
      this:SetFocus()
      this:HighlightText()
    end)

    editBox:SetScript("OnEnterPressed", function()
      CommitEditBoxValue(this)
      this:ClearFocus()
    end)

    editBox.scriptsConfigured = true
  end

  -- Set initial value
  slider.isInitializing = true
  slider:SetValue(config.currentSize)
  slider.isInitializing = false

  -- Setup hover effects if provided
  if config.hoverElements and AutoLFM.UI.RowList and AutoLFM.UI.RowList.SetupHover then
    local sliderElements = {}
    for i = 1, table.getn(config.hoverElements) do
      table.insert(sliderElements, config.hoverElements[i])
    end
    table.insert(sliderElements, editBox)
    AutoLFM.UI.RowList.SetupHover(slider, config.parent, config.color and config.color.name or nil, sliderElements)

    local editBoxElements = {}
    for i = 1, table.getn(config.hoverElements) do
      table.insert(editBoxElements, config.hoverElements[i])
    end
    table.insert(editBoxElements, editBox)
    AutoLFM.UI.RowList.SetupHover(editBox, config.parent, config.color and config.color.name or nil, editBoxElements)
  end

  -- Return control object with public methods
  return {
    slider = slider,
    editBox = editBox,

    --- Sets the value of the control
    --- @param value number - New value to set
    SetValue = function(value)
      slider.isInitializing = true
      slider:SetValue(value)
      slider.isInitializing = false
      editBox:SetText(tostring(value))
    end,

    --- Gets the current value of the control
    --- @return number - Current value
    GetValue = function()
      return math.floor(slider:GetValue())
    end,

    --- Shows the control
    Show = function()
      slider:Show()
      editBox:Show()
    end,

    --- Hides the control
    Hide = function()
      slider:Hide()
      editBox:Hide()
    end
  }
end
