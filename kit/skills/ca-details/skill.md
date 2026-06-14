---
name: ca-details
description: Treat frameworks, databases, and the web as swappable details, not architecture
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Frameworks, Databases, and the Web as Details

The most important insight of Clean Architecture: **frameworks, databases, the web, and external services are details**. They are tools that deliver your business rules, not the foundation on which business rules rest.

## When to invoke

- Choosing a framework and deciding how much influence it should have over the codebase structure
- Reviewing whether business logic is tied to a framework or ORM
- Designing a new system and deciding what the "core" is vs what are "details"

## Core concepts

### Frameworks are tools, not architectures
- Frameworks want you to derive from their classes and annotate your objects — this makes your code depend on them
- Use frameworks as plugins: call them from the outer layer, never let them call into your domain
- Business rules should be testable without loading the framework

### The database is a detail
- The choice of relational, document, or key-value store does not affect business rules
- Domain entities and use cases must be ignorant of the database schema
- The database schema serves the business model — not the other way around
- Access the database through an interface (Repository or Gateway); swap implementations freely

### The Web is a detail
- The web is a delivery mechanism — an I/O device
- Business rules must not know whether they are invoked by HTTP, CLI, gRPC, or a message queue
- Controllers translate HTTP requests into use case calls; use cases know nothing about HTTP

### External services are details
- Payment gateways, email services, third-party APIs — all are details
- Wrap them behind interfaces in the core; implement the wrappers in the infrastructure layer

## Implementation checklist

- [ ] Domain entities and use cases have no imports from any framework, ORM, or web library
- [ ] All framework-specific code lives in the outermost layer (adapters / infrastructure)
- [ ] Business rules can be executed in a test without starting the web server or connecting to a DB
- [ ] Database schema changes do not require changes to domain entities
- [ ] External service APIs are hidden behind interfaces the core defines

## Review checklist

- [ ] No ORM annotations on domain entity classes
- [ ] No HTTP types in use cases or entities
- [ ] Business logic tests run without any infrastructure (no test containers, no HTTP mocks)
- [ ] Replacing the database or web framework would only affect the outermost layer

## Common mistakes

- Letting the framework generate the project structure and never reorganizing it
- Using the database schema as the domain model (driving design from the outside in)
- Annotating domain entities with ORM metadata (JPA `@Entity`, ActiveRecord `has_many`)
- Putting business rules in framework callbacks, lifecycle hooks, or middleware
