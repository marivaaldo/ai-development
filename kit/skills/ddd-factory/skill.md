---
name: ddd-factory
description: Encapsulate complex aggregate and domain object creation in factories
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Factory

A Factory encapsulates the creation of complex domain objects — aggregates, entities, or value objects — when the constructor alone is insufficient to express creation intent or enforce creation invariants.

## When to invoke

- A constructor requires more than 3–4 parameters or complex coordination
- Creating an aggregate requires fetching other domain objects
- Multiple valid creation paths exist for the same object (e.g., `fromDraft`, `fromTemplate`)
- Object creation requires domain logic that doesn't belong in a constructor

## Core concepts

- **Factory Method** — a static or instance method on the aggregate root or a related class that expresses creation intent (`Order.placeFor(customer, items)`)
- **Factory Object** — a separate class when creation is complex, requires dependencies, or coordinates multiple aggregates
- **Creation is domain logic** — factories enforce creation-time invariants; they should throw domain exceptions on invalid input
- **Factories are not repositories** — factories create new objects; repositories retrieve existing ones

## Implementation checklist

**Factory Method (preferred for simple cases):**
- [ ] Place on the aggregate root as a static method with a domain-meaningful name
- [ ] Validate all creation invariants; throw domain exceptions on failure
- [ ] Return a fully initialized, valid aggregate

**Factory Object (for complex cases):**
- [ ] Create a dedicated factory class in the domain layer
- [ ] Inject only domain services or interfaces — no direct infrastructure dependencies
- [ ] Express creation scenarios as distinct methods, not a single `create(params)` method

Both:
- [ ] The created object is valid and complete — no two-step initialization
- [ ] Creation logic is not duplicated in tests (use the same factory)

## Review checklist

- [ ] Constructors are protected/private when a factory is present
- [ ] All creation paths result in a valid, fully initialized object
- [ ] Creation-time invariants are checked inside the factory, not in the caller
- [ ] Factory class lives in the domain layer, with no infrastructure imports

## Common mistakes

- Using factories as a generic "builder" with optional fields and late validation
- Two-step initialization: creating an empty object then calling setters
- Putting factory logic in Application Services
- Having factories depend directly on infrastructure (ORM sessions, DB connections)
