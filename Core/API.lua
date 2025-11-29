--=============================================================================
-- AutoLFM: Public API
--   Exposes broadcast and addon state for external addons
--   Usage: local api = AutoLFM.API
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.API = {}

--=============================================================================
-- BROADCAST STATE API
--=============================================================================

--- Gets the current broadcast message
--- @return string - The broadcast message, or empty string if none
function AutoLFM.API.GetBroadcastMessage()
  return AutoLFM.Core.Maestro.GetState("Message.ToBroadcast") or ""
end

--- Checks if broadcaster is currently running
--- @return boolean - True if broadcasting
function AutoLFM.API.IsBroadcasting()
  return AutoLFM.Core.Maestro.GetState("Broadcaster.IsRunning") or false
end

--- Gets the current broadcast interval in seconds
--- @return number - Interval in seconds (30-120)
function AutoLFM.API.GetBroadcastInterval()
  return AutoLFM.Core.Maestro.GetState("Broadcaster.Interval") or 60
end

--- Gets the number of messages sent in current session
--- @return number - Message count
function AutoLFM.API.GetMessagesSent()
  return AutoLFM.Core.Maestro.GetState("Broadcaster.MessagesSent") or 0
end

--=============================================================================
-- SELECTION STATE API
--=============================================================================

--- Gets all selected dungeon names
--- @return table - Array of dungeon names (empty if none selected)
function AutoLFM.API.GetSelectedDungeons()
  return AutoLFM.Core.Maestro.GetState("Selection.DungeonNames") or {}
end

--- Gets the selected raid name
--- @return string|nil - Raid name or nil if no raid selected
function AutoLFM.API.GetSelectedRaid()
  return AutoLFM.Core.Maestro.GetState("Selection.RaidName")
end

--- Gets selected roles
--- @return table - Array of role strings {"TANK", "HEAL", "DPS"}
function AutoLFM.API.GetSelectedRoles()
  return AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}
end

--- Gets the current selection mode
--- @return string - "dungeons" | "raid" | "quests" | "custom" | "none"
function AutoLFM.API.GetSelectionMode()
  return AutoLFM.Core.Maestro.GetState("Selection.Mode") or "none"
end

--=============================================================================
-- GROUP STATE API
--=============================================================================

--- Gets current group size
--- @return number - Group size (1-40)
function AutoLFM.API.GetGroupSize()
  return AutoLFM.Core.Maestro.GetState("Group.Size") or 1
end

--- Gets current group type
--- @return string - "solo" | "party" | "raid"
function AutoLFM.API.GetGroupType()
  return AutoLFM.Core.Maestro.GetState("Group.Type") or "solo"
end

--- Checks if player is group leader
--- @return boolean - True if leader (or solo)
function AutoLFM.API.IsGroupLeader()
  return AutoLFM.Core.Maestro.GetState("Group.IsLeader") or false
end

--=============================================================================
-- SETTINGS API
--=============================================================================

--- Checks if dark mode is enabled
--- @return boolean - True if dark mode enabled
function AutoLFM.API.IsDarkModeEnabled()
  return AutoLFM.Core.Maestro.GetState("Settings.DarkMode") or false
end

--- Checks if dry run mode is enabled
--- @return boolean - True if dry run enabled
function AutoLFM.API.IsDryRunEnabled()
  return AutoLFM.Core.Maestro.GetState("Settings.DryRun") or false
end

--- Gets dungeon difficulty filters
--- @return table - Table with color names as keys (GRAY, GREEN, YELLOW, ORANGE, RED)
function AutoLFM.API.GetDungeonFilters()
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.GetDungeonFilters then
    return AutoLFM.Core.Storage.GetDungeonFilters()
  end
  return {}
end

--- Gets broadcast interval setting from storage
--- @return number - Interval in seconds
function AutoLFM.API.GetBroadcastIntervalSetting()
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.GetBroadcastInterval then
    return AutoLFM.Core.Storage.GetBroadcastInterval()
  end
  return 60
end

--=============================================================================
-- EVENT SUBSCRIPTION API
--=============================================================================

--- Subscribes to broadcast state changes
--- Callback will be invoked when any broadcast state changes
--- @param listenerId string - Unique listener identifier
--- @param callback function - Function(newValue) called on state change
--- @return boolean - True if subscription successful
function AutoLFM.API.OnBroadcastStateChanged(listenerId, callback)
  if type(listenerId) ~= "string" or type(callback) ~= "function" then
    return false
  end

  AutoLFM.Core.Maestro.Listen(listenerId, "Broadcaster.*", callback)
  return true
end

--- Subscribes to selection state changes
--- Callback will be invoked when selection changes
--- @param listenerId string - Unique listener identifier
--- @param callback function - Function(newValue) called on state change
--- @return boolean - True if subscription successful
function AutoLFM.API.OnSelectionChanged(listenerId, callback)
  if type(listenerId) ~= "string" or type(callback) ~= "function" then
    return false
  end

  AutoLFM.Core.Maestro.Listen(listenerId, "Selection.*", callback)
  return true
end

--- Subscribes to group state changes
--- Callback will be invoked when group state changes
--- @param listenerId string - Unique listener identifier
--- @param callback function - Function(newValue) called on state change
--- @return boolean - True if subscription successful
function AutoLFM.API.OnGroupStateChanged(listenerId, callback)
  if type(listenerId) ~= "string" or type(callback) ~= "function" then
    return false
  end

  AutoLFM.Core.Maestro.Listen(listenerId, "Group.*", callback)
  return true
end

--- Unsubscribes from state changes
--- @param listenerId string - Listener identifier to remove
--- @return boolean - True if unsubscription successful
function AutoLFM.API.Unsubscribe(listenerId)
  if type(listenerId) ~= "string" then
    return false
  end

  AutoLFM.Core.Maestro.UnListen(listenerId)
  return true
end

--=============================================================================
-- UTILITY FUNCTIONS
--=============================================================================

--- Gets complete snapshot of all broadcast-related state
--- @return table - All broadcast and selection state
function AutoLFM.API.GetSnapshot()
  return {
    broadcast = {
      message = AutoLFM.API.GetBroadcastMessage(),
      isRunning = AutoLFM.API.IsBroadcasting(),
      interval = AutoLFM.API.GetBroadcastInterval(),
      messagesSent = AutoLFM.API.GetMessagesSent(),
    },
    selection = {
      dungeons = AutoLFM.API.GetSelectedDungeons(),
      raid = AutoLFM.API.GetSelectedRaid(),
      roles = AutoLFM.API.GetSelectedRoles(),
      mode = AutoLFM.API.GetSelectionMode(),
    },
    group = {
      size = AutoLFM.API.GetGroupSize(),
      type = AutoLFM.API.GetGroupType(),
      isLeader = AutoLFM.API.IsGroupLeader(),
    },
    settings = {
      darkMode = AutoLFM.API.IsDarkModeEnabled(),
      dryRun = AutoLFM.API.IsDryRunEnabled(),
      dungeonFilters = AutoLFM.API.GetDungeonFilters(),
    }
  }
end

--=============================================================================
-- INITIALIZATION
--=============================================================================
AutoLFM.Core.SafeRegisterInit("Core.API", function()
  -- API is ready after Storage is initialized (Maestro is loaded before all init handlers)
end, {
  id = "I03",
  dependencies = { "Core.Storage" }
})
