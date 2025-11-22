--=============================================================================
-- AutoLFM: Message Builder
--   Constructs broadcast message from selection state
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Message = {}

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================

--- Checks if group is full and returns missing count
--- @param targetSize number - Target group size
--- @return number, boolean - Missing count and whether group is full
local function calculateMissing(targetSize)
  -- Use Maestro state directly to avoid dependency issues
  local currentSize = AutoLFM.Core.Maestro.GetState("Group.Size") or 1
  local missing = targetSize - currentSize
  return missing, missing <= 0
end

--- Gets formatted roles text (e.g., "Tank & Heal", "All")
--- @param roles table - Array of role strings ("TANK", "HEAL", "DPS")
--- @return string - Role text without "Need" prefix
local function getRolesText(roles)
  if not roles or table.getn(roles) == 0 then
    return ""
  end

  -- If all 3 roles selected, return "All"
  if table.getn(roles) == 3 then
    return "All"
  end

  -- Build ordered list of role names (always Tank -> Heal -> DPS)
  local roleOrder = {"TANK", "HEAL", "DPS"}
  local roleNames = {TANK = "Tank", HEAL = "Heal", DPS = "DPS"}
  local parts = {}

  -- Check roles in order
  for i = 1, table.getn(roleOrder) do
    local roleKey = roleOrder[i]
    -- Check if this role is selected
    for j = 1, table.getn(roles) do
      if roles[j] == roleKey then
        table.insert(parts, roleNames[roleKey])
        break
      end
    end
  end

  if table.getn(parts) == 0 then
    return ""
  end

  return table.concat(parts, " & ")
end

--- Formats roles text for broadcast message (e.g., "Need Tank & Heal", "Need All")
--- @param roles table - Array of role strings ("TANK", "HEAL", "DPS")
--- @return string - Role text with "Need" prefix
local function formatRolesForMessage(roles)
  local rolesText = getRolesText(roles)
  if rolesText == "" then
    return ""
  end
  return "Need " .. rolesText
end

--- Builds dungeon message
--- @return string - Formatted dungeon message
local function buildDungeonMessage()
  local dungeonNames = AutoLFM.Core.Maestro.GetState("Selection.DungeonNames")
  AutoLFM.Core.Utils.LogInfo("buildDungeonMessage: dungeonNames count = " .. (dungeonNames and table.getn(dungeonNames) or 0))
  
  if not dungeonNames or table.getn(dungeonNames) == 0 then
    return ""
  end

  -- Trigger lazy loading of lookup tables
  AutoLFM.Core.Utils.EnsureLookupTables()

  local targetSize = 5  -- Dungeons are always 5-man
  local missing, isFull = calculateMissing(targetSize)
  
  AutoLFM.Core.Utils.LogInfo("buildDungeonMessage: missing=" .. missing .. ", isFull=" .. tostring(isFull))
  
  -- If group is full, don't show LFM
  if isFull then
    return ""
  end

  -- Get roles
  local roles = AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}
  local rolesText = formatRolesForMessage(roles)

  -- Build dungeon tags list by finding dungeons by name (O(1) lookup)
  local dungeonTags = {}
  for i = 1, table.getn(dungeonNames) do
    local dungeonName = dungeonNames[i]
    local dungeonInfo = AutoLFM.Core.Constants.DUNGEONS_BY_NAME[dungeonName]
    if dungeonInfo then
      table.insert(dungeonTags, dungeonInfo.data.tag)
    else
      AutoLFM.Core.Utils.LogWarning("buildDungeonMessage: dungeon not found in lookup: " .. dungeonName)
    end
  end

  AutoLFM.Core.Utils.LogInfo("buildDungeonMessage: dungeonTags count = " .. table.getn(dungeonTags))
  
  if table.getn(dungeonTags) == 0 then
    return ""
  end

  -- Format message: "LF3M for RFC or SFK Need Tank & Heal" or "LF3M for RFC"
  local dungeonList = table.concat(dungeonTags, " or ")

  local message
  if rolesText ~= "" then
    message = string.format("LF%dM for %s %s", missing, dungeonList, rolesText)
  else
    message = string.format("LF%dM for %s", missing, dungeonList)
  end

  -- Append details text if present
  local detailsText = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""
  if detailsText ~= "" then
    message = message .. " " .. detailsText
  end

  return message
end

--- Builds raid message
--- @return string - Formatted raid message
local function buildRaidMessage()
  local raidName = AutoLFM.Core.Maestro.GetState("Selection.RaidName")
  if not raidName then
    return ""
  end

  -- Trigger lazy loading of lookup tables
  AutoLFM.Core.Utils.EnsureLookupTables()

  -- Find the raid by name (O(1) lookup)
  local raidInfo = AutoLFM.Core.Constants.RAIDS_BY_NAME[raidName]
  if not raidInfo then
    return ""
  end

  local raid = raidInfo.data

  -- Get target size and calculate missing
  local targetSize = AutoLFM.Core.Maestro.GetState("Selection.RaidSize") or raid.size or 40
  local missing, isFull = calculateMissing(targetSize)
  
  -- If raid is full, don't show LFM
  if isFull then
    return ""
  end
  
  local currentSize = AutoLFM.Core.Maestro.GetState("Group.Size") or 1

  -- Get roles
  local roles = AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}
  local rolesText = formatRolesForMessage(roles)

  -- Format message: "MC LF5M Need Tank & Heal 35/40" or "MC LF5M 35/40"
  local message
  if rolesText ~= "" then
    message = string.format("%s LF%dM %s %d/%d", raid.tag, missing, rolesText, currentSize, targetSize)
  else
    message = string.format("%s LF%dM %d/%d", raid.tag, missing, currentSize, targetSize)
  end

  -- Append details text if present
  local detailsText = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""
  if detailsText ~= "" then
    message = message .. " " .. detailsText
  end

  return message
end

--- Builds custom message with variable substitution
--- @return string - Formatted custom message
local function buildCustomMessage()
  local customMessage = AutoLFM.Core.Maestro.GetState("Selection.CustomMessage") or ""
  if customMessage == "" then
    return ""
  end

  local targetSize = AutoLFM.Core.Maestro.GetState("Selection.CustomGroupSize") or 5
  local missing, isFull = calculateMissing(targetSize)
  local currentSize = AutoLFM.Core.Maestro.GetState("Group.Size") or 1

  -- Debug log
  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogInfo then
    AutoLFM.Core.Utils.LogInfo("buildCustomMessage: currentSize=" .. currentSize .. ", targetSize=" .. targetSize .. ", missing=" .. missing)
  end

  -- If group is full, don't show LFM
  if isFull then
    return ""
  end

  -- Get roles
  local roles = AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}
  local rolesText = getRolesText(roles)

  -- Replace variables in message
  local message = customMessage
  message = string.gsub(message, "{MIS}", tostring(missing))
  message = string.gsub(message, "{CUR}", tostring(currentSize))
  message = string.gsub(message, "{TAR}", tostring(targetSize))
  message = string.gsub(message, "{ROL}", rolesText)

  return message
end

--- Builds the complete broadcast message based on current selection
--- @return string - The message to broadcast
local function buildMessage()
  local selectionMode = AutoLFM.Core.Maestro.GetState("Selection.Mode")

  if selectionMode == "custom" then
    return buildCustomMessage()
  elseif selectionMode == "dungeons" then
    return buildDungeonMessage()
  elseif selectionMode == "raid" then
    return buildRaidMessage()
  end

  -- If mode is "none", check for details text or roles
  local detailsText = AutoLFM.Core.Maestro.GetState("Selection.DetailsText") or ""
  local roles = AutoLFM.Core.Maestro.GetState("Selection.Roles") or {}
  local rolesText = formatRolesForMessage(roles)

  -- Combine roles and details text
  local parts = {}
  if rolesText ~= "" then
    table.insert(parts, rolesText)
  end
  if detailsText ~= "" then
    table.insert(parts, detailsText)
  end

  if table.getn(parts) > 0 then
    return table.concat(parts, " ")
  end

  return ""
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Gets the current broadcast message
--- @return string - The message to broadcast
function AutoLFM.Logic.Message.GetMessage()
  return AutoLFM.Core.Maestro.GetState("Message.ToBroadcast") or ""
end

--- Manually rebuilds the message (usually triggered by Selection.Changed)
function AutoLFM.Logic.Message.RebuildMessage()
  local message = buildMessage()
  AutoLFM.Core.Maestro.SetState("Message.ToBroadcast", message)
  
  if message and message ~= "" then
    AutoLFM.Core.Utils.LogInfo("Message rebuilt: " .. message)
  else
    AutoLFM.Core.Utils.LogInfo("Message cleared (no selection)")
  end
end

--- Replaces variables in custom message (for preview/presets)
function AutoLFM.Logic.Message.ReplaceVariables(message, currentSize, targetSize, roles)
  if not message or message == "" then return "" end

  local missing = targetSize - currentSize
  local rolesText = getRolesText(roles or {})
  
  local result = message
  result = string.gsub(result, "{MIS}", tostring(missing))
  result = string.gsub(result, "{CUR}", tostring(currentSize))
  result = string.gsub(result, "{TAR}", tostring(targetSize))
  result = string.gsub(result, "{ROL}", rolesText)
  
  return result
end

--=============================================================================
-- STATE DECLARATIONS
--=============================================================================
AutoLFM.Core.SafeRegisterState("Message.ToBroadcast", "", { id = "S16" })

--=============================================================================
-- INITIALIZATION
--=============================================================================

AutoLFM.Core.SafeRegisterInit("Logic.Message", function()
  -- Register event listeners (wait for Selection.Changed and Group.SizeChanged to be registered)

  --- Rebuilds message when selection changes
  AutoLFM.Core.Maestro.Listen(
    "Logic.Message.OnSelectionChanged",
    "Selection.Changed",
    function()
      AutoLFM.Logic.Message.RebuildMessage()
    end,
    { id = "L03" }
  )

  --- Rebuilds message when group size changes (for LF3M -> LF2M updates)
  AutoLFM.Core.Maestro.Listen(
    "Logic.Message.OnGroupSizeChanged",
    "Group.SizeChanged",
    function(payload)
      local mode = AutoLFM.Core.Maestro.GetState("Selection.Mode")

      -- Rebuild for dungeons, raid, AND custom (custom can have {MIS}/{CUR} variables)
      if mode == "dungeons" or mode == "raid" or mode == "custom" then
        AutoLFM.Logic.Message.RebuildMessage()

        -- Log the automatic update
        if payload and payload.size then
          AutoLFM.Core.Utils.LogAction("Message auto-updated (group size: " .. payload.size .. ")")
        end
      end
    end,
    { id = "L01" }
  )

  AutoLFM.Logic.Message.RebuildMessage()
end, {
  id = "I13",
  dependencies = { "Logic.Selection", "Core.Events" }  -- Wait for Selection (I04) and Events (I01)
})
