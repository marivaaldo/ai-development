---
name: ddd-domain-event
description: Model, publish, and handle domain events for cross-aggregate communication
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Domain Event

Something that happened in the domain that domain experts care about. Domain Events are the primary mechanism for communicating state changes across aggregate boundaries without tight coupling.

## When to invoke

- A state change in one aggregate must trigger behavior in another
- Implementing eventual consistency between bounded contexts
- Auditing or logging domain state changes
- Designing an event-driven integration between systems

## Core concepts

- **Past tense naming** — events describe something that already happened: `OrderPlaced`, `PaymentFailed`, `CustomerRegistered`
- **Immutable** — events are facts; they are never modified after creation
- **Contain what happened** — include all data a subscriber needs to react without querying back
- **Raised by the aggregate root** — events are a consequence of successful domain operations
- **Published after persistence** — publish only after the aggregate is safely saved (outbox pattern recommended)
- **Idempotent handlers** — event handlers must be safe to execute more than once

## Implementation checklist

- [ ] Name the event in past tense using domain vocabulary
- [ ] Include: event ID, occurred-at timestamp, and all relevant domain data
- [ ] Raise the event inside the aggregate root method that causes the state change
- [ ] Collect events in the aggregate and publish them after the transaction commits
- [ ] Implement each handler to be idempotent (use event ID for deduplication)
- [ ] Consider the outbox pattern for reliable cross-service delivery

## Review checklist

- [ ] Event name is past tense and uses domain language (not technical language)
- [ ] Event carries enough data for subscribers to act without additional queries
- [ ] Events are raised inside aggregate methods, not in Application Services
- [ ] Event handlers do not assume events arrive exactly once
- [ ] Events are published only after the originating transaction commits

## Common mistakes

- Naming events in present tense (`OrderPlacing`) or imperative (`PlaceOrder`)
- Publishing events before the aggregate is persisted (phantom events on rollback)
- Putting event publishing logic inside the aggregate (aggregate should only raise, not publish)
- Making event handlers query back the aggregate instead of using event data
- Coupling handler logic to the event publisher (tight coupling defeats the purpose)
