---
name: eng-contract-testing
description: Verify service integration contracts with consumer-driven tests and schema validation
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Contract Testing

Integration tests that spin up multiple services together are slow, brittle, and hard to maintain. Contract testing replaces them with lightweight, isolated verification: the consumer defines what it expects from the provider, and the provider verifies it can meet those expectations — independently, in CI.

## When to invoke

- A service boundary exists between two teams or two deployable units
- An HTTP API or message schema is shared between a producer and one or more consumers
- Integration tests are slow, flaky, or require a full environment to run
- A provider is about to change an API and needs to verify consumers are not broken

## Core concepts

### Consumer-driven contracts

The consumer (caller) writes the contract — it specifies the minimal request it will send and the minimal response it needs. The provider then runs that contract against its own implementation.

**Benefits over full integration tests:**
- Consumers and providers test independently (no shared environment needed)
- Failures are attributed precisely: "consumer X expects field Y, provider does not return it"
- Contracts are versioned alongside the consumer code

**Tools:** Pact (REST and async), Spring Cloud Contract, Dredd (OpenAPI-based).

### The Pact workflow (REST)

```
1. Consumer test runs → generates pact file (JSON contract)
2. Pact file is published to a Pact Broker
3. Provider CI pulls the pact file → runs provider verification
4. Broker records: can-i-deploy? (consumer v2.1 ↔ provider v3.0) = YES/NO
```

Each step runs in the respective team's CI pipeline. No shared environment needed.

### Contract components

A REST contract specifies:

| Element | Consumer defines | Provider verifies |
|---|---|---|
| HTTP method + path | ✓ | ✓ |
| Request headers | Required headers only | At minimum those headers |
| Request body | Fields the consumer sends | Accepts those fields |
| Response status | Expected status code | Returns that code |
| Response body | Fields the consumer reads | Returns at minimum those fields |

The contract is a **minimal intersection**, not a full API spec. The consumer only specifies what it uses. The provider may return more — that is fine.

### Schema validation (OpenAPI)

When consumer-driven tests are impractical (public APIs, many consumers), validate request and response payloads against an OpenAPI schema in CI:

- **Request validation:** reject requests that do not match the schema at the API gateway or middleware layer
- **Response validation:** in contract tests or integration tests, assert that actual responses conform to the published schema
- **Schema diff:** on every pull request, run a diff tool (e.g., `oasdiff`, `openapi-diff`) and fail on **breaking changes** (removed fields, changed types, tightened constraints)

Breaking changes require a new API version. See `/eng-api-design` for versioning strategy.

### Async contracts (queues and events)

Apply the same principle to message schemas:

- The consumer defines the fields it reads from the message
- The producer verifies it publishes messages that contain at minimum those fields
- Use a schema registry (Confluent Schema Registry, AWS Glue) for Avro/Protobuf schemas with compatibility enforcement

Schema registry compatibility modes:
| Mode | Breaking change allowed |
|---|---|
| `BACKWARD` | Consumers on old schema can read new messages |
| `FORWARD` | Consumers on new schema can read old messages |
| `FULL` | Both — safest for independent deployments |

### When to use contract testing vs integration testing

| Scenario | Preferred approach |
|---|---|
| Two services owned by different teams | Contract testing |
| Internal service, same team, same deploy | Integration test with real service |
| Public API with many unknown consumers | OpenAPI schema validation + versioning |
| Legacy system with no test support | Integration test with recorded responses |
| Message-based integration between bounded contexts | Async contract testing + schema registry |

Contract testing does **not** replace integration testing entirely. Use integration tests to verify end-to-end business flows; use contract tests to verify interface compatibility.

## Implementation checklist

- [ ] Consumer test generates a pact/contract file as part of its CI run
- [ ] Contract file is published to a broker (Pact Broker, Pactflow) or committed alongside consumer code
- [ ] Provider CI pulls and verifies all consumer contracts before merging
- [ ] `can-i-deploy` check runs before production deployment for both consumer and provider
- [ ] OpenAPI schema diffs run on every pull request; breaking changes fail the build
- [ ] Async schemas are registered and compatibility mode is set to `FULL` or `BACKWARD`

## Review checklist

- [ ] Contracts specify only what the consumer actually uses (not the full API)
- [ ] No contract hardcodes dynamic values (timestamps, UUIDs) without matchers
- [ ] Provider verification runs against the same contract version the consumer depends on
- [ ] Schema changes that remove or rename fields increment the API version
- [ ] Breaking changes in message schemas are rejected by the schema registry

## Common mistakes

- Writing contracts that duplicate the full API spec — they become brittle and require updates on every provider change
- Not using matchers for dynamic fields (dates, IDs) — contracts fail on every run due to value mismatch
- Running provider verification only manually, not in CI — contracts go stale
- Treating a passing contract test as a passing integration test — contracts verify the interface, not the business logic
- Adding a schema registry without setting a compatibility mode (defaults to NONE in some tools — all changes are allowed)
