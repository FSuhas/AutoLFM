--=============================================================================
-- AutoLFM: Minimap Button
--=============================================================================


if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.Components then AutoLFM.UI.Components = {} end
if not AutoLFM.UI.Components.MinimapButton then AutoLFM.UI.Components.MinimapButton = {} end

-----------------------------------------------------------------------------
-- Position Management
-----------------------------------------------------------------------------
function AutoLFM.UI.Components.MinimapButton.ResetPosition()
  if not AutoLFM_MinimapButton then return end

  AutoLFM_MinimapButton:ClearAllPoints()
  AutoLFM_MinimapButton:SetPoint("LEFT", Minimap, "LEFT", 16, -68)
end
-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.UI.Components.MinimapButton.Init()
  if AutoLFM_MinimapButton then return end

  local settings = AutoLFM.Core.Settings.LoadMinimap()
  AutoLFM_MinimapButton = CreateFrame("Button", "AutoLFM_MinimapButton", Minimap)
  AutoLFM_MinimapButton:SetFrameStrata("LOW")
  AutoLFM_MinimapButton:SetWidth(33)
  AutoLFM_MinimapButton:SetHeight(33)
  AutoLFM_MinimapButton:SetMovable(true)
  AutoLFM_MinimapButton:SetClampedToScreen(true)
  
  AutoLFM_MinimapButton.icon = AutoLFM_MinimapButton:CreateTexture(nil, "BACKGROUND")
  AutoLFM_MinimapButton.icon:SetWidth(33)
  AutoLFM_MinimapButton.icon:SetHeight(33)
  AutoLFM_MinimapButton.icon:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "Eyes\\eye01")
  AutoLFM_MinimapButton.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
  AutoLFM_MinimapButton.icon:SetPoint("TOPLEFT", AutoLFM_MinimapButton, "TOPLEFT", -1, 1)
  
  local overlay = AutoLFM_MinimapButton:CreateTexture(nil, "OVERLAY")
  overlay:SetWidth(52)
  overlay:SetHeight(52)
  overlay:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "minimapBorder")
  overlay:SetPoint("TOPLEFT", AutoLFM_MinimapButton, "TOPLEFT", 0, 0)
  
  local highlight = AutoLFM_MinimapButton:CreateTexture(nil, "HIGHLIGHT")
  highlight:SetTexture(AutoLFM.Core.Constants.TEXTURE_PATH .. "minimapHighlight")
  highlight:SetAllPoints(AutoLFM_MinimapButton)
  highlight:SetBlendMode("ADD")
  
  AutoLFM_MinimapButton:EnableMouse(true)
  AutoLFM_MinimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  AutoLFM_MinimapButton:RegisterForDrag("LeftButton")
  
  AutoLFM_MinimapButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
    GameTooltip:SetText("Auto|cff0070DDL|r|cffffffffF|r|cffff0000M")
    GameTooltip:AddLine("Left-click to open main window.", 1, 1, 1)
    GameTooltip:AddLine("Hold control and drag to move.", 1, 1, 1)
    GameTooltip:AddLine("Hold control and right-click to reset position.", 1, 1, 1)
    GameTooltip:Show()
  end)
  
  AutoLFM_MinimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  
  AutoLFM_MinimapButton:SetScript("OnClick", function()
    if arg1 == "LeftButton" and not IsControlKeyDown() then
      if AutoLFM_MainFrame then
        if AutoLFM_MainFrame:IsVisible() then
          HideUIPanel(AutoLFM_MainFrame)
        else
          ShowUIPanel(AutoLFM_MainFrame)
        end
      end
    elseif arg1 == "RightButton" and IsControlKeyDown() then
      AutoLFM.Core.Settings.ResetMinimapPos()
      AutoLFM.UI.Components.MinimapButton.ResetPosition()
      AutoLFM.Core.Utils.PrintSuccess("Minimap button position reset")
    end
  end)

  AutoLFM_MinimapButton:SetScript("OnDragStart", function()
    if IsControlKeyDown() then
      this:LockHighlight()
      this:StartMoving()
    end
  end)
  
  AutoLFM_MinimapButton:SetScript("OnDragStop", function()
    this:UnlockHighlight()
    this:StopMovingOrSizing()
    
    local x, y = this:GetCenter()
    if x and y then
      AutoLFM.Core.Settings.SaveMinimapPos(x, y)
    end
  end)
  
  if settings.posX and settings.posY then
    AutoLFM_MinimapButton:ClearAllPoints()
    AutoLFM_MinimapButton:SetPoint("CENTER", UIParent, "BOTTOMLEFT", settings.posX, settings.posY)
  else
    AutoLFM.UI.Components.MinimapButton.ResetPosition()
  end

  if settings.hidden then
    AutoLFM_MinimapButton:Hide()
  else
    AutoLFM_MinimapButton:Show()
  end

  AutoLFM.UI.Components.DarkUI.RegisterFrame(AutoLFM_MinimapButton)
end

-----------------------------------------------------------------------------
-- Globals
-----------------------------------------------------------------------------
AutoLFM_MinimapButton = nil
