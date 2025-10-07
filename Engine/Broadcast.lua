--------------------------------------------------
-- Broadcast Management
--------------------------------------------------
local broadcastFrame = nil

--------------------------------------------------
-- Validate Broadcast Setup
--------------------------------------------------
function ValidateBroadcastConfiguration()
  local errors = {}
  
  if not generatedLFMMessage or generatedLFMMessage == "" or generatedLFMMessage == " " then
    table.insert(errors, "The LFM message is empty")
  end
  
  if not selectedChannelsList or not next(selectedChannelsList) then
    table.insert(errors, "No channel selected")
  else
    local invalidChannels = {}
    for channelName, _ in pairs(selectedChannelsList) do
      local channelId = GetChannelName(channelName)
      if not (channelId and channelId > 0) then
        table.insert(invalidChannels, channelName)
      end
    end
    
    if table.getn(invalidChannels) > 0 then
      for _, channelName in ipairs(invalidChannels) do
        table.insert(errors, "Channel '" .. channelName .. "' is invalid or closed")
      end
    end
  end
  
  local selectedRaidsLocal = GetSelectedRaidsList and GetSelectedRaidsList() or {}
  local selectedDungeonsLocal = GetSelectedDungeonsList and GetSelectedDungeonsList() or {}
  local hasUserMessage = customUserMessage and customUserMessage ~= ""
  
  if not hasUserMessage then
    if table.getn(selectedRaidsLocal) == 0 and table.getn(selectedDungeonsLocal) == 0 then
      table.insert(errors, "No dungeon or raid selected")
    end
  end
  
  if table.getn(selectedDungeonsLocal) > 0 then
    local groupSize = 1
    if GetPartyMemberCount and type(GetPartyMemberCount) == "function" then
      groupSize = GetPartyMemberCount()
    else
      groupSize = GetNumPartyMembers() + 1
    end
    
    if groupSize >= 5 then
      table.insert(errors, "Your dungeon group is already full (5/5)")
    end
  end
  
  if table.getn(errors) > 0 then
    return false, errors
  end
  
  return true, nil
end

--------------------------------------------------
-- Send Message to Selected Channels
--------------------------------------------------
function SendMessageToChannels(message)
  if not message or message == "" then
    AutoLFM_PrintError("Message is empty")
    return false
  end
  
  if not selectedChannelsList then
    selectedChannelsList = {}
  end
  
  if not next(selectedChannelsList) then
    AutoLFM_PrintError("No channel selected")
    return false
  end
  
  local sentCount = 0
  local invalidChannels = {}
  
  for channelName, _ in pairs(selectedChannelsList) do
    local channelId = GetChannelName(channelName)
    if channelId and channelId > 0 then
      SendChatMessage(message, "CHANNEL", nil, channelId)
      sentCount = sentCount + 1
    else
      table.insert(invalidChannels, channelName)
    end
  end
  
  if table.getn(invalidChannels) > 0 then
    for _, channelName in ipairs(invalidChannels) do
      AutoLFM_PrintError("The channel " .. channelName .. " is invalid or closed")
    end
    if sentCount == 0 then
      AutoLFM_PrintError("Message not sent: all channels are invalid")
      return false
    end
  end
  
  broadcastMessageCount = (broadcastMessageCount or 0) + 1
  return true
end

--------------------------------------------------
-- Start Broadcast
--------------------------------------------------
function StartBroadcast()
  local isValid, errors = ValidateBroadcastConfiguration()
  
  if not isValid then
    AutoLFM_PrintError("Broadcast cannot start:")
    for _, error in ipairs(errors) do
      AutoLFM_PrintError("  - " .. error)
    end
    return false
  end
  
  isBroadcastActive = true
  broadcastStartTimestamp = GetTime()
  lastBroadcastTimestamp = broadcastStartTimestamp
  AutoLFM_PrintInfo("Broadcast started")
  
  SendMessageToChannels(generatedLFMMessage)
  StartBroadcastAnimation()
  
  return true
end

--------------------------------------------------
-- Broadcast Loop
--------------------------------------------------
if not broadcastFrame then
  broadcastFrame = CreateFrame("Frame")
end

local lastUpdateCheck = 0
local UPDATE_THROTTLE = 1.0

broadcastFrame:SetScript("OnUpdate", function()
  if not isBroadcastActive then return end
  
  local currentTime = GetTime()
  
  if currentTime - lastUpdateCheck < UPDATE_THROTTLE then
    return
  end
  lastUpdateCheck = currentTime
  
  if not broadcastIntervalSlider then return end
  if not lastBroadcastTimestamp then
    lastBroadcastTimestamp = currentTime
    return
  end
  
  local sliderValue = broadcastIntervalSlider:GetValue()
  if not sliderValue or sliderValue < 1 then
    sliderValue = 80
  end
  
  local timeElapsed = currentTime - lastBroadcastTimestamp
  
  if timeElapsed >= sliderValue then
    if generatedLFMMessage and generatedLFMMessage ~= "" and generatedLFMMessage ~= " " then
      local success = SendMessageToChannels(generatedLFMMessage)
      if success then
        lastBroadcastTimestamp = currentTime
      else
        StopBroadcast()
        if broadcastToggleButton then
          broadcastToggleButton:SetText("Start")
        end
      end
    end
  end
end)

--------------------------------------------------
-- Stop Broadcast
--------------------------------------------------
function StopBroadcast()
  isBroadcastActive = false
  AutoLFM_PrintInfo("Broadcast stopped")
  
  StopBroadcastAnimation()
  broadcastMessageCount = 0
end