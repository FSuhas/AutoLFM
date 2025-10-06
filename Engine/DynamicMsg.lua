--------------------------------------------------
-- Dynamic Message Generation
--------------------------------------------------

--------------------------------------------------
-- Helper: Get Current Player Counts
--------------------------------------------------
local function GetPlayerCounts()
  local inGroup = 1
  local inRaid = 0
  
  if countGroupMembers and type(countGroupMembers) == "function" then
    inGroup = countGroupMembers()
  else
    inGroup = GetNumPartyMembers() + 1
  end
  
  if countRaidMembers and type(countRaidMembers) == "function" then
    inRaid = countRaidMembers()
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
  local raidSize = 0
  
  for _, raid in pairs(raids) do
    if raid.tag == raidTag then
      local isFixedSize = raid.sizeMin == raid.sizeMax
      
      if isFixedSize then
        if currentSliderFrame then
          currentSliderFrame:Hide()
          currentSliderFrame = nil
        end
        if sliderSizeFrame then 
          sliderSizeFrame:Hide() 
        end
        raidSize = raid.sizeMin
        sliderValue = raid.sizeMin
      else
        if sliderSize then
          sliderSize:SetMinMaxValues(raid.sizeMin, raid.sizeMax)
          local initVal = sliderValue ~= 0 and sliderValue or raid.sizeMin
          sliderSize:SetValue(initVal)
          if UpdateSliderText then 
            UpdateSliderText(initVal) 
          end
          raidSize = initVal
        else
          raidSize = sliderValue ~= 0 and sliderValue or raid.sizeMin
        end
        
        if AutoLFM and AutoLFM:IsShown() and sliderSizeFrame then
          sliderSizeFrame:Show()
          currentSliderFrame = sliderSizeFrame
        end
      end
      
      return raid.tag, raidSize
    end
  end
  
  return nil, 0
end

--------------------------------------------------
-- Helper: Process Dungeon Selection
--------------------------------------------------
local function ProcessDungeonSelection(totalGroupSize, totalPlayersInGroup)
  local selectedContent = {}
  
  for _, dungeonTag in pairs(selectedDungeons) do
    for _, dungeon in pairs(dungeons) do
      if dungeon.tag == dungeonTag then
        local missingPlayers = totalGroupSize - totalPlayersInGroup
        if missingPlayers < 0 then
          missingPlayers = 0
          if stopMessageBroadcast then 
            stopMessageBroadcast() 
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
  local contentCount = table.getn(selectedContent)
  local rolesCount = table.getn(selectedRoles or {})
  
  if contentCount == 0 and rolesCount == 0 and userInputMessage == "" then
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
    message = userInputMessage
  elseif contentCount == 0 and rolesCount > 0 then
    message = finalRolesSegment
  elseif contentCount > 0 and rolesCount == 0 then
    if isRaidSelected then
      message = contentMessage .. " LF" .. mate .. "M" .. raidPlayerCountText
    else
      message = "LF" .. mate .. "M for " .. contentMessage
    end
  else
    if isRaidSelected then
      message = contentMessage .. " LF" .. mate .. "M " .. finalRolesSegment .. raidPlayerCountText
    else
      message = "LF" .. mate .. "M for " .. contentMessage .. " " .. finalRolesSegment
    end
  end
  
  if userInputMessage ~= "" and message ~= "" then
    message = message .. " " .. userInputMessage
  end
  
  return message
end

--------------------------------------------------
-- Main Update Function
--------------------------------------------------
function updateMsgFrameCombined()
  if not selectedDungeons then selectedDungeons = {} end
  if not selectedRaids then selectedRaids = {} end
  if not selectedRoles then selectedRoles = {} end
  
  local totalPlayersInGroup, totalPlayersInRaid = GetPlayerCounts()
  local totalGroupSize = 5
  
  local selectedContent = {}
  local rolesList = table.concat(selectedRoles, " & ")
  
  local selectedRaidsLocal = GetSelectedRaids and GetSelectedRaids() or {}
  local raidTag, raidSize = ProcessRaidSelection(selectedRaidsLocal)
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
    mate = raidSize - currentCount
    if mate < 0 then mate = 0 end
    raidPlayerCountText = " " .. currentCount .. "/" .. raidSize
  else
    mate = totalGroupSize - totalPlayersInGroup
    if mate < 0 then mate = 0 end
  end
  
  combinedMessage = BuildFinalMessage(selectedContent, rolesList, mate, isRaidSelected, raidPlayerCountText)
  
  if msgTextDj then msgTextDj:SetText(combinedMessage) end
  if msgTextRaids then msgTextRaids:SetText(combinedMessage) end
  
  if AutoLFM_API and type(AutoLFM_API.NotifyDataChanged) == "function" then
    AutoLFM_API.NotifyDataChanged()
  end
end