--=============================================================================
-- AutoLFM: Event Handling
--   Centralized WoW event management for auto-refresh and reactivity
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Core = AutoLFM.Core or {}
AutoLFM.Core.Events = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local eventFrame = nil
local initFrame = nil
local lastGroupSize = 0  -- Track group size changes

--=============================================================================
-- TEST MODE STATE
--=============================================================================
local testModeEnabled = false
local simulatedGroupSize = 1

--=============================================================================
-- EVENT HANDLERS
--=============================================================================
-----------------------------------------------------------------------------
-- Quest Log Update Handler
-----------------------------------------------------------------------------

--- Handles QUEST_LOG_UPDATE event - clears cache and refreshes quest UI
local function onQuestLogUpdate()
  if AutoLFM.Logic.Content.Quests then
    AutoLFM.Logic.Content.Quests.ClearCache()
  end

  if AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() then
    if AutoLFM.Core.Maestro then
      AutoLFM.Core.Maestro.Dispatch("QuestsList.Refresh")
    end
  end
end

-----------------------------------------------------------------------------
-- Player Level Up Handler
-----------------------------------------------------------------------------

--- Handles PLAYER_LEVEL_UP event - clears caches and refreshes dungeon/quest UI
local function onPlayerLevelUp()
  local newLevel = arg1

  if AutoLFM.Logic.Content.Quests then
    AutoLFM.Logic.Content.Quests.ClearCache()
  end

  if AutoLFM.Logic.Content.Dungeons then
    AutoLFM.Logic.Content.Dungeons.ClearCache()
  end

  if AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() then
    if AutoLFM.Core.Maestro then
      AutoLFM.Core.Maestro.Dispatch("DungeonsList.Refresh")
      AutoLFM.Core.Maestro.Dispatch("QuestsList.Refresh")
    end
  end

  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogInfo then
    AutoLFM.Core.Utils.LogInfo("Level up! New level: " .. tostring(newLevel))
  end
end

-----------------------------------------------------------------------------
-- Group Roster Change Handler
--   Handles PARTY_MEMBERS_CHANGED and RAID_ROSTER_UPDATE
--   Updates broadcast message when group composition changes
-----------------------------------------------------------------------------

--- Handles group roster change events - tracks group size and dispatches events
local function onGroupRosterChange()
  -- Get current group size
  local currentSize = 1
  local raidCount = GetNumRaidMembers()
  local partyCount = GetNumPartyMembers()

  -- Debug log
  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogDebug then
    AutoLFM.Core.Utils.LogDebug("onGroupRosterChange: raidCount=" .. tostring(raidCount) .. ", partyCount=" .. tostring(partyCount))
  end

  if raidCount and raidCount > 0 then
    currentSize = raidCount
  elseif partyCount and partyCount > 0 then
    currentSize = partyCount + 1
  end

  -- Determine group type
  local groupType = "solo"
  if raidCount and raidCount > 0 then
    groupType = "raid"
  elseif partyCount and partyCount > 0 then
    groupType = "party"
  end

  -- Debug log
  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogDebug then
    AutoLFM.Core.Utils.LogDebug("onGroupRosterChange: currentSize=" .. currentSize .. ", lastGroupSize=" .. lastGroupSize .. ", groupType=" .. groupType)
  end

  -- Only process if size actually changed (prevents duplicate triggers)
  if currentSize ~= lastGroupSize then
    if AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogAction then
      AutoLFM.Core.Utils.LogAction("Group size changed: " .. lastGroupSize .. " -> " .. currentSize)
    end

    lastGroupSize = currentSize

    -- Call Broadcaster to handle group size changes
    if AutoLFM.Logic.Broadcaster then
      AutoLFM.Logic.Broadcaster.OnGroupSizeChanged(currentSize)
    end

    -- Update Maestro states
    if AutoLFM.Core.Maestro then
      AutoLFM.Core.Maestro.SetState("Group.Size", currentSize)
      AutoLFM.Core.Maestro.SetState("Group.Type", groupType)
    end

    -- Dispatch Maestro event for UI updates
    if AutoLFM.Core.Maestro then
      AutoLFM.Core.Maestro.Dispatch("Group.SizeChanged", { size = currentSize })
    end
  end
end

-----------------------------------------------------------------------------
-- Party Leader Changed Handler
--   Triggers when party/raid leader changes
--   Important for Auto Invite: can only invite if leader
-----------------------------------------------------------------------------

--- Handles PARTY_LEADER_CHANGED event - logs change and dispatches event
local function onPartyLeaderChanged()
  local isLeader = UnitIsPartyLeader("player")

  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogInfo then
    if isLeader then
      AutoLFM.Core.Utils.LogInfo("You are now the party leader")
    else
      AutoLFM.Core.Utils.LogInfo("Party leader changed")
    end
  end

  -- Update Maestro state
  if AutoLFM.Core.Maestro then
    AutoLFM.Core.Maestro.SetState("Group.IsLeader", isLeader)
  end

  -- Dispatch event for modules that care about leader status (e.g., Auto Invite)
  if AutoLFM.Core.Maestro then
    AutoLFM.Core.Maestro.Dispatch("Group.LeaderChanged", {
      isLeader = isLeader
    })
  end
end

-----------------------------------------------------------------------------
-- Chat Message Handler
--   Handles whispers for Auto Invite module (keyword detection)
-----------------------------------------------------------------------------

--- Handles CHAT_MSG_WHISPER event - dispatches whisper data to modules
local function onChatMsgWhisper()
  local message = arg1
  local sender = arg2

  -- Dispatch to modules that need whisper handling (e.g., Auto Invite)
  if AutoLFM.Core.Maestro then
    AutoLFM.Core.Maestro.Dispatch("Chat.WhisperReceived", {
      message = message,
      sender = sender
    })
  end
end

-----------------------------------------------------------------------------
-- Main Event Router
-----------------------------------------------------------------------------

--- Routes WoW events to appropriate handler functions
--- @param event string - WoW event name
local function onEvent(event)
  -- Debug log for all events
  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogDebug then
    AutoLFM.Core.Utils.LogDebug("WoW Event received: " .. tostring(event))
  end

  if event == "QUEST_LOG_UPDATE" then
    onQuestLogUpdate()

  elseif event == "PLAYER_LEVEL_UP" then
    onPlayerLevelUp()

  elseif event == "PARTY_MEMBERS_CHANGED" then
    onGroupRosterChange()

  elseif event == "RAID_ROSTER_UPDATE" then
    onGroupRosterChange()

  elseif event == "PARTY_LEADER_CHANGED" then
    onPartyLeaderChanged()

  elseif event == "CHAT_MSG_WHISPER" then
    onChatMsgWhisper()
  end
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Initializes the WoW event system and registers all required event listeners
--- Events registered:
---   - QUEST_LOG_UPDATE: Quest log changes
---   - PLAYER_LEVEL_UP: Player gains a level
---   - PARTY_MEMBERS_CHANGED: Party composition changes (CRITICAL for broadcast)
---   - RAID_ROSTER_UPDATE: Raid composition changes (CRITICAL for broadcast)
---   - PARTY_LEADER_CHANGED: Party leader changes (for Auto Invite)
---   - CHAT_MSG_WHISPER: Whisper received (for Auto Invite)
function AutoLFM.Core.Events.Init()
  if not eventFrame then
    eventFrame = CreateFrame("Frame", "AutoLFM_EventFrame")
    eventFrame:SetScript("OnEvent", function()
      onEvent(event)
    end)
  end

  -- Quest & Progression
  eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
  eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

  -- Group & Raid Management (CRITICAL)
  eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
  eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
  eventFrame:RegisterEvent("PARTY_LEADER_CHANGED")

  -- Chat (for Auto Invite)
  eventFrame:RegisterEvent("CHAT_MSG_WHISPER")

  -- Debug log to confirm events are registered
  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogInfo then
    AutoLFM.Core.Utils.LogInfo("Events registered: PARTY_MEMBERS_CHANGED, RAID_ROSTER_UPDATE, PARTY_LEADER_CHANGED, CHAT_MSG_WHISPER, QUEST_LOG_UPDATE, PLAYER_LEVEL_UP")
  end

  -- Initialize group size tracker and Maestro states
  local raidCount = GetNumRaidMembers()
  local partyCount = GetNumPartyMembers()
  local initialSize = 1
  local initialType = "solo"

  if raidCount and raidCount > 0 then
    initialSize = raidCount
    initialType = "raid"
  elseif partyCount and partyCount > 0 then
    initialSize = partyCount + 1
    initialType = "party"
  end

  lastGroupSize = initialSize

  -- Update initial Maestro states
  if AutoLFM.Core.Maestro then
    AutoLFM.Core.Maestro.SetState("Group.Size", initialSize)
    AutoLFM.Core.Maestro.SetState("Group.Type", initialType)
    AutoLFM.Core.Maestro.SetState("Group.IsLeader", UnitIsPartyLeader("player") or false)
  end

  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogInfo then
    AutoLFM.Core.Utils.LogInfo("Event system initialized (6 events registered)")
  end
end

--- Gets current group size (1 for solo, 2-5 for party, 6-40 for raid)
--- @return number - Current group size
function AutoLFM.Core.Events.GetGroupSize()
  -- Return simulated size if test mode is enabled
  if testModeEnabled then
    return simulatedGroupSize
  end

  local raidCount = GetNumRaidMembers()
  local partyCount = GetNumPartyMembers()

  if raidCount and raidCount > 0 then
    return raidCount
  elseif partyCount and partyCount > 0 then
    return partyCount + 1
  else
    return 1
  end
end

--- Gets current group type
--- @return string - "solo", "party", or "raid"
function AutoLFM.Core.Events.GetGroupType()
  local raidCount = GetNumRaidMembers()
  local partyCount = GetNumPartyMembers()

  if raidCount and raidCount > 0 then
    return "raid"
  elseif partyCount and partyCount > 0 then
    return "party"
  else
    return "solo"
  end
end

--- Checks if player is party/raid leader
--- @return boolean - True if player is leader
function AutoLFM.Core.Events.IsGroupLeader()
  return UnitIsPartyLeader("player") or false
end

--- Forces a refresh of the group size (useful when starting broadcaster)
function AutoLFM.Core.Events.RefreshGroupSize()
  onGroupRosterChange()
end

--=============================================================================
-- TEST MODE API
--=============================================================================

--- Enables test mode for simulating group size changes
function AutoLFM.Core.Events.EnableTestMode()
  testModeEnabled = true
  simulatedGroupSize = 1
end

--- Disables test mode and returns to real group size
function AutoLFM.Core.Events.DisableTestMode()
  testModeEnabled = false
  simulatedGroupSize = 1
end

--- Checks if test mode is currently enabled
--- @return boolean - True if test mode is active
function AutoLFM.Core.Events.IsTestModeEnabled()
  return testModeEnabled
end

--- Sets the simulated group size (only works in test mode)
--- @param size number - The simulated group size (1-40)
function AutoLFM.Core.Events.SetSimulatedGroupSize(size)
  if not testModeEnabled then
    return
  end

  if size < 1 then size = 1 end
  if size > 40 then size = 40 end

  simulatedGroupSize = size
end

--- Gets the simulated group size (for test mode)
--- @return number - The current simulated size
function AutoLFM.Core.Events.GetSimulatedGroupSize()
  return simulatedGroupSize
end

--=============================================================================
-- STATE DECLARATIONS
--=============================================================================
AutoLFM.Core.SafeRegisterState("Group.Size", 1, { id = "S11" })
AutoLFM.Core.SafeRegisterState("Group.Type", "solo", { id = "S12" })
AutoLFM.Core.SafeRegisterState("Group.IsLeader", false, { id = "S13" })

--=============================================================================
-- EVENT DECLARATIONS
--=============================================================================
AutoLFM.Core.Maestro.RegisterEvent("Group.SizeChanged", { id = "E02" })
AutoLFM.Core.Maestro.RegisterEvent("Group.LeaderChanged", { id = "E03" })
AutoLFM.Core.Maestro.RegisterEvent("Chat.WhisperReceived", { id = "E04" })

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("Core.Events", function()
  AutoLFM.Core.Events.Init()
end, { id = "I01" })

-- Handle PLAYER_ENTERING_WORLD for game initialization
initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function()
  AutoLFM.Core.Maestro.RunInit()
  initFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)
