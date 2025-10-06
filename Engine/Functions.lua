--------------------------------------------------
-- Chat Message Utilities
--------------------------------------------------
function AutoLFM_Print(message, r, g, b)
  if not addonPrefix then
    addonPrefix = "|cffffffff[Auto|cff0070DDL|cffffffffF|cffff0000M|cffffffff]|r "
  end
  
  local coloredMessage = message
  if r and g and b then
    coloredMessage = string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, message)
  end
  
  DEFAULT_CHAT_FRAME:AddMessage(addonPrefix .. coloredMessage)
end

function AutoLFM_PrintSuccess(message)
  AutoLFM_Print(message, 0, 1, 0)
end

function AutoLFM_PrintError(message)
  AutoLFM_Print(message, 1, 0, 0)
end

function AutoLFM_PrintWarning(message)
  AutoLFM_Print(message, 1, 1, 0)
end

function AutoLFM_PrintInfo(message)
  AutoLFM_Print(message, 1, 1, 1)
end

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
function CalculatePriority(playerLevel, dungeon)
  if not playerLevel or not dungeon then return 5 end
  local min = dungeon.levelMin or 1
  local max = dungeon.levelMax or 60
  local avg = math.floor((min + max) / 2)
  local diff = avg - playerLevel
  local greenThreshold
  if playerLevel <= 9 then
    greenThreshold = 4
  elseif playerLevel <= 19 then
    greenThreshold = 5
  elseif playerLevel <= 29 then
    greenThreshold = 6
  elseif playerLevel <= 39 then
    greenThreshold = 7
  else
    greenThreshold = 8
  end
  if diff >= 5 then
    return 4
  end
  if diff >= 3 and diff <= 4 then
    return 3
  end
  if diff >= -2 and diff <= 2 then
    return 2
  end
  if diff < -2 and diff >= -(greenThreshold) then
    return 1
  end
  return 5
end

--------------------------------------------------
-- Role Functions
--------------------------------------------------
function toggleRole(role)
  if not roleChecks or not roleChecks[role] then return end
  
  if roleChecks[role]:GetChecked() then
    table.insert(selectedRoles, role)
  else
    for i, v in ipairs(selectedRoles) do
      if v == role then
        table.remove(selectedRoles, i)
        break
      end
    end
  end
  
  if updateMsgFrameCombined then
    updateMsgFrameCombined()
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

function getSelectedRoles()
  return selectedRoles or {}
end

function isRoleSelected(role)
  for _, selectedRole in ipairs(selectedRoles or {}) do
    if selectedRole == role then
      return true
    end
  end
  return false
end

--------------------------------------------------
-- Selection Management
--------------------------------------------------
function clearSelectedDungeons()
  if AutoLFM_DungeonList and AutoLFM_DungeonList.ClearSelection then
    AutoLFM_DungeonList.ClearSelection()
  else
    for _, dungeonCheckbox in pairs(dungeonCheckButtons or {}) do
      dungeonCheckbox:SetChecked(false)
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
  if sliderSizeFrame then
    sliderSizeFrame:Hide()
  end
  if currentSliderFrame then
    currentSliderFrame:Hide()
    currentSliderFrame = nil
  end
  sliderValue = 0
end