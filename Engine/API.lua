---------------------------------------------------------------------------------
--                               AutoLFM API                                   --
---------------------------------------------------------------------------------
if not AutoLFM_API then
  AutoLFM_API = {}
end

local API_VERSION = "1.0.0"
local DEFAULT_DUNGEON_SIZE = 5

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

function AutoLFM_API.GetGroupType()
  local selectedDungeons = GetSelectedDungeons and GetSelectedDungeons() or {}
  local selectedRaids = GetSelectedRaids and GetSelectedRaids() or {}

  if table.getn(selectedRaids) > 0 then
    return "raid"
  elseif table.getn(selectedDungeons) > 0 then
    return "dungeon"
  else
    return "other"
  end
end

function AutoLFM_API.GetSelectedContent()
  local groupType = AutoLFM_API.GetGroupType()
  local content = {
    type = groupType,
    list = {},
    details = {}
  }
  
  if groupType == "dungeon" then
    local selectedDungeons = GetSelectedDungeons and GetSelectedDungeons() or {}
    for _, dungeonTag in ipairs(selectedDungeons) do
      table.insert(content.list, dungeonTag)
      if dungeons then
        for _, dungeon in pairs(dungeons) do
          if dungeon and dungeon.tag == dungeonTag then
            content.details[dungeonTag] = {
              name = dungeon.name or "",
              tag = dungeon.tag or "",
              levelMin = dungeon.levelMin or 1,
              levelMax = dungeon.levelMax or 60
            }
            break
          end
        end
      end
    end
  elseif groupType == "raid" then
    local selectedRaids = GetSelectedRaids and GetSelectedRaids() or {}
    for _, raidTag in ipairs(selectedRaids) do
      table.insert(content.list, raidTag)
      if raids then
        for _, raid in pairs(raids) do
          if raid and raid.tag == raidTag then
            content.details[raidTag] = {
              name = raid.name or "",
              tag = raid.tag or "",
              sizeMin = raid.sizeMin or 10,
              sizeMax = raid.sizeMax or 40
            }
            break
          end
        end
      end
    end
  end
  return content
end

function AutoLFM_API.GetPlayerCount()
  local groupType = AutoLFM_API.GetGroupType()
  local currentInGroup = 0
  local desiredTotal = 0
  local missing = 0
  
  if GetNumRaidMembers() > 0 then
    currentInGroup = GetNumRaidMembers()
  else
    if countGroupMembers and type(countGroupMembers) == "function" then
      currentInGroup = countGroupMembers()
    else
      currentInGroup = GetNumPartyMembers() + 1
    end
  end
  
  if not currentInGroup or currentInGroup < 1 then
    currentInGroup = 1
  end
  
  if groupType == "raid" then
    desiredTotal = sliderValue or 0
    if desiredTotal < 1 then
      desiredTotal = 10
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

function AutoLFM_API.GetRolesNeeded()
  local selectedRolesData = {}
  
  if GetSelectedRoles then
    selectedRolesData = GetSelectedRoles()
  elseif selectedRoles then
    selectedRolesData = selectedRoles
  end
  
  local rolesList = {}
  if selectedRolesData then
    for _, role in ipairs(selectedRolesData) do
      table.insert(rolesList, role)
    end
  end

  return rolesList
end

function AutoLFM_API.GetDynamicMessage()
  local combined = ""
  if GetCombinedMessage then
    combined = GetCombinedMessage()
  elseif combinedMessage then
    combined = combinedMessage
  end
  
  local userInput = userInputMessage or ""

  return {
    combined = combined,
    userInput = userInput,
    hasUserInput = (userInput ~= "")
  }
end

function AutoLFM_API.GetSelectedChannels()
  local channels = selectedChannels or {}
  local channelList = {}

  if channels then
    for channelName, _ in pairs(channels) do
      table.insert(channelList, channelName)
    end
  end

  return channelList
end

function AutoLFM_API.GetBroadcastStats()
  local broadcasting = isBroadcasting or false
  local startTime = broadcastStartTime or 0
  local lastTime = lastBroadcastTime or 0
  local searchStart = searchStartTime or 0
  local msgCount = messagesSentCount or 0

  local stats = {
    isActive = broadcasting,
    messagesSent = msgCount,
    searchDuration = 0
  }

  local currentTime = GetTime()

  if searchStart and searchStart > 0 then
    stats.searchDuration = currentTime - searchStart
  end

  return stats
end

function AutoLFM_API.GetTiming()
  local interval = slider and slider:GetValue() or 80
  local nextBroadcast = 0
  local timeUntilNext = 0

  if isBroadcasting and lastBroadcastTime and lastBroadcastTime > 0 then
    nextBroadcast = lastBroadcastTime + interval
    timeUntilNext = nextBroadcast - GetTime()
    if timeUntilNext < 0 then timeUntilNext = 0 end
  end

  return {
    intervalSeconds = interval,
    timeUntilNext = timeUntilNext
  }
end

function AutoLFM_API.IsAvailable()
  return (AutoLFM ~= nil and
          type(GetSelectedDungeons) == "function" and
          type(GetSelectedRaids) == "function" and
          type(GetSelectedRoles) == "function")
end

function AutoLFM_API.GetVersion()
  return API_VERSION
end

function AutoLFM_API.DebugPrint()
  if not AutoLFM_API.IsAvailable() then
    if AutoLFM_PrintError then
      AutoLFM_PrintError("API not available")
    end
    return
  end

  local status = AutoLFM_API.GetFullStatus()

  if AutoLFM_PrintInfo then AutoLFM_PrintInfo("[Debug]") end
  if AutoLFM_Print then
    AutoLFM_Print("Group Type: " .. (status.groupType or "unknown"))
    AutoLFM_Print("Content: " .. table.getn(status.selectedContent.list) .. " items")
    AutoLFM_Print("Players: " .. status.playerCount.currentInGroup .. "/" .. status.playerCount.desiredTotal .. " (missing: " .. status.playerCount.missing .. ")")
    AutoLFM_Print("Roles: " .. table.concat(status.rolesNeeded, ", "))
    AutoLFM_Print("Message: " .. (status.dynamicMessage.combined or ""))
    AutoLFM_Print("Channels: " .. table.concat(status.selectedChannels, ", "))
    AutoLFM_Print("Broadcasting: " .. (status.broadcastStats.isActive and "Yes" or "No"))
    AutoLFM_Print("Messages sent: " .. status.broadcastStats.messagesSent)
    AutoLFM_Print("Search duration: " .. math.floor(status.broadcastStats.searchDuration) .. "s")
    AutoLFM_Print("Next broadcast in: " .. math.floor(status.timing.timeUntilNext) .. "s")
  end
end

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