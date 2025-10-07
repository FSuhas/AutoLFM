--------------------------------------------------
-- Dynamic Message Generation
--------------------------------------------------

--------------------------------------------------
-- Helper: Get Current Player Counts
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
-- Helper: Process Raid Selection
--------------------------------------------------
local function ProcessRaidSelection(selectedRaidsLocal)
  if table.getn(selectedRaidsLocal) == 0 then
    return nil, 0
  end
  
  local raidTag = selectedRaidsLocal[1]
  local currentRaidSize = 0
  
  for _, raid in pairs(RAID_DATABASE) do
    if raid.tag == raidTag then
      local isFixedSize = raid.sizeMin == raid.sizeMax
      
      if isFixedSize then
        if raidSizeControlFrame then
          raidSizeControlFrame:Hide()
        end
        currentRaidSize = raid.sizeMin
        raidGroupSize = raid.sizeMin
      else
        if raidSizeSlider then
          raidSizeSlider:SetMinMaxValues(raid.sizeMin, raid.sizeMax)
          local initVal = raidGroupSize ~= 0 and raidGroupSize or raid.sizeMin
          raidSizeSlider:SetValue(initVal)
          if UpdateRaidSizeDisplay then 
            UpdateRaidSizeDisplay(initVal) 
          end
          currentRaidSize = initVal
        else
          currentRaidSize = raidGroupSize ~= 0 and raidGroupSize or raid.sizeMin
        end
        
        if AutoLFM_MainFrame and AutoLFM_MainFrame:IsShown() and raidSizeControlFrame then
          raidSizeControlFrame:Show()
        end
      end
      
      return raid.tag, currentRaidSize
    end
  end
  
  return nil, 0
end

--------------------------------------------------
-- Helper: Process Dungeon Selection
--------------------------------------------------
local function ProcessDungeonSelection(totalGroupSize, totalPlayersInGroup)
  local selectedContent = {}
  
  for _, dungeonTag in pairs(selectedDungeonTags) do
    for _, dungeon in pairs(DUNGEON_DATABASE) do
      if dungeon.tag == dungeonTag then
        local missingPlayers = totalGroupSize - totalPlayersInGroup
        if missingPlayers < 0 then
          missingPlayers = 0
          if StopBroadcast then 
            StopBroadcast() 
          end
        end
        if missingPlayers > 0 then
          table.insert(selectedContent, dungeon.tag)
        end
        break
      end
    end
  end
  
  return selectedContent
end

--------------------------------------------------
-- Helper: Build Final Message
--------------------------------------------------
local function BuildFinalMessage(selectedContent, rolesList, mate, isRaidSelected, raidPlayerCountText)
  if not selectedContent then selectedContent = {} end
  if not selectedRolesList then selectedRolesList = {} end

  local contentCount = table.getn(selectedContent)
  local rolesCount = table.getn(selectedRolesList)
  
  if contentCount == 0 and rolesCount == 0 and customUserMessage == "" then
    return ""
  end
  
  local contentMessage = table.concat(selectedContent, " & ")
  local finalRolesSegment = ""
  
  if rolesCount == 3 then
    finalRolesSegment = "Need All"
  elseif rolesCount > 0 then
    finalRolesSegment = "Need " .. rolesList
  end
  
  local message = ""
  
  if contentCount == 0 and rolesCount == 0 then
    message = customUserMessage
  elseif contentCount == 0 and rolesCount > 0 then
    message = finalRolesSegment
    if customUserMessage ~= "" then
      message = message .. " " .. customUserMessage
    end
  elseif contentCount > 0 and rolesCount == 0 then
    if isRaidSelected then
      message = contentMessage .. " LF" .. mate .. "M" .. raidPlayerCountText
    else
      message = "LF" .. mate .. "M for " .. contentMessage
    end
    if customUserMessage ~= "" then
      message = message .. " " .. customUserMessage
    end
  else
    if isRaidSelected then
      message = contentMessage .. " LF" .. mate .. "M " .. finalRolesSegment .. raidPlayerCountText
    else
      message = "LF" .. mate .. "M for " .. contentMessage .. " " .. finalRolesSegment
    end
    if customUserMessage ~= "" then
      message = message .. " " .. customUserMessage
    end
  end
  
  return message
end

--------------------------------------------------
-- Main Update Function
--------------------------------------------------
function UpdateDynamicMessage()
  if not selectedDungeonTags then selectedDungeonTags = {} end
  if not selectedRaidTags then selectedRaidTags = {} end
  if not selectedRolesList then selectedRolesList = {} end
  
  local totalPlayersInGroup, totalPlayersInRaid = GetPlayerCounts()
  local totalGroupSize = 5
  
  local selectedContent = {}
  local rolesList = table.concat(selectedRolesList, " & ")
  
  local selectedRaidsLocal = GetSelectedRaidsList and GetSelectedRaidsList() or {}
  local raidTag, currentRaidSize = ProcessRaidSelection(selectedRaidsLocal)
  local isRaidSelected = raidTag ~= nil
  
  if isRaidSelected then
    table.insert(selectedContent, raidTag)
  else
    selectedContent = ProcessDungeonSelection(totalGroupSize, totalPlayersInGroup)
  end
  
  local mate = 0
  local raidPlayerCountText = ""
  
  if isRaidSelected then
    local currentCount = totalPlayersInRaid > 0 and totalPlayersInRaid or totalPlayersInGroup
    mate = currentRaidSize - currentCount
    if mate < 0 then mate = 0 end
    raidPlayerCountText = " " .. currentCount .. "/" .. currentRaidSize
  else
    mate = totalGroupSize - totalPlayersInGroup
    if mate < 0 then mate = 0 end
  end
  
  generatedLFMMessage = BuildFinalMessage(selectedContent, rolesList, mate, isRaidSelected, raidPlayerCountText)
  
  if dungeonMessageText then dungeonMessageText:SetText(generatedLFMMessage) end
  if raidMessageText then raidMessageText:SetText(generatedLFMMessage) end
  
  if AutoLFM_API and type(AutoLFM_API.NotifyDataChanged) == "function" then
    AutoLFM_API.NotifyDataChanged()
  end
end