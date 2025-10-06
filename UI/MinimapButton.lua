--------------------------------------------------
-- Minimap Button
--------------------------------------------------
local minimapEventFrame = CreateFrame("Frame")

AutoLFMMinimapBtn = nil

function InitMinimapButton()
  if AutoLFMMinimapBtn then
    return
  end
  
  local isHidden = AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden
  
  AutoLFMMinimapBtn = CreateFrame("Button", "AutoLFMMinimapBtn", Minimap)
  AutoLFMMinimapBtn:SetFrameStrata("LOW")
  AutoLFMMinimapBtn:SetWidth(31)
  AutoLFMMinimapBtn:SetHeight(31)
  
  local posX = AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnX or -10
  local posY = AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnY or -10
  AutoLFMMinimapBtn:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", posX, posY)
  
  -- Icon
  local icon = AutoLFMMinimapBtn:CreateTexture(nil, "BACKGROUND")
  icon:SetWidth(20)
  icon:SetHeight(20)
  icon:SetTexture(texturePath .. "Eyes\\eye01")
  icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
  icon:SetPoint("TOPLEFT", AutoLFMMinimapBtn, "TOPLEFT", 7, -5)
  
  AutoLFMMinimapBtn.icon = icon
  
  -- Border
  local overlay = AutoLFMMinimapBtn:CreateTexture(nil, "OVERLAY")
  overlay:SetWidth(53)
  overlay:SetHeight(53)
  overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  overlay:SetPoint("TOPLEFT", AutoLFMMinimapBtn, "TOPLEFT", 0, 0)
  
  AutoLFMMinimapBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  
  AutoLFMMinimapBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(AutoLFMMinimapBtn, "ANCHOR_RIGHT")
    GameTooltip:SetText("Auto|cff0070DDL|r|cffffffffF|r|cffff0000M ")
    GameTooltip:AddLine("Click to toggle AutoLFM interface.", 1, 1, 1)
    GameTooltip:AddLine("Ctrl + Click for move.", 1, 1, 1)
    GameTooltip:Show()
  end)
  
  AutoLFMMinimapBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  
  AutoLFMMinimapBtn:SetScript("OnClick", function()
    if IsControlKeyDown() then return end
    
    if AutoLFM then
      if AutoLFM:IsShown() then
        HideUIPanel(AutoLFM)
      else
        ShowUIPanel(AutoLFM)
      end
    end
  end)
  
  AutoLFMMinimapBtn:SetMovable(true)
  AutoLFMMinimapBtn:EnableMouse(true)
  AutoLFMMinimapBtn:RegisterForDrag("LeftButton")
  
  AutoLFMMinimapBtn:SetScript("OnMouseDown", function()
    if IsControlKeyDown() then
      AutoLFMMinimapBtn:StartMoving()
    end
  end)
  
  AutoLFMMinimapBtn:SetScript("OnMouseUp", function()
    AutoLFMMinimapBtn:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = AutoLFMMinimapBtn:GetPoint()
    AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnX = xOfs
    AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnY = yOfs
  end)
  
  if isHidden then
    AutoLFMMinimapBtn:Hide()
  else
    AutoLFMMinimapBtn:Show()
  end
end

minimapEventFrame:RegisterEvent("ADDON_LOADED")
minimapEventFrame:SetScript("OnEvent", function()
  local currentEvent = event
  local currentArg = arg1
  if currentEvent == "ADDON_LOADED" and currentArg == "AutoLFM" then
    InitMinimapButton()
  end
end)