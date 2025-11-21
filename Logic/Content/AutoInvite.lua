--=============================================================================
-- AutoLFM: AutoInvite Logic
--   Handles automatic group invitations based on whisper keywords
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.AutoInvite = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================

--=============================================================================
-- INVITE MESSAGES
--=============================================================================
local inviteMessages = {
  "⚔️ %s, the Light demands your presence!",
  "🛡️ %s, by the Light! Join us!",
  "✨ %s, the Light calls you to adventure!",
  "⚔️ %s, the crusade awaits!",
  "🔥 %s, blessed hammer in hand, join the fight!"
}

--- Returns a random invitation message with the target name
--- @param target string - Player name to insert in the message
--- @return string - Formatted invitation message
local function getRandomInviteMessage(target)
  local index = math.random(1, table.getn(inviteMessages))
  return string.format(inviteMessages[index], target)
end

--=============================================================================
-- HELPERS
--=============================================================================

--- Checks if player is group leader or solo
--- @return boolean - True if player can invite (leader or solo)
local function isPlayerLeaderOrSolo()
  if not UnitInParty("player") then return true end
  return UnitIsPartyLeader("player")
end

--- Trims whitespace from both ends of a string
--- @param text string - Text to trim
--- @return string - Trimmed text
local function trim(text)
  if not text then return "" end
  return string.gsub(text, "^%s*(.-)%s*$", "%1")
end

--=============================================================================
-- INVITE LOGIC
--=============================================================================

--- Handles incoming whisper messages and auto-invites if keyword matches
--- @param data table - Whisper data with message and sender fields
local function handleWhisper(data)
  local enabled = AutoLFM.Core.Persistent.GetAutoInviteEnabled()
  if not enabled then return end
  
  local message = data.message
  local sender = data.sender
  if not message or not sender then return end
  
  local keyword = AutoLFM.Core.Persistent.GetAutoInviteKeyword()
  local trimmed = trim(message)
  local lowerMsg = string.lower(trimmed)
  local lowerKey = string.lower(keyword)
  
  if not string.find(lowerMsg, lowerKey, 1, true) then return end
  
  local playerName = UnitName("player")
  if sender == playerName then return end
  
  if isPlayerLeaderOrSolo() then
    InviteByName(sender)
    
    local sendConfirm = AutoLFM.Core.Persistent.GetAutoInviteConfirm()
    if sendConfirm then
      SendChatMessage(getRandomInviteMessage(sender), "WHISPER", nil, sender)
    end
    
    AutoLFM.Core.Utils.LogAction("Auto-invited " .. sender)
  else
    local sendConfirm = AutoLFM.Core.Persistent.GetAutoInviteConfirm()
    if sendConfirm then
      SendChatMessage("Cannot invite: I'm not the group leader.", "WHISPER", nil, sender)
    end
  end
end

--=============================================================================
-- COMMANDS
--=============================================================================

--- Command: Enable AutoInvite
--- Activates automatic group invitations based on whisper keywords
AutoLFM.Core.Maestro.RegisterCommand("AutoInvite.Enable", function()
  AutoLFM.Core.Persistent.SetAutoInviteEnabled(true)
  local keyword = AutoLFM.Core.Persistent.GetAutoInviteKeyword()
  AutoLFM.Core.Utils.PrintSuccess("Auto Invite enabled (keyword: " .. keyword .. ")")
  AutoLFM.Core.Maestro.Dispatch("AutoInvite.Changed")
end, { id = "C31" })

--- Command: Disable AutoInvite
--- Deactivates automatic group invitations
AutoLFM.Core.Maestro.RegisterCommand("AutoInvite.Disable", function()
  AutoLFM.Core.Persistent.SetAutoInviteEnabled(false)
  AutoLFM.Core.Utils.PrintWarning("Auto Invite disabled")
  AutoLFM.Core.Maestro.Dispatch("AutoInvite.Changed")
end, { id = "C32" })

--- Command: Set AutoInvite keyword
--- Changes the keyword that triggers automatic invitations
--- @param keyword string - New keyword to use
AutoLFM.Core.Maestro.RegisterCommand("AutoInvite.SetKeyword", function(keyword)
  if not keyword or keyword == "" then
    AutoLFM.Core.Utils.PrintError("Keyword cannot be empty")
    return
  end
  
  local trimmed = trim(keyword)
  AutoLFM.Core.Persistent.SetAutoInviteKeyword(trimmed)
  AutoLFM.Core.Utils.PrintSuccess("Keyword changed to: " .. trimmed)
  AutoLFM.Core.Maestro.Dispatch("AutoInvite.Changed")
end, { id = "C33" })

--- Command: Toggle confirmation messages
--- Enables/disables sending confirmation whispers to invited players
AutoLFM.Core.Maestro.RegisterCommand("AutoInvite.ToggleConfirm", function()
  local current = AutoLFM.Core.Persistent.GetAutoInviteConfirm()
  AutoLFM.Core.Persistent.SetAutoInviteConfirm(not current)
  local status = (not current) and "enabled" or "disabled"
  AutoLFM.Core.Utils.PrintInfo("Confirmation whisper " .. status)
  AutoLFM.Core.Maestro.Dispatch("AutoInvite.Changed")
end, { id = "C34" })

--=============================================================================
-- EVENTS
--=============================================================================

--- Event: AutoInvite.Changed
--- Dispatched when AutoInvite settings change (enabled, keyword, confirmation)
AutoLFM.Core.Maestro.RegisterEvent("AutoInvite.Changed", { id = "E06" })

--=============================================================================
-- EVENT HANDLERS
--=============================================================================

--- Handles group leader changes and disables AutoInvite if player loses leadership
--- @param data table - Leader change data with isLeader field
local function onLeaderChanged(data)
  local enabled = AutoLFM.Core.Persistent.GetAutoInviteEnabled()
  if not enabled then return end
  
  if not data.isLeader then
    AutoLFM.Core.Persistent.SetAutoInviteEnabled(false)
    AutoLFM.Core.Utils.PrintWarning("Auto Invite disabled: You are no longer the group leader")
    AutoLFM.Core.Maestro.Dispatch("AutoInvite.Changed")
  end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================

--- Initializes AutoInvite module
--- Registers listeners for whisper and leader change events
AutoLFM.Core.SafeRegisterInit("Logic.AutoInvite", function()
  AutoLFM.Core.Maestro.Listen(
    "AutoInvite.OnWhisper",
    "Chat.WhisperReceived",
    handleWhisper,
    { id = "L16" }
  )
  
  AutoLFM.Core.Maestro.Listen(
    "AutoInvite.OnLeaderChanged",
    "Group.LeaderChanged",
    onLeaderChanged,
    { id = "L17" }
  )
end, {
  id = "I18",
  dependencies = { "Core.Events" }
})
