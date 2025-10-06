--------------------------------------------------
-- Broadcast Management
--------------------------------------------------
local broadcastFrame = nil

--------------------------------------------------
-- Send Message to Selected Channels
--------------------------------------------------
function sendMessageToSelectedChannels(message)
  if not selectedChannels then
    selectedChannels = {}
  end
  
  if not next(selectedChannels) then
    AutoLFM_PrintError("No channel selected")
    return false
  end
  
  -- Validate all channels before sending
  for channelName, _ in pairs(selectedChannels) do
    local channelId = GetChannelName(channelName)
    if not (channelId and channelId > 0) then
      AutoLFM_PrintError("The channel " .. channelName .. " is invalid or closed")
      AutoLFM_PrintError("Message not sent: one or more channels are invalid")
      return false
    end
  end
  
  -- Send to all valid channels
  for channelName, _ in pairs(selectedChannels) do
    local channelId = GetChannelName(channelName)
    SendChatMessage(message, "CHANNEL", nil, channelId)
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

broadcastFrame:SetScript("OnUpdate", function()
  if not isBroadcasting then return end
  
  local sliderValue = slider and slider:GetValue() or 80
  local currentTime = GetTime()
  local timeElapsed = currentTime - lastBroadcastTime
  
  -- Send message at interval
  if timeElapsed >= sliderValue then
    if combinedMessage and combinedMessage ~= "" then
      sendMessageToSelectedChannels(combinedMessage)
    end
    
    lastBroadcastTime = GetTime()
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