--------------------------------------------------
-- Public API - External Addon Interface
--------------------------------------------------

if not AutoLFM_API then
  AutoLFM_API = {}
end

--------------------------------------------------
-- API Version
--------------------------------------------------
function AutoLFM_API.GetVersion()
  return API_VERSION
end

--------------------------------------------------
-- Availability Check
--------------------------------------------------
function AutoLFM_API.IsAvailable()
  return (AutoLFM_MainFrame ~= nil and
          type(GetSelectedDungeonsList) == "function" and
          type(GetSelectedRaidsList) == "function" and
          type(GetSelectedRolesList) == "function")
end

--------------------------------------------------
-- Get Full Status
--------------------------------------------------
function AutoLFM_API.GetFullStatus()
  local status = {
    groupType = AutoLFM_API.GetGroupType(),
    selectedContent = AutoLFM_API.GetSelectedContent(),
    playerCount = AutoLFM_API.GetPlayerCount(),
    rolesNeeded = AutoLFM_API.GetRolesNeeded(),
    dynamicMessage = AutoLFM_API.GetDynamicMessage(),
    selectedChannels = AutoLFM_API.GetSelectedChannels(),
    broadcastStats = AutoLFM_API.GetBroadcastStats(),
    timing = AutoLFM_API.GetTiming()
  }
  return status
end

--------------------------------------------------
-- Get Group Type
--------------------------------------------------
function AutoLFM_API.GetGroupType()
  local selectedDungeons = GetSelectedDungeonsList()
  local selectedRaids = GetSelectedRaidsList()

  if table.getn(selectedRaids) > 0 then
    return "raid"
  elseif table.getn(selectedDungeons) > 0 then
    return "dungeon"
  else
    return "other"
  end
end

--------------------------------------------------
-- Get Selected Content
--------------------------------------------------
function AutoLFM_API.GetSelectedContent()
  local groupType = AutoLFM_API.GetGroupType()
  local content = {
    type = groupType,
    list = {},
    details = {}
  }
  
  if groupType == "dungeon" then
    local selectedDungeons = GetSelectedDungeonsList()
    for _, dungeonTag in ipairs(selectedDungeons) do
      table.insert(content.list, dungeonTag)
      local dungeon = GetDungeonByTag(dungeonTag)
      if dungeon then
        content.details[dungeonTag] = {
          name = dungeon.name or "",
          tag = dungeon.tag or "",
          levelMin = dungeon.levelMin or 1,
          levelMax = dungeon.levelMax or 60
        }
      end
    end
  elseif groupType == "raid" then
    local selectedRaids = GetSelectedRaidsList()
    for _, raidTag in ipairs(selectedRaids) do
      table.insert(content.list, raidTag)
      local raid = GetRaidByTag(raidTag)
      if raid then
        content.details[raidTag] = {
          name = raid.name or "",
          tag = raid.tag or "",
          sizeMin = raid.sizeMin or 10,
          sizeMax = raid.sizeMax or 40
        }
      end
    end
  end
  
  return content
end

--------------------------------------------------
-- Get Player Count
--------------------------------------------------
function AutoLFM_API.GetPlayerCount()
  local groupType = AutoLFM_API.GetGroupType()
  local currentInGroup = 0
  local desiredTotal = 0
  local missing = 0
  
  if GetNumRaidMembers() > 0 then
    currentInGroup = GetNumRaidMembers()
  else
    currentInGroup = GetPartyMemberCount()
  end
  
  if not currentInGroup or currentInGroup < 1 then
    currentInGroup = 1
  end
  
  if groupType == "raid" then
    desiredTotal = GetRaidGroupSize()
    if desiredTotal < 1 then
      desiredTotal = DEFAULT_RAID_SIZE
    end
  else
    desiredTotal = DEFAULT_DUNGEON_SIZE
  end
  
  missing = desiredTotal - currentInGroup
  if missing < 0 then missing = 0 end
  
  return {
    currentInGroup = currentInGroup,
    desiredTotal = desiredTotal,
    missing = missing
  }
end

--------------------------------------------------
-- Get Roles Needed
--------------------------------------------------
function AutoLFM_API.GetRolesNeeded()
  local selectedRoles = GetSelectedRolesList()
  local rolesList = {}
  
  if selectedRoles and type(selectedRoles) == "table" then
    for _, role in ipairs(selectedRoles) do
      table.insert(rolesList, role)
    end
  end

  return rolesList
end

--------------------------------------------------
-- Get Dynamic Message
--------------------------------------------------
function AutoLFM_API.GetDynamicMessage()
  local combined = GetGeneratedLFMMessage()
  local userInput = GetCustomUserMessage()

  return {
    combined = combined,
    userInput = userInput,
    hasUserInput = (userInput ~= "")
  }
end

--------------------------------------------------
-- Get Selected Channels
--------------------------------------------------
function AutoLFM_API.GetSelectedChannels()
  local channels = GetSelectedChannelsList()
  local channelList = {}

  if channels and type(channels) == "table" then
    for channelName, _ in pairs(channels) do
      table.insert(channelList, channelName)
    end
  end

  return channelList
end

--------------------------------------------------
-- Get Broadcast Stats
--------------------------------------------------
function AutoLFM_API.GetBroadcastStats()
  local stats = GetBroadcastStats()
  
  local searchDuration = 0
  if stats.searchStartTimestamp and stats.searchStartTimestamp > 0 then
    searchDuration = GetTime() - stats.searchStartTimestamp
  end
  
  return {
    isActive = stats.isActive,
    messagesSent = stats.messageCount,
    searchDuration = searchDuration
  }
end

--------------------------------------------------
-- Get Timing
--------------------------------------------------
function AutoLFM_API.GetTiming()
  local interval = DEFAULT_BROADCAST_INTERVAL
  local nextBroadcast = 0
  local timeUntilNext = 0
  
  -- This will be set by UI slider if available
  if broadcastIntervalSlider and broadcastIntervalSlider.GetValue then
    interval = broadcastIntervalSlider:GetValue() or DEFAULT_BROADCAST_INTERVAL
  end
  
  local stats = GetBroadcastStats()
  
  if stats.isActive and stats.lastTimestamp and stats.lastTimestamp > 0 then
    nextBroadcast = stats.lastTimestamp + interval
    timeUntilNext = nextBroadcast - GetTime()
    if timeUntilNext < 0 then timeUntilNext = 0 end
  end

  return {
    intervalSeconds = interval,
    timeUntilNext = timeUntilNext
  }
end

--------------------------------------------------
-- Print API Data (debug)
--------------------------------------------------
function AutoLFM_API.DataPrint()
  if not AutoLFM_API.IsAvailable() then
    if AutoLFM_PrintError then
      AutoLFM_PrintError("API not available")
    end
    return
  end

  local status = AutoLFM_API.GetFullStatus()

  if AutoLFM_PrintSuccess then AutoLFM_PrintSuccess("API Data:") end
  if AutoLFM_PrintMessage then
    AutoLFM_PrintMessage(ColorizeText("Group Type: ","gray") .. (status.groupType or "unknown"))
    AutoLFM_PrintMessage(ColorizeText("Content: ","gray") .. table.getn(status.selectedContent.list) .. " items")
    AutoLFM_PrintMessage(ColorizeText("Players: ","gray") .. status.playerCount.currentInGroup .. "/" .. status.playerCount.desiredTotal .. " (missing: " .. status.playerCount.missing .. ")")
    AutoLFM_PrintMessage(ColorizeText("Roles: ","gray") .. table.concat(status.rolesNeeded, ", "))
    AutoLFM_PrintMessage(ColorizeText("Message: ","gray") .. (status.dynamicMessage.combined or ""))
    AutoLFM_PrintMessage(ColorizeText("Channels: ","gray") .. table.concat(status.selectedChannels, ", "))
    AutoLFM_PrintMessage(ColorizeText("Broadcasting: ","gray") .. (status.broadcastStats.isActive and "Yes" or "No"))
    AutoLFM_PrintMessage(ColorizeText("Messages sent: ","gray") .. status.broadcastStats.messagesSent)
    AutoLFM_PrintMessage(ColorizeText("Search duration: ","gray") .. math.floor(status.broadcastStats.searchDuration) .. "s")
    AutoLFM_PrintMessage(ColorizeText("Next broadcast in: ","gray") .. math.floor(status.timing.timeUntilNext) .. "s")
  end
end

--------------------------------------------------
-- Callback System
--------------------------------------------------
AutoLFM_API.callbacks = AutoLFM_API.callbacks or {}

function AutoLFM_API.RegisterCallback(addonName, callback)
  if not addonName or not callback then return end
  AutoLFM_API.callbacks[addonName] = callback
end

function AutoLFM_API.UnregisterCallback(addonName)
  if not addonName then return end
  AutoLFM_API.callbacks[addonName] = nil
end

function AutoLFM_API.NotifyDataChanged(eventType)
  if not AutoLFM_API.callbacks then return end
  
  for addonName, callback in pairs(AutoLFM_API.callbacks) do
    if type(callback) == "function" then
      local success, err = pcall(callback, AutoLFM_API.GetFullStatus(), eventType)
      if not success and AutoLFM_PrintError then
        AutoLFM_PrintError("Callback error for " .. tostring(addonName) .. ": " .. tostring(err))
      end
    end
  end
end