---
name: user-story-writer
description: Guide a brainstorming dialogue to write a User Story (Como/Quero/Para que) with Given/When/Then acceptance criteria — one question at a time, escalating to /ca-use-case when the flow proves too complex for a simple story
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# User Story Writer

Guide the user through a brainstorming dialogue to formalize a feature idea as a User Story with Given/When/Then acceptance criteria. Unlike `/issue-writer` (which extracts context and pre-fills a draft), this skill is conversational — the goal is the dialogue itself, not just the final document.

## Core Principle

**One question at a time.** Elicit the story and its scenarios through dialogue — don't assume or invent what the user hasn't said. Present the full draft only once the dialogue is complete.

## Phase 1 — Discovery

Ask, one at a time:

1. **Actor** — who is the user/persona performing this action?
2. **Goal** — what action or objective do they want?
3. **Benefit** — what value or outcome do they get from it?
4. **Feature name/slug** — what should this story be called? (used for the output filename)

If any of these were already stated earlier in the conversation, suggest the inferred value and ask for confirmation instead of asking from scratch.

## Phase 2 — Complexity Check

Ask whether the flow involves:
- Multiple alternative paths or exceptions
- Multiple actors or external systems interacting

If yes: tell the user that a full Use Case (`/ca-use-case`) may fit better than a simple User Story — it documents alternative/exception flows explicitly, which a single story does not. Ask whether they want to switch or continue with the User Story anyway. This is advisory only: proceed with whatever the user chooses.

If no: continue to Phase 3.

## Phase 3 — Acceptance Criteria Elicitation

Build Given/When/Then scenarios one at a time, one clause at a time (Given, then When, then Then — not all three in one question).

Required:
- At least one happy-path scenario
- At least one error/edge-case scenario

Allow the user to add as many additional scenarios as they want.

## Phase 4 — Draft and Review

Present the complete draft in one message: the User Story plus all acceptance criteria scenarios gathered so far. Do not ask field by field here — this phase is about reviewing the whole, not building it piece by piece.

The user can:
- Approve as-is
- Edit any field inline
- Ask to add/revise a scenario (returns to Phase 3 for that scenario only)

## Phase 5 — Validation

Before saving, verify:

- No field contains `TODO`, `TBD`, `<placeholder>`, or unchanged template prose
- Each acceptance criterion is concrete and verifiable — reject vague criteria (e.g., "works correctly", "handles errors properly") and ask the user to restate them observably

If validation fails, list exactly which fields/criteria need attention. Do not save.

## Phase 6 — Save

1. Copy the template below into a new file.
2. Save to `specs/<feature-slug>.md`, where `<feature-slug>` is the feature name in kebab-case.
3. Create `specs/` if it does not exist.
4. Report the saved file path.

### Template

```markdown
# User Story: [Feature Name]

Date: YYYY-MM-DD
Status: Draft | Approved

---

## Story

**Como** [tipo de ator/usuário]
**Quero** [ação/objetivo]
**Para que** [benefício/motivação]

## Context

[Uma frase ou parágrafo curto sobre por que essa story existe agora — opcional]

## Acceptance Criteria

### Scenario: [nome do cenário 1 — caminho feliz]
- **Given** [contexto/estado inicial]
- **When** [ação disparada]
- **Then** [resultado esperado]

### Scenario: [nome do cenário 2 — erro/borda]
- **Given** [contexto]
- **When** [ação]
- **Then** [resultado]

## Out of Scope

- [O que fica deliberadamente fora dessa story]

## Open Questions

- [Dúvidas não resolvidas durante o brainstorming, se houver]
```

Omit the `Open Questions` section entirely when there are no pending questions — do not fill it with invented content.

## Error Reference

| Situation | Action |
|-----------|--------|
| Feature idea involves multiple actors/alternative flows | Suggest `/ca-use-case`, let user decide |
| Acceptance criterion is vague/unverifiable | Ask user to restate it observably before saving |
| Required field empty or placeholder text | List missing fields, do not save |
| `specs/` does not exist | Create it before saving |
| Feature slug collides with existing `specs/<slug>.md` | Ask user to confirm overwrite or pick a different name |

## What NOT to do

- Do not auto-publish or hand off to `/issue-writer` — this skill only produces the spec file
- Do not ask combined multi-part questions — one question at a time
- Do not force escalation to `/ca-use-case` — advisory only, user decides
- Do not invent acceptance criteria the user hasn't stated — elicit, don't assume
