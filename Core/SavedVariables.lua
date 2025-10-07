--------------------------------------------------
-- SavedVariables - Data Persistence
--------------------------------------------------

--------------------------------------------------
-- Initialize SavedVariables Structure
--------------------------------------------------
if not AutoLFM_SavedVariables then
  AutoLFM_SavedVariables = {}
end

--------------------------------------------------
-- Initialize Character Info
--------------------------------------------------
function InitializeCharacterInfo()
  playerCharacterName = UnitName("player") or "Unknown"
  playerRealmName = GetRealmName() or "Unknown"
  characterUniqueID = playerCharacterName .. "-" .. playerRealmName
end

--------------------------------------------------
-- Initialize Character Data
--------------------------------------------------
function InitializeCharacterSavedVariables()
  if not AutoLFM_SavedVariables then
    AutoLFM_SavedVariables = {}
  end
  
  if not characterUniqueID or characterUniqueID == "" then
    if AutoLFM_PrintError then
      AutoLFM_PrintError("Cannot initialize SavedVariables: invalid character identifier")
    end
    return false
  end
  
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  
  local charData = AutoLFM_SavedVariables[characterUniqueID]
  
  -- Initialize with defaults if not set
  if not charData.selectedChannels then
    charData.selectedChannels = {}
  end
  
  if not charData.minimapBtnX then
    charData.minimapBtnX = DEFAULT_MINIMAP_X
  end
  
  if not charData.minimapBtnY then
    charData.minimapBtnY = DEFAULT_MINIMAP_Y
  end
  
  if not charData.minimapBtnHidden then
    charData.minimapBtnHidden = false
  end
  
  if not charData.dungeonFilters then
    charData.dungeonFilters = {}
    if PRIORITY_COLOR_SCHEME then
      for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
        if color and color.key then
          charData.dungeonFilters[color.key] = true
        end
      end
    end
  end
  
  return true
end

--------------------------------------------------
-- Channel Selection Persistence
--------------------------------------------------
function SaveChannelSelection()
  if not AutoLFM_SavedVariables then return end
  if not characterUniqueID then return end
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  
  AutoLFM_SavedVariables[characterUniqueID].selectedChannels = selectedChannelsList or {}
end

function LoadChannelSelection()
  if not AutoLFM_SavedVariables then return end
  if not characterUniqueID then return end
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  
  if AutoLFM_SavedVariables[characterUniqueID].selectedChannels then
    selectedChannelsList = AutoLFM_SavedVariables[characterUniqueID].selectedChannels
  else
    selectedChannelsList = {}
    AutoLFM_SavedVariables[characterUniqueID].selectedChannels = selectedChannelsList
  end
end

--------------------------------------------------
-- Minimap Button Persistence
--------------------------------------------------
function SaveMinimapPosition(x, y)
  if not AutoLFM_SavedVariables then return end
  if not characterUniqueID then return end
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  
  AutoLFM_SavedVariables[characterUniqueID].minimapBtnX = x
  AutoLFM_SavedVariables[characterUniqueID].minimapBtnY = y
end

function SaveMinimapVisibility(isHidden)
  if not AutoLFM_SavedVariables then return end
  if not characterUniqueID then return end
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  
  AutoLFM_SavedVariables[characterUniqueID].minimapBtnHidden = isHidden
end

function LoadMinimapSettings()
  if not AutoLFM_SavedVariables then return nil end
  if not characterUniqueID then return nil end
  if not AutoLFM_SavedVariables[characterUniqueID] then return nil end
  
  local charData = AutoLFM_SavedVariables[characterUniqueID]
  
  return {
    x = charData.minimapBtnX or DEFAULT_MINIMAP_X,
    y = charData.minimapBtnY or DEFAULT_MINIMAP_Y,
    hidden = charData.minimapBtnHidden or false
  }
end

--------------------------------------------------
-- Dungeon Filters Persistence
--------------------------------------------------
function SaveColorFilterSettings()
  if not AutoLFM_SavedVariables then return end
  if not characterUniqueID then return end
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  
  -- Save current filter states
  if filterStates then
    AutoLFM_SavedVariables[characterUniqueID].dungeonFilters = {}
    for key, value in pairs(filterStates) do
      AutoLFM_SavedVariables[characterUniqueID].dungeonFilters[key] = value
    end
  end
end

function LoadColorFilterSettings()
  if not AutoLFM_SavedVariables then return end
  if not characterUniqueID then return end
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  
  -- Load saved filter states
  if AutoLFM_SavedVariables[characterUniqueID].dungeonFilters then
    filterStates = {}
    for key, value in pairs(AutoLFM_SavedVariables[characterUniqueID].dungeonFilters) do
      filterStates[key] = value
    end
  else
    -- Initialize with defaults if no saved data
    filterStates = {}
    if PRIORITY_COLOR_SCHEME then
      for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
        if color and color.key then
          filterStates[color.key] = true
        end
      end
    end
  end
end