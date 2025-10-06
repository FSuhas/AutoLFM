---------------------------------------------------------------------------------
--                               AutoLFM API                                   --
---------------------------------------------------------------------------------
--   AutoLFM_API.GetFullStatus() :
--   {
--       groupType = "dungeon|raid|other",
--       selectedContent = { type, list[], details{} },
--       playerCount = { currentInGroup, desiredTotal, missing },
--       rolesNeeded = { "tank", "heal", "dps" },
--       dynamicMessage = { combined, userInput, hasUserInput },
--       selectedChannels = { "LookingForGroup", "World", ... },
--       broadcastStats = { isActive, messagesSent, searchDuration },
--       timing = { intervalSeconds, timeUntilNext }
--   }
--
--   AutoLFM_API.GetGroupType()          - string
--   AutoLFM_API.GetSelectedContent()    - table
--   AutoLFM_API.GetPlayerCount()        - table
--   AutoLFM_API.GetRolesNeeded()        - array
--   AutoLFM_API.GetDynamicMessage()     - table
--   AutoLFM_API.GetSelectedChannels()   - array
--   AutoLFM_API.GetBroadcastStats()     - table
--   AutoLFM_API.GetTiming()             - table
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
    local selectedDungeons = GetSelectedDungeons() or {}
    for _, dungeonTag in ipairs(selectedDungeons) do
      table.insert(content.list, dungeonTag)
      for _, dungeon in pairs(dungeons) do
        if dungeon.tag == dungeonTag then
          content.details[dungeonTag] = {
            name = dungeon.name,
            tag = dungeon.tag,
            levelMin = dungeon.levelMin,
            levelMax = dungeon.levelMax
          }
          break
        end
      end
    end
  elseif groupType == "raid" then
    local selectedRaids = GetSelectedRaids() or {}
    for _, raidTag in ipairs(selectedRaids) do
      table.insert(content.list, raidTag)
      for _, raid in pairs(raids) do
        if raid.tag == raidTag then
          content.details[raidTag] = {
            name = raid.name,
            tag = raid.tag,
            sizeMin = raid.sizeMin,
            sizeMax = raid.sizeMax
          }
          break
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
    if countGroupMembers then
      currentInGroup = countGroupMembers()
    else
      currentInGroup = GetNumPartyMembers() + 1
    end
  end
  
  if groupType == "raid" then
    desiredTotal = sliderValue or 0
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
  for _, role in ipairs(selectedRolesData) do
    table.insert(rolesList, role)
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

  for channelName, _ in pairs(channels) do
    table.insert(channelList, channelName)
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

  if searchStart > 0 then
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
    AutoLFM_PrintError("API not available")
    return
  end

  local status = AutoLFM_API.GetFullStatus()

  AutoLFM_PrintInfo("[Debug]")
  AutoLFM_Print("Group Type: " .. status.groupType)
  AutoLFM_Print("Content: " .. table.getn(status.selectedContent.list) .. " items")
  AutoLFM_Print("Players: " .. status.playerCount.currentInGroup .. "/" .. status.playerCount.desiredTotal .. " (missing: " .. status.playerCount.missing .. ")")
  AutoLFM_Print("Roles: " .. table.concat(status.rolesNeeded, ", "))
  AutoLFM_Print("Message: " .. status.dynamicMessage.combined)
  AutoLFM_Print("Channels: " .. table.concat(status.selectedChannels, ", "))
  AutoLFM_Print("Broadcasting: " .. (status.broadcastStats.isActive and "Yes" or "No"))
  AutoLFM_Print("Messages sent: " .. status.broadcastStats.messagesSent)
  AutoLFM_Print("Search duration: " .. math.floor(status.broadcastStats.searchDuration) .. "s")
  AutoLFM_Print("Next broadcast in: " .. math.floor(status.timing.timeUntilNext) .. "s")
end

AutoLFM_API.callbacks = AutoLFM_API.callbacks or {}

function AutoLFM_API.RegisterCallback(addonName, callback)
  AutoLFM_API.callbacks[addonName] = callback
end

function AutoLFM_API.UnregisterCallback(addonName)
  AutoLFM_API.callbacks[addonName] = nil
end

function AutoLFM_API.NotifyDataChanged(eventType)
  if not AutoLFM_API.callbacks then return end
  
  for addonName, callback in pairs(AutoLFM_API.callbacks) do
    if type(callback) == "function" then
      local success, err = pcall(callback, AutoLFM_API.GetFullStatus(), eventType)
      if not success then
        AutoLFM_PrintError("Callback error for " .. addonName .. ": " .. tostring(err))
      end
    end
  end
end