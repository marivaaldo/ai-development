---
name: ddd-cqrs
description: Separate read models from write models using Command Query Responsibility Segregation
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# CQRS

Command Query Responsibility Segregation separates the **write model** (commands that change state) from the **read model** (queries that return data). They are optimized independently.

## When to invoke

- Query requirements are complex and differ significantly from the write model structure
- Read and write performance must scale independently
- Using Event Sourcing (CQRS is a natural complement)
- Multiple query shapes are needed for the same underlying data

## Core concepts

- **Command side** — receives commands, validates them, executes domain logic via aggregates, persists state changes, emits events. Returns nothing or a command ID.
- **Query side** — read-only; returns view models (DTOs) optimized for each use case. No business logic — only projection and transformation.
- **Eventual consistency** — the read model is updated asynchronously from domain events; callers must tolerate a slight delay
- **Independent scaling** — commands and queries can be deployed, scaled, and optimized separately
- **Thin read models** — queries return flat, denormalized view models; no domain object reconstruction

## Implementation checklist

**Command side:**
- [ ] Each command is a named, immutable object (`PlaceOrderCommand`, `CancelOrderCommand`)
- [ ] Commands are validated before reaching the domain (format, authorization)
- [ ] Domain logic executes inside aggregates; Application Service orchestrates
- [ ] Emit domain events after successful state changes

**Query side:**
- [ ] Each query returns a dedicated view model (not a domain object)
- [ ] View models are built from projections updated by domain events (or direct DB reads)
- [ ] No business logic in query handlers — transform and return only
- [ ] Query handlers bypass the domain model; they read directly from optimized read stores

## Review checklist

- [ ] No query methods on the command side return domain state to callers
- [ ] No domain logic on the query side (no aggregate loading, no invariant checking)
- [ ] View models are flat and optimized for their specific use case
- [ ] Read model updates are driven by domain events, not direct write-side coupling

## Common mistakes

- Applying CQRS to every feature regardless of complexity (YAGNI)
- Returning domain aggregates from query handlers instead of view models
- Putting business logic in query handlers
- Making the read model synchronously consistent (defeats scalability benefits)
- Confusing CQRS with Event Sourcing — they complement each other but are independent
