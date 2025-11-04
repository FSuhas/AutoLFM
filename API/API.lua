--=============================================================================
-- AutoLFM: Public API
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.API then AutoLFM.API = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.API.VERSION = "v2.1"

local EVENTS = {
  BROADCAST_START = "BROADCAST_START",
  BROADCAST_STOP = "BROADCAST_STOP",
  MESSAGE_SENT = "MESSAGE_SENT",
  CONTENT_CHANGED = "CONTENT_CHANGED",
  ROLES_CHANGED = "ROLES_CHANGED",
  CHANNELS_CHANGED = "CHANNELS_CHANGED",
  INTERVAL_CHANGED = "INTERVAL_CHANGED",
  PLAYER_COUNT_CHANGED = "PLAYER_COUNT_CHANGED"
}

AutoLFM.API.EVENTS = EVENTS

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local callbacks = {}
local eventCallbacks = {}
local lastPlayerCount = nil

-----------------------------------------------------------------------------
-- Private Helpers
-----------------------------------------------------------------------------
local function SafePrint(printFunc, message)
  if AutoLFM.Core and AutoLFM.Core.Utils and AutoLFM.Core.Utils[printFunc] then
    AutoLFM.Core.Utils[printFunc](message)
  end
end

local function GetEmptyStatus()
  return {
    groupType = "unknown",
    selectedContent = { type = "unknown", list = {}, details = {} },
    playerCount = { currentInGroup = 1, desiredTotal = 1, missing = 0 },
    rolesNeeded = {},
    message = { combined = "", userInput = "", hasUserInput = false },
    selectedChannels = {},
    broadcastStats = { isActive = false, messagesSent = 0, searchDuration = 0 },
    timing = { intervalSeconds = 60, timeUntilNext = 0 }
  }
end

-----------------------------------------------------------------------------
-- Version & Availability
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
-- Group Information
-----------------------------------------------------------------------------
function AutoLFM.API.GetGroupType()
  if not AutoLFM.API.IsAvailable() then return "unknown" end
  
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

function AutoLFM.API.GetPlayerCount()
  if not AutoLFM.API.IsAvailable() then
    return { currentInGroup = 1, desiredTotal = 1, missing = 0 }
  end
  
  local mode = AutoLFM.Logic.Selection.GetMode()
  local currentInGroup = AutoLFM.Logic.Selection.GetGroupCount()
  local desiredTotal = 1
  
  if mode == "raid" then
    desiredTotal = AutoLFM.Logic.Content.GetRaidSize()
    if desiredTotal < 1 then
      desiredTotal = AutoLFM.Core.Constants.GROUP_SIZE_RAID
    end
  elseif mode == "dungeon" then
    desiredTotal = AutoLFM.Core.Constants.GROUP_SIZE_DUNGEON
  end
  
  local missing = desiredTotal - currentInGroup
  if missing < 0 then missing = 0 end
  
  return {
    currentInGroup = currentInGroup,
    desiredTotal = desiredTotal,
    missing = missing
  }
end

-----------------------------------------------------------------------------
-- Selected Content
-----------------------------------------------------------------------------
function AutoLFM.API.GetSelectedContent()
  if not AutoLFM.API.IsAvailable() then
    return { type = "unknown", list = {}, details = {} }
  end
  
  local groupType = AutoLFM.API.GetGroupType()
  local content = { type = groupType, list = {}, details = {} }
  
  if groupType == "dungeon" then
    local selectedDungeons = AutoLFM.Logic.Content.GetSelectedDungeons()
    for i = 1, table.getn(selectedDungeons) do
      local tag = selectedDungeons[i]
      table.insert(content.list, tag)
      local dungeon = AutoLFM.Logic.Content.GetDungeonByTag(tag)
      if dungeon then
        content.details[tag] = {
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
      local tag = selectedRaids[i]
      table.insert(content.list, tag)
      local raid = AutoLFM.Logic.Content.GetRaidByTag(tag)
      if raid then
        content.details[tag] = {
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

function AutoLFM.API.GetRolesNeeded()
  if not AutoLFM.API.IsAvailable() then return {} end
  
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
-- Message & Channels
-----------------------------------------------------------------------------
function AutoLFM.API.GetMessage()
  if not AutoLFM.API.IsAvailable() then
    return { combined = "", userInput = "", hasUserInput = false }
  end
  
  local combined = AutoLFM.Logic.Broadcaster.GetMessage()
  local userInput = AutoLFM.Logic.Broadcaster.GetCustomMessage()

  return {
    combined = combined,
    userInput = userInput,
    hasUserInput = (userInput ~= "")
  }
end

function AutoLFM.API.GetSelectedChannels()
  if not AutoLFM.API.IsAvailable() then return {} end
  
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
-- Broadcast Status
-----------------------------------------------------------------------------
function AutoLFM.API.IsActive()
  if not AutoLFM.API.IsAvailable() then return false end
  
  local stats = AutoLFM.Logic.Broadcaster.GetStats()
  return stats and stats.isActive or false
end

function AutoLFM.API.GetBroadcastStats()
  if not AutoLFM.API.IsAvailable() then
    return { isActive = false, messagesSent = 0, searchDuration = 0 }
  end
  
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

function AutoLFM.API.GetTiming()
  if not AutoLFM.API.IsAvailable() then
    return { intervalSeconds = 60, timeUntilNext = 0 }
  end
  
  local interval = AutoLFM.Logic.Broadcaster.INTERVAL_DEFAULT
  local broadcastSlider = AutoLFM.UI.MorePanel.GetBroadcastIntervalSlider()
  
  if broadcastSlider and broadcastSlider.GetValue then
    interval = broadcastSlider:GetValue() or interval
  end
  
  local timeUntilNext = 0
  local stats = AutoLFM.Logic.Broadcaster.GetStats()
  
  if stats.isActive and stats.lastTimestamp and stats.lastTimestamp > 0 then
    local nextBroadcast = stats.lastTimestamp + interval
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
  if not AutoLFM.API.IsAvailable() then
    return GetEmptyStatus()
  end
  
  return {
    groupType = AutoLFM.API.GetGroupType(),
    selectedContent = AutoLFM.API.GetSelectedContent(),
    playerCount = AutoLFM.API.GetPlayerCount(),
    rolesNeeded = AutoLFM.API.GetRolesNeeded(),
    message = AutoLFM.API.GetMessage(),
    selectedChannels = AutoLFM.API.GetSelectedChannels(),
    broadcastStats = AutoLFM.API.GetBroadcastStats(),
    timing = AutoLFM.API.GetTiming()
  }
end

-----------------------------------------------------------------------------
-- Callback System
-----------------------------------------------------------------------------
function AutoLFM.API.RegisterCallback(addonName, callback)
  if not addonName or not callback or type(callback) ~= "function" then
    SafePrint("PrintError", "RegisterCallback: invalid parameters")
    return false
  end
  
  callbacks[addonName] = callback
  
  return true
end

function AutoLFM.API.UnregisterCallback(addonName)
  if not addonName then return false end
  
  callbacks[addonName] = nil
  
  return true
end

function AutoLFM.API.RegisterEventCallback(eventType, addonName, callback)
  if not eventType or not addonName or not callback or type(callback) ~= "function" then
    SafePrint("PrintError", "RegisterEventCallback: invalid parameters")
    return false
  end
  
  if not eventCallbacks[eventType] then
    eventCallbacks[eventType] = {}
  end
  
  eventCallbacks[eventType][addonName] = callback
  
  return true
end

function AutoLFM.API.UnregisterEventCallback(eventType, addonName)
  if not eventType or not addonName then return false end
  
  if eventCallbacks[eventType] then
    eventCallbacks[eventType][addonName] = nil
  end
  
  return true
end

function AutoLFM.API.GetCallbackCount()
  local count = 0
  for _, _ in pairs(callbacks) do
    count = count + 1
  end
  return count
end

function AutoLFM.API.ListCallbacks()
  if not AutoLFM.Core or not AutoLFM.Core.Utils then return end
  
  AutoLFM.Core.Utils.PrintSuccess("=== Registered Callbacks ===")
  
  local count = 0
  for addonName, _ in pairs(callbacks) do
    count = count + 1
    AutoLFM.Core.Utils.Print("  " .. count .. ". " .. addonName)
  end
  
  if count == 0 then
    AutoLFM.Core.Utils.PrintNote("No callbacks registered")
  end
end

-----------------------------------------------------------------------------
-- Notification System
-----------------------------------------------------------------------------
local function ExecuteCallback(callback, status, eventType, addonName)
  local success, err = pcall(callback, status, eventType)
  if not success then
    SafePrint("PrintError", "Callback error for " .. tostring(addonName) .. ": " .. tostring(err))
  end
end

function AutoLFM.API.NotifyDataChanged(eventType)
  local status = AutoLFM.API.GetFullStatus()
  
  for addonName, callback in pairs(callbacks) do
    if type(callback) == "function" then
      ExecuteCallback(callback, status, eventType, addonName)
    end
  end
  
  if eventType and eventCallbacks[eventType] then
    for addonName, callback in pairs(eventCallbacks[eventType]) do
      if type(callback) == "function" then
        ExecuteCallback(callback, status, nil, addonName)
      end
    end
  end
end

-----------------------------------------------------------------------------
-- Debug
-----------------------------------------------------------------------------
function AutoLFM.API.DebugPrint()
  if not AutoLFM.API.IsAvailable() then
    SafePrint("PrintError", "API not available")
    return
  end

  local status = AutoLFM.API.GetFullStatus()
  if not AutoLFM.Core or not AutoLFM.Core.Utils then return end

  AutoLFM.Core.Utils.PrintSuccess("=== AutoLFM API Debug ===")
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Version: ", "white") .. AutoLFM.API.GetVersion())
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Group Type: ", "white") .. (status.groupType or "unknown"))
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Content: ", "white") .. table.getn(status.selectedContent.list) .. " items")
  
  if table.getn(status.selectedContent.list) > 0 then
    for i = 1, table.getn(status.selectedContent.list) do
      local tag = status.selectedContent.list[i]
      local detail = status.selectedContent.details[tag]
      if detail then
        AutoLFM.Core.Utils.Print("  - " .. detail.name .. " (" .. tag .. ")")
      end
    end
  end
  
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Players: ", "white") .. status.playerCount.currentInGroup .. "/" .. status.playerCount.desiredTotal .. " (missing: " .. status.playerCount.missing .. ")")
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Roles: ", "white") .. (table.getn(status.rolesNeeded) > 0 and table.concat(status.rolesNeeded, ", ") or "none"))
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Message: ", "white") .. (status.message.combined or ""))
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Channels: ", "white") .. (table.getn(status.selectedChannels) > 0 and table.concat(status.selectedChannels, ", ") or "none"))
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Broadcasting: ", "white") .. (status.broadcastStats.isActive and "Yes" or "No"))
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Messages Sent: ", "white") .. status.broadcastStats.messagesSent)
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Search Duration: ", "white") .. math.floor(status.broadcastStats.searchDuration) .. "s")
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Next Broadcast: ", "white") .. math.floor(status.timing.timeUntilNext) .. "s")
  AutoLFM.Core.Utils.Print(AutoLFM.Core.Utils.ColorizeText("Registered Callbacks: ", "white") .. AutoLFM.API.GetCallbackCount())
end

-----------------------------------------------------------------------------
-- Player Count Monitoring
-----------------------------------------------------------------------------
local monitoringFrame = nil

local function CheckPlayerCountChanged()
  local currentCount = AutoLFM.API.GetPlayerCount()
  
  if not lastPlayerCount then
    lastPlayerCount = currentCount
    return
  end
  
  if currentCount.currentInGroup ~= lastPlayerCount.currentInGroup or
     currentCount.desiredTotal ~= lastPlayerCount.desiredTotal then
    lastPlayerCount = currentCount
    AutoLFM.API.NotifyDataChanged(EVENTS.PLAYER_COUNT_CHANGED)
  end
end

function AutoLFM.API.InitMonitoring()
  if monitoringFrame then
    return true
  end
  
  monitoringFrame = CreateFrame("Frame")
  monitoringFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
  monitoringFrame:RegisterEvent("RAID_ROSTER_UPDATE")
  
  monitoringFrame:SetScript("OnEvent", function()
    if event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
      CheckPlayerCountChanged()
    end
  end)
  
  lastPlayerCount = AutoLFM.API.GetPlayerCount()
  
  return true
end
