--------------------------------------------------
-- FPS/MS Display Frame
--------------------------------------------------
local MyFPSFrame = CreateFrame("Frame", "MyFPSFrame", UIParent)
MyFPSFrame:SetWidth(90)
MyFPSFrame:SetHeight(40)
MyFPSFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)

MyFPSFrame.bg = MyFPSFrame:CreateTexture(nil, "BACKGROUND")
MyFPSFrame.bg:SetAllPoints(MyFPSFrame)
MyFPSFrame.bg:SetTexture(0, 0, 0, 0.3)
MyFPSFrame.bg:Hide()

MyFPSFrame.fpsText = MyFPSFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
MyFPSFrame.fpsText:SetPoint("TOP", 0, -5)

MyFPSFrame.msText = MyFPSFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
MyFPSFrame.msText:SetPoint("BOTTOM", 0, 5)

MyFPSFrame:EnableMouse(true)
MyFPSFrame:SetMovable(true)
MyFPSFrame:SetScript("OnMouseDown", function()
  if IsAltKeyDown() then
    MyFPSFrame:StartMoving()
  end
end)
MyFPSFrame:SetScript("OnMouseUp", function()
  MyFPSFrame:StopMovingOrSizing()
end)

MyFPSFrame.timeSinceUpdate = 0

local lastUpdate = 0
MyFPSFrame:SetScript("OnUpdate", function()
  local now = GetTime()
  if now - lastUpdate >= 1 then
    local fps = floor(GetFramerate() + 0.5)
    local _, _, latencyHome = GetNetStats()
    MyFPSFrame.fpsText:SetText("FPS: "..fps)
    MyFPSFrame.msText:SetText("MS: "..latencyHome)
    lastUpdate = now
  end
end)

MyFPSFrame:SetScript("OnEnter", function()
  MyFPSFrame.bg:Show()
end)

MyFPSFrame:SetScript("OnLeave", function()
  MyFPSFrame.bg:Hide()
end)

local function ToggleMyFPSFrame()
  if MyFPSFrame:IsShown() then
    MyFPSFrame:Hide()
  else
    MyFPSFrame:Show()
    MyFPSFrame.timeSinceUpdate = 1
  end
end

local originalToggleFramerate = ToggleFramerate
function ToggleFramerate()
  ToggleMyFPSFrame()
end

MyFPSFrame:Hide()