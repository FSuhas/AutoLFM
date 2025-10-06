--------------------------------------------------
-- Slash Commands Handler
--------------------------------------------------
local function ShowHelp()
  AutoLFM_PrintWarning("Available commands:")
  AutoLFM_PrintInfo("|cff00FFFF  /lfm |cffffffff- Opens AutoLFM window")
  AutoLFM_PrintInfo("|cff00FFFF  /lfm help |cffffffff- Displays all available commands")
  AutoLFM_PrintInfo("|cff00FFFF  /lfm minimap show |cffffffff- Shows minimap button")
  AutoLFM_PrintInfo("|cff00FFFF  /lfm minimap hide |cffffffff- Hides minimap button")
  AutoLFM_PrintInfo("|cff00FFFF  /lfm minimap reset |cffffffff- Resets minimap button position")
  AutoLFM_PrintInfo("|cff00FFFF  /lfm api status |cffffffff- Tests API availability")
  AutoLFM_PrintInfo("|cff00FFFF  /lfm api debug |cffffffff- Shows all current API data")
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

local function HandleMinimapCommand(args)
  if not args or not args[2] then
    AutoLFM_PrintError("Missing parameter. Use: /lfm minimap [show|hide|reset]")
    return
  end
  
  if args[2] == "show" then
    if not AutoLFMMinimapBtn then
      AutoLFM_PrintError("Minimap button not initialized")
      return
    end
    
    if not AutoLFMMinimapBtn:IsShown() then
      AutoLFMMinimapBtn:Show()
      if AutoLFM_SavedVariables and uniqueIdentifier and AutoLFM_SavedVariables[uniqueIdentifier] then
        AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden = false
      end
      AutoLFM_PrintSuccess("Minimap button displayed")
    else
      AutoLFM_PrintError("Minimap button already visible")
    end
    return
  end
  
  if args[2] == "hide" then
    if not AutoLFMMinimapBtn then
      AutoLFM_PrintError("Minimap button not initialized")
      return
    end
    
    if AutoLFMMinimapBtn:IsShown() then
      AutoLFMMinimapBtn:Hide()
      if AutoLFM_SavedVariables and uniqueIdentifier and AutoLFM_SavedVariables[uniqueIdentifier] then
        AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden = true
      end
      AutoLFM_PrintSuccess("Minimap button hidden")
    else
      AutoLFM_PrintError("Minimap button already hidden")
    end
    return
  end
  
  if args[2] == "reset" then
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
    return
  end
  
  AutoLFM_PrintError("Unknown parameter: " .. args[2])
  AutoLFM_PrintInfo("Use: /lfm minimap [show|hide|reset]")
end

local function HandleAPICommand(args)
  if not args or not args[2] then
    AutoLFM_PrintError("Missing parameter. Use: /lfm api [status|debug]")
    return
  end
  
  if args[2] == "status" then
    if AutoLFM_API and AutoLFM_API.IsAvailable and AutoLFM_API.IsAvailable() then
      AutoLFM_PrintSuccess("API available and functional")
      if AutoLFM_API.GetVersion then
        AutoLFM_PrintInfo("API Version: " .. AutoLFM_API.GetVersion())
      end
    else
      AutoLFM_PrintError("API not available")
    end
    return
  end
  
  if args[2] == "debug" then
    if AutoLFM_API and AutoLFM_API.DebugPrint then
      AutoLFM_API.DebugPrint()
    else
      AutoLFM_PrintError("API not available")
    end
    return
  end
  
  AutoLFM_PrintError("Unknown parameter: " .. args[2])
  AutoLFM_PrintInfo("Use: /lfm api [status|debug]")
end

--------------------------------------------------
-- Main Command Router
--------------------------------------------------
SLASH_LFM1 = "/lfm"

SlashCmdList["LFM"] = function(msg)
  if not msg then msg = "" end
  
  local args = SafeSplit(" ", msg)
  
  -- Empty command or help
  if not args[1] or args[1] == "" then
    HandleWindowCommand()
    return
  end
  
  if args[1] == "help" then
    ShowHelp()
    return
  end
  
  if args[1] == "open" then
    HandleWindowCommand()
    return
  end
  
  -- Minimap commands (require parameter)
  if args[1] == "minimap" then
    if not args[2] then
      AutoLFM_PrintError("Unknown command: minimap")
      ShowHelp()
      return
    end
    HandleMinimapCommand(args)
    return
  end
  
  -- API commands (require parameter)
  if args[1] == "api" then
    if not args[2] then
      AutoLFM_PrintError("Unknown command: api")
      ShowHelp()
      return
    end
    HandleAPICommand(args)
    return
  end
  
  if args[1] == "petfoireux" then
    if HandleEasterEggCommand then
      HandleEasterEggCommand()
    else
      AutoLFM_PrintInfo("Easter egg not loaded")
    end
    return
  end
  
  AutoLFM_PrintError("Unknown command: " .. args[1])
  ShowHelp()
end