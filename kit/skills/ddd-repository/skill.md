---
name: ddd-repository
description: Implement collection-like persistence interfaces for aggregate roots
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Repository

A Repository mediates between the domain model and data mapping layers. It presents a **collection-like interface** for accessing aggregate roots, hiding all persistence details from the domain.

## When to invoke

- Implementing persistence access for an aggregate root
- Reviewing whether a class is leaking persistence concerns into the domain
- Designing query interfaces for domain objects
- Deciding where to place complex queries

## Core concepts

- **One repository per aggregate root** — not per entity or per table
- **Collection metaphor** — the interface looks like an in-memory collection (`add`, `remove`, `findById`)
- **Persistence ignorance** — the domain model knows nothing about how it is stored
- **Interface in domain, implementation outside** — the repository interface lives in the domain layer; the implementation lives in the infrastructure layer
- **Query methods are domain-language** — `findByCustomerId`, not `selectWhereCustomerIdEquals`

## Implementation checklist

- [ ] Define the repository interface in the domain layer (no imports from ORM/database)
- [ ] Name methods using domain vocabulary (`findActiveOrders`, not `queryByStatus`)
- [ ] Implement the interface in the infrastructure layer using ORM, SQL, or document store
- [ ] Reconstruct a complete, valid aggregate from storage (not a partial object)
- [ ] Return `null` / `Optional` / `None` for `findById` misses — do not throw unless a miss is a domain error
- [ ] For complex queries, consider a Specification or a read-model query service instead

## Review checklist

- [ ] Repository interface has no persistence-specific imports (no ORM annotations, no SQL)
- [ ] Only aggregate roots have repositories — not child entities or value objects
- [ ] Query methods are named in domain language
- [ ] The implementation reconstructs fully valid aggregates (invariants hold after load)
- [ ] Transaction management lives outside the repository (in Application Services)

## Common mistakes

- Creating repositories for every entity, not just aggregate roots
- Putting ORM/SQL logic or annotations in the domain model
- Returning partially populated aggregates that violate invariants
- Using generic `findBy(Map<String, Object> criteria)` instead of domain-specific methods
- Placing transaction control inside the repository
