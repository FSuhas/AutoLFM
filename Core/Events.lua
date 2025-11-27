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
local eventFrame, initFrame
local lastGroupSize = 0

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================

--- Gets current group size and type
--- @return number, string - Current size and type ("solo", "party", "raid")
local function getGroupInfo()
  local raidCount = GetNumRaidMembers() or 0
  local partyCount = GetNumPartyMembers() or 0

  if raidCount > 0 then
    return raidCount, "raid"
  elseif partyCount > 0 then
    return partyCount + 1, "party"
  else
    return 1, "solo"
  end
end

--=============================================================================
-- EVENT HANDLERS
--=============================================================================

--- Handles QUEST_LOG_UPDATE event - clears cache and refreshes quest UI
local function onQuestLogUpdate()
  if AutoLFM.Logic.Content.Quests then
    AutoLFM.Logic.Content.Quests.ClearCache()
  end

  if AutoLFM_MainFrame and AutoLFM_MainFrame:IsVisible() then
    AutoLFM.Core.Maestro.Dispatch("QuestsList.Refresh")
  end
end

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
    AutoLFM.Core.Maestro.Dispatch("QuestsList.Refresh")
  end

  AutoLFM.Core.Utils.LogInfo("Level up! New level: " .. tostring(newLevel))
end

--- Handles group roster change events - tracks group size and dispatches events
local function onGroupRosterChange()
  local currentSize, groupType = getGroupInfo()

  if currentSize ~= lastGroupSize then
    AutoLFM.Core.Utils.LogAction("Group size: " .. lastGroupSize .. " -> " .. currentSize)

    lastGroupSize = currentSize

    -- Update Maestro states and dispatch event
    AutoLFM.Core.Maestro.SetState("Group.Type", groupType)
    AutoLFM.Core.Maestro.SetState("Group.Size", currentSize)
    AutoLFM.Core.Maestro.Dispatch("Group.SizeChanged", { size = currentSize })
  end
end

--- Handles PARTY_LEADER_CHANGED event - dispatches event
local function onPartyLeaderChanged()
  local isLeader = UnitIsPartyLeader("player") or false
  AutoLFM.Core.Maestro.SetState("Group.IsLeader", isLeader)
  AutoLFM.Core.Maestro.Dispatch("Group.LeaderChanged", { isLeader = isLeader })
end

--- Handles CHAT_MSG_WHISPER event - dispatches whisper data to modules
local function onChatMsgWhisper()
  local message = arg1
  local sender = arg2

  AutoLFM.Core.Maestro.Dispatch("Chat.WhisperReceived", {
    message = message,
    sender = sender
  })
end

--- Routes WoW events to appropriate handler functions
--- @param eventName string - WoW event name
local function onEvent(eventName)

  if eventName == "QUEST_LOG_UPDATE" then
    onQuestLogUpdate()
  elseif eventName == "PLAYER_LEVEL_UP" then
    onPlayerLevelUp()
  elseif eventName == "PARTY_MEMBERS_CHANGED" or eventName == "RAID_ROSTER_UPDATE" then
    onGroupRosterChange()
  elseif eventName == "PARTY_LEADER_CHANGED" then
    onPartyLeaderChanged()
  elseif eventName == "CHAT_MSG_WHISPER" then
    onChatMsgWhisper()
  end
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Initializes the WoW event system and registers all required event listeners
function AutoLFM.Core.Events.Init()
  if not eventFrame then
    eventFrame = CreateFrame("Frame", "AutoLFM_EventFrame")
    eventFrame:SetScript("OnEvent", function()
      onEvent(event)
    end)
  end

  -- Register all events
  eventFrame:RegisterEvent("QUEST_LOG_UPDATE")
  eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
  eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
  eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
  eventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
  eventFrame:RegisterEvent("CHAT_MSG_WHISPER")

  -- Initialize group size tracker and Maestro states
  local initialSize, initialType = getGroupInfo()
  lastGroupSize = initialSize

  AutoLFM.Core.Maestro.SetState("Group.Type", initialType)
  AutoLFM.Core.Maestro.SetState("Group.Size", initialSize)
  AutoLFM.Core.Maestro.SetState("Group.IsLeader", UnitIsPartyLeader("player") or false)

  AutoLFM.Core.Utils.LogInfo("Event system initialized (6 events registered)")
end

--- Forces a refresh of the group size (useful when starting broadcaster)
function AutoLFM.Core.Events.RefreshGroupSize()
  onGroupRosterChange()
end

--=============================================================================
-- SLASH COMMANDS
--=============================================================================

--- Handles slash command input and routes to appropriate actions
--- @param msg string - Command arguments (empty for toggle, "debug" for debug window)
local function handleSlashCommand(msg)
  msg = msg or ""
  local cmd = string.lower(string.sub(msg, 1, string.find(msg .. " ", " ") - 1))

  if cmd == "" then
    AutoLFM.Core.Maestro.Dispatch("MainFrame.Toggle")
  elseif cmd == "debug" then
    AutoLFM.Core.Maestro.Dispatch("Debug.Toggle")
  else
    AutoLFM.Core.Utils.PrintTitle("=== AutoLFM Commands ===")
    AutoLFM.Core.Utils.Print("  /lfm - Toggle main window")
    AutoLFM.Core.Utils.Print("  /lfm debug - Toggle debug window")
  end
end

--=============================================================================
-- STATE DECLARATIONS
--=============================================================================
AutoLFM.Core.SafeRegisterState("Group.Type", "solo", { id = "S10" })
AutoLFM.Core.SafeRegisterState("Group.Size", 1, { id = "S11" })
AutoLFM.Core.SafeRegisterState("Group.IsLeader", false, { id = "S12" })

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

--=============================================================================
-- SLASH COMMAND REGISTRATION
--=============================================================================
SLASH_AUTOLFM1 = "/lfm"
SlashCmdList["AUTOLFM"] = handleSlashCommand
