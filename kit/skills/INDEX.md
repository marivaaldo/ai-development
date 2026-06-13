# Skills Index

All available skills in this kit, organized by category.

---

## Domain-Driven Design
> Patterns from "Implementing Domain-Driven Design" — Vaughn Vernon (2013)

| Skill | Description |
|---|---|
| `/ddd-guide` | Choose the right DDD pattern for your current design problem |
| `/ddd-ubiquitous-language` | Build and enforce shared domain vocabulary between code and domain experts |
| `/ddd-bounded-context` | Define explicit model boundaries and map integration relationships between contexts |
| `/ddd-aggregate` | Model aggregate roots, enforce invariants, and maintain transactional consistency |
| `/ddd-entity-value-object` | Distinguish entities from value objects and model each correctly |
| `/ddd-repository` | Implement collection-like persistence interfaces for aggregate roots |
| `/ddd-factory` | Encapsulate complex aggregate and domain object creation in factories |
| `/ddd-services` | Distinguish domain services from application services and place logic correctly |
| `/ddd-domain-event` | Model, publish, and handle domain events for cross-aggregate communication |
| `/ddd-event-sourcing` | Implement event sourcing — storing aggregate state as an immutable event log |
| `/ddd-cqrs` | Separate read models from write models using CQRS |
| `/ddd-saga` | Implement long-running processes and cross-aggregate workflows with sagas |
| `/ddd-anti-corruption-layer` | Protect your domain model from external or legacy system concepts via translation |
| `/ddd-specification` | Encapsulate business rules and query criteria as composable specification objects |
| `/ddd-modules` | Organize domain code into cohesive modules that reflect the Ubiquitous Language |

---

## Clean Architecture
> Patterns from "Clean Architecture" — Robert C. Martin (2017)

| Skill | Description |
|---|---|
| `/ca-guide` | Choose the right Clean Architecture pattern for your current design problem |
| `/ca-solid` | Review and apply SOLID principles to classes and modules |
| `/ca-component-cohesion` | Apply REP, CCP, and CRP to design cohesive components and packages |
| `/ca-component-coupling` | Apply ADP, SDP, and SAP to manage dependencies between components |
| `/ca-dependency-rule` | Enforce the Clean Architecture dependency rule across all layers |
| `/ca-screaming-architecture` | Ensure folder and module structure reveals domain intent, not framework choices |
| `/ca-use-case` | Implement use cases as interactors with explicit input and output ports |
| `/ca-humble-object` | Separate hard-to-test UI and framework code from testable business logic |
| `/ca-ports-adapters` | Design pluggable interfaces using the Ports and Adapters (Hexagonal) pattern |
| `/ca-boundary-objects` | Design request models, response models, presenters, and controllers at architectural boundaries |
| `/ca-details` | Treat frameworks, databases, and the web as swappable details, not architecture |
| `/ca-testing-strategy` | Apply a layered testing strategy aligned with Clean Architecture boundaries |

---

## Architecture Decision Records
> ADR lifecycle management

| Skill | Description |
|---|---|
| `/adr-reader` | Consult Architecture Decision Records with token-efficient cascade loading |
| `/adr-writer` | Create consistent Architecture Decision Records and keep the index in sync |
| `/architecture-review` | Review architectural proposals for soundness and ADR alignment |

---

## Code Quality

| Skill | Description |
|---|---|
| `/code-review` | Review code changes for correctness, clarity, and consistency |

---

## Quick reference: start here

- **New feature?** → `/ca-use-case` then `/ddd-aggregate`
- **Integration with external system?** → `/ca-ports-adapters` + `/ddd-anti-corruption-layer`
- **Code review?** → `/code-review` + `/ca-solid`
- **Architecture decision?** → `/adr-writer` + `/architecture-review`
- **Unsure which DDD pattern?** → `/ddd-guide`
- **Unsure which CA pattern?** → `/ca-guide`
