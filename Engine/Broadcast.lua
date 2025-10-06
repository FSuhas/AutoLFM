--------------------------------------------------
-- Broadcast Management
--------------------------------------------------
local broadcastFrame = nil
local broadcastedHalf = false
local broadcastedOneSecBefore = false

--------------------------------------------------
-- Send Message to Selected Channels
--------------------------------------------------
function sendMessageToSelectedChannels(message)
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
  
  messagesSentCount = messagesSentCount + 1
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
  local halfSliderValue = sliderValue * 0.5
  local oneSecondBefore = sliderValue - 1
  
  -- Notification at half interval
  if not broadcastedHalf and timeElapsed >= halfSliderValue and timeElapsed < halfSliderValue + 1 then
    AutoLFM_PrintInfo("Rediffusion in " .. math.floor(halfSliderValue) .. " seconds", 0, 1, 1)
    broadcastedHalf = true
  end
  
  -- Notification 1 second before broadcast
  if not broadcastedOneSecBefore and timeElapsed >= oneSecondBefore and timeElapsed < oneSecondBefore + 1 then
    AutoLFM_PrintInfo("Rediffusion of Message", 0, 1, 1)
    broadcastedOneSecBefore = true
  end
  
  -- Send message at interval
  if timeElapsed >= sliderValue then
    if combinedMessage and combinedMessage ~= "" then
      sendMessageToSelectedChannels(combinedMessage)
    end
    
    lastBroadcastTime = GetTime()
    broadcastedHalf = false
    broadcastedOneSecBefore = false
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
  broadcastedHalf = false
  broadcastedOneSecBefore = false
end