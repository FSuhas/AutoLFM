--------------------------------------------------
-- Slash Commands Handler
--------------------------------------------------
local function ShowHelp()
  if AutoLFM_Print then
    AutoLFM_Print("/lfm " .. ColorText("- Opens AutoLFM window", "gray"))
    AutoLFM_Print("/lfm help " .. ColorText("- Displays all available commands", "gray"))
    AutoLFM_Print("/lfm minimap show " .. ColorText("- Shows minimap button", "gray"))
    AutoLFM_Print("/lfm minimap hide " .. ColorText("- Hides minimap button", "gray"))
    AutoLFM_Print("/lfm minimap reset " .. ColorText("- Resets minimap button position", "gray"))
    AutoLFM_Print("/lfm api status " .. ColorText("- Tests API availability", "gray"))
    AutoLFM_Print("/lfm api data " .. ColorText("- Shows all current API data", "gray"))
  end
end

--------------------------------------------------
-- Safe String Split
--------------------------------------------------
local function SafeSplit(delimiter, text)
  if not text or text == "" then
    return {}
  end
  
  local result = {}
  local start = 1
  local i = 1
  
  while true do
    local s, e = string.find(text, delimiter, start, true)
    
    if not s then
      local remaining = string.sub(text, start)
      if remaining ~= "" then
        result[i] = remaining
      end
      break
    end
    
    local part = string.sub(text, start, s - 1)
    if part ~= "" then
      result[i] = part
      i = i + 1
    end
    start = e + 1
  end
  
  return result
end

--------------------------------------------------
-- Command Handlers
--------------------------------------------------
local function HandleWindowCommand()
  if not AutoLFM then return end
  
  if AutoLFM:IsVisible() then
    HideUIPanel(AutoLFM)
  else
    ShowUIPanel(AutoLFM)
  end
end

local function SaveMinimapState(hidden)
  if AutoLFM_SavedVariables and uniqueIdentifier and AutoLFM_SavedVariables[uniqueIdentifier] then
    AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden = hidden
  end
end

local function HandleMinimapShow()
  if not AutoLFMMinimapBtn then
    AutoLFM_PrintError("Minimap button not initialized")
    return
  end
  
  if not AutoLFMMinimapBtn:IsShown() then
    AutoLFMMinimapBtn:Show()
    SaveMinimapState(false)
    AutoLFM_PrintSuccess("Minimap button displayed")
  else
    AutoLFM_PrintWarning("Minimap button already visible")
  end
end

local function HandleMinimapHide()
  if not AutoLFMMinimapBtn then
    AutoLFM_PrintError("Minimap button not initialized")
    return
  end
  
  if AutoLFMMinimapBtn:IsShown() then
    AutoLFMMinimapBtn:Hide()
    SaveMinimapState(true)
    AutoLFM_PrintSuccess("Minimap button hidden")
  else
    AutoLFM_PrintWarning("Minimap button already hidden")
  end
end

local function HandleMinimapReset()
  if not AutoLFM_SavedVariables or not uniqueIdentifier then
    AutoLFM_PrintError("SavedVariables not initialized")
    return
  end
  
  if not AutoLFM_SavedVariables[uniqueIdentifier] then
    AutoLFM_SavedVariables[uniqueIdentifier] = {}
  end
  
  AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnX = -10
  AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnY = -10
  
  if AutoLFMMinimapBtn then
    AutoLFMMinimapBtn:ClearAllPoints()
    AutoLFMMinimapBtn:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -10, -10)
    AutoLFMMinimapBtn:Show()
  end
  
  AutoLFM_PrintSuccess("Minimap button position reset")
end

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

local function HandleEasterEgg()
  if HandleEasterEggCommand then
    HandleEasterEggCommand()
  else
    AutoLFM_PrintInfo("Easter egg not loaded")
  end
end

--------------------------------------------------
-- Main Command Router
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

SLASH_LFM1 = "/lfm"

SlashCmdList["LFM"] = function(msg)
  if not msg then msg = "" end
  
  local args = SafeSplit(" ", msg)
  local command = args[1] or ""
  local subCommand = args[2]
  local handler = commandHandlers[command]
  
  if not handler then
    AutoLFM_PrintError("Unknown command: " .. ColorText(command, "orange"))
    return
  end
  
  if type(handler) == "table" then
    if not subCommand then
      AutoLFM_PrintError("Missing argument for command: " .. ColorText(command, "orange"))
      return
    end
    handler = handler[subCommand]
    if not handler then
      AutoLFM_PrintError("Unknown parameter: " .. ColorText(subCommand, "orange"))
      return
    end
  end
  
  if type(handler) == "function" then
    handler(args)
  end
end