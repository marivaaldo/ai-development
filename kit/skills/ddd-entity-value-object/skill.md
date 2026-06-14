---
name: ddd-entity-value-object
description: Distinguish entities from value objects and model each correctly
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Entity vs Value Object

The fundamental modeling choice: does this concept have **identity** (Entity) or is it defined entirely by its **attributes** (Value Object)?

## When to invoke

- Deciding whether a new domain concept needs an ID
- Reviewing whether a class should be mutable or immutable
- Modeling a concept that is "the same thing" despite having different data (Entity) vs "the same value" when data matches (Value Object)

## Core concepts

### Entity

- Has a **unique identity** that persists across state changes
- **Mutable** — state changes but identity remains
- Equality by **identity** (same ID = same entity, even if attributes differ)
- Has a **lifecycle** (created, modified, deleted)
- Examples: `Customer`, `Order`, `Employee`

### Value Object

- **No identity** — defined entirely by its attributes
- **Immutable** — never modified; replaced with a new instance
- Equality by **value** (same attributes = same value object)
- **Side-effect free** — methods return new instances, never mutate
- **Self-validating** — invariants enforced in the constructor
- Examples: `Money`, `Address`, `EmailAddress`, `DateRange`, `Coordinates`

## Implementation checklist

**For Entities:**
- [ ] Assign a stable, unique identity (UUID preferred over auto-increment integers)
- [ ] Protect invariants via the Aggregate Root that owns this entity
- [ ] Track meaningful state transitions (consider Domain Events)

**For Value Objects:**
- [ ] Make all fields `readonly` / `final` / immutable
- [ ] Implement structural equality (compare by attributes, not reference)
- [ ] Validate all invariants in the constructor; throw if invalid
- [ ] Return new instances from any "modification" method
- [ ] Make Value Objects the default choice — prefer them over entities when possible

## Review checklist

- [ ] Every entity has a meaningful, stable identity
- [ ] Value objects are immutable — no setters, no mutation
- [ ] Equality semantics match the domain concept (identity vs value)
- [ ] Value objects validate themselves at construction time
- [ ] The concept is modeled as a Value Object unless there is a genuine need for identity

## Common mistakes

- Adding IDs to value objects "just in case" (turns them into entities)
- Making value objects mutable for convenience
- Using primitive types (`String`, `int`) where a Value Object would carry more meaning
- Confusing database row identity with domain identity
