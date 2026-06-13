---
name: ca-dependency-rule
description: Enforce the Clean Architecture dependency rule across all layers
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# The Dependency Rule

The central rule of Clean Architecture: **source code dependencies must point only inward**, toward higher-level policy. Nothing in an inner layer may know anything about an outer layer.

## Layers (outer → inner)

```
Frameworks & Drivers        (outermost — web, database, UI, external services)
      ↓
Interface Adapters          (controllers, presenters, gateways, repository implementations)
      ↓
Use Cases / Application     (application-specific business rules, interactors)
      ↓
Entities / Domain           (enterprise business rules — innermost, most stable)
```

The arrows show allowed dependency direction. **Inner layers must never import from outer layers.**

## When to invoke

- Adding a new dependency between two classes and checking if the direction is correct
- Reviewing whether domain or use-case code imports framework or infrastructure types
- Deciding where to place a new class in the architecture

## Core concepts

- **Entities** — enterprise-wide business rules; plain objects with no framework imports
- **Use Cases** — application-specific rules; orchestrate entities; define input/output port interfaces
- **Interface Adapters** — convert data between use case format and external format (controllers, presenters, repository implementations)
- **Frameworks & Drivers** — the outermost details: web framework, ORM, message broker, UI

**Crossing boundaries:** data crossing a boundary must be a simple data structure (DTO, plain struct, primitive) — never a domain entity or a framework type.

## Implementation checklist

- [ ] Entities import nothing from outer layers (no framework annotations, no ORM)
- [ ] Use cases import only entities and their own port interfaces — no adapters, no frameworks
- [ ] Interface adapters import use case interfaces and implement them — not the other way around
- [ ] Frameworks are wired at the outermost layer (e.g., dependency injection container)
- [ ] Data crossing boundaries is a simple struct or DTO, never a domain entity
- [ ] Apply Dependency Inversion when an inner layer needs to call an outer layer (define interface inward, implement outward)

## Review checklist

- [ ] No `import framework.*` or `import orm.*` in entity or use case classes
- [ ] No domain entity types appear in controllers, presenters, or framework code
- [ ] Use case output ports are interfaces defined in the use case layer, implemented in adapters
- [ ] The dependency graph has no inward-pointing arrows (outer layers do not appear in inner layer imports)

## Common mistakes

- Annotating domain entities with ORM/framework annotations (JPA, ActiveRecord, Spring)
- Returning domain entities from controllers or presenters to the UI
- Use cases directly calling repository implementations instead of through an interface
- Passing framework request objects (HttpServletRequest, Express Request) into use cases
