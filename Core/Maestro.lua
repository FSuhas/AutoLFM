--=============================================================================
-- AutoLFM: Maestro System
--   Event bus and initialization system with load-order independence
--=============================================================================
AutoLFM = AutoLFM or {}
AutoLFM.Core = AutoLFM.Core or {}
AutoLFM.Core.Maestro = {}

--=============================================================================
-- SAFE REGISTRATION
--=============================================================================
local pendingInits = {}
local pendingStates = {}

--- Safely registers state declarations before Maestro is fully loaded
--- Queues the registration if Maestro.RegisterState is not yet available
--- @param namespace string - Unique identifier for this state
--- @param initialValue any - Initial state value
--- @param options table - Optional table with id
function AutoLFM.Core.SafeRegisterState(namespace, initialValue, options)
  if AutoLFM.Core.Maestro.RegisterState then
      AutoLFM.Core.Maestro.RegisterState(namespace, initialValue, options)
      return
  end

  table.insert(pendingStates, {
      namespace = namespace,
      initialValue = initialValue,
      options = options or {}
  })
end

--- Safely registers an initialization handler before Maestro is fully loaded
--- Queues the registration if Maestro.RegisterInit is not yet available
--- @param id string - Unique identifier for the initialization handler
--- @param handler function - The initialization function to execute
--- @param options table - Optional table with dependencies and order
function AutoLFM.Core.SafeRegisterInit(id, handler, options)
  if AutoLFM.Core.Maestro.RegisterInit then
      AutoLFM.Core.Maestro.RegisterInit(id, handler, options)
      return
  end

  table.insert(pendingInits, {
      id = id,
      handler = handler,
      options = options or {}
  })
end

--=============================================================================
-- PRIVATE STATE
--=============================================================================
local commands, commandsRegistry, commandCounter = {}, {}, 0
local events, eventsRegistry, eventCounter = {}, {}, 0
local listeners, listenersRegistry, listenerCounter = {}, {}, 0
local initHandlers, initRegistry, initCounter = {}, {}, 0
local stateCounter = 0
local isInitialized = false

--- Generates or validates an ID, updating the counter if needed
--- @param providedId string|nil - Optional provided ID (e.g., "C01")
--- @param prefix string - ID prefix (e.g., "C", "E", "L", "I", "S")
--- @param counter number - Current counter value
--- @return string, number - The ID and updated counter
local function getOrGenerateId(providedId, prefix, counter)
  if not providedId then
    counter = counter + 1
    return prefix .. string.format("%02d", counter), counter
  end
  local idNum = tonumber(string.sub(providedId, 2))
  if idNum and idNum > counter then
    counter = idNum
  end
  return providedId, counter
end

--=============================================================================
-- STATE MANAGEMENT
--=============================================================================
local stateRegistry = {}

--=============================================================================
-- COMMAND BUS
--=============================================================================

--- Registers a command with its handler function
--- @param key string - Dot-separated command key (e.g., "MainFrame.Toggle")
--- @param handler function - The function to execute when command is dispatched
--- @param options table - Optional table with {silent=bool, order=number}
--- @return number - The order ID assigned to this command
function AutoLFM.Core.Maestro.RegisterCommand(key, handler, options)
  if commands[key] then
    error("Maestro: Command '" .. key .. "' already registered")
    return
  end

  local opts = options or {}
  local commandId
  commandId, commandCounter = getOrGenerateId(opts.id, "C", commandCounter)

  commands[key] = {
      handler = handler,
      silent = opts.silent or false,
      id = commandId
  }

  table.insert(commandsRegistry, {
      id = commandId,
      key = key,
      handler = handler
  })
  return commandId
end

--- Generates a human-readable event name from a command key
--- @param key string - Command key (e.g., "MainFrame.Toggle")
--- @return string - Generated event name (e.g., "MainFrame toggled")
local function generateEventName(key)
  local parts = {}
  for part in string.gfind(key, "[^%.]+") do
      table.insert(parts, part)
  end

  local eventParts = {}
  local numParts = table.getn(parts)

  if numParts >= 2 then
      local verb = parts[numParts - 1]
      local noun = parts[numParts]

      if verb == "Toggle" then
          table.insert(eventParts, noun)
          table.insert(eventParts, "toggled")
      elseif verb == "Set" then
          table.insert(eventParts, noun)
          table.insert(eventParts, "set")
      elseif verb == "Select" then
          table.insert(eventParts, noun)
          table.insert(eventParts, "selected")
      else
          table.insert(eventParts, verb)
          table.insert(eventParts, noun)
          table.insert(eventParts, "executed")
      end
  else
      table.insert(eventParts, parts[numParts])
      table.insert(eventParts, "executed")
  end

  return table.concat(eventParts, " ")
end

--- Dispatches a command or emits an event by key with optional arguments
--- First checks if key is a registered command, then checks if it's an event
--- @param key string - The command/event key to dispatch (e.g., "MainFrame.Toggle", "Selection.Changed")
--- @param ... any - Optional arguments to pass to the command handler or event listeners
function AutoLFM.Core.Maestro.Dispatch(key, ...)
  -- Check if it's a registered command first
  local command = commands[key]
  if command then
      if not command.silent then
          -- Pass arguments to LogCommand for display in logs
          AutoLFM.Core.Utils.LogCommand(key, command.id, unpack(arg))

          local eventName = generateEventName(key)
          AutoLFM.Core.Utils.LogEvent(eventName)
      end

      local success, err = pcall(command.handler, unpack(arg))
      if not success then
          AutoLFM.Core.Utils.LogError("Command '" .. key .. "' failed: " .. tostring(err))
          error("Maestro: Error executing command '" .. key .. "': " .. tostring(err))
      end
      return
  end

  -- Check if it's a registered event
  local event = events[key]
  if event then
      if not event.silent then
          -- Pass arguments to LogEvent for display in logs
          AutoLFM.Core.Utils.LogEvent(key, event.id, unpack(arg))
      end

      -- Call all listeners for this event
      for i = 1, table.getn(event.listeners) do
          local success, err = pcall(event.listeners[i], unpack(arg))
          if not success then
              AutoLFM.Core.Utils.LogError("Event listener failed for '" .. key .. "': " .. tostring(err))
          end
      end
      return
  end

  -- Neither command nor event
  error("Maestro: Unknown command or event '" .. key .. "'")
end

--=============================================================================
-- EVENT SYSTEM
--=============================================================================

--- Registers an event that can be emitted via Dispatch()
--- Events are notifications without direct handlers - listeners subscribe to them
--- @param key string - Event key (e.g., "Selection.Changed")
--- @param options table - Optional table with {silent=bool, id=string}
--- @return string - The ID assigned to this event (e.g., "E01")
function AutoLFM.Core.Maestro.RegisterEvent(key, options)
  if events[key] then
    error("Maestro: Event '" .. key .. "' already registered")
    return
  end

  local opts = options or {}
  local eventId
  eventId, eventCounter = getOrGenerateId(opts.id, "E", eventCounter)

  events[key] = {
      listeners = {},
      silent = opts.silent or false,
      id = eventId
  }

  table.insert(eventsRegistry, {
      id = eventId,
      key = key
  })

  return eventId
end

--- Registers a listener function for an event
--- The listener will be called whenever the event is dispatched
--- @param listenerId string - Unique identifier for this listener (e.g., "Message.OnSelectionChanged")
--- @param eventKey string - The event key to listen to (e.g., "Selection.Changed")
--- @param callback function - The function to call when event is emitted
--- @param options table - Optional table with {id=string}
--- @return string - The ID assigned to this listener (e.g., "L01")
function AutoLFM.Core.Maestro.Listen(listenerId, eventKey, callback, options)
  if not events[eventKey] then
      error("Maestro: Cannot listen to unregistered event '" .. eventKey .. "'")
      return
  end

  if type(callback) ~= "function" then
      error("Maestro: Listener callback must be a function")
      return
  end

  table.insert(events[eventKey].listeners, callback)

  local opts = options or {}
  local listenId
  listenId, listenerCounter = getOrGenerateId(opts.id, "L", listenerCounter)

  -- Store in listeners registry
  listeners[listenerId] = {
      eventKey = eventKey,
      callback = callback
  }

  table.insert(listenersRegistry, {
      id = listenId,
      key = listenerId,
      eventKey = eventKey
  })

  return listenId
end

--=============================================================================
-- INITIALIZATION SYSTEM
--=============================================================================

--- Registers an initialization handler with optional dependencies
--- Handlers are executed in dependency order via topological sort
--- @param id string - Unique identifier for this initialization handler
--- @param handler function - The initialization function to execute
--- @param options table - Optional {dependencies=table, order=number}
--- @return number - The order ID assigned to this handler
function AutoLFM.Core.Maestro.RegisterInit(id, handler, options)
  if initHandlers[id] then
    error("Maestro: Init handler '" .. id .. "' already registered")
    return
  end

  local opts = options or {}
  local deps = opts.dependencies or {}
  local initId
  initId, initCounter = getOrGenerateId(opts.id, "I", initCounter)

  initHandlers[id] = {
      handler = handler,
      dependencies = deps,
      id = initId
  }

  table.insert(initRegistry, {
      id = initId,
      key = id,
      handler = handler,
      dependencies = deps
  })
  return initId
end

--- Processes all state handlers registered via SafeRegisterState before Maestro loaded
local function flushPendingStates()
  for i = 1, table.getn(pendingStates) do
      local reg = pendingStates[i]
      AutoLFM.Core.Maestro.RegisterState(reg.namespace, reg.initialValue, reg.options)
  end
  pendingStates = {}
end

--- Processes all init handlers registered via SafeRegisterInit before Maestro loaded
local function flushPendingInits()
  for i = 1, table.getn(pendingInits) do
      local reg = pendingInits[i]
      AutoLFM.Core.Maestro.RegisterInit(reg.id, reg.handler, reg.options)
  end
  pendingInits = {}
end

--- Builds the dependency graph for topological sort
--- @param handlers table - Map of {id = {handler, dependencies}} entries
--- @return table, table, table - inDegree map, adjacency map, sorted array of all IDs
local function buildDependencyGraph(handlers)
  local inDegree = {}
  local adjacency = {}
  local allIds = {}

  -- Initialize structures
  for id, data in pairs(handlers) do
      table.insert(allIds, id)
      inDegree[id] = 0
      adjacency[id] = {}
  end

  -- Sort by ID to ensure deterministic order
  table.sort(allIds, function(a, b)
      local idA = handlers[a].id or "I99"
      local idB = handlers[b].id or "I99"
      return idA < idB
  end)

  -- Build dependency edges
  for id, data in pairs(handlers) do
      for i = 1, table.getn(data.dependencies) do
          local dep = data.dependencies[i]
          if not handlers[dep] then
              error("Maestro: Init handler '" .. id .. "' depends on unknown handler '" .. dep .. "'")
              return nil, nil, nil
          end
          table.insert(adjacency[dep], id)
          inDegree[id] = inDegree[id] + 1
      end
  end

  return inDegree, adjacency, allIds
end

--- Finds all nodes with no dependencies (in-degree = 0)
--- @param inDegree table - Map of node ID to in-degree count
--- @param allIds table - Array of all node IDs
--- @return table - Array of nodes with zero in-degree
local function findNodesWithoutDependencies(inDegree, allIds)
  local queue = {}
  for i = 1, table.getn(allIds) do
      local id = allIds[i]
      if inDegree[id] == 0 then
          table.insert(queue, id)
      end
  end
  return queue
end

--- Processes the dependency queue using Kahn's algorithm
--- @param queue table - Initial queue of nodes with no dependencies
--- @param inDegree table - Map of node ID to in-degree count
--- @param adjacency table - Map of node ID to array of dependent nodes
--- @param handlers table - Original handlers map (for ID sorting)
--- @return table|nil - Sorted array of node IDs, or nil if circular dependency detected
local function processDependencyQueue(queue, inDegree, adjacency, handlers, allIds)
  local sorted = {}

  while table.getn(queue) > 0 do
      -- Always take the handler with lowest ID to ensure deterministic order
      table.sort(queue, function(a, b)
          local idA = handlers[a].id or "I99"
          local idB = handlers[b].id or "I99"
          return idA < idB
      end)

      local current = table.remove(queue, 1)
      table.insert(sorted, current)

      -- Process neighbors and reduce their in-degree
      for i = 1, table.getn(adjacency[current]) do
          local neighbor = adjacency[current][i]
          inDegree[neighbor] = inDegree[neighbor] - 1
          if inDegree[neighbor] == 0 then
              table.insert(queue, neighbor)
          end
      end
  end

  -- Check for circular dependencies
  if table.getn(sorted) ~= table.getn(allIds) then
      error("Maestro: Circular dependency detected in init handlers")
      return nil
  end

  return sorted
end

--- Performs topological sort on init handlers using Kahn's algorithm
--- Resolves dependencies to determine correct initialization order
--- @param handlers table - Map of {id = {handler, dependencies}} entries
--- @return table|nil - Array of sorted IDs in initialization order, or nil on error
local function topologicalSort(handlers)
  local inDegree, adjacency, allIds = buildDependencyGraph(handlers)
  if not inDegree then return nil end

  local queue = findNodesWithoutDependencies(inDegree, allIds)
  return processDependencyQueue(queue, inDegree, adjacency, handlers, allIds)
end

--- Executes all registered initialization handlers in dependency order
--- Uses topological sort (Kahn's algorithm) to resolve dependencies
--- Logs errors but continues initialization on failure
function AutoLFM.Core.Maestro.RunInit()
  if isInitialized then
      return
  end

  local sorted = topologicalSort(initHandlers)
  if not sorted then
      AutoLFM.Core.Utils.PrintError("Failed to initialize: circular dependencies")
      return
  end

  -- Phase 1: Log all registered states (in sorted order by ID)
  local stateList = {}
  for namespace, data in pairs(stateRegistry) do
    table.insert(stateList, { namespace = namespace, id = data.id or "S??" })
  end
  table.sort(stateList, function(a, b) return a.id < b.id end)

  for i = 1, table.getn(stateList) do
    local item = stateList[i]
    local idColored = AutoLFM.Core.Utils.ColorText("[" .. item.id .. "]", "GRAY")
    AutoLFM.Core.Utils.LogState(idColored .. " " .. item.namespace)
  end

  -- Phase 2: Log all INIT events
  for i = 1, table.getn(sorted) do
      local id = sorted[i]
      local data = initHandlers[id]
      local idColored = AutoLFM.Core.Utils.ColorText("[" .. (data.id or "I??") .. "]", "GRAY")
      AutoLFM.Core.Utils.LogInit(idColored .. " " .. id)
  end

  -- Phase 3: Run all initialization handlers
  for i = 1, table.getn(sorted) do
      local id = sorted[i]
      local data = initHandlers[id]

      local success, err = pcall(data.handler)
      if not success then
          AutoLFM.Core.Utils.LogError("Init handler '" .. id .. "' failed: " .. tostring(err))
      end
  end

  isInitialized = true
  AutoLFM.Core.Utils.PrintSuccess("Successfully loaded!")
end

--- Returns whether the addon has completed initialization
--- @return boolean - True if RunInit() has completed successfully
function AutoLFM.Core.Maestro.IsInitialized()
  return isInitialized
end

--=============================================================================
-- STATE MANAGEMENT API
--=============================================================================

--- Registers a state namespace with an initial value
--- @param namespace string - Unique identifier for this state (e.g., "Selection.Dungeons")
--- @param initialValue any - Initial state value (can be table, number, boolean, etc.)
--- @param options table - Optional table with {id=string}
--- @return string - The ID assigned to this state (e.g., "S01")
function AutoLFM.Core.Maestro.RegisterState(namespace, initialValue, options)
  if not namespace or type(namespace) ~= "string" then
    AutoLFM.Core.Utils.LogError("RegisterState: namespace must be a non-empty string")
    return
  end

  if stateRegistry[namespace] then
    AutoLFM.Core.Utils.LogWarning("RegisterState: namespace '" .. namespace .. "' already registered")
    return
  end

  local opts = options or {}
  local stateId
  stateId, stateCounter = getOrGenerateId(opts.id, "S", stateCounter)

  stateRegistry[namespace] = {
    value = initialValue,
    subscribers = {},
    id = stateId
  }

  -- Don't log here anymore - will be logged in batch during RunInit
  return stateId
end

--- Gets the current value of a state namespace (READ-ONLY)
--- @param namespace string - The state namespace to retrieve
--- @return any - The current state value, or nil if namespace not found
function AutoLFM.Core.Maestro.GetState(namespace)
  if not stateRegistry[namespace] then
    AutoLFM.Core.Utils.LogWarning("GetState: namespace '" .. tostring(namespace) .. "' not registered")
    return nil
  end

  return stateRegistry[namespace].value
end

--- Sets a new value for a state namespace and notifies all subscribers
--- Emits a Maestro event: "State.Changed.<namespace>"
--- @param namespace string - The state namespace to update
--- @param newValue any - The new state value
function AutoLFM.Core.Maestro.SetState(namespace, newValue)
  if not stateRegistry[namespace] then
    AutoLFM.Core.Utils.LogError("SetState: namespace '" .. tostring(namespace) .. "' not registered")
    return
  end

  local oldValue = stateRegistry[namespace].value
  stateRegistry[namespace].value = newValue

  -- Notify all subscribers
  local subscribers = stateRegistry[namespace].subscribers
  for i = 1, table.getn(subscribers) do
    local success, err = pcall(subscribers[i], newValue, oldValue)
    if not success then
      AutoLFM.Core.Utils.LogError("State subscriber failed for '" .. namespace .. "': " .. tostring(err))
    end
  end

  -- Emit Maestro event for loose coupling (only if event is registered)
  local eventName = "State.Changed." .. namespace
  if events[eventName] then
    AutoLFM.Core.Maestro.Dispatch(eventName, {
      namespace = namespace,
      newValue = newValue,
      oldValue = oldValue
    })
  end
end

--- Subscribes a callback function to state changes
--- The callback receives (newValue, oldValue) when state changes
--- @param namespace string - The state namespace to watch
--- @param callback function - Function to call when state changes: callback(newValue, oldValue)
function AutoLFM.Core.Maestro.SubscribeState(namespace, callback)
  if not stateRegistry[namespace] then
    AutoLFM.Core.Utils.LogError("SubscribeState: namespace '" .. tostring(namespace) .. "' not registered")
    return
  end

  if type(callback) ~= "function" then
    AutoLFM.Core.Utils.LogError("SubscribeState: callback must be a function")
    return
  end

  table.insert(stateRegistry[namespace].subscribers, callback)
end

--- Updates a state value using a transformer function
--- Useful for complex state modifications (e.g., table manipulations)
--- @param namespace string - The state namespace to update
--- @param transformer function - Function that receives current state and returns new state: newState = transformer(oldState)
function AutoLFM.Core.Maestro.UpdateState(namespace, transformer)
  if not stateRegistry[namespace] then
    AutoLFM.Core.Utils.LogError("UpdateState: namespace '" .. tostring(namespace) .. "' not registered")
    return
  end

  if type(transformer) ~= "function" then
    AutoLFM.Core.Utils.LogError("UpdateState: transformer must be a function")
    return
  end

  local currentValue = stateRegistry[namespace].value
  local success, newValue = pcall(transformer, currentValue)

  if not success then
    AutoLFM.Core.Utils.LogError("UpdateState: transformer failed for '" .. namespace .. "': " .. tostring(newValue))
    return
  end

  AutoLFM.Core.Maestro.SetState(namespace, newValue)
end

--=============================================================================
-- REGISTRY DATA GETTER
--=============================================================================

--- Returns all registries for debugging
--- Used by debug console to display registered commands, events, listeners, and handlers
--- @return table, table, table, table - commandsRegistry, eventsRegistry, listenersRegistry, initRegistry
function AutoLFM.Core.Maestro.GetRegistry()
  return commandsRegistry, eventsRegistry, listenersRegistry, initRegistry
end

--- Returns all registered states as a key-value table with IDs
--- Used by debug console to display current state
--- @return table - Table of namespace -> {value, id} mappings
function AutoLFM.Core.Maestro.GetAllStates()
  local states = {}
  for namespace, data in pairs(stateRegistry) do
    states[namespace] = {
      value = data.value,
      id = data.id or "S??"
    }
  end
  return states
end

--=============================================================================
-- AUTO-INITIALIZATION
--=============================================================================
flushPendingStates()
flushPendingInits()
