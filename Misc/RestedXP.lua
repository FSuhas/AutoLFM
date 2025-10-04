--------------------------------------------------
-- Rested XP Notification
--------------------------------------------------
local RestedXPFrame = CreateFrame("Frame")
local hasAnnouncedFull = false

function CheckFullRested()
  local level = UnitLevel("player")
  if level >= 60 then return end
  
  local restXP = GetXPExhaustion()
  local maxXP = UnitXPMax("player")
  
  if restXP and restXP >= (maxXP * 1.5) then
    if not hasAnnouncedFull then
      DEFAULT_CHAT_FRAME:AddMessage("✨ Your rested XP is FULL!", 0, 1, 0)
      PlaySound("LEVELUP")
      hasAnnouncedFull = true
    end
  else
    hasAnnouncedFull = false
  end
end

RestedXPFrame:SetScript("OnEvent", function()
  CheckFullRested()
end)

RestedXPFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
RestedXPFrame:RegisterEvent("UPDATE_EXHAUSTION")

SLASH_RESTEDXP1 = "/rested"
SlashCmdList["RESTEDXP"] = function()
  local level = UnitLevel("player")
  if level >= 60 then
    DEFAULT_CHAT_FRAME:AddMessage("You are level 60, rested XP does not apply.", 1, 0, 0)
    return
  end
  
  local restXP = GetXPExhaustion() or 0
  local maxXP = UnitXPMax("player")
  local percent = math.floor((restXP / (maxXP * 1.5)) * 100)
  
  DEFAULT_CHAT_FRAME:AddMessage(
    string.format("💤 Current rested XP: %d / %d (≈%d%%)", restXP, maxXP * 1.5, percent),
    0.5, 0.8, 1
  )
end