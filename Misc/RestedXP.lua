--=============================================================================
-- AutoLFM: Rested XP Monitor
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Misc then AutoLFM.Misc = {} end
if not AutoLFM.Misc.RestedXP then AutoLFM.Misc.RestedXP = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local restedFrame = nil
local hasAnnouncedFull = false
local isEnabled = false

-----------------------------------------------------------------------------
-- Rested XP Check
-----------------------------------------------------------------------------
function AutoLFM.Misc.RestedXP.CheckFull()
  local level = UnitLevel("player")
  if level >= 60 then return end
  
  local restXP = GetXPExhaustion()
  local maxXP = UnitXPMax("player")
  
  if restXP and restXP >= (maxXP * 1.5) then
    if not hasAnnouncedFull then
      if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintSuccess then
        AutoLFM.Core.Utils.PrintSuccess("Your rested XP is FULL!")
      end
      PlaySound("LEVELUP")
      hasAnnouncedFull = true
    end
  else
    hasAnnouncedFull = false
  end
end

function AutoLFM.Misc.RestedXP.ShowStatus()
  local level = UnitLevel("player")
  if level >= 60 then
    if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintError then
      AutoLFM.Core.Utils.PrintError("You are level 60, rested XP does not apply")
    end
    return
  end
  
  local restXP = GetXPExhaustion() or 0
  local maxXP = UnitXPMax("player")
  local percent = math.floor((restXP / (maxXP * 1.5)) * 100)
  
  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintInfo then
    AutoLFM.Core.Utils.PrintInfo(
      string.format("Current rested XP: %d / %d (~%d%%)", restXP, maxXP * 1.5, percent)
    )
  end
end

-----------------------------------------------------------------------------
-- Event Setup
-----------------------------------------------------------------------------
local function Setup()
  if not restedFrame then
    restedFrame = CreateFrame("Frame")
  end
  
  restedFrame:SetScript("OnEvent", function()
    AutoLFM.Misc.RestedXP.CheckFull()
  end)
  
  restedFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  restedFrame:RegisterEvent("UPDATE_EXHAUSTION")
  isEnabled = true
end

local function Teardown()
  if restedFrame and isEnabled then
    restedFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    restedFrame:UnregisterEvent("UPDATE_EXHAUSTION")
    isEnabled = false
  end
end

function AutoLFM.Misc.RestedXP.Enable()
  if not isEnabled then
    Setup()
  end
  
  AutoLFM.Core.Settings.SaveMiscModule("restedXP", true)
end

function AutoLFM.Misc.RestedXP.Disable()
  Teardown()
  
  AutoLFM.Core.Settings.SaveMiscModule("restedXP", false)
end

function AutoLFM.Misc.RestedXP.IsEnabled()
  return isEnabled
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.Misc.RestedXP.Init()
  if AutoLFM.Core.Settings.LoadMiscModule("restedXP") then
    Setup()
  end
end

-----------------------------------------------------------------------------
-- Slash Command Handler
-----------------------------------------------------------------------------
SLASH_RESTEDXP1 = "/rested"
SlashCmdList["RESTEDXP"] = function()
  AutoLFM.Misc.RestedXP.ShowStatus()
end
