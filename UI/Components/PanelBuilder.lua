--=============================================================================
-- AutoLFM: Panel Builder
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.PanelBuilder then AutoLFM.UI.PanelBuilder = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.UI.PanelBuilder.LAYOUT = {
  panelTop = -157,
  panelLeft = 25,
  panelWidth = 323,
  panelHeight = 253,
  contentTop = 0,
  contentLeft = 0,
  contentWidth = 295,
  contentHeight = 253,
  bottomZoneY = -27,
  bottomZoneX = -10,
  bottomZoneWidth = 300,
  bottomZoneHeight = 30
}

AutoLFM.UI.PanelBuilder.CONSTANTS = {
  ROW_HEIGHT = 20,
  CHECKBOX_SIZE = 20,
  ICON_SIZE = 16,
  EDITBOX_HEIGHT = 28,
  EDITBOX_WIDTH = 285,
  PANEL_CONTENT_WIDTH = 295,
  PANEL_CONTENT_HEIGHT = 253,
  BUTTON_HEIGHT = 20,
  BUTTON_WIDTH_SMALL = 60,
  BUTTON_WIDTH_MEDIUM = 80,
  BUTTON_WIDTH_LARGE = 110,
  SPACING_SMALL = 5,
  SPACING_MEDIUM = 10,
  SPACING_LARGE = 20
}

-----------------------------------------------------------------------------
-- Panel Structure Creation
-----------------------------------------------------------------------------
function AutoLFM.UI.PanelBuilder.GetConfig()
  return AutoLFM.UI.PanelBuilder.LAYOUT
end

function AutoLFM.UI.PanelBuilder.CreatePanel(parentFrame, panelName)
  if not parentFrame then return nil end
  
  local panelData = {}
  local layout = AutoLFM.UI.PanelBuilder.LAYOUT
  
  panelData.panel = CreateFrame("Frame", panelName, parentFrame)
  panelData.panel:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", layout.panelLeft, layout.panelTop)
  panelData.panel:SetWidth(layout.panelWidth)
  panelData.panel:SetHeight(layout.panelHeight)
  panelData.panel:SetFrameStrata("HIGH")
  panelData.panel:Hide()
  
  panelData.bottomZone = CreateFrame("Frame", nil, panelData.panel)
  panelData.bottomZone:SetPoint("BOTTOM", panelData.panel, "BOTTOM", layout.bottomZoneX, layout.bottomZoneY)
  panelData.bottomZone:SetWidth(layout.bottomZoneWidth)
  panelData.bottomZone:SetHeight(layout.bottomZoneHeight)
  
  return panelData
end

function AutoLFM.UI.PanelBuilder.AddScrollFrame(panelData, scrollName)
  if not panelData or not panelData.panel then return nil end
  
  local layout = AutoLFM.UI.PanelBuilder.LAYOUT
  local scrollFrame = CreateFrame("ScrollFrame", scrollName, panelData.panel, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", panelData.panel, "TOPLEFT", layout.contentLeft, layout.contentTop)
  scrollFrame:SetWidth(layout.contentWidth)
  scrollFrame:SetHeight(layout.contentHeight)
  scrollFrame:EnableMouse(true)
  scrollFrame:EnableMouseWheel(true)
  
  local contentFrame = CreateFrame("Frame", nil, scrollFrame)
  contentFrame:SetWidth(scrollFrame:GetWidth() - 20)
  contentFrame:SetHeight(1)
  scrollFrame:SetScrollChild(contentFrame)
  
  panelData.scrollFrame = scrollFrame
  panelData.contentFrame = contentFrame
  
  return panelData
end

function AutoLFM.UI.PanelBuilder.CreateLabel(panelData, text)
  if not panelData or not panelData.bottomZone then return nil, nil end
  
  local labelButton = CreateFrame("Button", nil, panelData.bottomZone)
  labelButton:SetWidth(150)
  labelButton:SetHeight(20)
  labelButton:SetPoint("LEFT", panelData.bottomZone, "LEFT", 0, 0)
  
  local labelText = labelButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  labelText:SetPoint("LEFT", labelButton, "LEFT", 0, 0)
  labelText:SetText(text)
  AutoLFM.Core.Utils.SetFontColor(labelText, "white")
  
  return labelButton, labelText
end

function AutoLFM.UI.PanelBuilder.CreateClickableLabel(panelData, text, onClickFunc, onEnterFunc, onLeaveFunc)
  if not panelData or not panelData.bottomZone then return nil, nil end
  
  local labelButton = CreateFrame("Button", nil, panelData.bottomZone)
  labelButton:SetWidth(150)
  labelButton:SetHeight(20)
  labelButton:SetPoint("LEFT", panelData.bottomZone, "LEFT", 0, 0)
  
  local labelText = labelButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  labelText:SetPoint("LEFT", labelButton, "LEFT", 0, 0)
  labelText:SetText(text)
  AutoLFM.Core.Utils.SetFontColor(labelText, "white")
  if onClickFunc then
    labelButton:SetScript("OnClick", function()
      onClickFunc(labelButton, labelText)
    end)
  end
  
  if onEnterFunc then
    labelButton:SetScript("OnEnter", function()
      onEnterFunc(labelButton, labelText)
    end)
  end
  
  if onLeaveFunc then
    labelButton:SetScript("OnLeave", function()
      onLeaveFunc(labelButton, labelText)
    end)
  end
  
  return labelButton, labelText
end

-----------------------------------------------------------------------------
-- Panel Visibility
-----------------------------------------------------------------------------
function AutoLFM.UI.PanelBuilder.ShowPanel(panelFrame, scrollFrame)
  if panelFrame then
    panelFrame:Show()
  end
  
  if scrollFrame then
    scrollFrame:Show()
    scrollFrame:SetVerticalScroll(0)
    
    if scrollFrame.UpdateScrollChildRect then
      scrollFrame:UpdateScrollChildRect()
    end
  end
end

function AutoLFM.UI.PanelBuilder.HidePanel(panelFrame, scrollFrame)
  if panelFrame then
    panelFrame:Hide()
  end
  
  if scrollFrame then
    scrollFrame:Hide()
  end
end

function AutoLFM.UI.PanelBuilder.UpdateScrollHeight(contentFrame, visibleCount, rowHeight)
  if not contentFrame then return end
  
  rowHeight = rowHeight or AutoLFM.UI.PanelBuilder.CONSTANTS.ROW_HEIGHT
  local contentHeight = visibleCount * rowHeight
  contentFrame:SetHeight(math.max(contentHeight, 1))
end

function AutoLFM.UI.PanelBuilder.RefreshScroll(scrollFrame)
  if scrollFrame and scrollFrame.UpdateScrollChildRect then
    scrollFrame:UpdateScrollChildRect()
  end
end

-----------------------------------------------------------------------------
-- Row Interactions
-----------------------------------------------------------------------------
function AutoLFM.UI.PanelBuilder.SetupRowHover(frame, checkbox, label, rightLabel, color)
  if not frame or not checkbox or not label or not color then return end
  
  local originalR = color.r or 1
  local originalG = color.g or 1
  local originalB = color.b or 1
  
  frame:SetScript("OnEnter", function()
    frame:SetBackdrop({
      bgFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "white",
      insets = {left = 1, right = 1, top = 1, bottom = 1}
    })
    frame:SetBackdropColor(originalR, originalG, originalB, 0.3)
    label:SetTextColor(1, 1, 1)
    if rightLabel then
      rightLabel:SetTextColor(1, 1, 1)
    end
    checkbox:LockHighlight()
  end)
  
  frame:SetScript("OnLeave", function()
    frame:SetBackdrop(nil)
    label:SetTextColor(originalR, originalG, originalB)
    if rightLabel then
      rightLabel:SetTextColor(originalR, originalG, originalB)
    end
    checkbox:UnlockHighlight()
  end)
end

function AutoLFM.UI.PanelBuilder.SetupClickToToggle(frame, checkbox, onToggleFunc)
  if not frame or not checkbox then return end
  
  frame:SetScript("OnClick", function()
    local success, err = pcall(function()
      checkbox:SetChecked(not checkbox:GetChecked())
      if onToggleFunc then
        onToggleFunc(checkbox:GetChecked())
      end
    end)
    
    if not success then
      AutoLFM.Core.Utils.PrintError("Click error: " .. tostring(err))
    end
  end)
end

function AutoLFM.UI.PanelBuilder.SetupCheckboxClick(checkbox, onToggleFunc)
  if not checkbox or not onToggleFunc then return end
  
  checkbox:SetScript("OnClick", function()
    local success, err = pcall(function()
      onToggleFunc(checkbox:GetChecked())
    end)
    
    if not success then
      AutoLFM.Core.Utils.PrintError("Checkbox error: " .. tostring(err))
    end
  end)
end

-----------------------------------------------------------------------------
-- Selectable Row Creation (Generic)
-----------------------------------------------------------------------------
function AutoLFM.UI.PanelBuilder.CreateSelectableRow(config)
  if not config or not config.parent then return nil end
  
  local clickableFrame = CreateFrame("Button", config.frameName, config.parent)
  clickableFrame:SetHeight(config.rowHeight or AutoLFM.UI.PanelBuilder.CONSTANTS.ROW_HEIGHT)
  clickableFrame:SetWidth(config.rowWidth or 300)
  clickableFrame:SetPoint("TOPLEFT", config.parent, "TOPLEFT", 0, -(config.yOffset or 0))
  
  local checkbox = CreateFrame("CheckButton", config.checkboxName, clickableFrame, "UICheckButtonTemplate")
  checkbox:SetWidth(config.checkboxSize or AutoLFM.UI.PanelBuilder.CONSTANTS.CHECKBOX_SIZE)
  checkbox:SetHeight(config.checkboxSize or AutoLFM.UI.PanelBuilder.CONSTANTS.CHECKBOX_SIZE)
  checkbox:SetPoint("LEFT", clickableFrame, "LEFT", 0, 0)
  
  if config.isChecked ~= nil then
    checkbox:SetChecked(config.isChecked)
  end
  
  local rightLabel = nil
  if config.rightText then
    rightLabel = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rightLabel:SetPoint("RIGHT", clickableFrame, "RIGHT", -10, 0)
    rightLabel:SetText(config.rightText)
  end
  
  local label = clickableFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  label:SetPoint("LEFT", checkbox, "RIGHT", 2, 0)
  label:SetText(config.mainText or "")
  
  if config.color then
    local r = config.color.r or 1
    local g = config.color.g or 1
    local b = config.color.b or 1
    label:SetTextColor(r, g, b)
    if rightLabel then
      rightLabel:SetTextColor(r, g, b)
    end
  end
  
  if config.customProperties then
    for key, value in pairs(config.customProperties) do
      clickableFrame[key] = value
    end
  end
  
  if config.customTooltip then
    clickableFrame:SetScript("OnEnter", function()
      local r = clickableFrame.originalR or (config.color and config.color.r) or 1
      local g = clickableFrame.originalG or (config.color and config.color.g) or 1
      local b = clickableFrame.originalB or (config.color and config.color.b) or 1
      
      clickableFrame:SetBackdrop({
        bgFile = AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "white",
        insets = {left = 1, right = 1, top = 1, bottom = 1},
      })
      clickableFrame:SetBackdropColor(r, g, b, 0.3)
      label:SetTextColor(1, 1, 1)
      if rightLabel then
        rightLabel:SetTextColor(1, 1, 1)
      end
      checkbox:LockHighlight()
      
      pcall(function()
        config.customTooltip(clickableFrame)
      end)
    end)
    
    clickableFrame:SetScript("OnLeave", function()
      clickableFrame:SetBackdrop(nil)
      
      local r = clickableFrame.originalR or (config.color and config.color.r) or 1
      local g = clickableFrame.originalG or (config.color and config.color.g) or 1
      local b = clickableFrame.originalB or (config.color and config.color.b) or 1
      
      label:SetTextColor(r, g, b)
      if rightLabel then
        rightLabel:SetTextColor(r, g, b)
      end
      
      checkbox:UnlockHighlight()
      AutoLFM.UI.PanelBuilder.HideTooltip()
    end)
  elseif config.color and not config.overrideHover then
    AutoLFM.UI.PanelBuilder.SetupRowHover(
      clickableFrame,
      checkbox,
      label,
      rightLabel,
      config.color
    )
  end
  
  if config.onCheckboxClick then
    AutoLFM.UI.PanelBuilder.SetupClickToToggle(
      clickableFrame,
      checkbox,
      function(isChecked)
        config.onCheckboxClick(checkbox, isChecked)
      end
    )
    
    AutoLFM.UI.PanelBuilder.SetupCheckboxClick(
      checkbox,
      function(isChecked)
        config.onCheckboxClick(checkbox, isChecked)
      end
    )
  end
  
  clickableFrame.checkbox = checkbox
  clickableFrame.label = label
  clickableFrame.rightLabel = rightLabel
  
  return clickableFrame
end

-----------------------------------------------------------------------------
-- Checkbox Utilities
-----------------------------------------------------------------------------
function AutoLFM.UI.PanelBuilder.CreateCheckbox(parent, name, onClickCallback)
  if not parent then return nil end
  
  local checkbox = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
  checkbox:SetWidth(20)
  checkbox:SetHeight(20)
  
  if onClickCallback and type(onClickCallback) == "function" then
    checkbox:SetScript("OnClick", onClickCallback)
  end
  
  return checkbox
end

function AutoLFM.UI.PanelBuilder.SetCheckboxColor(checkbox, r, g, b)
  if not checkbox then return end
  
  local normalTexture = checkbox:GetNormalTexture()
  local checkedTexture = checkbox:GetCheckedTexture()
  local disabledCheckedTexture = checkbox:GetDisabledCheckedTexture()
  
  if normalTexture then
    normalTexture:SetVertexColor(r, g, b)
  end
  
  if checkedTexture then
    checkedTexture:SetVertexColor(r, g, b)
  end
  
  if disabledCheckedTexture then
    disabledCheckedTexture:SetVertexColor(r, g, b)
  end
end

function AutoLFM.UI.PanelBuilder.BatchUpdateCheckboxes(checkboxTable, checkStateFunc)
  if not checkboxTable or not checkStateFunc then return end
  
  for key, checkbox in pairs(checkboxTable) do
    if checkbox then
      local isChecked = checkStateFunc(key)
      checkbox:SetChecked(isChecked)
    end
  end
end

function AutoLFM.UI.PanelBuilder.ClearCheckboxes(checkboxTable)
  if not checkboxTable then return end
  
  for _, checkbox in pairs(checkboxTable) do
    if checkbox then
      checkbox:SetChecked(false)
    end
  end
end

function AutoLFM.UI.PanelBuilder.UpdateCheckboxes(checkboxTable, stateCheckFunc)
  if not checkboxTable or not stateCheckFunc then return end
  
  for tag, checkbox in pairs(checkboxTable) do
    if checkbox then
      local isChecked = stateCheckFunc(tag)
      checkbox:SetChecked(isChecked)
    end
  end
end

function AutoLFM.UI.PanelBuilder.ClearBackdrops(frameCollection)
  if not frameCollection then return end
  
  for _, frame in pairs(frameCollection) do
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end

function AutoLFM.UI.PanelBuilder.HideFrames(frameCollection)
  if not frameCollection then return end
  
  for _, frame in pairs(frameCollection) do
    if frame and frame.Hide then
      frame:Hide()
    end
  end
end

-----------------------------------------------------------------------------
-- Label Highlight Utilities
-----------------------------------------------------------------------------
function AutoLFM.UI.PanelBuilder.AttachLabelHighlight(button, label, normalColor, hoverColor)
  if not button or not label then return end
  normalColor = normalColor or "gold"
  hoverColor = hoverColor or "blue"
  button:SetScript("OnEnter", function()
    AutoLFM.Core.Utils.SetFontColor(label, hoverColor)
    button:LockHighlight()
  end)
  button:SetScript("OnLeave", function()
    AutoLFM.Core.Utils.SetFontColor(label, normalColor)
    button:UnlockHighlight()
  end)
end

-----------------------------------------------------------------------------
-- Icon With Label Creation
-----------------------------------------------------------------------------
function AutoLFM.UI.PanelBuilder.CreateIconWithLabel(config)
  if not config or not config.parent then return nil, nil end
  local size = config.size or AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE
  local labelOffset = config.labelOffset or 3
  local icon = config.parent:CreateTexture(nil, "OVERLAY")
  icon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. (config.texture or "Icons\\generic"))
  icon:SetWidth(size)
  icon:SetHeight(size)
  if config.point then
    icon:SetPoint(
      config.point.point or "TOPLEFT",
      config.point.relativeTo or config.parent,
      config.point.relativePoint or "TOPLEFT",
      config.point.x or 0,
      config.point.y or 0
    )
  end
  local labelFontString = nil
  if config.label then
    labelFontString = config.parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelFontString:SetText(config.label)
    labelFontString:SetPoint("LEFT", icon, "RIGHT", labelOffset, 0)
    AutoLFM.Core.Utils.SetFontColor(labelFontString, config.labelColor or "white")
  end
  return icon, labelFontString
end

-----------------------------------------------------------------------------
-- Radio Button Group
-----------------------------------------------------------------------------
function AutoLFM.UI.PanelBuilder.CreateRadioButtonGroup(config)
  if not config or not config.parent or not config.buttons then return nil end

  local group = {
    radioButtons = {},
    labels = {}
  }

  function group.Update(checkedKey)
    for key, button in pairs(group.radioButtons) do
      if button then
        button:SetChecked(key == checkedKey)
      end
    end
  end

  function group.GetChecked()
    for key, button in pairs(group.radioButtons) do
      if button and button:GetChecked() then
        return key
      end
    end
    return nil
  end

  local lastRadio = nil
  for i = 1, table.getn(config.buttons) do
    local btnConfig = config.buttons[i]
    if btnConfig and btnConfig.key and btnConfig.label then
      local radio = CreateFrame("CheckButton", nil, config.parent, "UIRadioButtonTemplate")
      radio:SetWidth(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)
      radio:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.ICON_SIZE)

      if i == 1 and config.anchor then
        radio:SetPoint(config.anchor.point or "TOPLEFT", config.anchor.relativeTo or config.parent, config.anchor.relativePoint or "TOPLEFT", config.anchor.x or 0, config.anchor.y or 0)
      elseif lastRadio then
        local spacing = config.spacing or -4
        radio:SetPoint("TOPLEFT", lastRadio, "BOTTOMLEFT", 0, spacing)
      end

      if btnConfig.checked then
        radio:SetChecked(true)
      end

      local labelButton = CreateFrame("Button", nil, config.parent)
      labelButton:SetPoint("LEFT", radio, "RIGHT", 0, 0)
      labelButton:SetWidth(config.labelWidth or 55)
      labelButton:SetHeight(AutoLFM.UI.PanelBuilder.CONSTANTS.BUTTON_HEIGHT)

      local label = labelButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      label:SetPoint("LEFT", labelButton, "LEFT", 5, 0)
      label:SetText(btnConfig.label)
      AutoLFM.Core.Utils.SetFontColor(label, config.labelColor or "gold")

      local hoverColor = config.hoverColor or "blue"
      AutoLFM.UI.PanelBuilder.AttachLabelHighlight(labelButton, label, config.labelColor or "gold", hoverColor)
      AutoLFM.UI.PanelBuilder.AttachLabelHighlight(radio, label, config.labelColor or "gold", hoverColor)

      labelButton:SetScript("OnClick", function()
        radio:Click()
      end)

      radio:SetScript("OnClick", function()
        if btnConfig.onClick then
          btnConfig.onClick()
        end
        group.Update(btnConfig.key)
        if config.onUpdate then
          config.onUpdate(btnConfig.key)
        end
      end)

      group.radioButtons[btnConfig.key] = radio
      group.labels[btnConfig.key] = label
      lastRadio = radio
    end
  end

  return group
end

-----------------------------------------------------------------------------
-- Tooltip Utilities
-----------------------------------------------------------------------------
function AutoLFM.UI.PanelBuilder.ShowTooltip(frame, text, anchor)
  if not frame or not text then return end
  
  local success, err = pcall(function()
    anchor = anchor or "ANCHOR_RIGHT"
    GameTooltip:SetOwner(frame, anchor)
    GameTooltip:SetText(text, 1, 1, 1)
    GameTooltip:Show()
  end)
  
  if not success then
    GameTooltip:Hide()
  end
end

function AutoLFM.UI.PanelBuilder.HideTooltip()
  pcall(function()
    GameTooltip:Hide()
  end)
end
