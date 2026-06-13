---
name: ddd-specification
description: Encapsulate business rules and query criteria as composable specification objects
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Specification

A Specification encapsulates a business rule or query criterion as a standalone, named, composable object. Specifications can be combined with logical operators (`and`, `or`, `not`) to build complex rules from simple parts.

## When to invoke

- Validation logic for a domain object is complex and reused in multiple places
- Query criteria represent a business concept worth naming (`ActiveCustomers`, `OverdueInvoices`)
- The same rule is used for both filtering (repository query) and validation (domain guard)
- Building a rules engine or eligibility checker where rules vary per use case

## Core concepts

- **Named business rule** — a Specification is a first-class domain concept with a meaningful name
- **`isSatisfiedBy(candidate)`** — the core method: returns true if the candidate meets the rule
- **Composable** — combine specifications with `and()`, `or()`, `not()` to form complex rules
- **Three uses of the same specification:**
  1. **Validation** — check if an object satisfies the rule before an operation
  2. **Selection** — filter a collection (in-memory or via repository query translation)
  3. **Construction** — describe what an object should look like when built

## Implementation checklist

- [ ] Name the specification after the business rule it encodes (`EligibleForPromotion`, `OverdueInvoice`)
- [ ] Implement `isSatisfiedBy(T candidate): boolean` as the primary method
- [ ] Implement `and`, `or`, and `not` combinators (or inherit from a base `CompositeSpecification`)
- [ ] Keep each specification focused on a single rule — compose for complex cases
- [ ] When translating to repository queries, keep the translation in the infrastructure layer

## Review checklist

- [ ] Each specification is named after a domain concept, not a technical filter
- [ ] Specifications are composable — no if-else chains building complex rules imperatively
- [ ] The same specification is reused for validation and querying (not duplicated)
- [ ] Specification classes live in the domain layer with no persistence imports
- [ ] Complex queries are expressed as composed specifications, not raw query strings

## Common mistakes

- Creating a specification class but only using it in one place (just use a method instead)
- Putting query-translation logic (SQL, ORM predicates) inside the specification class
- Using specifications for every simple boolean check regardless of reuse potential
- Naming specifications after implementation details (`WhereStatusEqualsActive`) instead of domain concepts (`ActiveOrder`)
