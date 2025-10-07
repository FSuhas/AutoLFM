--------------------------------------------------
-- Constants - Static Data
--------------------------------------------------

--------------------------------------------------
-- Paths & Prefixes
--------------------------------------------------
TEXTURE_BASE_PATH = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\"
SOUND_BASE_PATH = "Interface\\AddOns\\AutoLFM\\UI\\Sounds\\"
CHAT_MESSAGE_PREFIX = "|cffffffff[|r|cffFEFE00Auto|r|cff0070DDL|r|cffffffffF|r|cffff0000M|r|cffffffff]|r "

--------------------------------------------------
-- Sound Files
--------------------------------------------------
SOUND_BROADCAST_START = "LFG_RoleCheck.ogg"
SOUND_BROADCAST_STOP = "LFG_Denied.ogg"

--------------------------------------------------
-- Channels
--------------------------------------------------
AVAILABLE_CHANNELS = {"WORLD", "LookingForGroup", "Hardcore", "testketa"}

--------------------------------------------------
-- Roles
--------------------------------------------------
ROLE_TANK = "Tank"
ROLE_HEAL = "Heal"
ROLE_DPS = "DPS"
AVAILABLE_ROLES = {ROLE_TANK, ROLE_HEAL, ROLE_DPS}

--------------------------------------------------
-- Dungeons Database
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
-- Raids Database
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
-- Priority Color Scheme
--------------------------------------------------
PRIORITY_COLOR_SCHEME = {
  {priority = 1, key = "green", r = 0.25, g = 0.75, b = 0.25, hex = "#40BF40"},
  {priority = 2, key = "yellow", r = 1.0, g = 1.0, b = 0.0, hex = "#FEFE00"},
  {priority = 3, key = "orange", r = 1.0, g = 0.50, b = 0.25, hex = "#FF8040"},
  {priority = 4, key = "red", r = 1.0, g = 0.0, b = 0.0, hex = "#FF0000"},
  {priority = 5, key = "gray", r = 0.5, g = 0.5, b = 0.5, hex = "#808080"}
}

--------------------------------------------------
-- Animation
--------------------------------------------------
ANIMATION_SEQUENCE = {
  "eye01", "eye02", "eye03", "eye04", "eye05", "eye06", "eye05", "eye04", "eye03", "eye02",
  "eye01", "eye07", "eye08", "eye09", "eye10", "eye11", "eye10", "eye09", "eye08", "eye07",
  "eye01", "eye02", "eye03", "eye04", "eye05", "eye06", "eye05", "eye04", "eye03", "eye02",
  "eye01", "eye07", "eye08", "eye09", "eye10", "eye11", "eye10", "eye09", "eye08", "eye07",
  "eye01", "eye12", "eye13", "eye14", "eye15", "eye16", "eye15", "eye14", "eye13", "eye12"
}
ANIMATION_SPEED = 0.15

--------------------------------------------------
-- UI Limits & Defaults
--------------------------------------------------
MAX_DUNGEONS_SELECTION = 4
MAX_CUSTOM_MESSAGE_LENGTH = 150
DEFAULT_DUNGEON_SIZE = 5
DEFAULT_RAID_SIZE = 10
DEFAULT_BROADCAST_INTERVAL = 80
BROADCAST_INTERVAL_MIN = 40
BROADCAST_INTERVAL_MAX = 120
BROADCAST_INTERVAL_STEP = 10
DEFAULT_MINIMAP_X = -10
DEFAULT_MINIMAP_Y = -10

--------------------------------------------------
-- Performance
--------------------------------------------------
UPDATE_THROTTLE_BROADCAST = 1.0
UPDATE_THROTTLE_SLIDER = 0.1

--------------------------------------------------
-- API
--------------------------------------------------
API_VERSION = "1.0.0"