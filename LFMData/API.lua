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
    local selectedDungeons = GetSelectedDungeons() or {}
    local selectedRaids = GetSelectedRaids() or {}

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
        for _, dungeonAbrev in pairs(selectedDungeons) do
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
        for _, raidAbrev in pairs(selectedRaids) do
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
        currentInGroup = countGroupMembers()
    end

    if groupType == "raid" then
        desiredTotal = sliderValue or 0
        missing = desiredTotal - currentInGroup
    elseif groupType == "dungeon" or groupType == "other" then
        desiredTotal = 5 
        missing = desiredTotal - currentInGroup
    end

    if missing < 0 then missing = 0 end

    return {
        currentInGroup = currentInGroup,
        desiredTotal = desiredTotal,
        missing = missing 
    }
end

function AutoLFM_API.GetRolesNeeded()
    local selectedRoles = GetSelectedRoles() or {}
    local rolesList = {}

    for _, role in pairs(selectedRoles) do
        table.insert(rolesList, role)
    end

    return rolesList
end

function AutoLFM_API.GetDynamicMessage()
    local combined = GetCombinedMessage() or ""
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
            selectedDungeons ~= nil and 
            selectedRaids ~= nil and 
            selectedRoles ~= nil)
end

function AutoLFM_API.GetVersion()
    return "1.0.0"
end

function AutoLFM_API.DebugPrint()
    if not AutoLFM_API.IsAvailable() then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[AutoLFM API]|r API not available")
        return
    end

    local status = AutoLFM_API.GetFullStatus()

    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoLFM API Debug]|r")
    DEFAULT_CHAT_FRAME:AddMessage("Group Type: " .. status.groupType)
    DEFAULT_CHAT_FRAME:AddMessage("Content: " .. table.getn(status.selectedContent.list) .. " items")
    DEFAULT_CHAT_FRAME:AddMessage("Players: " .. status.playerCount.currentInGroup .. "/" .. status.playerCount.desiredTotal .. " (missing: " .. status.playerCount.missing .. ")")
    DEFAULT_CHAT_FRAME:AddMessage("Roles: " .. table.concat(status.rolesNeeded, ", "))
    DEFAULT_CHAT_FRAME:AddMessage("Message: " .. status.dynamicMessage.combined)
    DEFAULT_CHAT_FRAME:AddMessage("Channels: " .. table.concat(status.selectedChannels, ", "))
    DEFAULT_CHAT_FRAME:AddMessage("Broadcasting: " .. (status.broadcastStats.isActive and "Yes" or "No"))
    DEFAULT_CHAT_FRAME:AddMessage("Messages sent: " .. status.broadcastStats.messagesSent)
    DEFAULT_CHAT_FRAME:AddMessage("Search duration: " .. math.floor(status.broadcastStats.searchDuration) .. "s")
    DEFAULT_CHAT_FRAME:AddMessage("Next broadcast in: " .. math.floor(status.timing.timeUntilNext) .. "s")
end

AutoLFM_API.callbacks = AutoLFM_API.callbacks or {}

function AutoLFM_API.RegisterCallback(addonName, callback)
    AutoLFM_API.callbacks[addonName] = callback
end

function AutoLFM_API.UnregisterCallback(addonName)
    AutoLFM_API.callbacks[addonName] = nil
end

function AutoLFM_API.NotifyDataChanged()
    for addonName, callback in pairs(AutoLFM_API.callbacks) do
        if type(callback) == "function" then
            pcall(callback, AutoLFM_API.GetFullStatus())
        end
    end
end

SLASH_LFMAPI1 = "/lfmapi"
SlashCmdList["LFMAPI"] = function(msg)
    if msg == "debug" then
        AutoLFM_API.DebugPrint()
    elseif msg == "status" then
        local status = AutoLFM_API.GetFullStatus()
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoLFM API]|r Status retrieved successfully")
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoLFM API Commands]|r")
        DEFAULT_CHAT_FRAME:AddMessage("/lfmapi debug - Show all current data")
        DEFAULT_CHAT_FRAME:AddMessage("/lfmapi status - Test API availability")
    end
end