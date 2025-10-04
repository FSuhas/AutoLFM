--------------------------------------------------
-- String Utilities
--------------------------------------------------

function strsplit(delim, text)
  local result = {}
  local start = 1
  local i = 1
  
  while true do
    local s, e = string.find(text, delim, start)
    
    if not s then
      result[i] = string.sub(text, start)
      break
    end
    
    result[i] = string.sub(text, start, s - 1)
    i = i + 1
    start = e + 1
  end
  
  return result
end

--------------------------------------------------
-- Table Utilities
--------------------------------------------------

function tableContains(tbl, value)
  if not tbl then return false end
  for _, v in pairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

function tableCount(tbl)
  if not tbl then return 0 end
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

--------------------------------------------------
-- Group Functions
--------------------------------------------------

function countGroupMembers()
  return GetNumPartyMembers() + 1
end

function countRaidMembers()
  return GetNumRaidMembers()
end

function CheckRaidStatus()
  return UnitInRaid("player")
end

function OnRaidRosterUpdate()
  countRaidMembers()
  if updateMsgFrameCombined then
    updateMsgFrameCombined()
  end
end

function OnGroupUpdate()
  countGroupMembers()
  if updateMsgFrameCombined then
    updateMsgFrameCombined()
  end
end

--------------------------------------------------
-- Priority Calculation
--------------------------------------------------

function calculer_priorite(niveau_joueur, donjon)
  if not niveau_joueur or not donjon then return 4 end
  
  local min = donjon.lvl_min or 1
  local max = donjon.lvl_max or 60
  
  if niveau_joueur < min then
    return 3
  end
  
  if niveau_joueur <= min + 5 then
    return 2
  end
  
  if niveau_joueur <= max - 1 then
    return 1
  end
  
  return 4
end

--------------------------------------------------
-- Selection Management
--------------------------------------------------

function clearSelectedDungeons()
  if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearSelection then
    AutoLFM_DungeonList.ClearSelection()
  else
    for _, donjonCheckbox in pairs(donjonCheckButtons or {}) do
      donjonCheckbox:SetChecked(false)
    end
    selectedDungeons = {}
  end
end

function clearSelectedRaids()
  if AutoLFM_RaidList and AutoLFM_RaidList.ClearSelection then
    AutoLFM_RaidList.ClearSelection()
  else
    for _, raidCheckbox in pairs(raidCheckButtons or {}) do
      raidCheckbox:SetChecked(false)
    end
    selectedRaids = {}
  end
end

function clearSelectedRoles()
  selectedRoles = {}
  
  if roleChecks then
    for role, check in pairs(roleChecks) do
      check:SetChecked(false)
    end
  end
end

function resetUserInputMessage()
  userInputMessage = ""
  if editBox then
    editBox:SetText("")
  end
  if updateMsgFrameCombined then
    updateMsgFrameCombined()
  end
end

--------------------------------------------------
-- Backdrop Utilities
--------------------------------------------------

function ClearAllBackdrops(framesTable)
  if not framesTable then return end
  for _, frame in pairs(framesTable) do
    if frame and frame.SetBackdrop then
      frame:SetBackdrop(nil)
    end
  end
end

--------------------------------------------------
-- Getters
--------------------------------------------------

function GetCombinedMessage()
  return combinedMessage or ""
end

function GetSelectedRoles()
  return selectedRoles or {}
end

function GetSelectedDungeons()
  return selectedDungeons or {}
end

function GetSelectedRaids()
  return selectedRaids or {}
end

--------------------------------------------------
-- Slider Management
--------------------------------------------------

function HideSliderForRaid()
  if currentSliderFrame then
    currentSliderFrame:Hide()
    currentSliderFrame = nil
  end
end