# AutoLFM Changelog

## [2.1.1] - Clear Tab Implementation

### Added
- Clear Tab: One-click action tab to clear all selections

### Changed
- Updated README architecture section to include ClearTab.lua
- Updated TODO list: Clear All functionality marked as complete
- Message preview tooltip now uses manual SetPoint positioning

### Improved
- User experience with quick reset functionality
- Tab navigation system to support action tabs

## [2.1.0] - API Complete Integration

### Added
- Complete API v2.0 integration
- Event-based callback system with 7 event types
- New API functions: `RegisterEventCallback()`, `UnregisterEventCallback()`, `IsActive()`, `DebugPrint()`, `GetCallbackCount()`, `ListCallbacks()`
- Complete example addon (AutoLFM_Example)
- Full API documentation and changelog

### Changed
- Renamed `GetDynamicMessage()` to `GetMessage()`

### Improved
- Error handling with safe defaults
- API consistency and reliability

## [2.0.0] - Full Restructuration

### Changed
- Complete addon restructuration
- New modular folder architecture (Core, Logic, UI, API, Misc)
- Separated concerns: Commands, Events, Settings, Utils

### Improved
- Code maintainability and readability
- Better organization for future development

## [1.6.8] - API Addition

### Added
- Initial API implementation for external addons
- Basic functions: `GetVersion()`, `IsAvailable()`, `GetGroupType()`, `GetSelectedContent()`, `GetPlayerCount()`, `GetRolesNeeded()`, `GetDynamicMessage()`, `GetSelectedChannels()`, `GetBroadcastStats()`, `GetTiming()`, `GetFullStatus()`
- Callback system for data changes
- Foundation for addon integrations

## [1.6.7] - FPS/MS Display

### Added
- FPS and MS display frame
- Drag-and-drop functionality for FPS display
- Performance monitoring tool

## [1.6.6] - Dungeon Level Updates

### Changed
- Updated dungeon level ranges for accuracy

### Improved
- Level consistency across content

## [1.6.5] - Content Variables Update

### Changed
- Updated dungeon and raid variables

### Improved
- Accuracy and completeness

## [1.6.4] - Edit Box Focus

### Improved
- Edit box focus handling
- Quest and item link functionality

## [1.6.3] - Code Refactor

### Changed
- Refactored code structure

### Improved
- Readability and maintainability

## [1.6.2] - SavedVariables Improvements

### Changed
- Refactored saved variables initialization
- Streamlined channel selection logic

## [1.6.1] - SavedVariables Refactor

### Changed
- Refactored saved variables initialization

## [1.6.0] - Channel Frame Toggle

### Changed
- Refactored channel frame toggle logic

## [1.5.9] - Channel Selection Refactor

### Changed
- Refactored channel selection logic

## [1.5.8] - UI Adjustments

### Changed
- Adjusted AutoLFM frame display
- Improved button dimensions and layout

## [1.5.7] - Graphical Improvements

### Improved
- Various graphical improvements

## [1.5.6] - Message Construction

### Changed
- Refactored `updateMsgFrameCombined` function

## [1.5.5] - Visibility Checks

### Added
- Visibility checks for quest and item link functions

## [1.5.4] - Item Link Copy

### Added
- Custom item button click behavior
- Copy item link to edit box

## [1.5.3] - Quest Link Creation

### Added
- Quest link creation
- Modified quest log button behavior

## [1.5.2] - Event Handling Refactor

### Changed
- Refactored event handling for raid and group updates

## [1.5.1] - Raid Status Check

### Added
- Raid status check

## [1.5.0] - Raid Status Implementation

### Added
- Implemented raid status check

## [1.4.9] - Minimap Button Update

### Changed
- Updated minimap button size

## [1.4.8] - Raid Status Enhancement

### Improved
- Enhanced raid status check

## [1.4.7] - Code Structure Refactor

### Changed
- Major code structure refactor

### Improved
- Readability and maintainability

## [1.4.6] - Channel Selection Update

### Changed
- Updated channel selection logic

## [1.4.5] - Channel Frame Visibility

### Changed
- Updated channel frame visibility logic

## [1.4.4] - Channel Frame Display

### Added
- Channel frame display logic
- Enhanced slash command functionality

## [1.4.3] - Dungeon & Raid Definitions

### Added
- Slider for raid size selection

### Changed
- Refactored dungeon and raid definitions

## [1.4.2] - Channel Functions Refactor

### Changed
- Refactored channel selection functions

## [1.4.1] - SavedVariables

### Added
- SavedVariables support

## [1.4.0] - Channel Selection

### Added
- Channel selection: World, LookingForGroup, Hardcore

## [1.3.9] - Sound Effects

### Added
- Sound effects

## [1.3.8] - Minimap Button Border

### Added
- Border to minimap button

## [1.3.7] - Minimap Button Fix

### Fixed
- Minimap button issues

## [1.3.6] - Dire Maul East

### Added
- Dire Maul East dungeon

## [1.3.5] - Refactor & Animations

### Added
- OnMouseOver animations

### Changed
- Code refactoring

## [1.3.4] - Broadcast Animation

### Added
- Fun animation when broadcast is active

## [1.3.3] - Minor Fixes

### Fixed
- Various minor fixes

## [1.3.2] - Features in Progress

### Changed
- Work in progress on new features

## [1.3.1] - Member Count Fix

### Fixed
- Member count calculation

## [1.3.0] - Graphical Overhaul

### Changed
- Complete graphical overhaul
- Code factorization

## [1.2.9] - Karazhan Crypts

### Changed
- Karazhan Crypts set to 5 players

## [1.2.8] - Version Rollback

### Fixed
- Reverted to version 1.2.5 due to raid/group count bug

## [1.2.7] - Group & Raid Count Fix

### Fixed
- Group and raid count bug

## [1.2.6] - Group Count Fix

### Fixed
- Group count calculation

## [1.2.5] - Frame Repositioning

### Improved
- Frame repositioning

## [1.2.4] - Dungeon Colors

### Changed
- Adjusted dungeon colors

## [1.2.3] - Color Overhaul

### Changed
- Complete color scheme overhaul

## [1.2.2] - Selection System

### Improved
- Selection system

## [1.2.1] - Details Addition

### Changed
- Removed free text input to add details

## [1.2.0] - Broadcast Timer

### Changed
- Adjusted broadcast timer

## [1.1.9] - Minor Fixes

### Fixed
- Minor corrections

## [1.1.8] - Localization

### Changed
- French to English adjustments

## [1.1.7] - Dungeon Ratio

### Changed
- Adjusted dungeon player ratio

## [1.1.6] - Broadcast Persistence

### Changed
- Messages continue broadcasting when window is closed

## [1.1.5] - Minor Fixes

### Fixed
- Minor corrections

## [1.1.4] - Git Integration

### Added
- Git repository

## [1.1.3] - Changelog Addition

### Added
- Changelog file
