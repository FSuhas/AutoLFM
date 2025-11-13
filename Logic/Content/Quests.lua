--=============================================================================
-- AutoLFM: Quests Logic
--   Quest color calculation, sorting and data management
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Content = AutoLFM.Logic.Content or {}
AutoLFM.Logic.Content.Quests = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local cachedQuests = nil

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================

--- Calculates the difficulty color for a quest based on player level
--- @param questLevel number - Quest level from quest log
--- @param playerLevel number - Current player level
--- @return table - Color object with r, g, b, hex, name, priority fields
local function getQuestColor(questLevel, playerLevel)
  if not questLevel or not playerLevel then
  return AutoLFM.Core.Utils.GetColorForLevel(1, AutoLFM.Core.Utils.INVALID_LEVEL, AutoLFM.Core.Utils.INVALID_LEVEL)
  end

  return AutoLFM.Core.Utils.GetColorForLevel(playerLevel, questLevel, questLevel)
end

--- Retrieves the zone name for a quest by scanning upward for its header
--- @param questIndex number - Quest log index to find zone for
--- @return string|nil - Zone name (quest log header), or nil if not found
local function getQuestZone(questIndex)
  if not questIndex or questIndex <= 0 then return nil end

  local numEntries = GetNumQuestLogEntries()
  for i = questIndex - 1, 1, -1 do
  local headerTitle, headerLevel, _, isHeader = GetQuestLogTitle(i)
  if headerTitle and isHeader then
    return headerTitle
  end
  end

  return nil
end

--- Builds a sorted list of quests from the player's quest log
--- Extracts quest data, calculates colors, finds zones, sorts by level
--- @return table - Array of {index, name, level, tag, zone, color} sorted by level
local function buildSortedQuests()
  local playerLevel = UnitLevel("player") or 1
  local quests = {}
  local numEntries = GetNumQuestLogEntries()

  for i = 1, numEntries do
  local questLogTitleText, level, questTag, isHeader = GetQuestLogTitle(i)

  if questLogTitleText and not isHeader then
    local color = getQuestColor(level, playerLevel)
    local zone = getQuestZone(i)

    table.insert(quests, {
      index = i,
      name = questLogTitleText,
      level = level or 1,
      tag = questTag,
      zone = zone,
      color = color
    })
  end
  end

  table.sort(quests, function(a, b)
  return a.level < b.level
  end)

  return quests
end

--- Returns cached sorted quest list, building it if not cached
--- @return table - Array of {index, name, level, tag, zone, color} sorted by level
local function getSortedQuests()
  if not cachedQuests then
  cachedQuests = buildSortedQuests()
  end
  return cachedQuests
end

--=============================================================================
-- QUEST LINK CREATION
--=============================================================================

--- Creates a quest hyperlink for chat messages
--- @param questIndex number - Quest log index
--- @return string|nil - Formatted quest link, or nil if quest not found
function AutoLFM.Logic.Content.Quests.CreateQuestLink(questIndex)
  if not questIndex or questIndex < 1 then return nil end

  local title, level, _, _, _, _, _, questID = GetQuestLogTitle(questIndex)
  if not title then return nil end

  questID = questID or 0
  level = level or 0

  -- Remove quest tag prefix like [Elite], [Dungeon], etc.
  local cleanTitle = string.gsub(title, "^%[.-%]%s*", "")

  -- Calculate color based on quest level vs player level
  local playerLevel = UnitLevel("player") or 1
  local color = getQuestColor(level, playerLevel)

  -- Create quest link format: |cFFHEXCODE|Hquest:questID:level|h[title]|h|r
  return string.format("|cFF%s|Hquest:%d:%d|h[%s]|h|r", color.hex, questID, level, cleanTitle)
end

--=============================================================================
-- CUSTOM MESSAGE MANIPULATION
--=============================================================================

--- Checks if a quest link is present in either details or custom message
--- @param link string - The quest link to check
--- @return boolean - True if link is in any message
local function isQuestLinkInMessage(link)
  if not link then return false end

  -- Escape special pattern characters in the link
  local escapedLink = string.gsub(link, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")

  -- Check both States
  local detailsText = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""
  local customText = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage") or ""

  return string.find(detailsText, escapedLink) ~= nil or string.find(customText, escapedLink) ~= nil
end

--- Adds a quest link to the current editbox text (details or custom mode)
--- @param link string - The quest link to add
local function addQuestLinkToMessage(link)
  if not link then return end

  -- Determine current broadcast mode from UI
  local broadcastMode = "details"  -- Default
  if AutoLFM.UI and AutoLFM.UI.Content and AutoLFM.UI.Content.Messaging then
    if AutoLFM.UI.Content.Messaging.GetCurrentMode then
      broadcastMode = AutoLFM.UI.Content.Messaging.GetCurrentMode()
    end
  end

  -- Get the appropriate State based on current broadcast mode
  local currentText = ""
  if broadcastMode == "custom" then
    currentText = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage") or ""
    local newText = currentText == "" and link or (currentText .. " " .. link)
    AutoLFM.Core.Maestro.Dispatch("Selection.SetCustomMessage", newText)
  else
    -- Details mode (default)
    currentText = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""
    local newText = currentText == "" and link or (currentText .. " " .. link)
    AutoLFM.Core.Maestro.Dispatch("Selection.SetDetailsText", newText)
  end
end

--- Removes a quest link from the current editbox text (details or custom mode)
--- @param link string - The quest link to remove
local function removeQuestLinkFromMessage(link)
  if not link then return end

  -- Get current mode to determine which State to update
  local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode") or "none"

  -- Try both States to find and remove the link
  local detailsText = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""
  local customText = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage") or ""

  -- Escape special pattern characters in the link
  local escapedLink = string.gsub(link, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")

  -- Check which State contains the link and remove it
  if string.find(detailsText, escapedLink) then
    local newText = string.gsub(detailsText, escapedLink, "")
    -- Clean up extra spaces
    newText = string.gsub(newText, "%s+", " ")
    newText = string.gsub(newText, "^%s+", "")
    newText = string.gsub(newText, "%s+$", "")
    AutoLFM.Core.Maestro.Dispatch("Selection.SetDetailsText", newText)
  elseif string.find(customText, escapedLink) then
    local newText = string.gsub(customText, escapedLink, "")
    -- Clean up extra spaces
    newText = string.gsub(newText, "%s+", " ")
    newText = string.gsub(newText, "^%s+", "")
    newText = string.gsub(newText, "%s+$", "")
    AutoLFM.Core.Maestro.Dispatch("Selection.SetCustomMessage", newText)
  end
end

--=============================================================================
-- COMMANDS
--=============================================================================

--- Toggles quest selection and adds/removes its link from the current message
AutoLFM.Core.Maestro.RegisterCommand("Quests.Toggle", function(questIndex)
  if not questIndex or type(questIndex) ~= "number" then
    AutoLFM.Core.Utils.LogError("ToggleQuest: invalid index")
    return
  end

  -- Create quest link
  local link = AutoLFM.Logic.Content.Quests.CreateQuestLink(questIndex)
  if not link then
    AutoLFM.Core.Utils.LogError("ToggleQuest: failed to create link for quest " .. questIndex)
    return
  end

  -- Toggle link in current message (details or custom)
  if isQuestLinkInMessage(link) then
    removeQuestLinkFromMessage(link)
    AutoLFM.Core.Utils.LogAction("Removed quest link from message")
  else
    addQuestLinkToMessage(link)
    AutoLFM.Core.Utils.LogAction("Added quest link to message")
  end
end, { id = "C26" })

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Returns quests from quest log sorted by level (uses cache)
--- @return table - Array of {index, name, level, tag, zone, color} sorted by level
function AutoLFM.Logic.Content.Quests.GetSortedQuests()
  return getSortedQuests()
end

--- Clears the cached quest list
--- Call this when quest log is updated or player levels up
function AutoLFM.Logic.Content.Quests.ClearCache()
  cachedQuests = nil
end

--- Checks if a quest link is in any message (details or custom)
--- @param questIndex number - Quest log index
--- @return boolean - True if quest link is in any message
function AutoLFM.Logic.Content.Quests.IsQuestSelected(questIndex)
  local link = AutoLFM.Logic.Content.Quests.CreateQuestLink(questIndex)
  if not link then return false end
  return isQuestLinkInMessage(link)
end
