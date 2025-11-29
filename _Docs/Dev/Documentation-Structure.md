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

**Development Guides** (_Dev/_):
- [Maestro-Architecture.md](Dev/Maestro-Architecture.md) - Understanding the CQRS command bus system
- [Best-Practices.md](Dev/Best-Practices.md) - Lua 5.0 compatibility and coding standards
- [Registry-and-Components.md](Dev/Registry-and-Components.md) - Component registration, state management, and complete component reference
- [API.md](Dev/API.md) - Public API documentation for external addon integration

---

## Reading Paths

### Quick Start (Users)
1. [README.md](../README.md) - Project overview
2. [installation-usage.md](installation-usage.md) - Detailed instructions

### Quick Start (New Developers)
1. [Dev/README.md](Dev/README.md) - Developer overview
2. [Dev/Maestro-Architecture.md](Dev/Maestro-Architecture.md) - Understand the system
3. [Dev/Best-Practices.md](Dev/Best-Practices.md) - Learn coding standards
4. [Dev/Registry-and-Components.md](Dev/Registry-and-Components.md) - Component management and reference lookup
5. [Dev/API.md](Dev/API.md) - Public API for external addons

### Quick Reference (Experienced Developers)
- Architecture: [Dev/Maestro-Architecture.md](Dev/Maestro-Architecture.md)
- Coding standards: [Dev/Best-Practices.md](Dev/Best-Practices.md)
- Component IDs & State: [Dev/Registry-and-Components.md](Dev/Registry-and-Components.md)
- Public API: [Dev/API.md](Dev/API.md)

---

## File Organization

```
AutoLFM/
├── README.md                          (Project overview)
└── _Docs/
    ├── Installation-Usage.md          (User guide)
    ├── Documentation-Structure.md     (This file)
    └── Dev/                           (Developer documentation)
        ├── README.md                  (Developer entry point)
        ├── Maestro-Architecture.md
        ├── Best-Practices.md
        ├── Registry-and-Components.md
        └── API.md
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
1. Update [Dev/Registry-and-Components.md](Dev/Registry-and-Components.md) with new IDs and component details
2. Reference [Dev/Registry-and-Components.md](Dev/Registry-and-Components.md) for patterns and state management
3. Follow naming conventions from [Dev/Best-Practices.md](Dev/Best-Practices.md)

For architecture changes:
- Update [Dev/Maestro-Architecture.md](Dev/Maestro-Architecture.md) with new patterns
- Update examples in related documentation files
