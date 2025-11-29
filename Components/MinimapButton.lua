--=============================================================================
-- AutoLFM: Minimap Button
--   Minimap button management
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.Components = AutoLFM.Components or {}
AutoLFM.Components.MinimapButton = {}

--=============================================================================
-- PUBLIC API
--   Functions for controlling minimap button visibility and position
--=============================================================================

--- Shows the minimap button and saves visibility state
function AutoLFM.Components.MinimapButton.Show()
  local button = getglobal("AutoLFM_MinimapButton")
  if button then
      button:Show()
      AutoLFM.Core.Storage.SetMinimapHidden(false)
  end
end

--- Hides the minimap button and saves visibility state
function AutoLFM.Components.MinimapButton.Hide()
  local button = getglobal("AutoLFM_MinimapButton")
  if button then
      button:Hide()
      AutoLFM.Core.Storage.SetMinimapHidden(true)
  end
end

--- Toggles minimap button visibility (show/hide)
function AutoLFM.Components.MinimapButton.Toggle()
  local button = getglobal("AutoLFM_MinimapButton")
  if not button then return end

  if button:IsVisible() then
      AutoLFM.Components.MinimapButton.Hide()
  else
      AutoLFM.Components.MinimapButton.Show()
  end
end

--- Resets minimap button to default position (left side of minimap)
function AutoLFM.Components.MinimapButton.ResetPosition()
  local button = getglobal("AutoLFM_MinimapButton")
  if button then
      button:ClearAllPoints()
      button:SetPoint("LEFT", Minimap, "LEFT", 16, -68)
  end
end

--=============================================================================
-- EVENT HANDLERS
--   XML callback functions for minimap button interactions
--=============================================================================

--- Handles minimap button click events
--- Left-click: Toggle main frame
--- Ctrl+Right-click: Reset position
--- @param button frame - The minimap button frame
--- @param mouseButton string - "LeftButton" or "RightButton"
function AutoLFM.Components.MinimapButton.OnClick(button, mouseButton)
  if mouseButton == "LeftButton" then
      AutoLFM.Core.Maestro.Dispatch("MainFrame.Toggle")
  elseif mouseButton == "RightButton" and IsControlKeyDown() then
      -- Reset minimap button position directly
      AutoLFM.Core.Storage.SetMinimapPos(nil, nil)
      AutoLFM.Components.MinimapButton.ResetPosition()
      AutoLFM.Core.Utils.LogInfo("Reset minimap button position")
  end
end

--- Handles minimap button drag stop event, saves new position
--- @param button frame - The minimap button frame
function AutoLFM.Components.MinimapButton.OnDragStop(button)
  if not button then return end

  -- Get current position
  local scale = button:GetEffectiveScale() / UIParent:GetEffectiveScale()
  local x, y = button:GetCenter()
  if x and y then
      x = x * scale
      y = y * scale

      -- Save position to Persistent
      AutoLFM.Core.Storage.SetMinimapPos(x, y)
  end
end

--- Shows tooltip on minimap button hover
--- @param button frame - The minimap button frame
function AutoLFM.Components.MinimapButton.OnEnter(button)
  GameTooltip:SetOwner(button, "ANCHOR_LEFT")
  GameTooltip:SetText("Auto|cff0070DDL|r|cffffffffF|r|cffff0000M")
  GameTooltip:AddLine("Left-click to open main window.", 1, 1, 1)
  GameTooltip:AddLine("Hold control and drag to move.", 1, 1, 1)
  GameTooltip:AddLine("Hold control and right-click to reset position.", 1, 1, 1)
  GameTooltip:Show()
end

--=============================================================================
-- INITIALIZATION
--   Loads saved position and visibility state from persistent storage
--=============================================================================

--- Initializes minimap button from persistent settings
--- Restores saved position and visibility state
function AutoLFM.Components.MinimapButton.Init()
  local button = getglobal("AutoLFM_MinimapButton")
  if not button then return end

  -- Load saved position
  local pos = AutoLFM.Core.Storage.GetMinimapPos()
  if pos and pos.x and pos.y then
      button:ClearAllPoints()
      button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x, pos.y)
  end

  -- Load visibility state (minimapHidden stored, so we invert it)
  local isHidden = AutoLFM.Core.Storage.GetMinimapHidden()
  if isHidden then
      button:Hide()
  else
      button:Show()
  end
end

AutoLFM.Core.SafeRegisterInit("Minimap", function()
  -- Initialize button from saved state
  AutoLFM.Components.MinimapButton.Init()

  -- No commands to register - all minimap operations go through Settings commands
end, {
  id = "I07",
  dependencies = {"Core.Storage"} -- Must run after Persistent loads
})
