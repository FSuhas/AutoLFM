--=============================================================================
-- AutoLFM: Core Utilities
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Core then AutoLFM.Core = {} end
if not AutoLFM.Core.Utils then AutoLFM.Core.Utils = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.Core.Utils.CONSTANTS = {
  GROUP_SIZE_DUNGEON = 5,
  GROUP_SIZE_RAID = 10,
  TEXTURE_PATH = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\",
  CHAT_PREFIX = "|cff808080[|r|cffffffffAuto|r|cff0070ddL|r|cffffffffF|r|cffff0000M|r|cff808080]|r "
}

-----------------------------------------------------------------------------
-- String Utilities
-----------------------------------------------------------------------------
function AutoLFM.Core.Utils.SplitString(delim, text)
  if not text then return {} end
  
  local result = {}
  local start = 1
  local i = 1
  
  while true do
    local s, e = string.find(text, delim, start)
    
    if not s then
      result[i] = string.sub(text, start)
      break
    end
    
    result[i] = string.sub(text, start, s - 1)
    i = i + 1
    start = e + 1
  end
  
  return result
end

-----------------------------------------------------------------------------
-- Color Management
-----------------------------------------------------------------------------
local COLORS = {
  yellow = "ffff00",
  white = "ffffff",
  green = "40bf40",
  red = "ff0000",
  orange = "ff8040",
  gray = "808080",
  blue = "0070dd"
}

function AutoLFM.Core.Utils.ColorizeText(text, colorKey)
  if not text then return "" end
  if not colorKey then return text end
  
  local hex = COLORS[colorKey]
  if not hex then return text end
  
  return "|cff" .. hex .. text .. "|r"
end

function AutoLFM.Color(text, colorKey)
  return AutoLFM.Core.Utils.ColorizeText(text, colorKey)
end

-----------------------------------------------------------------------------
-- Chat Output
-----------------------------------------------------------------------------
function AutoLFM.Core.Utils.Print(message, colorKey)
  if not message then return end
  
  local text = AutoLFM.Core.Utils.ColorizeText(message, colorKey or "yellow")
  
  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage(AutoLFM.Core.Utils.CONSTANTS.CHAT_PREFIX .. text)
  end
end

function AutoLFM.Core.Utils.PrintInfo(message)
  AutoLFM.Core.Utils.Print(message, "white")
end

function AutoLFM.Core.Utils.PrintSuccess(message)
  AutoLFM.Core.Utils.Print(message, "green")
end

function AutoLFM.Core.Utils.PrintError(message)
  AutoLFM.Core.Utils.Print(message, "red")
end

function AutoLFM.Core.Utils.PrintWarning(message)
  AutoLFM.Core.Utils.Print(message, "orange")
end

function AutoLFM.Core.Utils.PrintNote(message)
  AutoLFM.Core.Utils.Print(message, "gray")
end

function AutoLFM.Core.Utils.PrintTitle(message)
  AutoLFM.Core.Utils.Print(message, "blue")
end