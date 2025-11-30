# Maestro ID System - Complete Reference


This document provides the complete reference for all Maestro registry IDs (Commands, Events, Listeners, States, Init Handlers). IDs are organized by functional domain with alphabetical ordering within each domain.

---

## Quick Reference

### ID Categories at a Glance

```
Commands:       C01-C24 (24 total)
Events:         E01-E10 (10 total)
Listeners:      L01-L13 (13 implemented)
States:         S01-S20 (20 total)
Init Handlers:  I01-I30 (30 total: 24 static + 3 auto-assigned dynamic)

TOTAL: 97 implemented IDs across 5 categories
```

### System Data Flow

```
User Action → Command Handler → State Change → Event → Listeners → UI Update
    (C##)          Logic           (S##)        (E##)     (L##)    Updates
```

---

## Commands (23 Implemented: C01-C24)

### Core Commands
| ID | Name | Module | Purpose |
|----|------|--------|---------|
| C01 | MainFrame.Toggle | Logic.MainFrame | Toggle main UI window |
| C02 | Debug.Toggle | Components.Debug | Toggle debug window |

### Selection Commands (Alphabetically organized)
| ID | Name | Module | Purpose |
|----|------|--------|---------|
| C03 | Selection.ClearAll | Logic.Selection | Clear all selections |
| C04 | Selection.ClearCustomMessage | Logic.Selection | Clear custom message |
| C05 | Selection.ClearDungeons | Logic.Selection | Clear dungeon selections |
| C06 | Selection.ClearRaid | Logic.Selection | Clear raid selection |
| C07 | Selection.ClearRoles | Logic.Selection | Clear role selections |
| C08 | Selection.SetCustomGroupSize | Logic.Selection | Set custom group size |
| C09 | Selection.SetCustomMessage | Logic.Selection | Set custom message template |
| C10 | Selection.SetDetailsText | Logic.Selection | Add details text to message |
| C11 | Selection.SetRaidSize | Logic.Selection | Set raid size |
| C12 | Selection.ToggleDungeon | Logic.Selection | Toggle dungeon selection |
| C13 | Selection.ToggleRaid | Logic.Selection | Toggle raid selection |
| C14 | Selection.ToggleRole | Logic.Selection | Toggle role requirement (TANK/HEAL/DPS) |

### Broadcasting Commands
| ID | Name | Module | Purpose |
|----|------|--------|---------|
| C15 | Broadcaster.Toggle | Logic.Broadcaster | Start/stop broadcaster |
| C16 | Channels.ToggleChannel | Logic.Content.Messaging | Toggle individual channel |

### Preset Commands (Alphabetically organized)
| ID | Name | Module | Purpose |
|----|------|--------|---------|
| C17 | Presets.Delete | Logic.Content.Presets | Delete a saved preset |
| C18 | Presets.Load | Logic.Content.Presets | Load a saved preset |
| C19 | Presets.Save | Logic.Content.Presets | Save current state as preset |

### Quest Commands
| ID | Name | Module | Purpose |
|----|------|--------|---------|
| C20 | Quests.Toggle | Logic.Content.Quests | Toggle quest selection |
| C21 | QuestsList.Refresh | UI.Content.Quests | Refresh quest list UI |

### Auto Invite Commands (Alphabetically organized)
| ID | Name | Module | Purpose |
|----|------|--------|---------|
| C22 | AutoInvite.Disable | Logic.Content.AutoInvite | Disable auto-invite |
| C23 | AutoInvite.Enable | Logic.Content.AutoInvite | Enable auto-invite |
| C24 | AutoInvite.ToggleConfirm | Logic.Content.AutoInvite | Toggle confirmation requirement |

---

## Events (E01-E10)

| ID | Event | Triggered By | Payload |
|----|-------|--------------|---------|
| E01 | Selection.Changed | Selection changes | mode, dungeons, raid, roles |
| E02 | Group.SizeChanged | Player joins/leaves | size |
| E03 | Group.TypeChanged | Group converted to raid | type (solo/party/raid) |
| E04 | Channels.Changed | Channel config updated | channels |
| E05 | Broadcaster.StateChanged | Broadcaster starts/stops | isRunning |
| E06 | Presets.ListChanged | Preset saved/deleted | presets |
| E07 | Message.Generated | Message rebuilt | message |
| E08 | Settings.Changed | Settings updated | setting, value |
| E09 | AutoInvite.Enabled | Auto-invite enabled | - |
| E10 | AutoInvite.Disabled | Auto-invite disabled | - |

---

## Listeners (L01-L13)

Listeners are registered ONLY in Init Handlers, never at file load.

| ID | Listener ID | Module | Listens To | Purpose |
|----|------------|--------|-----------|---------|
| L01 | Logic.Selection.OnSelectionChanged | Logic.Selection | Selection.Changed (E01) | React to selection changes |
| L02 | Logic.Message.OnSelectionChanged | Logic.Message | Selection.Changed (E01) | Rebuild message |
| L03 | Logic.Message.OnGroupSizeChanged | Logic.Message | Group.SizeChanged (E02) | Update message |
| L04 | Logic.Selection.OnCacheInvalidation | Logic.Selection | Selection.Changed (E01) | Invalidate cache |
| L05 | Logic.Broadcaster.OnSelectionChanged | Logic.Broadcaster | Selection.Changed (E01) | Update broadcaster |
| L06 | Logic.Broadcaster.OnGroupChanged | Logic.Broadcaster | Group events (E02-E03) | Update broadcaster |
| L07 | UI.Content.MainFrame.OnStateChanged | UI.Content.MainFrame | All events | Refresh UI |
| L08 | UI.Messaging.OnChannelsChanged | UI.Content.Messaging | Channels.Changed (E04) | Update channel UI |
| L09 | UI.Presets.OnChanged | UI.Content.Presets | Presets.Changed (E06) | Update presets UI |
| L10 | UI.Content.Settings.OnSettingsChanged | UI.Content.Settings | Settings.Changed (E08) | Update settings UI |
| L11 | UI.Messaging.OnSelectionChanged | UI.Content.Messaging | Selection.Changed (E01) | Update message UI |
| L12 | Logic.AutoInvite.OnBroadcast | Logic.Content.AutoInvite | Broadcaster events | Monitor for invites |
| L13 | UI.Content.AutoInvite.OnAutoInviteChanged | UI.Content.AutoInvite | AutoInvite events | Update auto-invite UI |

---

## States (S01-S20)

### Selection States (S01-S08)
| ID | State | Type | Purpose |
|----|-------|------|---------|
| S01 | Selection.CustomGroupSize | number | Target size for custom mode (1-40) |
| S02 | Selection.CustomMessage | string | Custom message template |
| S03 | Selection.DetailsText | string | Additional details text |
| S04 | Selection.DungeonNames | table | Array of selected dungeon names |
| S05 | Selection.Mode | string | Current mode: "dungeons", "raid", "custom", or "none" |
| S06 | Selection.RaidName | string\|nil | Selected raid name |
| S07 | Selection.RaidSize | number | Selected raid size (20-40) |
| S08 | Selection.Roles | table | Selected roles: {"TANK"}, {"HEAL"}, {"DPS"}, or combinations |

### Group States (S09-S11)
| ID | State | Type | Purpose |
|----|-------|------|---------|
| S09 | Group.IsLeader | boolean | Is player leader? |
| S10 | Group.Size | number | Current group size (1-40) |
| S11 | Group.Type | string | "solo", "party", or "raid" |

### Broadcasting States (S12-S17)
| ID | State | Type | Purpose |
|----|-------|------|---------|
| S12 | Broadcaster.Interval | number | Seconds between broadcasts (30-120) |
| S13 | Broadcaster.IsRunning | boolean | Broadcaster active? |
| S14 | Broadcaster.LastBroadcastTime | number | Unix timestamp of last broadcast |
| S15 | Broadcaster.MessagesSent | number | Count of messages sent in session |
| S16 | Broadcaster.SessionStartTime | number | Unix timestamp of session start |
| S17 | Broadcaster.TimeRemaining | number | Seconds until next broadcast |

### Channels & Message (S18-S19)
| ID | State | Type | Purpose |
|----|-------|------|---------|
| S18 | Channels.ActiveChannels | table | Array of selected channel names |
| S19 | Message.ToBroadcast | string | Current broadcast message |

### Settings State (S20)
| ID | State | Type | Purpose |
|----|-------|------|---------|
| S20 | Settings.DryRun | boolean | Test mode without sending |

---

## Init Handlers (I01-I30)

Init Handlers run during addon initialization with dependency resolution. Static handlers have explicit IDs (I01-I27), while dynamic content panels use auto-assignment (I28+).

### Core Foundation (I01-I04)
| ID | Module | Dependencies | Purpose |
|----|--------|--------------|---------|
| I01 | Core.Events | None | Initialize event system |
| I02 | Core.Storage | None | Initialize persistent storage |
| I03 | Core.API | Core.Storage | Initialize external API |
| I04 | Core.Utils | None | Initialize utilities |

### Logic Workflow (I05-I10)
| ID | Module | Dependencies | Purpose |
|----|--------|--------------|---------|
| I05 | Logic.Selection | Core.Events | Selection logic |
| I06 | Logic.Content.Dungeons | Logic.Selection | Dungeon integration |
| I07 | Logic.Group | Core.Events | Group tracking |
| I08 | Logic.Message | Logic.Selection, Logic.Group | Message builder |
| I09 | Logic.Broadcaster | Logic.Message | Broadcaster system |
| I10 | Logic.Content.Messaging | Core.Events | Channel management |

### Content & Settings (I11-I18)
| ID | Module | Dependencies | Purpose |
|----|--------|--------------|---------|
| I11 | UI.MainFrame | Logic.Broadcaster, Logic.Message, Logic.Selection | Main UI frame |
| I12 | Logic.Content.Presets | Core.Storage, Logic.Selection | Preset system |
| I13 | Logic.Content.Settings | Core.Storage | Settings logic |
| I14 | Components.DarkUI | Core.Storage | Dark mode theme |
| I15 | UI.Content.Messaging | Logic.Content.Messaging, Logic.Broadcaster | Channel UI |
| I16 | Logic.AutoInvite | Core.Events | Auto-invite system |
| I17 | Core.Settings | Core.Storage | Settings core |
| I18 | UI.Content.Presets | Logic.Content.Presets | Presets UI |

### UI Components (I19-I27)
| ID | Module | Dependencies | Purpose |
|----|--------|--------------|---------|
| I19 | UI.Quests.Commands | UI.Content.Quests | Quest command registration |
| I20 | Components.EyeAnimation | Logic.Broadcaster | Eye animation effect |
| I21 | Components.WelcomePopup | Core.Storage | Welcome dialog |
| I22 | Components.Debug | None | Debug window UI |
| I25 | Logic.MainFrame | Logic.Broadcaster, Logic.Message, Logic.Selection | Main window commands |
| I26 | Components.DataBroker | Core.Events | LibDataBroker integration |
| I27 | Components.MinimapButton | Core.Storage | Minimap button |

### Dynamic Content Panels (I28-I30) - Auto-assigned by ContentPanel factory
| ID | Module | Dependencies | Purpose |
|----|--------|--------------|---------|
| I28 | UI.Content.Dungeons | Logic.Selection | Dungeon selection UI |
| I29 | UI.Content.Raids | Logic.Selection | Raid selection UI |
| I30 | UI.Content.Quests | Logic.Selection | Quest selection UI |

---

## ID Organization by Domain

### 1. Selection System
**Manage dungeon, raid, quest, custom selections**
- **Init:** I05-I06
- **Commands:** C03-C14 (12 operations)
- **Events:** E01
- **States:** S01-S08
- **Listeners:** L01, L04

### 2. Group Management
**Track player group status**
- **Init:** I07
- **Events:** E02-E03
- **States:** S09-S11
- **Listeners:** L06

### 3. Message System
**Generate and manage LFM messages**
- **Init:** I08
- **Events:** E07
- **States:** S12
- **Listeners:** L02-L03, L07

### 4. Broadcasting
**Send messages to chat channels**
- **Init:** I09-I10
- **Commands:** C15-C16 (2 operations)
- **Events:** E04-E05
- **States:** S13-S19
- **Listeners:** L05, L08

### 5. Presets
**Save and load configurations**
- **Init:** I12, I19
- **Commands:** C17-C19 (3 operations)
- **Events:** E05-E06
- **States:** S18
- **Listeners:** L11

### 6. Auto Invite
**Automatic group invitations**
- **Init:** I16
- **Commands:** C22-C24 (3 operations)
- **Events:** E09-E10
- **Listeners:** L12-L13

### 7. Settings & Configuration
**User preferences and behavior**
- **Init:** I13, I18
- **Events:** E08
- **States:** S20
- **Listeners:** L10

### 8. Core Foundation
**System initialization and utilities**
- **Init:** I01-I04
- **Commands:** C01-C02

### 9. Channels & Messaging
**Chat integration and messaging**
- **Init:** I10, I15
- **Commands:** C16, C20-C21 (3 operations)
- **Events:** E04, E07

### 10. UI Panels (Dynamic)
**Auto-assigned UI content panels via ContentPanel factory**
- **Init:** I28-I30 (Dungeons, Raids, Quests)
- Auto-assigned in load order without hardcoding

### 11. Components & UI
**Visual components and debug tools**
- **Init:** I11, I14, I19-I21, I25-I27

---

## Adding New Components

### Process

1. **Identify domain** - Which functional area?
2. **Choose category** - Need Command? Event? State? Listener? Handler?
3. **Find next ID** - Check current max in that category
4. **Register** - Use the new ID in registration
5. **Document** - Update this file in appropriate section

### Example: New Command

```lua
-- Determine next available ID (C31 is current max, so use C32)
AutoLFM.Core.Maestro.RegisterCommand("MyFeature.DoAction", function()
    -- Implementation
end, { id = "C32" })
```

### Example: New State

```lua
-- Determine next available ID (S20 is current max, so use S21)
AutoLFM.Core.SafeRegisterState("MyFeature.Config", defaultValue, { id = "S21" })
```

### Example: New Static Init Handler

```lua
-- For static handlers, use next available ID in I01-I27 range
-- Current max is I27, so use I28 would be for dynamic (ContentPanel) only
-- For new static handlers, find next gap in I01-I27
AutoLFM.Core.SafeRegisterInit("MyFeature.Init", function()
    -- Initialization
end, {
    id = "I31",  -- Next available static ID after I27
    dependencies = { "Core.Events" }
})
```

### Example: New Content Panel (Auto-assigned ID)

```lua
-- ContentPanel factory automatically assigns IDs starting at I28
-- No need to specify listenerInitHandler - it's auto-assigned
AutoLFM.UI.Content.MyPanel = AutoLFM.UI.CreateContentPanel({
  name = "MyPanel",
  rowTemplatePrefix = "AutoLFM_MyRow",
  createRowsFunc = function(scrollChild) ... end,
  listeningEvent = "Selection.Changed",
  listenerDependencies = { "Logic.Selection" },
  listenerId = "L14"
  -- listenerInitHandler is auto-assigned (I28, I29, I30, etc)
})
```

---

## ID Assignment Rules

1. **Immutable** - Never change an ID after it's used
2. **Sequential** - Static IDs (I01-I27) are explicit; dynamic IDs (I28+) auto-assign
3. **Organized** - IDs grouped by functional domain
4. **Separated** - Each category has its own namespace
5. **Ordered** - Init handlers execute in approximate order with dependency resolution
6. **Auto-assignment** - ContentPanel factory auto-assigns IDs starting at I28 (no hardcoding)

---

## Related Documentation

- [Registry-and-Components.md](Registry-and-Components.md) - Component organization principles
- [Maestro-Architecture.md](Maestro-Architecture.md) - System architecture
- [Best-Practices.md](Best-Practices.md) - Development standards
- [API.md](API.md) - Public API for external addons
- [README.md](README.md) - Developer guide and quick start
