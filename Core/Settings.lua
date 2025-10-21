--=============================================================================
-- AutoLFM: Saved Settings Manager
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Core then AutoLFM.Core = {} end
if not AutoLFM.Core.Settings then AutoLFM.Core.Settings = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.Core.Settings.DEFAULTS = {
  MINIMAP_ANGLE = 235,
  MINIMAP_HIDDEN = false,
  BROADCAST_INTERVAL = 60,
  MISC_MODULES = {
    fpsDisplay = false,
    restedXP = false,
    autoInvite = false,
    guildSpam = false,
    autoMarker = false
  }
}

local DEFAULTS = AutoLFM.Core.Settings.DEFAULTS

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local characterID = nil

local function GetCharData()
  if not V2_Settings or not characterID then return nil end
  return V2_Settings[characterID]
end

local function EnsureCharData()
  if not V2_Settings then
    V2_Settings = {}
  end
  
  if not characterID then return false end
  
  if not V2_Settings[characterID] then
    V2_Settings[characterID] = {
      selectedChannels = {},
      minimapBtnHidden = DEFAULTS.MINIMAP_HIDDEN,
      dungeonFilters = {},
      broadcastInterval = DEFAULTS.BROADCAST_INTERVAL,
      miscModules = {},
      miscModulesData = {}
    }
    
    for key, value in pairs(DEFAULTS.MISC_MODULES) do
      V2_Settings[characterID].miscModules[key] = value
    end
  end
  
  return true
end

local function EnsureMiscModules(charData)
  if not charData then return end
  
  if not charData.miscModules then
    charData.miscModules = {}
  end
  
  for key, defaultValue in pairs(DEFAULTS.MISC_MODULES) do
    if charData.miscModules[key] == nil then
      charData.miscModules[key] = defaultValue
    end
  end
end

-----------------------------------------------------------------------------
-- Character
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.InitCharacter()
  local name = UnitName("player") or "Unknown"
  local realm = GetRealmName() or "Unknown"
  characterID = name .. "-" .. realm
  return characterID
end

function AutoLFM.Core.Settings.InitSavedVars()
  if not EnsureCharData() then
    return false
  end
  
  local charData = GetCharData()
  if not charData then return false end
  
  if not charData.dungeonFilters then
    charData.dungeonFilters = {}
  end
  
  if not charData.miscModulesData then
    charData.miscModulesData = {}
  end
  
  EnsureMiscModules(charData)
  
  return true
end

function AutoLFM.Core.Settings.GetCharacterID()
  return characterID
end

-----------------------------------------------------------------------------
-- Channels
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveChannels(channels)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  if charData then
    charData.selectedChannels = channels or {}
  end
end

function AutoLFM.Core.Settings.LoadChannels()
  if not EnsureCharData() then return {} end
  local charData = GetCharData()
  return charData and charData.selectedChannels or {}
end

-----------------------------------------------------------------------------
-- Minimap
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveMinimapPos(x, y)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  if charData then
    charData.minimapBtnX = x
    charData.minimapBtnY = y
  end
end

function AutoLFM.Core.Settings.SaveMinimapHidden(isHidden)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  if charData then
    charData.minimapBtnHidden = (isHidden == true)
  end
end

function AutoLFM.Core.Settings.ResetMinimapPos()
  if not EnsureCharData() then return end
  local charData = GetCharData()
  if charData then
    charData.minimapBtnX = nil
    charData.minimapBtnY = nil
  end
end

function AutoLFM.Core.Settings.LoadMinimap()
  if not EnsureCharData() then
    return {
      hidden = DEFAULTS.MINIMAP_HIDDEN
    }
  end
  
  local charData = GetCharData()
  if not charData then
    return {
      hidden = DEFAULTS.MINIMAP_HIDDEN
    }
  end
  
  return {
    hidden = (charData.minimapBtnHidden == true),
    posX = charData.minimapBtnX,
    posY = charData.minimapBtnY
  }
end

-----------------------------------------------------------------------------
-- Color Filters
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveFilters(filters)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  if not charData then return end
  
  for colorKey, value in pairs(filters) do
    charData.dungeonFilters[colorKey] = (value == true)
  end
end

function AutoLFM.Core.Settings.LoadFilters()
  if not EnsureCharData() then return {} end
  local charData = GetCharData()
  return charData and charData.dungeonFilters or {}
end

-----------------------------------------------------------------------------
-- Broadcast Interval
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveInterval(interval)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  if charData then
    charData.broadcastInterval = interval or DEFAULTS.BROADCAST_INTERVAL
  end
end

function AutoLFM.Core.Settings.LoadInterval()
  if not EnsureCharData() then
    return DEFAULTS.BROADCAST_INTERVAL
  end
  
  local charData = GetCharData()
  return charData and charData.broadcastInterval or DEFAULTS.BROADCAST_INTERVAL
end

-----------------------------------------------------------------------------
-- Misc Modules
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveMiscModule(moduleName, isEnabled)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  if not charData then return end
  
  EnsureMiscModules(charData)
  charData.miscModules[moduleName] = (isEnabled == true)
end

function AutoLFM.Core.Settings.LoadMiscModule(moduleName)
  if not EnsureCharData() then
    return DEFAULTS.MISC_MODULES[moduleName] or false
  end
  
  local charData = GetCharData()
  if not charData then
    return DEFAULTS.MISC_MODULES[moduleName] or false
  end
  
  EnsureMiscModules(charData)
  
  local value = charData.miscModules[moduleName]
  if value == nil then
    return DEFAULTS.MISC_MODULES[moduleName] or false
  end
  
  return value == true
end

function AutoLFM.Core.Settings.GetAllMiscModules()
  if not EnsureCharData() then
    local result = {}
    for key, value in pairs(DEFAULTS.MISC_MODULES) do
      result[key] = value
    end
    return result
  end
  
  local charData = GetCharData()
  if not charData then
    local result = {}
    for key, value in pairs(DEFAULTS.MISC_MODULES) do
      result[key] = value
    end
    return result
  end
  
  EnsureMiscModules(charData)
  return charData.miscModules
end

-----------------------------------------------------------------------------
-- Generic Module Data
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveMiscModuleData(moduleName, key, value)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  if not charData then return end
  
  if not charData.miscModulesData then
    charData.miscModulesData = {}
  end
  
  if not charData.miscModulesData[moduleName] then
    charData.miscModulesData[moduleName] = {}
  end
  
  charData.miscModulesData[moduleName][key] = value
end

function AutoLFM.Core.Settings.LoadMiscModuleData(moduleName, key)
  if not EnsureCharData() then return nil end
  local charData = GetCharData()
  if not charData or not charData.miscModulesData then return nil end
  if not charData.miscModulesData[moduleName] then return nil end
  
  return charData.miscModulesData[moduleName][key]
end
