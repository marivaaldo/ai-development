---
name: ai-guide
description: Choose the right AI skill for your current problem — prompt design, evaluation, or LLM integration
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# AI Skills Guide

A decision guide for selecting the right AI skill. Describe your problem and get directed to the most relevant skill.

## Available AI skills

| Skill | Use when |
|---|---|
| `/ai-prompt-design` | Writing or improving a system prompt, few-shot examples, output format, or guardrails |
| `/ai-evaluation` | Measuring output quality, building an eval suite, or running regression tests on prompt changes |
| `/ai-llm-integration` | Integrating an LLM API into a service — retries, cost, latency, streaming, secrets, observability |

## Quick decision tree

**I need to make the model produce better output →** `/ai-prompt-design`
- Output is inconsistent or off-target
- Model ignores instructions or produces wrong format
- Need to add few-shot examples or chain-of-thought

**I need to measure or verify output quality →** `/ai-evaluation`
- Shipping a new LLM feature and need to know if it is good enough
- Prompt or model change may have regressed quality
- Need to build a test suite that runs in CI

**I need to wire the LLM into the application →** `/ai-llm-integration`
- Adding retry logic, timeouts, or circuit breakers to an LLM call
- Controlling cost and latency in production
- Managing API keys, streaming, or context window limits
- Defending against prompt injection

## Cross-skill combinations

| Problem | Skills to combine |
|---|---|
| Shipping a new LLM feature end-to-end | `/ai-prompt-design` → `/ai-evaluation` → `/ai-llm-integration` |
| LLM feature is slow and expensive in production | `/ai-llm-integration` (cost/latency) + `/ai-prompt-design` (reduce prompt size) |
| Model quality regressed after a prompt change | `/ai-evaluation` (run eval suite) + `/ai-prompt-design` (fix the prompt) |
| Security review of an LLM feature | `/ai-llm-integration` (injection, secrets) + `/eng-security-review` + `/eng-lgpd` |

## Other skill families

- **Engineering practices** (testing, observability, security) → `/eng-guide`
- **API design for the service that wraps the LLM** → `/eng-api-design`
- **Architecture decisions about AI components** → `/adr-writer`
