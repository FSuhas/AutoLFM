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
-- Command Handlers
--------------------------------------------------
local function HandleWindowCommand()
  if AutoLFM then
    if AutoLFM:IsVisible() then
      HideUIPanel(AutoLFM)
    else
      ShowUIPanel(AutoLFM)
    end
  end
end

local function HandleMinimapCommand(args)
  if args[2] == "show" then
    if AutoLFMMinimapBtn and not AutoLFMMinimapBtn:IsShown() then
      AutoLFMMinimapBtn:Show()
      AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden = false
      AutoLFM_PrintSuccess("Minimap button displayed")
    else
      AutoLFM_PrintError("Minimap button already visible")
    end
    return
  end
  
  if args[2] == "hide" then
    if AutoLFMMinimapBtn and AutoLFMMinimapBtn:IsShown() then
      AutoLFMMinimapBtn:Hide()
      AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden = true
      AutoLFM_PrintSuccess("Minimap button hidden")
    else
      AutoLFM_PrintError("Minimap button already hidden")
    end
    return
  end
  
  if args[2] == "reset" then
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
  
  AutoLFM_PrintError("Unknown command")
  ShowHelp()
end

local function HandleAPICommand(args)
  if args[2] == "status" then
    if AutoLFM_API and AutoLFM_API.IsAvailable and AutoLFM_API.IsAvailable() then
      AutoLFM_PrintSuccess("API available and functional")
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
  
  AutoLFM_PrintError("Unknown command")
  ShowHelp()
end

--------------------------------------------------
-- Main Command Router
--------------------------------------------------
SLASH_LFM1 = "/lfm"

SlashCmdList["LFM"] = function(msg)
  local args = strsplit(" ", msg)
  
  if not args[1] or args[1] == "help" then
    ShowHelp()
    return
  end
  
  if args[1] == "" or args[1] == "open" then
    HandleWindowCommand()
    return
  end
  
  if args[1] == "minimap" then
    HandleMinimapCommand(args)
    return
  end
  
  if args[1] == "api" then
    HandleAPICommand(args)
    return
  end
  
  if args[1] == "petfoireux" then
    if HandleEasterEggCommand then
      HandleEasterEggCommand()
    end
    return
  end
  
  AutoLFM_PrintError("Unknown command")
  ShowHelp()
end