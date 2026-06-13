---
name: eng-observability
description: Implement structured logging, request correlation, and LGPD-safe log hygiene
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Observability

Observability is the ability to understand what a system is doing from its external outputs — logs, metrics, and traces. This skill covers structured logging, request correlation, log hygiene (including LGPD constraints), and the distinction between logs, metrics, and traces.

## When to invoke

- Adding logging to a new feature or service
- Reviewing existing log statements for noise, missing context, or PII exposure
- Designing an alerting strategy
- Evaluating observability coverage before a production rollout

## Core concepts

### The three pillars

| Pillar | What it answers | Tool examples |
|---|---|---|
| **Logs** | What happened and when | Elasticsearch, Loki, CloudWatch Logs |
| **Metrics** | How many times / how fast / how much | Prometheus, Datadog, CloudWatch Metrics |
| **Traces** | Where time was spent in a request | Jaeger, Zipkin, AWS X-Ray, OpenTelemetry |

Use all three; they are complementary, not interchangeable.

### Structured logging

Log in **JSON** (or structured key-value), not free-form text strings:

```json
{ "level": "INFO", "timestamp": "2026-06-13T14:00:00Z", "trace_id": "abc123",
  "event": "order.placed", "order_id": "ord_99", "amount_cents": 4990 }
```

Never build log messages by string concatenation. Use a structured logger that serializes fields.

### Log levels

| Level | Use when |
|---|---|
| `DEBUG` | Detailed internal state for local debugging — must not appear in production by default |
| `INFO` | Normal operational events worth keeping (request received, order placed, job completed) |
| `WARN` | Unexpected but recoverable situations (retry attempt, deprecated usage) |
| `ERROR` | Failures that need human attention (unhandled exception, integration failure) |
| `FATAL` | Application cannot continue; triggers immediate alert and restart |

### Request correlation

- Assign a **correlation / trace ID** to every incoming request at the entry point (API gateway, load balancer, or first service)
- Propagate the ID through all downstream calls (HTTP headers, message metadata)
- Include the ID in every log entry for the duration of that request
- Standard headers: `X-Request-ID`, `X-Correlation-ID`, or OpenTelemetry `traceparent`

### What NOT to log (LGPD hygiene)

Logs must never contain:
- Names, CPF, email addresses, phone numbers
- IP addresses linked to identified users (special care needed)
- Passwords, tokens, API keys, or any secret
- Full request bodies that may contain personal data
- Credit card numbers, bank account numbers

Use opaque identifiers (`user_id`, `order_id`) instead of personal data. For full LGPD guidance, see `/eng-lgpd`.

### Alertable vs non-alertable events

- Alert on `ERROR` and `FATAL` levels, and on metric thresholds (latency p99, error rate, queue depth)
- Do not alert on `WARN` unless the warning rate spikes
- Every alert must be **actionable** — if the on-call cannot do anything about it, remove it

## Implementation checklist

- [ ] Logging library outputs JSON with consistent field names (`level`, `timestamp`, `trace_id`, `event`)
- [ ] A correlation ID is generated at the entry point and propagated through all downstream calls
- [ ] Every log entry includes the correlation ID
- [ ] No personal data (name, CPF, email, IP) appears in any log statement
- [ ] Log level is configurable at runtime without redeployment
- [ ] DEBUG logs are disabled in production by default
- [ ] Alerts are defined for ERROR rate, latency p99, and critical business events

## Review checklist

- [ ] No string-concatenated log messages — all fields are structured
- [ ] No PII in any log statement (check all `logger.*` calls)
- [ ] No secrets or tokens logged (check request/response logging middleware)
- [ ] Correlation ID is present in error logs (enables tracing back to the originating request)
- [ ] Log levels are appropriate — no ERROR for expected business exceptions

## Common mistakes

- Logging full request/response bodies in middleware without filtering sensitive fields
- Using `console.log` / `print` instead of a structured logger
- Not propagating the correlation ID into background jobs and async workers
- Setting DEBUG level in production (floods storage, increases cost, may expose data)
- Alerting on every ERROR log instead of on error rate thresholds (alert fatigue)
