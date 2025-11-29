--=============================================================================
-- AutoLFM: Constants
--   Shared constants, data tables, and configuration values
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Core = AutoLFM.Core or {}
AutoLFM.Core.Constants = {}

--=============================================================================
-- UI CONSTANTS
--=============================================================================
AutoLFM.Core.Constants.ROW_HEIGHT = 20
AutoLFM.Core.Constants.MAX_ROWS_SAFETY = 100
AutoLFM.Core.Constants.INVALID_LEVEL = 999
AutoLFM.Core.Constants.MESSAGE_PREVIEW_TEXT_WIDTH = 290

--=============================================================================
-- GROUP CONSTANTS
--=============================================================================
AutoLFM.Core.Constants.MAX_GROUP_SIZE = 40
AutoLFM.Core.Constants.MAX_PARTY_SIZE = 5

--=============================================================================
-- BROADCAST CONSTANTS
--=============================================================================
AutoLFM.Core.Constants.MIN_BROADCAST_INTERVAL = 30
AutoLFM.Core.Constants.MAX_BROADCAST_INTERVAL = 120  -- 2 minutes (slider max)
AutoLFM.Core.Constants.DEFAULT_BROADCAST_INTERVAL = 60

--=============================================================================
-- SELECTION CONSTANTS
--=============================================================================
AutoLFM.Core.Constants.MAX_DUNGEONS = 3

--=============================================================================
-- CHAT PREFIX
--=============================================================================
AutoLFM.Core.Constants.CHAT_PREFIX = "|cff808080[|r|cffffffffAuto|r|cff0070ddL|r|cffffffffF|r|cffff0000M|r|cff808080]|r"

--=============================================================================
-- LEVEL COLOR THRESHOLDS
--=============================================================================
-- GREEN_THRESHOLDS: Maps player level bracket to level-above threshold for GREEN difficulty
-- Used by GetColorForLevel() to determine when dungeon appears "trivial"
AutoLFM.Core.Constants.GREEN_THRESHOLDS = {
  [1] = 4,  -- Level 1-9:   Dungeon > 4 levels below = GREEN (easy)
  [2] = 5,  -- Level 10-19: Dungeon > 5 levels below = GREEN (easy)
  [3] = 6,  -- Level 20-29: Dungeon > 6 levels below = GREEN (easy)
  [4] = 7,  -- Level 30-39: Dungeon > 7 levels below = GREEN (easy)
  [5] = 8   -- Level 40+:   Dungeon > 8 levels below = GREEN (easy)
}

AutoLFM.Core.Constants.DIFFICULTY_RED_THRESHOLD = 5
AutoLFM.Core.Constants.DIFFICULTY_ORANGE_THRESHOLD = 3 
AutoLFM.Core.Constants.DIFFICULTY_YELLOW_THRESHOLD = -2 
-- If below -2, becomes GREEN (easy)

--=============================================================================
-- COLORS
--=============================================================================
AutoLFM.Core.Constants.COLORS = {
  {name = "GREEN", priority = 1, r = 0.25, g = 0.75, b = 0.25, hex = "40BF40", debugCategory = "STATE"},
  {name = "GREEN_BRIGHT", priority = 1, r = 0.0, g = 1.0, b = 0.0, hex = "00FF00", debugCategory = "REGISTRY"},
  {name = "YELLOW", priority = 2, r = 1.0, g = 1.0, b = 0.0, hex = "FFFF00", debugCategory = "INFO"},
  {name = "ORANGE", priority = 3, r = 1.0, g = 0.5, b = 0.25, hex = "FF8040", debugCategory = "WARNING"},
  {name = "RED", priority = 4, r = 1.0, g = 0.0, b = 0.0, hex = "FF0000", debugCategory = "ERROR"},
  {name = "GRAY", priority = 5, r = 0.5, g = 0.5, b = 0.5, hex = "808080", debugCategory = "TIMESTAMP"},
  {name = "WHITE", priority = 99, r = 1.0, g = 1.0, b = 1.0, hex = "FFFFFF", debugCategory = "ACTION"},
  {name = "PURPLE", priority = 99, r = 0.67, g = 0.0, b = 1.0, hex = "AA00FF", debugCategory = "INIT"},
  {name = "BLUE", priority = 99, r = 0.0, g = 0.67, b = 1.0, hex = "00AAFF", debugCategory = "COMMAND"},
  {name = "CYAN", priority = 99, r = 0.0, g = 1.0, b = 1.0, hex = "00FFFF", debugCategory = "EVENT"},
  {name = "MAGENTA", priority = 99, r = 1.0, g = 0.0, b = 1.0, hex = "FF00FF", debugCategory = "LISTENER"},
  {name = "GOLD", priority = 99, r = 1.0, g = 0.82, b = 0.0, hex = "FFD100"}
}

--=============================================================================
-- DUNGEONS DATABASE
--=============================================================================
AutoLFM.Core.Constants.DUNGEONS = {
  {name = "Ragefire Chasm", tag = "RFC", levelMin = 13, levelMax = 19},
  {name = "Wailing Caverns", tag = "WC", levelMin = 16, levelMax = 25},
  {name = "The Deadmines", tag = "DM", levelMin = 16, levelMax = 24},
  {name = "Shadowfang Keep", tag = "SFK", levelMin = 20, levelMax = 28},
  {name = "Blackfathom Deeps", tag = "BFD", levelMin = 22, levelMax = 31},
  {name = "The Stockade", tag = "Stockade", levelMin = 23, levelMax = 32},
  {name = "Dragonmaw Retreat", tag = "DR", levelMin = 26, levelMax = 35},
  {name = "Gnomeregan", tag = "Gnomeregan", levelMin = 28, levelMax = 37},
  {name = "Razorfen Kraul", tag = "RFK", levelMin = 29, levelMax = 36},
  {name = "Scarlet Monastery Graveyard", tag = "SM Grav", levelMin = 30, levelMax = 37},
  {name = "Scarlet Monastery Library", tag = "SM Lib", levelMin = 32, levelMax = 40},
  {name = "Stormwrought Castle", tag = "SC", levelMin = 32, levelMax = 40},
  {name = "The Crescent Grove", tag = "Crescent", levelMin = 33, levelMax = 39},
  {name = "Scarlet Monastery Armory", tag = "SM Armo", levelMin = 34, levelMax = 42},
  {name = "Razorfen Downs", tag = "RFD", levelMin = 35, levelMax = 44},
  {name = "Stormwrought Descent", tag = "SD", levelMin = 35, levelMax = 44},
  {name = "Scarlet Monastery Cathedral", tag = "SM Cath", levelMin = 35, levelMax = 45},
  {name = "Uldaman", tag = "Ulda", levelMin = 41, levelMax = 50},
  {name = "Zul'Farrak", tag = "ZF", levelMin = 42, levelMax = 51},
  {name = "Gilneas City", tag = "Gilneas", levelMin = 43, levelMax = 52},
  {name = "Maraudon Orange", tag = "Maraudon Orange", levelMin = 43, levelMax = 51},
  {name = "Maraudon Purple", tag = "Maraudon Purple", levelMin = 45, levelMax = 52},
  {name = "Maraudon Princess", tag = "Maraudon Princess", levelMin = 46, levelMax = 54},
  {name = "The Sunken Temple", tag = "ST", levelMin = 49, levelMax = 58},
  {name = "Blackrock Depths Arena", tag = "BRD Arena", levelMin = 50, levelMax = 60},
  {name = "Halteforge Quarry", tag = "HQ", levelMin = 51, levelMax = 60},
  {name = "Blackrock Depths Emperor", tag = "BRD Emperor", levelMin = 54, levelMax = 60},
  {name = "Blackrock Depths", tag = "BRD", levelMin = 54, levelMax = 60},
  {name = "Lower Blackrock Spire", tag = "LBRS", levelMin = 55, levelMax = 60},
  {name = "Dire Maul East", tag = "DM East", levelMin = 55, levelMax = 60},
  {name = "Dire Maul North", tag = "DM N", levelMin = 57, levelMax = 60},
  {name = "Dire Maul Tribute", tag = "DM Tribute", levelMin = 57, levelMax = 60},
  {name = "Dire Maul West", tag = "DM W", levelMin = 57, levelMax = 60},
  {name = "Stratholme Live 5", tag = "Strat Live 5", levelMin = 58, levelMax = 60},
  {name = "Scholomance 5", tag = "Scholo 5", levelMin = 58, levelMax = 60},
  {name = "Stratholme UD 5", tag = "Strat UD 5", levelMin = 58, levelMax = 60},
  {name = "Stormwind Vault", tag = "SWV", levelMin = 60, levelMax = 60},
  {name = "Karazhan Crypt", tag = "Kara Crypt", levelMin = 60, levelMax = 60},
  {name = "Caverns of Time. Black Morass", tag = "Black Morass", levelMin = 60, levelMax = 60}
}

--=============================================================================
-- RAIDS DATABASE
--=============================================================================
AutoLFM.Core.Constants.RAIDS = {
  {name = "Scholomance 10", tag = "Scholo 10", raidSizeMin = 10, raidSizeMax = 10},
  {name = "Stratholme Live 10", tag = "Strat Live 10", raidSizeMin = 10, raidSizeMax = 10},
  {name = "Stratholme UD 10", tag = "Strat UD 10", raidSizeMin = 10, raidSizeMax = 10},
  {name = "Upper Blackrock Spire", tag = "UBRS", raidSizeMin = 10, raidSizeMax = 10},
  {name = "Zul'Gurub", tag = "ZG", raidSizeMin = 12, raidSizeMax = 20},
  {name = "Ruins of Ahn'Qiraj", tag = "AQ20", raidSizeMin = 12, raidSizeMax = 20},
  {name = "Molten Core", tag = "MC", raidSizeMin = 20, raidSizeMax = 40},
  {name = "Onyxia's Lair", tag = "Ony", raidSizeMin = 15, raidSizeMax = 40},
  {name = "Lower Karazhan Halls", tag = "Kara10", raidSizeMin = 10, raidSizeMax = 10},
  {name = "Blackwing Lair", tag = "BWL", raidSizeMin = 20, raidSizeMax = 40},
  {name = "Emerald Sanctum", tag = "ES", raidSizeMin = 30, raidSizeMax = 40},
  {name = "Temple of Ahn'Qiraj", tag = "AQ40", raidSizeMin = 20, raidSizeMax = 40},
  {name = "Naxxramas", tag = "Naxx", raidSizeMin = 30, raidSizeMax = 40}
}

--=============================================================================
-- DEBUG CONSTANTS
--=============================================================================
AutoLFM.Core.Constants.DEBUG_LINE_HEIGHT = 14
AutoLFM.Core.Constants.DEBUG_BUFFER_MAX_LINES = 500

--=============================================================================
-- PERFORMANCE CONSTANTS
--=============================================================================
AutoLFM.Core.Constants.BROADCASTER_TIMER_INTERVAL = 1
AutoLFM.Core.Constants.SCROLL_PADDING = 10

--=============================================================================
-- UI CONSTANTS (Additional)
--=============================================================================
AutoLFM.Core.Constants.SOUND_DIRECTORY = "Interface\\AddOns\\AutoLFM\\UI\\Sounds\\"

--=============================================================================
-- LOOKUP TABLES (built on-demand by Core/Utils.lua lazy loading)
--=============================================================================
AutoLFM.Core.Constants.DUNGEONS_BY_NAME = {}
AutoLFM.Core.Constants.RAIDS_BY_NAME = {}
