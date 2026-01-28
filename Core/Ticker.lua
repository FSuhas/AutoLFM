--=============================================================================
-- AutoLFM: Ticker
--   Centralized tick management system to consolidate OnUpdate frames
--   Provides efficient timer callbacks without creating multiple frames
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Core = AutoLFM.Core or {}
AutoLFM.Core.Ticker = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local tickerFrame = nil
local tickers = {}  -- { id = { callback, interval, lastTick, enabled } }
local tickerCount = 0
local activeTickers = 0
local lastGlobalTick = 0

-- Minimum tick resolution in seconds (throttle to avoid excessive OnUpdate calls)
local TICK_RESOLUTION = 0.1

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================

--- Main OnUpdate handler - processes all registered tickers
local function onUpdate()
  local now = GetTime()

  -- Global throttle to avoid processing every frame
  if now - lastGlobalTick < TICK_RESOLUTION then
    return
  end
  lastGlobalTick = now

  -- Process each ticker
  for id, ticker in pairs(tickers) do
    if ticker.enabled then
      local elapsed = now - ticker.lastTick
      if elapsed >= ticker.interval then
        -- Call the ticker callback
        local success, err = pcall(ticker.callback, elapsed)
        if not success then
          AutoLFM.Core.Utils.LogError("Ticker '" .. id .. "' failed: " .. tostring(err))
        end
        ticker.lastTick = now
      end
    end
  end
end

--- Ensures the ticker frame exists and is properly configured
local function ensureFrame()
  if tickerFrame then return end

  tickerFrame = CreateFrame("Frame", "AutoLFM_TickerFrame")
  tickerFrame:Hide()
  tickerFrame:SetScript("OnUpdate", onUpdate)
end

--- Updates the frame visibility based on active ticker count
--- Frame is hidden when no tickers are active to save CPU
local function updateFrameState()
  if not tickerFrame then return end

  if activeTickers > 0 then
    tickerFrame:Show()
  else
    tickerFrame:Hide()
  end
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Registers a new ticker callback
--- @param id string - Unique identifier for this ticker
--- @param interval number - Interval in seconds between callbacks
--- @param callback function - Function to call on each tick, receives (elapsed) as argument
--- @param startImmediately boolean - If true, ticker starts enabled (default: false)
--- @return boolean - True if registration successful
function AutoLFM.Core.Ticker.Register(id, interval, callback, startImmediately)
  if not id or type(id) ~= "string" then
    AutoLFM.Core.Utils.LogError("Ticker.Register: id must be a non-empty string")
    return false
  end

  if tickers[id] then
    AutoLFM.Core.Utils.LogWarning("Ticker.Register: ticker '" .. id .. "' already registered, use Update to modify")
    return false
  end

  if not interval or type(interval) ~= "number" or interval <= 0 then
    AutoLFM.Core.Utils.LogError("Ticker.Register: interval must be a positive number")
    return false
  end

  if not callback or type(callback) ~= "function" then
    AutoLFM.Core.Utils.LogError("Ticker.Register: callback must be a function")
    return false
  end

  ensureFrame()

  local enabled = startImmediately == true

  tickers[id] = {
    callback = callback,
    interval = interval,
    lastTick = GetTime(),
    enabled = enabled
  }

  tickerCount = tickerCount + 1

  if enabled then
    activeTickers = activeTickers + 1
    updateFrameState()
  end

  AutoLFM.Core.Utils.LogInfo("Ticker registered: " .. id .. " (interval=" .. interval .. "s, enabled=" .. tostring(enabled) .. ")")
  return true
end

--- Starts a registered ticker
--- @param id string - Ticker identifier
--- @return boolean - True if ticker was started
function AutoLFM.Core.Ticker.Start(id)
  local ticker = tickers[id]
  if not ticker then
    AutoLFM.Core.Utils.LogWarning("Ticker.Start: ticker '" .. tostring(id) .. "' not found")
    return false
  end

  if ticker.enabled then
    return true  -- Already running
  end

  ticker.enabled = true
  ticker.lastTick = GetTime()  -- Reset last tick to avoid immediate callback
  activeTickers = activeTickers + 1
  updateFrameState()

  AutoLFM.Core.Utils.LogInfo("Ticker started: " .. id)
  return true
end

--- Stops a registered ticker
--- @param id string - Ticker identifier
--- @return boolean - True if ticker was stopped
function AutoLFM.Core.Ticker.Stop(id)
  local ticker = tickers[id]
  if not ticker then
    AutoLFM.Core.Utils.LogWarning("Ticker.Stop: ticker '" .. tostring(id) .. "' not found")
    return false
  end

  if not ticker.enabled then
    return true  -- Already stopped
  end

  ticker.enabled = false
  activeTickers = activeTickers - 1
  updateFrameState()

  AutoLFM.Core.Utils.LogInfo("Ticker stopped: " .. id)
  return true
end

--- Checks if a ticker is currently running
--- @param id string - Ticker identifier
--- @return boolean - True if ticker exists and is enabled
function AutoLFM.Core.Ticker.IsRunning(id)
  local ticker = tickers[id]
  return ticker and ticker.enabled or false
end

--- Unregisters a ticker completely
--- @param id string - Ticker identifier
--- @return boolean - True if ticker was unregistered
function AutoLFM.Core.Ticker.Unregister(id)
  local ticker = tickers[id]
  if not ticker then
    AutoLFM.Core.Utils.LogWarning("Ticker.Unregister: ticker '" .. tostring(id) .. "' not found")
    return false
  end

  if ticker.enabled then
    activeTickers = activeTickers - 1
  end

  tickers[id] = nil
  tickerCount = tickerCount - 1
  updateFrameState()

  AutoLFM.Core.Utils.LogInfo("Ticker unregistered: " .. id)
  return true
end

--- Updates the interval of an existing ticker
--- @param id string - Ticker identifier
--- @param newInterval number - New interval in seconds
--- @return boolean - True if interval was updated
function AutoLFM.Core.Ticker.SetInterval(id, newInterval)
  local ticker = tickers[id]
  if not ticker then
    AutoLFM.Core.Utils.LogWarning("Ticker.SetInterval: ticker '" .. tostring(id) .. "' not found")
    return false
  end

  if not newInterval or type(newInterval) ~= "number" or newInterval <= 0 then
    AutoLFM.Core.Utils.LogError("Ticker.SetInterval: interval must be a positive number")
    return false
  end

  ticker.interval = newInterval
  AutoLFM.Core.Utils.LogInfo("Ticker interval updated: " .. id .. " = " .. newInterval .. "s")
  return true
end

--- Gets the current interval of a ticker
--- @param id string - Ticker identifier
--- @return number|nil - Interval in seconds, or nil if ticker not found
function AutoLFM.Core.Ticker.GetInterval(id)
  local ticker = tickers[id]
  return ticker and ticker.interval
end

--- Triggers a ticker callback immediately (outside of normal schedule)
--- Useful for immediate execution without waiting for interval
--- @param id string - Ticker identifier
--- @return boolean - True if callback was executed
function AutoLFM.Core.Ticker.TriggerNow(id)
  local ticker = tickers[id]
  if not ticker then
    AutoLFM.Core.Utils.LogWarning("Ticker.TriggerNow: ticker '" .. tostring(id) .. "' not found")
    return false
  end

  local now = GetTime()
  local elapsed = now - ticker.lastTick

  local success, err = pcall(ticker.callback, elapsed)
  if not success then
    AutoLFM.Core.Utils.LogError("Ticker '" .. id .. "' failed: " .. tostring(err))
    return false
  end

  ticker.lastTick = now
  return true
end

--- Gets statistics about the ticker system
--- @return table - Stats object with count, active, and ids fields
function AutoLFM.Core.Ticker.GetStats()
  local ids = {}
  for id, ticker in pairs(tickers) do
    table.insert(ids, {
      id = id,
      interval = ticker.interval,
      enabled = ticker.enabled
    })
  end

  return {
    count = tickerCount,
    active = activeTickers,
    tickers = ids
  }
end

--=============================================================================
-- INITIALIZATION
--=============================================================================
AutoLFM.Core.SafeRegisterInit("Core.Ticker", function()
  -- Frame is created on-demand when first ticker is registered
  AutoLFM.Core.Utils.LogInfo("Ticker system initialized")
end, { id = "I24", dependencies = {} })
