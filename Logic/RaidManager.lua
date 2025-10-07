--------------------------------------------------
-- Raid Manager - Raid Logic
--------------------------------------------------

--------------------------------------------------
-- Toggle Raid Selection (only one at a time)
--------------------------------------------------
function ToggleRaidSelection(raidTag, isSelected)
  if not raidTag then return end
  if not selectedRaidTags then selectedRaidTags = {} end
  
  if isSelected then
    -- Clear dungeon selection when selecting raid
    if ClearDungeonSelection then
      ClearDungeonSelection()
    end
    
    -- Clear roles and custom message
    if ClearAllRoles then
      ClearAllRoles()
    end
    if ClearRoleCheckboxesUI then
      ClearRoleCheckboxesUI()
    end
    if ResetCustomMessage then
      ResetCustomMessage()
    end
    
    -- Update UI dungeon checkboxes
    if AutoLFM_DungeonList and AutoLFM_DungeonList.UpdateCheckboxes then
      AutoLFM_DungeonList.UpdateCheckboxes()
    end
    
    -- Only one raid can be selected at a time
    selectedRaidTags = {raidTag}
  else
    selectedRaidTags = {}
  end
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end
--------------------------------------------------
-- Clear All Raid Selections
--------------------------------------------------
function ClearRaidSelection()
  if not selectedRaidTags then selectedRaidTags = {} end
  selectedRaidTags = {}
  raidGroupSize = 0
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Get Selected Raids List
--------------------------------------------------
function GetSelectedRaidsList()
  return selectedRaidTags or {}
end

--------------------------------------------------
-- Check if Raid is Selected
--------------------------------------------------
function IsRaidSelected(raidTag)
  if not raidTag then return false end
  if not selectedRaidTags then return false end
  
  for _, tag in ipairs(selectedRaidTags) do
    if tag == raidTag then
      return true
    end
  end
  
  return false
end

--------------------------------------------------
-- Get Raid by Tag
--------------------------------------------------
function GetRaidByTag(raidTag)
  if not raidTag then return nil end
  if not RAID_DATABASE then return nil end
  
  for _, raid in ipairs(RAID_DATABASE) do
    if raid and raid.tag == raidTag then
      return raid
    end
  end
  
  return nil
end

--------------------------------------------------
-- Set Raid Group Size
--------------------------------------------------
function SetRaidGroupSize(size)
  if not size or size < 1 then
    raidGroupSize = DEFAULT_RAID_SIZE
  else
    raidGroupSize = size
  end
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
end

--------------------------------------------------
-- Get Raid Group Size
--------------------------------------------------
function GetRaidGroupSize()
  return raidGroupSize or DEFAULT_RAID_SIZE
end

--------------------------------------------------
-- Check if Raid Has Fixed Size
--------------------------------------------------
function IsRaidFixedSize(raidTag)
  local raid = GetRaidByTag(raidTag)
  if not raid then return true end
  
  return raid.sizeMin == raid.sizeMax
end

--------------------------------------------------
-- Get Raid Size Range
--------------------------------------------------
function GetRaidSizeRange(raidTag)
  local raid = GetRaidByTag(raidTag)
  if not raid then
    return DEFAULT_RAID_SIZE, DEFAULT_RAID_SIZE
  end
  
  return raid.sizeMin or DEFAULT_RAID_SIZE, raid.sizeMax or DEFAULT_RAID_SIZE
end

--------------------------------------------------
-- Initialize Raid Size for Tag
--------------------------------------------------
function InitializeRaidSizeForTag(raidTag)
  local raid = GetRaidByTag(raidTag)
  if not raid then
    raidGroupSize = DEFAULT_RAID_SIZE
    return DEFAULT_RAID_SIZE
  end
  
  -- Always start with minimum size
  raidGroupSize = raid.sizeMin or DEFAULT_RAID_SIZE
  
  if UpdateDynamicMessage then
    UpdateDynamicMessage()
  end
  
  return raidGroupSize
end