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
  local args = {}
  for word in string.gfind(msg, "[^ ]+") do
    table.insert(args, word)
  end
  
  if args[1] == "stop" then
    mgRunning = false
    mgFrame:SetScript("OnUpdate", nil)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[MG]|r Spam stopped.")
    return
  end
  
  if args[1] == "interval" then
    if args[2] and tonumber(args[2]) then
      mgInterval = tonumber(args[2])
      DEFAULT_CHAT_FRAME:AddMessage("|cff55ff55[MG]|r New interval: " .. mgInterval .. " seconds.")
    else
      DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[MG]|r Usage: /mg interval <seconds>")
    end
    return
  end
  
  if args[1] == "msg" then
    if mgMessage then
      local etat = mgRunning and "|cff55ff55Active|r" or "|cffff5555Inactive|r"
      DEFAULT_CHAT_FRAME:AddMessage("|cff55ff55[MG]|r Message: " .. mgMessage .. " | Interval: " .. mgInterval .. "s | State: " .. etat)
    else
      DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[MG]|r No message defined.")
    end
    return
  end
  
  if msg == "" then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[MG]|r Usage: /mg <message> | /mg stop | /mg interval <sec> | /mg msg")
    return
  end
  
  if not IsInGuild() then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[MG]|r You are not in a guild.")
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
  
  DEFAULT_CHAT_FRAME:AddMessage("|cff55ff55[MG]|r Spam started every " .. mgInterval .. "s: " .. msg)
end