--=============================================================================
-- AutoLFM: Minimap Button
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.MinimapButton then AutoLFM.UI.MinimapButton = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.UI.MinimapButton.DEFAULT_ANGLE = 225

-----------------------------------------------------------------------------
-- Position Management
-----------------------------------------------------------------------------
local function GetMinimapAngle()
  if not AutoLFM_MinimapButton then return AutoLFM.UI.MinimapButton.DEFAULT_ANGLE end
  
  local centerX, centerY = Minimap:GetCenter()
  local buttonX, buttonY = AutoLFM_MinimapButton:GetCenter()
  
  if not centerX or not centerY or not buttonX or not buttonY then
    return AutoLFM.UI.MinimapButton.DEFAULT_ANGLE
  end
  
  local dx = buttonX - centerX
  local dy = buttonY - centerY
  
  local angle = math.deg(math.atan2(dy, dx))
  
  if angle < 0 then
    angle = angle + 360
  end
  
  return angle
end

function AutoLFM.UI.MinimapButton.SetPosition(angle)
  if not AutoLFM_MinimapButton then return end
  if not angle then angle = AutoLFM.UI.MinimapButton.DEFAULT_ANGLE end
  
  local success, err = pcall(function()
    local radian = math.rad(angle)
    local radius = 80
    
    local x = math.cos(radian) * radius
    local y = math.sin(radian) * radius
    
    AutoLFM_MinimapButton:ClearAllPoints()
    AutoLFM_MinimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
  end)
  
  if not success then
    AutoLFM.Core.Utils.PrintError("Failed to position minimap button: " .. tostring(err))
  end
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.UI.MinimapButton.Init()
  if AutoLFM_MinimapButton then return end
  
  local success, err = pcall(function()
    local settings = AutoLFM.Core.Settings.LoadMinimap()
    
    AutoLFM_MinimapButton = CreateFrame("Button", "AutoLFM_MinimapButton", Minimap)
    AutoLFM_MinimapButton:SetFrameStrata("MEDIUM")
    AutoLFM_MinimapButton:SetFrameLevel(8)
    AutoLFM_MinimapButton:SetWidth(30)
    AutoLFM_MinimapButton:SetHeight(30)
    
    local icon = AutoLFM_MinimapButton:CreateTexture(nil, "BACKGROUND")
    icon:SetWidth(30)
    icon:SetHeight(30)
    icon:SetTexture(AutoLFM.Core.Utils.CONSTANTS.TEXTURE_PATH .. "Eyes\\eye07")
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    icon:SetPoint("TOPLEFT", AutoLFM_MinimapButton, "TOPLEFT", -1, 1)
    AutoLFM_MinimapButton.icon = icon
    
    local overlay = AutoLFM_MinimapButton:CreateTexture(nil, "OVERLAY")
    overlay:SetWidth(50)
    overlay:SetHeight(50)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetPoint("TOPLEFT", AutoLFM_MinimapButton, "TOPLEFT", 0, 0)
    
    AutoLFM_MinimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    AutoLFM_MinimapButton:EnableMouse(true)
    AutoLFM_MinimapButton:RegisterForClicks("LeftButtonUp")
    AutoLFM_MinimapButton:RegisterForDrag("LeftButton")
    
    AutoLFM_MinimapButton:SetScript("OnEnter", function()
      local success, err = pcall(function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetText("Auto|cff0070DDL|r|cffffffffF|r|cffff0000M")
        GameTooltip:AddLine("Click to toggle AutoLFM interface.", 1, 1, 1)
        GameTooltip:AddLine("Ctrl + Click to move.", 1, 1, 1)
        GameTooltip:Show()
      end)
      
      if not success then
        GameTooltip:Hide()
      end
    end)
    
    AutoLFM_MinimapButton:SetScript("OnLeave", function()
      pcall(function()
        GameTooltip:Hide()
      end)
    end)
    
    AutoLFM_MinimapButton:SetScript("OnClick", function()
      local success, err = pcall(function()
        if IsControlKeyDown() then return end
        
        if AutoLFM_MainFrame then
          if AutoLFM_MainFrame:IsVisible() then
            HideUIPanel(AutoLFM_MainFrame)
          else
            ShowUIPanel(AutoLFM_MainFrame)
          end
        end
      end)
      
      if not success then
        AutoLFM.Core.Utils.PrintError("Minimap button click error: " .. tostring(err))
      end
    end)
    
    AutoLFM_MinimapButton:SetScript("OnDragStart", function()
      local success, err = pcall(function()
        if IsControlKeyDown() then
          this:LockHighlight()
          this.isDragging = true
        end
      end)
      
      if not success then
        this.isDragging = nil
      end
    end)
    
    AutoLFM_MinimapButton:SetScript("OnDragStop", function()
      local success, err = pcall(function()
        if this.isDragging then
          this:UnlockHighlight()
          this.isDragging = nil
          
          local x, y = GetCursorPosition()
          local scale = Minimap:GetEffectiveScale()
          
          if not scale or scale <= 0 then
            scale = 1
          end
          
          x = x / scale
          y = y / scale
          
          local centerX, centerY = Minimap:GetCenter()
          if centerX and centerY then
            local dx = x - centerX
            local dy = y - centerY
            local angle = math.deg(math.atan2(dy, dx))
            
            if angle < 0 then
              angle = angle + 360
            end
            
            AutoLFM.Core.Settings.SaveMinimapPos(angle)
            AutoLFM.UI.MinimapButton.SetPosition(angle)
          end
        end
      end)
      
      if not success then
        if this.isDragging then
          this:UnlockHighlight()
          this.isDragging = nil
        end
      end
    end)
    
    AutoLFM_MinimapButton:SetScript("OnUpdate", function()
      pcall(function()
        if this.isDragging then
          local x, y = GetCursorPosition()
          local scale = Minimap:GetEffectiveScale()
          
          if not scale or scale <= 0 then
            scale = 1
          end
          
          x = x / scale
          y = y / scale
          
          local centerX, centerY = Minimap:GetCenter()
          if centerX and centerY then
            local dx = x - centerX
            local dy = y - centerY
            local angle = math.deg(math.atan2(dy, dx))
            
            if angle < 0 then
              angle = angle + 360
            end
            
            AutoLFM.UI.MinimapButton.SetPosition(angle)
          end
        end
      end)
    end)
    
    AutoLFM.UI.MinimapButton.SetPosition(settings.angle)
    
    if settings.hidden then
      AutoLFM_MinimapButton:Hide()
    else
      AutoLFM_MinimapButton:Show()
    end
  end)
  
  if not success then
    AutoLFM.Core.Utils.PrintError("Failed to initialize minimap button: " .. tostring(err))
  end
end

-----------------------------------------------------------------------------
-- Globals (Required by WoW API)
-----------------------------------------------------------------------------
AutoLFM_MinimapButton = nil
