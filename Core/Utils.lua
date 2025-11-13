--=============================================================================
-- AutoLFM: Utils
--   Shared utility functions for the addon
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Core = AutoLFM.Core or {}
AutoLFM.Core.Utils = {}

--=============================================================================
-- COLOR LOOKUP TABLE (PERFORMANCE OPTIMIZATION)
--=============================================================================
local COLORS_BY_NAME = {}

-- Build lookup table on load
local function BuildColorLookupTable()
  for i = 1, table.getn(AutoLFM.Core.Constants.COLORS) do
    local color = AutoLFM.Core.Constants.COLORS[i]
    COLORS_BY_NAME[color.name] = color
  end
end

--=============================================================================
-- COLOR HELPER FUNCTIONS
--=============================================================================

--- Retrieves a color object by name from the color lookup table
--- @param colorName string - The name of the color (e.g., "RED", "GREEN", "YELLOW")
--- @return table - Color object with r, g, b, hex, name fields. Returns GRAY if color not found.
function AutoLFM.Core.Utils.GetColor(colorName)
  if type(colorName) == "string" then
      local color = COLORS_BY_NAME[colorName]
      if color then return color end
  end
  -- Fallback to GRAY (index 5), not GREEN (index 1)
  return COLORS_BY_NAME["GRAY"] or AutoLFM.Core.Constants.COLORS[5]
end

--- Returns text wrapped in WoW color codes for chat display
--- @param text string - The text to colorize
--- @param colorName string - The name of the color to apply
--- @return string - Text with color codes (|cFFHEXCODE...text...|r)
function AutoLFM.Core.Utils.ColorText(text, colorName)
  if not text then return "" end
  local color = AutoLFM.Core.Utils.GetColor(colorName)
  return "|cFF" .. color.hex .. text .. "|r"
end

--- Sets text color for a UI element by color name
--- @param element frame - The UI element (FontString) to colorize
--- @param colorName string - The name of the color to apply
function AutoLFM.Core.Utils.SetTextColorByName(element, colorName)
  if not element then return end
  local color = AutoLFM.Core.Utils.GetColor(colorName)
  element:SetTextColor(color.r, color.g, color.b)
end

--- Sets vertex color for a texture by color name
--- @param texture texture - The texture object to colorize
--- @param colorName string - The name of the color to apply
--- @param alpha number - Optional alpha transparency (0.0-1.0), defaults to 1.0
function AutoLFM.Core.Utils.SetVertexColorByName(texture, colorName, alpha)
  if not texture then return end
  local color = AutoLFM.Core.Utils.GetColor(colorName)
  texture:SetVertexColor(color.r, color.g, color.b, alpha or 1)
end

--- Sets color for all checkbox textures (normal, checked, disabled) by color name
--- @param checkbox frame - The checkbox button to colorize
--- @param colorName string - The name of the color to apply
--- @param alpha number - Optional alpha transparency (0.0-1.0), defaults to 1.0
function AutoLFM.Core.Utils.SetCheckboxColorByName(checkbox, colorName, alpha)
  if not checkbox then return end
  local color = AutoLFM.Core.Utils.GetColor(colorName)
  alpha = alpha or 1

  local normalTex = checkbox:GetNormalTexture()
  local checkedTex = checkbox:GetCheckedTexture()
  local disabledCheckedTex = checkbox:GetDisabledCheckedTexture()

  if normalTex then normalTex:SetVertexColor(color.r, color.g, color.b, alpha) end
  if checkedTex then checkedTex:SetVertexColor(color.r, color.g, color.b, alpha) end
  if disabledCheckedTex then disabledCheckedTex:SetVertexColor(color.r, color.g, color.b, alpha) end
end

--=============================================================================
-- LEVEL-BASED COLOR CALCULATION
--=============================================================================

--- Determines difficulty color for content based on player level and content level range
--- Uses WoW-like color coding: RED (too hard), ORANGE (hard), YELLOW (appropriate),
--- GREEN (easy), GRAY (trivial). Thresholds scale with player level.
--- @param playerLevel number - The player's current level
--- @param minLevel number - Minimum level for the content
--- @param maxLevel number - Maximum level for the content
--- @return table - Color object (RED, ORANGE, YELLOW, GREEN, or GRAY)
function AutoLFM.Core.Utils.GetColorForLevel(playerLevel, minLevel, maxLevel)
  if not playerLevel or not minLevel or not maxLevel then
  return AutoLFM.Core.Utils.GetColor("GRAY")
  end

  if minLevel < 1 or maxLevel < 1 or minLevel > maxLevel then
  return AutoLFM.Core.Utils.GetColor("GRAY")
  end

  local thresholdIndex = math.min(math.floor(playerLevel / 10) + 1, 5)
  local greenThreshold = AutoLFM.Core.Constants.GREEN_THRESHOLDS[thresholdIndex] or 8

  local diff
  if minLevel == maxLevel then
  diff = minLevel - playerLevel
  else
  local avg = math.floor((minLevel + maxLevel) / 2)
  diff = avg - playerLevel
  end

  if diff >= 5 then return AutoLFM.Core.Utils.GetColor("RED") end
  if diff >= 3 then return AutoLFM.Core.Utils.GetColor("ORANGE") end
  if diff >= -2 then return AutoLFM.Core.Utils.GetColor("YELLOW") end
  if diff >= -greenThreshold then return AutoLFM.Core.Utils.GetColor("GREEN") end
  return AutoLFM.Core.Utils.GetColor("GRAY")
end

--=============================================================================
-- CHAT FUNCTIONS
--=============================================================================

--- Prints a message to the default chat frame with addon prefix
--- @param message string - The message to print
--- @param colorHex string|nil - Optional hex color code (without |cff prefix)
local function printToChat(message, colorHex)
  if message then
      if colorHex then
          DEFAULT_CHAT_FRAME:AddMessage(AutoLFM.Core.Constants.CHAT_PREFIX .. " |cff" .. colorHex .. message .. "|r")
      else
          DEFAULT_CHAT_FRAME:AddMessage(AutoLFM.Core.Constants.CHAT_PREFIX .. " " .. message)
      end
  end
end

--- Factory function that creates a chat print function with a specific color
--- @param colorName string|nil - Color name for the message, or nil for default
--- @return function - Function that prints messages in the specified color
local function CreatePrintFunction(colorName)
  if colorName then
      return function(message)
          local color = AutoLFM.Core.Utils.GetColor(colorName)
          printToChat(message, color and color.hex)
      end
  else
      return function(message)
          printToChat(message)
      end
  end
end

--- Prints message to chat with addon prefix
--- @param message string - The message to print
AutoLFM.Core.Utils.Print = CreatePrintFunction()

--- Prints error message to chat in red with addon prefix
--- @param message string - The error message to print
AutoLFM.Core.Utils.PrintError = CreatePrintFunction("RED")

--- Prints success message to chat in green with addon prefix
--- @param message string - The success message to print
AutoLFM.Core.Utils.PrintSuccess = CreatePrintFunction("GREEN")

--- Prints title message to chat in cyan with addon prefix
--- @param message string - The title message to print
AutoLFM.Core.Utils.PrintTitle = CreatePrintFunction("BLUE")

--- Prints info message to chat in gray with addon prefix
--- @param message string - The info message to print
AutoLFM.Core.Utils.PrintInfo = CreatePrintFunction("GRAY")

--- Prints warning message to chat in orange with addon prefix
--- @param message string - The warning message to print
AutoLFM.Core.Utils.PrintWarning = CreatePrintFunction("ORANGE")

--=============================================================================
-- DEBUG WINDOW LOGGING FUNCTIONS
--=============================================================================

--- Factory function that creates a debug log function for a specific method
--- @param methodName string - Name of the Components.Debug method to call
--- @return function - Function that logs messages to the debug window
local function CreateLogFunction(methodName)
  return function(message, id, ...)
      if AutoLFM.Components.Debug and AutoLFM.Components.Debug[methodName] then
          AutoLFM.Components.Debug[methodName](message, id, unpack(arg))
      end
  end
end

--- Logs info message to debug window (white)
--- @param message string - The info message to log
AutoLFM.Core.Utils.LogInfo = CreateLogFunction("LogInfo")

--- Logs action message to debug window (purple)
--- @param message string - The action message to log
AutoLFM.Core.Utils.LogAction = CreateLogFunction("LogAction")

--- Logs error message to debug window (red)
--- @param message string - The error message to log
AutoLFM.Core.Utils.LogError = CreateLogFunction("LogError")

--- Logs event message to debug window (green)
--- @param message string - The event message to log
AutoLFM.Core.Utils.LogEvent = CreateLogFunction("LogEvent")

--- Logs command message to debug window (blue)
--- @param message string - The command message to log
AutoLFM.Core.Utils.LogCommand = CreateLogFunction("LogCommand")

--- Logs warning message to debug window (orange)
--- @param message string - The warning message to log
AutoLFM.Core.Utils.LogWarning = CreateLogFunction("LogWarning")

--- Logs state registration to debug window (green)
--- @param message string - The state registration message to log
AutoLFM.Core.Utils.LogState = CreateLogFunction("LogState")

--- Logs initialization to debug window (yellow)
--- @param message string - The initialization message to log
AutoLFM.Core.Utils.LogInit = CreateLogFunction("LogInit")

--=============================================================================
-- TABLE UTILITIES
--=============================================================================

--- Checks if a table is nil or empty
--- @param tbl table - The table to check
--- @return boolean - True if the table is nil or empty
function AutoLFM.Core.Utils.IsEmpty(tbl)
  return not tbl or table.getn(tbl) == 0
end

--=============================================================================
-- GROUP TYPE UTILITIES
--=============================================================================

--- Determines group type based on group size
--- @param size number - The group size (1-40)
--- @return string - "solo" (size 1), "party" (2-5), or "raid" (6+)
function AutoLFM.Core.Utils.GetGroupTypeFromSize(size)
  if size > 5 then return "raid" end
  if size == 1 then return "solo" end
  return "party"
end

--=============================================================================
-- DUNGEON/RAID LOOKUP FUNCTIONS
--=============================================================================

--- Finds a dungeon's index by its name using O(1) lookup table
--- @param name string - The dungeon name to search for
--- @return number|nil - The dungeon index (1-based), or nil if not found
function AutoLFM.Core.Utils.GetDungeonIndexByName(name)
  if not name or type(name) ~= "string" then
    return nil
  end

  local dungeonInfo = AutoLFM.Core.Constants.DUNGEONS_BY_NAME[name]
  if dungeonInfo then
    return dungeonInfo.index
  end

  return nil
end

--- Finds a dungeon's name by its index
--- @param index number - The dungeon index (1-based)
--- @return string|nil - The dungeon name, or nil if index is invalid
function AutoLFM.Core.Utils.GetDungeonNameByIndex(index)
  if not index or type(index) ~= "number" then
    return nil
  end

  local dungeon = AutoLFM.Core.Constants.DUNGEONS[index]
  if dungeon then
    return dungeon.name
  end

  return nil
end

--- Finds a raid's index by its name using O(1) lookup table
--- @param name string - The raid name to search for
--- @return number|nil - The raid index (1-based), or nil if not found
function AutoLFM.Core.Utils.GetRaidIndexByName(name)
  if not name or type(name) ~= "string" then
    return nil
  end

  local raidInfo = AutoLFM.Core.Constants.RAIDS_BY_NAME[name]
  if raidInfo then
    return raidInfo.index
  end

  return nil
end

--- Finds a raid's name by its index
--- @param index number - The raid index (1-based)
--- @return string|nil - The raid name, or nil if index is invalid
function AutoLFM.Core.Utils.GetRaidNameByIndex(index)
  if not index or type(index) ~= "number" then
    return nil
  end

  local raid = AutoLFM.Core.Constants.RAIDS[index]
  if raid then
    return raid.name
  end

  return nil
end

--=============================================================================
-- TEXT UTILITIES
--=============================================================================

--- Finds the best position to break text at a word boundary
--- @param text string - The text to break
--- @param targetPos number - Target position to break at
--- @return number - Best break position
local function FindWordBreak(text, targetPos)
  if not text or targetPos <= 0 then return 0 end
  if targetPos >= string.len(text) then return string.len(text) end

  -- Look backwards from target position for a space
  for i = targetPos, 1, -1 do
    if string.sub(text, i, i) == " " then
      return i - 1
    end
  end

  -- No space found, return target position
  return targetPos
end

--- Truncates text to fit a single line using binary search
--- @param text string - The text to truncate
--- @param maxWidth number - Maximum width in pixels
--- @param fontString frame - FontString to measure text width
--- @param ellipsis string - String to append when truncated
--- @return string - Truncated text with ellipsis
local function truncateToSingleLine(text, maxWidth, fontString, ellipsis)
  fontString:SetText(ellipsis)
  local ellipsisWidth = fontString:GetStringWidth()
  local availableWidth = maxWidth - ellipsisWidth

  if availableWidth <= 0 then
    return ellipsis
  end

  local len = string.len(text)
  local left, right = 1, len
  local result = text

  -- Binary search for longest substring that fits
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

  -- Try to break at last word boundary if reasonable
  local breakPos = FindWordBreak(result, string.len(result))
  if breakPos > string.len(result) * 0.7 then
    result = string.sub(result, 1, breakPos)
  end

  -- Single line truncation always means text was truncated
  return result .. ellipsis, true
end

--- Truncates text to fit two lines using binary search
--- @param text string - The text to truncate
--- @param maxWidth number - Maximum width in pixels per line
--- @param fontString frame - FontString to measure text width
--- @param ellipsis string - String to append when truncated
--- @return string - Truncated text with newline and ellipsis
local function truncateToTwoLines(text, maxWidth, fontString, ellipsis)
  local len = string.len(text)
  local midPoint = math.floor(len / 2)

  -- Try to split text in half and see if each half fits
  local breakPos = FindWordBreak(text, midPoint)
  if breakPos == 0 then breakPos = midPoint end

  local line1 = string.sub(text, 1, breakPos)
  local line2 = string.sub(text, breakPos + 1)

  -- Trim leading space from line2
  while string.sub(line2, 1, 1) == " " do
    line2 = string.sub(line2, 2)
  end

  -- Check if both lines fit without truncation
  fontString:SetText(line1)
  local line1Width = fontString:GetStringWidth()
  fontString:SetText(line2)
  local line2Width = fontString:GetStringWidth()

  if line1Width <= maxWidth and line2Width <= maxWidth then
    -- Text fits on 2 lines without truncation
    return line1 .. "\n" .. line2, false
  end

  -- Doesn't fit on 2 lines, need to truncate
  -- Binary search for first line
  local left, right = 1, len
  local result1 = ""

  while left <= right do
    local mid = math.floor((left + right) / 2)
    local candidate = string.sub(text, 1, mid)
    fontString:SetText(candidate)
    local width = fontString:GetStringWidth()

    if width <= maxWidth then
      result1 = candidate
      left = mid + 1
    else
      right = mid - 1
    end
  end

  -- Break at word boundary if possible
  local breakPos1 = FindWordBreak(result1, string.len(result1))
  if breakPos1 > string.len(result1) * 0.7 then
    result1 = string.sub(result1, 1, breakPos1)
  end

  -- Binary search for second line with ellipsis
  local remaining = string.sub(text, string.len(result1) + 1)
  while string.sub(remaining, 1, 1) == " " do
    remaining = string.sub(remaining, 2)
  end

  fontString:SetText(ellipsis)
  local ellipsisWidth = fontString:GetStringWidth()
  local availableWidth2 = maxWidth - ellipsisWidth

  left, right = 1, string.len(remaining)
  local result2 = ""

  while left <= right do
    local mid = math.floor((left + right) / 2)
    local candidate = string.sub(remaining, 1, mid)
    fontString:SetText(candidate)
    local width = fontString:GetStringWidth()

    if width <= availableWidth2 then
      result2 = candidate
      left = mid + 1
    else
      right = mid - 1
    end
  end

  -- Break at word boundary if possible
  local breakPos2 = FindWordBreak(result2, string.len(result2))
  if breakPos2 > string.len(result2) * 0.7 then
    result2 = string.sub(result2, 1, breakPos2)
  end

  -- Text was truncated, return with ellipsis
  return result1 .. "\n" .. result2 .. ellipsis, true
end

--- Truncates text to fit within a specific pixel width using binary search
--- @param text string - The text to truncate
--- @param maxWidth number - Maximum width in pixels per line
--- @param fontString frame - FontString to measure text width
--- @param ellipsis string - String to append when truncated (default "...")
--- @param maxLines number - Maximum number of lines (1 or 2, default 2)
--- @return string, boolean - Truncated text (with newline if 2 lines) and whether it was truncated
function AutoLFM.Core.Utils.TruncateByWidth(text, maxWidth, fontString, ellipsis, maxLines)
  if not text then return "", false end
  if not fontString then return text, false end
  if not maxWidth or maxWidth <= 0 then return text, false end

  ellipsis = ellipsis or "..."
  maxLines = maxLines or 2

  -- First, check if text fits on one line
  fontString:SetText(text)
  local textWidth = fontString:GetStringWidth()

  if textWidth <= maxWidth then
    return text, false
  end

  -- Text doesn't fit on one line, try multi-line or truncate
  if maxLines == 1 then
    return truncateToSingleLine(text, maxWidth, fontString, ellipsis)
  else
    return truncateToTwoLines(text, maxWidth, fontString, ellipsis)
  end
end

--=============================================================================
-- LOOKUP TABLE BUILDERS
--=============================================================================

--- Builds dungeon and raid lookup tables for O(1) name-based access
local function BuildLookupTables()
  -- Build dungeon lookup table
  for i = 1, table.getn(AutoLFM.Core.Constants.DUNGEONS) do
    local dungeon = AutoLFM.Core.Constants.DUNGEONS[i]
    AutoLFM.Core.Constants.DUNGEONS_BY_NAME[dungeon.name] = {
      index = i,
      data = dungeon
    }
  end

  -- Build raid lookup table
  for i = 1, table.getn(AutoLFM.Core.Constants.RAIDS) do
    local raid = AutoLFM.Core.Constants.RAIDS[i]
    AutoLFM.Core.Constants.RAIDS_BY_NAME[raid.name] = {
      index = i,
      data = raid
    }
  end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

-- Build color lookup table immediately (before any other module loads)
BuildColorLookupTable()

AutoLFM.Core.SafeRegisterInit("Core.Utils", function()
  BuildLookupTables()
end, {
  id = "I03",
  dependencies = {}
})
