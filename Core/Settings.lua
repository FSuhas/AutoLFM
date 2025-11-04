--=============================================================================
-- AutoLFM: Saved Settings Manager
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Core then AutoLFM.Core = {} end
if not AutoLFM.Core.Settings then AutoLFM.Core.Settings = {} end

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
      welcomeShown = false,
      dungeonFilters = {},
      minimapBtnHidden = AutoLFM.Core.Constants.DEFAULTS.MINIMAP_HIDDEN,
      minimapBtnX = nil,
      minimapBtnY = nil,
      darkMode = AutoLFM.Core.Constants.DEFAULTS.DARK_MODE,
      selectedChannels = {},
      broadcastInterval = AutoLFM.Core.Constants.DEFAULTS.BROADCAST_INTERVAL,
      miscModules = {},
      miscModulesData = {}
    }
    
    for key, value in pairs(AutoLFM.Core.Constants.DEFAULTS.MISC_MODULES) do
      V2_Settings[characterID].miscModules[key] = value
    end
  end
  
  return true
end

local function EnsureMiscModules(charData)
  if not charData then return end
  if not charData.miscModules then charData.miscModules = {} end
  
  for key, defaultValue in pairs(AutoLFM.Core.Constants.DEFAULTS.MISC_MODULES) do
    if charData.miscModules[key] == nil then
      charData.miscModules[key] = defaultValue
    end
  end
end

-----------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.Init()
  local name = UnitName("player")
  local realm = GetRealmName()
  if not name or not realm then return end
  
  characterID = name .. "-" .. realm
  
  if not EnsureCharData() then return end
  local charData = GetCharData()
  
  if not charData.dungeonFilters then charData.dungeonFilters = {} end
  if not charData.miscModulesData then charData.miscModulesData = {} end
  
  EnsureMiscModules(charData)
end


function AutoLFM.Core.Settings.GetCharacterID()
  return characterID
end

-----------------------------------------------------------------------------
-- UI Settings
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveWelcomeShown(shown)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  
  charData.welcomeShown = (shown == true)
end

function AutoLFM.Core.Settings.LoadWelcomeShown()
  if not EnsureCharData() then return false end
  local charData = GetCharData()
  
  return (charData.welcomeShown == true)
end

function AutoLFM.Core.Settings.SaveFilters(filters)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  
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
-- Minimap Button
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveMinimapPos(x, y)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  
  charData.minimapBtnX = x
  charData.minimapBtnY = y
end

function AutoLFM.Core.Settings.SaveMinimapHidden(isHidden)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  
  charData.minimapBtnHidden = (isHidden == true)
end

function AutoLFM.Core.Settings.ResetMinimapPos()
  if not EnsureCharData() then return end
  local charData = GetCharData()
  
  charData.minimapBtnX = nil
  charData.minimapBtnY = nil
end

function AutoLFM.Core.Settings.LoadMinimap()
  if not EnsureCharData() then
    return { hidden = AutoLFM.Core.Constants.DEFAULTS.MINIMAP_HIDDEN }
  end
  
  local charData = GetCharData()
  if not charData then
    return { hidden = AutoLFM.Core.Constants.DEFAULTS.MINIMAP_HIDDEN }
  end
  
  return {
    hidden = (charData.minimapBtnHidden == true),
    posX = charData.minimapBtnX,
    posY = charData.minimapBtnY
  }
end

-----------------------------------------------------------------------------
-- Dark Mode
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveDarkMode(isEnabled)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  
  charData.darkMode = (isEnabled == true)
end

function AutoLFM.Core.Settings.LoadDarkMode()
  if not EnsureCharData() then
    return AutoLFM.Core.Constants.DEFAULTS.DARK_MODE
  end
  
  local charData = GetCharData()
  if not charData then
    return AutoLFM.Core.Constants.DEFAULTS.DARK_MODE
  end
  
  if charData.darkMode == nil then
    local initialValue = AutoLFM.Core.Constants.DEFAULTS.DARK_MODE
    if initialValue == nil then
      if ShaguTweaks and ShaguTweaks.DarkMode then
        initialValue = true
      else
        initialValue = false
      end
    end
    charData.darkMode = initialValue
    return initialValue
  end
  
  return (charData.darkMode == true)
end

-----------------------------------------------------------------------------
-- Broadcast Settings
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveChannels(channels)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  
  local copy = {}
  for k, v in pairs(channels or {}) do copy[k] = v end
  charData.selectedChannels = copy
end

function AutoLFM.Core.Settings.LoadChannels()
  if not EnsureCharData() then return {} end
  local charData = GetCharData()
  return charData and charData.selectedChannels or {}
end

function AutoLFM.Core.Settings.SaveInterval(interval)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  
  charData.broadcastInterval = interval or AutoLFM.Core.Constants.DEFAULTS.BROADCAST_INTERVAL
end

function AutoLFM.Core.Settings.LoadInterval()
  if not EnsureCharData() then
    return AutoLFM.Core.Constants.DEFAULTS.BROADCAST_INTERVAL
  end
  local charData = GetCharData()
  return charData and charData.broadcastInterval or AutoLFM.Core.Constants.DEFAULTS.BROADCAST_INTERVAL
end

-----------------------------------------------------------------------------
-- Misc Modules
-----------------------------------------------------------------------------
function AutoLFM.Core.Settings.SaveMiscModule(moduleName, isEnabled)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  EnsureMiscModules(charData)
  
  charData.miscModules[moduleName] = (isEnabled == true)
end

function AutoLFM.Core.Settings.LoadMiscModule(moduleName)
  if not EnsureCharData() then
    return AutoLFM.Core.Constants.DEFAULTS.MISC_MODULES[moduleName] or false
  end
  local charData = GetCharData()
  EnsureMiscModules(charData)
  
  local value = charData.miscModules[moduleName]
  return (value == true)
end

function AutoLFM.Core.Settings.GetAllMiscModules()
  local charData = GetCharData()
  if not charData then
    charData = { miscModules = {} }
    for key, value in pairs(AutoLFM.Core.Constants.DEFAULTS.MISC_MODULES) do
      charData.miscModules[key] = value
    end
  end
  EnsureMiscModules(charData)
  return charData.miscModules
end

function AutoLFM.Core.Settings.SaveMiscModuleData(moduleName, key, value)
  if not EnsureCharData() then return end
  local charData = GetCharData()
  
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
