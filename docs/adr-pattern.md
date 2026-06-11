# ADR Pattern

Architecture Decision Records in this repository follow a token-optimized format.
The first ~25 lines are a structured header that gives a complete picture without
reading the full body.

## Header format

```text
# ADR-XXXX

Title: <one line>
Status: Accepted | Proposed | Deprecated | Superseded
Category: Architecture | Infrastructure | AI | Product
Tags: [tag1, tag2]
Keywords: word1, word2, word3
Summary: <max 3 lines — what was decided and why>
Related: ADR-XXXX, ADR-XXXX
Date: YYYY-MM-DD

---
```

## Body sections

- **Context** — the situation that required a decision
- **Decision** — what was decided
- **Consequences** — trade-offs, follow-ups
- **Alternatives Considered** — up to 3 alternatives with brief reasoning

## Index file (adr/INDEX.md)

Every project using this pattern maintains an `adr/INDEX.md`:

```markdown
# ADR Index

| ADR  | Category       | Title                  | Summary                          |
|------|----------------|------------------------|----------------------------------|
| 0001 | Architecture   | DDD                    | Organize by domain               |
| 0002 | Infrastructure | PostgreSQL             | Primary relational database      |
```

The index is updated inline by the `adr-writer` skill after every new ADR.
The `scripts/update-adr-index.sh` script regenerates it from scratch when needed.

## Token-efficient read strategy for AI agents

1. Read `adr/INDEX.md` — full landscape in one cheap read
2. Read headers (~25 lines) of related ADRs only
3. Read full body only when necessary
4. Often no body needs to be read at all

## Directory structure

```text
adr/
├── INDEX.md
├── architecture/
├── infrastructure/
├── ai/
└── product/
```
