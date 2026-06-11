---
name: adr-writer
description: Create consistent Architecture Decision Records and keep the index in sync
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
---

# ADR Writer

Create a new Architecture Decision Record following the project's token-optimized format,
then update the index inline.

## Before creating an ADR

1. Read `adr/INDEX.md`
   - Build a mental index of existing decisions
   - Identify the next ADR number (highest existing + 1)

2. From the index, identify ADRs that may be related to the new decision

3. Read the header (~25 lines) of each related ADR
   - Check for conflicts or superseded decisions
   - Read the full body only if the header is insufficient

4. Only then draft the new ADR

## ADR structure

```text
# ADR-XXXX

Title: <one line>
Status: Proposed
Category: Architecture | Infrastructure | AI | Product
Tags: [tag1, tag2]
Keywords: word1, word2, word3
Summary: <max 3 lines>
Related: ADR-XXXX (if any)
Date: YYYY-MM-DD

---

## Context

<The situation that required a decision>

## Decision

<What was decided>

## Consequences

<Trade-offs and follow-ups>

## Alternatives Considered

<Up to 3 alternatives with brief reasoning for rejection>
```

## File placement

Place the new ADR in the matching category folder:

```text
adr/
├── architecture/   ← for architecture decisions
├── infrastructure/ ← for infra/tooling decisions
├── ai/             ← for AI/ML/LLM decisions
└── product/        ← for product/feature decisions
```

File name: `XXXX-<kebab-title>.md` (e.g. `0021-qdrant-vector-db.md`)

## After creating the ADR

Append a new row to `adr/INDEX.md`:

```markdown
| XXXX | Category | Title | One-line summary |
```

Insert in numeric order. Do not regenerate the full file — append the row only.

If `adr/INDEX.md` does not exist yet, create it:

```markdown
# ADR Index

| ADR  | Category | Title | Summary |
|------|----------|-------|---------|
| XXXX | Category | Title | Summary |
```

> Provider note: editing a Markdown file is a standard file edit operation.
> See `kit/references/` for how to edit files on your provider.
