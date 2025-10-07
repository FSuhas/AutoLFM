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
  end
  
  if PRIORITY_COLOR_SCHEME then
    for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
      if color and color.key then
        if charData.dungeonFilters[color.key] == nil then
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
  
  if not AutoLFM_SavedVariables[characterUniqueID].dungeonFilters then
    AutoLFM_SavedVariables[characterUniqueID].dungeonFilters = {}
  end
  
  if PRIORITY_COLOR_SCHEME then
    for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
      if color and color.key then
        local value = true
        if filterStates and filterStates[color.key] ~= nil then
          value = filterStates[color.key]
        end
        AutoLFM_SavedVariables[characterUniqueID].dungeonFilters[color.key] = (value == true)
      end
    end
  end
end

function LoadColorFilterSettings()
  if not AutoLFM_SavedVariables then return end
  if not characterUniqueID then return end
  if not AutoLFM_SavedVariables[characterUniqueID] then
    AutoLFM_SavedVariables[characterUniqueID] = {}
  end
  
  if not filterStates then
    filterStates = {}
  end
  
  if PRIORITY_COLOR_SCHEME then
    for _, color in ipairs(PRIORITY_COLOR_SCHEME) do
      if color and color.key then
        if AutoLFM_SavedVariables[characterUniqueID].dungeonFilters and 
           AutoLFM_SavedVariables[characterUniqueID].dungeonFilters[color.key] ~= nil then
          local value = AutoLFM_SavedVariables[characterUniqueID].dungeonFilters[color.key]
          filterStates[color.key] = (value == true or value == 1)
        else
          filterStates[color.key] = true
        end
      end
    end
  end
end