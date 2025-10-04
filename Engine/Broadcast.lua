--------------------------------------------------
-- Broadcast Functions
--------------------------------------------------
local lastMessageSent = 0
local MIN_INTERVAL = 30

--------------------------------------------------
-- Icon Toggle
--------------------------------------------------
function toggleMinimapButtonIcon()
  if not AutoLFMMinimapBtn then return end
  
  local icon = math.random(1, 2) == 1 and "eye01" or "eye04"
  local pushed = icon == "eye01" and "eye04" or "eye01"
  AutoLFMMinimapBtn:SetNormalTexture(texturePath .. "Eyes\\" .. icon)
  AutoLFMMinimapBtn:SetPushedTexture(texturePath .. "Eyes\\" .. pushed)
end

--------------------------------------------------
-- Stop Broadcast
--------------------------------------------------
function stopMessageBroadcast()
  isBroadcasting = false
  DEFAULT_CHAT_FRAME:AddMessage("Broadcast stopped")
  
  if AutoLFMMinimapBtn then
    AutoLFMMinimapBtn:SetNormalTexture(texturePath .. "Eyes\\eye01")
    AutoLFMMinimapBtn:SetPushedTexture(texturePath .. "Eyes\\eye04")
  end
  
  if iconUpdateFrame then
    iconUpdateFrame:SetScript("OnUpdate", nil)
  end
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
  
  local now = GetTime()
  if now - lastMessageSent < MIN_INTERVAL then
    local remaining = math.ceil(MIN_INTERVAL - (now - lastMessageSent))
    DEFAULT_CHAT_FRAME:AddMessage("Anti-spam: wait " .. remaining .. "s before next broadcast.", 1, 0.5, 0)
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
  lastMessageSent = now
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
  
  if not iconUpdateFrame then
    iconUpdateFrame = CreateFrame("Frame")
  end
  
  local lastIconUpdate = GetTime()
  iconUpdateFrame:SetScript("OnUpdate", function()
    if not isBroadcasting then
      iconUpdateFrame:SetScript("OnUpdate", nil)
      return
    end
    
    local now = GetTime()
    if now - lastIconUpdate >= 0.3 then
      toggleMinimapButtonIcon()
      lastIconUpdate = now
    end
  end)
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