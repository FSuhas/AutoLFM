# AutoLFM - Developer Guide

## 📚 Documentation Overview

This guide provides entry points to AutoLFM's development documentation:

| Document | Purpose |
|----------|----------|
| [**Maestro-Architecture.md**](Maestro-Architecture.md) | Complete guide to the Maestro architecture |
| [**Best-Practices.md**](Best-Practices.md) | Lua 5.0 compatibility and coding standards |
| [**Registry-and-Components.md**](Registry-and-Components.md) | Registry system, state management patterns, and component reference |
| [**API.md**](API.md) | Public API documentation for external addon integration |

## 🚀 Quick Start

### 1. Understanding Maestro
Read [**Maestro-Architecture.md**](Maestro-Architecture.md) to understand the command bus architecture that powers AutoLFM.

### 2. Coding Standards
Read [**Best-Practices.md**](Best-Practices.md) for Lua 5.0 compatibility rules and development guidelines.

### 3. Component Management
Read [**Registry-and-Components.md**](Registry-and-Components.md) to learn how the registry system works, state management patterns, and view the complete component reference.

### 4. External Integration
Check [**API.md**](API.md) for the public API documentation to integrate AutoLFM with other addons.

## 🎯 Maestro Quick Reference

### Core Components
- **Commands (C##)**: User actions - `Dispatch("Selection.ToggleDungeon", name)`
- **Events (E##)**: Notifications - `EmitEvent("Selection.Changed")`
- **States (S##)**: Data store - `GetState("Selection.Mode")`
- **Listeners (L##)**: Event handlers - registered in Init Handlers only
- **Init Handlers (I##)**: Module initialization with dependencies

### Data Flow
```
User Action → Command → State Change → Event → UI Update
```

### Essential Rules
1. **All components need unique IDs** (C01, E01, L01, S01, I01...)
2. **Listeners ONLY in Init Handlers** - never at file load
3. **States are single source of truth** - don't duplicate data
4. **Commands are the only way to modify state**
5. **Update Registry-and-Components.md** when adding components

## 🔧 Development Workflow

1. **Plan** - Identify required C/E/L/S/I components
2. **Logic** - Implement business logic and state management
3. **UI** - Create user interface and synchronization
4. **Listeners** - Add event handlers for reactivity
5. **Registry** - Update Registry-and-Components.md with new IDs
6. **Test** - Use `/lfm debug` to verify registration

## 📁 Project Structure

```
AutoLFM/
├── Core/           # Framework (Maestro, Events, Utils)
├── Components/     # Reusable components (Debug, MinimapButton)
├── Logic/          # Business logic and state management
├── UI/             # User interface handlers and templates
└── _Docs/          # Documentation
    ├── Installation-Usage.md  # User guide and troubleshooting
    └── Dev/                   # Developer documentation
        ├── README.md
        ├── Maestro-Architecture.md
        ├── Best-Practices.md
        ├── Registry-and-Components.md
        ├── API.md
        └── Documentation-Structure.md
```

---

**For detailed information, follow the links to the specific documentation files above.**