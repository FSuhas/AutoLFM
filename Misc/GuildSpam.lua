--=============================================================================
-- AutoLFM: Guild Spam
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Misc then AutoLFM.Misc = {} end
if not AutoLFM.Misc.GuildSpam then AutoLFM.Misc.GuildSpam = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local message = nil
local interval = 60
local elapsed = 0
local isRunning = false
local updateFrame = nil

-----------------------------------------------------------------------------
-- Spam Control
-----------------------------------------------------------------------------
function AutoLFM.Misc.GuildSpam.Start(msg)
  if not msg or msg == "" then
    if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintError then
      AutoLFM.Core.Utils.PrintError("[MG] Message cannot be empty")
    end
    return false
  end
  
  if not IsInGuild() then
    if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintError then
      AutoLFM.Core.Utils.PrintError("[MG] You are not in a guild")
    end
    return false
  end
  
  message = msg
  elapsed = interval
  isRunning = true
  
  if not updateFrame then
    updateFrame = CreateFrame("Frame", "MGSpamFrame")
  end
  
  updateFrame.lastUpdate = nil
  
  updateFrame:SetScript("OnUpdate", function()
    local now = GetTime()
    if not updateFrame.lastUpdate then
      updateFrame.lastUpdate = now
      return
    end
    
    local dt = now - updateFrame.lastUpdate
    updateFrame.lastUpdate = now
    
    if not isRunning then
      updateFrame:SetScript("OnUpdate", nil)
      return
    end
    
    elapsed = elapsed + dt
    if elapsed >= interval then
      elapsed = 0
      SendChatMessage(message, "GUILD")
    end
  end)
  
  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintSuccess then
    AutoLFM.Core.Utils.PrintSuccess("[MG] Spam started every " .. interval .. "s: " .. msg)
  end
  
  return true
end

function AutoLFM.Misc.GuildSpam.IsEnabled()
  return isRunning
end

function AutoLFM.Misc.GuildSpam.Stop()
  isRunning = false
  if updateFrame then
    updateFrame:SetScript("OnUpdate", nil)
  end
  
  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintError then
    AutoLFM.Core.Utils.PrintError("[MG] Spam stopped")
  end
end

function AutoLFM.Misc.GuildSpam.SetInterval(sec)
  local value = tonumber(sec)
  if not value then
    if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintError then
      AutoLFM.Core.Utils.PrintError("[MG] Usage: /mg interval <seconds>")
    end
    return false
  end
  
  interval = value
  
  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintSuccess then
    AutoLFM.Core.Utils.PrintSuccess("[MG] New interval: " .. interval .. " seconds")
  end
  
  return true
end

function AutoLFM.Misc.GuildSpam.ShowStatus()
  if not message then
    if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintError then
      AutoLFM.Core.Utils.PrintError("[MG] No message defined")
    end
    return
  end
  
  local state = isRunning and "|cff55ff55Active|r" or "|cffff5555Inactive|r"
  
  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintInfo then
    AutoLFM.Core.Utils.PrintInfo("[MG] Message: " .. message .. " | Interval: " .. interval .. "s | State: " .. state)
  end
end

-----------------------------------------------------------------------------
-- Slash Command Handler
-----------------------------------------------------------------------------
SLASH_MG1 = "/mg"
SlashCmdList["MG"] = function(msg)
  local args = AutoLFM.Core.Utils.SplitString(" ", msg)
  
  if not args or table.getn(args) == 0 then
    if AutoLFM.Core.Utils and AutoLFM.Core.Utils.Print then
      AutoLFM.Core.Utils.Print("[MG] Usage: /mg <message> | /mg stop | /mg interval <sec> | /mg msg")
    end
    return
  end
  
  if args[1] == "stop" then
    AutoLFM.Misc.GuildSpam.Stop()
    return
  end
  
  if args[1] == "interval" then
    AutoLFM.Misc.GuildSpam.SetInterval(args[2])
    return
  end
  
  if args[1] == "msg" then
    AutoLFM.Misc.GuildSpam.ShowStatus()
    return
  end
  
  if msg == "" then
    if AutoLFM.Core.Utils and AutoLFM.Core.Utils.Print then
      AutoLFM.Core.Utils.Print("[MG] Usage: /mg <message> | /mg stop | /mg interval <sec> | /mg msg")
    end
    return
  end
  
  AutoLFM.Misc.GuildSpam.Start(msg)
end
