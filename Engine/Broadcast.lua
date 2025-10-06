--------------------------------------------------
-- Broadcast Management
--------------------------------------------------
local broadcastFrame = nil

--------------------------------------------------
-- Validate Broadcast Setup
--------------------------------------------------
function ValidateBroadcastSetup()
  local errors = {}
  
  -- Check message
  if not combinedMessage or combinedMessage == "" or combinedMessage == " " then
    table.insert(errors, "The LFM message is empty")
  end
  
  -- Check channels
  if not selectedChannels or not next(selectedChannels) then
    table.insert(errors, "No channel selected")
  else
    -- Validate each channel
    local invalidChannels = {}
    for channelName, _ in pairs(selectedChannels) do
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
  
  -- Check if content is selected
  local selectedRaidsLocal = GetSelectedRaids and GetSelectedRaids() or {}
  local selectedDungeonsLocal = GetSelectedDungeons and GetSelectedDungeons() or {}
  
  if table.getn(selectedRaidsLocal) == 0 and table.getn(selectedDungeonsLocal) == 0 then
    table.insert(errors, "No dungeon or raid selected")
  end
  
  -- Check dungeon group size (but allow raid at any size)
  if table.getn(selectedDungeonsLocal) > 0 then
    local groupSize = 1
    if countGroupMembers and type(countGroupMembers) == "function" then
      groupSize = countGroupMembers()
    else
      groupSize = GetNumPartyMembers() + 1
    end
    
    if groupSize >= 5 then
      table.insert(errors, "Your dungeon group is already full (5/5)")
    end
  end
  
  -- Return validation result
  if table.getn(errors) > 0 then
    return false, errors
  end
  
  return true, nil
end

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
  -- Use centralized validation
  local isValid, errors = ValidateBroadcastSetup()
  
  if not isValid then
    AutoLFM_PrintError("Broadcast cannot start:")
    for _, error in ipairs(errors) do
      AutoLFM_PrintError("  - " .. error)
    end
    return false
  end
  
  isBroadcasting = true
  broadcastStartTime = GetTime()
  lastBroadcastTime = broadcastStartTime
  AutoLFM_PrintInfo("Broadcast started")
  
  sendMessageToSelectedChannels(combinedMessage)
  StartIconAnimation()
  
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