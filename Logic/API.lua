--=============================================================================
-- AutoLFM: API
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.API then AutoLFM.API = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.API.VERSION = "1.0.0"

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
AutoLFM.API.callbacks = AutoLFM.API.callbacks or {}

-----------------------------------------------------------------------------
-- Availability Check
-----------------------------------------------------------------------------
function AutoLFM.API.GetVersion()
  return AutoLFM.API.VERSION
end

function AutoLFM.API.IsAvailable()
  return (AutoLFM_MainFrame ~= nil and
          type(AutoLFM.Logic.Content.GetSelectedDungeons) == "function" and
          type(AutoLFM.Logic.Content.GetSelectedRaids) == "function" and
          type(AutoLFM.Logic.Selection.GetRoles) == "function")
end

-----------------------------------------------------------------------------
-- Group Type
-----------------------------------------------------------------------------
function AutoLFM.API.GetGroupType()
  local selectedDungeons = AutoLFM.Logic.Content.GetSelectedDungeons()
  local selectedRaids = AutoLFM.Logic.Content.GetSelectedRaids()

  if table.getn(selectedRaids) > 0 then
    return "raid"
  elseif table.getn(selectedDungeons) > 0 then
    return "dungeon"
  else
    return "other"
  end
end

-----------------------------------------------------------------------------
-- Selected Content
-----------------------------------------------------------------------------
function AutoLFM.API.GetSelectedContent()
  local groupType = AutoLFM.API.GetGroupType()
  local content = {
    type = groupType,
    list = {},
    details = {}
  }
  
  if groupType == "dungeon" then
    local selectedDungeons = AutoLFM.Logic.Content.GetSelectedDungeons()
    for i = 1, table.getn(selectedDungeons) do
      local dungeonTag = selectedDungeons[i]
      table.insert(content.list, dungeonTag)
      local dungeon = AutoLFM.Logic.Content.GetDungeonByTag(dungeonTag)
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
    local selectedRaids = AutoLFM.Logic.Content.GetSelectedRaids()
    for i = 1, table.getn(selectedRaids) do
      local raidTag = selectedRaids[i]
      table.insert(content.list, raidTag)
      local raid = AutoLFM.Logic.Content.GetRaidByTag(raidTag)
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

-----------------------------------------------------------------------------
-- Player Count
-----------------------------------------------------------------------------
function AutoLFM.API.GetPlayerCount()
  local mode = AutoLFM.Logic.Selection.GetMode()
  local currentInGroup = AutoLFM.Logic.Selection.GetGroupCount()
  local desiredTotal = 0
  local missing = 0
  
  if not currentInGroup or currentInGroup < 1 then
    currentInGroup = 1
  end
  
  if mode == "raid" then
    desiredTotal = AutoLFM.Logic.Content.GetRaidSize()
    if desiredTotal < 1 then
      desiredTotal = AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_RAID
    end
  elseif mode == "dungeon" then
    desiredTotal = AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_DUNGEON
  else
    desiredTotal = 1
  end
  
  missing = desiredTotal - currentInGroup
  if missing < 0 then missing = 0 end
  
  return {
    currentInGroup = currentInGroup,
    desiredTotal = desiredTotal,
    missing = missing
  }
end

-----------------------------------------------------------------------------
-- Roles Needed
-----------------------------------------------------------------------------
function AutoLFM.API.GetRolesNeeded()
  local selectedRoles = AutoLFM.Logic.Selection.GetRoles()
  local rolesList = {}
  
  if selectedRoles and type(selectedRoles) == "table" then
    for i = 1, table.getn(selectedRoles) do
      table.insert(rolesList, selectedRoles[i])
    end
  end

  return rolesList
end

-----------------------------------------------------------------------------
-- Dynamic Message
-----------------------------------------------------------------------------
function AutoLFM.API.GetDynamicMessage()
  local combined = AutoLFM.Logic.Broadcaster.GetMessage()
  local userInput = AutoLFM.Logic.Broadcaster.GetCustomMessage()

  return {
    combined = combined,
    userInput = userInput,
    hasUserInput = (userInput ~= "")
  }
end

-----------------------------------------------------------------------------
-- Selected Channels
-----------------------------------------------------------------------------
function AutoLFM.API.GetSelectedChannels()
  local channels = AutoLFM.Logic.Selection.GetChannels()
  local channelList = {}

  if channels and type(channels) == "table" then
    for channelName, _ in pairs(channels) do
      table.insert(channelList, channelName)
    end
  end

  return channelList
end

-----------------------------------------------------------------------------
-- Broadcast Stats
-----------------------------------------------------------------------------
function AutoLFM.API.GetBroadcastStats()
  local stats = AutoLFM.Logic.Broadcaster.GetStats()
  
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

-----------------------------------------------------------------------------
-- Timing
-----------------------------------------------------------------------------
function AutoLFM.API.GetTiming()
  local interval = AutoLFM.Logic.Broadcaster.INTERVAL_DEFAULT
  local nextBroadcast = 0
  local timeUntilNext = 0
  
  local broadcastSlider = AutoLFM.UI.MorePanel.GetBroadcastIntervalSlider()
  if broadcastSlider and broadcastSlider.GetValue then
    interval = broadcastSlider:GetValue() or AutoLFM.Logic.Broadcaster.INTERVAL_DEFAULT
  end
  
  local stats = AutoLFM.Logic.Broadcaster.GetStats()
  
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

-----------------------------------------------------------------------------
-- Full Status
-----------------------------------------------------------------------------
function AutoLFM.API.GetFullStatus()
  local status = {
    groupType = AutoLFM.API.GetGroupType(),
    selectedContent = AutoLFM.API.GetSelectedContent(),
    playerCount = AutoLFM.API.GetPlayerCount(),
    rolesNeeded = AutoLFM.API.GetRolesNeeded(),
    dynamicMessage = AutoLFM.API.GetDynamicMessage(),
    selectedChannels = AutoLFM.API.GetSelectedChannels(),
    broadcastStats = AutoLFM.API.GetBroadcastStats(),
    timing = AutoLFM.API.GetTiming()
  }
  return status
end

-----------------------------------------------------------------------------
-- Debug Print
-----------------------------------------------------------------------------
function AutoLFM.API.DataPrint()
  if not AutoLFM.API.IsAvailable() then
    AutoLFM.Core.Utils.PrintError("API not available")
    return
  end

  local status = AutoLFM.API.GetFullStatus()

  AutoLFM.Core.Utils.PrintSuccess("API Data:")
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Group Type: ","white") .. (status.groupType or "unknown"))
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Content: ","white") .. table.getn(status.selectedContent.list) .. " items")
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Players: ","white") .. status.playerCount.currentInGroup .. "/" .. status.playerCount.desiredTotal .. " (missing: " .. status.playerCount.missing .. ")")
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Roles: ","white") .. table.concat(status.rolesNeeded, ", "))
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Message: ","white") .. (status.dynamicMessage.combined or ""))
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Channels: ","white") .. table.concat(status.selectedChannels, ", "))
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Broadcasting: ","white") .. (status.broadcastStats.isActive and "Yes" or "No"))
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Messages sent: ","white") .. status.broadcastStats.messagesSent)
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Search duration: ","white") .. math.floor(status.broadcastStats.searchDuration) .. "s")
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Next broadcast in: ","white") .. math.floor(status.timing.timeUntilNext) .. "s")
end

-----------------------------------------------------------------------------
-- Callback System
-----------------------------------------------------------------------------
function AutoLFM.API.RegisterCallback(addonName, callback)
  if not addonName or not callback then return end
  AutoLFM.API.callbacks[addonName] = callback
end

function AutoLFM.API.UnregisterCallback(addonName)
  if not addonName then return end
  AutoLFM.API.callbacks[addonName] = nil
end

function AutoLFM.API.NotifyDataChanged(eventType)
  if not AutoLFM.API.callbacks then return end
  
  for addonName, callback in pairs(AutoLFM.API.callbacks) do
    if type(callback) == "function" then
      local success, err = pcall(callback, AutoLFM.API.GetFullStatus(), eventType)
      if not success then
        AutoLFM.Core.Utils.PrintError("Callback error for " .. tostring(addonName) .. ": " .. tostring(err))
      end
    end
  end
end
