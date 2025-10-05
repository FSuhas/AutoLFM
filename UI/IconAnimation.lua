--------------------------------------------------
-- Icon Animation System
--------------------------------------------------
local currentFrameIndex = 1
local animationSequence = {
  "eye01",
  "eye00",
  "eye06",
  "eye07",
  "eye08",
  "eye09",
  "eye10",
  "eye09",
  "eye08",
  "eye07",
  "eye06",
  "eye11",
  "eye12",
  "eye13",
  "eye14",
  "eye15",
  "eye14",
  "eye13",
  "eye12",
  "eye11",
  "eye06",
  "eye07",
  "eye08",
  "eye09",
  "eye10",
  "eye09",
  "eye08",
  "eye07",
  "eye06",
  "eye11",
  "eye12",
  "eye13",
  "eye14",
  "eye15",
  "eye14",
  "eye13",
  "eye12",
  "eye11",
  "eye00",
  "eye01",
  "eye02",
  "eye03",
  "eye04",
  "eye05",
  "eye04",
  "eye03",
  "eye02"
}

local animationFrame = nil
local animationSpeed = 0.15

--------------------------------------------------
-- Core Animation Functions
--------------------------------------------------
function AnimateIcons()
  currentFrameIndex = currentFrameIndex + 1
  if currentFrameIndex > table.getn(animationSequence) then
    currentFrameIndex = 1
  end
  
  local iconPath = texturePath .. "Eyes\\" .. animationSequence[currentFrameIndex]
  
  if AutoLFMMinimapBtn and AutoLFMMinimapBtn.icon then
    AutoLFMMinimapBtn.icon:SetTexture(iconPath)
  end
  
  if AutoLFMMainIcon then
    AutoLFMMainIcon:SetTexture(iconPath)
  end
end

function ResetIcons()
  currentFrameIndex = 1
  
  if AutoLFMMinimapBtn and AutoLFMMinimapBtn.icon then
    AutoLFMMinimapBtn.icon:SetTexture(texturePath .. "Eyes\\eye01")
  end
  
  if AutoLFMMainIcon then
    AutoLFMMainIcon:SetTexture(texturePath .. "Eyes\\eye01")
  end
end

--------------------------------------------------
-- Animation Control
--------------------------------------------------
function StartIconAnimation()
  if not animationFrame then
    animationFrame = CreateFrame("Frame")
  end
  
  local lastUpdate = GetTime()
  animationFrame:SetScript("OnUpdate", function()
    if not isBroadcasting then
      StopIconAnimation()
      return
    end
    
    local now = GetTime()
    if now - lastUpdate >= animationSpeed then
      AnimateIcons()
      lastUpdate = now
    end
  end)
end

function StopIconAnimation()
  if animationFrame then
    animationFrame:SetScript("OnUpdate", nil)
  end
  ResetIcons()
end