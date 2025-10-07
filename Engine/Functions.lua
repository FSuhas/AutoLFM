--------------------------------------------------
-- Chat Message Utilities
--------------------------------------------------
local function GetColorHex(colorKey)
  if not colors then return "FFFFFF" end
  for _, color in ipairs(colors) do
    if color.key == colorKey then
      if color.hex then
        return string.gsub(color.hex, "#", "")
      elseif color.r and color.g and color.b then
        return string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
      end
    end
  end
  return "FFFFFF"
end

function ColorText(text, colorKey)
  local hex = GetColorHex(colorKey)
  return "|cff" .. hex .. text .. "|r"
end

function AutoLFM_Print(message, colorKey)
  if not message then return end
  if not addonPrefix then
    addonPrefix = "|cffffffff[Auto|cff0070DDL|cffffffffF|cffff0000M|cffffffff]|r "
  end
  
  local coloredMessage = message
  if colorKey then
    coloredMessage = ColorText(message, colorKey)
  end
  
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage(addonPrefix .. coloredMessage)
  end
end

function AutoLFM_PrintSuccess(message)
  AutoLFM_Print(message, "green")
end

function AutoLFM_PrintError(message)
  AutoLFM_Print(message, "red")
end

function AutoLFM_PrintWarning(message)
  AutoLFM_Print(message, "orange")
end

function AutoLFM_PrintNote(message)
  AutoLFM_Print(message, "yellow")
end

function AutoLFM_PrintInfo(message)
  AutoLFM_Print(message, "gray")
end

--------------------------------------------------
-- String Utilities
--------------------------------------------------
function strsplit(delim, text)
  if not text or not delim then return {} end
  
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
  if not dungeon.levelMin or not dungeon.levelMax then return 5 end
  
  local min = dungeon.levelMin
  local max = dungeon.levelMax
  
  if min < 1 or max < 1 or min > max then return 5 end
  
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
  if not role then return end
  if not roleChecks or not roleChecks[role] then return end
  
  if roleChecks[role]:GetChecked() then
    if not selectedRoles then selectedRoles = {} end
    table.insert(selectedRoles, role)
  else
    if selectedRoles then
      for i, v in ipairs(selectedRoles) do
        if v == role then
          table.remove(selectedRoles, i)
          break
        end
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
      if check and check.SetChecked then
        check:SetChecked(false)
      end
    end
  end
end

function getSelectedRoles()
  return selectedRoles or {}
end

function isRoleSelected(role)
  if not role then return false end
  if not selectedRoles then return false end
  
  for _, selectedRole in ipairs(selectedRoles) do
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
  if not selectedDungeons then selectedDungeons = {} end
  
  if AutoLFM_DungeonList and type(AutoLFM_DungeonList.ClearSelection) == "function" then
    AutoLFM_DungeonList.ClearSelection()
  else
    selectedDungeons = {}
  end
end

function clearSelectedRaids()
  if not selectedRaids then selectedRaids = {} end
  
  if AutoLFM_RaidList and type(AutoLFM_RaidList.ClearSelection) == "function" then
    AutoLFM_RaidList.ClearSelection()
  else
    selectedRaids = {}
  end
end

function resetUserInputMessage()
  userInputMessage = ""
  if editBox and editBox.SetText then
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
  if sliderSizeFrame and sliderSizeFrame.Hide then
    sliderSizeFrame:Hide()
  end
  if currentSliderFrame and currentSliderFrame.Hide then
    currentSliderFrame:Hide()
    currentSliderFrame = nil
  end
  sliderValue = 0
end