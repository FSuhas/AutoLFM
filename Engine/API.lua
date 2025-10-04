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
--
--   /lfmapi
---------------------------------------------------------------------------------

if not AutoLFM_API then
    AutoLFM_API = {}
end

local API_VERSION = "1.0.0"
local DEFAULT_DUNGEON_SIZE = 5

-- Utilitaire pour affichage
local function Print(msg)
    local prefix = "|cff00ff00[AutoLFM API]|r "
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. (msg or ""))
end

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

-- Détermine le type de groupe
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
        for _, dungeonAbrev in ipairs(selectedDungeons) do
            table.insert(content.list, dungeonAbrev)
            for _, donjon in pairs(donjons) do
                if donjon.abrev == dungeonAbrev then
                    content.details[dungeonAbrev] = {
                        name = donjon.nom,
                        abrev = donjon.abrev,
                        size = donjon.size,
                        levelMin = donjon.lvl_min,
                        levelMax = donjon.lvl_max
                    }
                    break
                end
            end
        end
    elseif groupType == "raid" then
        local selectedRaids = GetSelectedRaids() or {}
        for _, raidAbrev in ipairs(selectedRaids) do
            table.insert(content.list, raidAbrev)
            for _, raid in pairs(raids) do
                if raid.abrev == raidAbrev then
                    content.details[raidAbrev] = {
                        name = raid.nom,
                        abrev = raid.abrev,
                        sizeMin = raid.size_min,
                        sizeMax = raid.size_max
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
    currentInGroup = countGroupMembers and countGroupMembers() or 0
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
    local selectedRoles = GetSelectedRoles and GetSelectedRoles() or {}
    local rolesList = {}

    for _, role in ipairs(selectedRoles) do
        table.insert(rolesList, role)
    end

    return rolesList
end

function AutoLFM_API.GetDynamicMessage()
    local combined = GetCombinedMessage and GetCombinedMessage() or ""
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

-- Stats de broadcast
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

-- Timing
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

-- Vérifie si l’API est dispo
function AutoLFM_API.IsAvailable()
    return (AutoLFM ~= nil and
            type(GetSelectedDungeons) == "function" and
            type(GetSelectedRaids) == "function" and
            type(GetSelectedRoles) == "function")
end

-- Version
function AutoLFM_API.GetVersion()
    return API_VERSION
end

-- Debug print
function AutoLFM_API.DebugPrint()
    if not AutoLFM_API.IsAvailable() then
        Print("|cffff0000API not available|r")
        return
    end

    local status = AutoLFM_API.GetFullStatus()

    Print("[Debug]")
    Print("Group Type: " .. status.groupType)
    Print("Content: " .. table.getn(status.selectedContent.list) .. " items")
    Print("Players: " .. status.playerCount.currentInGroup .. "/" .. status.playerCount.desiredTotal .. " (missing: " .. status.playerCount.missing .. ")")
    Print("Roles: " .. table.concat(status.rolesNeeded, ", "))
    Print("Message: " .. status.dynamicMessage.combined)
    Print("Channels: " .. table.concat(status.selectedChannels, ", "))
    Print("Broadcasting: " .. (status.broadcastStats.isActive and "Yes" or "No"))
    Print("Messages sent: " .. status.broadcastStats.messagesSent)
    Print("Search duration: " .. math.floor(status.broadcastStats.searchDuration) .. "s")
    Print("Next broadcast in: " .. math.floor(status.timing.timeUntilNext) .. "s")
end

-- Callbacks
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
        DEFAULT_CHAT_FRAME:AddMessage("[AutoLFM API] Callback error for " .. addonName .. ": " .. tostring(err))
      end
    end
  end
end

-- Slash command
SLASH_LFMAPI1 = "/lfmapi"
SlashCmdList["LFMAPI"] = function(msg)
    if msg == "debug" then
        AutoLFM_API.DebugPrint()
    elseif msg == "status" then
        AutoLFM_API.GetFullStatus()
        Print("Status retrieved successfully")
    else
        Print("Commands:")
        Print("/lfmapi debug - Show all current data")
        Print("/lfmapi status - Test API availability")
    end
end