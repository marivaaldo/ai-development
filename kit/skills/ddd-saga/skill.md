---
name: ddd-saga
description: Implement long-running processes and cross-aggregate workflows with sagas
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Saga / Process Manager

A **Saga** manages a long-running business process that spans multiple aggregates or bounded contexts. It coordinates a sequence of steps using domain events and commands, maintaining overall process consistency without distributed transactions.

## When to invoke

- A business operation involves multiple aggregates that cannot be in the same transaction
- A workflow spans multiple bounded contexts or external services
- Compensating actions are needed when a step in a multi-step process fails
- A process has observable intermediate states (e.g., `OrderPending`, `PaymentProcessing`, `OrderConfirmed`)

## Core concepts

### Choreography (event-driven, no central coordinator)
- Each service/aggregate listens to events and reacts independently
- Simple to implement for short chains; becomes hard to trace for long ones

### Orchestration / Process Manager (explicit coordinator)
- A dedicated Process Manager object tracks process state and issues commands
- Observable, testable, and explicit about what step the process is in
- Preferred for complex, multi-step workflows

**Key rules:**
- **Compensating transactions** — no rollback across services; design undo commands (`CancelReservation`, `RefundPayment`)
- **Idempotent steps** — each step can be retried safely
- **Process state is persisted** — the Saga/Process Manager stores its own state in a dedicated store
- **Time-outs** — handle steps that do not complete within an expected window

## Implementation checklist

- [ ] Name the saga after the business process (`OrderFulfillmentSaga`, `UserRegistrationProcess`)
- [ ] Define all steps and their expected events/commands
- [ ] Design compensating commands for each step that can fail
- [ ] Persist saga state after every transition (never hold state only in memory)
- [ ] Implement all event handlers and command dispatches as idempotent
- [ ] Add time-out handling for steps that may not complete
- [ ] Emit a process-completed or process-failed event when the saga terminates

## Review checklist

- [ ] Process state is durable — not held only in memory or in application cache
- [ ] Each step has a compensating command defined
- [ ] Event handlers are idempotent — safe to receive duplicate events
- [ ] The saga does not enforce aggregate invariants (delegates to aggregates)
- [ ] Time-outs are handled explicitly, not left to "eventually" resolve

## Common mistakes

- Putting business invariant logic inside the saga (invariants belong in aggregates)
- Using distributed transactions (2PC) instead of designing compensations
- Forgetting to persist saga state (loses process progress on restart)
- Not handling duplicate event delivery (non-idempotent handlers cause corruption)
- Mixing choreography and orchestration within the same process without clarity
