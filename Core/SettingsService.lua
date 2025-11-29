--=============================================================================
-- AutoLFM: Settings Service
--   Abstraction layer for persistent settings (SavedVariables)
--   Encapsulates access to Persistent module for testability
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Core = AutoLFM.Core or {}
AutoLFM.Core.SettingsService = {}

--=============================================================================
-- SETTINGS ACCESSORS (Wrappers around Persistent module)
--=============================================================================

--- Gets the broadcast interval setting
--- @return number - Interval in seconds (30-120)
function AutoLFM.Core.SettingsService.GetBroadcastInterval()
  return AutoLFM.Core.Storage.GetBroadcastInterval()
end

--- Sets the broadcast interval setting
--- @param value number - Interval in seconds (30-120)
function AutoLFM.Core.SettingsService.SetBroadcastInterval(value)
  if type(value) ~= "number" then
    AutoLFM.Core.Utils.LogWarning("SettingsService: SetBroadcastInterval - Invalid type: " .. type(value))
    return false
  end
  if value < 30 or value > 120 then
    AutoLFM.Core.Utils.LogWarning("SettingsService: SetBroadcastInterval - Value out of range: " .. value)
    return false
  end
  return AutoLFM.Core.Storage.SetBroadcastInterval(value)
end

--- Gets the auto-invite enabled setting
--- @return boolean - Whether auto-invite is enabled
function AutoLFM.Core.SettingsService.GetAutoInviteEnabled()
  return AutoLFM.Core.Storage.GetAutoInviteEnabled()
end

--- Sets the auto-invite enabled setting
--- @param value boolean - Whether to enable auto-invite
function AutoLFM.Core.SettingsService.SetAutoInviteEnabled(value)
  if type(value) ~= "boolean" then
    AutoLFM.Core.Utils.LogWarning("SettingsService: SetAutoInviteEnabled - Invalid type: " .. type(value))
    return false
  end
  return AutoLFM.Core.Storage.SetAutoInviteEnabled(value)
end

--- Gets the auto-invite keywords setting
--- @return table - Array of keywords
function AutoLFM.Core.SettingsService.GetAutoInviteKeywords()
  return AutoLFM.Core.Storage.GetAutoInviteKeywords() or {}
end

--- Sets the auto-invite keywords setting
--- @param keywords table - Array of keywords to match
function AutoLFM.Core.SettingsService.SetAutoInviteKeywords(keywords)
  if type(keywords) ~= "table" then
    AutoLFM.Core.Utils.LogWarning("SettingsService: SetAutoInviteKeywords - Invalid type: " .. type(keywords))
    return false
  end
  return AutoLFM.Core.Storage.SetAutoInviteKeywords(keywords)
end

--- Gets the dark mode setting
--- @return boolean - Whether dark mode is enabled
function AutoLFM.Core.SettingsService.GetDarkMode()
  return AutoLFM.Core.Storage.GetDarkMode()
end

--- Sets the dark mode setting
--- @param value boolean - Whether to enable dark mode
function AutoLFM.Core.SettingsService.SetDarkMode(value)
  if type(value) ~= "boolean" then
    AutoLFM.Core.Utils.LogWarning("SettingsService: SetDarkMode - Invalid type: " .. type(value))
    return false
  end
  return AutoLFM.Core.Storage.SetDarkMode(value)
end

--- Gets the dungeon filters setting
--- @return table - Dungeon color filter table
function AutoLFM.Core.SettingsService.GetDungeonFilters()
  return AutoLFM.Core.Storage.GetDungeonFilters() or {}
end

--- Sets the dungeon filters setting
--- @param filters table - Dungeon color filter table
function AutoLFM.Core.SettingsService.SetDungeonFilters(filters)
  if type(filters) ~= "table" then
    AutoLFM.Core.Utils.LogWarning("SettingsService: SetDungeonFilters - Invalid type: " .. type(filters))
    return false
  end
  return AutoLFM.Core.Storage.SetDungeonFilters(filters)
end

--- Gets the selected chat channels setting
--- @return table - Array of channel names
function AutoLFM.Core.SettingsService.GetSelectedChannels()
  return AutoLFM.Core.Storage.GetSelectedChannels() or {}
end

--- Sets the selected chat channels setting
--- @param channels table - Array of channel names
function AutoLFM.Core.SettingsService.SetSelectedChannels(channels)
  if type(channels) ~= "table" then
    AutoLFM.Core.Utils.LogWarning("SettingsService: SetSelectedChannels - Invalid type: " .. type(channels))
    return false
  end
  return AutoLFM.Core.Storage.SetSelectedChannels(channels)
end

--=============================================================================
-- VALIDATION HELPERS
--=============================================================================

--- Validates all settings are within acceptable ranges
--- @return boolean, string - true if valid, false + error message if not
function AutoLFM.Core.SettingsService.ValidateAllSettings()
  local interval = AutoLFM.Core.SettingsService.GetBroadcastInterval()
  if interval < 30 or interval > 120 then
    return false, "Invalid broadcast interval: " .. interval
  end

  local channels = AutoLFM.Core.SettingsService.GetSelectedChannels()
  if not channels or table.getn(channels) == 0 then
    return false, "No channels selected"
  end

  return true, ""
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("Core.SettingsService", function()
  AutoLFM.Core.Utils.LogInfo("SettingsService initialized")
end, { dependencies = {"Core.Storage"} })
