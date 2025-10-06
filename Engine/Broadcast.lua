--------------------------------------------------
-- Broadcast Management
--------------------------------------------------
local broadcastFrame = nil

--------------------------------------------------
-- Send Message to Selected Channels
--------------------------------------------------
function sendMessageToSelectedChannels(message)
  if not message or message == "" then
    AutoLFM_PrintError("Message is empty")
    return false
  end
  
  if not selectedChannels then
    selectedChannels = {}
  end
  
  if not next(selectedChannels) then
    AutoLFM_PrintError("No channel selected")
    return false
  end
  
  -- Send to all channels and track success
  local sentCount = 0
  local invalidChannels = {}
  
  for channelName, _ in pairs(selectedChannels) do
    local channelId = GetChannelName(channelName)
    if channelId and channelId > 0 then
      SendChatMessage(message, "CHANNEL", nil, channelId)
      sentCount = sentCount + 1
    else
      table.insert(invalidChannels, channelName)
    end
  end
  
  -- Report invalid channels if any
  if table.getn(invalidChannels) > 0 then
    for _, channelName in ipairs(invalidChannels) do
      AutoLFM_PrintError("The channel " .. channelName .. " is invalid or closed")
    end
    -- Only fail if ALL channels were invalid
    if sentCount == 0 then
      AutoLFM_PrintError("Message not sent: all channels are invalid")
      return false
    end
  end
  
  messagesSentCount = (messagesSentCount or 0) + 1
  return true
end

--------------------------------------------------
-- Start Broadcast
--------------------------------------------------
function startMessageBroadcast()
  if not combinedMessage or combinedMessage == "" or combinedMessage == " " then
    AutoLFM_PrintError("The LFM message is empty. The broadcast cannot begin")
    return
  end
  
  isBroadcasting = true
  broadcastStartTime = GetTime()
  lastBroadcastTime = broadcastStartTime
  AutoLFM_PrintInfo("Broadcast started")
  
  sendMessageToSelectedChannels(combinedMessage)
  StartIconAnimation()
end

--------------------------------------------------
-- Broadcast Loop
--------------------------------------------------
if not broadcastFrame then
  broadcastFrame = CreateFrame("Frame")
end

local lastUpdateCheck = 0
local UPDATE_THROTTLE = 1.0  -- Check only once per second

broadcastFrame:SetScript("OnUpdate", function()
  if not isBroadcasting then return end
  
  local currentTime = GetTime()
  
  -- Throttle: only check once per second
  if currentTime - lastUpdateCheck < UPDATE_THROTTLE then
    return
  end
  lastUpdateCheck = currentTime
  
  if not slider then return end
  if not lastBroadcastTime then
    lastBroadcastTime = currentTime
    return
  end
  
  local sliderValue = slider:GetValue()
  if not sliderValue or sliderValue < 1 then
    sliderValue = 80
  end
  
  local timeElapsed = currentTime - lastBroadcastTime
  
  -- Send message at interval
  if timeElapsed >= sliderValue then
    if combinedMessage and combinedMessage ~= "" and combinedMessage ~= " " then
      local success = sendMessageToSelectedChannels(combinedMessage)
      if success then
        lastBroadcastTime = currentTime
      else
        -- Stop broadcast if sending failed
        stopMessageBroadcast()
        if toggleButton then
          toggleButton:SetText("Start")
        end
      end
    end
  end
end)

--------------------------------------------------
-- Stop Broadcast
--------------------------------------------------
function stopMessageBroadcast()
  isBroadcasting = false
  AutoLFM_PrintInfo("Broadcast stopped")
  
  StopIconAnimation()
  messagesSentCount = 0
end