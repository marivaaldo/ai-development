---
name: ddd-aggregate
description: Model aggregate roots, enforce invariants, and maintain transactional consistency
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Aggregate

A cluster of domain objects (entities and value objects) treated as a single unit for data changes. The **Aggregate Root** is the sole entry point; all invariants of the cluster are enforced within one transaction.

## When to invoke

- Modeling domain objects that must change together to stay consistent
- Deciding which objects belong in the same transactional boundary
- Reviewing whether an aggregate is too large or has too many responsibilities
- Designing consistency rules between domain objects

## Core concepts

- **Aggregate Root** — the only object external code may hold a reference to; it enforces all invariants
- **Transactional boundary** — all changes within one aggregate are committed atomically
- **Reference by identity** — aggregates reference other aggregates by ID, never by object reference
- **Small aggregates** — keep them small; large aggregates cause contention and complexity
- **Eventual consistency between aggregates** — use Domain Events to propagate state across aggregate boundaries

## Implementation checklist

- [ ] Identify all invariants that must be true at all times — these define the aggregate boundary
- [ ] Designate one entity as the Aggregate Root; all mutations go through it
- [ ] Remove direct object references to other aggregates; replace with IDs
- [ ] Make the root the only class loaded and saved by the Repository
- [ ] Emit Domain Events from the root when state changes that other aggregates need to know about
- [ ] Ask: "can this object exist without the root?" — if yes, it may belong to its own aggregate

## Review checklist

- [ ] External code only holds references to the Aggregate Root
- [ ] All business invariants are enforced inside the aggregate (no enforcement in services)
- [ ] No direct object references to other aggregates — IDs only
- [ ] The aggregate is as small as possible while still enforcing its invariants
- [ ] Changes to the aggregate produce Domain Events when cross-aggregate propagation is needed

## Common mistakes

- Large aggregates that include every related object (Order + OrderLines + Customer + Product)
- Holding object references to other aggregate roots instead of IDs
- Enforcing aggregate invariants in Application Services instead of inside the root
- Designing aggregates around database tables instead of around invariants
- Loading an entire aggregate graph when only part is needed
