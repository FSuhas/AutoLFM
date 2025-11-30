--=============================================================================
-- AutoLFM: Eye Animation Component
--   Manages eye animation on main icon and minimap button during broadcast
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Components = AutoLFM.Components or {}
AutoLFM.Components.EyeAnimation = {}

--=============================================================================
-- CONSTANTS
--=============================================================================
local ANIMATION_FRAMES = {
  "Eye01", "Eye02", "Eye03", "Eye04", "Eye05", "Eye04", "Eye03", "Eye02", "Eye01", "Eye00",
  "Eye06", "Eye07", "Eye08", "Eye09", "Eye10", "Eye09", "Eye08", "Eye07", "Eye06", "Eye00",
  "Eye11", "Eye12", "Eye13", "Eye14", "Eye15", "Eye14", "Eye13", "Eye12", "Eye11", "Eye00"
}

local ANIMATION_SPEED = 0.15  -- seconds per frame

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local animationTimer = nil
local currentFrameIndex = 1
local lastFrameTime = 0
local isAnimating = false

--=============================================================================
-- HELPER FUNCTIONS
--=============================================================================

--- Updates the texture of an icon to display the current animation frame
--- @param textureName string - The global name of the texture (e.g., "AutoLFM_MainFrame_Icon")
--- @param frameName string - The name of the frame (e.g., "Eye01")
local function updateIconTexture(textureName, frameName)
  local texture = getglobal(textureName)
  if not texture then return end
  
  local path = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\Eye\\" .. frameName
  texture:SetTexture(path)
end

--- Starts the animation loop
local function startAnimation()
  if animationTimer then return end
  
  isAnimating = true
  currentFrameIndex = 0  -- Start at 0 so first frame is Eye01
  lastFrameTime = GetTime()
  
  animationTimer = CreateFrame("Frame", "AutoLFM_EyeAnimationTimer")
  
  animationTimer:SetScript("OnUpdate", function()
    local currentTime = GetTime()
    if currentTime - lastFrameTime >= ANIMATION_SPEED then
      lastFrameTime = currentTime
      
      -- Update frame index with looping
      currentFrameIndex = currentFrameIndex + 1
      if currentFrameIndex > table.getn(ANIMATION_FRAMES) then
        currentFrameIndex = 1
      end
      
      -- Get the current frame name
      local frameName = ANIMATION_FRAMES[currentFrameIndex]
      
      -- Update both icons
      updateIconTexture("AutoLFM_MainFrame_Icon", frameName)
      updateIconTexture("AutoLFM_MinimapButton_Icon", frameName)
    end
  end)
end

--- Stops the animation loop
local function stopAnimation()
  if animationTimer then
    animationTimer:SetScript("OnUpdate", nil)
    animationTimer = nil
  end
  
  isAnimating = false
  currentFrameIndex = 1
  
  -- Reset icons to default frame
  updateIconTexture("AutoLFM_MainFrame_Icon", "Eye00")
  updateIconTexture("AutoLFM_MinimapButton_Icon", "Eye00")
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Starts the eye animation
function AutoLFM.Components.EyeAnimation.Start()
  if not isAnimating then
    startAnimation()
  end
end

--- Stops the eye animation
function AutoLFM.Components.EyeAnimation.Stop()
  if isAnimating then
    stopAnimation()
  end
end

--- Returns whether animation is currently running
--- @return boolean - True if animation is active
function AutoLFM.Components.EyeAnimation.IsAnimating()
  return isAnimating
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("Components.EyeAnimation", function()
  --- Listen to Broadcaster.IsRunning state changes
  AutoLFM.Core.Maestro.SubscribeState("Broadcaster.IsRunning", function(newValue, oldValue)
    if newValue then
      -- Start animation when broadcast starts
      AutoLFM.Components.EyeAnimation.Start()
    else
      -- Stop animation when broadcast stops
      AutoLFM.Components.EyeAnimation.Stop()
    end
  end)
  
  -- Start animation if broadcaster is already running
  if AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning") then
    AutoLFM.Components.EyeAnimation.Start()
  end
end, {
  id = "I20",
  dependencies = { "Logic.Broadcaster" }
})
