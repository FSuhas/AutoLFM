--=============================================================================
-- AutoLFM: Constants
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Core then AutoLFM.Core = {} end
if not AutoLFM.Core.Constants then AutoLFM.Core.Constants = {} end

-----------------------------------------------------------------------------
-- General Constants
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.GROUP_SIZE_DUNGEON = 5
AutoLFM.Core.Constants.GROUP_SIZE_RAID = 10
AutoLFM.Core.Constants.MAX_DUNGEONS = 4
AutoLFM.Core.Constants.MAX_MESSAGE_LENGTH = 150
AutoLFM.Core.Constants.UPDATE_THROTTLE = 0.1

-----------------------------------------------------------------------------
-- Interval Settings
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.INTERVAL_MIN = 30
AutoLFM.Core.Constants.INTERVAL_MAX = 120
AutoLFM.Core.Constants.INTERVAL_STEP = 10
AutoLFM.Core.Constants.INTERVAL_DEFAULT = 60

-----------------------------------------------------------------------------
-- UI Dimensions
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.ROW_HEIGHT = 20
AutoLFM.Core.Constants.CHECKBOX_SIZE = 20
AutoLFM.Core.Constants.ICON_SIZE = 16
AutoLFM.Core.Constants.EDITBOX_HEIGHT = 28
AutoLFM.Core.Constants.EDITBOX_WIDTH = 285
AutoLFM.Core.Constants.BUTTON_HEIGHT = 20
AutoLFM.Core.Constants.BUTTON_WIDTH_SMALL = 60
AutoLFM.Core.Constants.BUTTON_WIDTH_MEDIUM = 80
AutoLFM.Core.Constants.BUTTON_WIDTH_LARGE = 110
AutoLFM.Core.Constants.SPACING_SMALL = 5
AutoLFM.Core.Constants.SPACING_MEDIUM = 10
AutoLFM.Core.Constants.SPACING_LARGE = 20

-----------------------------------------------------------------------------
-- Content Types
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.TYPE_DUNGEON = "dungeon"
AutoLFM.Core.Constants.TYPE_RAID = "raid"

-----------------------------------------------------------------------------
-- Paths
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.TEXTURE_PATH = "Interface\\AddOns\\AutoLFM\\UI\\Textures\\"
AutoLFM.Core.Constants.SOUND_PATH = "Interface\\AddOns\\AutoLFM\\UI\\Sounds\\"

-----------------------------------------------------------------------------
-- Chat
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.CHAT_PREFIX = "|cff808080[|r|cffffffffAuto|r|cff0070ddL|r|cffffffffF|r|cffff0000M|r|cff808080]|r "

-----------------------------------------------------------------------------
-- Textures
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.TEXTURES = {
  TOOLTIP_BACKGROUND = "tooltipBackground",
  TOOLTIP_BORDER = "tooltipBorder",
  SLIDER_BUTTON = "sliderButtonHorizontal",
  SLIDER_BACKGROUND = "sliderBackground",
  SLIDER_BORDER = "sliderBorder",
  WHITE = "white",
  BUTTON_ROTATION_LEFT = "Icons\\buttonRotationLeft",
  BUTTON_HIGHLIGHT = "Icons\\buttonHighlight"
}

-----------------------------------------------------------------------------
-- Sounds
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.SOUNDS = {
  START = "LFG_RoleCheck.ogg",
  STOP = "LFG_Denied.ogg"
}

-----------------------------------------------------------------------------
-- Color Presets (RGB)
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.COLOR_PRESETS = {
  yellow = {r = 1, g = 1, b = 0},
  gold = {r = 1, g = 0.82, b = 0},
  white = {r = 1, g = 1, b = 1},
  green = {r = 0.25, g = 0.75, b = 0.25},
  red = {r = 1, g = 0, b = 0},
  orange = {r = 1, g = 0.5, b = 0.25},
  gray = {r = 0.5, g = 0.5, b = 0.5},
  blue = {r = 0.3, g = 0.6, b = 1},
  disabled = {r = 0.5, g = 0.5, b = 0.5}
}

-----------------------------------------------------------------------------
-- Chat Colors (Hex)
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.CHAT_COLORS = {
  yellow = "ffff00",
  gold = "ffd100",
  white = "ffffff",
  green = "40bf40",
  red = "ff0000",
  orange = "ff8040",
  gray = "808080",
  blue = "0070dd"
}

-----------------------------------------------------------------------------
-- Priority Colors
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.PRIORITY_COLORS = {
  {priority = 5, key = "gray", r = 0.5, g = 0.5, b = 0.5},
  {priority = 1, key = "green", r = 0.25, g = 0.75, b = 0.25},
  {priority = 2, key = "yellow", r = 1.0, g = 1.0, b = 0.0},
  {priority = 3, key = "orange", r = 1.0, g = 0.50, b = 0.25},
  {priority = 4, key = "red", r = 1.0, g = 0.0, b = 0.0}
}

-----------------------------------------------------------------------------
-- Default Settings
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.DEFAULTS = {
  MINIMAP_ANGLE = 235,
  MINIMAP_HIDDEN = false,
  DARK_MODE = nil,
  BROADCAST_INTERVAL = 60,
  MISC_MODULES = {
    fpsDisplay = false,
    restedXP = false,
    autoInvite = false,
    guildSpam = false,
    autoMarker = false
  }
}

-----------------------------------------------------------------------------
-- Link Patterns
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.LINK_PATTERNS = {
  QUEST = "|c.-|Hquest:.-|h%[.-%]|h|r",
  ITEM = "|c.-|Hitem:.-|h%[.-%]|h|r"
}

-----------------------------------------------------------------------------
-- Link Formats
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.LINK_FORMATS = {
  QUEST = "|c%s|Hquest:%d:%d|h[%s]|h|r"
}

-----------------------------------------------------------------------------
-- Dungeons Database
-----------------------------------------------------------------------------
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

-----------------------------------------------------------------------------
-- Raids Database
-----------------------------------------------------------------------------
AutoLFM.Core.Constants.RAIDS = {
  {name = "Scholomance 10", tag = "Scholo 10", sizeMin = 10, sizeMax = 10},
  {name = "Stratholme Live 10", tag = "Strat Live 10", sizeMin = 10, sizeMax = 10},
  {name = "Stratholme UD 10", tag = "Strat UD 10", sizeMin = 10, sizeMax = 10},
  {name = "Upper Blackrock Spire", tag = "UBRS", sizeMin = 10, sizeMax = 10},
  {name = "Zul'Gurub", tag = "ZG", sizeMin = 12, sizeMax = 20},
  {name = "Ruins of Ahn'Qiraj", tag = "AQ20", sizeMin = 12, sizeMax = 20},
  {name = "Molten Core", tag = "MC", sizeMin = 20, sizeMax = 40},
  {name = "Onyxia's Lair", tag = "Ony", sizeMin = 15, sizeMax = 40},
  {name = "Lower Karazhan Halls", tag = "Kara10", sizeMin = 10, sizeMax = 10},
  {name = "Blackwing Lair", tag = "BWL", sizeMin = 20, sizeMax = 40},
  {name = "Emerald Sanctum", tag = "ES", sizeMin = 30, sizeMax = 40},
  {name = "Temple of Ahn'Qiraj", tag = "AQ40", sizeMin = 20, sizeMax = 40},
  {name = "Naxxramas", tag = "Naxx", sizeMin = 30, sizeMax = 40}
}
