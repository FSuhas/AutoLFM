--=============================================================================
-- AutoLFM: Persistent Storage
--   Centralized access to V3_Settings and V3_Presets SavedVariables
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Core = AutoLFM.Core or {}
AutoLFM.Core.Storage = {}

-----------------------------------------------------------------------------
-- Private State
-----------------------------------------------------------------------------
local characterID

-----------------------------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------------------------

--- Creates a deep copy of a table (recursive)
--- @param obj any - Object to copy (can be table or primitive)
--- @return any - Deep copy of the object
local function deepCopy(obj)
  if type(obj) ~= "table" then return obj end
  local copy = {}
  for k, v in pairs(obj) do
    copy[k] = type(v) == "table" and deepCopy(v) or v
  end
  return copy
end

-----------------------------------------------------------------------------
-- Settings Registry
-----------------------------------------------------------------------------
local SETTINGS_REGISTRY = {
  {key = "dungeonFilters", type = "table", default = {GRAY = true, GREEN = true, YELLOW = true, ORANGE = true, RED = true}},
  {key = "broadcastInterval", type = "number", default = 60},
  {key = "minimapHidden", type = "boolean", default = false},
  {key = "minimapPos", type = "table", default = nil},
  {key = "darkMode", type = "boolean", default = nil},
  {key = "previewMessageLines", type = "number", default = 2},
  {key = "customInput", type = "boolean", default = false},
  {key = "presetsCondensed", type = "boolean", default = false},
  {key = "defaultPanel", type = "string", default = "dungeons"},
  {key = "dryRun", type = "boolean", default = false},
  {key = "selectedChannels", type = "table", default = {}},
  {key = "autoInviteEnabled", type = "boolean", default = false},
  {key = "autoInviteKeywords", type = "table", default = {"+1"}},
  {key = "autoInviteConfirm", type = "boolean", default = true},
  {key = "autoInviteRandomMessages", type = "boolean", default = true},
  {key = "autoInviteRespondWhenNotLeader", type = "boolean", default = false},
  {key = "isHardcore", type = "boolean", default = nil},
  {key = "welcomeShown", type = "boolean", default = false}
}

-----------------------------------------------------------------------------
-- Helper Functions
-----------------------------------------------------------------------------

--- Retrieves character-specific persistent data, optionally creating it
--- @param ensure boolean - If true, creates character data if it doesn't exist
--- @return table|nil - Character data table, or nil if not available
local function getCharData(ensure)
  if not characterID then return nil end
  if not V3_Settings then
    if not ensure then return nil end
    V3_Settings = {}
  end
  if not V3_Settings[characterID] and ensure then
    local defaults = {}
    for i = 1, table.getn(SETTINGS_REGISTRY) do
      local setting = SETTINGS_REGISTRY[i]
      if setting.type == "table" and setting.default then
        defaults[setting.key] = deepCopy(setting.default)
      else
        defaults[setting.key] = setting.default
      end
    end
    if defaults.darkMode == nil then
      defaults.darkMode = (ShaguTweaks and ShaguTweaks.DarkMode) or nil
    end
    V3_Settings[characterID] = defaults
  end
  return V3_Settings[characterID]
end

-----------------------------------------------------------------------------
-- Generic Get/Set
--   Direct access to character-specific persistent storage
-----------------------------------------------------------------------------

--- Gets a value from character-specific persistent storage
--- @param key string - The setting key to retrieve
--- @param defaultValue any - Value to return if key is not found or nil
--- @return any - The stored value or defaultValue
function AutoLFM.Core.Storage.Get(key, defaultValue)
  local charData = getCharData()
  if not charData then
      return defaultValue
  end
  local value = charData[key]
  if value == nil then
      return defaultValue
  end

  return value
end

--- Sets a value in character-specific persistent storage
--- @param key string - The setting key to store
--- @param value any - The value to store (will be saved to SavedVariables)
function AutoLFM.Core.Storage.Set(key, value)
  local charData = getCharData(true)
  if not charData then return end

  charData[key] = value
end

-----------------------------------------------------------------------------
-- Auto-generated accessors
--   Dynamically creates Get*/Set* functions for each registered setting
--   Example: GetDarkMode(), SetDarkMode(value), GetMinimapVisible(), etc.
-----------------------------------------------------------------------------
for i = 1, table.getn(SETTINGS_REGISTRY) do
  local setting = SETTINGS_REGISTRY[i]
  local capitalizedKey = string.upper(string.sub(setting.key, 1, 1)) .. string.sub(setting.key, 2)
  AutoLFM.Core.Storage["Get" .. capitalizedKey] = function()
      return AutoLFM.Core.Storage.Get(setting.key, setting.default)
  end
  AutoLFM.Core.Storage["Set" .. capitalizedKey] = function(value)
      local coerced = value
      if setting.type == "boolean" then
          coerced = value == true
      elseif setting.type == "string" then
          coerced = tostring(value)
      elseif setting.type == "number" then
          coerced = tonumber(value)
      end
      AutoLFM.Core.Storage.Set(setting.key, coerced)
  end
end

-----------------------------------------------------------------------------
-- Specialized accessors
--   Custom accessors with special logic beyond simple get/set
-----------------------------------------------------------------------------

--- Sets minimap button position or clears it if nil
--- @param x number - X coordinate (optional, pass nil to clear position)
--- @param y number - Y coordinate (optional, pass nil to clear position)
function AutoLFM.Core.Storage.SetMinimapPos(x, y)
  if x and y then
      AutoLFM.Core.Storage.Set("minimapPos", { x = x, y = y })
  else
      AutoLFM.Core.Storage.Set("minimapPos", nil)
  end
end

--- Updates a single dungeon color filter state
--- @param filterId string - Color name (e.g., "RED", "GREEN", "YELLOW")
--- @param enabled boolean - Whether dungeons of this color should be shown
function AutoLFM.Core.Storage.SetDungeonFilter(filterId, enabled)
  local filters = AutoLFM.Core.Storage.GetDungeonFilters()
  filters[filterId] = enabled
  AutoLFM.Core.Storage.SetDungeonFilters(filters)
end

--- Deep copy utility for cloning tables recursively
--- @param tbl table - The table to deep copy
--- @return table - A new table with all nested tables copied
AutoLFM.Core.Storage.DeepCopy = deepCopy

-----------------------------------------------------------------------------
-- Additional Specialized Accessors
-----------------------------------------------------------------------------

--- Sets the broadcast interval with validation
--- @param interval number - Interval in seconds (30-7200)
function AutoLFM.Core.Storage.SetBroadcastInterval(interval)
  -- Clamp between 30 seconds and 2 hours
  local clamped = math.max(30, math.min(7200, tonumber(interval) or 60))
  AutoLFM.Core.Storage.Set("broadcastInterval", clamped)
end

-----------------------------------------------------------------------------
-- Hardcore Detection
-----------------------------------------------------------------------------

--- Detects if character is in hardcore mode by scanning spellbook
--- @return boolean - True if "hardcore" spell found in spellbook
local function detectHardcoreCharacter()
  for tab = 1, GetNumSpellTabs() do
    local _, _, offset, numSpells = GetSpellTabInfo(tab)
    for i = 1, numSpells do
      local spellName = GetSpellName(offset + i, "spell")
      if spellName and string.find(string.lower(spellName), "hardcore") then
        return true
      end
    end
  end
  return false
end

-----------------------------------------------------------------------------
-- Initialization
--   Sets up character ID and initializes storage on first load
-----------------------------------------------------------------------------

--- Initializes persistent storage for current character
--- Creates character-specific storage and detects hardcore mode
function AutoLFM.Core.Storage.Init()
  local name = UnitName("player")
  local realm = GetRealmName()
  if not name or not realm then return end
  characterID = name .. "-" .. realm
  getCharData(true)
  if not V3_Presets then
      V3_Presets = {}
  end
  if not V3_Presets[characterID] then
      V3_Presets[characterID] = {
          data = {},
          order = {}
      }
  end

  local charData = getCharData()
  if charData and charData.isHardcore == nil then
    local isHardcore = detectHardcoreCharacter()
    AutoLFM.Core.Storage.SetIsHardcore(isHardcore)
  end
end

-----------------------------------------------------------------------------
-- Presets Management
-----------------------------------------------------------------------------

--- Gets all presets for the current character
--- @return table - Table with 'data' (preset name -> preset data) and 'order' (array of preset names)
function AutoLFM.Core.Storage.GetPresets()
  if not V3_Presets or not characterID then
    return { data = {}, order = {} }
  end
  if not V3_Presets[characterID] then
    V3_Presets[characterID] = { data = {}, order = {} }
  end
  return V3_Presets[characterID]
end

--- Saves a preset with the given name and data
--- If preset already exists, it will be overwritten (data updated, order preserved)
--- @param presetName string - Name of the preset
--- @param presetData table - Preset data to save
--- @return boolean - True if successful
function AutoLFM.Core.Storage.SavePreset(presetName, presetData)
  if not presetName or presetName == "" then return false end
  if not V3_Presets or not characterID then return false end

  local presets = AutoLFM.Core.Storage.GetPresets()

  -- Check if preset already exists
  local exists = false
  for i = 1, table.getn(presets.order) do
    if presets.order[i] == presetName then
      exists = true
      break
    end
  end

  -- Add to order if new (preserve order for existing presets)
  if not exists then
    table.insert(presets.order, presetName)
  end

  -- Save data (deep copy to avoid reference issues)
  -- This will overwrite existing preset data if it exists
  presets.data[presetName] = deepCopy(presetData)

  return true
end

--- Checks if a preset exists
--- @param presetName string - Name of the preset
--- @return boolean - True if preset exists
function AutoLFM.Core.Storage.PresetExists(presetName)
  if not presetName or presetName == "" then return false end
  local presets = AutoLFM.Core.Storage.GetPresets()
  return presets.data[presetName] ~= nil
end

--- Deletes a preset
--- @param presetName string - Name of the preset to delete
--- @return boolean - True if successful
function AutoLFM.Core.Storage.DeletePreset(presetName)
  if not presetName or presetName == "" then return false end
  local presets = AutoLFM.Core.Storage.GetPresets()

  -- Remove from data
  presets.data[presetName] = nil

  -- Remove from order
  local newOrder = {}
  for i = 1, table.getn(presets.order) do
    if presets.order[i] ~= presetName then
      table.insert(newOrder, presets.order[i])
    end
  end
  presets.order = newOrder

  return true
end

--- Moves a preset up in the order
--- @param presetName string - Name of the preset to move
--- @return boolean - True if successful
function AutoLFM.Core.Storage.MovePresetUp(presetName)
  if not presetName or presetName == "" then return false end
  local presets = AutoLFM.Core.Storage.GetPresets()

  local index
  for i = 1, table.getn(presets.order) do
    if presets.order[i] == presetName then
      index = i
      break
    end
  end
  if not index or index == 1 then return false end

  presets.order[index - 1], presets.order[index] = presets.order[index], presets.order[index - 1]
  return true
end

--- Moves a preset down in the order
--- @param presetName string - Name of the preset to move
--- @return boolean - True if successful
function AutoLFM.Core.Storage.MovePresetDown(presetName)
  if not presetName or presetName == "" then return false end
  local presets = AutoLFM.Core.Storage.GetPresets()

  local index
  for i = 1, table.getn(presets.order) do
    if presets.order[i] == presetName then
      index = i
      break
    end
  end
  if not index or index == table.getn(presets.order) then return false end

  presets.order[index], presets.order[index + 1] = presets.order[index + 1], presets.order[index]
  return true
end

-----------------------------------------------------------------------------
-- Registration
-----------------------------------------------------------------------------
AutoLFM.Core.SafeRegisterInit("Core.Storage", function()
  AutoLFM.Core.Storage.Init()
end, { id = "I02" })
