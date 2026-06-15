---
name: eng-error-handling
description: Design retry, circuit breaker, timeout, dead letter queue, and fallback strategies for distributed systems
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Error Handling & Resilience

Distributed systems fail partially. This skill covers the patterns that keep a system functional when dependencies fail: retry with backoff, circuit breaker, timeout, dead letter queue, idempotency, and fallback.

## When to invoke

- Designing a client that calls an external HTTP service, database, or message broker
- Reviewing code that has bare `try/catch` or no retry logic
- Diagnosing cascading failures or thundering herd incidents
- Adding a new consumer to a queue or event stream

## Core concepts

### Retry with exponential backoff and jitter

Retrying immediately after a failure usually hits the same overloaded resource. Use exponential backoff with random jitter to spread retry storms:

```
delay = min(cap, base * 2^attempt) + random(0, jitter)
```

| Parameter | Typical value |
|---|---|
| `base` | 100–500 ms |
| `cap` | 30–60 s |
| `jitter` | ±25% of delay |
| Max attempts | 3–5 for synchronous calls; unlimited with DLQ for async |

**Only retry idempotent operations.** A failed POST that creates a resource must use an idempotency key before retrying; a failed GET or DELETE can be retried unconditionally.

### Circuit breaker

Prevents cascading failures by stopping calls to a failing dependency before they exhaust thread pools or connection pools.

| State | Behavior | Transition |
|---|---|---|
| **Closed** | Requests pass through; failures are counted | Opens after N failures in a window |
| **Open** | All requests fail immediately (fail fast) | Moves to Half-Open after a timeout |
| **Half-Open** | One probe request is allowed through | Closes on success; Opens on failure |

Configure thresholds per dependency, not globally. A slow database should not open the circuit breaker for the payment provider.

### Timeout

Every network call must have a timeout. Without one, a thread waits indefinitely and the thread pool fills.

| Timeout type | What it covers |
|---|---|
| **Connect timeout** | Time to establish the TCP connection (2–5 s) |
| **Read timeout** | Time to receive the first byte after connecting (5–30 s depending on operation) |
| **Request timeout** | Total wall-clock time for the full request including retries |

Set the request timeout to less than the caller's own timeout. If your HTTP handler times out at 30 s, your downstream call must time out at 20 s to leave room for error handling.

### Dead letter queue (DLQ)

For async consumers (queues, event streams): messages that fail repeatedly must be moved to a DLQ instead of blocking the queue or being silently dropped.

- Set a max delivery count (3–5 attempts) before routing to DLQ
- The DLQ must be monitored with an alert — a growing DLQ is a silent data loss event
- Build a replay mechanism: fix the bug, then replay DLQ messages in order

### Idempotency for consumers

A message may be delivered more than once (at-least-once delivery). Consumers must be idempotent:

- Use the message ID or a business key to detect and discard duplicates
- Persist processed message IDs in a durable store (DB, Redis) with a TTL
- Idempotency check must happen inside the same transaction as the business operation, or use the outbox pattern

### Fallback strategies

When a dependency is unavailable, choose the right degradation:

| Strategy | When appropriate |
|---|---|
| **Return cached data** | Stale data is acceptable; TTL is reasonable |
| **Return empty / default** | Missing data does not break the user flow |
| **Fail fast with clear error** | Partial data would be more harmful than no data |
| **Queue for later** | Operation can be deferred (async write, email queue) |

Never silently swallow errors. Every fallback must be logged at WARN or ERROR level.

## Implementation checklist

- [ ] All HTTP and database calls have explicit connect and read timeouts
- [ ] Retry logic uses exponential backoff with jitter; max attempts are bounded
- [ ] Only idempotent operations are retried without an idempotency key
- [ ] Circuit breakers are configured per dependency
- [ ] Async consumers move failed messages to a DLQ after N attempts
- [ ] The DLQ has a monitoring alert and a replay runbook
- [ ] Consumers are idempotent: duplicate messages produce the same outcome
- [ ] Fallback behaviour is explicit and logged — no silent swallowing of errors

## Review checklist

- [ ] No network call without a timeout
- [ ] No unbounded retry loop (missing max attempts or missing backoff)
- [ ] No retry of non-idempotent operations without an idempotency key
- [ ] No queue consumer that drops or ignores a failed message
- [ ] Circuit breaker thresholds are tuned per dependency, not copied from defaults
- [ ] Fallback paths are tested — not just the happy path

## Common mistakes

- Retrying immediately with no delay, causing a thundering herd that makes the outage worse
- Using the same timeout for all dependencies (a payment provider is not the same as an internal cache)
- Not testing the circuit breaker — it only helps if it opens at the right threshold
- Moving messages to a DLQ with no alert and no replay process (effectively silent data loss)
- Treating at-most-once delivery as a guarantee in messaging systems that provide at-least-once
- Swallowing exceptions in a `catch` block and returning a default without logging
