# user-story-writer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a new kit skill, `user-story-writer`, that guides a conversational brainstorming dialogue to produce a User Story (Como/Quero/Para que) with Given/When/Then acceptance criteria, saved via a new `kit/templates/user-story.md` template.

**Architecture:** This is a content-only kit repo (no build system, no test runner — per `CLAUDE.md`). "Verification" here means: the new skill file and template are well-formed per the kit's existing conventions, `kit/skills/INDEX.md` is updated consistently, and `scripts/install.sh` (the only executable logic touched by this change) correctly picks up and installs the new skill end-to-end.

**Tech Stack:** Markdown (skill/template content), POSIX shell (`scripts/install.sh`, unchanged but exercised as verification).

**Reference spec:** `docs/superpowers/specs/2026-07-16-user-story-writer-design.md`

---

### Task 1: Create the User Story template

**Files:**
- Create: `kit/templates/user-story.md`

- [ ] **Step 1: Write the template file**

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

- [ ] **Step 2: Verify the file was created correctly**

Run: `cat kit/templates/user-story.md`
Expected: exact content from Step 1, no truncation.

- [ ] **Step 3: Commit**

```bash
git add kit/templates/user-story.md
git commit -m "feat: add user-story.md template"
```

---

### Task 2: Create the user-story-writer skill

**Files:**
- Create: `kit/skills/user-story-writer/skill.md`

- [ ] **Step 1: Write the skill file**

```markdown
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
```

- [ ] **Step 2: Verify frontmatter is well-formed**

Run: `head -n 9 kit/skills/user-story-writer/skill.md`
Expected:
```
---
name: user-story-writer
description: Guide a brainstorming dialogue to write a User Story (Como/Quero/Para que) with Given/When/Then acceptance criteria — one question at a time, escalating to /ca-use-case when the flow proves too complex for a simple story
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---
```

- [ ] **Step 3: Commit**

```bash
git add kit/skills/user-story-writer/skill.md
git commit -m "feat: add user-story-writer skill"
```

---

### Task 3: Register the skill in INDEX.md

**Files:**
- Modify: `kit/skills/INDEX.md:104-107` (Project Management table)
- Modify: `kit/skills/INDEX.md:110-112` (Quick reference list)

- [ ] **Step 1: Add the skill to the "Project Management" table**

Find this block:
```markdown
## Project Management

| Skill | Description |
|---|---|
| `/issue-writer` | Create context-rich GitHub/GitLab issues with enough information for AI agents to implement independently |
```

Replace with:
```markdown
## Project Management

| Skill | Description |
|---|---|
| `/user-story-writer` | Guide a brainstorming dialogue to write a User Story with Given/When/Then acceptance criteria |
| `/issue-writer` | Create context-rich GitHub/GitLab issues with enough information for AI agents to implement independently |
```

- [ ] **Step 2: Add a quick-reference line before the existing `/ca-use-case` entry**

Find this line:
```markdown
- **New feature?** → `/ca-use-case` then `/ddd-aggregate`
```

Replace with:
```markdown
- **New feature idea to formalize?** → `/user-story-writer`
- **New feature?** → `/ca-use-case` then `/ddd-aggregate`
```

- [ ] **Step 3: Verify both edits landed**

Run: `grep -n "user-story-writer" kit/skills/INDEX.md`
Expected: two matches — one in the Project Management table, one in the quick reference list.

- [ ] **Step 4: Commit**

```bash
git add kit/skills/INDEX.md
git commit -m "docs: register user-story-writer in skills index"
```

---

### Task 4: Verify end-to-end install via scripts/install.sh

This exercises the only executable code path this change touches — confirms `install.sh` picks up the new skill with no code changes to the script itself (per `CLAUDE.md`: "install.sh picks it up automatically via `find kit/skills -mindepth 1 -maxdepth 1 -type d`").

**Files:**
- None (verification only, run from a scratch directory so no stray `.claude/` is left in the repo)

- [ ] **Step 1: Run project-scope install into a scratch directory**

```bash
SCRATCH="$(mktemp -d)"
cd "$SCRATCH"
/home/marivaldo/git/ai-development/scripts/install.sh --provider claude --skill user-story-writer --scope project
```

Expected output includes:
```
Installing user-story-writer for claude (project)...
  ✓ Installed to <SCRATCH>/.claude/commands/user-story-writer.md
  ✓ Installed to <SCRATCH>/.claude/skills/user-story-writer/skill.md
```

- [ ] **Step 2: Verify installed content matches source exactly**

```bash
cmp "$SCRATCH/.claude/commands/user-story-writer.md" /home/marivaldo/git/ai-development/kit/skills/user-story-writer/skill.md
cmp "$SCRATCH/.claude/skills/user-story-writer/skill.md" /home/marivaldo/git/ai-development/kit/skills/user-story-writer/skill.md
```

Expected: both commands produce no output (files identical).

- [ ] **Step 3: Clean up the scratch directory**

```bash
cd /home/marivaldo/git/ai-development
rm -rf "$SCRATCH"
```

- [ ] **Step 4: No commit needed** — this task only verifies existing committed files; nothing changes in the repo.

---

## Self-Review Checklist (run before handing off)

- **Spec coverage:** Task 1 covers the template; Task 2 covers all 6 phases from the spec plus the Error Reference and "What NOT to do" sections; Task 3 covers the INDEX.md changes; Task 4 covers the install.sh pickup behavior. No spec section left uncovered.
- **Placeholder scan:** No `TBD`/`TODO` in any task step; the `[Feature Name]`, `[tipo de ator/usuário]`, etc. placeholders are intentional template content, not plan placeholders.
- **Type/name consistency:** `user-story-writer` (skill name), `kit/templates/user-story.md` (template path), `specs/<feature-slug>.md` (output path) are consistent across Task 1, Task 2, and the spec.
