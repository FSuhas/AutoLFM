--------------------------------------------------
-- Dungeon Manager - Dungeon Logic
--------------------------------------------------

--------------------------------------------------
-- Calculate Dungeon Priority Based on Player Level
--------------------------------------------------
function CalculateDungeonPriority(playerLevel, dungeon)
  if not playerLevel or not dungeon then return 5 end
  if not dungeon.levelMin or not dungeon.levelMax then return 5 end
  
  local min = dungeon.levelMin
  local max = dungeon.levelMax
  
  if min < 1 or max < 1 or min > max then return 5 end
  
  local avg = math.floor((min + max) / 2)
  local diff = avg - playerLevel
  
  local greenThreshold
  if playerLevel <= 9 then
    greenThreshold = 4
  elseif playerLevel <= 19 then
    greenThreshold = 5
  elseif playerLevel <= 29 then
    greenThreshold = 6
  elseif playerLevel <= 39 then
    greenThreshold = 7
  else
    greenThreshold = 8
  end
  
  if diff >= 5 then
    return 4
  end
  if diff >= 3 and diff <= 4 then
    return 3
  end
  if diff >= -2 and diff <= 2 then
    return 2
  end
  if diff < -2 and diff >= -(greenThreshold) then
    return 1
  end
  return 5
end

--------------------------------------------------
-- Toggle Dungeon Selection
--------------------------------------------------
function ToggleDungeonSelection(dungeonTag, isSelected)
  if not dungeonTag then return end
  if not selectedDungeonTags then selectedDungeonTags = {} end
  
  if isSelected then
    -- Check if already selected
    local alreadySelected = false
    for _, tag in ipairs(selectedDungeonTags) do
      if tag == dungeonTag then
        alreadySelected = true
        break
      end
    end
    
    if not alreadySelected then
      -- Limit to MAX_DUNGEONS_SELECTION
      if table.getn(selectedDungeonTags) >= MAX_DUNGEONS_SELECTION then
        table.remove(selectedDungeonTags, 1)
      end
      table.insert(selectedDungeonTags, dungeonTag)
    end
  else
    -- Remove from selection
    for i, tag in ipairs(selectedDungeonTags) do
      if tag == dungeonTag then
        table.remove(selectedDungeonTags, i)
        break
      end
    end
  end
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Clear All Dungeon Selections
--------------------------------------------------
function ClearDungeonSelection()
  if not selectedDungeonTags then selectedDungeonTags = {} end
  selectedDungeonTags = {}
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Get Selected Dungeons List
--------------------------------------------------
function GetSelectedDungeonsList()
  return selectedDungeonTags or {}
end

--------------------------------------------------
-- Check if Dungeon is Selected
--------------------------------------------------
function IsDungeonSelected(dungeonTag)
  if not dungeonTag then return false end
  if not selectedDungeonTags then return false end
  
  for _, tag in ipairs(selectedDungeonTags) do
    if tag == dungeonTag then
      return true
    end
  end
  
  return false
end

--------------------------------------------------
-- Get Dungeon by Tag
--------------------------------------------------
function GetDungeonByTag(dungeonTag)
  if not dungeonTag then return nil end
  if not DUNGEON_DATABASE then return nil end
  
  for _, dungeon in ipairs(DUNGEON_DATABASE) do
    if dungeon and dungeon.tag == dungeonTag then
      return dungeon
    end
  end
  
  return nil
end

--------------------------------------------------
-- Get Sorted Dungeons by Priority
--------------------------------------------------
function GetSortedDungeonsByPriority(playerLevel)
  if not playerLevel or playerLevel < 1 then
    playerLevel = UnitLevel("player") or 1
  end
  
  local sortedDungeons = {}
  
  for index, dungeon in ipairs(DUNGEON_DATABASE or {}) do
    if dungeon then
      local priority = CalculateDungeonPriority(playerLevel, dungeon)
      table.insert(sortedDungeons, {
        dungeon = dungeon,
        priority = priority,
        originalIndex = index
      })
    end
  end
  
  table.sort(sortedDungeons, function(a, b)
    if a.priority == b.priority then
      return a.originalIndex < b.originalIndex
    else
      return a.priority < b.priority
    end
  end)
  
  return sortedDungeons
end