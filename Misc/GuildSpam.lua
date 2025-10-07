--------------------------------------------------
-- Guild Message Spam
--------------------------------------------------
local mgMessage = nil
local mgInterval = 60
local mgElapsed = 0
local mgRunning = false
local mgFrame = CreateFrame("Frame", "MGSpamFrame")

SLASH_MG1 = "/mg"
SlashCmdList["MG"] = function(msg)
  local args = SplitString(" ", msg)
  
  if not args or table.getn(args) == 0 then
    AutoLFM_PrintError("[MG] Usage: /mg <message> | /mg stop | /mg interval <sec> | /mg msg")
    return
  end
  
  if args[1] == "stop" then
    mgRunning = false
    mgFrame:SetScript("OnUpdate", nil)
    AutoLFM_PrintError("[MG] Spam stopped")
    return
  end
  
  if args[1] == "interval" then
    if args[2] and tonumber(args[2]) then
      mgInterval = tonumber(args[2])
      AutoLFM_PrintSuccess("[MG] New interval: " .. mgInterval .. " seconds")
    else
      AutoLFM_PrintError("[MG] Usage: /mg interval <seconds>")
    end
    return
  end
  
  if args[1] == "msg" then
    if mgMessage then
      local state = mgRunning and "|cff55ff55Active|r" or "|cffff5555Inactive|r"
      AutoLFM_PrintInfo("[MG] Message: " .. mgMessage .. " | Interval: " .. mgInterval .. "s | State: " .. state)
    else
      AutoLFM_PrintError("[MG] No message defined")
    end
    return
  end
  
  if msg == "" then
    AutoLFM_PrintError("[MG] Usage: /mg <message> | /mg stop | /mg interval <sec> | /mg msg")
    return
  end
  
  if not IsInGuild() then
    AutoLFM_PrintError("[MG] You are not in a guild")
    return
  end
  
  mgMessage = msg
  mgElapsed = mgInterval
  mgRunning = true
  
  mgFrame.lastUpdate = nil
  
  mgFrame:SetScript("OnUpdate", function()
    local now = GetTime()
    if not mgFrame.lastUpdate then
      mgFrame.lastUpdate = now
      return
    end
    
    local elapsed = now - mgFrame.lastUpdate
    mgFrame.lastUpdate = now
    
    if not mgRunning then
      mgFrame:SetScript("OnUpdate", nil)
      return
    end
    
    mgElapsed = mgElapsed + elapsed
    if mgElapsed >= mgInterval then
      mgElapsed = 0
      SendChatMessage(mgMessage, "GUILD")
    end
  end)
  
  AutoLFM_PrintSuccess("[MG] Spam started every " .. mgInterval .. "s: " .. msg)
end