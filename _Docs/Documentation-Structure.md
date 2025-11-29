# AutoLFM Documentation Structure

## Overview

AutoLFM documentation is organized in two main sections: **User Documentation** and **Developer Documentation**.

### For Users

**[Installation-usage.md](Installation-usage.md)** - Complete installation and usage guide
- Installation requirements and step-by-step instructions
- Feature usage and configuration
- Troubleshooting and support

### For Developers

**[Dev/README.md](Dev/README.md)** - Developer documentation entry point

**Development Guides** (_Dev/Guide/_):
- [Maestro-Architecture.md](Dev/Guide/Maestro-Architecture.md) - Understanding the CQRS command bus system
- [Best-Practices.md](Dev/Guide/Best-Practices.md) - Lua 5.0 compatibility and coding standards
- [Registry-System.md](Dev/Guide/Registry-System.md) - Component registration and state management

**Reference** (_Dev/Reference/_):
- [Component-Registry.md](Dev/Reference/Component-Registry.md) - Complete list of all registered components with IDs

---

## Reading Paths

### Quick Start (Users)
1. [README.md](../README.md) - Project overview
2. [installation-usage.md](installation-usage.md) - Detailed instructions

### Quick Start (New Developers)
1. [Dev/README.md](Dev/README.md) - Developer overview
2. [Dev/Guide/Maestro-Architecture.md](Dev/Guide/Maestro-Architecture.md) - Understand the system
3. [Dev/Guide/Best-Practices.md](Dev/Guide/Best-Practices.md) - Learn coding standards
4. [Dev/Guide/Registry-System.md](Dev/Guide/Registry-System.md) - Component management
5. [Dev/Reference/Component-Registry.md](Dev/Reference/Component-Registry.md) - Reference lookup

### Quick Reference (Experienced Developers)
- Architecture: [Dev/Guide/Maestro-Architecture.md](Dev/Guide/Maestro-Architecture.md)
- Coding standards: [Dev/Guide/Best-Practices.md](Dev/Guide/Best-Practices.md)
- Component IDs: [Dev/Reference/Component-Registry.md](Dev/Reference/Component-Registry.md)
- State management: [Dev/Guide/Registry-System.md](Dev/Guide/Registry-System.md)

---

## File Organization

```
AutoLFM/
├── README.md                          (Project overview)
└── _Docs/
    ├── installation-usage.md          (User guide)
    ├── documentation-structure.md     (This file)
    └── Dev/
        ├── README.md                  (Developer entry point)
        ├── Guide/                     (Development guides)
        │   ├── Maestro-Architecture.md
        │   ├── Best-Practices.md
        │   └── Registry-System.md
        └── Reference/                 (Component reference)
            └── Component-Registry.md
```

---

## Key Principles

1. **All documentation is in English** for consistency
2. **Guides first** - Learn concepts before diving into reference
3. **Single source of truth** - Each component documented once
4. **Keep it current** - Update docs when adding new components

---

## Maintaining Documentation

When adding new Maestro components:
1. Update [Dev/Reference/Component-Registry.md](Dev/Reference/Component-Registry.md) with new IDs
2. Reference [Dev/Guide/Registry-System.md](Dev/Guide/Registry-System.md) for patterns
3. Follow naming conventions from [Dev/Guide/Best-Practices.md](Dev/Guide/Best-Practices.md)

For architecture changes:
- Update [Dev/Guide/Maestro-Architecture.md](Dev/Guide/Maestro-Architecture.md) with new patterns
- Update examples in related guide files
