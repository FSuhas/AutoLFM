# Maestro Component Registry

**Complete reference of all Maestro IDs (Commands, Events, Listeners, States, Init Handlers) used in AutoLFM.**

---

## Quick Reference

| Category | Range | Count | Purpose |
|----------|-------|-------|---------|
| **Commands** | C01-C99 | 24 | User actions and system operations |
| **Events** | E01-E99 | 8 | System notifications and state changes |
| **Listeners** | L01-L99 | 11 | Event handlers and cross-module communication |
| **States** | S01-S99 | 20 | Data storage and system state |
| **Init Handlers** | I01-I99 | 24 | Module initialization and dependency management |

---

## Commands (C01-C99)

| ID | Name | Module | Purpose |
|----|------|--------|---------|
| **C01** | `MainFrame.Toggle` | Logic.MainFrame | Toggle main window visibility |
| **C02** | `Debug.Toggle` | Components.Debug | Toggle debug window visibility |
| **C06** | `Selection.ToggleDungeon` | Logic.Selection | Toggle dungeon selection (FIFO max 3) |
| **C07** | `Selection.ToggleRaid` | Logic.Selection | Toggle raid selection (exclusive) |
| **C08** | `Selection.SetRaidSize` | Logic.Selection | Set custom raid size (1-40) |
| **C09** | `Selection.ToggleRole` | Logic.Selection | Toggle role selection (TANK/HEAL/DPS) |
| **C10** | `Selection.ClearRoles` | Logic.Selection | Clear all role selections |
| **C11** | `Selection.SetCustomMessage` | Logic.Selection | Set custom broadcast message |
| **C12** | `Selection.ClearCustomMessage` | Logic.Selection | Clear custom message |
| **C13** | `Selection.SetCustomGroupSize` | Logic.Selection | Set custom group size (1-40) |
| **C14** | `Selection.ClearDungeons` | Logic.Selection | Clear all dungeon selections |
| **C15** | `Selection.ClearRaid` | Logic.Selection | Clear raid selection |
| **C16** | `Selection.SetDetailsText` | Logic.Selection | Set details text (appended to messages) |
| **C17** | `Selection.ClearAll` | Logic.Selection | Clear all selections |
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

| ID | Name | Module | Emitted When |
|----|------|--------|-------------|
| **E01** | `Selection.Changed` | Logic.Selection | Any selection modified (dungeons/raids/roles/custom) |
| **E02** | `Group.SizeChanged` | Core.Events | PARTY_MEMBERS_CHANGED or RAID_ROSTER_UPDATE |
| **E03** | `Group.LeaderChanged` | Core.Events | PARTY_LEADER_CHANGED |
| **E04** | `Chat.WhisperReceived` | Core.Events | CHAT_MSG_WHISPER (for Auto Invite) |
| **E05** | `Channels.Changed` | Logic.Content.Messaging | Any channel toggled |
| **E06** | `AutoInvite.Changed` | Logic.AutoInvite | Settings modified |
| **E07** | `Presets.Changed` | Logic.Content.Presets | Preset saved or deleted |
| **E08** | `Presets.Loaded` | Logic.Content.Presets | User loads a preset |

---

## Listeners (L01-L99)

| ID | Name | Listens To | Module | Purpose |
|----|------|------------|--------|---------|
| **L01** | `Logic.Message.OnGroupSizeChanged` | E02 | Logic.Message | Rebuild message when group size changes |
| **L02** | `Broadcaster.OnGroupSizeChanged` | E02 | Logic.Broadcaster | Handle group changes, convert to raid, auto-stop |
| **L03** | `Logic.Message.OnSelectionChanged` | E01 | Logic.Message | Rebuild message when selection changes |
| **L06** | `UI.Dungeons.OnSelectionChanged` | E01 | UI.Content.Dungeons | Update dungeons UI when selection changes |
| **L07** | `UI.Raids.OnSelectionChanged` | E01 | UI.Content.Raids | Update raids UI when selection changes |
| **L08** | `UI.Quests.OnSelectionChanged` | E01 | UI.Content.Quests | Update quests UI when selection changes |
| **L09** | `UI.Messaging.OnChannelsChanged` | E05 | UI.Content.Messaging | Update messaging UI when channels change |
| **L10** | `UI.Messaging.OnSelectionChanged` | E01 | UI.Content.Messaging | Update messaging UI when selection changes |
| **L11** | `UI.Presets.OnChanged` | E07 | UI.Content.Presets | Update presets UI when presets list changes |
| **L16** | `AutoInvite.OnWhisper` | E04 | Logic.AutoInvite | Process whispers for auto-invite |
| **L17** | `AutoInvite.OnLeaderChanged` | E03 | Logic.AutoInvite | Handle leader changes for auto-invite |

---

## States (S01-S99)

| ID | Name | Module | Type | Default |
|----|------|--------|------|---------|
| **S01** | `Selection.Mode` | Logic.Selection | string | "none" |
| **S02** | `Selection.Roles` | Logic.Selection | table | {} |
| **S03** | `Selection.DungeonNames` | Logic.Selection | table | {} |
| **S04** | `Selection.RaidName` | Logic.Selection | string/nil | nil |
| **S05** | `Selection.RaidSize` | Logic.Selection | number | 40 |
| **S06** | `Selection.DetailsText` | Logic.Selection | string | "" |
| **S07** | `Selection.CustomMessage` | Logic.Selection | string | "" |
| **S08** | `Selection.CustomGroupSize` | Logic.Selection | number | 5 |
| **S10** | `Group.Type` | Logic.Group | string | "solo" |
| **S11** | `Group.Size` | Logic.Group | number | 1 |
| **S12** | `Group.IsLeader` | Logic.Group | boolean | false |
| **S15** | `Channels.ActiveChannels` | Logic.Content.Messaging | table | {} |
| **S16** | `Message.ToBroadcast` | Logic.Message | string | "" |
| **S20** | `Broadcaster.IsRunning` | Logic.Broadcaster | boolean | false |
| **S21** | `Broadcaster.Interval` | Logic.Broadcaster | number | 60 |
| **S22** | `Broadcaster.MessagesSent` | Logic.Broadcaster | number | 0 |
| **S23** | `Broadcaster.SessionStartTime` | Logic.Broadcaster | number | 0 |
| **S24** | `Broadcaster.LastBroadcastTime` | Logic.Broadcaster | number | 0 |
| **S25** | `Broadcaster.TimeRemaining` | Logic.Broadcaster | number | 0 |
| **S30** | `Settings.DryRun` | Logic.Content.Settings | boolean | false |

---

## Init Handlers (I01-I99)

| ID | Name | Module | Dependencies | Purpose |
|----|------|--------|--------------|---------|
| **I01** | `Core.Events` | Core.Events | - | Initialize WoW event listeners, register events |
| **I02** | `Core.Storage` | Core.Storage | - | Initialize SavedVariables |
| **I03** | `Core.API` | Core.API | - | Initialize API module |
| **I04** | `Core.Utils` | Core.Utils | - | Initialize utility functions |
| **I06** | `Debug` | Components.Debug | - | Register debug interface |
| **I07** | `Minimap` | Components.Minimap | - | Initialize minimap button |
| **I08** | `Components.DarkUI` | Components.DarkUI | - | Initialize dark UI theme |
| **I09** | `Components.WelcomePopup` | Components.WelcomePopup | - | Initialize welcome popup |
| **I11** | `MainFrame` | Logic.MainFrame | - | Register main frame command |
| **I12** | `Logic.Selection` | Logic.Selection | - | Register selection commands and events |
| **I13** | `Logic.Message` | Logic.Message | Logic.Selection, Logic.Group, Core.Events | Initialize message builder |
| **I14** | `Logic.Broadcaster` | Logic.Broadcaster | Logic.Message, Logic.Content.Messaging, Core.Events | Initialize broadcaster system |
| **I15** | `Logic.Content.Settings` | Logic.Content.Settings | Core.Storage | Initialize settings panel |
| **I16** | `Logic.Content.Messaging` | Logic.Content.Messaging | Core.Storage | Initialize messaging system |
| **I17** | `Logic.Content.Presets` | Logic.Content.Presets | Core.Storage, Logic.Selection | Initialize presets system |
| **I18** | `Logic.AutoInvite` | Logic.AutoInvite | Core.Events | Initialize auto-invite system |
| **I19** | `Logic.Content.Dungeons` | Logic.Content.Dungeons | - | Initialize dungeons cache |
| **I20** | `Logic.Group` | Logic.Group | Core.Events | Initialize group tracking |
| **I21** | `UI.MainFrame` | UI.MainFrame | - | Initialize main frame UI |
| **I22** | `UI.Dungeons` | UI.Content.Dungeons | - | Initialize dungeons UI |
| **I23** | `UI.Raids` | UI.Content.Raids | - | Initialize raids UI |
| **I24** | `UI.Quests` | UI.Content.Quests | - | Initialize quests UI |
| **I25** | `UI.Messaging` | UI.Content.Messaging | Logic.Content.Messaging, Logic.Broadcaster | Initialize messaging UI |
| **I26** | `Components.EyeAnimation` | Components.EyeAnimation | Logic.Broadcaster | Initialize eye animation |
| **I27** | `UI.Content.Presets` | UI.Content.Presets | Logic.Content.Presets | Initialize presets UI |

---

## Key Principles

1. **IDs are for documentation and reference only** - Code uses full names like `"Selection.ToggleDungeon"`, not IDs
2. **IDs are immutable** - Never change an assigned ID after it's been used
3. **Gaps in numbering are intentional** - Reserved for future features or domain organization
4. **Each category has its own namespace** - C01 and E01 can coexist without conflict
5. **Init handler order matters** - Handlers execute in roughly numerical order with dependencies resolved

---

## Adding New Components

When adding new Commands, Events, Listeners, States, or Init Handlers:

1. Find the next available ID in the appropriate range
2. Update this file with the new entry
3. Update documentation as needed
4. Use the ID in your registration: `{ id = "C42" }`

Example:
```lua
RegisterCommand("MyModule.DoSomething", function()
    -- Implementation
end, { id = "C42" })
```

---

## Related Documentation

- [Maestro-Architecture.md](../guide/Maestro-Architecture.md) - System design and patterns
- [Best-Practices.md](../guide/Best-Practices.md) - Development guidelines
- [Registry-System.md](../guide/Registry-System.md) - Registry and state management guide

---

[← Back to README](../README.md)
