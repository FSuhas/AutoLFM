## [v3.8] 2026/01/02
- Fix duplicate Listener IDs: L05/L06 were used twice (UI panels now use L10-L12)
- Fix `API.IsDarkModeEnabled()` accessing non-existent Maestro state (now uses Storage)
- Fix Lua 5.0 compatibility: remove unused `self` parameter in `SetScript("OnUpdate")` callback
- Optimize `Selection.SetRaidSize()`: use O(1) `RAIDS_BY_NAME` lookup instead of O(n) loop
- Update documentation: correct ID counts (92 total: 24 Commands, 9 Events, 12 Listeners, 20 States, 27 Init Handlers)
- Fix documentation: Auto Invite section incorrectly listed E09-E10 (only E09 exists)
- Update ContentPanel factory comments for clarity on ID auto-assignment (I25+)

## [v3.7] 2025/12/29
- Add pre-calculated array counts (`DUNGEONS_COUNT`, `RAIDS_COUNT`, `COLORS_COUNT`) to avoid O(n) `table.getn()` calls
- Optimize broadcast timer: reuse frame with `Show()`/`Hide()` instead of recreating
- Factorize `forEachRow()` helper in RowList.lua to reduce code duplication
- Add automatic retry mechanism for failed broadcasts (max 2 retries with 1s delay)
- Add `scheduleRetry()` with dedicated frame for deferred retry execution
- Add `escapePattern()` to sanitize auto-invite keywords against Lua pattern injection
- Add `UnregisterCommand()` function to Maestro for command cleanup
- Add optional `validator` parameter to `RegisterState()` for state value validation
- `SetState()` now returns boolean indicating success/failure
- Add comprehensive inline comments for Kahn's topological sort algorithm
- Document all algorithm steps with examples and time complexity

## [v3.6] 2025/12/26
- Add `ArrayContains()` and `ShallowCopy()` utility functions in Utils.lua
- Add `SELECTION_MODES`, `ROLES`, and `VALID_ROLES` constants for type-safe mode switching
- Replace magic strings with constants in Selection.lua (`MODES.DUNGEONS`, `MODES.RAID`, etc.)
- Fix state mutation bug: create shallow copies before modifying arrays from GetState()
- Remove dead code (empty if block) in RowList.lua
- Release memory by setting `pendingStates`/`pendingInits` to nil after flush in Maestro.lua

## [v3.5] 2025/12/11
- Remove redundant Core/Settings.lua
- Remove deprecated GREEN_THRESHOLDS alias
- Remove unused `createQuestLink()` function
- Remove unused `Message.Generated` event
- Add pcall protection for SendChatMessage in Broadcaster.lua
- Add `Utils.RemoveFromArray()` utility function and refactor array removal patterns in Selection.lua and Messaging.lua
- Add configurable General channel index in lua file
- Add `migrateSettings()` to auto-add new settings to existing SavedVariables
- Move initFrame from Events.lua to Maestro.lua
- Simplify dungeon selection lookup
- Unify SOUND_PATH constant
- Renumber IDs: L01-L08, I01-I26, E07-E09

## [v3.4] 2025/12/05
- Add General channel
- Move interval slider in settings (add state info)
- Fix alignment messaging details/custom

## [v3.3] 2025/12/05
- Fix Maestro ID lists
- Fix docs files

## [v3.2] 2025/12/05
- Add quests links requirements
- Reduce space in messaging content: no more scroll in details
- Fix dungeons/raids not visible in presets list
- Add tooltip on VAR insert button for custom message
- Fix Maestro ID lists

## [v3.1] 2025/11/29
- Fix dungeons filters settings
- Rename Settings.lua and add in .toc
- Fix hover row list darkUI
- Clean texture files
- UI.ContentPanel factory pattern
- Add documentation to Core/Constants files
- Improve error messages with context
- Add API and improve documentation
- Optimize dungeon selection lookup performance
- Fix timer context issue in OnUpdate handler
- Fix SavePreset() to allow overwriting existing presets
- Implement UnSubscribeState() function
- Add cache size limit to prevent unbounded growth
- Verify JoinChannelByName() success
- Optimized BuildColorLookupTable()
- Implement Unsubscribe functionality for broadcast and group state listeners
- Enhance Maestro init logging with events and commands registry display
- Refactor Selection.lua with setSelectionMode() for mutual exclusivity
- Optimize registry IDs for better organization and clarity
- Reduce Save Preset popup window size and remove preset name label
- Add screenshots

## [v3.0] 2025/11/29
- Maestro, initial release.