--=============================================================================
-- AutoLFM: RowList
--   Row hover and interaction helpers
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.UI = AutoLFM.UI or {}
AutoLFM.UI.RowList = {}

--=============================================================================
-- ROW CACHE
--   Caches row frames by prefix to avoid repeated getglobal() calls
--=============================================================================
local rowCache = {}  -- { [prefix] = { row1, row2, ... } }

--- Registers a row in the cache for faster iteration
--- @param rowPrefix string - Prefix for row names (e.g., "AutoLFM_DungeonRow")
--- @param row frame - The row frame to cache
function AutoLFM.UI.RowList.RegisterRow(rowPrefix, row)
  if not rowPrefix or not row then return end
  if not rowCache[rowPrefix] then
    rowCache[rowPrefix] = {}
  end
  table.insert(rowCache[rowPrefix], row)
end

--- Gets all cached rows for a prefix
--- @param rowPrefix string - Prefix for row names
--- @return table - Array of cached row frames (may be empty)
local function getCachedRows(rowPrefix)
  return rowCache[rowPrefix] or {}
end

--- Clears the row cache for a prefix (call when recreating rows)
--- @param rowPrefix string - Prefix for row names
function AutoLFM.UI.RowList.ClearRowCache(rowPrefix)
  if rowPrefix then
    rowCache[rowPrefix] = {}
  end
end

--=============================================================================
-- HOVER HELPERS
--   Functions for creating hover effects on list rows
--=============================================================================

--- Configures the backdrop for a row to enable hover coloring
--- @param row frame - The row frame to configure
function AutoLFM.UI.RowList.SetupRowBackdrop(row)
  if not row then
    return
  end

  row:SetBackdrop({
    bgFile = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\White",
    tile = true,
    tileSize = 8,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
  })
  -- Ensure both backdrop and border are fully transparent
  row:SetBackdropColor(0, 0, 0, 0)
  row:SetBackdropBorderColor(0, 0, 0, 0)
  row:EnableMouse(true)
end

--- Sets up hover effects on any UI element with color transitions
--- Changes element colors to white on hover, restores original color on leave
--- @param element frame - The UI element (checkbox, slider, editbox, etc.)
--- @param row frame - The parent row frame for backdrop coloring
--- @param color table - Color object with r, g, b fields
--- @param elements table - Array of elements to colorize on hover
--- @param options table - Optional {tooltipZone=string} for tooltip display
--- @return nil
function AutoLFM.UI.RowList.SetupHover(element, row, color, elements, options)
  if not element or not row then
    return
  end

  elements = elements or {}
  options = options or {}

  -- Initialize backdrop to transparent state (both color and border)
  row:SetBackdropColor(0, 0, 0, 0)
  row:SetBackdropBorderColor(0, 0, 0, 0)

  element:SetScript("OnEnter", function()
    -- Set all elements to white
    for _, elem in ipairs(elements) do
      AutoLFM.Core.Utils.SetTextColorByName(elem, "WHITE")
    end

    -- Use the provided color for hover background (or fallback to gold)
    local hoverColor = color
    if not hoverColor or type(hoverColor) ~= "table" or not hoverColor.r then
      hoverColor = AutoLFM.Core.Utils.GetColor("GOLD")
    end

    if hoverColor then
      row:SetBackdropColor(hoverColor.r, hoverColor.g, hoverColor.b, 0.3)
    end

    -- Show tooltip if provided
    if options.tooltipZone then
      local scale = UIParent:GetEffectiveScale()
      local x, y = GetCursorPosition()
      x, y = x / scale, y / scale

      GameTooltip:SetOwner(this, "ANCHOR_NONE")
      GameTooltip:ClearAllPoints()
      GameTooltip:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", x + 10, y - 10)
      local whiteColor = AutoLFM.Core.Utils.GetColor("WHITE")
      if whiteColor then
        GameTooltip:SetText(options.tooltipZone, whiteColor.r, whiteColor.g, whiteColor.b)
      else
        GameTooltip:SetText(options.tooltipZone, 1, 1, 1)
      end
      GameTooltip:Show()
    end
  end)

  element:SetScript("OnLeave", function()
    -- Restore original color for all elements
    local restoreColor = color

    -- Fallback to gold if restoreColor is invalid
    if not restoreColor or type(restoreColor) ~= "table" or not restoreColor.r then
      restoreColor = AutoLFM.Core.Utils.GetColor("GOLD")
    end

    for _, elem in ipairs(elements) do
      if elem and elem.SetTextColor then
        elem:SetTextColor(restoreColor.r, restoreColor.g, restoreColor.b)
      end
    end

    row:SetBackdropColor(0, 0, 0, 0)
    row:SetBackdropBorderColor(0, 0, 0, 0)

    -- Hide tooltip
    if options.tooltipZone then
      GameTooltip:Hide()
    end
  end)
end
  
--=============================================================================
-- CALCULATION HELPERS
--   Utility functions for scroll frame and row positioning
--=============================================================================

--- Calculates total height needed for a given number of rows
--- @param numRows number - Number of rows to display
--- @param rowHeight number - Optional height per row, defaults to ROW_HEIGHT
--- @return number - Total height in pixels
function AutoLFM.UI.RowList.CalculateScrollHeight(numRows, rowHeight)
  return numRows * (rowHeight or AutoLFM.Core.Constants.ROW_HEIGHT)
end

--- Calculates vertical offset for a row at given index
--- @param index number - Row index (1-based)
--- @param rowHeight number - Optional height per row, defaults to ROW_HEIGHT
--- @return number - Negative Y offset from top
function AutoLFM.UI.RowList.CalculateRowOffset(index, rowHeight)
  return -(index - 1) * (rowHeight or AutoLFM.Core.Constants.ROW_HEIGHT)
end

--=============================================================================
-- ROW FACTORY
--   Factory pattern for efficient row frame reuse
--=============================================================================

--- Retrieves an existing row frame or creates a new one from template
--- Reuses existing frames to minimize CreateFrame calls for performance
--- @param rowName string - Unique name for the row frame
--- @param scrollChild frame - Parent scroll child frame
--- @param template string - XML template name for row creation
--- @param index number - Row index (1-based) for positioning
--- @param rowHeight number - Height of each row in pixels
--- @return frame|nil - The configured row frame, or nil on error
function AutoLFM.UI.RowList.GetOrCreateRow(rowName, scrollChild, template, index, rowHeight)
  if not rowName or not scrollChild or not template then
    return nil
  end

  -- Extract prefix from rowName (e.g., "AutoLFM_DungeonRow1" -> "AutoLFM_DungeonRow")
  local prefix = string.gsub(rowName, "%d+$", "")

  local row = getglobal(rowName)
  local isNewRow = (row == nil)
  if not row then
    row = CreateFrame("Frame", rowName, scrollChild, template)
  end

  -- Register new rows in cache for faster iteration in hideAllRows/resetAllRowBackdrops
  if isNewRow and prefix ~= "" then
    AutoLFM.UI.RowList.RegisterRow(prefix, row)
  end

  row:ClearAllPoints()
  row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, AutoLFM.UI.RowList.CalculateRowOffset(index, rowHeight))
  AutoLFM.UI.RowList.SetupRowBackdrop(row)

  return row
end

--=============================================================================
-- FRAME HELPERS
--   Helper functions for navigating frame hierarchies
--=============================================================================

--- Retrieves the scroll child frame from a content frame
--- @param frame frame - The content frame containing a scroll frame
--- @return frame|nil - The scroll child frame, or nil if not found
function AutoLFM.UI.RowList.GetScrollChild(frame)
  if not frame then return nil end
  return getglobal(frame:GetName() .. "_ScrollFrame_ScrollChild")
end

--- Updates the scroll frame's child rectangle to reflect content size changes
--- @param scrollChild frame - The scroll child frame to update
function AutoLFM.UI.RowList.UpdateScrollFrame(scrollChild)
  if not scrollChild then return end
  local scrollFrame = scrollChild:GetParent()
  if scrollFrame and scrollFrame.UpdateScrollChildRect then
    scrollFrame:UpdateScrollChildRect()
  end
end

--- Retrieves a child element by appending suffix to parent frame's name
--- @param parent frame - The parent frame
--- @param suffix string - The suffix to append (e.g., "_Label", "_CheckButton")
--- @return frame|nil - The child element, or nil if parent is nil
function AutoLFM.UI.RowList.GetChildElement(parent, suffix)
  if not parent then return nil end
  return getglobal(parent:GetName() .. suffix)
end

--=============================================================================
-- INITIALIZATION HELPER
--   Generic OnShow handler for content frames with row lists
--=============================================================================

--- Hides all existing rows with the given prefix (private helper)
--- Uses row cache for O(n) iteration instead of O(n) getglobal calls
--- @param rowPrefix string - Prefix for row names (e.g., "AutoLFM_DungeonRow")
local function hideAllRows(rowPrefix)
  local cachedRows = getCachedRows(rowPrefix)
  if table.getn(cachedRows) > 0 then
    -- Use cached rows for faster iteration
    for i = 1, table.getn(cachedRows) do
      cachedRows[i]:Hide()
    end
  else
    -- Fallback to getglobal if cache is empty (first run)
    local index = 1
    while index <= AutoLFM.Core.Constants.MAX_ROWS_SAFETY do
      local row = getglobal(rowPrefix .. index)
      if not row then
        break
      end
      row:Hide()
      index = index + 1
    end
  end
end

--- Resets backdrop colors for all rows with the given prefix (private helper)
--- Ensures rows are transparent after DarkUI may have modified them
--- Uses row cache for O(n) iteration instead of O(n) getglobal calls
--- @param rowPrefix string - Prefix for row names (e.g., "AutoLFM_DungeonRow")
local function resetAllRowBackdrops(rowPrefix)
  local cachedRows = getCachedRows(rowPrefix)
  if table.getn(cachedRows) > 0 then
    -- Use cached rows for faster iteration
    for i = 1, table.getn(cachedRows) do
      cachedRows[i]:SetBackdropColor(0, 0, 0, 0)
      cachedRows[i]:SetBackdropBorderColor(0, 0, 0, 0)
    end
  else
    -- Fallback to getglobal if cache is empty (first run)
    local index = 1
    while index <= AutoLFM.Core.Constants.MAX_ROWS_SAFETY do
      local row = getglobal(rowPrefix .. index)
      if not row then
        break
      end
      row:SetBackdropColor(0, 0, 0, 0)
      row:SetBackdropBorderColor(0, 0, 0, 0)
      index = index + 1
    end
  end
end

--- Generic OnShow handler for content frames with row-based lists
--- Hides all existing rows, clears cache, then recreates rows from scratch
--- @param frame frame - The content frame being shown
--- @param createRowsFunc function - Function to create rows (receives scrollChild)
--- @param clearCacheFunc function - Optional cache clearing function (can be nil)
--- @param rowPrefix string - Prefix for row names (e.g., "AutoLFM_DungeonRow")
function AutoLFM.UI.RowList.OnShowHandler(frame, createRowsFunc, clearCacheFunc, rowPrefix)
  if not frame or not createRowsFunc or not rowPrefix then
    return
  end

  -- Hide all existing rows first
  hideAllRows(rowPrefix)

  -- Clear cache if function provided
  if clearCacheFunc then
    clearCacheFunc()
  end

  local scrollChild = AutoLFM.UI.RowList.GetScrollChild(frame)
  if scrollChild then
    -- Create/update rows (will reuse existing frames or create new ones)
    createRowsFunc(scrollChild)

    -- Reset row backdrops to transparent (in case DarkUI modified them)
    resetAllRowBackdrops(rowPrefix)
  end
end
