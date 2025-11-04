--=============================================================================
-- AutoLFM: Core Utilities
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Core then AutoLFM.Core = {} end
if not AutoLFM.Core.Utils then AutoLFM.Core.Utils = {} end

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

function AutoLFM.Core.Utils.TruncateByWidth(text, maxWidth, fontString, ellipsis)
  if not text then return "", false end
  if not fontString then return text, false end
  
  ellipsis = ellipsis or "..."
  
  fontString:SetText(text)
  local textWidth = fontString:GetStringWidth()
  
  if textWidth <= maxWidth then
    return text, false
  end
  
  fontString:SetText(ellipsis)
  local ellipsisWidth = fontString:GetStringWidth()
  local availableWidth = maxWidth - ellipsisWidth
  
  if availableWidth <= 0 then
    return ellipsis, true
  end
  
  local len = string.len(text)
  local left, right = 1, len
  local result = text
  
  while left <= right do
    local mid = math.floor((left + right) / 2)
    local truncated = string.sub(text, 1, mid)
    fontString:SetText(truncated)
    local width = fontString:GetStringWidth()
    
    if width <= availableWidth then
      result = truncated
      left = mid + 1
    else
      right = mid - 1
    end
  end
  
  local lastSpace = 1
  for i = string.len(result), 1, -1 do
    if string.sub(result, i, i) == " " then
      lastSpace = i
      break
    end
  end
  
  if lastSpace > 1 and lastSpace > string.len(result) * 0.7 then
    result = string.sub(result, 1, lastSpace - 1)
  end
  
  return result .. ellipsis, true
end

function AutoLFM.Core.Utils.TruncateByLength(text, maxLength, ellipsis)
  if not text then return "" end
  
  ellipsis = ellipsis or "..."
  
  if string.len(text) <= maxLength then 
    return text 
  end
  
  local truncated = string.sub(text, 1, maxLength)
  
  local lastSpace = 1
  for i = string.len(truncated), 1, -1 do
    if string.sub(truncated, i, i) == " " then
      lastSpace = i
      break
    end
  end
  
  if lastSpace > 1 and lastSpace > string.len(truncated) * 0.7 then
    truncated = string.sub(truncated, 1, lastSpace - 1)
  end
  
  return truncated .. ellipsis
end

-----------------------------------------------------------------------------
-- Color Utilities
-----------------------------------------------------------------------------
function AutoLFM.Core.Utils.RGBToHex(r, g, b)
  if not r or not g or not b then return "ff808080" end
  return string.format("ff%02x%02x%02x", 
    math.floor(r * 255), 
    math.floor(g * 255), 
    math.floor(b * 255))
end

function AutoLFM.Core.Utils.GetColorPreset(colorName)
  if not colorName then return {r = 1, g = 1, b = 1} end
  return AutoLFM.Core.Constants.COLOR_PRESETS[colorName] or {r = 1, g = 1, b = 1}
end

function AutoLFM.Core.Utils.SetFontColor(fontString, colorIdentifier)
  if not fontString then return false end
  if not colorIdentifier then return false end
  local r, g, b
  if type(colorIdentifier) == "string" then
    local color = AutoLFM.Core.Utils.GetColorPreset(colorIdentifier)
    r, g, b = color.r, color.g, color.b
  elseif type(colorIdentifier) == "number" then
    r, g, b = AutoLFM.Core.Utils.GetPriorityColor(colorIdentifier)
  elseif type(colorIdentifier) == "table" then
    r = colorIdentifier.r or 1
    g = colorIdentifier.g or 1
    b = colorIdentifier.b or 1
  else
    r, g, b = 1, 1, 1
  end
  fontString:SetTextColor(r, g, b)
  return true
end

function AutoLFM.Core.Utils.GetPriorityColor(priority)
  if not AutoLFM.Logic or not AutoLFM.Logic.Content or not AutoLFM.Logic.Content.GetColor then 
    return 1, 0.82, 0 
  end
  return AutoLFM.Logic.Content.GetColor(priority, true)
end

function AutoLFM.Core.Utils.ColorizeText(text, colorKey)
  if not text then return "" end
  if not colorKey then return text end
  
  local hex = AutoLFM.Core.Constants.CHAT_COLORS[colorKey]
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
    DEFAULT_CHAT_FRAME:AddMessage(AutoLFM.Core.Constants.CHAT_PREFIX .. text)
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
