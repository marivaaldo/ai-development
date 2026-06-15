---
name: ddd-guide
description: Choose the right DDD pattern for your current design problem
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# DDD Pattern Guide

A decision guide for selecting the right Domain-Driven Design pattern from "Implementing Domain-Driven Design" (Vaughn Vernon). Describe your problem and get directed to the most relevant skill.

## Available DDD skills

| Skill | Use when |
|---|---|
| `/ddd-ubiquitous-language` | Naming classes/methods, aligning code with domain expert vocabulary |
| `/ddd-bounded-context` | Designing system or service boundaries; integrating two systems |
| `/ddd-aggregate` | Deciding which objects must change together; enforcing invariants |
| `/ddd-entity-value-object` | Modeling a domain concept — does it need identity or is it defined by value? |
| `/ddd-repository` | Implementing persistence access for an aggregate root |
| `/ddd-factory` | Creating complex aggregates or domain objects |
| `/ddd-services` | Placing domain logic that doesn't fit in an entity or value object |
| `/ddd-domain-event` | Propagating state changes across aggregate or context boundaries |
| `/ddd-event-sourcing` | Storing state as an event log; audit trail; temporal queries |
| `/ddd-cqrs` | Separating complex read models from the write model |
| `/ddd-saga` | Coordinating a multi-step process across aggregates or services |
| `/ddd-anti-corruption-layer` | Integrating with a legacy or external system without polluting your model |
| `/ddd-specification` | Encapsulating a reusable business rule for validation or querying |
| `/ddd-modules` | Organizing packages within a bounded context |
| `/ddd-context-map` | Documenting integration relationships between bounded contexts |

## Quick decision tree

**I need to decide on system/service boundaries →** `/ddd-bounded-context`

**I need to model a domain concept:**
- Does it have a unique identity that persists through state changes? → `/ddd-entity-value-object` (Entity path)
- Is it defined entirely by its attributes, with no identity? → `/ddd-entity-value-object` (Value Object path)
- Does it group multiple objects that must stay consistent together? → `/ddd-aggregate`

**I need to place business logic:**
- Logic belongs to a single entity or value object → put it there directly
- Logic spans multiple domain objects → `/ddd-services` (Domain Service)
- Logic orchestrates a use case (load, execute, save, publish) → `/ddd-services` (Application Service)

**I need to handle state changes across boundaries:**
- One aggregate change must trigger another → `/ddd-domain-event`
- A process spans multiple steps across aggregates/services → `/ddd-saga`
- Read and write models need to differ → `/ddd-cqrs`
- Full history of changes is required → `/ddd-event-sourcing`

**I need to integrate with an external system:**
- External model must not leak in → `/ddd-anti-corruption-layer`
- Two contexts need a clear integration contract → `/ddd-bounded-context`
- Documenting all integration relationships in the system → `/ddd-context-map`

**I need to organize or review code:**
- Package/namespace structure → `/ddd-modules`
- Reusable business rule or query criterion → `/ddd-specification`
- Naming consistency with domain experts → `/ddd-ubiquitous-language`
