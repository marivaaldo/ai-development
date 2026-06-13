---
name: ca-guide
description: Choose the right Clean Architecture pattern for your current design problem
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Clean Architecture Pattern Guide

A decision guide for selecting the right Clean Architecture concept from "Clean Architecture" (Robert C. Martin). Describe your problem and get directed to the most relevant skill.

## Available Clean Architecture skills

| Skill | Use when |
|---|---|
| `/ca-solid` | Reviewing class or interface design for maintainability |
| `/ca-component-cohesion` | Deciding what belongs in a package or library (REP, CCP, CRP) |
| `/ca-component-coupling` | Reviewing dependency directions between packages (ADP, SDP, SAP) |
| `/ca-dependency-rule` | Checking that dependencies flow correctly across layers |
| `/ca-screaming-architecture` | Evaluating or redesigning folder/module structure |
| `/ca-use-case` | Implementing a business operation as an Interactor |
| `/ca-humble-object` | Separating testable logic from hard-to-test UI or framework code |
| `/ca-ports-adapters` | Making infrastructure pluggable via Ports & Adapters / Hexagonal |
| `/ca-boundary-objects` | Designing Request/Response models, Presenters, Controllers |
| `/ca-details` | Keeping business rules independent of frameworks, DBs, and web |
| `/ca-testing-strategy` | Designing a layered test suite aligned with architecture boundaries |

## Quick decision tree

**I need to design a class or interface:**
- Is the class doing too many things? → `/ca-solid` (SRP)
- Does it depend on something concrete it should not? → `/ca-solid` (DIP) + `/ca-dependency-rule`
- Is the interface too large? → `/ca-solid` (ISP)

**I need to design a component/package/library:**
- What should be grouped together? → `/ca-component-cohesion` (CCP)
- Are there circular dependencies? → `/ca-component-coupling` (ADP)
- Does a stable component depend on a volatile one? → `/ca-component-coupling` (SDP)

**I need to add a new feature/business operation:**
- Implement the business logic → `/ca-use-case`
- Design the data that crosses boundaries → `/ca-boundary-objects`
- Wire the use case to the web framework → `/ca-boundary-objects` (Controller path)
- Format the output for the UI → `/ca-boundary-objects` (Presenter path) + `/ca-humble-object`

**I need to connect to external infrastructure:**
- Database, API, message broker → `/ca-ports-adapters` + `/ca-details`
- Testing without real infrastructure → `/ca-ports-adapters` + `/ca-testing-strategy`

**I need to review the codebase:**
- Does the structure reveal domain intent? → `/ca-screaming-architecture`
- Are dependencies going the right direction? → `/ca-dependency-rule`
- Is framework code bleeding into business logic? → `/ca-details`
- Are tests slow or brittle? → `/ca-testing-strategy` + `/ca-humble-object`

## Combined DDD + Clean Architecture

These skills complement each other:

| CA concept | DDD counterpart |
|---|---|
| Entities (CA) | Entities + Value Objects (DDD) |
| Use Cases | Application Services |
| Gateways / Driven Ports | Repositories |
| Bounded Context | Vertical slice within Clean Architecture |
| Domain Events | Cross-boundary communication between use cases |

Use `/ddd-guide` for patterns from Vaughn Vernon's "Implementing DDD".
