# Repository Structure Design

Date: 2026-06-11
Status: Approved

---

## Overview

`ai-development` is a provider-agnostic collection of skills, prompts, templates, and patterns for AI-first projects. It is designed to be reused by any project, by any team, eventually as open source.

---

## Audience

Primary: the author, syncing across personal projects.  
Secondary: teams adopting it as a base for new projects.  
Future: open source community contributions.

---

## Consumption Mechanisms

Projects can adopt this repository in four ways:

1. **Manual copy** — dev clones and copies what they need
2. **Git submodule/subtree** — repository lives inside the project
3. **Script** — `./scripts/init.sh <destination>` scaffolds a new project
4. **Combination** — submodule for active skills/prompts, copy for docs/templates

---

## Repository Structure

```
ai-development/
├── kit/
│   ├── skills/
│   │   ├── adr-writer/
│   │   │   └── skill.md
│   │   ├── code-review/
│   │   │   └── skill.md
│   │   ├── architecture-review/
│   │   │   └── skill.md
│   │   └── ...
│   ├── prompts/
│   │   ├── adr.md
│   │   ├── code-review.md
│   │   └── ...
│   ├── templates/
│   │   ├── adr.md
│   │   ├── spec.md
│   │   └── ...
│   └── references/
│       ├── claude.md
│       ├── gemini.md
│       └── codex.md
├── docs/
│   ├── guide.md
│   ├── adr-pattern.md
│   ├── skills-pattern.md
│   └── adoption.md
├── example/
│   ├── README.md
│   ├── adr/
│   │   ├── INDEX.md
│   │   ├── architecture/
│   │   ├── infrastructure/
│   │   ├── ai/
│   │   └── product/
│   ├── skills/
│   ├── prompts/
│   ├── specs/
│   ├── runbooks/
│   └── glossary/
├── scripts/
│   ├── init.sh
│   └── update-adr-index.sh
└── README.md
```

---

## Skills Format (provider-agnostic)

Each skill lives at `kit/skills/<name>/skill.md` with frontmatter:

```markdown
---
name: adr-writer
description: Create consistent Architecture Decision Records
providers:
  claude: native
  gemini: see references/gemini.md
  codex: see references/codex.md
---
```

Skill content is written once, provider-agnostic. The `kit/references/` files explain installation and usage differences per provider without duplicating skill content.

---

## ADR Pattern

Every ADR starts with a token-optimized header (~20-30 lines) readable without opening the body:

```markdown
# ADR-0001

Title: ...
Status: Accepted | Proposed | Deprecated | Superseded
Category: Architecture | Infrastructure | AI | Product
Tags: [tag1, tag2]
Keywords: word1, word2, word3
Summary: (max 3 lines)
Related: ADR-0002, ADR-0005
Date: YYYY-MM-DD

---

## Context
## Decision
## Consequences
## Alternatives Considered
```

### ADR Index (`adr/INDEX.md`)

Generated and maintained automatically:

```markdown
# ADR Index

| ADR  | Category       | Title        | Summary                     |
|------|----------------|--------------|-----------------------------|
| 0001 | Architecture   | DDD          | Organização por domínio     |
```

### Token-efficient read strategy (used by adr-writer skill)

1. Read `adr/INDEX.md` — get full picture cheaply
2. Read headers only of related ADRs (~20 lines each)
3. Read full body only of directly relevant ADRs
4. Often no ADR body needs to be opened at all

---

## ADR Writer Skill — Index Update Strategy

The `adr-writer` skill handles index maintenance directly, without requiring the script to be re-run:

- **On ADR creation:** skill appends the new row to `adr/INDEX.md` inline
- **On conflict or drift:** `./scripts/update-adr-index.sh` regenerates the full index from scratch

This means the index stays in sync after every skill run. The script exists as a repair/sync tool, not as the primary update mechanism.

---

## README Structure

The root `README.md` serves as entry point for both humans and AI agents:

- One-line description
- Table of folders with purpose
- Three adoption paths (copy, script, submodule)
- Supported providers
- Link to `docs/guide.md` and `example/`

---

## Out of Scope

- RAG pipeline implementation (phase 3+ of guide.md — future work)
- MCP server definitions (phase 4 — future work)
- Agent orchestration (phase 5 — future work)
- CLI tool (`ai-dev`) — possible future evolution of `scripts/init.sh`
