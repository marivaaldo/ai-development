---
name: ca-ports-adapters
description: Design pluggable interfaces using the Ports and Adapters (Hexagonal) pattern
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Ports & Adapters (Hexagonal Architecture)

The application core defines **Ports** (interfaces) for everything it needs from or provides to the outside world. **Adapters** implement those ports for specific technologies. The core never depends on adapters.

## When to invoke

- Designing how the application interacts with databases, message brokers, external APIs, or UIs
- Making infrastructure components swappable (e.g., replace PostgreSQL with MongoDB)
- Enabling the core to be tested without any real infrastructure

## Core concepts

- **Port** — an interface defined by and owned by the application core. Two kinds:
  - **Driving port (primary)** — entry points into the core; implemented by the core, called by adapters (e.g., use case input port)
  - **Driven port (secondary)** — interfaces the core calls to reach the outside world (e.g., repository interface, email sender interface)
- **Adapter** — an implementation of a port for a specific technology:
  - **Driving adapter** — translates external input into core calls (HTTP controller, CLI command, message consumer)
  - **Driven adapter** — implements a driven port using a real technology (SQL repository, SMTP email sender, Stripe payment gateway)
- **The core is isolated** — it depends only on port interfaces; no adapter code is visible inside the core

## Implementation checklist

- [ ] Define all driven ports as interfaces in the application core (no technology imports)
- [ ] Implement driven adapters in the infrastructure layer; inject them into the core at startup
- [ ] Keep driving adapters thin — they translate input and call the driving port; no business logic
- [ ] Wire everything together in a composition root (main, app factory, DI container)
- [ ] Test the core with in-memory adapter implementations (no real infrastructure needed)
- [ ] Name ports after their purpose, not their technology: `OrderRepository` not `PostgresOrderStore`

## Review checklist

- [ ] All interfaces used by the core are defined in the core layer (not in adapters)
- [ ] No adapter type names appear in core classes
- [ ] Swapping an adapter (e.g., different database) requires no changes to core logic
- [ ] Core can be tested entirely with in-memory or stub adapters
- [ ] Driving adapters contain only translation logic, no business rules

## Common mistakes

- Defining port interfaces in the adapter layer (inverts the ownership)
- Leaking adapter-specific types into the core (e.g., JPA Entity annotations on domain classes)
- Creating ports for every method (over-engineering) instead of for every external system interaction
- Skipping the driving adapter and calling use cases directly from framework controllers with framework types
