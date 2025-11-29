# AutoLFM - Developer Guide

## 📚 Documentation Overview

This guide provides entry points to AutoLFM's development documentation:

| Document | Purpose |
|----------|----------|
| [**Maestro-Architecture.md**](Guide/Maestro-Architecture.md) | Complete guide to the Maestro architecture |
| [**Best-Practices.md**](Guide/Best-Practices.md) | Lua 5.0 compatibility and coding standards |
| [**Registry-System.md**](Guide/Registry-System.md) | Registry system and state management patterns |
| [**Component-Registry.md**](Reference/Component-Registry.md) | Current registry of all C/E/L/S/I components with IDs |

## 🚀 Quick Start

### 1. Understanding Maestro
Read [**Maestro-Architecture.md**](Guide/Maestro-Architecture.md) to understand the command bus architecture that powers AutoLFM.

### 2. Coding Standards
Read [**Best-Practices.md**](Guide/Best-Practices.md) for Lua 5.0 compatibility rules and development guidelines.

### 3. Component Management
Read [**Registry-System.md**](Guide/Registry-System.md) to learn how the registry system works and state management patterns.

### 4. Component Reference
Check [**Component-Registry.md**](Reference/Component-Registry.md) for the actual list of all registered components with their current IDs.

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
5. **Update Component-Registry.md** when adding components

## 🔧 Development Workflow

1. **Plan** - Identify required C/E/L/S/I components
2. **Logic** - Implement business logic and state management
3. **UI** - Create user interface and synchronization
4. **Listeners** - Add event handlers for reactivity
5. **Registry** - Update Component-Registry.md with new IDs
6. **Test** - Use `/lfm debug` to verify registration

## 📁 Project Structure

```
AutoLFM/
├── Core/           # Framework (Maestro, Events, Utils)
├── Components/     # Reusable components (Debug, MinimapButton)
├── Logic/          # Business logic and state management
├── UI/             # User interface handlers and templates
└── _Docs/          # Documentation
    └── Dev/
        ├── Guide/          # Development guides
        │   ├── Maestro-Architecture.md
        │   ├── Best-Practices.md
        │   └── Registry-System.md
        └── Reference/      # Reference documentation
            └── Component-Registry.md
```

---

**For detailed information, follow the links to the specific documentation files above.**