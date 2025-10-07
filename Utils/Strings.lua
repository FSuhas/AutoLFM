--------------------------------------------------
-- String Utilities
--------------------------------------------------

--------------------------------------------------
-- Get Color Hex from Key
--------------------------------------------------
local function GetColorHex(colorKey)
  if not PRIORITY_COLOR_SCHEME then return "FFFFFF" end
  
  for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
    if color.key == colorKey then
      if color.hex then
        return string.gsub(color.hex, "#", "")
      elseif color.r and color.g and color.b then
        local r = color.r or 1
        local g = color.g or 1
        local b = color.b or 1
        return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
      end
    end
  end
  
  return "FFFFFF"
end

--------------------------------------------------
-- Colorize Text
--------------------------------------------------
function ColorizeText(text, colorKey)
  if not text then return "" end
  if not colorKey then return text end
  
  local hex = GetColorHex(colorKey)
  return "|cff" .. hex .. text .. "|r"
end

--------------------------------------------------
-- Split String by Delimiter
--------------------------------------------------
function SplitString(delim, text)
  if not text or not delim then return {} end
  
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

--------------------------------------------------
-- Chat Message Printing
--------------------------------------------------
function AutoLFM_PrintMessage(message, colorKey)
  if not message then return end
  if not DEFAULT_CHAT_FRAME then return end
  
  local coloredMessage = message
  if colorKey then
    coloredMessage = ColorizeText(message, colorKey)
  end
  
  DEFAULT_CHAT_FRAME:AddMessage(CHAT_MESSAGE_PREFIX .. coloredMessage)
end

function AutoLFM_PrintSuccess(message)
  AutoLFM_PrintMessage(message, "green")
end

function AutoLFM_PrintError(message)
  AutoLFM_PrintMessage(message, "red")
end

function AutoLFM_PrintWarning(message)
  AutoLFM_PrintMessage(message, "orange")
end

function AutoLFM_PrintNote(message)
  AutoLFM_PrintMessage(message, "yellow")
end

function AutoLFM_PrintInfo(message)
  AutoLFM_PrintMessage(message, "gray")
end