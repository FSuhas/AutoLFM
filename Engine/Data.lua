--------------------------------------------------
-- Global Variables Declaration
--------------------------------------------------
-- Frame
contentFrame = nil
djScrollFrame = nil
djframe = nil
dungeonFilterFrame = nil
editBox = nil
insideList = nil
insideMore = nil
msgFrameDj = nil
msgFrameRaids = nil
msgTextDj = nil
msgTextRaids = nil
raidContentFrame = nil
raidFrame = nil
raidScrollFrame = nil
slider = nil
sliderSize = nil
sliderSizeEditBox = nil
sliderSizeFrame = nil
sliderframe = nil
toggleButton = nil

-- Broadcast
isBroadcasting = false
broadcastStartTime = 0
lastBroadcastTime = 0
messagesSentCount = 0
searchStartTime = 0

-- Selection
selectedDungeons = {}
selectedRaids = {}
selectedRoles = {}
roleChecks = {}

-- Message
combinedMessage = ""
userInputMessage = ""
sliderValue = 0

-- Configuration
texturePath = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\"
addonPrefix = "|cffffffff[Auto|cff0070DDL|cffffffffF|cffff0000M|cffffffff]|r "

--------------------------------------------------
-- Dungeons Data
--------------------------------------------------
dungeons = {
  { name = "Ragefire Chasm", tag = "RFC", levelMin = 13, levelMax = 19, originalIndex = 1 },
  { name = "Wailing Caverns", tag = "WC", levelMin = 16, levelMax = 25, originalIndex = 2 },
  { name = "The Deadmines", tag = "DM", levelMin = 16, levelMax = 24, originalIndex = 3 },
  { name = "Shadowfang Keep", tag = "SFK", levelMin = 20, levelMax = 28, originalIndex = 4 },
  { name = "Blackfathom Deeps", tag = "BFD", levelMin = 22, levelMax = 31, originalIndex = 5 },
  { name = "The Stockade", tag = "Stockade", levelMin = 23, levelMax = 32, originalIndex = 6 },
  { name = "Dragonnmaw Retreat", tag = "DR", levelMin = 26, levelMax = 35, originalIndex = 7 },
  { name = "Gnomeregan", tag = "Gnomeregan", levelMin = 28, levelMax = 37, originalIndex = 8 },
  { name = "Razorfen Kraul", tag = "RFK", levelMin = 29, levelMax = 36, originalIndex = 9 },
  { name = "Scarlet Monastery Graveyard", tag = "SM Grav", levelMin = 30, levelMax = 37, originalIndex = 10 },
  { name = "Scarlet Monastery Library", tag = "SM Lib", levelMin = 32, levelMax = 40, originalIndex = 11 },
  { name = "Stormwrought Castle", tag = "SC", levelMin = 32, levelMax = 40, originalIndex = 12 },
  { name = "The Crescent Grove", tag = "Crescent", levelMin = 33, levelMax = 39, originalIndex = 13 },
  { name = "Scarlet Monastery Armory", tag = "SM Armo", levelMin = 34, levelMax = 42, originalIndex = 14 },
  { name = "Razorfen Downs", tag = "RFD", levelMin = 35, levelMax = 44, originalIndex = 15 },
  { name = "Stormwrought Descent", tag = "SD", levelMin = 35, levelMax = 44, originalIndex = 16 },
  { name = "Scarlet Monastery Cathedral", tag = "SM Cath", levelMin = 35, levelMax = 45, originalIndex = 17 },
  { name = "Uldaman", tag = "Ulda", levelMin = 41, levelMax = 50, originalIndex = 18 },
  { name = "Zul'Farrak", tag = "ZF", levelMin = 42, levelMax = 51, originalIndex = 19 },
  { name = "Gilneas City", tag = "Gilneas", levelMin = 43, levelMax = 52, originalIndex = 20 },
  { name = "Maraudon Orange", tag = "Maraudon Orange", levelMin = 43, levelMax = 51, originalIndex = 21 },
  { name = "Maraudon Purple", tag = "Maraudon Purple", levelMin = 45, levelMax = 52, originalIndex = 22 },
  { name = "Maraudon Princess", tag = "Maraudon Princess", levelMin = 46, levelMax = 54, originalIndex = 23 },
  { name = "The Sunken Temple", tag = "ST", levelMin = 49, levelMax = 58, originalIndex = 24 },
  { name = "Blackrock Depths Arena", tag = "BRD Arena", levelMin = 50, levelMax = 60, originalIndex = 25 },
  { name = "Halteforge Quarry", tag = "HQ", levelMin = 51, levelMax = 60, originalIndex = 26 },
  { name = "Blackrock Depths Emperor", tag = "BRD Emperor", levelMin = 54, levelMax = 60, originalIndex = 27 },
  { name = "Blackrock Depths", tag = "BRD", levelMin = 54, levelMax = 60, originalIndex = 28 },
  { name = "Lower Blackrock Spire", tag = "LBRS", levelMin = 55, levelMax = 60, originalIndex = 29 },
  { name = "Dire Maul East", tag = "DM East", levelMin = 55, levelMax = 60, originalIndex = 30 },
  { name = "Dire Maul North", tag = "DM N", levelMin = 57, levelMax = 60, originalIndex = 31 },
  { name = "Dire Maul Tribute", tag = "DM Tribute", levelMin = 57, levelMax = 60, originalIndex = 32 },
  { name = "Dire Maul West", tag = "DM W", levelMin = 57, levelMax = 60, originalIndex = 33 },
  { name = "Stratholme Live 5", tag = "Strat Live 5", levelMin = 58, levelMax = 60, originalIndex = 34 },
  { name = "Scholomance 5", tag = "Scholo 5", levelMin = 58, levelMax = 60, originalIndex = 35 },
  { name = "Stratholme UD 5", tag = "Strat UD 5", levelMin = 58, levelMax = 60, originalIndex = 36 },
  { name = "Stormwind Vault", tag = "SWV", levelMin = 60, levelMax = 60, originalIndex = 37 },
  { name = "Karazhan Crypt", tag = "Kara Crypt", levelMin = 60, levelMax = 60, originalIndex = 38 },
  { name = "Caverns of Time. Black Morass", tag = "Black Morass", levelMin = 60, levelMax = 60, originalIndex = 39 },
}
maxDungeons = 100

--------------------------------------------------
-- Raids Data
--------------------------------------------------
raids = {
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
maxRaids = 100

--------------------------------------------------
-- Priority Colors
--------------------------------------------------
priorityColors = {
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

charName = UnitName("player") or "Unknown"
realmName = GetRealmName() or "Unknown"
uniqueIdentifier = charName .. "-" .. realmName

--------------------------------------------------
-- Initialize Character SavedVariables
--------------------------------------------------
function InitializeCharacterSavedVariables()
  if not AutoLFM_SavedVariables then
    AutoLFM_SavedVariables = {}
  end
  
  if not uniqueIdentifier or uniqueIdentifier == "" then
    AutoLFM_PrintError("Cannot initialize SavedVariables: invalid character identifier")
    return false
  end
  
  if not AutoLFM_SavedVariables[uniqueIdentifier] then
    AutoLFM_SavedVariables[uniqueIdentifier] = {}
  end
  
  local char = AutoLFM_SavedVariables[uniqueIdentifier]
  
  -- Initialize all default values
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
    -- Initialize with all filters enabled by default
    for _, color in ipairs(priorityColors or {}) do
      char.dungeonFilters[color.key] = true
    end
  end
  
  -- Set global reference for easy access
  selectedChannels = char.selectedChannels
  
  return true
end

-- Initialize immediately
local initSuccess = InitializeCharacterSavedVariables()
if not initSuccess then
  AutoLFM_PrintError("Failed to initialize SavedVariables")
end