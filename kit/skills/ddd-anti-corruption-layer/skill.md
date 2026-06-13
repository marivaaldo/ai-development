---
name: ddd-anti-corruption-layer
description: Protect your domain model from external or legacy system concepts via translation
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Anti-Corruption Layer

A translation layer that isolates your domain model from the concepts, terminology, and data structures of external or legacy systems. The ACL converts foreign models into your Ubiquitous Language.

## When to invoke

- Integrating with a legacy system, third-party API, or external bounded context
- The external system's model would "corrupt" (pollute) your domain if used directly
- Translating between two bounded contexts with different Ubiquitous Languages
- Wrapping a Conformist relationship with a translation layer for future independence

## Core concepts

- **Translation boundary** — the ACL sits between your bounded context and the external system; nothing from the external model crosses it
- **Adapters** — convert external data structures to domain value objects and entities
- **Facades** — simplify complex external APIs into domain-meaningful operations
- **Domain language preserved** — your code only ever sees and uses your own Ubiquitous Language
- **Infrastructure concern** — the ACL implementation lives in the infrastructure layer; the domain layer sees only the interface

## Implementation checklist

- [ ] Define an interface in your domain layer using only domain concepts (no external types)
- [ ] Implement the ACL adapter in the infrastructure layer; import external types only there
- [ ] Map all external fields to domain value objects (translate codes, enums, date formats)
- [ ] Handle external errors and translate them to domain exceptions
- [ ] Write tests against the domain interface, not against the external system directly
- [ ] Document what external concepts map to which domain concepts

## Review checklist

- [ ] No types from the external system appear in the domain or application layers
- [ ] The domain interface uses Ubiquitous Language, not external system terminology
- [ ] The ACL implementation is the only place that imports the external SDK or types
- [ ] All edge cases from the external system (nulls, unknown codes, formats) are handled at the boundary
- [ ] Mapping logic is tested in isolation from the external system

## Common mistakes

- Letting external model types leak into domain services or aggregates
- Building no translation layer (Conformist without intent) and then struggling to change it later
- Duplicating ACL logic in multiple places instead of centralizing it
- Creating an ACL that is a thin pass-through (no actual translation)
- Forgetting to translate error codes and status values, only translating data fields
