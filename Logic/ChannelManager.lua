--------------------------------------------------
-- Channel Manager - Channel Logic
--------------------------------------------------

--------------------------------------------------
-- Find Available Channels
--------------------------------------------------
function FindAvailableChannels()
  local foundChannels = {}
  
  if not AVAILABLE_CHANNELS or table.getn(AVAILABLE_CHANNELS) == 0 then
    return foundChannels
  end
  
  for _, channelName in ipairs(AVAILABLE_CHANNELS) do
    if channelName then
      -- Special case: Always show Hardcore even if not a real channel
      if channelName == "Hardcore" then
        table.insert(foundChannels, {
          name = channelName,
          id = 0  -- Dummy ID for Hardcore
        })
      else
        -- Regular channel check
        local channelId = GetChannelName(channelName)
        if channelId and channelId > 0 then
          table.insert(foundChannels, {
            name = channelName,
            id = channelId
          })
        end
      end
    end
  end
  
  return foundChannels
end
--------------------------------------------------
-- Toggle Channel Selection
--------------------------------------------------
function ToggleChannelSelection(channelName, isSelected)
  if not selectedChannelsList then selectedChannelsList = {} end
  if not channelName then return end
  
  if isSelected then
    selectedChannelsList[channelName] = true
  else
    selectedChannelsList[channelName] = nil
  end
  
  SaveChannelSelection()
end

--------------------------------------------------
-- Get Selected Channels List
--------------------------------------------------
function GetSelectedChannelsList()
  return selectedChannelsList or {}
end

--------------------------------------------------
-- Check if Channel is Selected
--------------------------------------------------
function IsChannelSelected(channelName)
  if not channelName then return false end
  if not selectedChannelsList then return false end
  
  return selectedChannelsList[channelName] == true
end

--------------------------------------------------
-- Check if Channel is Available
--------------------------------------------------
function IsChannelAvailable(channelName)
  if not channelName then return false end
  
  local channelId = GetChannelName(channelName)
  return channelId and channelId > 0
end

--------------------------------------------------
-- Get Channel ID by Name
--------------------------------------------------
function GetChannelIdByName(channelName)
  if not channelName then return nil end
  
  local channelId = GetChannelName(channelName)
  if channelId and channelId > 0 then
    return channelId
  end
  
  return nil
end

--------------------------------------------------
-- Get Selected Channels Count
--------------------------------------------------
function GetSelectedChannelsCount()
  if not selectedChannelsList then return 0 end
  
  local count = 0
  for _ in pairs(selectedChannelsList) do
    count = count + 1
  end
  
  return count
end

--------------------------------------------------
-- Validate Selected Channels
--------------------------------------------------
function ValidateSelectedChannels()
  if not selectedChannelsList then return {} end
  
  local validChannels = {}
  local invalidChannels = {}
  
  for channelName, _ in pairs(selectedChannelsList) do
    if IsChannelAvailable(channelName) then
      table.insert(validChannels, channelName)
    else
      table.insert(invalidChannels, channelName)
    end
  end
  
  return validChannels, invalidChannels
end

--------------------------------------------------
-- Clear All Channel Selections
--------------------------------------------------
function ClearAllChannelSelections()
  selectedChannelsList = {}
  SaveChannelSelection()
end