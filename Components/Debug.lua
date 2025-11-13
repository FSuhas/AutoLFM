--=============================================================================
-- AutoLFM: Debug Window Component
--   Real-time debug console with action logging
--=============================================================================

AutoLFM = AutoLFM or {}
AutoLFM.Components = AutoLFM.Components or {}
AutoLFM.Components.Debug = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================

local debugFrame = nil
local logBuffer = {}
local isEnabled = false

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

--- Adds a log line to the buffer (no limit)
--- @param line string - Formatted log line to add
local function addToBuffer(line)
  table.insert(logBuffer, line)
end

--- Updates the debug window display with current buffer contents
local function updateDisplay()
  if not debugFrame or not debugFrame:IsVisible() then
      return
  end

  local scrollFrame = getglobal("AutoLFM_DebugWindow_ScrollFrame")
  local editBox = getglobal("AutoLFM_DebugWindow_ScrollFrame_EditBox")

  if not scrollFrame or not editBox then
      return
  end

  -- Set text content
  local text = table.concat(logBuffer, "\n")
  editBox:SetText(text)

  -- Calculate required height for content
  local lineCount = table.getn(logBuffer)
  local lineHeight = AutoLFM.Core.Constants.DEBUG_LINE_HEIGHT
  local contentHeight = lineCount * lineHeight + 20  -- Extra padding

  -- Get scroll frame height
  local scrollHeight = scrollFrame:GetHeight()

  -- Set EditBox height to larger of content or visible area
  if contentHeight < scrollHeight then
    editBox:SetHeight(scrollHeight)
  else
    editBox:SetHeight(contentHeight)
  end

  -- Update scroll child rect
  scrollFrame:UpdateScrollChildRect()

  -- Scroll to bottom
  local scrollBar = getglobal("AutoLFM_DebugWindow_ScrollFrameScrollBar")
  if scrollBar then
    local _, maxValue = scrollBar:GetMinMaxValues()
    if maxValue and maxValue > 0 then
      scrollBar:SetValue(maxValue)
    end
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

  if isEnabled then
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

  -- Update display (will handle all UI reset)
  local scrollFrame = getglobal("AutoLFM_DebugWindow_ScrollFrame")
  local editBox = getglobal("AutoLFM_DebugWindow_ScrollFrame_EditBox")
  local scrollBar = getglobal("AutoLFM_DebugWindow_ScrollFrameScrollBar")

  if not scrollFrame or not editBox then
      return
  end

  -- Clear text
  editBox:SetText("")

  -- Reset to minimum height
  editBox:SetHeight(scrollFrame:GetHeight())

  -- Reset scroll position
  scrollFrame:SetVerticalScroll(0)
  scrollFrame:SetHorizontalScroll(0)

  if scrollBar then
    scrollBar:SetValue(0)
  end

  -- Update scroll child rect
  scrollFrame:UpdateScrollChildRect()

  -- Clear focus
  editBox:ClearFocus()
end

--- Displays the Maestro command and listener registry in the debug window
function AutoLFM.Components.Debug.ShowRegistry()
  local titleColor = AutoLFM.Core.Utils.GetColor("WHITE")
  local commandColor = AutoLFM.Core.Utils.GetColor("BLUE")
  local eventColor = AutoLFM.Core.Utils.GetColor("CYAN")
  local listenerColor = AutoLFM.Core.Utils.GetColor("MAGENTA")
  local initColor = AutoLFM.Core.Utils.GetColor("PURPLE")

  AutoLFM.Components.Debug.LogRegistry("|cff" .. titleColor.hex .. "=== MAESTRO REGISTRY ===|r")

  local commands, events, listeners, handlers = AutoLFM.Core.Maestro.GetRegistry()

  -- Commands Section (BLUE)
  table.sort(commands, function(a, b)
      return a.id < b.id
  end)

  AutoLFM.Components.Debug.LogRegistry("|cff" .. commandColor.hex .. "COMMANDS (" .. table.getn(commands) .. " registered):|r")
  for i = 1, table.getn(commands) do
      local entry = commands[i]
      AutoLFM.Components.Debug.LogRegistry("  |cff888888[" .. entry.id .. "]|r " .. entry.key)
  end

  -- Events Section (CYAN)
  table.sort(events, function(a, b)
      return a.id < b.id
  end)

  AutoLFM.Components.Debug.LogRegistry("|cff" .. eventColor.hex .. "EVENTS (" .. table.getn(events) .. " registered):|r")
  for i = 1, table.getn(events) do
      local entry = events[i]
      AutoLFM.Components.Debug.LogRegistry("  |cff888888[" .. entry.id .. "]|r " .. entry.key)
  end

  -- Listeners Section (MAGENTA)
  table.sort(listeners, function(a, b)
      return a.id < b.id
  end)

  AutoLFM.Components.Debug.LogRegistry("|cff" .. listenerColor.hex .. "LISTENERS (" .. table.getn(listeners) .. " registered):|r")
  for i = 1, table.getn(listeners) do
      local entry = listeners[i]
      AutoLFM.Components.Debug.LogRegistry("  |cff888888[" .. entry.id .. "]|r " .. entry.key)
  end

  -- Init Handlers Section (PURPLE)
  table.sort(handlers, function(a, b)
      return a.id < b.id
  end)

  AutoLFM.Components.Debug.LogRegistry("|cff" .. initColor.hex .. "INIT HANDLERS (" .. table.getn(handlers) .. " registered):|r")
  for i = 1, table.getn(handlers) do
      local entry = handlers[i]
      AutoLFM.Components.Debug.LogRegistry("  |cff888888[" .. entry.id .. "]|r " .. entry.key)
  end

  if isEnabled then
      updateDisplay()
  end
end

--- Displays the Maestro state in the debug window
function AutoLFM.Components.Debug.ShowState()
  local titleColor = AutoLFM.Core.Utils.GetColor("WHITE")
  local stateColor = AutoLFM.Core.Utils.GetColor("GREEN")

  AutoLFM.Components.Debug.LogState("|cff" .. titleColor.hex .. "=== MAESTRO STATE ===|r")

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

    AutoLFM.Components.Debug.LogState("|cff888888[" .. id .. "]|r |cffffaa00" .. key .. ":|r " .. valueStr)
  end

  if not hasState then
    AutoLFM.Components.Debug.LogState("|cff888888(No states registered)|r")
  end

  if isEnabled then
    updateDisplay()
  end
end

--=============================================================================
-- FRAME CREATION
--=============================================================================

--- Creates and initializes the debug window frame from XML template
function AutoLFM.Components.Debug.CreateFrame()
  if debugFrame then
      return
  end

  -- Get frame created from XML template
  debugFrame = getglobal("AutoLFM_DebugWindow")

  if not debugFrame then
      if AutoLFM.Core.Utils and AutoLFM.Core.Utils.PrintError then
          AutoLFM.Core.Utils.PrintError("Debug window template not found")
      end
      return
  end

  -- Get editbox for dynamic sizing
  local scrollFrame = getglobal("AutoLFM_DebugWindow_ScrollFrame")
  local editBox = getglobal("AutoLFM_DebugWindow_ScrollFrame_EditBox")

  if scrollFrame and editBox then
      editBox:SetWidth(scrollFrame:GetWidth())
      editBox:SetHeight(scrollFrame:GetHeight())
  end

  -- Register with DarkUI if available
  if AutoLFM.Components.DarkUI and AutoLFM.Components.DarkUI.RegisterFrame then
      AutoLFM.Components.DarkUI.RegisterFrame(debugFrame)
  end
end

--- XML OnLoad callback for debug window frame
--- @param frame frame - The debug window frame
function AutoLFM.Components.Debug.OnFrameLoad(frame)
  -- Called from XML when frame is loaded
  debugFrame = frame
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("Debug", function()
  AutoLFM.Core.Maestro.RegisterCommand("Debug.Toggle", AutoLFM.Components.Debug.Toggle, { id = "C02" })
end, { id = "I06" })
