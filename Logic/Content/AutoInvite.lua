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

-- Cooldown tracking: stores last invite time per player to prevent spam
-- Key: player name (lowercase), Value: GetTime() timestamp of last invite
local lastInviteTime = {}

-- Cleanup timer frame (created on demand)
local cleanupFrame = nil
local lastCleanupTime = 0

--=============================================================================
-- INVITE MESSAGES
--=============================================================================
-- Mixed pool of themed (Light/Crusade) and generic messages for variety
local inviteMessages = {
  "%s, the Light demands your presence!",
  "%s, by the Light! Join us!",
  "%s, the Light calls you to adventure!",
  "%s, the crusade awaits!",
  "%s, blessed hammer in hand, join the fight!",
  "%s, you're in! Welcome aboard.",
  "%s, grab your gear and let's go!",
  "Welcome %s! Let's do this.",
  "%s, invitation sent! See you soon.",
  "Hey %s! You're invited, join up!",
  "%s, pack your bags, adventure awaits!",
  "Roger that %s, you're in!",
  "%s, we've got room for one more hero!"
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

--- Escapes Lua pattern special characters in a string
--- This prevents users from accidentally (or maliciously) injecting regex patterns
--- @param text string - Text to escape
--- @return string - Escaped text safe for pattern matching
local function escapePattern(text)
  if not text then return "" end
  -- Escape all Lua pattern magic characters: ^$()%.[]*+-?
  return string.gsub(text, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

--- Checks if a player is on cooldown (recently invited)
--- Prevents spam if someone sends multiple whispers quickly
--- @param sender string - Player name to check
--- @return boolean - True if player can be invited, false if on cooldown
local function canInvitePlayer(sender)
  local senderLower = string.lower(sender)
  local now = GetTime()
  local lastTime = lastInviteTime[senderLower]
  local cooldown = AutoLFM.Core.Constants.INVITE_COOLDOWN or 5

  if lastTime and (now - lastTime) < cooldown then
    AutoLFM.Core.Utils.LogInfo("Auto-invite cooldown: " .. sender .. " (wait " .. math.ceil(cooldown - (now - lastTime)) .. "s)")
    return false
  end

  return true
end

--- Records an invite timestamp for cooldown tracking
--- @param sender string - Player name that was invited
local function recordInvite(sender)
  local senderLower = string.lower(sender)
  lastInviteTime[senderLower] = GetTime()
end

--- Removes expired entries from cooldown table to prevent unbounded memory growth
--- Called periodically by cleanup timer
local function cleanupExpiredCooldowns()
  local now = GetTime()
  local cooldown = AutoLFM.Core.Constants.INVITE_COOLDOWN or 5
  local removedCount = 0

  for playerName, timestamp in pairs(lastInviteTime) do
    if (now - timestamp) > cooldown then
      lastInviteTime[playerName] = nil
      removedCount = removedCount + 1
    end
  end

  if removedCount > 0 then
    AutoLFM.Core.Utils.LogInfo("Auto-invite cleanup: removed " .. removedCount .. " expired entries")
  end
end

--- Starts the periodic cleanup timer (only when auto-invite is enabled)
local function startCleanupTimer()
  if not cleanupFrame then
    cleanupFrame = CreateFrame("Frame", "AutoLFM_InviteCooldownCleanup")
    cleanupFrame:Hide()  -- Hidden by default until Show() is called
    cleanupFrame:SetScript("OnUpdate", function()
      local now = GetTime()
      local interval = AutoLFM.Core.Constants.INVITE_COOLDOWN_CLEANUP_INTERVAL or 60

      if (now - lastCleanupTime) >= interval then
        lastCleanupTime = now
        cleanupExpiredCooldowns()
      end
    end)
  end

  lastCleanupTime = GetTime()
  cleanupFrame:Show()
end

--- Stops the periodic cleanup timer and clears cooldown data (when auto-invite is disabled)
local function stopCleanupTimer()
  if cleanupFrame then
    cleanupFrame:Hide()
  end
  -- Clear cooldown table to free memory immediately
  lastInviteTime = {}
end

--- Checks if a message matches any of the configured keywords
--- Keywords are sanitized to prevent pattern injection attacks
--- @param message string - The whisper message to check
--- @param keywords table - Array of keyword strings to match
--- @return boolean - True if any keyword matches
local function matchesKeyword(message, keywords)
  local lowerMsg = string.lower(trim(message))

  for i = 1, table.getn(keywords) do
    local keyword = keywords[i]
    if keyword and keyword ~= "" then
      -- Sanitize keyword to prevent pattern injection
      local sanitizedKey = escapePattern(string.lower(keyword))
      if string.find(lowerMsg, sanitizedKey) then
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

--- Sends rejection message when not leader or assist
--- @param sender string - Player name to send to
local function sendNotLeaderMessage(sender)
  SendChatMessage("Cannot invite: I'm not leader or assist.", "WHISPER", nil, sender)
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

  -- Check cooldown to prevent spam from same player
  if not canInvitePlayer(sender) then return end

  -- Get settings
  local sendConfirm = AutoLFM.Core.Storage.GetAutoInviteConfirm()
  local useRandomMsg = AutoLFM.Core.Storage.GetAutoInviteRandomMessages()
  local respondWhenNotLeader = AutoLFM.Core.Storage.GetAutoInviteRespondWhenNotLeader()

  -- Check if we can invite
  if AutoLFM.Logic.Group.CanInvite() then
    InviteByName(sender)
    recordInvite(sender)  -- Record invite for cooldown tracking

    if sendConfirm then
      sendInviteConfirmation(sender, useRandomMsg)
    end

    AutoLFM.Core.Utils.LogAction("Auto-invited " .. sender)
  else
    -- Not leader, optionally send message
    if respondWhenNotLeader and sendConfirm then
      sendNotLeaderMessage(sender)
      recordInvite(sender)  -- Also record to prevent spam of "not leader" messages
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
  startCleanupTimer()
  AutoLFM.Core.Utils.PrintSuccess("Auto Invite enabled")
  AutoLFM.Core.Maestro.Dispatch("AutoInvite.Changed")
end, { id = "C23" })

--- Command: Disable AutoInvite
--- Deactivates automatic group invitations
AutoLFM.Core.Maestro.RegisterCommand("AutoInvite.Disable", function()
  AutoLFM.Core.Storage.SetAutoInviteEnabled(false)
  stopCleanupTimer()
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
AutoLFM.Core.Maestro.RegisterEvent("AutoInvite.Changed", { id = "E09" })

--=============================================================================
-- EVENT HANDLERS
--=============================================================================

--- Handles group leader/assist changes
--- No longer disables AutoInvite; it simply won't work until player becomes leader or assist again
--- @param data table - Leader change data with isLeader field
local function onLeaderChanged(data)
  -- AutoInvite remains enabled even if player loses leadership/assist
  -- It will simply not invite anyone until player becomes leader or assist again
  if not data.isLeader then
    AutoLFM.Core.Utils.LogInfo("Auto Invite paused: You are no longer leader or assist (will resume if you become leader or assist again)")
  else
    AutoLFM.Core.Utils.LogInfo("Auto Invite active: You are now leader or assist")
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
    { id = "L07" }
  )

  AutoLFM.Core.Maestro.Listen(
    "AutoInvite.OnLeaderChanged",
    "Group.LeaderChanged",
    onLeaderChanged,
    { id = "L08" }
  )

  -- Start periodic cleanup only if auto-invite is already enabled
  if AutoLFM.Core.Storage.GetAutoInviteEnabled() then
    startCleanupTimer()
  end
end, {
  id = "I16",
  dependencies = { "Core.Events" }
})
