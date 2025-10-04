--------------------------------------------------
-- Dynamic Message Generation
--------------------------------------------------
function updateMsgFrameCombined()
  local totalPlayersInGroup = countGroupMembers()
  local totalPlayersInRaid = countRaidMembers()
  local totalGroupSize = 5
  
  local selectedContent = {}
  local selectedCountRoles = table.getn(selectedRoles)
  
  local rolesList = table.concat(selectedRoles, " & ")
  local finalRolesSegment = selectedCountRoles == 3 and "Need All" or (selectedCountRoles > 0 and "Need " .. rolesList or "")
  
  local selectedRaids = GetSelectedRaids()
  local isRaidSelected = false
  local raidSize = 0
  
  -- Process raids
  if table.getn(selectedRaids) > 0 then
    local raidTag = selectedRaids[1]
    for _, raid in pairs(raids) do
      if raid.tag == raidTag then
        table.insert(selectedContent, raid.tag)
        
        -- Handle slider visibility
        local isFixedSize = raid.sizeMin == raid.sizeMax
        
        if isFixedSize then
          if currentSliderFrame then
            currentSliderFrame:Hide()
            currentSliderFrame = nil
          end
          if sliderSizeFrame then sliderSizeFrame:Hide() end
          raidSize = raid.sizeMin
          sliderValue = raid.sizeMin
        else
          if sliderSize then
            sliderSize:SetMinMaxValues(raid.sizeMin, raid.sizeMax)
            local initVal = sliderValue ~= 0 and sliderValue or raid.sizeMin
            sliderSize:SetValue(initVal)
            if UpdateSliderText then UpdateSliderText(initVal) end
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
  
  -- Process dungeons if no raid selected
  if not isRaidSelected then
    for _, dungeonTag in pairs(selectedDungeons) do
      for _, dungeon in pairs(dungeons) do
        if dungeon.tag == dungeonTag then
          local missingPlayers = totalGroupSize - totalPlayersInGroup
          if missingPlayers < 0 then
            missingPlayers = 0
            if stopMessageBroadcast then stopMessageBroadcast() end
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
  
  -- Early exit if nothing selected
  if contentCount == 0 and selectedCountRoles == 0 and userInputMessage == "" then
    combinedMessage = ""
    if msgTextDj then msgTextDj:SetText("") end
    if msgTextRaids then msgTextRaids:SetText("") end
    return
  end
  
  -- Calculate missing players
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
  
  -- Build message
  local contentMessage = table.concat(selectedContent, " & ")
  
  if contentCount == 0 and selectedCountRoles == 0 then
    combinedMessage = userInputMessage
  elseif contentCount == 0 and selectedCountRoles > 0 then
    combinedMessage = finalRolesSegment
    if userInputMessage ~= "" then
      combinedMessage = combinedMessage .. " " .. userInputMessage
    end
  elseif contentCount > 0 and selectedCountRoles == 0 then
    combinedMessage = isRaidSelected and (contentMessage .. " LF" .. mate .. "M" .. raidPlayerCountText) or ("LF" .. mate .. "M for " .. contentMessage)
    if userInputMessage ~= "" then
      combinedMessage = combinedMessage .. " " .. userInputMessage
    end
  else
    combinedMessage = isRaidSelected and (contentMessage .. " LF" .. mate .. "M " .. finalRolesSegment .. raidPlayerCountText) or ("LF" .. mate .. "M for " .. contentMessage .. " " .. finalRolesSegment)
    if userInputMessage ~= "" then
      combinedMessage = combinedMessage .. " " .. userInputMessage
    end
  end
  
  if msgTextDj then msgTextDj:SetText(combinedMessage) end
  if msgTextRaids then msgTextRaids:SetText(combinedMessage) end
  
  if AutoLFM_API and AutoLFM_API.NotifyDataChanged then
    AutoLFM_API.NotifyDataChanged()
  end
end