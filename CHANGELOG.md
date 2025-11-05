# AutoLFM Changelog

## [2.34] - Refactor UI components for AutoLFM

- Simplified initialization of UI tables in MainWindow and DungeonsPanel.
- Improved readability by consolidating variable declarations and reducing redundant checks.
- Enhanced the structure of the Size Controls in RaidsPanel for better clarity and maintainability.
- Updated function definitions and calls to ensure consistent formatting and style across the codebase.
- Added checks for nil values before accessing properties to prevent potential errors.
- Improved tooltip handling and user feedback in the Size Controls.

## [2.23] - DarkUI

- Add ShaguTweaks DarkUI theme

## [2.22] - Cached Dungeons list, Backdrops

- Dungeons list only refreshed if player level up
- Backdrop Presets
- Opti CalculateLevelPriority


## [2.21] - Reorganize Init and Settings

- Reorganize Init and Settings
- Match patterns for WelcomePopup

## [2.20] - Add Constants.lua

- Centralized all constants in Constants.lua
- Main readme restructuration

## [2.19] - Code refactoring

- Centralized utility functions to Core/Utils.lua (truncate, setfontcolor, ...)
- Label hover behavior: created AttachLabelHighlight utility
- CreateRadioButtonGroup
- CreateIconWithLabel: unified icon+label creation
- CreateSlider: unified slider creation

## [2.18] - FuBar plugin 1.0

- FuBarPlugin v1.0
- Add "gold" color in utils (wow yellow game color)

## [2.17] - Add Welcome Popup 

- New functionality to AutoLFM

## [2.16] - Add functionality

- Uncheck all quest checkboxes on tab click

## [2.15] - FuBar plugin 0.1, refactoring Raids & Quests Panels

- FuBarPlugin v0.1 (need design)
- (Previous commits: refactoring Raids & Quests Panels)

## [2.14] - Addon API example

- Update Addon API example
- Remove Readme Fubar section
- (Previous commits: refactoring DungeonsPanel and fix Filters issue)

## [2.13] - FuBar plugin

- Add FuBar plugin

## [2.12] - API v2.1

- Monitoring
- PLAYER_COUNT_CHANGED
- Refactoring

## [2.11] - Tooltips zones quests, slash commands

- Revamping commands SLASH and helpers
- Add zone tooltips in QuestsPanel
- Versioning fix

## [2.10] - Add fun Paladin-style invitation messages

- Add randomize confirmation response

## [2.9] - Enhance quest list display

- Adding dungeon/raid detection 
- Truncating long titles

## [2.8] - Cleanup guards, helpers UI panels, illustration

- Removed redundant guards and optimized pcall usage
- Eliminated global helper variables UI panels
- Add toplevel for mainframe
- Change illustration

## [2.7] - Refactoring row creation, illustration

- Centralized selectable row creation in PanelBuilder
- Change illustration

## [2.6] - Code cleanup

- Removed dead code, reduced duplication

## [2.5] - Self-contained Assets

- Internalized all UI textures (buttons, sliders, backdrops)

## [2.4] - Reorganize MorePanel, HC status from spell

- Simplify frames (REALY NEED TO USE PROPER XML TEMPLATE IN FUTURE)
- Identify Hardcore status from spell

## [2.3] - Fix Hardcore chan

- Add Hardcore channel detection and message handling

## [2.2] - Fix minimap button

- Animation, position, size

## [2.1] - Misc modules, init, minimapBtn moving

- Integrate misc modules
- Simplified Init.lua
- Minimap button free moving

## [2.0] - Full Restructuration

- Complete modular architecture
- API v2.0 integration

## [1.6.8] - API Addition

- Public API for external addons
- Callback system

## [1.6.7] - FPS/MS Display

- FPS and latency monitor
- Draggable overlay

## [1.6.6] - Dungeon Level Updates

- Updated level ranges

## [1.6.5] - Content Variables Update

- Updated dungeon/raid data

## [1.6.4] - Edit Box Focus

- Improved quest/item links

## [1.6.3] - Code Refactor

- Structure improvements

## [1.6.2] - SavedVariables Improvements

- Better initialization

## [1.6.1] - SavedVariables Refactor

- Settings cleanup

## [1.6.0] - Channel Frame Toggle

- Improved channel logic

## [1.5.9] - Channel Selection Refactor

- Channel selection improvements

## [1.5.8] - UI Adjustments

- Button layout improvements

## [1.5.7] - Graphical Improvements

- Visual enhancements

## [1.5.6] - Message Construction

- Message function refactor

## [1.5.5] - Visibility Checks

- Link function checks

## [1.5.4] - Item Link Copy

- Custom item button behavior

## [1.5.3] - Quest Link Creation

- Quest log integration

## [1.5.2] - Event Handling Refactor

- Event system improvements

## [1.5.1] - Raid Status Check

- Added raid status

## [1.5.0] - Raid Status Implementation

- Implemented raid checks

## [1.4.9] - Minimap Button Update

- Button size adjustment

## [1.4.8] - Raid Status Enhancement

- Enhanced raid checks

## [1.4.7] - Code Structure Refactor

- Major restructure

## [1.4.6] - Channel Selection Update

- Channel logic update

## [1.4.5] - Channel Frame Visibility

- Visibility logic update

## [1.4.4] - Channel Frame Display

- Channel frame logic
- Slash command enhancement

## [1.4.3] - Dungeon & Raid Definitions

- Raid size slider
- Definition refactor

## [1.4.2] - Channel Functions Refactor

- Channel function improvements

## [1.4.1] - SavedVariables

- Added SavedVariables support

## [1.4.0] - Channel Selection

- World, LFG, Hardcore channels

## [1.3.9] - Sound Effects

- Added sound effects

## [1.3.8] - Minimap Button Border

- Button border added

## [1.3.7] - Minimap Button Fix

- Fixed minimap issues

## [1.3.6] - Dire Maul East

- Added DM East

## [1.3.5] - Refactor & Animations

- OnMouseOver animations
- Code refactoring

## [1.3.4] - Broadcast Animation

- Active broadcast animation

## [1.3.3] - Minor Fixes

- Bug fixes

## [1.3.2] - Features in Progress

- WIP features

## [1.3.1] - Member Count Fix

- Fixed count calculation

## [1.3.0] - Graphical Overhaul

- Complete UI redesign
- Code factorization

## [1.2.9] - Karazhan Crypts

- Set to 5 players

## [1.2.8] - Version Rollback

- Reverted to 1.2.5

## [1.2.7] - Group & Raid Count Fix

- Fixed count bug

## [1.2.6] - Group Count Fix

- Fixed calculation

## [1.2.5] - Frame Repositioning

- Frame improvements

## [1.2.4] - Dungeon Colors

- Adjusted colors

## [1.2.3] - Color Overhaul

- Complete color redesign

## [1.2.2] - Selection System

- Improved selection

## [1.2.1] - Details Addition

- Removed free text input

## [1.2.0] - Broadcast Timer

- Adjusted timer

## [1.1.9] - Minor Fixes

- Corrections

## [1.1.8] - Localization

- French to English

## [1.1.7] - Dungeon Ratio

- Player ratio adjustments

## [1.1.6] - Broadcast Persistence

- Messages persist when closed

## [1.1.5] - Minor Fixes

- Corrections

## [1.1.4] - Git Integration

- Added Git repository

## [1.1.3] - Changelog Addition

- Added changelog
