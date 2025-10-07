--------------------------------------------------
-- Icon Animation System
--------------------------------------------------
local currentFrameIndex = 1
local animationSequence = {
  "eye01",
  "eye02",
  "eye03",
  "eye04",
  "eye05",
  "eye06",
  "eye05",
  "eye04",
  "eye03",
  "eye02",
  "eye01",
  "eye07",
  "eye08",
  "eye09",
  "eye10",
  "eye11",
  "eye10",
  "eye09",
  "eye08",
  "eye07",
  "eye01",
  "eye02",
  "eye03",
  "eye04",
  "eye05",
  "eye06",
  "eye05",
  "eye04",
  "eye03",
  "eye02",
  "eye01",
  "eye07",
  "eye08",
  "eye09",
  "eye10",
  "eye11",
  "eye10",
  "eye09",
  "eye08",
  "eye07",
  "eye01",
  "eye12",
  "eye13",
  "eye14",
  "eye15",
  "eye16",
  "eye15",
  "eye14",
  "eye13",
  "eye12"
}

local animationFrame = nil
local animationSpeed = 0.15

--------------------------------------------------
-- Core Animation Functions
--------------------------------------------------
function AnimateMinimapIcon()
  currentFrameIndex = currentFrameIndex + 1
  if currentFrameIndex > table.getn(animationSequence) then
    currentFrameIndex = 1
  end
  
  local iconPath = TEXTURE_BASE_PATH .. "Eyes\\" .. animationSequence[currentFrameIndex]
  
  if AutoLFM_MinimapButton and AutoLFM_MinimapButton.icon then
    AutoLFM_MinimapButton.icon:SetTexture(iconPath)
  end
  
  if AutoLFM_MainIconTexture then
    AutoLFM_MainIconTexture:SetTexture(iconPath)
  end
end

function ResetMinimapIcon()
  currentFrameIndex = 1
  
  if AutoLFM_MinimapButton and AutoLFM_MinimapButton.icon then
    AutoLFM_MinimapButton.icon:SetTexture(TEXTURE_BASE_PATH .. "Eyes\\eye01")
  end
  
  if AutoLFM_MainIconTexture then
    AutoLFM_MainIconTexture:SetTexture(TEXTURE_BASE_PATH .. "Eyes\\eye01")
  end
end

--------------------------------------------------
-- Animation Control
--------------------------------------------------
function StartBroadcastAnimation()
  if not animationFrame then
    animationFrame = CreateFrame("Frame")
  end
  
  animationFrame.lastUpdate = GetTime()
  
  animationFrame:SetScript("OnUpdate", function()
    if not isBroadcastActive then
      StopBroadcastAnimation()
      return
    end
    
    if not animationFrame.lastUpdate then
      animationFrame.lastUpdate = GetTime()
      return
    end
    
    local now = GetTime()
    if now - animationFrame.lastUpdate >= animationSpeed then
      AnimateMinimapIcon()
      animationFrame.lastUpdate = now
    end
  end)
end

function StopBroadcastAnimation()
  if animationFrame then
    animationFrame:SetScript("OnUpdate", nil)
  end
  ResetMinimapIcon()
end