---
name: ddd-services
description: Distinguish domain services from application services and place logic correctly
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Domain Services vs Application Services

Two distinct service types serve different purposes in DDD. Misplacing logic between them is one of the most common DDD implementation mistakes.

## When to invoke

- Deciding where a piece of business logic belongs
- Reviewing whether a service is doing too much or too little
- Extracting logic that does not belong in an entity or value object

## Core concepts

### Domain Service

- Contains **domain logic** that does not naturally belong in a single entity or value object
- **Stateless** — no instance state; operates on domain objects passed as parameters
- Lives in the **domain layer** — no infrastructure imports, no application coordination
- Named after a domain concept, not a technical operation (`TransferService`, not `MoneyMover`)
- Examples: fund transfer between accounts, tax calculation, route optimization

### Application Service

- **Orchestrates** a use case: loads aggregates, calls domain logic, saves results, publishes events
- **Stateless** — coordinates, does not contain business rules
- Lives in the **application layer** — may import repositories, event publishers, and external services
- One method per use case; thin; delegates business logic to the domain
- Examples: `PlaceOrderService`, `RegisterCustomerService`

## Implementation checklist

**Domain Service:**
- [ ] The operation involves multiple domain objects and cannot belong to any single one
- [ ] No repository calls, no event publishing — domain logic only
- [ ] Parameters and return types are domain objects or value objects
- [ ] Named with a domain verb + noun (`PricingService.calculateDiscount`)

**Application Service:**
- [ ] Load required aggregates from repositories
- [ ] Invoke domain objects or domain services for all business logic
- [ ] Persist changed aggregates
- [ ] Publish domain events after successful persistence
- [ ] Handle transaction boundaries

## Review checklist

- [ ] Domain services contain no application coordination (no repository calls)
- [ ] Application services contain no business rules (they delegate everything)
- [ ] Business logic lives in entities, value objects, or domain services — not in application services
- [ ] Application services are thin orchestrators

## Common mistakes

- Putting business rules in Application Services (the "anemic domain model" smell)
- Calling repositories from Domain Services
- Creating a "service" for every entity just to avoid putting logic in the entity
- Making services stateful
