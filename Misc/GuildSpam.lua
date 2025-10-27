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
    return false
  end
  
  if not IsInGuild() then
    return false
  end
  
  message = msg
  elapsed = interval
  isRunning = true
  
  if not updateFrame then
    updateFrame = CreateFrame("Frame", "AutoLFM_GuildSpamFrame")
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
  
  AutoLFM.Core.Settings.SaveMiscModuleData("guildSpam", "message", message)
  AutoLFM.Core.Settings.SaveMiscModule("guildSpam", true)
  AutoLFM.Core.Utils.PrintSuccess("Guild spam started (every " .. interval .. "s): " .. msg)
  
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
  
  AutoLFM.Core.Settings.SaveMiscModule("guildSpam", false)
  AutoLFM.Core.Utils.PrintWarning("Guild spam stopped")
end

function AutoLFM.Misc.GuildSpam.SetInterval(sec)
  local value = tonumber(sec)
  if not value or value < 30 then
    return false
  end
  
  interval = value
  
  AutoLFM.Core.Settings.SaveMiscModuleData("guildSpam", "interval", interval)
  AutoLFM.Core.Utils.PrintSuccess("New interval: " .. interval .. " seconds")
  
  return true
end

function AutoLFM.Misc.GuildSpam.GetInterval()
  return interval
end

function AutoLFM.Misc.GuildSpam.GetMessage()
  return message
end

function AutoLFM.Misc.GuildSpam.ShowStatus()
  if not message then
    AutoLFM.Core.Utils.PrintWarning("No message defined")
    return
  end
  
  local state = isRunning and AutoLFM.Color("Active", "green") or AutoLFM.Color("Inactive", "red")
  
  AutoLFM.Core.Utils.PrintInfo("Guild Spam Status:")
  AutoLFM.Core.Utils.Print("  Message: " .. AutoLFM.Color(message, "yellow"))
  AutoLFM.Core.Utils.Print("  Interval: " .. AutoLFM.Color(interval .. "s", "yellow"))
  AutoLFM.Core.Utils.Print("  State: " .. state)
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.Misc.GuildSpam.Init()
  local enabled = AutoLFM.Core.Settings.LoadMiscModule("guildSpam")
  local savedMessage = AutoLFM.Core.Settings.LoadMiscModuleData("guildSpam", "message")
  local savedInterval = AutoLFM.Core.Settings.LoadMiscModuleData("guildSpam", "interval")
  
  if savedMessage then
    message = savedMessage
  end
  
  if savedInterval then
    interval = savedInterval
  end
  
  if enabled and message and message ~= "" then
    AutoLFM.Misc.GuildSpam.Start(message)
  end
end

-----------------------------------------------------------------------------
-- Legacy Slash Command (/mg)
-----------------------------------------------------------------------------
SLASH_MG1 = "/mg"
SlashCmdList["MG"] = function(msg)
  local args = AutoLFM.Core.Utils.SplitString(" ", msg)
  
  if not args or table.getn(args) == 0 then
    AutoLFM.Core.Utils.PrintInfo("Legacy command /mg - Use /lfm misc guild instead")
    AutoLFM.Core.Utils.PrintNote("Usage: /mg <message> | /mg stop | /mg interval <sec> | /mg msg")
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
    AutoLFM.Core.Utils.PrintInfo("Legacy command /mg - Use /lfm misc guild instead")
    AutoLFM.Misc.GuildSpam.ShowStatus()
    return
  end
  
  if msg == "" then
    AutoLFM.Core.Utils.PrintInfo("Legacy command /mg - Use /lfm misc guild instead")
    AutoLFM.Core.Utils.PrintNote("Usage: /mg <message> | /mg stop | /mg interval <sec> | /mg msg")
    return
  end
  
  AutoLFM.Misc.GuildSpam.Start(msg)
end
