--------------------------------------------------
-- Global Variables Declaration
--------------------------------------------------
-- Frame references (used across files)
dungeonListContentFrame = nil
dungeonFilterFrame = nil
customMessageEditBox = nil
moreTabContentFrame = nil
dungeonMessageDisplayFrame = nil
raidMessageDisplayFrame = nil
dungeonMessageText = nil
raidMessageText = nil
broadcastIntervalSlider = nil
raidSizeSlider = nil
raidSizeValueEditBox = nil
raidSizeControlFrame = nil
broadcastIntervalFrame = nil
broadcastToggleButton = nil

-- Broadcast state
isBroadcastActive = false
broadcastStartTimestamp = 0
lastBroadcastTimestamp = 0
broadcastMessageCount = 0
groupSearchStartTimestamp = 0

-- Selection state
selectedDungeonTags = {}
selectedRaidTags = {}
selectedRolesList = {}
roleCheckboxes = {}
selectedChannelsList = {}

-- Message state
generatedLFMMessage = ""
customUserMessage = ""
raidGroupSize = 0

-- Configuration
TEXTURE_BASE_PATH = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\"
CHAT_MESSAGE_PREFIX = "|cffffffff[Auto|cff0070DDL|cffffffffF|cffff0000M|cffffffff]|r "
playerCharacterName = nil
playerRealmName = nil
characterUniqueID = nil

-- Global tables (initialized in their respective files)
AutoLFM_DungeonList = nil
AutoLFM_RaidList = nil
AutoLFM_API = nil
AutoLFM_MainFrame = nil
AutoLFM_MinimapButton = nil
AutoLFM_MainIconTexture = nil

--------------------------------------------------
-- Dungeons Data
--------------------------------------------------
DUNGEON_DATABASE = {
  { name = "Ragefire Chasm", tag = "RFC", levelMin = 13, levelMax = 19 },
  { name = "Wailing Caverns", tag = "WC", levelMin = 16, levelMax = 25 },
  { name = "The Deadmines", tag = "DM", levelMin = 16, levelMax = 24 },
  { name = "Shadowfang Keep", tag = "SFK", levelMin = 20, levelMax = 28 },
  { name = "Blackfathom Deeps", tag = "BFD", levelMin = 22, levelMax = 31 },
  { name = "The Stockade", tag = "Stockade", levelMin = 23, levelMax = 32 },
  { name = "Dragonnmaw Retreat", tag = "DR", levelMin = 26, levelMax = 35 },
  { name = "Gnomeregan", tag = "Gnomeregan", levelMin = 28, levelMax = 37 },
  { name = "Razorfen Kraul", tag = "RFK", levelMin = 29, levelMax = 36 },
  { name = "Scarlet Monastery Graveyard", tag = "SM Grav", levelMin = 30, levelMax = 37 },
  { name = "Scarlet Monastery Library", tag = "SM Lib", levelMin = 32, levelMax = 40 },
  { name = "Stormwrought Castle", tag = "SC", levelMin = 32, levelMax = 40 },
  { name = "The Crescent Grove", tag = "Crescent", levelMin = 33, levelMax = 39 },
  { name = "Scarlet Monastery Armory", tag = "SM Armo", levelMin = 34, levelMax = 42 },
  { name = "Razorfen Downs", tag = "RFD", levelMin = 35, levelMax = 44 },
  { name = "Stormwrought Descent", tag = "SD", levelMin = 35, levelMax = 44 },
  { name = "Scarlet Monastery Cathedral", tag = "SM Cath", levelMin = 35, levelMax = 45 },
  { name = "Uldaman", tag = "Ulda", levelMin = 41, levelMax = 50 },
  { name = "Zul'Farrak", tag = "ZF", levelMin = 42, levelMax = 51 },
  { name = "Gilneas City", tag = "Gilneas", levelMin = 43, levelMax = 52 },
  { name = "Maraudon Orange", tag = "Maraudon Orange", levelMin = 43, levelMax = 51 },
  { name = "Maraudon Purple", tag = "Maraudon Purple", levelMin = 45, levelMax = 52 },
  { name = "Maraudon Princess", tag = "Maraudon Princess", levelMin = 46, levelMax = 54 },
  { name = "The Sunken Temple", tag = "ST", levelMin = 49, levelMax = 58 },
  { name = "Blackrock Depths Arena", tag = "BRD Arena", levelMin = 50, levelMax = 60 },
  { name = "Halteforge Quarry", tag = "HQ", levelMin = 51, levelMax = 60 },
  { name = "Blackrock Depths Emperor", tag = "BRD Emperor", levelMin = 54, levelMax = 60 },
  { name = "Blackrock Depths", tag = "BRD", levelMin = 54, levelMax = 60 },
  { name = "Lower Blackrock Spire", tag = "LBRS", levelMin = 55, levelMax = 60 },
  { name = "Dire Maul East", tag = "DM East", levelMin = 55, levelMax = 60 },
  { name = "Dire Maul North", tag = "DM N", levelMin = 57, levelMax = 60 },
  { name = "Dire Maul Tribute", tag = "DM Tribute", levelMin = 57, levelMax = 60 },
  { name = "Dire Maul West", tag = "DM W", levelMin = 57, levelMax = 60 },
  { name = "Stratholme Live 5", tag = "Strat Live 5", levelMin = 58, levelMax = 60 },
  { name = "Scholomance 5", tag = "Scholo 5", levelMin = 58, levelMax = 60 },
  { name = "Stratholme UD 5", tag = "Strat UD 5", levelMin = 58, levelMax = 60 },
  { name = "Stormwind Vault", tag = "SWV", levelMin = 60, levelMax = 60 },
  { name = "Karazhan Crypt", tag = "Kara Crypt", levelMin = 60, levelMax = 60 },
  { name = "Caverns of Time. Black Morass", tag = "Black Morass", levelMin = 60, levelMax = 60 },
}

--------------------------------------------------
-- Raids Data
--------------------------------------------------
RAID_DATABASE = {
  { name = "Scholomance 10", tag = "Scholo 10", sizeMin = 10, sizeMax = 10 },
  { name = "Stratholme Live 10", tag = "Strat Live 10", sizeMin = 10, sizeMax = 10 },
  { name = "Stratholme UD 10", tag = "Strat UD 10", sizeMin = 10, sizeMax = 10 },
  { name = "Upper Blackrock Spire", tag = "UBRS", sizeMin = 10, sizeMax = 10 },
  { name = "Zul'Gurub", tag = "ZG", sizeMin = 12, sizeMax = 20 },
  { name = "Ruins of Ahn'Qiraj", tag = "AQ20", sizeMin = 12, sizeMax = 20 },
  { name = "Molten Core", tag = "MC", sizeMin = 20, sizeMax = 40 },
  { name = "Onyxia's Lair", tag = "Ony", sizeMin = 15, sizeMax = 40 },
  { name = "Lower Karazhan Halls", tag = "Kara10", sizeMin = 10, sizeMax = 10 },
  { name = "Blackwing Lair", tag = "BWL", sizeMin = 20, sizeMax = 40 },
  { name = "Emerald Sanctum", tag = "ES", sizeMin = 30, sizeMax = 40 },
  { name = "Temple of Ahn'Qiraj", tag = "AQ40", sizeMin = 20, sizeMax = 40 },
  { name = "Naxxramas", tag = "Naxx", sizeMin = 30, sizeMax = 40 },
}

--------------------------------------------------
-- Colors
--------------------------------------------------
PRIORITY_COLOR_SCHEME = {
  {priority = 1, key = "green", r = 0.25, g = 0.75, b = 0.25, hex = "#40BF40"},
  {priority = 2, key = "yellow", r = 1.0, g = 1.0, b = 0.0, hex = "#FEFE00"},
  {priority = 3, key = "orange", r = 1.0, g = 0.50, b = 0.25, hex = "#FF8040"},
  {priority = 4, key = "red", r = 1.0, g = 0.0, b = 0.0, hex = "#FF0000"},
  {priority = 5, key = "gray", r = 0.5, g = 0.5, b = 0.5, hex = "#808080"}
}

--------------------------------------------------
-- Saved Variables Initialization
--------------------------------------------------
if not AutoLFM_SavedVariables then
  AutoLFM_SavedVariables = {}
end

playerCharacterName = UnitName("player") or "Unknown"
playerRealmName = GetRealmName() or "Unknown"
characterUniqueID = playerCharacterName .. "-" .. playerRealmName

--------------------------------------------------
-- Initialize Character SavedVariables
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
  
  local char = AutoLFM_SavedVariables[characterUniqueID]
  
  if not char.selectedChannels then
    char.selectedChannels = {}
  end
  
  if not char.minimapBtnX then
    char.minimapBtnX = -10
  end
  
  if not char.minimapBtnY then
    char.minimapBtnY = -10
  end
  
  if not char.minimapBtnHidden then
    char.minimapBtnHidden = false
  end
  
  if not char.dungeonFilters then
    char.dungeonFilters = {}
    for _, color in ipairs(PRIORITY_COLOR_SCHEME or {}) do
      char.dungeonFilters[color.key] = true
    end
  end
  
  selectedChannelsList = char.selectedChannels
  
  return true
end

local initSuccess = InitializeCharacterSavedVariables()
if not initSuccess then
  if AutoLFM_PrintError then
    AutoLFM_PrintError("Failed to initialize SavedVariables")
  end
end