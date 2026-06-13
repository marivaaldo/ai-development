---
name: ca-use-case
description: Implement use cases as interactors with explicit input and output ports
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Use Case / Interactor

A Use Case (also called an Interactor) implements one application-specific business rule. It orchestrates the flow of data from input to entities to output, without knowing about the delivery mechanism (web, CLI, queue) or storage details (SQL, NoSQL).

## When to invoke

- Implementing a new business operation (e.g., "place order", "register user")
- Reviewing whether business logic is leaking into controllers or infrastructure
- Deciding the boundary between application logic and domain logic

## Core concepts

- **One use case per class** — each interactor has a single responsibility: one named business operation
- **Input Port** — an interface defining what the use case accepts; implemented by the interactor
- **Output Port** — an interface defining how the interactor delivers results; implemented by a Presenter or callback
- **No framework imports** — the interactor knows nothing about HTTP, databases, or UI frameworks
- **Orchestrates, does not own business rules** — business rules live in Entities; the interactor coordinates them
- **Calls Gateways** — uses interfaces (not implementations) to access external systems

## Implementation checklist

- [ ] Name the interactor after the use case in verb-noun form (`PlaceOrderInteractor`, `RegisterUserUseCase`)
- [ ] Define an `InputPort` interface (or equivalent) with a single `execute(request)` method
- [ ] Define an `OutputPort` interface (or equivalent) for delivering results
- [ ] The interactor class implements `InputPort` and depends on `OutputPort` (not a concrete presenter)
- [ ] Use request/response model objects (simple DTOs) to cross the boundary — no entities, no framework types
- [ ] Inject all dependencies (gateways, repositories) as interfaces — no concrete infrastructure inside the interactor
- [ ] Business rule validation happens in entities; only orchestration happens in the interactor

## Review checklist

- [ ] No framework imports inside the interactor class
- [ ] No direct database, HTTP, or external service calls — only through gateway interfaces
- [ ] Input and output are simple data structures, not domain entities or framework request/response objects
- [ ] The interactor can be tested in complete isolation using mock gateways and a mock presenter
- [ ] Each interactor class handles exactly one use case

## Common mistakes

- Putting business rules inside the interactor (they belong in entities)
- Passing framework request objects (HTTP request, gRPC message) directly into the interactor
- Returning domain entities as output (should be output DTOs through the output port)
- Having one "mega interactor" that handles multiple use cases
- Calling concrete repository implementations directly instead of through interfaces
