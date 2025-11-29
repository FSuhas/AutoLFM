--=============================================================================
-- AutoLFM: Slash Commands
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Core then AutoLFM.Core = {} end
if not AutoLFM.Core.Commands then AutoLFM.Core.Commands = {} end

-----------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------
local function ErrorCommandPath(...)
  local parts = {}
  for i = 1, arg.n do
    if arg[i] and arg[i] ~= "" then
      table.insert(parts, arg[i])
    end
  end
  return table.concat(parts, " ")
end

local function ShowErrorAndHelp(error, helpFunc)
  AutoLFM.Core.Utils.PrintError(error)
  helpFunc()
end

-----------------------------------------------------------------------------
-- Main Help
-----------------------------------------------------------------------------
local function ShowMainHelp()
  AutoLFM.Core.Utils.PrintTitle("=== AutoLFM Commands ===")
  AutoLFM.Core.Utils.Print("/lfm" .. AutoLFM.Color(" - Opens AutoLFM window", "white"))
  AutoLFM.Core.Utils.Print("/lfm minimap" .. AutoLFM.Color(" - Minimap button commands", "white"))
  AutoLFM.Core.Utils.Print("/lfm darkui" .. AutoLFM.Color(" - Dark mode commands", "white"))
  AutoLFM.Core.Utils.Print("/lfm misc" .. AutoLFM.Color(" - Misc modules commands", "white"))
  AutoLFM.Core.Utils.Print("/lfm api" .. AutoLFM.Color(" - API testing commands", "white"))
end

-----------------------------------------------------------------------------
-- Command Execution
-----------------------------------------------------------------------------
function AutoLFM.Core.Commands.Handle(msg)
  local args = AutoLFM.Core.Utils.SplitString(" ", msg or "")
  local cmd1 = args[1] or ""
  local cmd2 = args[2]
  local cmd3 = args[3]
  
  if cmd1 == "" then
    if AutoLFM_MainFrame then
      if AutoLFM_MainFrame:IsVisible() then
        HideUIPanel(AutoLFM_MainFrame)
      else
        ShowUIPanel(AutoLFM_MainFrame)
      end
    end
    return
  end
  
  if cmd1 == "help" then
    ShowMainHelp()
    return
  end
  
  -----------------------------------------------------------------------------
  -- MINIMAP
  -----------------------------------------------------------------------------
  if cmd1 == "minimap" then
    local function ShowMinimapHelp()
      AutoLFM.Core.Utils.PrintTitle("=== Minimap Commands ===")
      AutoLFM.Core.Utils.Print("/lfm minimap show" .. AutoLFM.Color(" - Shows minimap button", "white"))
      AutoLFM.Core.Utils.Print("/lfm minimap hide" .. AutoLFM.Color(" - Hides minimap button", "white"))
      AutoLFM.Core.Utils.Print("/lfm minimap reset" .. AutoLFM.Color(" - Resets button position", "white"))
    end
    
    local function CheckMinimapButton()
      if not AutoLFM_MinimapButton then
        AutoLFM.Core.Utils.PrintError("Minimap button not initialized")
        return false
      end
      return true
    end
    
    if not cmd2 or cmd2 == "help" then
      ShowMinimapHelp()
      
    elseif cmd2 == "show" then
      if not CheckMinimapButton() then return end
      if not AutoLFM_MinimapButton:IsShown() then
        AutoLFM_MinimapButton:Show()
        AutoLFM.Core.Settings.SaveMinimapHidden(false)
        AutoLFM.Core.Utils.PrintSuccess("Minimap button displayed")
      else
        AutoLFM.Core.Utils.PrintWarning("Minimap button already visible")
      end
      
    elseif cmd2 == "hide" then
      if not CheckMinimapButton() then return end
      if AutoLFM_MinimapButton:IsShown() then
        AutoLFM_MinimapButton:Hide()
        AutoLFM.Core.Settings.SaveMinimapHidden(true)
        AutoLFM.Core.Utils.PrintSuccess("Minimap button hidden")
      else
        AutoLFM.Core.Utils.PrintWarning("Minimap button already hidden")
      end
      
    elseif cmd2 == "reset" then
      if AutoLFM_MinimapButton and AutoLFM.UI.MinimapButton.ResetPosition then
        AutoLFM.Core.Settings.ResetMinimapPos()
        AutoLFM.UI.MinimapButton.ResetPosition()
        AutoLFM.Core.Utils.PrintSuccess("Minimap button position reset")
      else
        AutoLFM.Core.Utils.PrintError("Minimap button not initialized")
      end
      
    else
      ShowErrorAndHelp("Unknown command: " .. ErrorCommandPath(cmd1, cmd2), ShowMinimapHelp)
    end
    return
  end
  
  -----------------------------------------------------------------------------
  -- DARK
  -----------------------------------------------------------------------------
  if cmd1 == "darkui" then
    local function ShowDarkHelp()
      AutoLFM.Core.Utils.PrintTitle("=== Dark Mode Commands " .. AutoLFM.Color("( ","white") .. AutoLFM.Color("/reload","gold") .. AutoLFM.Color(" must be required)","white") .. AutoLFM.Color(" ===","blue"))
      AutoLFM.Core.Utils.Print("/lfm darkui on" .. AutoLFM.Color(" - Enables dark mode", "white"))
      AutoLFM.Core.Utils.Print("/lfm darkui off" .. AutoLFM.Color(" - Disables dark mode", "white"))
    end
    
    if not cmd2 or cmd2 == "help" then
      ShowDarkHelp()
      
    elseif cmd2 == "on" then
      if not AutoLFM.UI.DarkUI.IsEnabled() then
        AutoLFM.UI.DarkUI.Enable()
      else
        AutoLFM.Core.Utils.PrintWarning("Dark mode already enabled")
      end
      
    elseif cmd2 == "off" then
      if AutoLFM.UI.DarkUI.IsEnabled() then
        AutoLFM.UI.DarkUI.Disable()
      else
        AutoLFM.Core.Utils.PrintWarning("Dark mode already disabled")
      end
      
    else
      ShowErrorAndHelp("Unknown command: " .. ErrorCommandPath(cmd1, cmd2), ShowDarkHelp)
    end
    return
  end
  
  -----------------------------------------------------------------------------
  -- MISC
  -----------------------------------------------------------------------------
  if cmd1 == "misc" then
    local function ShowMiscHelp()
      AutoLFM.Core.Utils.PrintTitle("=== Misc Commands ===")
      AutoLFM.Core.Utils.Print("/lfm misc status" .. AutoLFM.Color(" - Shows all modules status", "white"))
      AutoLFM.Core.Utils.Print("/lfm misc fps" .. AutoLFM.Color(" - FPS Display commands", "white"))
      AutoLFM.Core.Utils.Print("/lfm misc rested" .. AutoLFM.Color(" - Rested XP Monitor commands", "white"))
      AutoLFM.Core.Utils.Print("/lfm misc autoinv" .. AutoLFM.Color(" - Auto Invite commands", "white"))
      AutoLFM.Core.Utils.Print("/lfm misc gspam" .. AutoLFM.Color(" - Guild Spam commands", "white"))
      AutoLFM.Core.Utils.Print("/lfm misc marker" .. AutoLFM.Color(" - Auto Marker commands", "white"))
    end
    
    if not cmd2 or cmd2 == "help" then
      ShowMiscHelp()
      
    elseif cmd2 == "status" then
      AutoLFM.Core.Utils.PrintTitle("=== Misc Modules Status ===")
      local fpsStatus = AutoLFM.Misc.FPSDisplay.IsEnabled() and AutoLFM.Color("ON", "green") or AutoLFM.Color("OFF", "red")
      AutoLFM.Core.Utils.Print("  FPS Display: " .. fpsStatus)
      local restedStatus = AutoLFM.Misc.RestedXP.IsEnabled() and AutoLFM.Color("ON", "green") or AutoLFM.Color("OFF", "red")
      AutoLFM.Core.Utils.Print("  Rested XP Monitor: " .. restedStatus)
      local inviteStatus = AutoLFM.Misc.AutoInvite.IsEnabled() and AutoLFM.Color("ON", "green") or AutoLFM.Color("OFF", "red")
      AutoLFM.Core.Utils.Print("  Auto Invite: " .. inviteStatus)
      local spamStatus = AutoLFM.Misc.GuildSpam.IsEnabled() and AutoLFM.Color("ON", "green") or AutoLFM.Color("OFF", "red")
      AutoLFM.Core.Utils.Print("  Guild Spam: " .. spamStatus)
      local markerStatus = AutoLFM.Misc.AutoMarker.IsEnabled() and AutoLFM.Color("ON", "green") or AutoLFM.Color("OFF", "red")
      AutoLFM.Core.Utils.Print("  Auto Marker: " .. markerStatus)
      
    -----------------------------------------------------------------------------
    -- FPS
    -----------------------------------------------------------------------------
    elseif cmd2 == "fps" then
      local function ShowFPSHelp()
        AutoLFM.Core.Utils.PrintTitle("=== FPS Display Commands ===")
        AutoLFM.Core.Utils.Print("/lfm misc fps status" .. AutoLFM.Color(" - Shows current status", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc fps on" .. AutoLFM.Color(" - Enables FPS display", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc fps off" .. AutoLFM.Color(" - Disables FPS display", "white"))
      end
      
      if not cmd3 or cmd3 == "help" then
        ShowFPSHelp()
      elseif cmd3 == "status" then
        local status = AutoLFM.Misc.FPSDisplay.IsEnabled() and AutoLFM.Color("ON", "green") or AutoLFM.Color("OFF", "red")
        AutoLFM.Core.Utils.PrintInfo("FPS Display: " .. status)
      elseif cmd3 == "on" then
        AutoLFM.Misc.FPSDisplay.Enable()
        AutoLFM.Core.Utils.PrintSuccess("FPS Display enabled")
      elseif cmd3 == "off" then
        AutoLFM.Misc.FPSDisplay.Disable()
        AutoLFM.Core.Utils.PrintSuccess("FPS Display disabled")
      else
        ShowErrorAndHelp("Unknown command: " .. ErrorCommandPath(cmd1, cmd2, cmd3), ShowFPSHelp)
      end
      
    -----------------------------------------------------------------------------
    -- RESTED
    -----------------------------------------------------------------------------
    elseif cmd2 == "rested" then
      local function ShowRestedHelp()
        AutoLFM.Core.Utils.PrintTitle("=== Rested XP Monitor Commands ===")
        AutoLFM.Core.Utils.Print("/lfm misc rested status" .. AutoLFM.Color(" - Shows current status", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc rested on" .. AutoLFM.Color(" - Enables monitoring", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc rested off" .. AutoLFM.Color(" - Disables monitoring", "white"))
      end
      
      if not cmd3 or cmd3 == "help" then
        ShowRestedHelp()
      elseif cmd3 == "status" then
        local status = AutoLFM.Misc.RestedXP.IsEnabled() and AutoLFM.Color("ON", "green") or AutoLFM.Color("OFF", "red")
        AutoLFM.Core.Utils.PrintInfo("Rested XP Monitor: " .. status)
      elseif cmd3 == "on" then
        AutoLFM.Misc.RestedXP.Enable()
        AutoLFM.Core.Utils.PrintSuccess("Rested XP Monitor enabled")
      elseif cmd3 == "off" then
        AutoLFM.Misc.RestedXP.Disable()
        AutoLFM.Core.Utils.PrintSuccess("Rested XP Monitor disabled")
      else
        ShowErrorAndHelp("Unknown command: " .. ErrorCommandPath(cmd1, cmd2, cmd3), ShowRestedHelp)
      end
      
    -----------------------------------------------------------------------------
    -- AUTOINV
    -----------------------------------------------------------------------------
    elseif cmd2 == "autoinv" then
      local function ShowAutoInvHelp()
        AutoLFM.Core.Utils.PrintTitle("=== Auto Invite Commands ===")
        AutoLFM.Core.Utils.Print("/lfm misc autoinv status" .. AutoLFM.Color(" - Shows current status", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc autoinv on" .. AutoLFM.Color(" - Enables auto invite", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc autoinv off" .. AutoLFM.Color(" - Disables auto invite", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc autoinv keyword <word>" .. AutoLFM.Color(" - Sets invite keyword", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc autoinv confirm" .. AutoLFM.Color(" - Toggles confirmation whisper", "white"))
      end
      
      if not cmd3 or cmd3 == "help" then
        ShowAutoInvHelp()
      elseif cmd3 == "status" then
        AutoLFM.Misc.AutoInvite.ShowStatus()
      elseif cmd3 == "on" then
        AutoLFM.Misc.AutoInvite.Enable()
      elseif cmd3 == "off" then
        AutoLFM.Misc.AutoInvite.Disable()
      elseif cmd3 == "keyword" then
        local keyword = args[4]
        if not keyword then
          AutoLFM.Core.Utils.PrintError("Missing argument: keyword")
          ShowAutoInvHelp()
        else
          AutoLFM.Misc.AutoInvite.SetKeyword(keyword)
        end
      elseif cmd3 == "confirm" then
        AutoLFM.Misc.AutoInvite.ToggleConfirm()
      else
        ShowErrorAndHelp("Unknown command: " .. ErrorCommandPath(cmd1, cmd2, cmd3), ShowAutoInvHelp)
      end
      
    -----------------------------------------------------------------------------
    -- GSPAM
    -----------------------------------------------------------------------------
    elseif cmd2 == "gspam" then
      local function ShowGSpamHelp()
        AutoLFM.Core.Utils.PrintTitle("=== Guild Spam Commands ===")
        AutoLFM.Core.Utils.Print("/lfm misc gspam status" .. AutoLFM.Color(" - Shows current status", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc gspam start <message>" .. AutoLFM.Color(" - Starts broadcasting", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc gspam stop" .. AutoLFM.Color(" - Stops broadcasting", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc gspam interval <seconds>" .. AutoLFM.Color(" - Sets interval", "white"))
      end
      
      if not cmd3 or cmd3 == "help" then
        ShowGSpamHelp()
      elseif cmd3 == "status" then
        AutoLFM.Misc.GuildSpam.ShowStatus()
      elseif cmd3 == "start" then
        local message = ""
        for i = 4, table.getn(args) do
          if message ~= "" then
            message = message .. " "
          end
          message = message .. args[i]
        end
        if message == "" then
          AutoLFM.Core.Utils.PrintError("Missing argument: message")
          ShowGSpamHelp()
        else
          AutoLFM.Misc.GuildSpam.Start(message)
        end
      elseif cmd3 == "stop" then
        AutoLFM.Misc.GuildSpam.Stop()
      elseif cmd3 == "interval" then
        local interval = args[4]
        if not interval then
          AutoLFM.Core.Utils.PrintError("Missing argument: seconds")
          ShowGSpamHelp()
        else
          AutoLFM.Misc.GuildSpam.SetInterval(interval)
        end
      else
        ShowErrorAndHelp("Unknown command: " .. ErrorCommandPath(cmd1, cmd2, cmd3), ShowGSpamHelp)
      end
      
    -----------------------------------------------------------------------------
    -- MARKER
    -----------------------------------------------------------------------------
    elseif cmd2 == "marker" then
      local function ShowMarkerHelp()
        AutoLFM.Core.Utils.PrintTitle("=== Auto Marker Commands ===")
        AutoLFM.Core.Utils.Print("/lfm misc marker status" .. AutoLFM.Color(" - Shows current status", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc marker on" .. AutoLFM.Color(" - Enables auto marker", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc marker off" .. AutoLFM.Color(" - Disables auto marker", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc marker add <n> <icon>" .. AutoLFM.Color(" - Tracks player (1-8)", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc marker del <n>" .. AutoLFM.Color(" - Removes player", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc marker list" .. AutoLFM.Color(" - Shows tracked players", "white"))
        AutoLFM.Core.Utils.Print("/lfm misc marker clear" .. AutoLFM.Color(" - Clears all marks", "white"))
      end
      
      if not cmd3 or cmd3 == "help" then
        ShowMarkerHelp()
      elseif cmd3 == "status" or cmd3 == "list" then
        AutoLFM.Misc.AutoMarker.ShowStatus()
      elseif cmd3 == "on" then
        AutoLFM.Misc.AutoMarker.Enable()
      elseif cmd3 == "off" then
        AutoLFM.Misc.AutoMarker.Disable()
      elseif cmd3 == "add" then
        local name = args[4]
        local icon = args[5]
        if not name or not icon then
          AutoLFM.Core.Utils.PrintError("Missing arguments: name and icon")
          ShowMarkerHelp()
        else
          AutoLFM.Misc.AutoMarker.AddPlayer(name, icon)
        end
      elseif cmd3 == "del" then
        local name = args[4]
        if not name then
          AutoLFM.Core.Utils.PrintError("Missing argument: name")
          ShowMarkerHelp()
        else
          AutoLFM.Misc.AutoMarker.RemovePlayer(name)
        end
      elseif cmd3 == "clear" then
        AutoLFM.Misc.AutoMarker.ClearAll()
      else
        ShowErrorAndHelp("Unknown command: " .. ErrorCommandPath(cmd1, cmd2, cmd3), ShowMarkerHelp)
      end
      
    else
      ShowErrorAndHelp("Unknown command: " .. ErrorCommandPath(cmd1, cmd2), ShowMiscHelp)
    end
    return
  end
  
  -----------------------------------------------------------------------------
  -- API
  -----------------------------------------------------------------------------
  if cmd1 == "api" then
    local function ShowAPIHelp()
      AutoLFM.Core.Utils.PrintTitle("=== API Commands ===")
      AutoLFM.Core.Utils.Print("/lfm api status" .. AutoLFM.Color(" - Tests API availability", "white"))
      AutoLFM.Core.Utils.Print("/lfm api debug" .. AutoLFM.Color(" - Shows detailed debug information", "white"))
      AutoLFM.Core.Utils.Print("/lfm api data" .. AutoLFM.Color(" - Shows current API data", "white"))
      AutoLFM.Core.Utils.Print("/lfm api callbacks" .. AutoLFM.Color(" - Lists registered callbacks", "white"))
    end
    
    if not cmd2 or cmd2 == "help" then
      ShowAPIHelp()
      
    elseif cmd2 == "status" then
      if AutoLFM.API and AutoLFM.API.IsAvailable and AutoLFM.API.IsAvailable() then
        AutoLFM.Core.Utils.PrintSuccess("API available and functional")
        if AutoLFM.API.GetVersion then
          AutoLFM.Core.Utils.PrintInfo("API Version: " .. AutoLFM.API.GetVersion())
        end
      else
        AutoLFM.Core.Utils.PrintError("API not available")
      end
      
    elseif cmd2 == "debug" then
      if AutoLFM.API and AutoLFM.API.DebugPrint then
        AutoLFM.API.DebugPrint()
      else
        AutoLFM.Core.Utils.PrintError("API not available")
      end
      
    elseif cmd2 == "data" then
      if not AutoLFM.API or not AutoLFM.API.IsAvailable or not AutoLFM.API.IsAvailable() then
        AutoLFM.Core.Utils.PrintError("API not available")
        return
      end
      
      local status = AutoLFM.API.GetFullStatus()
      
      AutoLFM.Core.Utils.PrintTitle("=== AutoLFM API Data ===")
      AutoLFM.Core.Utils.Print("API Version: " .. AutoLFM.Color(AutoLFM.API.GetVersion(), "yellow"))
      AutoLFM.Core.Utils.Print("Group Type: " .. AutoLFM.Color(status.groupType, "yellow"))
      AutoLFM.Core.Utils.Print("Broadcasting: " .. AutoLFM.Color(status.broadcastStats.isActive and "Yes" or "No", status.broadcastStats.isActive and "green" or "red"))
      AutoLFM.Core.Utils.Print("Players: " .. AutoLFM.Color(status.playerCount.currentInGroup .. "/" .. status.playerCount.desiredTotal, "yellow"))
      AutoLFM.Core.Utils.Print("Missing: " .. AutoLFM.Color(tostring(status.playerCount.missing), "yellow"))
      AutoLFM.Core.Utils.Print("Selected Content: " .. AutoLFM.Color(tostring(table.getn(status.selectedContent.list)), "yellow") .. " items")
      AutoLFM.Core.Utils.Print("Roles: " .. AutoLFM.Color(table.getn(status.rolesNeeded) > 0 and table.concat(status.rolesNeeded, ", ") or "none", "yellow"))
      AutoLFM.Core.Utils.Print("Channels: " .. AutoLFM.Color(table.getn(status.selectedChannels) > 0 and table.concat(status.selectedChannels, ", ") or "none", "yellow"))
      AutoLFM.Core.Utils.Print("Interval: " .. AutoLFM.Color(tostring(status.timing.intervalSeconds) .. "s", "yellow"))
      AutoLFM.Core.Utils.Print("Callbacks: " .. AutoLFM.Color(tostring(AutoLFM.API.GetCallbackCount()), "yellow"))
      
    elseif cmd2 == "callbacks" then
      if AutoLFM.API and AutoLFM.API.ListCallbacks then
        AutoLFM.API.ListCallbacks()
      else
        AutoLFM.Core.Utils.PrintError("API not available")
      end
      
    else
      ShowErrorAndHelp("Unknown command: " .. ErrorCommandPath(cmd1, cmd2), ShowAPIHelp)
    end
    return
  end
  
  -----------------------------------------------------------------------------
  -- UNKNOWN
  -----------------------------------------------------------------------------
  AutoLFM.Core.Utils.PrintError("Unknown command: " .. cmd1)
  ShowMainHelp()
end

-----------------------------------------------------------------------------
-- Registration
-----------------------------------------------------------------------------
SLASH_LFM1 = "/lfm"
SlashCmdList["LFM"] = AutoLFM.Core.Commands.Handle
