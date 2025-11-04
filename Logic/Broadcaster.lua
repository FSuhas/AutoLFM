--=============================================================================
-- AutoLFM: Broadcaster
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Logic then AutoLFM.Logic = {} end
if not AutoLFM.Logic.Broadcaster then AutoLFM.Logic.Broadcaster = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local isActive = false
local lastTimestamp = 0
local messageCount = 0
local searchStartTime = 0
local generatedMessage = ""
local customMessage = ""
local broadcastFrame = nil
local lastUpdateCheck = 0

-----------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------
local function IsMessageEmpty(msg)
  return not msg or msg == "" or msg == " "
end

-----------------------------------------------------------------------------
-- Message Construction
-----------------------------------------------------------------------------
local function BuildContentList(tags)
  if not tags or table.getn(tags) == 0 then return nil end
  return table.concat(tags, " or ")
end

local function CalculateGroupCounts(mode, targetSize)
  local currentCount = AutoLFM.Logic.Selection.GetGroupCount()
  local missingCount = targetSize - currentCount
  
  return {
    current = currentCount,
    target = targetSize,
    missing = missingCount
  }
end

local function BuildDungeonSegment()
  local selectedDungeons = AutoLFM.Logic.Content.GetSelectedDungeons()
  if not selectedDungeons then return {}, 0 end
  
  local counts = CalculateGroupCounts("dungeon", AutoLFM.Core.Constants.GROUP_SIZE_DUNGEON)
  
  if counts.missing <= 0 then
    return {}, 0
  end
  
  local dungeonList = {}
  for i = 1, table.getn(selectedDungeons) do
    table.insert(dungeonList, selectedDungeons[i])
  end
  
  return dungeonList, counts.missing
end

local function BuildRaidSegment()
  local selectedRaids = AutoLFM.Logic.Content.GetSelectedRaids()
  if not selectedRaids or table.getn(selectedRaids) == 0 then
    return nil, 0, 0, 0
  end
  
  local raidTag = selectedRaids[1]
  local raid = AutoLFM.Logic.Content.GetRaidByTag(raidTag)
  
  if not raid then
    return nil, 0, 0, 0
  end
  
  local currentRaidSize = AutoLFM.Logic.Content.GetRaidSize()
  if currentRaidSize == 0 then
    currentRaidSize = raid.sizeMin or AutoLFM.Core.Constants.GROUP_SIZE_RAID
  end
  
  local counts = CalculateGroupCounts("raid", currentRaidSize)
  
  return raidTag, counts.missing, counts.target, counts.current
end

-----------------------------------------------------------------------------
-- Message Formatting
-----------------------------------------------------------------------------
local function FormatDungeonMessage(contentText, rolesString, missingCount)
  if not contentText then return "" end
  
  local message = "LF" .. missingCount .. "M for " .. contentText
  
  if rolesString and rolesString ~= "" then
    message = message .. " " .. rolesString
  end
  
  return message
end

local function FormatRaidMessage(raidTag, rolesString, missingCount, currentCount, raidSize)
  if not raidTag then return "" end
  
  local message = raidTag .. " LF" .. missingCount .. "M"
  
  if rolesString and rolesString ~= "" then
    message = message .. " " .. rolesString
  end
  
  message = message .. " " .. currentCount .. "/" .. raidSize
  
  return message
end

local function BuildFinalMessage(contentText, rolesString, missingCount, isRaid, raidData)
  local hasCustom = customMessage and customMessage ~= ""
  
  if not contentText and not rolesString then
    return customMessage or ""
  end
  
  if not contentText then
    local message = rolesString or ""
    return hasCustom and (message .. " " .. customMessage) or message
  end
  
  local message
  if isRaid and raidData then
    message = FormatRaidMessage(contentText, rolesString, missingCount, raidData.current, raidData.size)
  else
    message = FormatDungeonMessage(contentText, rolesString, missingCount)
  end
  
  return hasCustom and (message .. " " .. customMessage) or message
end

-----------------------------------------------------------------------------
-- Message Update
-----------------------------------------------------------------------------
function AutoLFM.Logic.Broadcaster.UpdateMessage()
  local success, err = pcall(function()
    local rolesString = AutoLFM.Logic.Selection.GetRolesString()
    local raidTag, raidMissingCount, raidSize, raidCurrentCount = BuildRaidSegment()
    local isRaid = raidTag ~= nil
    local contentText
    local missingCount = 0
    local raidData = nil
    
    if isRaid then
      contentText = raidTag
      missingCount = raidMissingCount
      raidData = {
        current = raidCurrentCount,
        size = raidSize
      }
    else
      local dungeonList, dungeonMissingCount = BuildDungeonSegment()
      contentText = BuildContentList(dungeonList)
      missingCount = dungeonMissingCount
    end
    
    generatedMessage = BuildFinalMessage(contentText, rolesString, missingCount, isRaid, raidData)
    
    if AutoLFM.UI.MainWindow.UpdateMessagePreview then
      AutoLFM.UI.MainWindow.UpdateMessagePreview()
    end
    
    if AutoLFM.API and AutoLFM.API.NotifyDataChanged then
      AutoLFM.API.NotifyDataChanged()
    end
  end)
  
  if not success then
    AutoLFM.Core.Utils.PrintError("Failed to update message: " .. tostring(err))
  end
end

function AutoLFM.Logic.Broadcaster.GetMessage()
  return generatedMessage or ""
end

function AutoLFM.Logic.Broadcaster.SetCustomMessage(message)
  customMessage = message or ""
  AutoLFM.Logic.Broadcaster.UpdateMessage()
end

function AutoLFM.Logic.Broadcaster.GetCustomMessage()
  return customMessage or ""
end

function AutoLFM.Logic.Broadcaster.ResetCustomMessage()
  customMessage = ""
  AutoLFM.Logic.Broadcaster.UpdateMessage()
end

-----------------------------------------------------------------------------
-- Validation
-----------------------------------------------------------------------------
local validationRules = {
  message = function()
    if IsMessageEmpty(generatedMessage) then
      return false, "The LFM message is empty"
    end
    return true, nil
  end,
  
  channels = function()
    local selectedChannels = AutoLFM.Logic.Selection.GetChannels()
    if not selectedChannels or not next(selectedChannels) then
      return false, "No channel selected"
    end
    
    for channelName, _ in pairs(selectedChannels) do
      if channelName ~= "Hardcore" and not AutoLFM.Logic.Selection.IsChannelAvailable(channelName) then
        return false, "Channel '" .. channelName .. "' is invalid or closed"
      end
    end
    
    return true, nil
  end,
  
  content = function()
    local selectedRaids = AutoLFM.Logic.Content.GetSelectedRaids()
    local selectedDungeons = AutoLFM.Logic.Content.GetSelectedDungeons()
    local hasUserMessage = customMessage and customMessage ~= ""
    
    if not hasUserMessage then
      if table.getn(selectedRaids) == 0 and table.getn(selectedDungeons) == 0 then
        return false, "No dungeon/raid selected or no custom message set"
      end
    end
    
    return true, nil
  end,
  
  groupSize = function()
    local mode = AutoLFM.Logic.Selection.GetMode()
    local currentCount = AutoLFM.Logic.Selection.GetGroupCount()
    
    if mode == "dungeon" then
      if currentCount >= AutoLFM.Core.Constants.GROUP_SIZE_DUNGEON then
        return false, "Your dungeon group is already full (" .. AutoLFM.Core.Constants.GROUP_SIZE_DUNGEON .. "/" .. AutoLFM.Core.Constants.GROUP_SIZE_DUNGEON .. ")"
      end
    elseif mode == "raid" then
      local raidSize = AutoLFM.Logic.Content.GetRaidSize()
      if currentCount >= raidSize then
        return false, "Your raid group is already full (" .. raidSize .. "/" .. raidSize .. ")"
      end
    end
    
    return true, nil
  end
}

function AutoLFM.Logic.Broadcaster.Validate()
  local errors = {}
  
  for ruleName, validator in pairs(validationRules) do
    local isValid, errorMsg = validator()
    
    if not isValid and errorMsg then
      table.insert(errors, errorMsg)
    end
  end
  
  if table.getn(errors) > 0 then
    return false, errors
  end
  
  return true, nil
end

-----------------------------------------------------------------------------
-- Broadcast Operations
-----------------------------------------------------------------------------
function AutoLFM.Logic.Broadcaster.SendToChannels(message)
  if not message or message == "" then
    return false
  end
  
  local selectedChannels = AutoLFM.Logic.Selection.GetChannels()
  if not selectedChannels or not next(selectedChannels) then
    return false
  end
  
  local sentCount = 0
  local hadErrors = false

  for channelName, _ in pairs(selectedChannels) do
    if channelName == "Hardcore" then
      local hardcoreMessage = message
      local success, err = pcall(SendChatMessage, hardcoreMessage, "Hardcore")
      
      if success then
        sentCount = sentCount + 1
        -- DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Hardcore]|r " .. message)
      else
        hadErrors = true
        AutoLFM.Core.Utils.PrintError("Failed to send on Hardcore: " .. tostring(err))
      end

    else
      local channelId = AutoLFM.Logic.Selection.GetChannelId(channelName)
      if channelId then
        local success, err = pcall(SendChatMessage, message, "CHANNEL", nil, channelId)
        if success then
          sentCount = sentCount + 1
        else
          hadErrors = true
          AutoLFM.Core.Utils.PrintError("Failed to send on " .. channelName .. ": " .. tostring(err))
        end
      else
        hadErrors = true
        AutoLFM.Core.Utils.PrintError("The channel " .. channelName .. " is invalid or closed")
      end
    end
  end

  if sentCount == 0 then
    AutoLFM.Core.Utils.PrintError("Message not sent: all channels are invalid")
    return false
  end

  messageCount = (messageCount or 0) + 1
  lastTimestamp = GetTime()
  
  if AutoLFM.API and AutoLFM.API.NotifyDataChanged then
     AutoLFM.API.NotifyDataChanged(AutoLFM.API.EVENTS.MESSAGE_SENT)
  end
  
  return true
end


function AutoLFM.Logic.Broadcaster.Start()
  local success, result = pcall(function()
    local isValid, errors = AutoLFM.Logic.Broadcaster.Validate()
    
    if not isValid then
      AutoLFM.Core.Utils.PrintError("Broadcast cannot start:")
      for i = 1, table.getn(errors) do
        AutoLFM.Core.Utils.PrintError("  - " .. errors[i])
      end
      return false
    end
    
    isActive = true
    lastTimestamp = GetTime()
    searchStartTime = GetTime()
    messageCount = 0
    
    AutoLFM.Core.Utils.PrintSuccess("Broadcast started")
    
    AutoLFM.Logic.Broadcaster.SendToChannels(generatedMessage)
    
    if AutoLFM.UI.IconAnimation.Start then
      AutoLFM.UI.IconAnimation.Start()
    end
    
    if AutoLFM.API and AutoLFM.API.NotifyDataChanged then
      AutoLFM.API.NotifyDataChanged(AutoLFM.API.EVENTS.BROADCAST_START)
    end
    
    return true
  end)
  
  if not success then
    AutoLFM.Core.Utils.PrintError("Failed to start broadcast: " .. tostring(result))
    return false
  end
  
  return result
end

function AutoLFM.Logic.Broadcaster.Stop()
  isActive = false
  AutoLFM.Core.Utils.PrintWarning("Broadcast stopped")
  
  if AutoLFM.UI.IconAnimation.Stop then
    AutoLFM.UI.IconAnimation.Stop()
  end
  
  if AutoLFM.API and AutoLFM.API.NotifyDataChanged then
    AutoLFM.API.NotifyDataChanged(AutoLFM.API.EVENTS.BROADCAST_STOP)
  end
  
  messageCount = 0
end

function AutoLFM.Logic.Broadcaster.IsActive()
  return isActive or false
end

function AutoLFM.Logic.Broadcaster.GetStats()
  return {
    isActive = isActive or false,
    lastTimestamp = lastTimestamp or 0,
    messageCount = messageCount or 0,
    searchStartTimestamp = searchStartTime or 0
  }
end

function AutoLFM.Logic.Broadcaster.FormatDuration()
  local stats = AutoLFM.Logic.Broadcaster.GetStats()
  
  if stats.isActive and stats.searchStartTimestamp and stats.searchStartTimestamp > 0 then
    local duration = GetTime() - stats.searchStartTimestamp
    local minutes = math.floor(duration / 60)
    local seconds = math.floor(math.mod(duration, 60))
    return string.format("%02d:%02d", minutes, seconds)
  end
  
  return "00:00"
end

-----------------------------------------------------------------------------
-- Group State Management
-----------------------------------------------------------------------------
local function ClearAllSelections()
  if AutoLFM.Logic.Content.ClearDungeons then
    AutoLFM.Logic.Content.ClearDungeons()
  end
  
  if AutoLFM.Logic.Content.ClearRaids then
    AutoLFM.Logic.Content.ClearRaids()
  end
  
  if AutoLFM.Logic.Selection.ClearRoles then
    AutoLFM.Logic.Selection.ClearRoles()
  end
  
  if AutoLFM.Logic.Broadcaster.ResetCustomMessage then
    AutoLFM.Logic.Broadcaster.ResetCustomMessage()
  end
  
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
end

function AutoLFM.Logic.Broadcaster.HandleGroupFull(contentType)
  if AutoLFM.Logic.Broadcaster.IsActive() then
    AutoLFM.Logic.Broadcaster.Stop()
  end
  
  ClearAllSelections()
  
  return {
    needsUIUpdate = true,
    playStopSound = true
  }
end

-----------------------------------------------------------------------------
-- Broadcast Loop
-----------------------------------------------------------------------------
local function GetBroadcastInterval()
  local interval = AutoLFM.Core.Constants.INTERVAL_DEFAULT
  
  if AutoLFM.UI.MorePanel.GetBroadcastIntervalSlider then
    local broadcastSlider = AutoLFM.UI.MorePanel.GetBroadcastIntervalSlider()
    if broadcastSlider and broadcastSlider.GetValue then
      interval = broadcastSlider:GetValue()
    end
  end
  
  if not interval or interval < AutoLFM.Core.Constants.INTERVAL_MIN then
    interval = AutoLFM.Core.Constants.INTERVAL_DEFAULT
  end
  
  return interval
end

local function ShouldExecuteBroadcast(currentTime)
  if not isActive then return false end
  if not lastTimestamp or lastTimestamp <= 0 then return false end
  
  local interval = GetBroadcastInterval()
  local timeElapsed = currentTime - lastTimestamp
  
  return timeElapsed >= interval
end

local function ExecuteBroadcast()
  if IsMessageEmpty(generatedMessage) then
    return
  end
  
  local sendSuccess = AutoLFM.Logic.Broadcaster.SendToChannels(generatedMessage)
  
  if not sendSuccess then
    AutoLFM.Logic.Broadcaster.Stop()
    
    local broadcastButton = AutoLFM.UI.MainWindow.GetBroadcastToggleButton()
    if broadcastButton then
      broadcastButton:SetText("Start")
    end
  end
end

local function OnBroadcastUpdate()
  local currentTime = GetTime()
  
  if currentTime - lastUpdateCheck < AutoLFM.Core.Constants.UPDATE_THROTTLE then
    return
  end
  lastUpdateCheck = currentTime
  
  if ShouldExecuteBroadcast(currentTime) then
    ExecuteBroadcast()
  end
end

function AutoLFM.Logic.Broadcaster.InitLoop()
  if broadcastFrame then
    broadcastFrame:SetScript("OnUpdate", nil)
    broadcastFrame = nil
  end
  
  broadcastFrame = CreateFrame("Frame")
  lastUpdateCheck = 0
  
  broadcastFrame:SetScript("OnUpdate", function()
    local success, err = pcall(OnBroadcastUpdate)
    
    if not success then
      if not broadcastFrame.hasErrored then
        AutoLFM.Core.Utils.PrintError("Broadcast loop error: " .. tostring(err))
        broadcastFrame.hasErrored = true
      end
    end
  end)
end
