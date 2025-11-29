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
-- ROW_HEIGHT: Pixel height of each list row (dungeons, raids, quests)
-- Used for calculating scroll frame heights and positioning elements
AutoLFM.Core.Constants.ROW_HEIGHT = 20

-- MAX_ROWS_SAFETY: Safety limit for maximum displayable rows
-- Prevents excessive UI creation or performance issues
AutoLFM.Core.Constants.MAX_ROWS_SAFETY = 100

-- INVALID_LEVEL: Sentinel value for unset or invalid player levels
-- Used internally to detect uninitialized level states
AutoLFM.Core.Constants.INVALID_LEVEL = 999

-- MESSAGE_PREVIEW_TEXT_WIDTH: Max pixel width for broadcast message preview display
-- Controls text wrapping in message preview panel
AutoLFM.Core.Constants.MESSAGE_PREVIEW_TEXT_WIDTH = 290

--=============================================================================
-- GROUP CONSTANTS
--=============================================================================
-- MAX_GROUP_SIZE: Maximum WoW raid group size (Vanilla WoW limit)
-- Used for raid size calculations and validation
AutoLFM.Core.Constants.MAX_GROUP_SIZE = 40

-- MAX_PARTY_SIZE: Maximum WoW party group size (standard 5-player dungeon limit)
-- Used to distinguish between party and raid instances
AutoLFM.Core.Constants.MAX_PARTY_SIZE = 5

--=============================================================================
-- BROADCAST CONSTANTS
--=============================================================================
-- MIN_BROADCAST_INTERVAL: Minimum seconds between broadcast messages
-- Prevents spam and respects WoW chat rate limits (30 sec minimum)
AutoLFM.Core.Constants.MIN_BROADCAST_INTERVAL = 30

-- MAX_BROADCAST_INTERVAL: Maximum seconds between broadcast messages (2 minutes)
-- Upper slider limit for broadcast interval setting
AutoLFM.Core.Constants.MAX_BROADCAST_INTERVAL = 120

-- DEFAULT_BROADCAST_INTERVAL: Default interval when addon is first used
-- Balanced between visibility and avoiding chat spam (60 sec = 1 min)
AutoLFM.Core.Constants.DEFAULT_BROADCAST_INTERVAL = 60

--=============================================================================
-- SELECTION CONSTANTS
--=============================================================================
-- MAX_DUNGEONS: Maximum number of dungeons that can be selected simultaneously
-- Enforced using FIFO (oldest selection removed when limit reached)
-- Prevents spam messages with too many dungeon choices
AutoLFM.Core.Constants.MAX_DUNGEONS = 3

--=============================================================================
-- CHAT PREFIX
--=============================================================================
-- CHAT_PREFIX: Colored "[AutoLFM]" prefix added to all broadcast messages
-- Provides visual identification in chat and helps distinguish addon messages
AutoLFM.Core.Constants.CHAT_PREFIX = "|cff808080[|r|cffffffffAuto|r|cff0070ddL|r|cffffffffF|r|cffff0000M|r|cff808080]|r"

--=============================================================================
-- LEVEL COLOR THRESHOLDS
--=============================================================================

-- DIFFICULTY COLOR SYSTEM:
-- Colors represent how difficult a dungeon is for a player of a given level
-- RED:    Too hard (5+ levels above) - High wipe risk
-- ORANGE: Challenging (3-5 levels above) - Skilled group recommended
-- YELLOW: Recommended (0 to 2 levels below) - Good XP and challenge
-- GREEN:  Easy (below YELLOW threshold) - Low threat, mostly XP-less
-- GRAY:   Trivial (far below GREEN) - No XP, soloing possible

-- GREEN_DIFFICULTY_THRESHOLD_BY_LEVEL_BRACKET: Defines when content becomes GREEN (trivial)
-- The threshold increases with player level to keep difficulty meaningful at all levels
-- Index = player level bracket (1=1-9, 2=10-19, 3=20-29, 4=30-39, 5=40+)
-- Value = how many levels BELOW player level a dungeon must be to appear GREEN
-- Example: Level 25 player (bracket 3, threshold=6):
--          Dungeon is GREEN if max_level < (25-6) = 19
-- This allows higher level players to have more challenging "green" content
AutoLFM.Core.Constants.GREEN_DIFFICULTY_THRESHOLD_BY_LEVEL_BRACKET = {
  [1] = 4,  -- Level 1-9:   GREEN if dungeon_level < (player_level - 4)
  [2] = 5,  -- Level 10-19: GREEN if dungeon_level < (player_level - 5)
  [3] = 6,  -- Level 20-29: GREEN if dungeon_level < (player_level - 6)
  [4] = 7,  -- Level 30-39: GREEN if dungeon_level < (player_level - 7)
  [5] = 8   -- Level 40+:   GREEN if dungeon_level < (player_level - 8)
}

-- Legacy name for backward compatibility (deprecated, use GREEN_DIFFICULTY_THRESHOLD_BY_LEVEL_BRACKET)
AutoLFM.Core.Constants.GREEN_THRESHOLDS = AutoLFM.Core.Constants.GREEN_DIFFICULTY_THRESHOLD_BY_LEVEL_BRACKET

-- DIFFICULTY_RED_THRESHOLD: Dungeon appears RED if its min level is 5+ above player level
-- RED = Too hard, likely to wipe (5+ levels above player)
-- Fixed threshold (not level-dependent) because risk scales linearly at all levels
AutoLFM.Core.Constants.DIFFICULTY_RED_THRESHOLD = 5

-- DIFFICULTY_ORANGE_THRESHOLD: Dungeon appears ORANGE if its min level is 3-5 above player level
-- ORANGE = Challenging but doable, requires skilled/coordinated group (3-5 levels above)
-- Fixed threshold (not level-dependent) for consistency
AutoLFM.Core.Constants.DIFFICULTY_ORANGE_THRESHOLD = 3

-- DIFFICULTY_YELLOW_THRESHOLD: Dungeon appears YELLOW if its min level is within 2 levels below player level
-- YELLOW = Recommended, balanced difficulty with good XP reward (0 to 2 levels below)
-- BELOW this threshold (-2) becomes GREEN based on the bracket-specific thresholds
-- Fixed threshold to set the minimum floor for YELLOW difficulty
AutoLFM.Core.Constants.DIFFICULTY_YELLOW_THRESHOLD = -2

--=============================================================================
-- COLORS
--=============================================================================
-- COLORS: Color palette used throughout UI and logging
-- Fields:
--   name: Color identifier (e.g., "RED", "GREEN", "GOLD")
--   priority: Sort priority for difficulty colors (lower = more severe)
--   r, g, b: RGB values (0.0 to 1.0)
--   hex: Hex color code for WoW chat color codes
--   debugCategory: Debug log category for this color (used in logging system)
-- Difficulty colors (priorities 1-5): GREEN < YELLOW < ORANGE < RED < GRAY
-- Debug colors (priority 99): Used for different system components
AutoLFM.Core.Constants.COLORS = {
  {name = "GREEN", priority = 1, r = 0.25, g = 0.75, b = 0.25, hex = "40BF40", debugCategory = "STATE"},
  {name = "YELLOW", priority = 2, r = 1.0, g = 1.0, b = 0.0, hex = "FFFF00", debugCategory = "INFO"},
  {name = "ORANGE", priority = 3, r = 1.0, g = 0.5, b = 0.25, hex = "FF8040", debugCategory = "WARNING"},
  {name = "RED", priority = 4, r = 1.0, g = 0.0, b = 0.0, hex = "FF0000", debugCategory = "ERROR"},
  {name = "GRAY", priority = 5, r = 0.5, g = 0.5, b = 0.5, hex = "808080", debugCategory = "TIMESTAMP"},
  {name = "WHITE", priority = 99, r = 1.0, g = 1.0, b = 1.0, hex = "FFFFFF", debugCategory = "ACTION"},
  {name = "PURPLE", priority = 99, r = 0.67, g = 0.0, b = 1.0, hex = "AA00FF", debugCategory = "INIT"},
  {name = "BLUE", priority = 99, r = 0.0, g = 0.67, b = 1.0, hex = "00AAFF", debugCategory = "COMMAND"},
  {name = "CYAN", priority = 99, r = 0.0, g = 1.0, b = 1.0, hex = "00FFFF", debugCategory = "EVENT"},
  {name = "MAGENTA", priority = 99, r = 1.0, g = 0.0, b = 1.0, hex = "FF00FF", debugCategory = "LISTENER"},
  {name = "GREEN_BRIGHT", priority = 99, r = 0.0, g = 1.0, b = 0.0, hex = "00FF00", debugCategory = "REGISTRY"},
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
-- DEBUG_LINE_HEIGHT: Pixel height of each line in debug console
-- Controls vertical spacing of log entries in debug window
AutoLFM.Core.Constants.DEBUG_LINE_HEIGHT = 14

-- DEBUG_BUFFER_MAX_LINES: Maximum log lines kept in debug buffer
-- Older lines are discarded when limit exceeded (circular buffer)
-- Prevents unbounded memory growth during extended sessions
AutoLFM.Core.Constants.DEBUG_BUFFER_MAX_LINES = 500

--=============================================================================
-- PERFORMANCE CONSTANTS
--=============================================================================
-- BROADCASTER_TIMER_INTERVAL: Update frequency for broadcast countdown timer
-- How often (in seconds) the broadcaster checks if message should be sent
-- Smaller = more precise timing but more CPU; 1 sec = good balance
AutoLFM.Core.Constants.BROADCASTER_TIMER_INTERVAL = 1

-- SCROLL_PADDING: Extra pixel padding around scrollable content areas
-- Provides breathing room and prevents content from touching edges
AutoLFM.Core.Constants.SCROLL_PADDING = 10

--=============================================================================
-- UI CONSTANTS (Additional)
--=============================================================================
-- SOUND_DIRECTORY: File path to broadcast notification sound
-- Used when playing sound effect on message sending (feature-gated)
AutoLFM.Core.Constants.SOUND_DIRECTORY = "Interface\\AddOns\\AutoLFM\\UI\\Sounds\\"

--=============================================================================
-- LOOKUP TABLES (built on-demand by Core/Utils.lua lazy loading)
--=============================================================================
-- DUNGEONS_BY_NAME: O(1) name-to-dungeon lookup table
-- Built on first use by GetDungeonByName() for performance
-- Allows fast dungeon lookups without iterating DUNGEONS array
AutoLFM.Core.Constants.DUNGEONS_BY_NAME = {}

-- RAIDS_BY_NAME: O(1) name-to-raid lookup table
-- Built on first use by GetRaidByName() for performance
-- Allows fast raid lookups without iterating RAIDS array
AutoLFM.Core.Constants.RAIDS_BY_NAME = {}
