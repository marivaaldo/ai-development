---
name: ca-screaming-architecture
description: Ensure folder and module structure reveals domain intent, not framework choices
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Screaming Architecture

A well-structured system "screams" its purpose. The top-level structure of the codebase should tell a reader what the system does — not which framework it uses. If the top-level directories say `controllers/`, `models/`, and `views/`, the architecture screams "MVC" rather than the actual domain.

## When to invoke

- Designing the folder/package structure of a new system or feature
- Reviewing whether existing structure reveals or hides domain intent
- Onboarding a new developer and evaluating what the structure communicates

## Core concepts

- **Screams domain, not framework** — top-level structure reflects business capabilities, not technical layers
- **Framework is a detail** — routes, controllers, templates are implementation details, placed inside domain packages, not at the top level
- **Use cases are prominent** — the major use cases of the system should be visible in the structure
- **Enables framework substitution** — if the framework changed tomorrow, the domain structure would remain

## Good vs bad structure

**Screams framework (bad):**
```
src/
  controllers/
  models/
  services/
  repositories/
  views/
```

**Screams domain (good):**
```
src/
  billing/
    PlaceOrder.ts          ← use case
    Order.ts               ← entity
    OrderRepository.ts     ← interface
    web/OrderController.ts ← adapter
  inventory/
  customer/
```

## Implementation checklist

- [ ] Top-level directories are named after domain concepts or business capabilities
- [ ] Use case names are visible in the folder/file names (not buried under `services/`)
- [ ] Framework-specific files (controllers, routes, templates) are nested inside domain directories or in a dedicated `web/` folder
- [ ] A new developer can enumerate the system's main use cases from the directory tree alone
- [ ] Renaming or removing the framework would not force renaming top-level directories

## Review checklist

- [ ] Top-level folder names describe the domain, not the technology
- [ ] Use cases are identifiable by name in the file structure
- [ ] No framework-specific directory (e.g., `controllers/`) at the top level
- [ ] The folder structure would survive a framework swap without domain-level restructuring

## Common mistakes

- Generating project structure from a framework scaffold and never reorganizing it
- Treating "by layer" organization as the only option (`services/`, `repositories/`, `controllers/`)
- Hiding the most important use cases inside deeply nested technical directories
- Believing that a flat structure with good file names is sufficient (domain grouping still matters at scale)
