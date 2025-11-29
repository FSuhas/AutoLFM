--=============================================================================
-- AutoLFM: Dungeons Logic
--   Dungeon color calculation, sorting and data management
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Logic = AutoLFM.Logic or {}
AutoLFM.Logic.Content = AutoLFM.Logic.Content or {}
AutoLFM.Logic.Content.Dungeons = {}

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
--- @return table - Array of {index, dungeon, color} sorted by priority then level
local function buildSortedDungeons()
  local playerLevel = UnitLevel("player") or 1
  local dungeons = AutoLFM.Core.Constants.DUNGEONS
  local sorted = {}

  local activeFilters = {}
  if AutoLFM.Logic.Content.Settings and AutoLFM.Logic.Content.Settings.GetDungeonFilters then
    activeFilters = AutoLFM.Logic.Content.Settings.GetDungeonFilters()
  end

  for i = 1, table.getn(dungeons) do
    local dungeon = dungeons[i]
    local color = getDungeonColor(dungeon, playerLevel)

    local colorId = color.name
    local isEnabled = activeFilters[colorId]
    if isEnabled == nil then isEnabled = true end

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

  return sorted
end

--- Counts dungeons that would be hidden by a specific color filter
--- @param colorId string - Color name to check (e.g., "GREEN", "YELLOW")
--- @return number - Count of dungeons with that color
local function countDungeonsByColor(colorId)
  local playerLevel = UnitLevel("player") or 1
  local dungeons = AutoLFM.Core.Constants.DUNGEONS
  local count = 0

  for i = 1, table.getn(dungeons) do
    local dungeon = dungeons[i]
    local color = getDungeonColor(dungeon, playerLevel)
    if color.name == colorId then
      count = count + 1
    end
  end

  return count
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Returns dungeons sorted by difficulty color and level (uses cache)
--- @return table - Array of {index, dungeon, color} sorted by priority and level
function AutoLFM.Logic.Content.Dungeons.GetSortedDungeons()
  return AutoLFM.Core.Cache.Get("Dungeons")
end

--- Clears the cached sorted dungeon list
--- Call this when player level changes or filters are updated
function AutoLFM.Logic.Content.Dungeons.ClearCache()
  AutoLFM.Core.Cache.Clear("Dungeons")
end

--- Refreshes the dungeon list and UI after a filter change
--- @param changedColorId string - Color filter that changed (for logging)
--- @param changedState boolean - New state of the filter (for logging)
function AutoLFM.Logic.Content.Dungeons.RefreshList(changedColorId, changedState)
  -- Log the filter change
  if changedColorId then
    if changedState then
      AutoLFM.Core.Utils.LogAction("Show dungeons " .. changedColorId)
    else
      local count = countDungeonsByColor(changedColorId)
      AutoLFM.Core.Utils.LogAction("Hide dungeons " .. changedColorId .. " (" .. count .. ")")
    end
  else
    AutoLFM.Core.Utils.LogAction("Refresh Dungeons list")
  end

  -- Clear cache and refresh UI
  AutoLFM.Core.Cache.Clear("Dungeons")

  if AutoLFM.UI.Content.Dungeons and AutoLFM.UI.Content.Dungeons.Refresh then
    AutoLFM.UI.Content.Dungeons.Refresh()
  end
end

--=============================================================================
-- INITIALIZATION
--=============================================================================
AutoLFM.Core.SafeRegisterInit("Logic.Content.Dungeons", function()
  AutoLFM.Core.Cache.Register("Dungeons", buildSortedDungeons)
end, { id = "I06" })
