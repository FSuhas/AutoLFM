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
local isRunning = false
local broadcastTimer = nil
local lastBroadcastTime = 0
local messagesSent = 0
local sessionStartTime = 0

--- Gets the current broadcast interval from state
--- @return number - Broadcast interval in seconds
local function getBroadcastInterval()
  return AutoLFM.Core.Maestro.GetState("Broadcaster.Interval") or AutoLFM.Core.Constants.DEFAULT_BROADCAST_INTERVAL or 60
end

-- Sound file paths
local SOUND_PATH = "Interface\\AddOns\\AutoLFM\\UI\\Sounds\\"
local SOUNDS = {
  START = "Start.ogg",
  STOP = "Stop.ogg",
  FULL = "Full.ogg"
}

--=============================================================================
-- STATISTICS MANAGEMENT
--=============================================================================

--- Resets broadcast statistics to zero
local function resetStats()
  messagesSent = 0
  sessionStartTime = GetTime()
  lastBroadcastTime = 0

  -- Update Maestro states
  AutoLFM.Core.Maestro.SetState("Broadcaster.MessagesSent", 0)
  AutoLFM.Core.Maestro.SetState("Broadcaster.SessionStartTime", sessionStartTime)

  AutoLFM.Core.Utils.LogInfo("Statistics reset")
end

--- Increments the message counter and updates state
local function incrementMessageCount()
  messagesSent = messagesSent + 1
  AutoLFM.Core.Maestro.SetState("Broadcaster.MessagesSent", messagesSent)
end

--- Updates the last broadcast timestamp and state
local function updateLastBroadcastTime()
  lastBroadcastTime = GetTime()
  AutoLFM.Core.Maestro.SetState("Broadcaster.LastBroadcastTime", lastBroadcastTime)
end

--=============================================================================
-- CONVERT TO RAID
--=============================================================================

--- Converts party to raid if group size exceeds 5 and target size is > 5
--- @return boolean - True if conversion was attempted or already in raid
local function convertToRaid()
  local groupType = AutoLFM.Core.Events.GetGroupType()
  local groupSize = AutoLFM.Core.Events.GetGroupSize()

  -- Already in raid, nothing to do
  if groupType == "raid" then
    return true
  end

  -- Solo, can't convert
  if groupType == "solo" then
    return false
  end

  -- Get target size from selection
  local selectionMode = AutoLFM.Core.Maestro.GetState("Selection.Mode")
  local targetSize = 5 -- Default to dungeon size

  if selectionMode == "raid" then
    targetSize = AutoLFM.Core.Maestro.GetState("Selection.RaidSize") or 40
  elseif selectionMode == "custom" then
    targetSize = AutoLFM.Core.Maestro.GetState("Selection.CustomGroupSize") or 5
  end

  -- Check if we need to convert (target size > 5 and group is party)
  if targetSize > 5 and groupType == "party" then
    -- Check if we're the party leader
    if not AutoLFM.Core.Events.IsGroupLeader() then
      AutoLFM.Core.Utils.LogWarning("Cannot convert to raid: not party leader")
      return false
    end

    -- Convert to raid (WoW API function)
    local success, err = pcall(ConvertToRaid)
    if not success then
      AutoLFM.Core.Utils.LogError("Failed to convert to raid: " .. tostring(err))
      return false
    end

    AutoLFM.Core.Utils.LogAction("Converted party to raid (target size: " .. targetSize .. ")")
    AutoLFM.Core.Utils.Print("Converted party to raid")
    return true
  end

  return false
end

--=============================================================================
-- MESSAGE BROADCASTING
--=============================================================================

--- Sends a message to a specific channel
--- @param channelName string - The name of the channel
--- @param message string - The message to send
local function sendToChannel(channelName, message)
  local channelID = GetChannelName(channelName)

  if channelID > 0 then
    SendChatMessage(message, "CHANNEL", nil, channelID)
    AutoLFM.Core.Utils.LogAction("Broadcast to " .. channelName .. ": " .. message)
    return true
  else
    AutoLFM.Core.Utils.LogWarning("Not in channel: " .. channelName)
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
--- Respects dry run mode (sends to chat instead of channels)
--- @return boolean - True if message was sent successfully
local function broadcastMessage()
  -- Get the message to broadcast
  local message = AutoLFM.Logic.Message.GetMessage()

  if not message or message == "" then
    AutoLFM.Core.Utils.LogWarning("No message to broadcast (empty selection)")
    return false
  end

  -- Check if dry run mode is enabled
  local isDryRun = AutoLFM.Core.Maestro.GetState("Settings.DryRun") or false

  -- Get selected channels
  local channels = AutoLFM.Core.Maestro.GetState("Channels.ActiveChannels") or {}

  if table.getn(channels) == 0 and not isDryRun then
    AutoLFM.Core.Utils.LogWarning("No channels selected for broadcast")
    return false
  end

  if isDryRun then
    -- Dry run: print to chat instead of sending
    local dryRunPrefix = AutoLFM.Core.Utils.ColorText("[DRY RUN]", "YELLOW")
    AutoLFM.Core.Utils.Print(dryRunPrefix .. " " .. message)
    AutoLFM.Core.Utils.LogAction("Dry run broadcast: " .. message)
  else
    -- Real broadcast: send to all selected channels
    for i = 1, table.getn(channels) do
      local channelName = channels[i]

      -- Special handling for Hardcore channel
      if channelName == "Hardcore" then
        sendToHardcoreChannel(message)
      else
        sendToChannel(channelName, message)
      end
    end
  end

  -- Update statistics
  incrementMessageCount()
  updateLastBroadcastTime()

  return true
end

--=============================================================================
-- TIMER MANAGEMENT
--=============================================================================

--- Timer tick handler - broadcasts message at regular intervals
local function onTimerTick()
  if not isRunning then
    return
  end

  local currentTime = GetTime()
  local timeSinceLastBroadcast = currentTime - lastBroadcastTime
  local interval = getBroadcastInterval()

  -- Check if it's time to broadcast
  if timeSinceLastBroadcast >= interval then
    broadcastMessage()
  end

  -- Update time remaining state (for UI display)
  local timeRemaining = interval - timeSinceLastBroadcast
  if timeRemaining < 0 then
    timeRemaining = 0
  end
  AutoLFM.Core.Maestro.SetState("Broadcaster.TimeRemaining", timeRemaining)
end

--- Starts the broadcast timer
local function startTimer()
  if broadcastTimer then
    return -- Already running
  end

  -- Create timer frame
  broadcastTimer = CreateFrame("Frame", "AutoLFM_BroadcastTimer")
  broadcastTimer:SetScript("OnUpdate", function()
    -- OnUpdate fires every frame, so we throttle it to ~1 second
    if not this.lastUpdate or GetTime() - this.lastUpdate >= 1 then
      this.lastUpdate = GetTime()
      onTimerTick()
    end
  end)

  AutoLFM.Core.Utils.LogInfo("Broadcast timer started")
end

--- Stops the broadcast timer
local function stopTimer()
  if broadcastTimer then
    broadcastTimer:SetScript("OnUpdate", nil)
    broadcastTimer = nil
    AutoLFM.Core.Utils.LogInfo("Broadcast timer stopped")
  end
end

--=============================================================================
-- START/STOP (PRIVATE)
--=============================================================================

--- Starts broadcasting (sends immediately, then at regular intervals)
--- @private Internal use only - use Toggle() instead
local function start()
  if isRunning then
    AutoLFM.Core.Utils.LogWarning("Broadcaster already running")
    return
  end

  local isDryRun = AutoLFM.Core.Maestro.GetState("Settings.DryRun") or false

  -- Force refresh group size before starting
  if AutoLFM.Core.Events and AutoLFM.Core.Events.RefreshGroupSize then
    AutoLFM.Core.Events.RefreshGroupSize()
  end

  -- Reset statistics
  resetStats()

  -- Set running state
  isRunning = true
  AutoLFM.Core.Maestro.SetState("Broadcaster.IsRunning", true)

  -- Play start sound
  pcall(PlaySoundFile, SOUND_PATH .. SOUNDS.START)

  -- Log success (isDryRun already retrieved above)
  if isDryRun then
    AutoLFM.Core.Utils.PrintSuccess("Broadcast started in DRY RUN mode (messages will print to chat)")
  else
    AutoLFM.Core.Utils.PrintSuccess("Broadcast started")
  end

  -- Send first broadcast immediately
  broadcastMessage()

  -- Start timer for subsequent broadcasts
  startTimer()
end

--- Stops broadcasting
--- @private Internal use only - use Toggle() instead
local function stop()
  if not isRunning then
    AutoLFM.Core.Utils.LogWarning("Broadcaster not running")
    return
  end

  -- Stop timer
  stopTimer()

  -- Clear running state
  isRunning = false
  AutoLFM.Core.Maestro.SetState("Broadcaster.IsRunning", false)
  AutoLFM.Core.Maestro.SetState("Broadcaster.TimeRemaining", 0)

  -- Play stop sound
  pcall(PlaySoundFile, SOUND_PATH .. SOUNDS.STOP)

  -- Log success
  AutoLFM.Core.Utils.PrintSuccess("Broadcast stopped")

  -- Show statistics
  local sessionDuration = GetTime() - sessionStartTime
  local minutes = math.floor(sessionDuration / 60)
  AutoLFM.Core.Utils.Print(string.format("Session stats: %d messages in %d minutes", messagesSent, minutes))
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Toggles broadcasting on/off
function AutoLFM.Logic.Broadcaster.Toggle()
  if isRunning then
    stop()
  else
    start()
  end
end

--- Returns whether broadcaster is currently running
--- @return boolean - True if broadcasting is active
function AutoLFM.Logic.Broadcaster.IsRunning()
  return isRunning
end

--- Gets current broadcast statistics
--- @return table - Statistics object with messagesSent, sessionStartTime, isRunning
function AutoLFM.Logic.Broadcaster.GetStats()
  return {
    messagesSent = messagesSent,
    sessionStartTime = sessionStartTime,
    lastBroadcastTime = lastBroadcastTime,
    isRunning = isRunning
  }
end

--- Called when group size changes - updates message and checks for raid conversion
--- @param newSize number - New group size
function AutoLFM.Logic.Broadcaster.OnGroupSizeChanged(newSize)
  if not isRunning then
    return
  end

  -- Message will auto-update via Logic.Message listener
  -- Just log the change
  AutoLFM.Core.Utils.LogAction("Group size changed to " .. newSize .. " (message will auto-update)")

  -- Check if we need to convert to raid
  local selectionMode = AutoLFM.Core.Maestro.GetState("Selection.Mode")
  local targetSize = 5

  if selectionMode == "raid" then
    targetSize = AutoLFM.Core.Maestro.GetState("Selection.RaidSize") or 40
  elseif selectionMode == "custom" then
    targetSize = AutoLFM.Core.Maestro.GetState("Selection.CustomGroupSize") or 5
  end

  -- If group is full, stop broadcasting
  if newSize >= targetSize then
    AutoLFM.Core.Utils.Print("Group is full! Stopping broadcast.")
    -- Play full sound before stopping
    pcall(PlaySoundFile, SOUND_PATH .. SOUNDS.FULL)
    stop()
    return
  end

  -- Try to convert to raid if needed
  convertToRaid()
end

--=============================================================================
-- MAESTRO DECLARATIONS
--=============================================================================

--- Command: Toggle broadcasting on/off
AutoLFM.Core.Maestro.RegisterCommand("Broadcaster.Toggle", function()
  AutoLFM.Logic.Broadcaster.Toggle()
end, { id = "C21" })

--- State: Is broadcaster running
AutoLFM.Core.SafeRegisterState("Broadcaster.IsRunning", false, { id = "S14" })

--- State: Messages sent this session
AutoLFM.Core.SafeRegisterState("Broadcaster.MessagesSent", 0, { id = "S15" })

--- State: Session start time (GetTime())
AutoLFM.Core.SafeRegisterState("Broadcaster.SessionStartTime", 0, { id = "S16" })

--- State: Last broadcast time (GetTime())
AutoLFM.Core.SafeRegisterState("Broadcaster.LastBroadcastTime", 0, { id = "S17" })

--- State: Time remaining until next broadcast (seconds)
AutoLFM.Core.SafeRegisterState("Broadcaster.TimeRemaining", 0, { id = "S18" })

--- State: Broadcast interval in seconds
AutoLFM.Core.SafeRegisterState("Broadcaster.Interval", 60, { id = "S19" })

--=============================================================================
-- PUBLIC API (ADDITIONAL)
--=============================================================================

--- Sets the broadcast interval
--- @param interval number - Interval in seconds (30-7200)
function AutoLFM.Logic.Broadcaster.SetInterval(interval)
  local clampedInterval = math.max(AutoLFM.Core.Constants.MIN_BROADCAST_INTERVAL, math.min(AutoLFM.Core.Constants.MAX_BROADCAST_INTERVAL, interval))
  local oldInterval = AutoLFM.Core.Maestro.GetState("Broadcaster.Interval") or 60
  
  if oldInterval == clampedInterval then return end

  AutoLFM.Core.Maestro.SetState("Broadcaster.Interval", clampedInterval)
  AutoLFM.Core.Utils.LogInfo("Broadcast interval set to " .. clampedInterval .. " seconds")

  if AutoLFM.Core.Persistent and AutoLFM.Core.Persistent.SetBroadcastInterval then
    AutoLFM.Core.Persistent.SetBroadcastInterval(clampedInterval)
  end
end

--- Gets the current broadcast interval
--- @return number - Interval in seconds
function AutoLFM.Logic.Broadcaster.GetInterval()
  return getBroadcastInterval()
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("Logic.Broadcaster", function()
  -- Listen to group size changes
  AutoLFM.Core.Maestro.Listen(
    "Broadcaster.OnGroupSizeChanged",
    "Group.SizeChanged",
    function(payload)
      if payload and payload.size then
        AutoLFM.Logic.Broadcaster.OnGroupSizeChanged(payload.size)
      end
    end,
    { id = "L02" }
  )

  local savedInterval = AutoLFM.Core.Persistent.GetBroadcastInterval()
  if savedInterval then
    AutoLFM.Core.Maestro.SetState("Broadcaster.Interval", savedInterval)
  end
end, {
  id = "I14",
  dependencies = { "Logic.Message", "Logic.Content.Messaging", "Core.Events" }
})
