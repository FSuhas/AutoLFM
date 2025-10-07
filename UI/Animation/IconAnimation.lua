--------------------------------------------------
-- Icon Animation System
--------------------------------------------------

local currentFrameIndex = 1
local animationFrame = nil

--------------------------------------------------
-- Animate Minimap Icon
--------------------------------------------------
function AnimateMinimapIcon()
  currentFrameIndex = currentFrameIndex + 1
  if currentFrameIndex > table.getn(ANIMATION_SEQUENCE) then
    currentFrameIndex = 1
  end
  
  local iconPath = TEXTURE_BASE_PATH .. "Eyes\\" .. ANIMATION_SEQUENCE[currentFrameIndex]
  
  if AutoLFM_MinimapButton and AutoLFM_MinimapButton.icon then
    AutoLFM_MinimapButton.icon:SetTexture(iconPath)
  end
  
  if AutoLFM_MainIconTexture then
    AutoLFM_MainIconTexture:SetTexture(iconPath)
  end
end

--------------------------------------------------
-- Reset Icon to Default
--------------------------------------------------
function ResetMinimapIcon()
  currentFrameIndex = 1
  
  local defaultIconPath = TEXTURE_BASE_PATH .. "Eyes\\eye01"
  
  if AutoLFM_MinimapButton and AutoLFM_MinimapButton.icon then
    AutoLFM_MinimapButton.icon:SetTexture(defaultIconPath)
  end
  
  if AutoLFM_MainIconTexture then
    AutoLFM_MainIconTexture:SetTexture(defaultIconPath)
  end
end

--------------------------------------------------
-- Start Animation Loop
--------------------------------------------------
function StartBroadcastAnimation()
  if not animationFrame then
    animationFrame = CreateFrame("Frame")
  end
  
  animationFrame.lastUpdate = GetTime()
  
  animationFrame:SetScript("OnUpdate", function()
    if not IsBroadcastActive() then
      StopBroadcastAnimation()
      return
    end
    
    if not animationFrame.lastUpdate then
      animationFrame.lastUpdate = GetTime()
      return
    end
    
    local now = GetTime()
    if now - animationFrame.lastUpdate >= ANIMATION_SPEED then
      AnimateMinimapIcon()
      animationFrame.lastUpdate = now
    end
  end)
end

--------------------------------------------------
-- Stop Animation Loop
--------------------------------------------------
function StopBroadcastAnimation()
  if animationFrame then
    animationFrame:SetScript("OnUpdate", nil)
  end
  ResetMinimapIcon()
end