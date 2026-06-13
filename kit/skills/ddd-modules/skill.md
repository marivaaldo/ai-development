---
name: ddd-modules
description: Organize domain code into cohesive modules that reflect the Ubiquitous Language
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Modules

Modules (packages, namespaces) are the organizational unit within a bounded context. They group related domain concepts together and communicate intent through their names — which must come from the Ubiquitous Language.

## When to invoke

- Organizing a bounded context into subdirectories or packages
- Reviewing whether current package structure reflects domain concepts or technical layers
- Deciding where a new class belongs within a bounded context
- A module is growing too large and needs to be subdivided

## Core concepts

- **Named by domain, not by layer** — prefer `com.example.ordering.pricing` over `com.example.service`
- **High cohesion** — objects in the same module change together and communicate frequently
- **Low coupling** — modules interact through well-defined interfaces, minimizing cross-module dependencies
- **Tell a story** — the list of modules in a bounded context should read like the domain model overview
- **Technical layers inside modules** — if needed, place technical sub-packages (e.g., `persistence`) inside domain modules, not the other way around

## Implementation checklist

- [ ] Name each module using Ubiquitous Language terms, not technical roles
- [ ] Group objects that change together and share the same invariants in the same module
- [ ] Expose only what other modules need; keep internals package-private when possible
- [ ] Avoid circular dependencies between modules
- [ ] Review module names with domain experts — they should recognize the names

## Review checklist

- [ ] Module names reflect domain concepts that domain experts would recognize
- [ ] No technical layer names as top-level modules (`services`, `repositories`, `controllers` at the top)
- [ ] Modules are cohesive — classes inside a module are related by domain concept, not by technical role
- [ ] Cross-module dependencies go through defined interfaces, not direct class references
- [ ] A new team member can infer the domain model outline from the module names alone

## Common mistakes

- Organizing everything by technical layer (`models/`, `services/`, `repositories/`) hiding the domain
- Creating one module per class (over-granulation) or one module for everything (under-granulation)
- Using generic names (`common/`, `shared/`, `util/`) as a dumping ground
- Circular dependencies between modules that should be separate concepts
- Not updating module organization as the domain model evolves
