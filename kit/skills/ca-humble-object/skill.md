---
name: ca-humble-object
description: Separate hard-to-test UI and framework code from testable business logic
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Humble Object Pattern

Split a component into two parts: the **Humble Object** (stripped of all testable logic, directly coupled to the hard-to-test environment) and the **testable logic** (extracted into a plain, framework-free class). Named by Michael Feathers, adopted by Uncle Bob as an architectural boundary marker.

## When to invoke

- A class is hard to test because it is tightly coupled to a UI framework, database, or external service
- A Presenter, Controller, or View contains business logic that needs testing
- Designing the boundary between the framework layer and the application layer

## Core concepts

- **Humble Object** — contains only the minimum code needed to talk to the hard-to-test environment (screen, database, network). Contains no logic worth testing.
- **Extracted logic** — moved to a plain object that can be tested without any framework
- **Common pairings:**
  - View (Humble) + View Model (testable)
  - Presenter (Humble, formats and writes to view) + Use Case output port (testable)
  - Gateway implementation (Humble, talks to DB) + Gateway interface (tested via mock)
  - Event handler (Humble, wired to framework) + Handler logic (testable plain class)

## Implementation checklist

- [ ] Identify what makes the class hard to test (requires UI, HTTP, real DB, etc.)
- [ ] Extract all decision-making, transformation, and calculation logic into a plain class
- [ ] Leave the original class with only the minimal code to interact with the environment
- [ ] The humble class becomes so thin it needs no unit tests — only integration or acceptance tests
- [ ] The extracted class has rich unit tests with no mocking of infrastructure

## Review checklist

- [ ] Controllers contain no business logic — they translate input and delegate to use cases
- [ ] Presenters contain no business logic — they format use case output for the view
- [ ] View Models are plain data structures with no framework dependencies
- [ ] Database gateway implementations contain no business logic — they query and map only
- [ ] The seam between humble and testable code aligns with an architectural boundary

## Common mistakes

- Extracting logic into a "helper" that still depends on the framework (not truly humble)
- Applying the pattern too granularly — one humble object per method, creating excessive indirection
- Not applying it where it matters: controllers and presenters that are growing with business logic
- Confusing "Humble Object" with "empty class" — the humble part still does real work, it just has no testable logic
