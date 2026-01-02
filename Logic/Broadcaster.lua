--=============================================================================
-- AutoLFM: Broadcaster
--   Automated message broadcasting with statistics and dry run support
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Broadcaster = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local broadcastTimer
local SOUNDS = {
  START = "Start.ogg",
  STOP = "Stop.ogg",
  FULL = "Full.ogg"
}

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================

--- Gets the current broadcast interval from state
--- @return number - Broadcast interval in seconds
local function getBroadcastInterval()
  return AutoLFM.Core.Maestro.GetState("Broadcaster.Interval") or AutoLFM.Core.Constants.DEFAULT_BROADCAST_INTERVAL or 60
end

--=============================================================================
-- STATISTICS MANAGEMENT
--=============================================================================

--- Resets broadcast statistics to zero
local function resetStats()
  AutoLFM.Core.Maestro.SetState("Broadcaster.MessagesSent", 0)
  AutoLFM.Core.Maestro.SetState("Broadcaster.SessionStartTime", GetTime())
  AutoLFM.Core.Maestro.SetState("Broadcaster.LastBroadcastTime", 0)
end

--- Increments the message counter
local function incrementMessageCount()
  local count = (AutoLFM.Core.Maestro.GetState("Broadcaster.MessagesSent") or 0) + 1
  AutoLFM.Core.Maestro.SetState("Broadcaster.MessagesSent", count)
end

--- Updates the last broadcast timestamp
local function updateLastBroadcastTime()
  AutoLFM.Core.Maestro.SetState("Broadcaster.LastBroadcastTime", GetTime())
end

--=============================================================================
-- GROUP CHANGE HANDLING
--=============================================================================

--- Handles group changes: convert to raid if needed, stop if full
local function onGroupChange()
  -- Convert to raid if needed (regardless of broadcaster state)
  AutoLFM.Logic.Group.ConvertToRaidIfNeeded()

  -- Only check for full group if broadcaster is running
  local isRunning = AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning")
  if not isRunning then
    return
  end

  -- If group is full, stop broadcasting
  local groupSize = AutoLFM.Logic.Group.GetSize()
  local targetSize = AutoLFM.Logic.Group.GetTargetSize()

  if groupSize >= targetSize then
    AutoLFM.Core.Utils.PrintSuccess("Group is full! Stopping broadcast.")
    -- NOTE: pcall used intentionally - sound files are optional and may not exist
    -- Failure to play sound should not interrupt broadcast functionality
    pcall(PlaySoundFile, AutoLFM.Core.Constants.SOUND_PATH .. SOUNDS.FULL)
    AutoLFM.Logic.Broadcaster.Toggle()
  end
end

--=============================================================================
-- MESSAGE BROADCASTING
--=============================================================================

--- Retry frame for deferred broadcast retries
local retryFrame = nil

--- Schedules a retry for a failed broadcast
--- @param sendFunc function - The send function to retry
--- @param args table - Arguments to pass to the send function
--- @param retriesLeft number - Number of retries remaining
local function scheduleRetry(sendFunc, args, retriesLeft)
  if retriesLeft <= 0 then return end

  if not retryFrame then
    retryFrame = CreateFrame("Frame", "AutoLFM_RetryFrame")
  end

  local startTime = GetTime()
  local delay = AutoLFM.Core.Constants.BROADCAST_RETRY_DELAY or 1

  retryFrame:SetScript("OnUpdate", function()
    if GetTime() - startTime >= delay then
      retryFrame:SetScript("OnUpdate", nil)
      retryFrame:Hide()
      sendFunc(args.message, retriesLeft - 1)
    end
  end)
  retryFrame:Show()
end

--- Sends a message to a specific channel with retry support
--- @param channelName string - The name of the channel
--- @param message string - The message to send
--- @param retries number - Number of retries remaining (optional, defaults to MAX_BROADCAST_RETRIES)
local function sendToChannel(channelName, message, retries)
  if retries == nil then
    retries = AutoLFM.Core.Constants.MAX_BROADCAST_RETRIES or 2
  end

  local channelID = GetChannelName(channelName)

  if channelID > 0 then
    local success, err = pcall(SendChatMessage, message, "CHANNEL", nil, channelID)
    if success then
      AutoLFM.Core.Utils.LogAction("Broadcast to " .. channelName .. ": " .. message)
      return true
    else
      AutoLFM.Core.Utils.LogWarning("Failed to send to " .. channelName .. ": " .. tostring(err))
      if retries > 0 then
        AutoLFM.Core.Utils.LogInfo("Retrying broadcast to " .. channelName .. " (" .. retries .. " attempts left)")
        scheduleRetry(function(msg, r) sendToChannel(channelName, msg, r) end, {message = message}, retries)
      end
      return false
    end
  else
    AutoLFM.Core.Utils.LogWarning("Not in channel: " .. channelName)
    return false
  end
end

--- Sends a message to the General channel (configurable index, default /1)
--- Channel index is read from Storage (set via V3_Settings.generalChannelIndex)
--- @param message string - The message to send
local function sendToGeneralChannel(message)
  local channelIndex = 1
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.GetGeneralChannelIndex then
    channelIndex = AutoLFM.Core.Storage.GetGeneralChannelIndex() or 1
  end
  local channelID, channelName = GetChannelName(channelIndex)
  if channelID and channelID > 0 then
    local success, err = pcall(SendChatMessage, message, "CHANNEL", nil, channelID)
    if success then
      AutoLFM.Core.Utils.LogAction("Broadcast to General /" .. channelIndex .. " (" .. (channelName or tostring(channelIndex)) .. "): " .. message)
      return true
    else
      AutoLFM.Core.Utils.LogWarning("Failed to send to General /" .. channelIndex .. ": " .. tostring(err))
      return false
    end
  else
    AutoLFM.Core.Utils.LogWarning("Not in General channel /" .. channelIndex)
    return false
  end
end

--- Sends a message to the Hardcore channel (special handling)
--- @param message string - The message to send
local function sendToHardcoreChannel(message)
  local success, err = pcall(SendChatMessage, message, "Hardcore")
  if success then
    AutoLFM.Core.Utils.LogAction("Broadcast to Hardcore: " .. message)
    return true
  else
    AutoLFM.Core.Utils.LogWarning("Failed to send to Hardcore: " .. tostring(err))
    return false
  end
end

--- Sends the broadcast message to all selected channels
--- @return boolean - True if message was sent successfully
local function broadcastMessage()
  local message = AutoLFM.Logic.Message.GetMessage()

  if not message or message == "" then
    AutoLFM.Core.Utils.LogWarning("No message to broadcast (empty selection)")
    return false
  end

  local isDryRun = AutoLFM.Core.Maestro.GetState("Settings.DryRun") or false
  local channels = AutoLFM.Core.Maestro.GetState("Channels.ActiveChannels") or {}

  if table.getn(channels) == 0 and not isDryRun then
    AutoLFM.Core.Utils.LogWarning("No channels selected for broadcast")
    return false
  end

  if isDryRun then
    local dryRunPrefix = AutoLFM.Core.Utils.ColorText("[DRY RUN]", "YELLOW")
    AutoLFM.Core.Utils.Print(dryRunPrefix .. " " .. message)
    AutoLFM.Core.Utils.LogAction("Dry run broadcast: " .. message)
  else
    for i = 1, table.getn(channels) do
      local channelName = channels[i]
      if channelName == "Hardcore" then
        sendToHardcoreChannel(message)
      elseif channelName == "General" then
        sendToGeneralChannel(message)
      else
        sendToChannel(channelName, message)
      end
    end
  end

  incrementMessageCount()
  updateLastBroadcastTime()
  return true
end

--=============================================================================
-- TIMER MANAGEMENT
--=============================================================================

--- Timer tick handler - broadcasts message at regular intervals
local function onTimerTick()
  local isRunning = AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning")
  if not isRunning then
    return
  end

  local currentTime = GetTime()
  local lastBroadcastTime = AutoLFM.Core.Maestro.GetState("Broadcaster.LastBroadcastTime") or 0
  local timeSinceLastBroadcast = currentTime - lastBroadcastTime
  local interval = getBroadcastInterval()

  if timeSinceLastBroadcast >= interval then
    broadcastMessage()
  end

  local timeRemaining = interval - timeSinceLastBroadcast
  if timeRemaining < 0 then timeRemaining = 0 end
  AutoLFM.Core.Maestro.SetState("Broadcaster.TimeRemaining", timeRemaining)
end

--- Starts the broadcast timer
--- Uses OnUpdate with proper throttle (avoid 'this' context issues)
--- Design: Synchronous OnUpdate with 1-second throttle is simpler and more reliable than
--- async timers, avoiding race conditions while maintaining acceptable CPU efficiency.
--- Performance: Frame is hidden when not running to completely stop OnUpdate callbacks.
local function startTimer()
  if broadcastTimer then
    -- Reuse existing frame, just show it to restart OnUpdate
    broadcastTimer:Show()
    return
  end

  broadcastTimer = CreateFrame("Frame", "AutoLFM_BroadcastTimer")
  local lastTick = GetTime()

  broadcastTimer:SetScript("OnUpdate", function()
    local now = GetTime()
    -- Throttle to 1 second intervals to minimize CPU usage
    -- Fires approximately 5-10 times per second from OnUpdate, we process ~1 per second
    if now - lastTick >= 1 then
      lastTick = now
      onTimerTick()
    end
  end)
end

--- Stops the broadcast timer and cleans up resources
--- Performance: Hiding the frame completely stops OnUpdate callbacks without destroying it
local function stopTimer()
  if broadcastTimer then
    broadcastTimer:Hide()
    -- Note: Frame is not destroyed (would require unregistering from name registry)
    -- Hiding stops OnUpdate from firing, so no CPU usage when stopped
  end
end

--=============================================================================
-- START/STOP (PRIVATE)
--=============================================================================

--- Starts broadcasting
local function start()
  local isRunning = AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning")
  if isRunning then
    AutoLFM.Core.Utils.LogWarning("Broadcaster already running")
    return
  end

  local isDryRun = AutoLFM.Core.Maestro.GetState("Settings.DryRun") or false

  resetStats()
  AutoLFM.Core.Maestro.SetState("Broadcaster.IsRunning", true)
  -- NOTE: pcall used intentionally - sound files are optional and may not exist
  -- Failure to play sound should not interrupt broadcast functionality
  pcall(PlaySoundFile, AutoLFM.Core.Constants.SOUND_PATH .. SOUNDS.START)

  if isDryRun then
    AutoLFM.Core.Utils.PrintSuccess("Broadcast started in DRY RUN mode (messages will print to chat)")
  else
    AutoLFM.Core.Utils.PrintSuccess("Broadcast started")
  end

  -- Convert to raid if needed
  AutoLFM.Logic.Group.ConvertToRaidIfNeeded()

  broadcastMessage()
  startTimer()
end

--- Stops broadcasting
local function stop()
  local isRunning = AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning")
  if not isRunning then
    AutoLFM.Core.Utils.LogWarning("Broadcaster not running")
    return
  end

  stopTimer()
  AutoLFM.Core.Maestro.SetState("Broadcaster.IsRunning", false)
  AutoLFM.Core.Maestro.SetState("Broadcaster.TimeRemaining", 0)
  -- NOTE: pcall used intentionally - sound files are optional and may not exist
  -- Failure to play sound should not interrupt broadcast functionality
  pcall(PlaySoundFile, AutoLFM.Core.Constants.SOUND_PATH .. SOUNDS.STOP)

  AutoLFM.Core.Utils.PrintSuccess("Broadcast stopped")

  local sessionStartTime = AutoLFM.Core.Maestro.GetState("Broadcaster.SessionStartTime") or 0
  local messagesSent = AutoLFM.Core.Maestro.GetState("Broadcaster.MessagesSent") or 0
  local sessionDuration = GetTime() - sessionStartTime
  local minutes = math.floor(sessionDuration / 60)
  AutoLFM.Core.Utils.Print(string.format("Session stats: %d messages in %d minutes", messagesSent, minutes))
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Toggles broadcasting on/off
function AutoLFM.Logic.Broadcaster.Toggle()
  local isRunning = AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning")
  if isRunning then
    stop()
  else
    start()
  end
end

--- Returns whether broadcaster is currently running
--- @return boolean - True if broadcasting is active
function AutoLFM.Logic.Broadcaster.IsRunning()
  return AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning") or false
end

--- Gets current broadcast statistics
--- @return table - Statistics object
function AutoLFM.Logic.Broadcaster.GetStats()
  return {
    messagesSent = AutoLFM.Core.Maestro.GetState("Broadcaster.MessagesSent") or 0,
    sessionStartTime = AutoLFM.Core.Maestro.GetState("Broadcaster.SessionStartTime") or 0,
    lastBroadcastTime = AutoLFM.Core.Maestro.GetState("Broadcaster.LastBroadcastTime") or 0,
    isRunning = AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning") or false
  }
end

--- Sets the broadcast interval
--- @param interval number - Interval in seconds (30-120)
function AutoLFM.Logic.Broadcaster.SetInterval(interval)
  -- Validate interval parameter
  if type(interval) ~= "number" then
    AutoLFM.Core.Utils.LogError("SetInterval: interval must be number, got " .. type(interval))
    return false
  end

  -- Validate interval is within acceptable range
  if interval < AutoLFM.Core.Constants.MIN_BROADCAST_INTERVAL or interval > AutoLFM.Core.Constants.MAX_BROADCAST_INTERVAL then
    AutoLFM.Core.Utils.LogWarning("SetInterval: interval out of range [" .. AutoLFM.Core.Constants.MIN_BROADCAST_INTERVAL .. "-" .. AutoLFM.Core.Constants.MAX_BROADCAST_INTERVAL .. "], got " .. interval)
  end

  local clampedInterval = math.max(AutoLFM.Core.Constants.MIN_BROADCAST_INTERVAL, math.min(AutoLFM.Core.Constants.MAX_BROADCAST_INTERVAL, interval))
  local oldInterval = AutoLFM.Core.Maestro.GetState("Broadcaster.Interval") or 60

  if oldInterval == clampedInterval then return end

  AutoLFM.Core.Maestro.SetState("Broadcaster.Interval", clampedInterval)

  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.SetBroadcastInterval then
    AutoLFM.Core.Storage.SetBroadcastInterval(clampedInterval)
  end
end

--- Gets the current broadcast interval
--- @return number - Interval in seconds
function AutoLFM.Logic.Broadcaster.GetInterval()
  return getBroadcastInterval()
end

--=============================================================================
-- STATE DECLARATIONS
--=============================================================================
AutoLFM.Core.SafeRegisterState("Broadcaster.IsRunning", false, { id = "S13" })
AutoLFM.Core.SafeRegisterState("Broadcaster.Interval", 60, { id = "S12" })
AutoLFM.Core.SafeRegisterState("Broadcaster.MessagesSent", 0, { id = "S15" })
AutoLFM.Core.SafeRegisterState("Broadcaster.SessionStartTime", 0, { id = "S16" })
AutoLFM.Core.SafeRegisterState("Broadcaster.LastBroadcastTime", 0, { id = "S14" })
AutoLFM.Core.SafeRegisterState("Broadcaster.TimeRemaining", 0, { id = "S17" })

--=============================================================================
-- COMMAND DECLARATIONS
--=============================================================================
AutoLFM.Core.Maestro.RegisterCommand("Broadcaster.Toggle", function()
  AutoLFM.Logic.Broadcaster.Toggle()
end, { id = "C15" })

--=============================================================================
-- INITIALIZATION
--=============================================================================
AutoLFM.Core.SafeRegisterInit("Logic.Broadcaster", function()
  AutoLFM.Core.Maestro.Listen(
    "Broadcaster.OnGroupSizeChanged",
    "Group.SizeChanged",
    onGroupChange,
    { id = "L03" }
  )

  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.GetBroadcastInterval then
    local savedInterval = AutoLFM.Core.Storage.GetBroadcastInterval()
    -- NOTE: Use explicit nil check instead of 'if savedInterval' to handle interval = 0 correctly
    if savedInterval ~= nil then
      AutoLFM.Core.Maestro.SetState("Broadcaster.Interval", savedInterval)
    end
  end
end, {
  id = "I09",
  dependencies = { "Logic.Message", "Logic.Group", "Logic.Content.Messaging", "Core.Events" }
})
