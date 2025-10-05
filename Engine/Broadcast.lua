--------------------------------------------------
-- Stop Broadcast
--------------------------------------------------
function stopMessageBroadcast()
  isBroadcasting = false
  DEFAULT_CHAT_FRAME:AddMessage("Broadcast stopped")
  
  StopIconAnimation()
  messagesSentCount = 0
end

--------------------------------------------------
-- Send Message
--------------------------------------------------
function sendMessageToSelectedChannels(message)
  if not next(selectedChannels) then
    DEFAULT_CHAT_FRAME:AddMessage("Error: No channel selected.")
    return false
  end
  
  -- Validate channels
  for channelName, _ in pairs(selectedChannels) do
    local channelId = GetChannelName(channelName)
    if not (channelId and channelId > 0) then
      DEFAULT_CHAT_FRAME:AddMessage("Error: The channel " .. channelName .. " is invalid or closed.")
      DEFAULT_CHAT_FRAME:AddMessage("Message not sent: one or more channels are invalid.")
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
    DEFAULT_CHAT_FRAME:AddMessage("The LFM message is empty. The broadcast cannot begin.")
    return
  end
  
  isBroadcasting = true
  broadcastStartTime = GetTime()
  lastBroadcastTime = broadcastStartTime
  DEFAULT_CHAT_FRAME:AddMessage("Broadcast started.")
  
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
  local timeElapsed = GetTime() - lastBroadcastTime
  local halfSliderValue = sliderValue * 0.5
  local oneSecondBefore = sliderValue - 1
  
  if not broadcastedHalf and timeElapsed >= halfSliderValue and timeElapsed < halfSliderValue + 1 then
    DEFAULT_CHAT_FRAME:AddMessage("Rediffusion in " .. math.floor(halfSliderValue) .. " seconds", 0, 1, 1)
    broadcastedHalf = true
  end
  
  if not broadcastedOneSecBefore and timeElapsed >= oneSecondBefore and timeElapsed < oneSecondBefore + 1 then
    DEFAULT_CHAT_FRAME:AddMessage("Rediffusion of Message", 0, 1, 1)
    broadcastedOneSecBefore = true
  end
  
  if timeElapsed >= sliderValue then
    if combinedMessage and combinedMessage ~= "" then
      sendMessageToSelectedChannels(combinedMessage)
    end
    
    lastBroadcastTime = GetTime()
    broadcastedHalf = false
    broadcastedOneSecBefore = false
  end
end)