---
name: ca-boundary-objects
description: Design request models, response models, presenters, and controllers at architectural boundaries
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Boundary Objects

Architectural boundaries are crossed using simple data structures — **Request Models**, **Response Models**, **Presenters**, and **Controllers**. These objects prevent domain entities and framework types from leaking across layers.

## When to invoke

- Designing how data flows between a use case and its caller
- Reviewing whether domain entities are being passed to controllers or views
- Implementing a Presenter or Controller for a use case

## Core concepts

### Request Model (Input DTO)
- Simple data structure passed from a driving adapter to a use case input port
- No methods, no business logic — just data
- Defined in the use case layer (not in the adapter layer)
- Contains only what the use case needs — no framework types (`HttpRequest`, `FormData`)

### Response Model (Output DTO)
- Simple data structure produced by the use case and passed to the output port
- No methods, no behavior — just data in the format the use case naturally produces
- Defined in the use case layer

### Presenter
- Implements the use case **output port**
- Receives the Response Model and converts it to a **View Model** (format suitable for a specific view)
- Humble Object — formats data; no business logic
- Knows about the view format; the use case does not

### Controller
- Implements the use case **input port** call
- Receives input from the framework (HTTP request, CLI args), translates to a Request Model
- Calls the use case input port
- No business logic

### View Model
- The final formatted data ready for rendering
- May contain strings, formatted dates, currency symbols — ready to display without further processing

## Implementation checklist

- [ ] Define Request and Response models in the use case layer as plain data classes
- [ ] Controllers translate framework input → Request Model → use case call
- [ ] Presenters translate Response Model → View Model for the specific view
- [ ] No domain entities appear in controllers, presenters, or views
- [ ] No framework types appear in Request or Response models

## Review checklist

- [ ] Domain entities never cross an architectural boundary
- [ ] Request models contain no framework types
- [ ] Presenters do only formatting — no business decisions
- [ ] Controllers do only translation and delegation — no business logic
- [ ] View models are flat, pre-formatted, and ready to render without additional transformation

## Common mistakes

- Passing domain entities to views or controllers (tight coupling to domain internals)
- Putting formatting logic in use cases (they should not know about view requirements)
- Sharing the same DTO class across multiple use cases (each use case has its own boundary)
- Using framework request/response objects (HttpServletRequest, Flask Request) inside use cases
