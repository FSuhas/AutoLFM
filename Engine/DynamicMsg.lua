--------------------------------------------------
-- Dynamic Message Generation
--------------------------------------------------
function updateMsgFrameCombined()
  local totalPlayersInGroup = countGroupMembers()
  local totalPlayersInRaid = countRaidMembers()
  local totalGroupSize = 5
  
  local selectedContent = {}
  local selectedCountRoles = 0
  
  for _, role in pairs(selectedRoles) do
    selectedCountRoles = selectedCountRoles + 1
  end
  
  local rolesList = table.concat(selectedRoles, " & ")
  local finalRolesSegment = ""
  if selectedCountRoles == 3 then
    finalRolesSegment = "Need All"
  elseif selectedCountRoles > 0 then
    finalRolesSegment = "Need " .. rolesList
  end
  
  local selectedRaids = GetSelectedRaids()
  local isRaidSelected = false
  local raidSize = 0
  
  if table.getn(selectedRaids) > 0 then
    for _, raidTag in pairs(selectedRaids) do
      for _, raid in pairs(raids) do
        if raid.tag == raidTag then
          table.insert(selectedContent, raid.tag)
          
          if raid.sizeMin == raid.sizeMax then
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
                UpdateSliderText(sliderSize:GetValue())
              end
            end
            if AutoLFM and AutoLFM:IsShown() and sliderSizeFrame then
              sliderSizeFrame:Show()
              currentSliderFrame = sliderSizeFrame
            end
            raidSize = sliderValue
          end
          
          isRaidSelected = true
          break
        end
      end
    end
  end
  
  if not isRaidSelected then
    for _, dungeonTag in pairs(selectedDungeons) do
      for _, dungeon in pairs(dungeons) do
        if dungeon.tag == dungeonTag then
          local missingPlayers = totalGroupSize - totalPlayersInGroup
          if missingPlayers < 0 then
            missingPlayers = 0
            stopMessageBroadcast()
          end
          if missingPlayers > 0 then
            table.insert(selectedContent, dungeon.tag)
          end
          break
        end
      end
    end
  end
  
  local contentCount = table.getn(selectedContent)
  if contentCount == 0 and selectedCountRoles == 0 and userInputMessage == "" then
    combinedMessage = ""
    msgTextDj:SetText(combinedMessage)
    msgTextRaids:SetText(combinedMessage)
    return
  end
  
  local mate = 0
  local raidPlayerCountText = ""
  local currentCount = 0
  
  if isRaidSelected then
    if totalPlayersInRaid > 0 then
      currentCount = totalPlayersInRaid
    else
      currentCount = totalPlayersInGroup
    end
    mate = raidSize - currentCount
    if mate < 0 then mate = 0 end
    raidPlayerCountText = " " .. currentCount .. "/" .. raidSize
  else
    mate = totalGroupSize - totalPlayersInGroup
    if mate < 0 then mate = 0 end
  end
  
  local contentMessage = table.concat(selectedContent, " & ")
  
  if contentCount == 0 and selectedCountRoles == 0 then
    combinedMessage = userInputMessage
    
  elseif contentCount == 0 and selectedCountRoles > 0 then
    combinedMessage = finalRolesSegment
    if userInputMessage ~= "" then
      combinedMessage = combinedMessage .. " " .. userInputMessage
    end
    
  elseif contentCount > 0 and selectedCountRoles == 0 then
    if isRaidSelected then
      combinedMessage = contentMessage .. " LF" .. mate .. "M" .. raidPlayerCountText
    else
      combinedMessage = "LF" .. mate .. "M for " .. contentMessage
    end
    if userInputMessage ~= "" then
      combinedMessage = combinedMessage .. " " .. userInputMessage
    end
    
  elseif contentCount > 0 and selectedCountRoles > 0 then
    if isRaidSelected then
      combinedMessage = contentMessage .. " LF" .. mate .. "M " .. finalRolesSegment .. raidPlayerCountText
    else
      combinedMessage = "LF" .. mate .. "M for " .. contentMessage .. " " .. finalRolesSegment
    end
    if userInputMessage ~= "" then
      combinedMessage = combinedMessage .. " " .. userInputMessage
    end
  end
  
  msgTextDj:SetText(combinedMessage)
  msgTextRaids:SetText(combinedMessage)
  
  if AutoLFM_API and AutoLFM_API.NotifyDataChanged then
    AutoLFM_API.NotifyDataChanged()
  end
end