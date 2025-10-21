--=============================================================================
-- AutoLFM: Minimap Button
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.MinimapButton then AutoLFM.UI.MinimapButton = {} end

-----------------------------------------------------------------------------
-- Position Management
-----------------------------------------------------------------------------
function AutoLFM.UI.MinimapButton.ResetPosition()
  if not AutoLFM_MinimapButton then return end
  
  local defaultAngle = AutoLFM.Core.Settings.DEFAULTS.MINIMAP_ANGLE
  local radian = math.rad(defaultAngle)
  local radius = 80
  local x = math.cos(radian) * radius
  local y = math.sin(radian) * radius
  
  local minimapX, minimapY = Minimap:GetCenter()
  if minimapX and minimapY then
    AutoLFM_MinimapButton:ClearAllPoints()
    AutoLFM_MinimapButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", minimapX + x, minimapY + y)
  else
    AutoLFM_MinimapButton:ClearAllPoints()
    AutoLFM_MinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
  end
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.UI.MinimapButton.Init()
  if AutoLFM_MinimapButton then return end
  
  local settings = AutoLFM.Core.Settings.LoadMinimap()
  
  AutoLFM_MinimapButton = CreateFrame("Button", "AutoLFM_MinimapButton", UIParent)
  AutoLFM_MinimapButton:SetFrameStrata("MEDIUM")
  AutoLFM_MinimapButton:SetFrameLevel(8)
  AutoLFM_MinimapButton:SetWidth(42)
  AutoLFM_MinimapButton:SetHeight(42)
  
  local icon = AutoLFM_MinimapButton:CreateTexture(nil, "BACKGROUND")
  icon:SetWidth(42)
  icon:SetHeight(42)
  icon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Eyes\\eye07")
  icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
  icon:SetPoint("CENTER", AutoLFM_MinimapButton, "CENTER", 0, 0)
  
  local overlay = AutoLFM_MinimapButton:CreateTexture(nil, "OVERLAY")
  overlay:SetWidth(64)
  overlay:SetHeight(64)
  overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  overlay:SetPoint("TOPLEFT", AutoLFM_MinimapButton, "TOPLEFT", 1, -2)

  -- 🔥 Ajout pour que l’animation le détecte
  AutoLFM_MinimapButton.icon = icon
  
  AutoLFM_MinimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  AutoLFM_MinimapButton:EnableMouse(true)
  AutoLFM_MinimapButton:SetMovable(true)
  AutoLFM_MinimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  AutoLFM_MinimapButton:RegisterForDrag("RightButton")

  AutoLFM_MinimapButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:SetText("Auto|cff0070DDL|r|cffffffffF|r|cffff0000M")
    GameTooltip:AddLine("Left Click: Toggle interface", 1, 1, 1)
    GameTooltip:AddLine("Right Click + Drag: Move", 1, 1, 1)
    GameTooltip:AddLine("Shift + Right Click: Reset position", 1, 1, 1)
    GameTooltip:Show()
  end)

  AutoLFM_MinimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)

  AutoLFM_MinimapButton:SetScript("OnClick", function()
    if arg1 == "LeftButton" then
      if AutoLFM_MainFrame then
        if AutoLFM_MainFrame:IsVisible() then
          HideUIPanel(AutoLFM_MainFrame)
        else
          ShowUIPanel(AutoLFM_MainFrame)
        end
      end
    elseif arg1 == "RightButton" and IsShiftKeyDown() then
      AutoLFM.Core.Settings.ResetMinimapPos()
      AutoLFM.UI.MinimapButton.ResetPosition()
      AutoLFM.Core.Utils.PrintSuccess("Minimap button position reset")
    end
  end)

  AutoLFM_MinimapButton:SetScript("OnDragStart", function()
    AutoLFM_MinimapButton:StartMoving()
  end)

  AutoLFM_MinimapButton:SetScript("OnDragStop", function()
    AutoLFM_MinimapButton:StopMovingOrSizing()
    
    local x, y = AutoLFM_MinimapButton:GetCenter()
    if x and y then
      AutoLFM.Core.Settings.SaveMinimapPos(x, y)
    end
  end)

  if settings.posX and settings.posY then
    AutoLFM_MinimapButton:ClearAllPoints()
    AutoLFM_MinimapButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", settings.posX, settings.posY)
  else
    AutoLFM.UI.MinimapButton.ResetPosition()
  end
  
  if settings.hidden then
    AutoLFM_MinimapButton:Hide()
  else
    AutoLFM_MinimapButton:Show()
  end
end

-----------------------------------------------------------------------------
-- Globals
-----------------------------------------------------------------------------
AutoLFM_MinimapButton = nil
