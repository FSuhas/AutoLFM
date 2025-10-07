--------------------------------------------------
-- Broadcast Manager - Broadcast Logic
--------------------------------------------------

--------------------------------------------------
-- Validate Broadcast Configuration
--------------------------------------------------
function ValidateBroadcastConfiguration()
  local errors = {}
  
  -- Check message
  if not generatedLFMMessage or generatedLFMMessage == "" or generatedLFMMessage == " " then
    table.insert(errors, "The LFM message is empty")
  end
  
  -- Check channels
  if not selectedChannelsList or not next(selectedChannelsList) then
    table.insert(errors, "No channel selected")
  else
    local invalidChannels = {}
    for channelName, _ in pairs(selectedChannelsList) do
      if not IsChannelAvailable(channelName) then
        table.insert(invalidChannels, channelName)
      end
    end
    
    if table.getn(invalidChannels) > 0 then
      for _, channelName in ipairs(invalidChannels) do
        table.insert(errors, "Channel '" .. channelName .. "' is invalid or closed")
      end
    end
  end
  
  -- Check content selection
  local selectedRaids = GetSelectedRaidsList()
  local selectedDungeons = GetSelectedDungeonsList()
  local hasUserMessage = customUserMessage and customUserMessage ~= ""
  
  if not hasUserMessage then
    if table.getn(selectedRaids) == 0 and table.getn(selectedDungeons) == 0 then
      table.insert(errors, "No dungeon/raid selected or no custom message set")
    end
  end
  
  -- Check dungeon group size
  if table.getn(selectedDungeons) > 0 then
    local groupSize = GetPartyMemberCount()
    
    if groupSize >= DEFAULT_DUNGEON_SIZE then
      table.insert(errors, "Your dungeon group is already full (" .. DEFAULT_DUNGEON_SIZE .. "/" .. DEFAULT_DUNGEON_SIZE .. ")")
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
    if AutoLFM_PrintError then
      AutoLFM_PrintError("Message is empty")
    end
    return false
  end
  
  if not selectedChannelsList then
    selectedChannelsList = {}
  end
  
  if not next(selectedChannelsList) then
    if AutoLFM_PrintError then
      AutoLFM_PrintError("No channel selected")
    end
    return false
  end
  
  local sentCount = 0
  local invalidChannels = {}
  
  for channelName, _ in pairs(selectedChannelsList) do
    -- Skip Hardcore channel (it's not a real broadcast channel)
    if channelName ~= "Hardcore" then
      local channelId = GetChannelIdByName(channelName)
      if channelId then
        SendChatMessage(message, "CHANNEL", nil, channelId)
        sentCount = sentCount + 1
      else
        table.insert(invalidChannels, channelName)
      end
    end
  end
  
  if table.getn(invalidChannels) > 0 then
    for _, channelName in ipairs(invalidChannels) do
      if AutoLFM_PrintError then
        AutoLFM_PrintError("The channel " .. channelName .. " is invalid or closed")
      end
    end
    if sentCount == 0 then
      if AutoLFM_PrintError then
        AutoLFM_PrintError("Message not sent: all channels are invalid")
      end
      return false
    end
  end
  
  broadcastMessageCount = (broadcastMessageCount or 0) + 1
  lastBroadcastTimestamp = GetTime()
  
  return true
end

--------------------------------------------------
-- Start Broadcast
--------------------------------------------------
function StartBroadcast()
  local isValid, errors = ValidateBroadcastConfiguration()
  
  if not isValid then
    if AutoLFM_PrintError then
      AutoLFM_PrintError("Broadcast cannot start:")
      for _, error in ipairs(errors) do
        AutoLFM_PrintError("  - " .. error)
      end
    end
    return false
  end
  
  isBroadcastActive = true
  broadcastStartTimestamp = GetTime()
  lastBroadcastTimestamp = broadcastStartTimestamp
  groupSearchStartTimestamp = broadcastStartTimestamp
  broadcastMessageCount = 0
  
  if AutoLFM_PrintInfo then
    AutoLFM_PrintInfo("Broadcast started")
  end
  
  SendMessageToChannels(generatedLFMMessage)
  
  if StartBroadcastAnimation then
    StartBroadcastAnimation()
  end
  
  return true
end

--------------------------------------------------
-- Stop Broadcast
--------------------------------------------------
function StopBroadcast()
  isBroadcastActive = false
  
  if AutoLFM_PrintInfo then
    AutoLFM_PrintInfo("Broadcast stopped")
  end
  
  if StopBroadcastAnimation then
    StopBroadcastAnimation()
  end
  
  broadcastMessageCount = 0
end

--------------------------------------------------
-- Check if Broadcast is Active
--------------------------------------------------
function IsBroadcastActive()
  return isBroadcastActive or false
end

--------------------------------------------------
-- Get Broadcast Stats
--------------------------------------------------
function GetBroadcastStats()
  return {
    isActive = isBroadcastActive or false,
    startTimestamp = broadcastStartTimestamp or 0,
    lastTimestamp = lastBroadcastTimestamp or 0,
    messageCount = broadcastMessageCount or 0,
    searchStartTimestamp = groupSearchStartTimestamp or 0
  }
end

--------------------------------------------------
-- Reset Broadcast Stats
--------------------------------------------------
function ResetBroadcastStats()
  broadcastMessageCount = 0
  broadcastStartTimestamp = 0
  lastBroadcastTimestamp = 0
  groupSearchStartTimestamp = 0
end