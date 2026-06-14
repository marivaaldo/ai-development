---
name: eng-testing-strategy
description: Apply the test pyramid — when to use unit, integration, and e2e tests
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Testing Strategy

A general-purpose testing strategy based on the test pyramid. Covers when to use each test level, how to choose the right test double, and how to detect tests that provide false confidence. For Clean Architecture-specific layering, also see `/ca-testing-strategy`.

## When to invoke

- Designing a test suite for a new feature or service
- Reviewing whether existing tests provide genuine confidence or only validate mocks
- Deciding what type of test to write for a specific scenario
- Diagnosing a slow or brittle test suite

## Core concepts

### The Test Pyramid

```
        /\
       /  \   E2E / Acceptance
      /----\  (few, slow, expensive)
     /      \
    /--------\ Integration
   /          \ (some, medium speed)
  /------------\
 /              \ Unit
/----------------\ (many, fast, cheap)
```

- **Unit tests** — test one unit (function, class, module) in isolation; no I/O; milliseconds to run
- **Integration tests** — test two or more units together, including real databases, queues, or HTTP calls; seconds to run
- **E2E / Acceptance tests** — test the full system through its external interface; minutes to run; cover critical user flows only

The pyramid shape is intentional: invert it and you get a slow, fragile suite that breaks on every infrastructure change.

### Test doubles taxonomy

| Double | What it does | When to use |
|---|---|---|
| **Dummy** | Passed but never used | Satisfying a required parameter |
| **Stub** | Returns a fixed value | Controlling indirect inputs |
| **Fake** | Working implementation (e.g., in-memory DB) | Fast integration tests without real infra |
| **Spy** | Records calls; real implementation | Verifying interactions without mocking |
| **Mock** | Pre-programmed expectations | Verifying that a specific call was made |

### The "only validates mocks" anti-pattern

A test that mocks everything it calls and then asserts only that mocks were called does not test behavior — it tests the implementation. Signs:

- Every dependency is mocked
- Assertions verify only that mock methods were called, not what was actually produced
- The test would pass even if the business logic was deleted and replaced with the mock calls
- Refactoring the internals (without changing behavior) breaks the test

Fix: test **observable outcomes** (return values, state changes, real side effects) rather than internal interactions. Use fakes or real implementations where possible.

## Choosing the right test level

| Scenario | Recommended level |
|---|---|
| Pure function / business rule | Unit test |
| Aggregate or domain entity logic | Unit test |
| Database query correctness | Integration test with real DB |
| HTTP adapter (controller mapping) | Integration test |
| External API client | Integration test with recorded responses or a fake server |
| Critical user flow (login, checkout) | E2E / acceptance test |
| Infrastructure wiring | E2E or smoke test |

## Implementation checklist

- [ ] Unit tests cover all business rules and pure logic
- [ ] Integration tests cover all database queries and external service clients
- [ ] E2E tests cover only the critical happy paths (not every edge case)
- [ ] Mocks are used only when a real or fake implementation is impractical
- [ ] Assertions test observable outcomes, not internal mock calls
- [ ] The suite runs in CI without external dependencies in the unit test phase

## Review checklist

- [ ] No unit test asserts only that a mock method was called
- [ ] Database queries are tested against a real (or in-memory) database, not mocked
- [ ] The test pyramid is not inverted (not more E2E than unit tests)
- [ ] Tests do not depend on test execution order
- [ ] Flaky tests are fixed or removed — not skipped indefinitely

## Common mistakes

- Mocking the database in every test — queries that build wrong SQL pass with mocks
- Writing E2E tests for every scenario (slow, fragile, hard to debug)
- Asserting only that a save/write method was called without checking what was actually saved
- Not testing error and edge cases (only the happy path)
- Treating code coverage as a proxy for test quality (100% coverage with mock-only tests = false confidence)
