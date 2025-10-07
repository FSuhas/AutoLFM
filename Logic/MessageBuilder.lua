--------------------------------------------------
-- Message Builder - Dynamic LFM Message
--------------------------------------------------

--------------------------------------------------
-- Get Current Player Counts
--------------------------------------------------
local function GetPlayerCounts()
  local inGroup = 1
  local inRaid = 0
  
  if GetPartyMemberCount and type(GetPartyMemberCount) == "function" then
    inGroup = GetPartyMemberCount()
  else
    inGroup = GetNumPartyMembers() + 1
  end
  
  if GetRaidMemberCount and type(GetRaidMemberCount) == "function" then
    inRaid = GetRaidMemberCount()
  else
    inRaid = GetNumRaidMembers()
  end
  
  return inGroup, inRaid
end

--------------------------------------------------
-- Build Dungeon Message Segment
--------------------------------------------------
local function BuildDungeonSegment()
  if not selectedDungeonTags then return {} end
  
  local totalPlayersInGroup = GetPartyMemberCount()
  local totalGroupSize = DEFAULT_DUNGEON_SIZE
  local missingPlayers = totalGroupSize - totalPlayersInGroup
  
  if missingPlayers < 0 then
    missingPlayers = 0
  end
  
  if missingPlayers == 0 then
    return {}
  end
  
  local dungeonList = {}
  
  for _, dungeonTag in ipairs(selectedDungeonTags) do
    table.insert(dungeonList, dungeonTag)
  end
  
  return dungeonList
end

--------------------------------------------------
-- Build Raid Message Segment
--------------------------------------------------
local function BuildRaidSegment()
  local selectedRaids = GetSelectedRaidsList()
  if not selectedRaids or table.getn(selectedRaids) == 0 then
    return nil, 0, 0
  end
  
  local raidTag = selectedRaids[1]
  local raid = GetRaidByTag(raidTag)
  
  if not raid then
    return nil, 0, 0
  end
  
  local currentRaidSize = GetRaidGroupSize()
  if currentRaidSize == 0 then
    currentRaidSize = raid.sizeMin or DEFAULT_RAID_SIZE
  end
  
  local totalPlayersInGroup, totalPlayersInRaid = GetPlayerCounts()
  local currentCount = totalPlayersInRaid > 0 and totalPlayersInRaid or totalPlayersInGroup
  
  return raidTag, currentRaidSize, currentCount
end

--------------------------------------------------
-- Build Final Message
--------------------------------------------------
local function BuildFinalMessage(contentList, rolesString, missingCount, isRaid, raidCountText)
  if not contentList then contentList = {} end
  
  local contentCount = table.getn(contentList)
  local hasRoles = rolesString and rolesString ~= ""
  local hasCustom = customUserMessage and customUserMessage ~= ""
  
  -- Empty message
  if contentCount == 0 and not hasRoles and not hasCustom then
    return ""
  end
  
  local message = ""
  local contentText = table.concat(contentList, " & ")
  
  -- Only custom message
  if contentCount == 0 and not hasRoles then
    message = customUserMessage
  
  -- Only roles
  elseif contentCount == 0 and hasRoles then
    message = rolesString
    if hasCustom then
      message = message .. " " .. customUserMessage
    end
  
  -- Content without roles
  elseif contentCount > 0 and not hasRoles then
    if isRaid then
      message = contentText .. " LF" .. missingCount .. "M" .. raidCountText
    else
      message = "LF" .. missingCount .. "M for " .. contentText
    end
    if hasCustom then
      message = message .. " " .. customUserMessage
    end
  
  -- Content with roles
  else
    if isRaid then
      message = contentText .. " LF" .. missingCount .. "M " .. rolesString .. raidCountText
    else
      message = "LF" .. missingCount .. "M for " .. contentText .. " " .. rolesString
    end
    if hasCustom then
      message = message .. " " .. customUserMessage
    end
  end
  
  return message
end

--------------------------------------------------
-- Update Dynamic Message
--------------------------------------------------
function UpdateDynamicMessage()
  if not selectedDungeonTags then selectedDungeonTags = {} end
  if not selectedRaidTags then selectedRaidTags = {} end
  
  local rolesString = GetRolesString()
  
  -- Check if raid is selected
  local raidTag, raidSize, raidCurrentCount = BuildRaidSegment()
  local isRaid = raidTag ~= nil
  
  local contentList = {}
  local missingCount = 0
  local raidCountText = ""
  
  if isRaid then
    -- Raid mode
    table.insert(contentList, raidTag)
    missingCount = raidSize - raidCurrentCount
    if missingCount < 0 then missingCount = 0 end
    raidCountText = " " .. raidCurrentCount .. "/" .. raidSize
  else
    -- Dungeon mode
    contentList = BuildDungeonSegment()
    local totalPlayersInGroup = GetPartyMemberCount()
    missingCount = DEFAULT_DUNGEON_SIZE - totalPlayersInGroup
    if missingCount < 0 then missingCount = 0 end
  end
  
  generatedLFMMessage = BuildFinalMessage(contentList, rolesString, missingCount, isRaid, raidCountText)
  
  -- Update UI preview
  if UpdateMessagePreview then
    UpdateMessagePreview()
  end
  
  -- Notify API callbacks
  if AutoLFM_API and type(AutoLFM_API.NotifyDataChanged) == "function" then
    AutoLFM_API.NotifyDataChanged()
  end
end

--------------------------------------------------
-- Get Generated Message
--------------------------------------------------
function GetGeneratedLFMMessage()
  return generatedLFMMessage or ""
end

--------------------------------------------------
-- Set Custom User Message
--------------------------------------------------
function SetCustomUserMessage(message)
  customUserMessage = message or ""
  UpdateDynamicMessage()
end

--------------------------------------------------
-- Get Custom User Message
--------------------------------------------------
function GetCustomUserMessage()
  return customUserMessage or ""
end

--------------------------------------------------
-- Reset Custom Message
--------------------------------------------------
function ResetCustomMessage()
  customUserMessage = ""
  UpdateDynamicMessage()
end