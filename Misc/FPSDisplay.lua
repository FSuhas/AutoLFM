--=============================================================================
-- AutoLFM: FPS Display
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Misc then AutoLFM.Misc = {} end
if not AutoLFM.Misc.FPSDisplay then AutoLFM.Misc.FPSDisplay = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.Misc.FPSDisplay.UPDATE_INTERVAL = 1

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local fpsFrame = nil

-----------------------------------------------------------------------------
-- Frame Creation
-----------------------------------------------------------------------------
local function CreateFPSFrame()
  fpsFrame = CreateFrame("Frame", "MyFPSFrame", UIParent)
  fpsFrame:SetWidth(90)
  fpsFrame:SetHeight(40)

  -- Load saved position or default
  local saved = V2_Settings and V2_Settings.FPSDisplayPosition
  if saved then
    fpsFrame:SetPoint(saved.point or "CENTER", UIParent, saved.relativePoint or "CENTER", saved.x or 0, saved.y or 200)
  else
    fpsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
  end

  fpsFrame.bg = fpsFrame:CreateTexture(nil, "BACKGROUND")
  fpsFrame.bg:SetAllPoints(fpsFrame)
  fpsFrame.bg:SetTexture(0, 0, 0, 0.3)
  fpsFrame.bg:Hide()

  fpsFrame.fpsText = fpsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  fpsFrame.fpsText:SetPoint("TOP", 0, -5)

  fpsFrame.msText = fpsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  fpsFrame.msText:SetPoint("BOTTOM", 0, 5)

  fpsFrame:EnableMouse(true)
  fpsFrame:SetMovable(true)
  
  fpsFrame:SetScript("OnMouseDown", function()
    if IsAltKeyDown() then
      fpsFrame:StartMoving()
    end
  end)
  
  fpsFrame:SetScript("OnMouseUp", function()
    fpsFrame:StopMovingOrSizing()

    -- Save position to V2_Settings
    if not V2_Settings then V2_Settings = {} end
    if not V2_Settings.FPSDisplayPosition then V2_Settings.FPSDisplayPosition = {} end

    local point, _, relativePoint, xOfs, yOfs = fpsFrame:GetPoint()
    V2_Settings.FPSDisplayPosition.point = point
    V2_Settings.FPSDisplayPosition.relativePoint = relativePoint
    V2_Settings.FPSDisplayPosition.x = xOfs
    V2_Settings.FPSDisplayPosition.y = yOfs
  end)
  
  local lastUpdate = 0
  fpsFrame:SetScript("OnUpdate", function()
    local now = GetTime()
    if now - lastUpdate >= AutoLFM.Misc.FPSDisplay.UPDATE_INTERVAL then
      local fps = floor(GetFramerate() + 0.5)
      local _, _, latencyHome = GetNetStats()
      fpsFrame.fpsText:SetText("FPS: " .. fps)
      fpsFrame.msText:SetText("MS: " .. latencyHome)
      lastUpdate = now
    end
  end)

  fpsFrame:SetScript("OnEnter", function()
    fpsFrame.bg:Show()
  end)

  fpsFrame:SetScript("OnLeave", function()
    fpsFrame.bg:Hide()
  end)

  fpsFrame:Hide()
end

-----------------------------------------------------------------------------
-- Toggle FPS Display
-----------------------------------------------------------------------------
function AutoLFM.Misc.FPSDisplay.Toggle()
  if not fpsFrame then
    CreateFPSFrame()
  end
  
  if fpsFrame:IsShown() then
    fpsFrame:Hide()
    AutoLFM.Core.Settings.SaveMiscModule("fpsDisplay", false)
  else
    fpsFrame:Show()
    AutoLFM.Core.Settings.SaveMiscModule("fpsDisplay", true)
  end
end

function AutoLFM.Misc.FPSDisplay.Enable()
  if not fpsFrame then
    CreateFPSFrame()
  end
  fpsFrame:Show()
  AutoLFM.Core.Settings.SaveMiscModule("fpsDisplay", true)
end

function AutoLFM.Misc.FPSDisplay.Disable()
  if fpsFrame then
    fpsFrame:Hide()
  end
  AutoLFM.Core.Settings.SaveMiscModule("fpsDisplay", false)
end

function AutoLFM.Misc.FPSDisplay.IsEnabled()
  return fpsFrame and fpsFrame:IsShown() or false
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.Misc.FPSDisplay.Init()
  if not fpsFrame then
    CreateFPSFrame()
  end
  
  if AutoLFM.Core.Settings.LoadMiscModule("fpsDisplay") then
    fpsFrame:Show()
  end
end

-----------------------------------------------------------------------------
-- Hook ToggleFramerate
-----------------------------------------------------------------------------
function ToggleFramerate()
  AutoLFM.Misc.FPSDisplay.Toggle()
end
