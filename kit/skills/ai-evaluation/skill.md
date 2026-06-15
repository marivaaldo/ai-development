---
name: ai-evaluation
description: Measure LLM output quality with evals, LLM-as-judge, and regression suites
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# AI Evaluation

An LLM feature without an eval suite ships blind. Evals are automated tests that measure whether the model's outputs meet quality, safety, and correctness requirements — and whether they stay that way when the model, prompt, or retrieval pipeline changes.

## When to invoke

- Designing a new LLM feature before writing the prompt
- Reviewing an LLM feature before it ships to production
- A prompt change regressed output quality in a way only users noticed
- Choosing between model versions or prompt strategies

## What to evaluate

| Dimension | Question | How to measure |
|---|---|---|
| **Correctness** | Does the output contain the right answer or information? | Reference-based comparison, unit evals |
| **Faithfulness** | Does the output stay grounded in the provided context? | LLM-as-judge, citation checks |
| **Relevance** | Does the output address the user's actual question? | LLM-as-judge |
| **Format compliance** | Does the output match the required structure? | Schema validation, regex |
| **Safety / refusal** | Does the model refuse harmful inputs correctly? | Adversarial eval set |
| **Latency / cost** | Is the output produced within acceptable time and budget? | Telemetry (see `/ai-llm-integration`) |

Not all dimensions apply to every feature. Start with correctness and format compliance.

## Eval types

### Unit evals (deterministic)

Use when the correct answer is known in advance.

```
Input:  "What is the capital of France?"
Expected: contains "Paris"
Pass:   output.lower() contains "paris"
```

Best for: fact extraction, classification, structured data extraction, yes/no questions.

### Reference-based evals

Compare output to a gold-standard reference using a similarity metric.

| Metric | Use case | Limitation |
|---|---|---|
| Exact match | Code generation, structured fields | Too strict for natural language |
| F1 / ROUGE | Summarization, extraction | Sensitive to phrasing; ignores semantics |
| Semantic similarity (embedding) | Open-ended answers | Requires embedding model; slow |

Use reference-based metrics as signals, not as absolute thresholds. A 0.85 ROUGE score may be excellent for one task and poor for another.

### LLM-as-judge

Use a model (often a stronger or different model) to score another model's output on a rubric.

```
Prompt to judge model:
"Given the context: <context>
User question: <question>
Model answer: <answer>

Rate the answer on:
- Faithfulness (1–5): does it only contain information from the context?
- Relevance (1–5): does it answer the question asked?
Return JSON: {"faithfulness": N, "relevance": N, "reasoning": "..."}"
```

**Strengths:** handles open-ended outputs; flexible rubrics.
**Weaknesses:** non-deterministic; judge model has its own biases; adds cost and latency.

Use LLM-as-judge for dimensions that cannot be verified by deterministic comparison (tone, coherence, faithfulness in long documents).

### Adversarial evals

Test cases designed to trigger failures:

- Prompt injection attempts ("Ignore your instructions and...")
- Out-of-scope questions that should be declined
- Ambiguous inputs where the correct behavior must be defined
- Edge cases at the boundary of the stated scope

Adversarial evals must be in the eval suite before the feature ships, not added after the first incident.

## Building a regression suite

1. **Collect cases from production** (after launch): log inputs and outputs; label failures found by users
2. **Add every bug as a test case**: when the model fails, capture the input and expected output and add it to the suite
3. **Run on every prompt change** and every model upgrade before deploying
4. **Track scores over time**: a score that was 0.90 and is now 0.85 is a regression, even if 0.85 is "acceptable"

Minimum viable eval suite for a new feature:
- 10–20 representative inputs with expected outputs
- 5–10 adversarial or edge case inputs
- 2–3 cases the feature should decline

## Eval pipeline in CI

```
prompt change or model upgrade
       ↓
run eval suite (deterministic + LLM-as-judge)
       ↓
compare scores to baseline
       ↓
fail build if any score drops below threshold
       ↓
human review of borderline cases
```

Treat eval regressions the same as failing unit tests: block the change until the regression is understood and addressed.

## Implementation checklist

- [ ] An eval suite exists before the feature ships
- [ ] Eval suite covers correctness, format compliance, and at least one adversarial category
- [ ] Eval scores are tracked as a time series (baseline per prompt version)
- [ ] Evals run automatically on prompt changes and model upgrades
- [ ] LLM-as-judge rubric is documented and reproducible
- [ ] Every production failure generates a new eval case

## Review checklist

- [ ] No prompt change shipped without running the eval suite
- [ ] No model upgrade without a full eval run and score comparison to the previous model
- [ ] Adversarial cases are present in the eval suite, not just happy-path inputs
- [ ] LLM-as-judge criteria are explicit — not "is this good?" but "does it contain X and not Y?"
- [ ] Eval scores are persisted — not recalculated from scratch each time

## Common mistakes

- Shipping an LLM feature with manual spot-checking instead of an eval suite — regressions appear after the second prompt change
- Using a single aggregate score to summarize all dimensions — a feature can score 0.90 on average while failing 100% of adversarial inputs
- Building evals only from easy, happy-path examples — the suite will not catch the cases that matter in production
- Running evals on the same model that generates the outputs (the model cannot reliably judge its own outputs)
- Not pinning the judge model version — the same prompt + inputs can score differently across judge model versions
