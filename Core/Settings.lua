--=============================================================================
-- AutoLFM:  Saved Settings Manager
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Core then AutoLFM.Core = {} end
if not AutoLFM.Core.Settings then AutoLFM.Core.Settings = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local characterID = nil
local charData = nil

local function GetCharData()
  if not charData and characterID and V2_Settings then
    charData = V2_Settings[characterID]
  end
  return charData
end

local function EnsureCharData()
  if not V2_Settings then V2_Settings = {} end
  if not characterID then return false end
  
  if not V2_Settings[characterID] then
    local defaults = AutoLFM.Core.Constants.DEFAULTS
    V2_Settings[characterID] = {
      welcomeShown = false,
      dungeonFilters = {},
      minimapBtnHidden = defaults.MINIMAP_HIDDEN,
      minimapBtnX = nil,
      minimapBtnY = nil,
      darkMode = defaults.DARK_MODE,
      selectedChannels = {},
      broadcastInterval = defaults.BROADCAST_INTERVAL,
      miscModules = {},
      miscModulesData = {}
    }
    
    for key, value in pairs(defaults.MISC_MODULES) do
      V2_Settings[characterID].miscModules[key] = value
    end
  end
  
  charData = V2_Settings[characterID]
  return true
end

local function EnsureMiscModules(data)
  if not data or not data.miscModules then return end
  
  for key, defaultValue in pairs(AutoLFM.Core.Constants.DEFAULTS.MISC_MODULES) do
    if data.miscModules[key] == nil then
      data.miscModules[key] = defaultValue
    end
  end
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.Init()
  local name, realm = UnitName("player"), GetRealmName()
  if not name or not realm then return end
  
  characterID = name .. "-" .. realm
  if not EnsureCharData() then return end
  
  charData.dungeonFilters = charData.dungeonFilters or {}
  charData.miscModulesData = charData.miscModulesData or {}
  EnsureMiscModules(charData)
end

function AutoLFM.Core.Settings.GetCharacterID()
  return characterID
end

-----------------------------------------------------------------------------
-- UI Settings
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveWelcomeShown(shown)
  local data = GetCharData()
  if data then data.welcomeShown = shown == true end
end

function AutoLFM.Core.Settings.LoadWelcomeShown()
  local data = GetCharData()
  return data and data.welcomeShown == true or false
end

function AutoLFM.Core.Settings.SaveFilters(filters)
  local data = GetCharData()
  if not data then return end
  
  for colorKey, value in pairs(filters) do
    data.dungeonFilters[colorKey] = value == true
  end
end

function AutoLFM.Core.Settings.LoadFilters()
  local data = GetCharData()
  return data and data.dungeonFilters or {}
end

-----------------------------------------------------------------------------
-- Minimap Button
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveMinimapPos(x, y)
  local data = GetCharData()
  if data then
    data.minimapBtnX = x
    data.minimapBtnY = y
  end
end

function AutoLFM.Core.Settings.SaveMinimapHidden(isHidden)
  local data = GetCharData()
  if data then data.minimapBtnHidden = isHidden == true end
end

function AutoLFM.Core.Settings.ResetMinimapPos()
  local data = GetCharData()
  if data then
    data.minimapBtnX = nil
    data.minimapBtnY = nil
  end
end

function AutoLFM.Core.Settings.LoadMinimap()
  local data = GetCharData()
  local defaults = AutoLFM.Core.Constants.DEFAULTS
  
  return {
    hidden = data and data.minimapBtnHidden == true or defaults.MINIMAP_HIDDEN,
    posX = data and data.minimapBtnX,
    posY = data and data.minimapBtnY
  }
end

-----------------------------------------------------------------------------
-- Dark Mode
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveDarkMode(isEnabled)
  local data = GetCharData()
  if data then data.darkMode = isEnabled == true end
end

function AutoLFM.Core.Settings.LoadDarkMode()
  local data = GetCharData()
  if not data then return AutoLFM.Core.Constants.DEFAULTS.DARK_MODE end
  
  if data.darkMode == nil then
    local initialValue = AutoLFM.Core.Constants.DEFAULTS.DARK_MODE
    if initialValue == nil then
      initialValue = ShaguTweaks and ShaguTweaks.DarkMode or false
    end
    data.darkMode = initialValue
    return initialValue
  end
  
  return data.darkMode == true
end

-----------------------------------------------------------------------------
-- Broadcast Settings
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveChannels(channels)
  local data = GetCharData()
  if not data then return end
  
  local copy = {}
  for k, v in pairs(channels or {}) do copy[k] = v end
  data.selectedChannels = copy
end

function AutoLFM.Core.Settings.LoadChannels()
  local data = GetCharData()
  return data and data.selectedChannels or {}
end

function AutoLFM.Core.Settings.SaveInterval(interval)
  local data = GetCharData()
  if data then
    data.broadcastInterval = interval or AutoLFM.Core.Constants.DEFAULTS.BROADCAST_INTERVAL
  end
end

function AutoLFM.Core.Settings.LoadInterval()
  local data = GetCharData()
  return data and data.broadcastInterval or AutoLFM.Core.Constants.DEFAULTS.BROADCAST_INTERVAL
end

-----------------------------------------------------------------------------
-- Misc Modules
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveMiscModule(moduleName, isEnabled)
  local data = GetCharData()
  if not data then return end
  EnsureMiscModules(data)
  data.miscModules[moduleName] = isEnabled == true
end

function AutoLFM.Core.Settings.LoadMiscModule(moduleName)
  local data = GetCharData()
  if not data then
    return AutoLFM.Core.Constants.DEFAULTS.MISC_MODULES[moduleName] or false
  end
  EnsureMiscModules(data)
  return data.miscModules[moduleName] == true
end

function AutoLFM.Core.Settings.GetAllMiscModules()
  local data = GetCharData()
  if not data then
    data = { miscModules = {} }
    for key, value in pairs(AutoLFM.Core.Constants.DEFAULTS.MISC_MODULES) do
      data.miscModules[key] = value
    end
  end
  EnsureMiscModules(data)
  return data.miscModules
end

function AutoLFM.Core.Settings.SaveMiscModuleData(moduleName, key, value)
  local data = GetCharData()
  if not data then return end
  
  data.miscModulesData = data.miscModulesData or {}
  data.miscModulesData[moduleName] = data.miscModulesData[moduleName] or {}
  data.miscModulesData[moduleName][key] = value
end

function AutoLFM.Core.Settings.LoadMiscModuleData(moduleName, key)
  local data = GetCharData()
  return data and data.miscModulesData and data.miscModulesData[moduleName] and
         data.miscModulesData[moduleName][key]
end
