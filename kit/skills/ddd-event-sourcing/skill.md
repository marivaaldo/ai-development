---
name: ddd-event-sourcing
description: Implement event sourcing — storing aggregate state as an immutable event log
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Event Sourcing

Instead of storing the current state of an aggregate, store the **sequence of domain events** that led to that state. Current state is derived by replaying events from the beginning (or from a snapshot).

## When to invoke

- The business requires a full audit trail of all state changes
- Historical state at any point in time must be queryable
- Complex undo/redo or time-travel debugging is needed
- The system is already using Domain Events heavily

## Core concepts

- **Event log as source of truth** — the database stores events, not current state
- **State by replay** — reconstruct aggregate state by applying events in order: `apply(event)` mutates state
- **Append-only** — events are never updated or deleted; past is immutable
- **Projections / Read models** — current state views are derived from the event stream and stored separately (CQRS pairing is natural)
- **Snapshots** — periodic state snapshots reduce replay cost for long-lived aggregates
- **Event schema versioning** — events must be versioned; old events must be upcasted to new schemas

## Implementation checklist

- [ ] Define one event type per meaningful state transition (not a generic `StateChanged`)
- [ ] Implement `apply(Event)` methods that mutate aggregate state without side effects
- [ ] Store events in an append-only event store (never update or delete rows)
- [ ] Load aggregates by replaying their event history (or from snapshot + subsequent events)
- [ ] Build read models as projections from event streams (update on each event)
- [ ] Version all event schemas and implement upcasters for schema evolution
- [ ] Implement snapshots when aggregate history grows large (configurable threshold)

## Review checklist

- [ ] No current-state table for the aggregate — the event log is the only write store
- [ ] `apply()` methods are pure — they only update state, no side effects, no I/O
- [ ] All events are immutable value types with timestamps and sequence numbers
- [ ] Read models are rebuilt from events — no joins back to the event store at query time
- [ ] Event schema changes are handled via upcasting, not in-place migration

## Common mistakes

- Using event sourcing for every aggregate regardless of need (adds complexity without benefit)
- Mixing command handling logic inside `apply()` methods
- Storing events without version numbers (breaks schema evolution)
- Skipping projections and querying the event store directly for reads
- Not planning for event schema evolution from the start
