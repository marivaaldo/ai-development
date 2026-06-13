---
name: ca-testing-strategy
description: Apply a layered testing strategy aligned with Clean Architecture boundaries
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Testing Strategy for Clean Architecture

Clean Architecture's layered structure creates natural testing seams. Each layer has a distinct testing approach — tests stay fast, independent, and meaningful by respecting the same boundaries the architecture defines.

## When to invoke

- Designing the test suite for a new system or feature
- Reviewing whether tests are too slow, too brittle, or too few
- Deciding what to test at which layer

## Testing by layer

### Entities — Unit Tests (pure)
- Test business rules in complete isolation: no mocks, no I/O, no framework
- Should be the fastest and most numerous tests in the suite
- A change in framework or database never breaks these tests

### Use Cases — Unit Tests (with mocks/stubs)
- Test orchestration logic: does the use case call the right gateways in the right order?
- Mock or stub all driven ports (repositories, external service interfaces)
- Use case tests should not require a web server or database

### Interface Adapters — Integration Tests
- Test that controllers correctly translate framework input → use case request model
- Test that presenters correctly format use case output → view model
- Test that repository implementations correctly map domain objects ↔ database schema
- May require a test database or an in-memory substitute

### Frameworks & Drivers — Acceptance / E2E Tests (minimal)
- Test the system end-to-end through the real delivery mechanism (HTTP, CLI)
- Small in number — cover only the most critical user flows
- Slowest and most expensive; catch configuration and wiring issues

## Implementation checklist

- [ ] Entity tests: no mocks, no imports from outer layers, pure inputs and outputs
- [ ] Use case tests: mock all driven ports; assert calls and outputs
- [ ] Adapter tests: test the mapping/translation logic; use real or in-memory implementations
- [ ] At least one acceptance test per major use case that runs through the full stack
- [ ] The test pyramid is respected: many unit tests, fewer integration, few E2E

## Review checklist

- [ ] Entity tests run in milliseconds with no I/O
- [ ] Use case tests run without a database or web server
- [ ] Adapter (repository) tests exercise real SQL or real external calls in isolation
- [ ] E2E test count is small and focused on happy paths
- [ ] A broken database adapter does not cause entity or use case tests to fail

## Common mistakes

- Testing only through the HTTP layer (slow, brittle, covers too much at once)
- Mocking entities in use case tests (entities should be used directly — they are pure)
- Not testing adapters (mappings are a common source of bugs)
- Inverting the test pyramid: many E2E, few unit tests
- Making entity tests depend on frameworks to run (defeats the purpose of inner-layer independence)
