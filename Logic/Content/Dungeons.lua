--=============================================================================
-- AutoLFM: Dungeons Logic
--   Dungeon color calculation, sorting and data management
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Content = AutoLFM.Logic.Content or {}
AutoLFM.Logic.Content.Dungeons = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local cachedDungeons = nil

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================

--- Calculates the difficulty color for a dungeon based on player level
--- @param dungeon table - Dungeon data with levelMin and levelMax fields
--- @param playerLevel number - Current player level
--- @return table - Color object with r, g, b, hex, name, priority fields
local function getDungeonColor(dungeon, playerLevel)
  if not dungeon or not dungeon.levelMin or not playerLevel then
  return AutoLFM.Core.Utils.GetColorForLevel(1, AutoLFM.Core.Constants.INVALID_LEVEL, AutoLFM.Core.Constants.INVALID_LEVEL)
  end

  return AutoLFM.Core.Utils.GetColorForLevel(playerLevel, dungeon.levelMin, dungeon.levelMax)
end

--- Builds a sorted list of dungeons filtered by active color filters
--- Applies color-based filtering, sorts by priority and level, logs changes
--- @param changedColorId string - Optional color filter that changed (for logging)
--- @param changedState boolean - Optional new state of the filter (for logging)
--- @return table - Array of {index, dungeon, color} sorted by priority then level
local function buildSortedDungeons(changedColorId, changedState)
  local playerLevel = UnitLevel("player") or 1
  local dungeons = AutoLFM.Core.Constants.DUNGEONS
  local sorted = {}

  local activeFilters = {}
  if AutoLFM.Logic.Content.Settings and AutoLFM.Logic.Content.Settings.GetDungeonFilters then
  activeFilters = AutoLFM.Logic.Content.Settings.GetDungeonFilters()
  end

  local hiddenCount = 0
  for i = 1, table.getn(dungeons) do
  local dungeon = dungeons[i]
  local color = getDungeonColor(dungeon, playerLevel)

  local colorId = color.name
  local isEnabled = activeFilters[colorId]
  if isEnabled == nil then isEnabled = true end

  if changedColorId and colorId == changedColorId and not isEnabled then
    hiddenCount = hiddenCount + 1
  end

  if isEnabled then
    table.insert(sorted, {
      index = i,
      dungeon = dungeon,
      color = color
    })
  end
  end

  table.sort(sorted, function(a, b)
  if a.color.priority ~= b.color.priority then
    return a.color.priority < b.color.priority
  end
  return a.dungeon.levelMin < b.dungeon.levelMin
  end)

  if changedColorId and AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogAction then
  if changedState then
    AutoLFM.Core.Utils.LogAction("Show dungeons " .. changedColorId)
  else
    AutoLFM.Core.Utils.LogAction("Hide dungeons " .. changedColorId .. " (" .. hiddenCount .. ")")
  end
  end

  return sorted
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Returns dungeons sorted by difficulty color and level (uses cache)
--- @param changedColorId string - Optional color filter that changed (for logging)
--- @param changedState boolean - Optional new state of the filter (for logging)
--- @return table - Array of {index, dungeon, color} sorted by priority and level
function AutoLFM.Logic.Content.Dungeons.GetSortedDungeons(changedColorId, changedState)
  if not cachedDungeons then
  cachedDungeons = buildSortedDungeons(changedColorId, changedState)
  end
  return cachedDungeons
end

--- Clears the cached sorted dungeon list
--- Call this when player level changes or filters are updated
function AutoLFM.Logic.Content.Dungeons.ClearCache()
  cachedDungeons = nil
end

--- Refreshes the dungeon list and UI
--- @param changedColorId string - Optional color filter that changed (for logging)
--- @param changedState boolean - Optional new state of the filter (for logging)
function AutoLFM.Logic.Content.Dungeons.RefreshList(changedColorId, changedState)
  AutoLFM.Logic.Content.Dungeons.ClearCache()

  local sorted = buildSortedDungeons(changedColorId, changedState)
  cachedDungeons = sorted

  if AutoLFM.Core.Utils and AutoLFM.Core.Utils.LogAction then
  AutoLFM.Core.Utils.LogAction("Refresh Dungeons list")
  end

  -- Refresh UI directly (no Maestro needed for UI-only operations)
  if AutoLFM.UI.Content.Dungeons and AutoLFM.UI.Content.Dungeons.Refresh then
  AutoLFM.UI.Content.Dungeons.Refresh()
  end
end

