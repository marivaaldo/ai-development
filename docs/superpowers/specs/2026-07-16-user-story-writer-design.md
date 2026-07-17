# user-story-writer — Design Spec

Date: 2026-07-16
Status: Approved

---

## Overview

A new skill `user-story-writer` that guides the user through a brainstorming dialogue to formalize a feature idea as a **User Story** (Como/Quero/Para que) with **Given/When/Then** acceptance criteria. It lives in `kit/skills/user-story-writer/skill.md`, category "Project Management" alongside `issue-writer`.

**Core principle:** Unlike `issue-writer` (assertive — extracts context and pre-fills a draft), this skill is **conversational**. Its purpose is the brainstorming dialogue itself, not just the final document. It asks one question at a time and lets the user's answers shape the story and its scenarios.

It is independent from `issue-writer` — it produces a standalone spec file. The user can later feed that file into `issue-writer` manually if they want to open an issue from it; the two skills are not wired together automatically.

---

## Phases

### Phase 1 — Discovery (one question at a time)

Ask, one at a time, multiple choice where sensible:
- Who is the actor/persona?
- What is the action/goal?
- What is the benefit/motivation?
- What is the feature name/slug (used for the output filename)?

If any of these can reasonably be inferred from conversation context (e.g., the user already described the goal earlier in the conversation), suggest it and ask for confirmation instead of asking from scratch.

### Phase 2 — Complexity check

Ask whether the flow involves multiple alternative paths/exceptions or multiple actors/systems interacting.

- If yes: tell the user that a full Use Case (`/ca-use-case`) may be a better fit than a simple User Story, and ask whether they want to switch or continue with the User Story anyway.
- If no: proceed to Phase 3.

This is advisory only — the skill never forces a switch, and continues with whatever the user chooses.

### Phase 3 — Acceptance criteria elicitation

Guide the user through Given/When/Then scenarios, one scenario at a time:
- Always elicit at least one happy-path scenario.
- Always elicit at least one error/edge-case scenario.
- Allow as many additional scenarios as the user wants to add.

Each scenario is built conversationally (Given, then When, then Then) rather than asked as one combined question.

### Phase 4 — Draft and review

Present the full draft (User Story + all acceptance criteria scenarios) at once — not field by field. The user can approve as-is, edit inline, or ask to revise/add scenarios.

### Phase 5 — Validation

Before saving, verify:
- No field contains `TODO`, `TBD`, `<placeholder>`, or unchanged template prose.
- Each acceptance criterion is concrete and verifiable — reject vague criteria (e.g., "works correctly", "handles errors properly") and ask the user to restate them observably.

If validation fails, list exactly which fields/criteria need attention. Do not save.

### Phase 6 — Save

1. Copy `kit/templates/user-story.md` and fill it in with the reviewed content.
2. Save to `specs/<feature-slug>.md` (single file per feature), where `<feature-slug>` is the feature name in kebab-case.
3. Create `specs/` if it does not exist.
4. Report the saved file path. No further action (no auto-handoff to other skills).

---

## Template (`kit/templates/user-story.md`)

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

Design notes:
- Multiple `### Scenario:` blocks allow as many scenarios as needed — not fixed at two.
- `Open Questions` is omitted (not filled with invented content) when there are no pending questions.
- Header style (`Date`/`Status`) matches `kit/templates/adr.md` and `kit/templates/spec.md` for consistency across the kit.
- Story and criteria content is written in Portuguese or English matching the user's conversation language; template scaffolding/comments in the kit source stay in English per the repo's language rule (CLAUDE.md).

---

## INDEX.md changes

Add to the "Project Management" table:

```
| `/user-story-writer` | Guide a brainstorming dialogue to write a User Story with Given/When/Then acceptance criteria |
```

Add to "Quick reference: start here", positioned before the existing `/ca-use-case` entry:

```
- **New feature idea to formalize?** → `/user-story-writer`
```

---

## Error Reference

| Situation | Action |
|-----------|--------|
| Feature idea involves multiple actors/alternative flows | Suggest `/ca-use-case`, let user decide |
| Acceptance criterion is vague/unverifiable | Ask user to restate it observably before saving |
| Required field empty or placeholder text | List missing fields, do not save |
| `specs/` does not exist | Create it before saving |
| Feature slug collides with existing `specs/<slug>.md` | Ask user to confirm overwrite or pick a different name |

---

## What NOT to do

- Do not auto-publish or hand off to `issue-writer` — this skill only produces the spec file.
- Do not ask combined multi-part questions — one question at a time, per the brainstorming style.
- Do not force escalation to `/ca-use-case` — advisory only, user decides.
- Do not invent acceptance criteria the user hasn't stated — elicit, don't assume.

---

## Out of Scope

- Publishing to GitHub/GitLab (use `/issue-writer` separately if desired)
- Full Use Case documentation with alternative/exception flows (use `/ca-use-case`)
- Splitting one story into multiple automatically
