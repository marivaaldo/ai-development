---
name: ai-llm-integration
description: Integrate LLM APIs safely — model selection, cost, latency, retries, streaming, and prompt injection defense
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# LLM Integration

Integrating a language model API into a production service requires the same engineering discipline as any external dependency: timeouts, retries, cost control, observability, and security. This skill covers the operational concerns of LLM integration — not prompt design (see `/ai-prompt-design`) or quality measurement (see `/ai-evaluation`).

## When to invoke

- Adding an LLM API call to an existing service
- Reviewing an LLM integration before production launch
- Diagnosing latency, cost, or reliability problems in an LLM-backed feature
- Choosing between model options for a given use case

## Model selection

Choose the smallest model that meets your quality threshold (verified by evals). Larger models cost more per token and have higher latency.

| Consideration | Guidance |
|---|---|
| **Correctness requirements** | Run evals with the smallest model first; upgrade only if quality is insufficient |
| **Latency budget** | Larger models are slower; streaming mitigates perceived latency for interactive use |
| **Cost per request** | Input tokens + output tokens × price per million; measure in production, not estimates |
| **Context window** | Choose based on your maximum expected input size + output size with a 20% margin |
| **Multimodal needs** | Only use vision/audio models when the task requires it |

Never hardcode a model identifier. Externalize it as configuration so it can be updated without a code deploy.

## Cost control

| Technique | Effect |
|---|---|
| **Prompt caching** | Cache static portions of the system prompt (provider-dependent); reduces input token cost by 80–90% for repeated calls |
| **Output length limits** | Set `max_tokens` to the minimum needed; open-ended output is the fastest path to unexpected cost |
| **Model tiers** | Route simple tasks to smaller/cheaper models; reserve large models for complex tasks |
| **Request deduplication** | Cache responses for identical inputs (same prompt + same user input) with a short TTL |
| **Batching** | For offline/async tasks, batch requests to use batch APIs (typically 50% cheaper, higher latency) |

Set a cost budget per feature and alert when daily spend exceeds a threshold.

## Latency

| Technique | When to apply |
|---|---|
| **Streaming** | Any user-facing feature where time-to-first-token matters; stream tokens as they arrive |
| **Prompt caching** | Reduces input processing time for long, repeated prompts |
| **Parallelism** | Independent LLM calls (e.g., evaluating multiple candidates) can run concurrently |
| **Smaller model** | First optimization to try; often 2–4× faster with comparable quality |

Measure and track:
- **Time to first token (TTFT)** — perceived responsiveness for streaming
- **Time to last token (TTLT)** — total wall-clock latency
- **p99 latency** — worst-case user experience

## Retries and rate limiting

LLM APIs return rate limit errors (`429`) and transient errors (`500`, `503`). Apply the same retry strategy as any external dependency (see `/eng-error-handling`):

- Retry on `429` and `5xx` only; do not retry `4xx` (bad request, invalid API key)
- Use exponential backoff with jitter; respect `Retry-After` headers when present
- Set a maximum retry budget (3–5 attempts for synchronous; more for async with a queue)
- Apply a circuit breaker if the provider experiences sustained degradation

Never retry on the same request without a delay. A thundering herd against an already-rate-limited endpoint makes the outage worse.

## Streaming

```
client ← token₁ token₂ token₃ ... tokenN ← LLM API
```

- Connect the output stream directly to the client where possible; avoid buffering the full response
- Handle stream interruption: the model may stop mid-sentence; detect incomplete output and retry or display a warning
- For structured outputs (JSON), buffer the full response before parsing — partial JSON is not valid
- Set a stream timeout: if no token arrives within N seconds, close the stream and surface an error

## Context management

LLMs have a finite context window. Exceeding it causes truncation, errors, or quality degradation.

| Strategy | When to use |
|---|---|
| **Sliding window** | Drop the oldest messages in a multi-turn conversation when the window fills |
| **Summarization** | Summarize older turns into a compact history before they are dropped |
| **RAG (retrieval)** | Retrieve only the relevant document chunks for the current query instead of loading all documents |
| **Chunking** | Split large documents into overlapping chunks; process each separately; aggregate results |

Always measure the token count of your prompt before sending. Use the provider's token-counting API or a client-side tokenizer to avoid surprises.

## Prompt injection defense

A user-facing LLM feature is a potential prompt injection vector. Users can supply inputs that attempt to override system prompt instructions.

**Mitigations:**
- Separate system instructions from user input at the structural level (use the `system` role, not a user message)
- Never interpolate raw user input into the system prompt
- Validate that the model's output conforms to the expected format before surfacing it to other users
- Treat model output as untrusted when it will be rendered as HTML or executed as code — sanitize it
- Add adversarial injection attempts to your eval suite

## Secrets and API keys

- Store API keys in a secrets manager; never in source code, environment files committed to version control, or logs
- Rotate keys on a schedule and immediately after any exposure
- Use separate keys per environment (dev, staging, production) — a dev key should not have production quotas or billing
- Restrict key permissions to the minimum required (read-only where possible)

## Observability

Log for every LLM call:
- Model name and version
- Input token count, output token count
- Latency (TTFT and TTLT)
- Finish reason (`stop`, `length`, `content_filter`)
- Request ID from the provider (for support escalation)

Do not log the full prompt or response content in production without confirming it contains no personal data (see `/eng-lgpd`).

Alert on:
- Error rate above baseline
- p99 latency exceeding SLA
- Daily cost exceeding budget threshold
- Finish reason `content_filter` rate spike (may indicate adversarial inputs)

## Implementation checklist

- [ ] Model identifier is externalized as configuration, not hardcoded
- [ ] `max_tokens` is set to the minimum required for the task
- [ ] Prompt caching is enabled for static system prompts
- [ ] Retries use exponential backoff; `429` and `5xx` only; max attempts bounded
- [ ] Streaming is used for all user-facing features
- [ ] Token count is measured before each call; context window overflow is handled
- [ ] API keys are in a secrets manager; separate keys per environment
- [ ] Latency and cost metrics are emitted for every call
- [ ] Prompt injection: user input is in the `user` role, never interpolated into `system`

## Review checklist

- [ ] No hardcoded model identifier or API key
- [ ] No unbounded `max_tokens` (defaults to context window maximum — expensive)
- [ ] No LLM call without a timeout
- [ ] No retry on `4xx` errors
- [ ] No raw user input interpolated into the system prompt
- [ ] No logging of prompt/response content containing personal data

## Common mistakes

- Defaulting to the largest available model without running evals on smaller ones
- Not setting `max_tokens`, leading to unexpectedly long (and expensive) responses
- Logging full prompts and responses in production without PII filtering
- Building multi-turn chat without a context window management strategy — the app breaks when the conversation gets long
- Treating `finish_reason: "length"` as success — the model was cut off mid-response
