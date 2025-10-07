--------------------------------------------------
-- Commands - Slash Commands Handler
--------------------------------------------------

--------------------------------------------------
-- Show Help
--------------------------------------------------
local function ShowHelp()
  if AutoLFM_PrintMessage then
    AutoLFM_PrintMessage("/lfm " .. ColorizeText("- Opens AutoLFM window", "gray"))
    AutoLFM_PrintMessage("/lfm help " .. ColorizeText("- Displays all available commands", "gray"))
    AutoLFM_PrintMessage("/lfm minimap show " .. ColorizeText("- Shows minimap button", "gray"))
    AutoLFM_PrintMessage("/lfm minimap hide " .. ColorizeText("- Hides minimap button", "gray"))
    AutoLFM_PrintMessage("/lfm minimap reset " .. ColorizeText("- Resets minimap button position", "gray"))
    AutoLFM_PrintMessage("/lfm api status " .. ColorizeText("- Tests API availability", "gray"))
    AutoLFM_PrintMessage("/lfm api data " .. ColorizeText("- Shows all current API data", "gray"))
  end
end

--------------------------------------------------
-- Window Command
--------------------------------------------------
local function HandleWindowCommand()
  if not AutoLFM_MainFrame then return end
  
  if AutoLFM_MainFrame:IsVisible() then
    HideUIPanel(AutoLFM_MainFrame)
  else
    ShowUIPanel(AutoLFM_MainFrame)
  end
end

--------------------------------------------------
-- Minimap Commands
--------------------------------------------------
local function HandleMinimapShow()
  if not AutoLFM_MinimapButton then
    AutoLFM_PrintError("Minimap button not initialized")
    return
  end
  
  if not AutoLFM_MinimapButton:IsShown() then
    AutoLFM_MinimapButton:Show()
    SaveMinimapVisibility(false)
    AutoLFM_PrintSuccess("Minimap button displayed")
  else
    AutoLFM_PrintWarning("Minimap button already visible")
  end
end

local function HandleMinimapHide()
  if not AutoLFM_MinimapButton then
    AutoLFM_PrintError("Minimap button not initialized")
    return
  end
  
  if AutoLFM_MinimapButton:IsShown() then
    AutoLFM_MinimapButton:Hide()
    SaveMinimapVisibility(true)
    AutoLFM_PrintSuccess("Minimap button hidden")
  else
    AutoLFM_PrintWarning("Minimap button already hidden")
  end
end

local function HandleMinimapReset()
  if not AutoLFM_SavedVariables or not characterUniqueID then
    AutoLFM_PrintError("SavedVariables not initialized")
    return
  end
  
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  
  SaveMinimapPosition(DEFAULT_MINIMAP_X, DEFAULT_MINIMAP_Y)
  
  if AutoLFM_MinimapButton then
    AutoLFM_MinimapButton:ClearAllPoints()
    AutoLFM_MinimapButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", DEFAULT_MINIMAP_X, DEFAULT_MINIMAP_Y)
    AutoLFM_MinimapButton:Show()
  end
  
  AutoLFM_PrintSuccess("Minimap button position reset")
end

--------------------------------------------------
-- API Commands
--------------------------------------------------
local function HandleAPIStatus()
  if AutoLFM_API and AutoLFM_API.IsAvailable and AutoLFM_API.IsAvailable() then
    AutoLFM_PrintSuccess("API available and functional")
    if AutoLFM_API.GetVersion then
      AutoLFM_PrintInfo("API Version: " .. AutoLFM_API.GetVersion())
    end
  else
    AutoLFM_PrintError("API not available")
  end
end

local function HandleAPIData()
  if AutoLFM_API and AutoLFM_API.DataPrint then
    AutoLFM_API.DataPrint()
  else
    AutoLFM_PrintError("API not available")
  end
end

--------------------------------------------------
-- Easter Egg Command
--------------------------------------------------
local function HandleEasterEgg()
  if HandleEasterEggCommand then
    HandleEasterEggCommand()
  else
    AutoLFM_PrintInfo("Easter egg not loaded")
  end
end

--------------------------------------------------
-- Command Router
--------------------------------------------------
local commandHandlers = {
  [""] = HandleWindowCommand,
  help = ShowHelp,
  open = HandleWindowCommand,
  minimap = {
    show = HandleMinimapShow,
    hide = HandleMinimapHide,
    reset = HandleMinimapReset
  },
  api = {
    status = HandleAPIStatus,
    data = HandleAPIData
  },
  petfoireux = HandleEasterEgg
}

--------------------------------------------------
-- Main Slash Command Handler
--------------------------------------------------
local function HandleSlashCommand(msg)
  if not msg then msg = "" end
  
  local args = SplitString(" ", msg)
  local command = args[1] or ""
  local subCommand = args[2]
  local handler = commandHandlers[command]
  
  if not handler then
    AutoLFM_PrintError("Unknown command: " .. ColorizeText(command, "orange"))
    return
  end
  
  if type(handler) == "table" then
    if not subCommand then
      AutoLFM_PrintError("Missing argument for command: " .. ColorizeText(command, "orange"))
      return
    end
    handler = handler[subCommand]
    if not handler then
      AutoLFM_PrintError("Unknown parameter: " .. ColorizeText(subCommand, "orange"))
      return
    end
  end
  
  if type(handler) == "function" then
    handler(args)
  end
end

--------------------------------------------------
-- Register Slash Commands
--------------------------------------------------
SLASH_LFM1 = "/lfm"
SlashCmdList["LFM"] = HandleSlashCommand

--------------------------------------------------
-- Slash Command: /questlist
--------------------------------------------------
SLASH_QUESTLIST1 = "/questlist"
SLASH_QUESTLIST2 = "/ql"

SlashCmdList["QUESTLIST"] = function(msg)
  if ToggleQuestList then
    ToggleQuestList()
  else
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[AutoLFM] Quest list not loaded!|r")
  end
end