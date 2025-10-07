--------------------------------------------------
-- Minimap Button Component
--------------------------------------------------

AutoLFM_MinimapButton = nil

--------------------------------------------------
-- Initialize Minimap Button
--------------------------------------------------
function InitializeMinimapButton()
  if AutoLFM_MinimapButton then return end
  
  -- Load saved settings
  local settings = LoadMinimapSettings()
  if not settings then
    settings = {
      x = DEFAULT_MINIMAP_X,
      y = DEFAULT_MINIMAP_Y,
      hidden = false
    }
  end
  
  -- Create button
  AutoLFM_MinimapButton = CreateFrame("Button", "AutoLFM_MinimapButton", Minimap)
  AutoLFM_MinimapButton:SetFrameStrata("LOW")
  AutoLFM_MinimapButton:SetWidth(30)
  AutoLFM_MinimapButton:SetHeight(30)
  AutoLFM_MinimapButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", settings.x, settings.y)
  
  -- Icon texture
  local icon = AutoLFM_MinimapButton:CreateTexture(nil, "BACKGROUND")
  icon:SetWidth(30)
  icon:SetHeight(30)
  icon:SetTexture(TEXTURE_BASE_PATH .. "Eyes\\eye01")
  icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
  icon:SetPoint("TOPLEFT", AutoLFM_MinimapButton, "TOPLEFT", -1, 1)
  AutoLFM_MinimapButton.icon = icon
  
  -- Border overlay
  local overlay = AutoLFM_MinimapButton:CreateTexture(nil, "OVERLAY")
  overlay:SetWidth(50)
  overlay:SetHeight(50)
  overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  overlay:SetPoint("TOPLEFT", AutoLFM_MinimapButton, "TOPLEFT", 0, 0)
  
  -- Highlight
  AutoLFM_MinimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  
  -- Tooltip
  AutoLFM_MinimapButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(AutoLFM_MinimapButton, "ANCHOR_RIGHT")
    GameTooltip:SetText("Auto|cff0070DDL|r|cffffffffF|r|cffff0000M")
    GameTooltip:AddLine("Click to toggle AutoLFM interface.", 1, 1, 1)
    GameTooltip:AddLine("Ctrl + Click to move.", 1, 1, 1)
    GameTooltip:Show()
  end)
  
  AutoLFM_MinimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  
  -- Click handler
  AutoLFM_MinimapButton:SetScript("OnClick", function()
    if IsControlKeyDown() then return end
    
    if AutoLFM_MainFrame then
      if AutoLFM_MainFrame:IsVisible() then
        HideUIPanel(AutoLFM_MainFrame)
      else
        ShowUIPanel(AutoLFM_MainFrame)
      end
    end
  end)
  
  -- Drag functionality
  AutoLFM_MinimapButton:SetMovable(true)
  AutoLFM_MinimapButton:EnableMouse(true)
  AutoLFM_MinimapButton:RegisterForDrag("LeftButton")
  
  AutoLFM_MinimapButton:SetScript("OnMouseDown", function()
    if IsControlKeyDown() then
      AutoLFM_MinimapButton:StartMoving()
    end
  end)
  
  AutoLFM_MinimapButton:SetScript("OnMouseUp", function()
    AutoLFM_MinimapButton:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = AutoLFM_MinimapButton:GetPoint()
    SaveMinimapPosition(xOfs, yOfs)
  end)
  
  -- Show or hide based on saved settings
  if settings.hidden then
    AutoLFM_MinimapButton:Hide()
  else
    AutoLFM_MinimapButton:Show()
  end
end