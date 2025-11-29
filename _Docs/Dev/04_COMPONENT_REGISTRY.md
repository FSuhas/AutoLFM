# Maestro Registry - Complete Reference

This file lists **ALL** IDs used in AutoLFM for the Maestro system.

**⚠️ IMPORTANT: Keep this file updated!**
- Every time you add a Command, Event, Listener, Init or State
- IDs must be **unique** within their category
- IDs are used for **sorting**, **documentation** and **execution order** (for Init Handlers)
- Code uses **full names** for dispatching, IDs are for organization

---

## Commands (C01-C99)

| ID | Nom | Module | Description |
|----|-----|--------|-------------|
| **C01** | `MainFrame.Toggle` | Logic.MainFrame | Toggle main window visibility |
| **C02** | `Debug.Toggle` | Components.Debug | Toggle debug window visibility |
| **C06** | `Selection.ToggleDungeon` | Logic.Selection | Toggle dungeon selection (FIFO max 3) |
| **C07** | `Selection.ToggleRaid` | Logic.Selection | Toggle raid selection (exclusive) |
| **C08** | `Selection.SetRaidSize` | Logic.Selection | Set custom raid size (1-40) |
| **C09** | `Selection.ToggleRole` | Logic.Selection | Toggle role selection (TANK/HEAL/DPS) |
| **C10** | `Selection.ClearRoles` | Logic.Selection | Clear all role selections |
| **C11** | `Selection.SetCustomMessage` | Logic.Selection | Set custom broadcast message |
| **C12** | `Selection.ClearCustomMessage` | Logic.Selection | Clear custom message |
| **C13** | `Selection.SetCustomGroupSize` | Logic.Selection | Set custom group size for custom messages (1-40) |
| **C14** | `Selection.ClearDungeons` | Logic.Selection | Clear all dungeon selections |
| **C15** | `Selection.ClearRaid` | Logic.Selection | Clear raid selection |
| **C16** | `Selection.SetDetailsText` | Logic.Selection | Set details text (appended to auto-generated messages) |
| **C17** | `Selection.ClearAll` | Logic.Selection | Clear all selections (dungeons/raids/roles/custom/details) |
| **C21** | `Broadcaster.Toggle` | Logic.Broadcaster | Toggle broadcasting on/off |
| **C23** | `Channels.ToggleChannel` | Logic.Content.Messaging | Toggle channel selection |
| **C26** | `Quests.Toggle` | UI.Content.Quests | Toggle quests panel visibility |
| **C27** | `QuestsList.Refresh` | UI.Content.Quests | Refresh quests list display |
| **C28** | `Presets.Save` | Logic.Content.Presets | Save current selection as preset |
| **C29** | `Presets.Load` | Logic.Content.Presets | Load a saved preset |
| **C30** | `Presets.Delete` | Logic.Content.Presets | Delete a saved preset |
| **C31** | `AutoInvite.Enable` | Logic.AutoInvite | Enable auto-invite |
| **C32** | `AutoInvite.Disable` | Logic.AutoInvite | Disable auto-invite |
| **C36** | `AutoInvite.SetKeywords` | Logic.AutoInvite | Set auto-invite keywords |

---

## Events (E01-E99)

| ID | Name | Module | Description | Emitted When |
|----|------|--------|-------------|-------------|
| **E01** | `Selection.Changed` | Logic.Selection | Selection state changed | Any selection modified (dungeons/raids/roles/custom) |
| **E02** | `Group.SizeChanged` | Core.Events | Group size changed | PARTY_MEMBERS_CHANGED or RAID_ROSTER_UPDATE |
| **E03** | `Group.LeaderChanged` | Core.Events | Party leader changed | PARTY_LEADER_CHANGED |
| **E04** | `Chat.WhisperReceived` | Core.Events | Whisper received | CHAT_MSG_WHISPER (for Auto Invite) |
| **E05** | `Channels.Changed` | Logic.Content.Messaging | Channels selection changed | Any channel toggled |
| **E06** | `AutoInvite.Changed` | Logic.AutoInvite | Auto-invite settings changed | Auto-invite enabled/disabled or settings modified |
| **E07** | `Presets.Changed` | Logic.Content.Presets | Presets list changed | Preset saved or deleted |
| **E08** | `Presets.Loaded` | Logic.Content.Presets | Preset loaded | User loads a saved preset |

---

## Listeners (L01-L99)

| ID | Name | Event Listened | Module | Description |
|----|------|----------------|--------|-------------|
| **L01** | `Logic.Message.OnGroupSizeChanged` | E02 (Group.SizeChanged) | Logic.Message | Rebuild message when group size changes (LF3M → LF2M) |
| **L02** | `Broadcaster.OnGroupSizeChanged` | E02 (Group.SizeChanged) | Logic.Broadcaster | Handle group size changes, convert to raid, auto-stop when full |
| **L03** | `Logic.Message.OnSelectionChanged` | E01 (Selection.Changed) | Logic.Message | Rebuild message when selection changes |
| **L06** | `UI.Dungeons.OnSelectionChanged` | E01 (Selection.Changed) | UI.Content.Dungeons | Update dungeons UI when selection changes |
| **L07** | `UI.Raids.OnSelectionChanged` | E01 (Selection.Changed) | UI.Content.Raids | Update raids UI when selection changes |
| **L08** | `UI.Quests.OnSelectionChanged` | E01 (Selection.Changed) | UI.Content.Quests | Update quests UI when selection changes |
| **L09** | `UI.Messaging.OnChannelsChanged` | E05 (Channels.Changed) | UI.Content.Messaging | Update messaging UI when channels change |
| **L10** | `UI.Messaging.OnSelectionChanged` | E01 (Selection.Changed) | UI.Content.Messaging | Update messaging UI when selection changes |
| **L11** | `UI.Presets.OnChanged` | E07 (Presets.Changed) | UI.Content.Presets | Update presets UI when presets list changes |
| **L16** | `AutoInvite.OnWhisper` | E04 (Chat.WhisperReceived) | Logic.AutoInvite | Process whispers for auto-invite |
| **L17** | `AutoInvite.OnLeaderChanged` | E03 (Group.LeaderChanged) | Logic.AutoInvite | Handle leader changes for auto-invite |

---

## Init Handlers (I01-I99)

**Note:** Init Handlers execute in **ID** order (I01, I02, I03...). Dependencies ensure a module waits for required modules.

| ID | Name | Module | Dependencies | Description |
|----|-----|--------|--------------|-------------|
| **I01** | `Core.Events` | Core.Events | - | Initialize WoW event listeners, register events (E02-E04), states (S10-S12) |
| **I02** | `Core.Persistent` | Core.Persistent | - | Initialize SavedVariables |
| **I03** | `Core.Utils` | Core.Utils | - | Initialize utility functions |
| **I06** | `Debug` | Components.Debug | - | Register debug command (C02) |
| **I07** | `Minimap` | Components.Minimap | - | Initialize minimap button |
| **I08** | `Components.DarkUI` | Components.DarkUI | - | Initialize dark UI theme |
| **I09** | `Components.WelcomePopup` | Components.WelcomePopup | - | Initialize welcome popup |
| **I11** | `MainFrame` | Logic.MainFrame | - | Register main frame command (C01) |
| **I12** | `Logic.Selection` | Logic.Selection | - | Register selection commands (C06-C17), event (E01), states (S01-S08) |
| **I13** | `Logic.Message` | Logic.Message | Logic.Selection, Logic.Group, Core.Events | Register message listeners (L01, L03), state (S16) |
| **I14** | `Logic.Broadcaster` | Logic.Broadcaster | Logic.Message, Logic.Content.Messaging, Core.Events | Initialize broadcaster, register command (C21), states (S20-S25), listener (L02) |
| **I15** | `Logic.Content.Settings` | Logic.Content.Settings | Core.Persistent | Initialize settings panel, register state (S30), load dry run from persistent |
| **I16** | `Logic.Content.Messaging` | Logic.Content.Messaging | Core.Persistent | Initialize messaging, register command (C23), event (E05), state (S15) |
| **I17** | `Logic.Content.Presets` | Logic.Content.Presets | Core.Persistent, Logic.Selection | Initialize presets, register commands (C28-C30), events (E07-E08) |
| **I18** | `Logic.AutoInvite` | Logic.AutoInvite | Core.Events | Initialize auto-invite, register commands (C31-C32, C34), event (E06), listeners (L16-L17) |
| **I19** | `Logic.Content.Dungeons` | Logic.Content.Dungeons | - | Initialize dungeons cache builder |
| **I20** | `Logic.Group` | Logic.Group | Core.Events | Initialize group management logic |
| **I21** | `UI.MainFrame` | UI.MainFrame | - | Initialize main frame UI |
| **I22** | `UI.Dungeons` | UI.Content.Dungeons | - | Initialize dungeons UI, register listener (L06) |
| **I23** | `UI.Raids` | UI.Content.Raids | - | Initialize raids UI, register listener (L07) |
| **I24** | `UI.Quests` | UI.Content.Quests | - | Initialize quests UI, register command (C26-C27), listener (L08) |
| **I25** | `UI.Messaging` | UI.Content.Messaging | Logic.Content.Messaging, Logic.Broadcaster | Initialize messaging UI, register listeners (L09-L10) |
| **I26** | `Components.EyeAnimation` | Components.EyeAnimation | Logic.Broadcaster | Initialize eye animation system, auto-triggers on broadcast state change |
| **I27** | `UI.Content.Presets` | UI.Content.Presets | Logic.Content.Presets | Initialize presets UI, register listener (L11) |

---

## States (S01-S99)

| ID | Name | Module | Type | Default | Description |
|----|-----|--------|------|---------|-------------|
| **S01** | `Selection.Mode` | Logic.Selection | string | "none" | Current mode: "none", "dungeons", "raid", "custom" |
| **S02** | `Selection.Roles` | Logic.Selection | table | {} | Array of selected roles ("TANK", "HEAL", "DPS") |
| **S03** | `Selection.DungeonNames` | Logic.Selection | table | {} | Array of selected dungeon names (strings) |
| **S04** | `Selection.RaidName` | Logic.Selection | string/nil | nil | Selected raid name (nil if none) |
| **S05** | `Selection.RaidSize` | Logic.Selection | number | 40 | Custom raid size (1-40) |
| **S06** | `Selection.DetailsText` | Logic.Selection | string | "" | Details text appended to auto-generated messages |
| **S07** | `Selection.CustomMessage` | Logic.Selection | string | "" | Custom broadcast message text |
| **S08** | `Selection.CustomGroupSize` | Logic.Selection | number | 5 | Custom group size for custom messages with variables (1-40) |
| **S09** | - | - | - | - | *Spare* |
| **S10** | `Group.Type` | Logic.Group (declared in Core.Events) | string | "solo" | Current group type: "solo", "party", "raid" |
| **S11** | `Group.Size` | Logic.Group (declared in Core.Events) | number | 1 | Current group size (1-40) |
| **S12** | `Group.IsLeader` | Logic.Group (declared in Core.Events) | boolean | false | Is player party/raid leader |
| **S13** | - | - | - | - | *Spare* |
| **S14** | - | - | - | - | *Spare* |
| **S15** | `Channels.ActiveChannels` | Logic.Content.Messaging | table | {} | Array of active channel names |
| **S16** | `Message.ToBroadcast` | Logic.Message | string | "" | Generated broadcast message |
| **S17** | - | - | - | - | *Spare* |
| **S18** | - | - | - | - | *Spare* |
| **S19** | - | - | - | - | *Spare* |
| **S20** | `Broadcaster.IsRunning` | Logic.Broadcaster | boolean | false | Is broadcaster currently active |
| **S21** | `Broadcaster.Interval` | Logic.Broadcaster | number | 60 | Broadcast interval in seconds (30-7200, configurable via UI slider) |
| **S22** | `Broadcaster.MessagesSent` | Logic.Broadcaster | number | 0 | Number of messages sent this session |
| **S23** | `Broadcaster.SessionStartTime` | Logic.Broadcaster | number | 0 | GetTime() when broadcast started |
| **S24** | `Broadcaster.LastBroadcastTime` | Logic.Broadcaster | number | 0 | GetTime() when last message was sent |
| **S25** | `Broadcaster.TimeRemaining` | Logic.Broadcaster | number | 0 | Seconds until next broadcast |
| **S26** | - | - | - | - | *Spare* |
| **S27** | - | - | - | - | *Spare* |
| **S28** | - | - | - | - | *Spare* |
| **S29** | - | - | - | - | *Spare* |
| **S30** | `Settings.DryRun` | Logic.Content.Settings | boolean | false | Dry run mode enabled/disabled (broadcasts print to chat instead of sending) |

---

## Naming Conventions

### Commands (C)
- Format: `Module.Action`
- Examples: `Selection.ToggleDungeon`, `MainFrame.Toggle`, `Debug.Toggle`
- Action verbs: Toggle, Clear, Set, Refresh, Show, Hide

### Events (E)
- Format: `Module.Changed` or `Module.EventName`
- Examples: `Selection.Changed`, `Group.SizeChanged`, `Chat.WhisperReceived`
- Suffixes: Changed, Opened, Closed, Received, Sent

### Listeners (L)
- Format: `Module.OnEventName`
- Examples: `Message.OnSelectionChanged`, `Broadcaster.OnGroupSizeChanged`
- Prefix: On (indicates it reacts to an event)

### Init Handlers (I)
- Format: `Module.SubModule` or simply `Module`
- Examples: `Logic.Selection`, `UI.Content.Dungeons`

### States (S)
- Format: `Module.PropertyName`
- Examples: `Selection.Mode`, `Message.ToBroadcast`, `Broadcaster.IsActive`
- PascalCase for PropertyName

---

## Usage in Code

### Register with Explicit ID (RECOMMENDED)
```lua
-- Command
RegisterCommand("Selection.ToggleDungeon", handler, { id = "C03" })

-- Event
RegisterEvent("Selection.Changed", { id = "E01" })

-- Listener
Listen("Message.OnSelectionChanged", "Selection.Changed", callback, { id = "L05" })

-- Init
SafeRegisterInit("Logic.Selection", handler, { id = "I07" })

-- State
RegisterState("Selection.Mode", "none", { id = "S01" })
```

### Auto-generate ID (not recommended for documentation)
```lua
-- Without ID, Maestro auto-generates E01, E02, etc.
RegisterEvent("Selection.Changed")  -- Auto: E01
RegisterEvent("Group.SizeChanged")  -- Auto: E02
```

---

## Special Implementation Notes

### Debug Window & Checkbox Synchronization (C02 / UI.Content.Settings)

The debug window checkbox in the Settings panel is kept synchronized with the actual debug window state:

**Behaviors:**
1. **Tab Switch**: When switching to the Settings tab, the checkbox reflects whether the debug window is actually open (via `SyncDebugCheckbox()` in `RestoreState()`)
2. **Command `/lfm debug`**: Dispatches `Debug.Toggle` → calls `Show()` or `Hide()` → calls `SyncSettingsCheckbox(true/false)` to update the checkbox
3. **Close Button**: The X button calls `Hide()` → calls `SyncSettingsCheckbox(false)` to uncheck the checkbox
4. **Frame OnHide**: Even if the frame is hidden externally, the `OnHide` script triggers `Hide()` → checkbox is unchecked

**Implementation Details:**
- `Components.Debug.Show()`: Calls `SyncSettingsCheckbox(true)` before logging
- `Components.Debug.Hide()`: Calls `SyncSettingsCheckbox(false)` before logging
- `UI.Content.Settings.SyncDebugCheckbox()`: Reads the actual `AutoLFM_DebugWindow` frame state and sets checkbox accordingly
- `UI.Templates.Debug.xml OnHide`: Added to catch frame hide events and sync checkbox

**Code Locations:**
- Debug component: `Components/Debug.lua` (Show, Hide, SyncSettingsCheckbox)
- Settings UI: `UI/Content/Settings.lua` (OnDebugToggle, SyncDebugCheckbox, RestoreState)
- Debug template: `UI/Templates/Debug.xml` (OnHide script)

---

[← Back to README](README.md)