--------------------------------------------------
-- Core Variables
--------------------------------------------------

texturePath = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\"

selectedDungeons = {}
selectedRaids = {}
selectedRoles = {}

donjonCheckButtons = {}
raidCheckButtons = {}

donjonClickableFrames = {}
raidClickableFrames = {}

userInputMessage = ""
combinedMessage = ""

--------------------------------------------------
-- Dungeons Data
--------------------------------------------------

donjons = {
  { nom = "Ragefire Chasm", abrev = "RFC", size = 5, lvl = "13-19", lvl_min = 13, lvl_max = 19, originalIndex = 1 },
  { nom = "Wailing Caverns", abrev = "WC", size = 5, lvl = "16-25", lvl_min = 16, lvl_max = 25, originalIndex = 2 },
  { nom = "The Deadmines", abrev = "DM", size = 5, lvl = "16-24", lvl_min = 16, lvl_max = 24, originalIndex = 3 },
  { nom = "Shadowfang Keep", abrev = "SFK", size = 5, lvl = "20-28", lvl_min = 20, lvl_max = 28, originalIndex = 4 },
  { nom = "Blackfathom Deeps", abrev = "BFD", size = 5, lvl = "22-31", lvl_min = 22, lvl_max = 31, originalIndex = 5 },
  { nom = "The Stockade", abrev = "Stockade", size = 5, lvl = "23-32", lvl_min = 23, lvl_max = 32, originalIndex = 6 },
  { nom = "Dragonnmaw Retreat", abrev = "DR", size = 5, lvl = "26-35", lvl_min = 26, lvl_max = 35, originalIndex = 7 },
  { nom = "Gnomeregan", abrev = "Gnomeregan", size = 5, lvl = "28-37", lvl_min = 28, lvl_max = 37, originalIndex = 8 },
  { nom = "Razorfen Kraul", abrev = "RFK", size = 5, lvl = "29-36", lvl_min = 29, lvl_max = 36, originalIndex = 9 },
  { nom = "Scarlet Monastery Graveyard", abrev = "SM Grav", size = 5, lvl = "30-37", lvl_min = 30, lvl_max = 37, originalIndex = 10 },
  { nom = "Scarlet Monastery Library", abrev = "SM Lib", size = 5, lvl = "32-40", lvl_min = 32, lvl_max = 40, originalIndex = 11 },
  { nom = "Stormwrought Castle", abrev = "SC", size = 5, lvl = "32-40", lvl_min = 32, lvl_max = 40, originalIndex = 12 },
  { nom = "The Crescent Grove", abrev = "Crescent", size = 5, lvl = "33-39", lvl_min = 33, lvl_max = 39, originalIndex = 13 },
  { nom = "Scarlet Monastery Armory", abrev = "SM Armo", size = 5, lvl = "34-42", lvl_min = 34, lvl_max = 42, originalIndex = 14 },
  { nom = "Razorfen Downs", abrev = "RFD", size = 5, lvl = "35-44", lvl_min = 35, lvl_max = 45, originalIndex = 15 },
  { nom = "Stormwrought Descent", abrev = "SD", size = 5, lvl = "35-44", lvl_min = 35, lvl_max = 44, originalIndex = 16 },
  { nom = "Scarlet Monastery Cathedral", abrev = "SM Cath", size = 5, lvl = "35-45", lvl_min = 35, lvl_max = 45, originalIndex = 17 },
  { nom = "Uldaman", abrev = "Ulda", size = 5, lvl = "41-50", lvl_min = 41, lvl_max = 50, originalIndex = 18 },
  { nom = "Zul'Farrak", abrev = "ZF", size = 5, lvl = "42-51", lvl_min = 42, lvl_max = 51, originalIndex = 19 },
  { nom = "Gilneas City", abrev = "Gilneas", size = 5, lvl = "43-52", lvl_min = 43, lvl_max = 52, originalIndex = 20 },
  { nom = "Maraudon Orange", abrev = "Maraudon Orange", size = 5, lvl = "43-51", lvl_min = 43, lvl_max = 51, originalIndex = 21 },
  { nom = "Maraudon Purple", abrev = "Maraudon Purple", size = 5, lvl = "45-52", lvl_min = 45, lvl_max = 52, originalIndex = 22 },
  { nom = "Maraudon Princess", abrev = "Maraudon Princess", size = 5, lvl = "46-54", lvl_min = 46, lvl_max = 54, originalIndex = 23 },
  { nom = "The Sunken Temple", abrev = "ST", size = 5, lvl = "49-58", lvl_min = 49, lvl_max = 58, originalIndex = 24 },
  { nom = "Blackrock Depths Arena", abrev = "BRD Arena", size = 5, lvl = "50-60", lvl_min = 50, lvl_max = 60, originalIndex = 25 },
  { nom = "Halteforge Quarry", abrev = "HQ", size = 5, lvl = "51-60", lvl_min = 51, lvl_max = 60, originalIndex = 26 },
  { nom = "Blackrock Depths Emperor", abrev = "BRD Emperor", size = 5, lvl = "54-60", lvl_min = 54, lvl_max = 60, originalIndex = 27 },
  { nom = "Blackrock Depths", abrev = "BRD", size = 5, lvl = "54-60", lvl_min = 54, lvl_max = 60, originalIndex = 28 },
  { nom = "Lower Blackrock Spire", abrev = "LBRS", size = 5, lvl = "55-60", lvl_min = 55, lvl_max = 60, originalIndex = 29 },
  { nom = "Dire Maul East", abrev = "DM East", size = 5, lvl = "55-60", lvl_min = 55, lvl_max = 60, originalIndex = 30 },
  { nom = "Dire Maul North", abrev = "DM N", size = 5, lvl = "57-60", lvl_min = 57, lvl_max = 60, originalIndex = 31 },
  { nom = "Dire Maul Tribute", abrev = "DM Tribute", size = 5, lvl = "57-60", lvl_min = 57, lvl_max = 60, originalIndex = 32 },
  { nom = "Dire Maul West", abrev = "DM W", size = 5, lvl = "57-60", lvl_min = 57, lvl_max = 60, originalIndex = 33 },
  { nom = "Stratholme Live 5", abrev = "Strat Live 5", size = 5, lvl = "58-60", lvl_min = 58, lvl_max = 60, originalIndex = 34 },
  { nom = "Scholomance 5", abrev = "Scholo 5", size = 5, lvl = "58-60", lvl_min = 58, lvl_max = 60, originalIndex = 35 },
  { nom = "Stratholme UD 5", abrev = "Strat UD 5", size = 5, lvl = "58-60", lvl_min = 58, lvl_max = 60, originalIndex = 36 },
  { nom = "Stormwind Vault", abrev = "SWV", size = 5, lvl = "60", lvl_min = 60, lvl_max = 60, originalIndex = 37 },
  { nom = "Karazhan Crypt", abrev = "Kara Crypt", size = 5, lvl = "60", lvl_min = 60, lvl_max = 60, originalIndex = 38 },
  { nom = "Caverns of Time. Black Morass", abrev = "Black Morass", size = 5, lvl = "60", lvl_min = 60, lvl_max = 60, originalIndex = 39 },
}

maxDonjons = 100

--------------------------------------------------
-- Raids Data
--------------------------------------------------

raids = {
  { nom = "Scholomance 10", abrev = "Scholo 10", size_min = 10, size_max = 10},
  { nom = "Stratholme Live 10", abrev = "Strat Live 10", size_min = 10, size_max = 10},
  { nom = "Stratholme UD 10", abrev = "Strat UD 10", size_min = 10, size_max = 10},
  { nom = "Upper Blackrock Spire", abrev = "UBRS", size_min = 10, size_max = 10 },
  { nom = "Zul'Gurub", abrev = "ZG", size_min = 12, size_max = 20},
  { nom = "Ruins of Ahn'Qiraj", abrev = "AQ20", size_min = 12, size_max = 20},
  { nom = "Molten Core", abrev = "MC", size_min = 20, size_max = 40},
  { nom = "Onyxia's Lair", abrev = "Ony", size_min = 15, size_max = 40},
  { nom = "Lower Karazhan Halls", abrev = "Kara10", size_min = 10, size_max = 10},
  { nom = "Blackwing Lair", abrev = "BWL", size_min = 20, size_max = 40},
  { nom = "Emerald Sanctum", abrev = "ES", size_min = 30, size_max = 40},
  { nom = "Temple of Ahn'Qiraj", abrev = "AQ40", size_min = 20, size_max = 40},
  { nom = "Naxxramas", abrev = "Naxx", size_min = 30, size_max = 40},
}

maxRaids = 100

--------------------------------------------------
-- Saved Variables Initialization
--------------------------------------------------

if not AutoLFM_SavedVariables then
  AutoLFM_SavedVariables = {}
end

charName = UnitName("player") or "Unknown"
realmName = GetRealmName() or "Unknown"
uniqueIdentifier = charName .. "-" .. realmName

if not AutoLFM_SavedVariables[uniqueIdentifier] then
  AutoLFM_SavedVariables[uniqueIdentifier] = {}
end

if not AutoLFM_SavedVariables[uniqueIdentifier].selectedChannels then
  AutoLFM_SavedVariables[uniqueIdentifier].selectedChannels = {}
end

if not AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnX then
  AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnX = -10
end

if not AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnY then
  AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnY = -10
end

if not AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden then
  AutoLFM_SavedVariables[uniqueIdentifier].minimapBtnHidden = false
end

selectedChannels = AutoLFM_SavedVariables[uniqueIdentifier].selectedChannels