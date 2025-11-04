--=============================================================================
-- AutoLFM: Content Management
--=============================================================================

if not AutoLFM then AutoLFM = {} end
if not AutoLFM.Logic then AutoLFM.Logic = {} end
if not AutoLFM.Logic.Content then AutoLFM.Logic.Content = {} end

-----------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------
AutoLFM.Logic.Content.MAX_DUNGEONS = 4
AutoLFM.Logic.Content.TYPE_DUNGEON = "dungeon"
AutoLFM.Logic.Content.TYPE_RAID = "raid"

AutoLFM.Logic.Content.COLORS = {
  {priority = 5, key = "gray", r = 0.5, g = 0.5, b = 0.5},
  {priority = 1, key = "green", r = 0.25, g = 0.75, b = 0.25},
  {priority = 2, key = "yellow", r = 1.0, g = 1.0, b = 0.0},
  {priority = 3, key = "orange", r = 1.0, g = 0.50, b = 0.25},
  {priority = 4, key = "red", r = 1.0, g = 0.0, b = 0.0}
}

AutoLFM.Logic.Content.LINK_PATTERNS = {
  QUEST = "|c.-|Hquest:.-|h%[.-%]|h|r",
  ITEM = "|c.-|Hitem:.-|h%[.-%]|h|r"
}

AutoLFM.Logic.Content.LINK_FORMATS = {
  QUEST = "|c%s|Hquest:%d:%d|h[%s]|h|r"
}

-----------------------------------------------------------------------------
-- Databases
-----------------------------------------------------------------------------
AutoLFM.Logic.Content.DUNGEONS = {
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

AutoLFM.Logic.Content.RAIDS = {
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

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local selectedDungeons = {}
local selectedRaids = {}
local raidSize = 0

-----------------------------------------------------------------------------
-- Private Helpers
-----------------------------------------------------------------------------
local function CalculateLevelPriority(playerLevel, minLevel, maxLevel)
  if not playerLevel or not minLevel or not maxLevel then return 5 end
  if minLevel < 1 or maxLevel < 1 or minLevel > maxLevel then return 5 end
  
  local avg = math.floor((minLevel + maxLevel) / 2)
  local diff = avg - playerLevel
  
  local greenThresholds = {
    [1] = 4,
    [2] = 5,
    [3] = 6,
    [4] = 7,
    [5] = 8
  }
  
  local thresholdIndex = math.min(math.floor(playerLevel / 10) + 1, 5)
  local greenThreshold = greenThresholds[thresholdIndex] or 8
  
  if diff >= 5 then return 4 end
  if diff >= 3 then return 3 end
  if diff >= -2 then return 2 end
  if diff >= -greenThreshold then return 1 end
  return 5
end

-----------------------------------------------------------------------------
-- Color Utilities
-----------------------------------------------------------------------------
function AutoLFM.Logic.Content.GetColor(identifier, returnRGBOnly)
  if not identifier then 
    if returnRGBOnly then
      return 1, 0.82, 0
    else
      return nil
    end
  end
  
  local color = nil
  
  for i = 1, table.getn(AutoLFM.Logic.Content.COLORS) do
    local c = AutoLFM.Logic.Content.COLORS[i]
    if c then
      if type(identifier) == "number" and c.priority == identifier then
        color = c
        break
      elseif type(identifier) == "string" and c.key == identifier then
        color = c
        break
      end
    end
  end
  
  if not color then
    if returnRGBOnly then
      return 1, 0.82, 0
    else
      return nil
    end
  end
  
  if returnRGBOnly then
    return color.r, color.g, color.b
  else
    return color
  end
end

-----------------------------------------------------------------------------
-- Priority Calculation
-----------------------------------------------------------------------------
function AutoLFM.Logic.Content.CalculateDungeonPriority(playerLevel, dungeon)
  if not dungeon or not dungeon.levelMin or not dungeon.levelMax then 
    return 5 
  end
  return CalculateLevelPriority(playerLevel, dungeon.levelMin, dungeon.levelMax)
end

function AutoLFM.Logic.Content.CalculateQuestPriority(playerLevel, questLevel)
  if not questLevel then return 5 end
  return CalculateLevelPriority(playerLevel, questLevel, questLevel)
end

-----------------------------------------------------------------------------
-- Quest Link Utilities
-----------------------------------------------------------------------------
function AutoLFM.Logic.Content.CreateQuestLink(questID, level, title)
  local playerLevel = UnitLevel("player") or 1
  local priority = AutoLFM.Logic.Content.CalculateQuestPriority(playerLevel, level)
  local r, g, b = AutoLFM.Logic.Content.GetColor(priority, true)
  local colorCode = AutoLFM.Core.Utils.RGBToHex(r, g, b)
  
  return string.format(
    AutoLFM.Logic.Content.LINK_FORMATS.QUEST, 
    colorCode, 
    questID or 0, 
    level or 0, 
    title or ""
  )
end

function AutoLFM.Logic.Content.CleanQuestText(text)
  if not text then return "" end
  
  text = string.gsub(text, "^ +", "")
  text = string.gsub(text, "  +", " ")
  text = string.gsub(text, "^ ", "")
  text = string.gsub(text, " $", "")
  
  return text
end

-----------------------------------------------------------------------------
-- Generic Content Helpers
-----------------------------------------------------------------------------
local function GetDatabase(contentType)
  if contentType == AutoLFM.Logic.Content.TYPE_DUNGEON then
    return AutoLFM.Logic.Content.DUNGEONS
  elseif contentType == AutoLFM.Logic.Content.TYPE_RAID then
    return AutoLFM.Logic.Content.RAIDS
  end
  return nil
end

local function GetSelected(contentType)
  if contentType == AutoLFM.Logic.Content.TYPE_DUNGEON then
    return selectedDungeons
  elseif contentType == AutoLFM.Logic.Content.TYPE_RAID then
    return selectedRaids
  end
  return {}
end

local function SetSelected(contentType, tags)
  if contentType == AutoLFM.Logic.Content.TYPE_DUNGEON then
    while table.getn(selectedDungeons) > 0 do
      table.remove(selectedDungeons)
    end
    for i = 1, table.getn(tags) do
      table.insert(selectedDungeons, tags[i])
    end
  elseif contentType == AutoLFM.Logic.Content.TYPE_RAID then
    while table.getn(selectedRaids) > 0 do
      table.remove(selectedRaids)
    end
    for i = 1, table.getn(tags) do
      table.insert(selectedRaids, tags[i])
    end
  end
end

local function ClearOpposite(contentType)
  if contentType == AutoLFM.Logic.Content.TYPE_DUNGEON then
    if AutoLFM.Logic.Content.ClearRaids then AutoLFM.Logic.Content.ClearRaids() end
    if AutoLFM.UI.RaidsPanel.ClearSelection then
      AutoLFM.UI.RaidsPanel.ClearSelection()
    end
  elseif contentType == AutoLFM.Logic.Content.TYPE_RAID then
    if AutoLFM.Logic.Content.ClearDungeons then AutoLFM.Logic.Content.ClearDungeons() end
    if AutoLFM.UI.DungeonsPanel.ClearSelection then
      AutoLFM.UI.DungeonsPanel.ClearSelection()
    end
  end
end

-----------------------------------------------------------------------------
-- Selection Logic
-----------------------------------------------------------------------------
local function HandleDungeonSelection(tags, tag, isSelected)
  if not isSelected then
    for i, t in ipairs(tags) do
      if t == tag then
        table.remove(tags, i)
        break
      end
    end
    return
  end
  
  local exists = false
  for _, t in ipairs(tags) do
    if t == tag then
      exists = true
      break
    end
  end
  
  if not exists then
    if table.getn(tags) >= AutoLFM.Logic.Content.MAX_DUNGEONS then
      local removedTag = tags[1]
      table.remove(tags, 1)
      
      if AutoLFM.UI.DungeonsPanel.UncheckDungeon then
        AutoLFM.UI.DungeonsPanel.UncheckDungeon(removedTag)
      end
    end
    table.insert(tags, tag)
  end
end

local function HandleRaidSelection(tags, tag, isSelected)
  while table.getn(tags) > 0 do
    table.remove(tags)
  end
  
  if isSelected then
    table.insert(tags, tag)
  end
end

local function ToggleSelection(contentType, tag, isSelected)
  if not tag then return end
  
  local tags = GetSelected(contentType)
  if not tags then return end
  
  if isSelected then
    ClearOpposite(contentType)
  end
  
  if contentType == AutoLFM.Logic.Content.TYPE_DUNGEON then
    HandleDungeonSelection(tags, tag, isSelected)
  elseif contentType == AutoLFM.Logic.Content.TYPE_RAID then
    HandleRaidSelection(tags, tag, isSelected)
  end
  
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
  
  if AutoLFM and AutoLFM.API and type(AutoLFM.API.NotifyDataChanged) == "function" then
    AutoLFM.API.NotifyDataChanged(AutoLFM.API.EVENTS.CONTENT_CHANGED)
  end
end

local function ClearSelection(contentType)
  if contentType == AutoLFM.Logic.Content.TYPE_DUNGEON then
    while table.getn(selectedDungeons) > 0 do
      table.remove(selectedDungeons)
    end
  elseif contentType == AutoLFM.Logic.Content.TYPE_RAID then
    while table.getn(selectedRaids) > 0 do
      table.remove(selectedRaids)
    end
    raidSize = 0
  end
  
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
  
  if AutoLFM and AutoLFM.API and type(AutoLFM.API.NotifyDataChanged) == "function" then
    AutoLFM.API.NotifyDataChanged(AutoLFM.API.EVENTS.CONTENT_CHANGED)
  end
end

local function GetByTag(contentType, tag)
  if not tag then return nil end
  
  local db = GetDatabase(contentType)
  if not db then return nil end
  
  for i = 1, table.getn(db) do
    if db[i] and db[i].tag == tag then
      return db[i]
    end
  end
  
  return nil
end

local function IsSelected(contentType, tag)
  if not tag then return false end
  
  local tags = GetSelected(contentType)
  if not tags then return false end
  
  for i = 1, table.getn(tags) do
    if tags[i] == tag then
      return true
    end
  end
  
  return false
end

-----------------------------------------------------------------------------
-- Dungeon Management
-----------------------------------------------------------------------------
function AutoLFM.Logic.Content.ToggleDungeon(tag, isSelected)
  ToggleSelection(AutoLFM.Logic.Content.TYPE_DUNGEON, tag, isSelected)
end

function AutoLFM.Logic.Content.ClearDungeons()
  ClearSelection(AutoLFM.Logic.Content.TYPE_DUNGEON)
end

function AutoLFM.Logic.Content.GetSelectedDungeons()
  return GetSelected(AutoLFM.Logic.Content.TYPE_DUNGEON)
end

function AutoLFM.Logic.Content.IsDungeonSelected(tag)
  return IsSelected(AutoLFM.Logic.Content.TYPE_DUNGEON, tag)
end

function AutoLFM.Logic.Content.GetDungeonByTag(tag)
  return GetByTag(AutoLFM.Logic.Content.TYPE_DUNGEON, tag)
end

function AutoLFM.Logic.Content.GetSortedDungeons(playerLevel)
  if not playerLevel or playerLevel < 1 then
    playerLevel = UnitLevel("player") or 1
  end
  
  local sorted = {}
  
  for i = 1, table.getn(AutoLFM.Logic.Content.DUNGEONS) do
    local dungeon = AutoLFM.Logic.Content.DUNGEONS[i]
    if dungeon then
      local priority = AutoLFM.Logic.Content.CalculateDungeonPriority(playerLevel, dungeon)
      table.insert(sorted, {
        dungeon = dungeon,
        priority = priority,
        originalIndex = i
      })
    end
  end
  
  table.sort(sorted, function(a, b)
    if a.priority == b.priority then
      return a.originalIndex < b.originalIndex
    else
      return a.priority < b.priority
    end
  end)
  
  return sorted
end

-----------------------------------------------------------------------------
-- Raid Management
-----------------------------------------------------------------------------
function AutoLFM.Logic.Content.ToggleRaid(tag, isSelected)
  ToggleSelection(AutoLFM.Logic.Content.TYPE_RAID, tag, isSelected)
end

function AutoLFM.Logic.Content.ClearRaids()
  ClearSelection(AutoLFM.Logic.Content.TYPE_RAID)
end

function AutoLFM.Logic.Content.GetSelectedRaids()
  return GetSelected(AutoLFM.Logic.Content.TYPE_RAID)
end

function AutoLFM.Logic.Content.IsRaidSelected(tag)
  return IsSelected(AutoLFM.Logic.Content.TYPE_RAID, tag)
end

function AutoLFM.Logic.Content.GetRaidByTag(tag)
  return GetByTag(AutoLFM.Logic.Content.TYPE_RAID, tag)
end

function AutoLFM.Logic.Content.SetRaidSize(size)
  if not size or size < 1 then
    raidSize = AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_RAID
  else
    raidSize = size
  end
  
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
  
  if AutoLFM and AutoLFM.API and type(AutoLFM.API.NotifyDataChanged) == "function" then
    AutoLFM.API.NotifyDataChanged(AutoLFM.API.EVENTS.CONTENT_CHANGED)
  end
end

function AutoLFM.Logic.Content.GetRaidSize()
  return raidSize or AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_RAID
end

function AutoLFM.Logic.Content.GetRaidSizeRange(tag)
  local raid = AutoLFM.Logic.Content.GetRaidByTag(tag)
  if not raid then
    return AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_RAID, AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_RAID
  end
  
  return raid.sizeMin or AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_RAID, raid.sizeMax or AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_RAID
end

function AutoLFM.Logic.Content.InitRaidSize(tag)
  local raid = AutoLFM.Logic.Content.GetRaidByTag(tag)
  if not raid then
    raidSize = AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_RAID
    return AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_RAID
  end
  
  raidSize = raid.sizeMin or AutoLFM.Core.Utils.CONSTANTS.GROUP_SIZE_RAID
  
  if AutoLFM.Logic.Broadcaster.UpdateMessage then
    AutoLFM.Logic.Broadcaster.UpdateMessage()
  end
  
  return raidSize
end
