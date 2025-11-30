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
  "%s, the Light demands your presence!",
  "%s, by the Light! Join us!",
  "%s, the Light calls you to adventure!",
  "%s, the crusade awaits!",
  "%s, blessed hammer in hand, join the fight!"
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

--- Trims whitespace from both ends of a string
--- @param text string - Text to trim
--- @return string - Trimmed text
local function trim(text)
  if not text then return "" end
  return string.gsub(text, "^%s*(.-)%s*$", "%1")
end

--- Checks if a message matches any of the configured keywords
--- @param message string - The whisper message to check
--- @param keywords table - Array of keyword strings to match
--- @return boolean - True if any keyword matches
local function matchesKeyword(message, keywords)
  local lowerMsg = string.lower(trim(message))
  
  for i = 1, table.getn(keywords) do
    local keyword = keywords[i]
    if keyword and keyword ~= "" then
      local lowerKey = string.lower(keyword)
      if string.find(lowerMsg, lowerKey, 1, true) then
        return true
      end
    end
  end
  
  return false
end

--- Sends confirmation whisper to invited player
--- @param sender string - Player name to send to
--- @param useRandomMsg boolean - Whether to use random message
local function sendInviteConfirmation(sender, useRandomMsg)
  if useRandomMsg then
    SendChatMessage(getRandomInviteMessage(sender), "WHISPER", nil, sender)
  else
    SendChatMessage("Invitation sent!", "WHISPER", nil, sender)
  end
end

--- Sends rejection message when not leader
--- @param sender string - Player name to send to
local function sendNotLeaderMessage(sender)
  SendChatMessage("Cannot invite: I'm not the group leader.", "WHISPER", nil, sender)
end

--=============================================================================
-- INVITE LOGIC
--=============================================================================

--- Handles incoming whisper messages and auto-invites if keyword matches
--- @param data table - Whisper data with message and sender fields
local function handleWhisper(data)
  if not data then return end

  local enabled = AutoLFM.Core.Storage.GetAutoInviteEnabled()
  if not enabled then return end

  local message = data.message
  local sender = data.sender
  if not message or not sender then return end
  
  -- Ignore self-whispers
  if sender == UnitName("player") then return end
  
  -- Check if message matches any keyword
  local keywords = AutoLFM.Core.Storage.GetAutoInviteKeywords() or {"+1"}
  if not matchesKeyword(message, keywords) then return end
  
  -- Get settings
  local sendConfirm = AutoLFM.Core.Storage.GetAutoInviteConfirm()
  local useRandomMsg = AutoLFM.Core.Storage.GetAutoInviteRandomMessages()
  local respondWhenNotLeader = AutoLFM.Core.Storage.GetAutoInviteRespondWhenNotLeader()
  
  -- Check if we can invite
  if AutoLFM.Logic.Group.CanInvite() then
    InviteByName(sender)
    
    if sendConfirm then
      sendInviteConfirmation(sender, useRandomMsg)
    end
    
    AutoLFM.Core.Utils.LogAction("Auto-invited " .. sender)
  else
    -- Not leader, optionally send message
    if respondWhenNotLeader and sendConfirm then
      sendNotLeaderMessage(sender)
    end
  end
end

--=============================================================================
-- COMMANDS
--=============================================================================

--- Command: Enable AutoInvite
--- Activates automatic group invitations based on whisper keywords
AutoLFM.Core.Maestro.RegisterCommand("AutoInvite.Enable", function()
  AutoLFM.Core.Storage.SetAutoInviteEnabled(true)
  AutoLFM.Core.Utils.PrintSuccess("Auto Invite enabled")
  AutoLFM.Core.Maestro.Dispatch("AutoInvite.Changed")
end, { id = "C23" })

--- Command: Disable AutoInvite
--- Deactivates automatic group invitations
AutoLFM.Core.Maestro.RegisterCommand("AutoInvite.Disable", function()
  AutoLFM.Core.Storage.SetAutoInviteEnabled(false)
  AutoLFM.Core.Utils.PrintWarning("Auto Invite disabled")
  AutoLFM.Core.Maestro.Dispatch("AutoInvite.Changed")
end, { id = "C22" })

--- Command: Toggle confirmation messages
--- Enables/disables sending confirmation whispers to invited players
AutoLFM.Core.Maestro.RegisterCommand("AutoInvite.ToggleConfirm", function()
  local current = AutoLFM.Core.Storage.GetAutoInviteConfirm()
  AutoLFM.Core.Storage.SetAutoInviteConfirm(not current)
  local status = (not current) and "enabled" or "disabled"
  AutoLFM.Core.Utils.PrintInfo("Confirmation whisper " .. status)
  AutoLFM.Core.Maestro.Dispatch("AutoInvite.Changed")
end, { id = "C24" })

--=============================================================================
-- EVENTS
--=============================================================================

--- Event: AutoInvite.Changed
--- Dispatched when AutoInvite settings change (enabled, keyword, confirmation)
AutoLFM.Core.Maestro.RegisterEvent("AutoInvite.Changed", { id = "E10" })

--=============================================================================
-- EVENT HANDLERS
--=============================================================================

--- Handles group leader changes
--- No longer disables AutoInvite; it simply won't work until player becomes leader again
--- @param data table - Leader change data with isLeader field
local function onLeaderChanged(data)
  -- AutoInvite remains enabled even if player loses leadership
  -- It will simply not invite anyone until player becomes leader again
  if not data.isLeader then
    AutoLFM.Core.Utils.LogInfo("Auto Invite paused: You are no longer the group leader (will resume if you become leader again)")
  else
    AutoLFM.Core.Utils.LogInfo("Auto Invite active: You are now the group leader")
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
    { id = "L12" }
  )
  
  AutoLFM.Core.Maestro.Listen(
    "AutoInvite.OnLeaderChanged",
    "Group.LeaderChanged",
    onLeaderChanged,
    { id = "L13" }
  )
end, {
  id = "I16",
  dependencies = { "Core.Events" }
})
