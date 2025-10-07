--------------------------------------------------
-- Chat Message Utilities
--------------------------------------------------
local function GetColorHex(colorKey)
  if not PRIORITY_COLOR_SCHEME then return "FFFFFF" end
  for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
    if color.key == colorKey then
      if color.hex then
        return string.gsub(color.hex, "#", "")
      elseif color.r and color.g and color.b then
        local r = color.r or 1
        local g = color.g or 1
        local b = color.b or 1
        return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
      end
    end
  end
  return "FFFFFF"
end

function ColorizeText(text, colorKey)
  local hex = GetColorHex(colorKey)
  return "|cff" .. hex .. text .. "|r"
end

function AutoLFM_PrintMessage(message, colorKey)
  if not message then return end
  if not CHAT_MESSAGE_PREFIX then
    CHAT_MESSAGE_PREFIX = "|cffffffff[|r|cffFEFE00Auto|r|cff0070DDL|r|cffffffffF|r|cffff0000M|r|cffffffff]|r "
  end
  
  local coloredMessage = message
  if colorKey then
    coloredMessage = ColorizeText(message, colorKey)
  end
  
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage(CHAT_MESSAGE_PREFIX .. coloredMessage)
  end
end

function AutoLFM_PrintSuccess(message)
  AutoLFM_PrintMessage(message, "green")
end

function AutoLFM_PrintError(message)
  AutoLFM_PrintMessage(message, "red")
end

function AutoLFM_PrintWarning(message)
  AutoLFM_PrintMessage(message, "orange")
end

function AutoLFM_PrintNote(message)
  AutoLFM_PrintMessage(message, "yellow")
end

function AutoLFM_PrintInfo(message)
  AutoLFM_PrintMessage(message, "gray")
end

--------------------------------------------------
-- String Utilities
--------------------------------------------------
function SplitString(delim, text)
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
function TableContains(tbl, value)
  if not tbl then return false end
  for _, v in pairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

function TableCount(tbl)
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
function GetPartyMemberCount()
  return GetNumPartyMembers() + 1
end

function GetRaidMemberCount()
  return GetNumRaidMembers()
end

function IsPlayerInRaid()
  return UnitInRaid("player")
end

function HandleRaidRosterUpdate()
  GetRaidMemberCount()
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

function HandlePartyUpdate()
  GetPartyMemberCount()
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Priority Calculation
--------------------------------------------------
function CalculateDungeonPriority(playerLevel, dungeon)
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
function ToggleRoleSelection(role)
  if not role then return end
  if not roleCheckboxes then return end
  if not roleCheckboxes[role] then return end
  
  local isChecked = roleCheckboxes[role]:GetChecked()
  if not isChecked then isChecked = false end
  
  if isChecked then
    if not selectedRolesList then selectedRolesList = {} end
    table.insert(selectedRolesList, role)
  else
    if selectedRolesList then
      for i, v in ipairs(selectedRolesList) do
        if v == role then
          table.remove(selectedRolesList, i)
          break
        end
      end
    end
  end
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

function ClearAllRoles()
  selectedRolesList = {}
  if roleCheckboxes then
    for role, check in pairs(roleCheckboxes) do
      if check and check.SetChecked then
        check:SetChecked(false)
      end
    end
  end
end

function GetSelectedRoles()
  return selectedRolesList or {}
end

function IsRoleSelected(role)
  if not role then return false end
  if not selectedRolesList then return false end
  
  for _, selectedRole in ipairs(selectedRolesList) do
    if selectedRole == role then
      return true
    end
  end
  return false
end

--------------------------------------------------
-- Selection Management
--------------------------------------------------
function ClearDungeonSelection()
  if not selectedDungeonTags then selectedDungeonTags = {} end
  
  if AutoLFM_DungeonList and type(AutoLFM_DungeonList.ClearSelection) == "function" then
    AutoLFM_DungeonList.ClearSelection()
  else
    selectedDungeonTags = {}
  end
end

function ClearRaidSelection()
  if not selectedRaidTags then selectedRaidTags = {} end
  
  if AutoLFM_RaidList and type(AutoLFM_RaidList.ClearSelection) == "function" then
    AutoLFM_RaidList.ClearSelection()
  else
    selectedRaidTags = {}
  end
end

function ResetCustomMessage()
  customUserMessage = ""
  if customMessageEditBox and customMessageEditBox.SetText then
    customMessageEditBox:SetText("")
  end
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
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
function GetGeneratedLFMMessage()
  return generatedLFMMessage or ""
end

function GetSelectedRolesList()
  return selectedRolesList or {}
end

function GetSelectedDungeonsList()
  return selectedDungeonTags or {}
end

function GetSelectedRaidsList()
  return selectedRaidTags or {}
end

--------------------------------------------------
-- Slider Management
--------------------------------------------------
function HideRaidSizeControls()
  if raidSizeControlFrame and raidSizeControlFrame.Hide then
    raidSizeControlFrame:Hide()
  end
  raidGroupSize = 0
end