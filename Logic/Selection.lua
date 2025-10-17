--=============================================================================
-- AutoLFM: Selection Manager
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Logic then AutoLFM.Logic = {} end
if not AutoLFM.Logic.Selection then AutoLFM.Logic.Selection = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.Logic.Selection.CHANNELS = {"LookingForGroup", "World", "Hardcore"}
AutoLFM.Logic.Selection.ROLES = {"Tank", "Heal", "DPS"}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local selectedRoles = {}
local selectedChannels = {}

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.Logic.Selection.Init()
  local loadedChannels = AutoLFM.Core.Settings.LoadChannels()
  if loadedChannels then
    for k, v in pairs(loadedChannels) do
      selectedChannels[k] = v
    end
  end
end

-----------------------------------------------------------------------------
-- Helpers
-----------------------------------------------------------------------------
local function FindIndex(list, item)
  if not list then return nil end
  
  for i = 1, table.getn(list) do
    if list[i] == item then
      return i
    end
  end
  
  return nil
end

local function ToggleInList(list, item, shouldAdd)
  if not list or not item then return list end
  
  local index = FindIndex(list, item)
  
  if shouldAdd == nil then
    if index then
      table.remove(list, index)
    else
      table.insert(list, item)
    end
  elseif shouldAdd and not index then
    table.insert(list, item)
  elseif not shouldAdd and index then
    table.remove(list, index)
  end
  
  return list
end

-----------------------------------------------------------------------------
-- Group State
-----------------------------------------------------------------------------
function AutoLFM.Logic.Selection.GetMode()
  if selectedRaids and table.getn(selectedRaids) > 0 then
    return "raid"
  elseif selectedDungeons and table.getn(selectedDungeons) > 0 then
    return "dungeon"
  else
    return "none"
  end
end

function AutoLFM.Logic.Selection.GetGroupCount()
  local success, result = pcall(function()
    local mode = AutoLFM.Logic.Selection.GetMode()
    
    if mode == "raid" then
      local raidCount = GetNumRaidMembers()
      if raidCount and raidCount > 0 then return raidCount end
      
      local partyCount = GetNumPartyMembers()
      if partyCount and partyCount > 0 then return partyCount + 1 end
      
      return 1
    elseif mode == "dungeon" then
      local partyCount = GetNumPartyMembers()
      if partyCount and partyCount > 0 then return partyCount + 1 end
      
      return 1
    else
      local raidCount = GetNumRaidMembers()
      if raidCount and raidCount > 0 then return raidCount end
      
      local partyCount = GetNumPartyMembers()
      if partyCount and partyCount > 0 then return partyCount + 1 end
      
      return 1
    end
  end)
  
  if not success then
    return 1
  end
  
  return result
end

-----------------------------------------------------------------------------
-- Roles Management
-----------------------------------------------------------------------------
local function IsValidRole(role)
  if not role then return false end
  
  for i = 1, table.getn(AutoLFM.Logic.Selection.ROLES) do
    if AutoLFM.Logic.Selection.ROLES[i] == role then
      return true
    end
  end
  
  return false
end

function AutoLFM.Logic.Selection.ToggleRole(role)
  if not role then return end
  if not IsValidRole(role) then
    AutoLFM.Core.Utils.PrintWarning("Invalid role: " .. tostring(role))
    return
  end
  
  selectedRoles = ToggleInList(selectedRoles, role)
  
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
end

function AutoLFM.Logic.Selection.ClearRoles()
  while table.getn(selectedRoles) > 0 do
    table.remove(selectedRoles)
  end
  
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
end

function AutoLFM.Logic.Selection.GetRoles()
  return selectedRoles or {}
end

function AutoLFM.Logic.Selection.IsRoleSelected(role)
  return FindIndex(selectedRoles, role) ~= nil
end

function AutoLFM.Logic.Selection.GetRolesCount()
  return table.getn(selectedRoles)
end

function AutoLFM.Logic.Selection.AreAllRolesSelected()
  return table.getn(selectedRoles) == table.getn(AutoLFM.Logic.Selection.ROLES)
end

function AutoLFM.Logic.Selection.GetRolesString()
  local count = table.getn(selectedRoles)
  
  if count == 0 then
    return ""
  end
  
  if AutoLFM.Logic.Selection.AreAllRolesSelected() then
    return "Need All"
  end
  
  return "Need " .. table.concat(selectedRoles, " & ")
end

-----------------------------------------------------------------------------
-- Hardcore Detection
-----------------------------------------------------------------------------
local function IsHardcoreBuffName(buffName)
  if not buffName then return false end
  
  local lowerName = string.lower(buffName)
  return lowerName == "hardcore" or 
         string.find(lowerName, "^hardcore ") or 
         string.find(lowerName, " hardcore$")
end

local function HasHardcoreBuff()
  local i = 1
  while UnitBuff("player", i) do
    local buffName = UnitBuff("player", i)
    if IsHardcoreBuffName(buffName) then
      return true
    end
    i = i + 1
  end
  return false
end

function AutoLFM.Logic.Selection.IsHardcoreMode()
  local channelId = GetChannelName("Hardcore")
  if channelId and channelId > 0 then
    return true
  end
  
  return HasHardcoreBuff()
end

-----------------------------------------------------------------------------
-- Channels Management
-----------------------------------------------------------------------------
local function IsHardcoreChannel(channelName)
  return channelName == "Hardcore"
end

local function IsChannelAvailable(channelName)
  if not channelName then return false end
  
  if IsHardcoreChannel(channelName) then
    return true
  end
  
  local channelId = GetChannelName(channelName)
  return channelId and channelId > 0
end

function AutoLFM.Logic.Selection.FindAvailableChannels()
  local found = {}
  
  for i = 1, table.getn(AutoLFM.Logic.Selection.CHANNELS) do
    local channelName = AutoLFM.Logic.Selection.CHANNELS[i]
    if channelName then
      local channelData = {name = channelName, id = 0}
      
      if IsHardcoreChannel(channelName) then
        table.insert(found, channelData)
      else
        local channelId = GetChannelName(channelName)
        if channelId and channelId > 0 then
          channelData.id = channelId
          table.insert(found, channelData)
        end
      end
    end
  end
  
  return found
end

function AutoLFM.Logic.Selection.ToggleChannel(channelName, isSelected)
  if not channelName then return end
  
  if isSelected then
    selectedChannels[channelName] = true
  else
    selectedChannels[channelName] = nil
  end
  
  AutoLFM.Core.Settings.SaveChannels(selectedChannels)
end

function AutoLFM.Logic.Selection.GetChannels()
  return selectedChannels or {}
end

function AutoLFM.Logic.Selection.IsChannelSelected(channelName)
  if not channelName then return false end
  return selectedChannels[channelName] == true
end

function AutoLFM.Logic.Selection.IsChannelAvailable(channelName)
  return IsChannelAvailable(channelName)
end

function AutoLFM.Logic.Selection.GetChannelId(channelName)
  if not channelName then return nil end
  
  local channelId = GetChannelName(channelName)
  if channelId and channelId > 0 then
    return channelId
  end
  
  return nil
end

function AutoLFM.Logic.Selection.GetChannelsCount()
  local count = 0
  for _ in pairs(selectedChannels) do
    count = count + 1
  end
  
  return count
end

function AutoLFM.Logic.Selection.ValidateChannels()
  local valid = {}
  local invalid = {}
  
  for channelName, _ in pairs(selectedChannels) do
    if IsChannelAvailable(channelName) then
      table.insert(valid, channelName)
    else
      table.insert(invalid, channelName)
    end
  end
  
  return valid, invalid
end

function AutoLFM.Logic.Selection.ClearChannels()
  for k in pairs(selectedChannels) do
    selectedChannels[k] = nil
  end
  AutoLFM.Core.Settings.SaveChannels(selectedChannels)
end
