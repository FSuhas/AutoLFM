--=============================================================================
-- AutoLFM: Debug Window Component
--   Real-time debug console with action logging
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.Components = AutoLFM.Components or {}
AutoLFM.Components.Debug = {}

--=============================================================================
-- CONSTANTS
--=============================================================================

local DEBUG_WINDOW_WIDTH = 600
local DEBUG_WINDOW_HEIGHT = 400
local DEBUG_LINE_HEIGHT = 14
local DEBUG_BUTTON_HEIGHT = 22
local DEBUG_BUTTON_WIDTH = 80
local SCROLL_BAR_WIDTH = 20

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local debugFrame, scrollFrame, editBox
local logBuffer = {}
local isEnabled = false
local currentViewMode = "monitoring"
local stateBtn, registryBtn

--=============================================================================
-- HELPER FUNCTIONS
--=============================================================================

--- Returns current time as HH:MM:SS timestamp
--- @return string - Formatted time string
local function getTimestamp()
  return date("%H:%M:%S")
end

--- Retrieves color object for a debug category
--- @param category string - Debug category (e.g., "ACTION", "INFO", "WARNING", "ERROR")
--- @return table - Color object with r, g, b, hex fields
local function getColorByDebugCategory(category)
  for i = 1, table.getn(AutoLFM.Core.Constants.COLORS) do
      if AutoLFM.Core.Constants.COLORS[i].debugCategory == category then
          return AutoLFM.Core.Constants.COLORS[i]
      end
  end
  -- Default to WHITE for unknown categories
  return AutoLFM.Core.Utils.GetColor("WHITE")
end

--- Formats a log line with colored timestamp and category
--- @param category string - Debug category (e.g., "ACTION", "INFO", "WARNING", "ERROR")
--- @param message string - Log message content
--- @return string - Formatted log line with WoW color codes
local function formatLogLine(category, message)
  local timestampColor = getColorByDebugCategory("TIMESTAMP")
  local categoryColor = getColorByDebugCategory(category)

  if not timestampColor or not categoryColor then
      return "[" .. getTimestamp() .. "] [" .. category .. "] " .. message
  end

  local timestamp = "|cff" .. timestampColor.hex .. "[" .. getTimestamp() .. "]|r"
  local coloredCategory = "|cff" .. categoryColor.hex .. "[" .. category .. "]|r"

  return timestamp .. " " .. coloredCategory .. " " .. message
end

--- Adds a log line to the buffer (max DEBUG_BUFFER_MAX_LINES lines)
--- @param line string - Formatted log line to add
local function addToBuffer(line)
  table.insert(logBuffer, line)

  -- Keep only last N lines to prevent memory bloat
  local maxLines = AutoLFM.Core.Constants.DEBUG_BUFFER_MAX_LINES or 500
  if table.getn(logBuffer) > maxLines then
    table.remove(logBuffer, 1)
  end
end

--- Removes WoW color codes from a string for display in EditBox
--- @param text string - Text with WoW color codes
--- @return string - Text without color codes
local function stripColorCodes(text)
  if not text then return "" end
  -- Remove |cff##### format (color codes)
  text = string.gsub(text, "|cff%x%x%x%x%x%x", "")
  -- Remove |r format (color reset)
  text = string.gsub(text, "|r", "")
  return text
end

--- Updates button styling based on current view mode
--- Buttons remain unstyled, content display shows the mode
local function updateButtonStyling()
  -- Buttons are simple text buttons with no special styling
  -- The view mode only affects the content display, not button appearance
end

--- Updates the debug window display with current buffer contents
--- Dynamically resizes scroll frame based on content
--- Auto-scrolls to bottom when new logs are added
local function updateDisplay()
  if not debugFrame or not debugFrame:IsVisible() then
      return
  end

  if not scrollFrame or not editBox then
      return
  end

  -- Set text content (keep color codes for EditBox)
  local text = table.concat(logBuffer, "\n")
  editBox:SetText(text)

  -- Calculate content height based on line count
  local lineCount = table.getn(logBuffer)
  if lineCount == 0 then
    lineCount = 1
  end

  -- Set EditBox dimensions to match content
  -- Width: scrollFrame width minus a margin
  local scrollWidth = scrollFrame:GetWidth()
  editBox:SetWidth(scrollWidth - 5)

  -- Height: line count * line height
  local contentHeight = lineCount * DEBUG_LINE_HEIGHT
  editBox:SetHeight(contentHeight)

  -- Update scroll frame to track new child rect
  scrollFrame:UpdateScrollChildRect()

  -- Scroll to bottom: set vertical scroll to the maximum possible value
  local maxScroll = editBox:GetHeight() - scrollFrame:GetHeight()
  if maxScroll > 0 then
    scrollFrame:SetVerticalScroll(maxScroll)
  else
    scrollFrame:SetVerticalScroll(0)
  end
end

--=============================================================================
-- GENERIC LOGGING FUNCTION
--=============================================================================

--- Generic logging function that formats and adds messages to the debug buffer
--- Supports variable arguments that are appended to message in parentheses
--- @param category string - Debug category (e.g., "ACTION", "INFO", "WARNING", "ERROR", "EVENT")
--- @param message string - Log message text
--- @param ... any - Optional additional arguments to append to message
local function log(category, message, ...)
  -- Format message with arguments if provided
  local formattedMessage = message
  if arg.n > 0 then
      local argsList = {}
      for i = 1, arg.n do
          table.insert(argsList, tostring(arg[i]))
      end
      formattedMessage = message .. " (" .. table.concat(argsList, ", ") .. ")"
  end

  local line = formatLogLine(category, formattedMessage)
  addToBuffer(line)

  -- Always update display if window is visible, don't wait for isEnabled
  if debugFrame and debugFrame:IsVisible() then
      updateDisplay()
  end
end

--=============================================================================
-- PUBLIC LOGGING API
--=============================================================================

--- Logs an event message to the debug window (green)
--- @param eventName string - The event name to log
--- @param id string - Optional ID (e.g., "E01")
--- @param ... any - Optional arguments to append to the log message
function AutoLFM.Components.Debug.LogEvent(eventName, id, ...)
  local message = eventName
  if id and AutoLFM.Core.Utils and AutoLFM.Core.Utils.ColorText then
    local idColored = AutoLFM.Core.Utils.ColorText("[" .. id .. "]", "GRAY")
    message = idColored .. " " .. eventName
  elseif id then
    message = "[" .. id .. "] " .. eventName
  end

  -- Pass arguments to log function if provided
  if arg.n > 0 then
    log("EVENT", message, unpack(arg))
  else
    log("EVENT", message)
  end
end

--- Logs a command message to the debug window (blue)
--- @param commandName string - The command name to log
--- @param id string - Optional ID (e.g., "C01")
--- @param ... any - Optional arguments to append to the log message
function AutoLFM.Components.Debug.LogCommand(commandName, id, ...)
  local message = commandName
  if id and AutoLFM.Core.Utils and AutoLFM.Core.Utils.ColorText then
    local idColored = AutoLFM.Core.Utils.ColorText("[" .. id .. "]", "GRAY")
    message = idColored .. " " .. commandName
  elseif id then
    message = "[" .. id .. "] " .. commandName
  end

  -- Pass arguments to log function if provided
  if arg.n > 0 then
    log("COMMAND", message, unpack(arg))
  else
    log("COMMAND", message)
  end
end

--- Logs an error message to the debug window (red)
--- @param message string - The error message to log
function AutoLFM.Components.Debug.LogError(message)
  log("ERROR", message)
end

--- Logs a warning message to the debug window (orange)
--- @param message string - The warning message to log
function AutoLFM.Components.Debug.LogWarning(message)
  log("WARNING", message)
end

--- Logs an info message to the debug window (white)
--- @param message string - The info message to log
function AutoLFM.Components.Debug.LogInfo(message)
  log("INFO", message)
end

--- Logs an action message to the debug window (purple)
--- @param message string - The action message to log
function AutoLFM.Components.Debug.LogAction(message)
  log("ACTION", message)
end

--- Logs a registry message to the debug window
--- @param message string - The registry message to log
function AutoLFM.Components.Debug.LogRegistry(message)
  log("REGISTRY", message)
end

--- Logs a state message to the debug window
--- @param message string - The state message to log
function AutoLFM.Components.Debug.LogState(message)
  log("STATE", message)
end

--- Logs an initialization message to the debug window
--- @param message string - The initialization message to log
function AutoLFM.Components.Debug.LogInit(message)
  log("INIT", message)
end

--=============================================================================
-- WINDOW MANAGEMENT
--=============================================================================

--- Hides the debug window
function AutoLFM.Components.Debug.Hide()
  if debugFrame then
      debugFrame:Hide()
      isEnabled = false
      AutoLFM.Components.Debug.LogAction("Hide Debug Window")

      -- Sync the Settings checkbox
      AutoLFM.Components.Debug.SyncSettingsCheckbox(false)
  end
end

--- Shows the debug window (creates it if it doesn't exist)
function AutoLFM.Components.Debug.Show()
  if not debugFrame then
      AutoLFM.Components.Debug.CreateFrame()
  end

  if not debugFrame then
      return
  end

  debugFrame:Show()
  isEnabled = true
  updateDisplay()

  AutoLFM.Components.Debug.LogAction("Show Debug Window")

  -- Sync the Settings checkbox
  AutoLFM.Components.Debug.SyncSettingsCheckbox(true)
end

--- Toggles debug window visibility (show/hide)
function AutoLFM.Components.Debug.Toggle()
  if debugFrame and debugFrame:IsVisible() then
      AutoLFM.Components.Debug.Hide()
  else
      AutoLFM.Components.Debug.Show()
  end
end

--- Syncs the debug checkbox state in the Settings panel
--- @param isChecked boolean - True to check the checkbox, false to uncheck
function AutoLFM.Components.Debug.SyncSettingsCheckbox(isChecked)
  local optionsPanel = getglobal("AutoLFM_Content_Settings")
  if not optionsPanel then return end

  local scrollChild = getglobal(optionsPanel:GetName().."_ScrollFrame_ScrollChild")
  if not scrollChild then return end

  local debugCheckbox = getglobal(scrollChild:GetName().."_Debug")
  if debugCheckbox then
      debugCheckbox:SetChecked(isChecked and 1 or nil)
  end
end

--- Clears all messages from the debug window
function AutoLFM.Components.Debug.Clear()
  -- Clear buffer
  logBuffer = {}

  if not scrollFrame or not editBox then
      return
  end

  -- Clear text
  editBox:SetText("")

  -- Reset to minimum height
  editBox:SetHeight(scrollFrame:GetHeight())

  -- Reset scroll position to top
  scrollFrame:SetVerticalScroll(0)
  scrollFrame:SetHorizontalScroll(0)

  -- Update scroll child rect
  scrollFrame:UpdateScrollChildRect()

  -- Clear focus
  editBox:ClearFocus()
end

--- Toggles registry view on/off (tab mode)
--- If already showing registry, returns to monitoring
--- If in different mode, switches to registry
function AutoLFM.Components.Debug.ShowRegistry()
  if currentViewMode == "registry" then
    -- Already showing registry - toggle back to monitoring
    currentViewMode = "monitoring"
    updateButtonStyling()
    if debugFrame and debugFrame:IsVisible() then
        updateDisplay()
    end
    return
  end

  -- Clear previous content and populate with registry
  logBuffer = {}
  currentViewMode = "registry"

  local titleColor = AutoLFM.Core.Utils.GetColor("WHITE")
  local commandColor = AutoLFM.Core.Utils.GetColor("BLUE")
  local eventColor = AutoLFM.Core.Utils.GetColor("CYAN")
  local listenerColor = AutoLFM.Core.Utils.GetColor("MAGENTA")
  local initColor = AutoLFM.Core.Utils.GetColor("PURPLE")

  AutoLFM.Components.Debug.LogInfo("|cff" .. titleColor.hex .. "=== MAESTRO REGISTRY ===|r")

  local commands, events, listeners, handlers = AutoLFM.Core.Maestro.GetRegistry()

  -- Commands Section (BLUE)
  table.sort(commands, function(a, b)
      return a.id < b.id
  end)

  AutoLFM.Components.Debug.LogRegistry("|cff" .. commandColor.hex .. "COMMANDS (" .. table.getn(commands) .. " registered):|r")
  for i = 1, table.getn(commands) do
      local entry = commands[i]
      AutoLFM.Components.Debug.LogRegistry("|cff888888[" .. entry.id .. "]|r |cffffaa00" .. entry.key .. "|r")
  end

  -- Events Section (CYAN)
  table.sort(events, function(a, b)
      return a.id < b.id
  end)

  AutoLFM.Components.Debug.LogRegistry("|cff" .. eventColor.hex .. "EVENTS (" .. table.getn(events) .. " registered):|r")
  for i = 1, table.getn(events) do
      local entry = events[i]
      AutoLFM.Components.Debug.LogRegistry("|cff888888[" .. entry.id .. "]|r |cffffaa00" .. entry.key .. "|r")
  end

  -- Listeners Section (MAGENTA)
  table.sort(listeners, function(a, b)
      return a.id < b.id
  end)

  AutoLFM.Components.Debug.LogRegistry("|cff" .. listenerColor.hex .. "LISTENERS (" .. table.getn(listeners) .. " registered):|r")
  for i = 1, table.getn(listeners) do
      local entry = listeners[i]
      AutoLFM.Components.Debug.LogRegistry("|cff888888[" .. entry.id .. "]|r |cffffaa00" .. entry.key .. "|r")
  end

  -- Init Handlers Section (PURPLE)
  table.sort(handlers, function(a, b)
      return a.id < b.id
  end)

  AutoLFM.Components.Debug.LogRegistry("|cff" .. initColor.hex .. "INIT HANDLERS (" .. table.getn(handlers) .. " registered):|r")
  for i = 1, table.getn(handlers) do
      local entry = handlers[i]
      AutoLFM.Components.Debug.LogRegistry("|cff888888[" .. entry.id .. "]|r |cffffaa00" .. entry.key .. "|r")
  end

  updateButtonStyling()
  if debugFrame and debugFrame:IsVisible() then
      updateDisplay()
  end
end

--- Toggles state view on/off (tab mode)
--- If already showing state, returns to monitoring
--- If in different mode, switches to state
function AutoLFM.Components.Debug.ShowState()
  if currentViewMode == "state" then
    -- Already showing state - toggle back to monitoring
    currentViewMode = "monitoring"
    updateButtonStyling()
    if debugFrame and debugFrame:IsVisible() then
        updateDisplay()
    end
    return
  end

  -- Clear previous content and populate with state
  logBuffer = {}
  currentViewMode = "state"

  local titleColor = AutoLFM.Core.Utils.GetColor("WHITE")
  local stateColor = AutoLFM.Core.Utils.GetColor("GREEN")

  AutoLFM.Components.Debug.LogInfo("|cff" .. titleColor.hex .. "=== MAESTRO STATE ===|r")

  -- Get all registered states from Maestro
  local states = AutoLFM.Core.Maestro.GetAllStates()

  -- Sort by ID (S01, S02, S03...)
  local sortedKeys = {}
  for key in pairs(states) do
    table.insert(sortedKeys, key)
  end

  table.sort(sortedKeys, function(a, b)
    local idA = states[a].id or "S99"
    local idB = states[b].id or "S99"
    return idA < idB
  end)

  local hasState = false
  for i = 1, table.getn(sortedKeys) do
    local key = sortedKeys[i]
    local stateData = states[key]
    hasState = true

    local value = stateData.value
    local id = stateData.id or "S??"

    local valueStr = tostring(value)
    if type(value) == "table" then
      -- Show table contents
      local count = 0
      for _ in pairs(value) do
        count = count + 1
      end
      valueStr = "{table: " .. count .. " items}"

      -- Show first few items if it's an array
      if count > 0 and count <= 5 then
        local items = {}
        for k, v in pairs(value) do
          if type(k) == "number" then
            table.insert(items, tostring(v))
          end
        end
        if table.getn(items) > 0 then
          valueStr = "{" .. table.concat(items, ", ") .. "}"
        end
      end
    elseif type(value) == "boolean" then
      valueStr = value and "true" or "false"
    elseif type(value) == "nil" then
      valueStr = "nil"
    end

    AutoLFM.Components.Debug.LogState("|cff888888[" .. id .. "]|r |cffffaa00" .. key .. "|r: " .. valueStr)
  end

  if not hasState then
    AutoLFM.Components.Debug.LogState("|cff888888(No states registered)|r")
  end

  updateButtonStyling()
  if debugFrame and debugFrame:IsVisible() then
      updateDisplay()
  end
end

--=============================================================================
-- FRAME CREATION (PURE LUA)
--=============================================================================

--- Creates the debug window frame entirely in Lua (no XML)
function AutoLFM.Components.Debug.CreateFrame()
  if debugFrame then
      return
  end

  -- Main window frame (simple frame, no template)
  debugFrame = CreateFrame("Frame", "AutoLFM_DebugWindow", UIParent)
  debugFrame:SetWidth(DEBUG_WINDOW_WIDTH)
  debugFrame:SetHeight(DEBUG_WINDOW_HEIGHT)
  debugFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  debugFrame:EnableMouse(true)
  debugFrame:SetMovable(true)
  debugFrame:SetClampedToScreen(true)
  debugFrame:SetFrameStrata("DIALOG")
  debugFrame:Hide()

  -- Add backdrop (dialog box style)
  debugFrame:SetBackdrop({
    bgFile = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\DialogBoxBackground",
    edgeFile = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\DialogBoxBorder",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
  })
  debugFrame:SetBackdropColor(0, 0, 0, 0.8)

  -- Title
  local title = debugFrame:CreateFontString(nil, "OVERLAY")
  title:SetFont("Fonts\\FRIZQT__.TTF", 16)
  title:SetTextColor(1, 0.84, 0)  -- Gold color
  title:SetText("AutoLFM Maestro Debug")
  title:SetPoint("TOP", debugFrame, "TOP", 0, -15)

  -- Close button
  local closeBtn = CreateFrame("Button", nil, debugFrame, "UIPanelCloseButton")
  closeBtn:SetPoint("TOPRIGHT", debugFrame, "TOPRIGHT", -5, -5)
  closeBtn:SetScript("OnClick", function()
    if AutoLFM.Components.Debug then
      AutoLFM.Components.Debug.Hide()
    end
  end)

  -- Scroll frame for content (simple frame, no template)
  scrollFrame = CreateFrame("ScrollFrame", nil, debugFrame)
  scrollFrame:SetPoint("TOPLEFT", debugFrame, "TOPLEFT", 20, -40)
  scrollFrame:SetPoint("BOTTOMRIGHT", debugFrame, "BOTTOMRIGHT", -35, 45)

  -- Create a simple scrollbar using OnMouseWheel
  scrollFrame:EnableMouseWheel(true)
  scrollFrame:SetScript("OnMouseWheel", function()
    local current = scrollFrame:GetVerticalScroll()
    local delta = 20 * (arg1 > 0 and -1 or 1)
    scrollFrame:SetVerticalScroll(math.max(0, current + delta))
  end)

  -- EditBox (read-only display)
  editBox = CreateFrame("EditBox", nil, scrollFrame)
  editBox:SetMultiLine(true)
  editBox:SetAutoFocus(false)
  editBox:SetMaxLetters(0)  -- No character limit
  editBox:EnableMouse(true)  -- Allow mouse interaction
  editBox:SetFont("Fonts\\FRIZQT__.TTF", 11)
  editBox:SetScript("OnEscapePressed", function()
    this:ClearFocus()
  end)
  scrollFrame:SetScrollChild(editBox)

  -- Clear button (bottom left)
  local clearBtn = CreateFrame("Button", nil, debugFrame, "UIPanelButtonTemplate")
  clearBtn:SetWidth(DEBUG_BUTTON_WIDTH)
  clearBtn:SetHeight(DEBUG_BUTTON_HEIGHT)
  clearBtn:SetPoint("BOTTOM", debugFrame, "BOTTOM", -135, 15)
  clearBtn:SetText("Clear")
  clearBtn:SetScript("OnClick", function()
    if AutoLFM.Components.Debug then
      AutoLFM.Components.Debug.Clear()
    end
  end)

  -- Select All button (bottom center-left)
  local selectAllBtn = CreateFrame("Button", nil, debugFrame, "UIPanelButtonTemplate")
  selectAllBtn:SetWidth(DEBUG_BUTTON_WIDTH)
  selectAllBtn:SetHeight(DEBUG_BUTTON_HEIGHT)
  selectAllBtn:SetPoint("BOTTOM", debugFrame, "BOTTOM", -45, 15)
  selectAllBtn:SetText("Select All")
  selectAllBtn:SetScript("OnClick", function()
    if editBox then
      editBox:HighlightText()
      editBox:SetFocus()
    end
  end)

  -- State button (bottom center-right)
  stateBtn = CreateFrame("Button", nil, debugFrame, "UIPanelButtonTemplate")
  stateBtn:SetWidth(DEBUG_BUTTON_WIDTH)
  stateBtn:SetHeight(DEBUG_BUTTON_HEIGHT)
  stateBtn:SetPoint("BOTTOM", debugFrame, "BOTTOM", 45, 15)
  stateBtn:SetText("State")
  stateBtn:SetScript("OnClick", function()
    if AutoLFM.Components.Debug then
      AutoLFM.Components.Debug.ShowState()
    end
  end)

  -- Registry button (bottom right)
  registryBtn = CreateFrame("Button", nil, debugFrame, "UIPanelButtonTemplate")
  registryBtn:SetWidth(DEBUG_BUTTON_WIDTH)
  registryBtn:SetHeight(DEBUG_BUTTON_HEIGHT)
  registryBtn:SetPoint("BOTTOM", debugFrame, "BOTTOM", 135, 15)
  registryBtn:SetText("Registry")
  registryBtn:SetScript("OnClick", function()
    if AutoLFM.Components.Debug then
      AutoLFM.Components.Debug.ShowRegistry()
    end
  end)

  -- Initialize button styling
  updateButtonStyling()

  -- Mouse drag handling
  debugFrame:SetScript("OnMouseDown", function()
    if arg1 == "LeftButton" then
      this:StartMoving()
    end
  end)

  debugFrame:SetScript("OnMouseUp", function()
    this:StopMovingOrSizing()
  end)

  -- Register with DarkUI if available
  if AutoLFM.Components.DarkUI and AutoLFM.Components.DarkUI.RegisterFrame then
      AutoLFM.Components.DarkUI.RegisterFrame(debugFrame)
  end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("Debug", function()
  AutoLFM.Core.Maestro.RegisterCommand("Debug.Toggle", AutoLFM.Components.Debug.Toggle, { id = "C02" })
end, { id = "I21" })
