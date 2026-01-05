--=============================================================================
-- AutoLFM: Public API
--   Exposes broadcast and addon state for external addons
--   Usage: local api = AutoLFM.API
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.API = {}

--=============================================================================
-- PRIVATE SUBSCRIPTION TRACKING
--=============================================================================

--- Tracks subscription groups for unsubscribe functionality
--- Maps listenerId → {stateNames: array, callbacks: array}
local subscriptionGroups = {}

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

--- Checks if player is group leader or raid assist
--- @return boolean - True if leader, raid leader, raid assist, or solo
function AutoLFM.API.IsGroupLeader()
  return AutoLFM.Core.Maestro.GetState("Group.IsLeader") or false
end

--=============================================================================
-- SETTINGS API
--=============================================================================

--- Checks if dark mode is enabled
--- @return boolean - True if dark mode enabled
function AutoLFM.API.IsDarkModeEnabled()
  if AutoLFM.Core.Storage and AutoLFM.Core.Storage.GetDarkMode then
    return AutoLFM.Core.Storage.GetDarkMode() or false
  end
  return false
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

--- Subscribes to state changes for broadcast-related states
--- Callback receives (newValue, oldValue) when state changes
--- Use Unsubscribe(listenerId) to stop listening
--- @param listenerId string - Unique listener identifier
--- @param callback function - Function(newValue, oldValue) called on state change
--- @return boolean - True if subscription successful
function AutoLFM.API.OnBroadcastStateChanged(listenerId, callback)
  if type(listenerId) ~= "string" or type(callback) ~= "function" then
    return false
  end

  -- Subscribe to state changes directly via Maestro state subscription
  local broadcastStates = {
    "Broadcaster.IsRunning",
    "Broadcaster.Interval",
    "Broadcaster.MessagesSent",
    "Broadcaster.TimeRemaining"
  }

  -- Store callbacks for unsubscribe functionality
  local callbacks = {}

  for i = 1, table.getn(broadcastStates) do
    local stateName = broadcastStates[i]
    local wrappedCallback = function(newValue, oldValue)
      callback(newValue, oldValue)
    end
    table.insert(callbacks, { stateName = stateName, callback = wrappedCallback })
    AutoLFM.Core.Maestro.SubscribeState(stateName, wrappedCallback)
  end

  -- Track subscription group for unsubscribe
  subscriptionGroups[listenerId] = {
    type = "broadcast",
    stateNames = broadcastStates,
    callbacks = callbacks
  }

  return true
end

--- Subscribes to selection state changes
--- Callback receives (newValue, oldValue) when selection changes
--- @param listenerId string - Unique listener identifier
--- @param callback function - Function(newValue, oldValue) called on state change
--- @return boolean - True if subscription successful
function AutoLFM.API.OnSelectionChanged(listenerId, callback)
  if type(listenerId) ~= "string" or type(callback) ~= "function" then
    return false
  end

  -- Use the Selection.Changed event which is fired when any selection changes
  AutoLFM.Core.Maestro.Listen(listenerId, "Selection.Changed", callback)
  return true
end

--- Subscribes to group state changes
--- Callback receives (newValue, oldValue) when group state changes
--- Use Unsubscribe(listenerId) to stop listening
--- @param listenerId string - Unique listener identifier
--- @param callback function - Function(newValue, oldValue) called on state change
--- @return boolean - True if subscription successful
function AutoLFM.API.OnGroupStateChanged(listenerId, callback)
  if type(listenerId) ~= "string" or type(callback) ~= "function" then
    return false
  end

  -- Subscribe to group state changes directly via Maestro state subscription
  local groupStates = {
    "Group.Size",
    "Group.Type",
    "Group.IsLeader"
  }

  -- Store callbacks for unsubscribe functionality
  local callbacks = {}

  for i = 1, table.getn(groupStates) do
    local stateName = groupStates[i]
    local wrappedCallback = function(newValue, oldValue)
      callback(newValue, oldValue)
    end
    table.insert(callbacks, { stateName = stateName, callback = wrappedCallback })
    AutoLFM.Core.Maestro.SubscribeState(stateName, wrappedCallback)
  end

  -- Track subscription group for unsubscribe
  subscriptionGroups[listenerId] = {
    type = "group",
    stateNames = groupStates,
    callbacks = callbacks
  }

  return true
end

--- Unsubscribes from all state/event changes for a listener
--- Works for: OnBroadcastStateChanged, OnGroupStateChanged, OnSelectionChanged
--- @param listenerId string - Listener identifier returned by subscribe functions
--- @return boolean - True if unsubscription successful, false if listener not found
function AutoLFM.API.Unsubscribe(listenerId)
  if type(listenerId) ~= "string" then
    return false
  end

  -- Check if it's a state subscription group (broadcast or group states)
  local subGroup = subscriptionGroups[listenerId]
  if subGroup then
    -- Unsubscribe from all tracked callbacks in the group
    for i = 1, table.getn(subGroup.callbacks) do
      local cb = subGroup.callbacks[i]
      AutoLFM.Core.Maestro.UnSubscribeState(cb.stateName, cb.callback)
    end
    subscriptionGroups[listenerId] = nil
    AutoLFM.Core.Utils.LogInfo("API: Unsubscribed listener '" .. listenerId .. "'")
    return true
  end

  -- Try to remove event listeners (for Selection.Changed subscriptions)
  if AutoLFM.Core.Maestro.UnListen then
    local success = AutoLFM.Core.Maestro.UnListen(listenerId)
    if success then
      return true
    end
  end

  AutoLFM.Core.Utils.LogWarning("API: Unsubscribe - Listener '" .. listenerId .. "' not found")
  return false
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
