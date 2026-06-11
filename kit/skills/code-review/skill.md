---
name: code-review
description: Review code changes for correctness, clarity, and consistency
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Code Review

Review the current diff or specified files for issues.

## What to check

1. **Correctness** — logic bugs, off-by-one errors, missing null checks at boundaries
2. **Consistency** — follows patterns established in the codebase
3. **Clarity** — names communicate intent, no misleading comments
4. **Security** — no injection vectors, no secrets in code, safe input handling
5. **Tests** — critical paths have coverage, edge cases are handled

## What NOT to check

- Style preferences already handled by a linter
- Hypothetical future requirements (YAGNI)
- Patterns outside the current diff

## Output format

For each finding:

```text
File: path/to/file.ext:LINE
Severity: critical | warning | suggestion
Issue: <one-line description>
Suggestion: <concrete fix>
```

Finish with a summary: total findings by severity, overall recommendation
(approve / approve with suggestions / request changes).
