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
    builder = builder
  }
end

--- Gets cached data, building it if not available
--- @param name string - Cache name
--- @param ... any - Optional arguments to pass to builder function
--- @return any - Cached data
function AutoLFM.Core.Cache.Get(name, ...)
  local cache = caches[name]
  if not cache then
    AutoLFM.Core.Utils.LogError("Cache not found: " .. tostring(name))
    return nil
  end

  if not cache.data then
    cache.data = cache.builder(unpack(arg))
  end

  return cache.data
end

--- Clears a specific cache
--- @param name string - Cache name
function AutoLFM.Core.Cache.Clear(name)
  local cache = caches[name]
  if cache then
    cache.data = nil
  end
end

--- Clears all caches
function AutoLFM.Core.Cache.ClearAll()
  for name, cache in pairs(caches) do
    cache.data = nil
  end
end

--- Checks if a cache exists and has data
--- @param name string - Cache name
--- @return boolean - True if cache exists and has data
function AutoLFM.Core.Cache.Has(name)
  local cache = caches[name]
  return cache and cache.data ~= nil
end
