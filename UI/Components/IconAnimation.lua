
if not AutoLFM then AutoLFM = {} end
if not AutoLFM.UI then AutoLFM.UI = {} end
if not AutoLFM.UI.Components then AutoLFM.UI.Components = {} end
if not AutoLFM.UI.Components.IconAnimation then AutoLFM.UI.Components.IconAnimation = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.UI.Components.IconAnimation.SEQUENCE = {
  "eye01", "eye02", "eye03", "eye04", "eye05", "eye06", "eye05", "eye04", "eye03", "eye02",
  "eye01", "eye07", "eye08", "eye09", "eye10", "eye11", "eye10", "eye09", "eye08", "eye07",
  "eye01", "eye02", "eye03", "eye04", "eye05", "eye06", "eye05", "eye04", "eye03", "eye02",
  "eye01", "eye07", "eye08", "eye09", "eye10", "eye11", "eye10", "eye09", "eye08", "eye07",
  "eye01", "eye12", "eye13", "eye14", "eye15", "eye16", "eye15", "eye14", "eye13", "eye12"
}

AutoLFM.UI.Components.IconAnimation.SPEED = 0.15

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local currentFrameIndex = 1
local animationFrame = nil
-----------------------------------------------------------------------------
-- Icon Management
-----------------------------------------------------------------------------
local function AnimateIcons()
  currentFrameIndex = currentFrameIndex + 1
  if currentFrameIndex > table.getn(AutoLFM.UI.Components.IconAnimation.SEQUENCE) then
    currentFrameIndex = 1
  end

  local iconPath = AutoLFM.Core.Constants.TEXTURE_PATH .. "Eyes\\" .. AutoLFM.UI.Components.IconAnimation.SEQUENCE[currentFrameIndex]

  if AutoLFM_MinimapButton and AutoLFM_MinimapButton.icon then
    AutoLFM_MinimapButton.icon:SetTexture(iconPath)
  end
  
  if AutoLFM_MainIconTexture then
    AutoLFM_MainIconTexture:SetTexture(iconPath)
  end
end
local function ResetIcons()
  currentFrameIndex = 1
  
  local defaultIconPath = AutoLFM.Core.Constants.TEXTURE_PATH .. "Eyes\\eye07"
  
  if AutoLFM_MinimapButton and AutoLFM_MinimapButton.icon then
    AutoLFM_MinimapButton.icon:SetTexture(defaultIconPath)
  end
  
  if AutoLFM_MainIconTexture then
    AutoLFM_MainIconTexture:SetTexture(defaultIconPath)
  end
end
-----------------------------------------------------------------------------
-- Animation Control
-----------------------------------------------------------------------------
function AutoLFM.UI.Components.IconAnimation.Start()
  if not animationFrame then
    animationFrame = CreateFrame("Frame")
  end
  animationFrame.lastUpdate = GetTime()

  animationFrame:SetScript("OnUpdate", function()
    if not AutoLFM.Logic.Broadcaster.IsActive() then
      AutoLFM.UI.Components.IconAnimation.Stop()
      return
    end
    if not animationFrame.lastUpdate then
      animationFrame.lastUpdate = GetTime()
      return
    end

    local now = GetTime()
    if now - animationFrame.lastUpdate >= AutoLFM.UI.Components.IconAnimation.SPEED then
      AnimateIcons()
      animationFrame.lastUpdate = now
    end
  end)
end

function AutoLFM.UI.Components.IconAnimation.Stop()
  if animationFrame then
    animationFrame:SetScript("OnUpdate", nil)
  end
  ResetIcons()
end