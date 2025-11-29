--=============================================================================
-- AutoLFM: Cache Manager
--   Generic cache system for computed data with automatic invalidation
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Core = AutoLFM.Core or {}
AutoLFM.Core.Cache = {}

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local caches = {}

--=============================================================================
-- PRIVATE HELPERS
--=============================================================================

--- Serializes arguments to a string key for cache lookup
--- @param args table - Arguments table
--- @return string - Serialized key
local function serializeArgs(args)
  if not args or table.getn(args) == 0 then
    return ""
  end

  local parts = {}
  for i = 1, table.getn(args) do
    local v = args[i]
    if type(v) == "table" then
      -- Simple table serialization (shallow)
      local tableParts = {}
      for k, val in pairs(v) do
        table.insert(tableParts, tostring(k) .. "=" .. tostring(val))
      end
      table.sort(tableParts)
      table.insert(parts, "{" .. table.concat(tableParts, ",") .. "}")
    else
      table.insert(parts, tostring(v))
    end
  end
  return table.concat(parts, "|")
end

--=============================================================================
-- PUBLIC API
--=============================================================================

--- Registers a new cache with a builder function
--- @param name string - Cache name (e.g., "Dungeons", "Quests")
--- @param builder function - Function that builds the cached data
function AutoLFM.Core.Cache.Register(name, builder)
  if not name or type(name) ~= "string" then
    AutoLFM.Core.Utils.LogError("Cache.Register: name must be a string")
    return
  end

  if not builder or type(builder) ~= "function" then
    AutoLFM.Core.Utils.LogError("Cache.Register: builder must be a function")
    return
  end

  caches[name] = {
    data = nil,
    builder = builder,
    lastArgsKey = nil
  }
end

--- Gets cached data, building it if not available or if arguments changed
--- @param name string - Cache name
--- @param ... any - Optional arguments to pass to builder function
--- @return any - Cached data
function AutoLFM.Core.Cache.Get(name, ...)
  -- Validate name parameter
  if type(name) ~= "string" then
    AutoLFM.Core.Utils.LogError("Cache.Get: name must be string, got " .. type(name))
    return nil
  end

  local cache = caches[name]
  if not cache then
    AutoLFM.Core.Utils.LogError("Cache not found: " .. tostring(name))
    return nil
  end

  local argsKey = serializeArgs(arg)

  -- Invalidate if arguments changed
  if cache.lastArgsKey ~= argsKey then
    cache.data = nil
    cache.lastArgsKey = argsKey
  end

  if not cache.data then
    cache.data = cache.builder(unpack(arg))
  end

  return cache.data
end

--- Clears a specific cache
--- @param name string - Cache name
function AutoLFM.Core.Cache.Clear(name)
  -- Validate name parameter
  if type(name) ~= "string" then
    AutoLFM.Core.Utils.LogError("Cache.Clear: name must be string, got " .. type(name))
    return false
  end

  local cache = caches[name]
  if cache then
    cache.data = nil
    cache.lastArgsKey = nil
    return true
  end

  AutoLFM.Core.Utils.LogWarning("Cache.Clear: cache not found: " .. name)
  return false
end

--- Clears all caches
function AutoLFM.Core.Cache.ClearAll()
  for name, cache in pairs(caches) do
    cache.data = nil
    cache.lastArgsKey = nil
  end
end

--- Checks if a cache exists and has data
--- @param name string - Cache name
--- @return boolean - True if cache exists and has data
function AutoLFM.Core.Cache.Has(name)
  local cache = caches[name]
  return cache and cache.data ~= nil
end
