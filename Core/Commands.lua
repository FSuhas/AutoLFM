--=============================================================================
-- AutoLFM: Slash Commands
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Core then AutoLFM.Core = {} end
if not AutoLFM.Core.Commands then AutoLFM.Core.Commands = {} end

-----------------------------------------------------------------------------
-- Command Structure
-----------------------------------------------------------------------------
local COMMANDS = {
  {
    cmd = "",
    desc = "Opens AutoLFM window",
    handler = function()
      if AutoLFM_MainFrame then
        if AutoLFM_MainFrame:IsVisible() then
          HideUIPanel(AutoLFM_MainFrame)
        else
          ShowUIPanel(AutoLFM_MainFrame)
        end
      end
    end
  },
  {
    cmd = "minimap",
    desc = "Minimap button commands",
    subCommands = {
      {
        cmd = "show",
        desc = "Shows minimap button",
        handler = function()
          if not AutoLFM_MinimapButton then
            AutoLFM.Core.Utils.PrintError("Minimap button not initialized")
            return
          end
          if not AutoLFM_MinimapButton:IsShown() then
            AutoLFM_MinimapButton:Show()
            AutoLFM.Core.Settings.SaveMinimapHidden(false)
            AutoLFM.Core.Utils.PrintSuccess("Minimap button displayed")
          else
            AutoLFM.Core.Utils.PrintWarning("Minimap button already visible")
          end
        end
      },
      {
        cmd = "hide",
        desc = "Hides minimap button",
        handler = function()
          if not AutoLFM_MinimapButton then
            AutoLFM.Core.Utils.PrintError("Minimap button not initialized")
            return
          end
          if AutoLFM_MinimapButton:IsShown() then
            AutoLFM_MinimapButton:Hide()
            AutoLFM.Core.Settings.SaveMinimapHidden(true)
            AutoLFM.Core.Utils.PrintSuccess("Minimap button hidden")
          else
            AutoLFM.Core.Utils.PrintWarning("Minimap button already hidden")
          end
        end
      },
      {
        cmd = "reset",
        desc = "Resets button position",
        handler = function()
          local defaultAngle = 225
          AutoLFM.Core.Settings.SaveMinimapPos(defaultAngle)
          if AutoLFM_MinimapButton and AutoLFM.UI.MinimapButton.SetPosition then
            AutoLFM.UI.MinimapButton.SetPosition(defaultAngle)
            AutoLFM_MinimapButton:Show()
          end
          AutoLFM.Core.Utils.PrintSuccess("Minimap button position reset")
        end
      }
    }
  },
  {
    cmd = "misc",
    desc = "Misc modules management",
    subCommands = {
      {
        cmd = "status",
        desc = "Shows all modules status",
        handler = function()
          AutoLFM.Core.Utils.Print("|cff00ff00=== Misc Modules Status ===|r")
          local fpsStatus = AutoLFM.Misc.FPSDisplay.IsEnabled() and "|cff55ff55ON|r" or "|cffff5555OFF|r"
          AutoLFM.Core.Utils.Print("  FPS Display: " .. fpsStatus)
          local restedStatus = AutoLFM.Misc.RestedXP.IsEnabled() and "|cff55ff55ON|r" or "|cffff5555OFF|r"
          AutoLFM.Core.Utils.Print("  Rested XP Monitor: " .. restedStatus)
        end
      },
      {
        cmd = "fps",
        desc = "FPS Display",
        args = "[status | on | off]",
        handler = function(args)
          local action = args[3]
          if not action or action == "status" then
            local status = AutoLFM.Misc.FPSDisplay.IsEnabled() and "|cff55ff55ON|r" or "|cffff5555OFF|r"
            AutoLFM.Core.Utils.PrintInfo("FPS Display: " .. status)
          elseif action == "on" then
            AutoLFM.Misc.FPSDisplay.Enable()
            AutoLFM.Core.Utils.PrintSuccess("FPS Display enabled")
          elseif action == "off" then
            AutoLFM.Misc.FPSDisplay.Disable()
            AutoLFM.Core.Utils.PrintSuccess("FPS Display disabled")
          else
            AutoLFM.Core.Utils.PrintError("Usage: /lfm misc fps [on|off|status]")
          end
        end
      },
      {
        cmd = "rested",
        desc = "Rested XP Monitor",
        args = "[status | on | off]",
        handler = function(args)
          local action = args[3]
          if not action or action == "status" then
            local status = AutoLFM.Misc.RestedXP.IsEnabled() and "|cff55ff55ON|r" or "|cffff5555OFF|r"
            AutoLFM.Core.Utils.PrintInfo("Rested XP Monitor: " .. status)
          elseif action == "on" then
            AutoLFM.Misc.RestedXP.Enable()
            AutoLFM.Core.Utils.PrintSuccess("Rested XP Monitor enabled")
          elseif action == "off" then
            AutoLFM.Misc.RestedXP.Disable()
            AutoLFM.Core.Utils.PrintSuccess("Rested XP Monitor disabled")
          else
            AutoLFM.Core.Utils.PrintError("Usage: /lfm misc rested [on|off|status]")
          end
        end
      }
    }
  },
  {
    cmd = "api",
    desc = "API testing commands",
    subCommands = {
      {
        cmd = "status",
        desc = "Tests API availability",
        handler = function()
          if AutoLFM.API and AutoLFM.API.IsAvailable and AutoLFM.API.IsAvailable() then
            AutoLFM.Core.Utils.PrintSuccess("API available and functional")
            if AutoLFM.API.GetVersion then
              AutoLFM.Core.Utils.PrintInfo("API Version: " .. AutoLFM.API.GetVersion())
            end
          else
            AutoLFM.Core.Utils.PrintError("API not available")
          end
        end
      },
      {
        cmd = "data",
        desc = "Shows all current API data",
        handler = function()
          if AutoLFM.API and AutoLFM.API.DataPrint then
            AutoLFM.API.DataPrint()
          else
            AutoLFM.Core.Utils.PrintError("API not available")
          end
        end
      }
    }
  }
}

-----------------------------------------------------------------------------
-- Help Formatting
-----------------------------------------------------------------------------
local function FormatArgs(argsText)
  if not argsText then return "" end
  
  local result = ""
  local currentWord = ""
  
  for i = 1, string.len(argsText) do
    local char = string.sub(argsText, i, i)
    
    if char == "[" then
      result = result .. AutoLFM.Color("[ ", "gray")
    elseif char == "]" then
      if currentWord ~= "" then
        result = result .. AutoLFM.Color(currentWord, "blue")
        currentWord = ""
      end
      result = result .. AutoLFM.Color(" ]", "gray")
    elseif char == "|" then
      if currentWord ~= "" then
        result = result .. AutoLFM.Color(currentWord, "blue")
        currentWord = ""
      end
      result = result .. AutoLFM.Color(" | ", "gray")
    elseif char == "" then
      if currentWord ~= "" then
        result = result .. AutoLFM.Color(currentWord, "blue")
        currentWord = ""
      end
    else
      currentWord = currentWord .. char
    end
  end
  
  if currentWord ~= "" then
    result = result .. AutoLFM.Color(currentWord, "blue")
  end
  
  return result
end

-----------------------------------------------------------------------------
-- Help Generation
-----------------------------------------------------------------------------
local function ShowMainHelp()
  AutoLFM.Core.Utils.PrintSuccess("=== Main commands: ===")
  
  for i = 1, table.getn(COMMANDS) do
    local cmd = COMMANDS[i]
    local cmdText = "/lfm " .. (cmd.cmd ~= "" and cmd.cmd or "")
    local descText = AutoLFM.Color("- " .. cmd.desc, "white")
    
    if cmd.subCommands then
      local subCmdList = {}
      for j = 1, table.getn(cmd.subCommands) do
        table.insert(subCmdList, cmd.subCommands[j].cmd)
      end
      
      local argsText = AutoLFM.Color("[ ", "gray")
      for k = 1, table.getn(subCmdList) do
        argsText = argsText .. AutoLFM.Color(subCmdList[k], "blue")
        if k < table.getn(subCmdList) then
          argsText = argsText .. AutoLFM.Color(" | ", "gray")
        end
      end
      argsText = argsText .. AutoLFM.Color(" ]", "gray")
      
      AutoLFM.Core.Utils.Print(cmdText .. " " .. descText .. " " .. argsText)
    else
      AutoLFM.Core.Utils.Print(cmdText .. " " .. descText)
    end
  end
  
  AutoLFM.Core.Utils.PrintInfo("Use " .. AutoLFM.Color("/lfm <category> help", "yellow") .. AutoLFM.Color(" for detailed commands", "white"))
end

local function ShowCategoryHelp(category)
  AutoLFM.Core.Utils.PrintSuccess("=== " .. category.cmd .. " Commands ===")
  
  if not category.subCommands then return end
  
  for i = 1, table.getn(category.subCommands) do
    local subCmd = category.subCommands[i]
    local cmdText = "/lfm " .. category.cmd .. " " .. subCmd.cmd
    local descText = AutoLFM.Color("- " .. subCmd.desc, "white")
    
    if subCmd.args then
      AutoLFM.Core.Utils.Print(cmdText .. " " .. descText .. " " .. FormatArgs(subCmd.args))
    else
      AutoLFM.Core.Utils.Print(cmdText .. " " .. descText)
    end
  end
end

-----------------------------------------------------------------------------
-- Command Lookup
-----------------------------------------------------------------------------
local function FindCommand(cmdName)
  for i = 1, table.getn(COMMANDS) do
    if COMMANDS[i].cmd == cmdName then
      return COMMANDS[i]
    end
  end
  return nil
end

local function FindSubCommand(category, subCmdName)
  if not category.subCommands then return nil end
  
  for i = 1, table.getn(category.subCommands) do
    if category.subCommands[i].cmd == subCmdName then
      return category.subCommands[i]
    end
  end
  return nil
end

-----------------------------------------------------------------------------
-- Command Execution
-----------------------------------------------------------------------------
function AutoLFM.Core.Commands.Handle(msg)
  local success, err = pcall(function()
    if not msg then msg = "" end
    
    local args = AutoLFM.Core.Utils.SplitString(" ", msg)
    local cmdName = args[1] or ""
    local subCmdName = args[2]
    
    if cmdName == "help" then
      ShowMainHelp()
      return
    end
    
    local command = FindCommand(cmdName)
    
    if not command then
      AutoLFM.Core.Utils.PrintError("Unknown command: " .. AutoLFM.Core.Utils.ColorizeText(cmdName, "orange"))
      AutoLFM.Core.Utils.Print("Type " .. AutoLFM.Core.Utils.ColorizeText("/lfm help", "yellow") .. " for available commands")
      return
    end
    
    if command.subCommands then
      if not subCmdName or subCmdName == "help" then
        ShowCategoryHelp(command)
        return
      end
      
      local subCommand = FindSubCommand(command, subCmdName)
      if not subCommand then
        AutoLFM.Core.Utils.PrintError("Unknown sub-command: " .. AutoLFM.Core.Utils.ColorizeText(subCmdName, "orange"))
        AutoLFM.Core.Utils.Print("Type " .. AutoLFM.Core.Utils.ColorizeText("/lfm " .. cmdName .. " help", "yellow") .. " for available commands")
        return
      end
      
      if subCommand.handler then
        subCommand.handler(args)
      end
    elseif command.handler then
      command.handler(args)
    end
  end)
  
  if not success then
    AutoLFM.Core.Utils.PrintError("Command error: " .. tostring(err))
  end
end

-----------------------------------------------------------------------------
-- Registration
-----------------------------------------------------------------------------
SLASH_LFM1 = "/lfm"
SlashCmdList["LFM"] = AutoLFM.Core.Commands.Handle
