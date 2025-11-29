--=============================================================================
-- AutoLFM: Hybrid Settings Manager
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Core then AutoLFM.Core = {} end
if not AutoLFM.Core.Settings then AutoLFM.Core.Settings = {} end

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local characterID = nil
local charData = nil

local function GetCharData(safe)
  if not charData and characterID and V2_Settings then
    charData = V2_Settings[characterID]
  end
  if not charData and safe then
    AutoLFM.Core.Utils.PrintError("[Settings] Character data missing for " .. tostring(characterID))
  end
  return charData
end

local function EnsureCharData()
  if not V2_Settings then V2_Settings = {} end
  if not characterID then
    AutoLFM.Core.Utils.PrintError("[Settings] characterID not set")
    return false
  end

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
    for k, v in pairs(defaults.MISC_MODULES) do
      V2_Settings[characterID].miscModules[k] = v
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
  local data = GetCharData(true)
  if data then data.welcomeShown = shown == true end
end

function AutoLFM.Core.Settings.LoadWelcomeShown()
  local data = GetCharData(true)
  return data and data.welcomeShown == true or false
end

function AutoLFM.Core.Settings.SaveFilters(filters)
  local data = GetCharData(true)
  if not data then return end
  for k, v in pairs(filters) do data.dungeonFilters[k] = v == true end
end

function AutoLFM.Core.Settings.LoadFilters()
  local data = GetCharData(true)
  return data and data.dungeonFilters or {}
end

-----------------------------------------------------------------------------
-- Minimap Button
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveMinimapPos(x, y)
  local data = GetCharData(true)
  if data then
    data.minimapBtnX = x
    data.minimapBtnY = y
  end
end

function AutoLFM.Core.Settings.SaveMinimapHidden(hidden)
  local data = GetCharData(true)
  if data then data.minimapBtnHidden = hidden == true end
end

function AutoLFM.Core.Settings.ResetMinimapPos()
  local data = GetCharData(true)
  if data then
    data.minimapBtnX = nil
    data.minimapBtnY = nil
  end
end

function AutoLFM.Core.Settings.LoadMinimap()
  local data = GetCharData(true)
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
function AutoLFM.Core.Settings.SaveDarkMode(enabled)
  local data = GetCharData(true)
  if data then data.darkMode = enabled == true end
end

function AutoLFM.Core.Settings.LoadDarkMode()
  local data = GetCharData(true)
  if not data then return AutoLFM.Core.Constants.DEFAULTS.DARK_MODE end

  if data.darkMode == nil then
    local val = AutoLFM.Core.Constants.DEFAULTS.DARK_MODE
    if val == nil then val = ShaguTweaks and ShaguTweaks.DarkMode or false end
    data.darkMode = val
    return val
  end
  return data.darkMode == true
end

-----------------------------------------------------------------------------
-- Broadcast Settings
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveChannels(channels)
  local data = GetCharData(true)
  if not data then return end
  local copy = {}
  for k,v in pairs(channels or {}) do copy[k] = v end
  data.selectedChannels = copy
end

function AutoLFM.Core.Settings.LoadChannels()
  local data = GetCharData(true)
  return data and data.selectedChannels or {}
end

function AutoLFM.Core.Settings.SaveInterval(interval)
  local data = GetCharData(true)
  if data then
    data.broadcastInterval = interval or AutoLFM.Core.Constants.DEFAULTS.BROADCAST_INTERVAL
  end
end

function AutoLFM.Core.Settings.LoadInterval()
  local data = GetCharData(true)
  return data and data.broadcastInterval or AutoLFM.Core.Constants.DEFAULTS.BROADCAST_INTERVAL
end

-----------------------------------------------------------------------------
-- Misc Modules
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveMiscModule(name, enabled)
  local data = GetCharData(true)
  if not data then return end
  EnsureMiscModules(data)
  data.miscModules[name] = enabled == true
end

function AutoLFM.Core.Settings.LoadMiscModule(name)
  local data = GetCharData(true)
  if not data then return AutoLFM.Core.Constants.DEFAULTS.MISC_MODULES[name] or false end
  EnsureMiscModules(data)
  return data.miscModules[name] == true
end

function AutoLFM.Core.Settings.GetAllMiscModules()
  local data = GetCharData(true)
  if not data then
    data = { miscModules = {} }
    for k,v in pairs(AutoLFM.Core.Constants.DEFAULTS.MISC_MODULES) do
      data.miscModules[k] = v
    end
  end
  EnsureMiscModules(data)
  return data.miscModules
end

function AutoLFM.Core.Settings.SaveMiscModuleData(name, key, value)
  local data = GetCharData(true)
  if not data then return end
  data.miscModulesData = data.miscModulesData or {}
  data.miscModulesData[name] = data.miscModulesData[name] or {}
  data.miscModulesData[name][key] = value
end

function AutoLFM.Core.Settings.LoadMiscModuleData(name, key)
  local data = GetCharData(true)
  return data and data.miscModulesData and data.miscModulesData[name] and
         data.miscModulesData[name][key]
end
