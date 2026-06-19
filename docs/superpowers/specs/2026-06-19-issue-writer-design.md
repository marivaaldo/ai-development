# issue-writer — Design Spec

Date: 2026-06-19
Status: Approved

---

## Overview

A single skill `issue-writer` that guides the creation of context-rich issues for AI agent implementation. Covers the full cycle: intent declaration → technical context extraction → preview → publication.

**Core principle:** The agent pre-fills everything it can infer from the codebase. It only asks the human for input on fields it genuinely cannot deduce. It presents a complete draft for review, not a blank form.

---

## Phases

### Phase 1 — Intent (human declares)

The human provides:
- Issue type: bug / feature / task / chore
- Provisional title
- Motivation in one sentence

If these can be inferred from a branch name, recent commit, or open TODO in code, the agent suggests them and asks for confirmation instead of asking from scratch.

### Phase 2 — Context Extraction (agent executes)

The agent runs the following before drafting, in order:

1. **Detect provider** — `git remote get-url origin` → identifies `github.com` or `gitlab.com`, selects `gh` or `glab`
2. **Understand codebase** — `git log --oneline -20`, directory structure, languages present
3. **Find relevant files** — grep by title/topic to locate affected modules
4. **Current behavior** — reads found files to describe the present state of the code
5. **Dependencies** — identifies imports, external calls, related services
6. **Related history** — `git log --all --grep="<topic>"` for prior issues/commits in the same context
7. **Infer labels** — detects change type (UI, API, DB, infra) and suggests labels consistent with the repo (`gh label list` / `glab label list`)
8. **Infer size** — estimates based on number of affected files and apparent complexity

### Phase 3 — Generation and Preview (agent generates, human reviews)

Agent produces the complete filled template and presents it. The human can:
- Approve as-is
- Edit specific fields inline
- Ask the agent to expand or revise a section

The agent does not ask field-by-field questions. It presents the full draft and waits for feedback.

### Phase 4 — Publication (agent executes with confirmation)

1. Validates all required fields are filled and non-generic
2. Shows final markdown preview
3. Asks for explicit confirmation before publishing
4. Publishes via the detected method (see Publication section)
5. Returns the created issue URL

---

## Issue Template

Fields marked `*` are required. The skill refuses to publish if they are empty or contain placeholder text.

```markdown
## Context and Motivation *
<Why does this issue exist? What problem does it solve or opportunity does it capture?>

## Type *
[ ] Bug  [ ] Feature  [ ] Task  [ ] Chore

## Current Behavior / Current Situation *
<What happens today? What is the state of the system before this change?>

## Expected Behavior / Desired Outcome *
<What should happen after implementation?>

## Acceptance Criteria *
- [ ] <verifiable criterion 1>
- [ ] <verifiable criterion 2>

## Out of Scope *
<What is deliberately excluded from this issue to maintain focus?>

## Relevant Files and Modules
<Paths, functions, classes the agent should know before starting>

## Dependencies and Impacts
<Related issues, affected services, regression risks>

## Technical Approach Suggestion
<Optional: implementation direction without over-prescribing>

## Estimated Size
[ ] XS (< 1h)  [ ] S (1-4h)  [ ] M (4-8h)  [ ] L (> 1 day)

## Labels
<e.g.: bug, enhancement, ai-ready, needs-refinement>
```

**Agent fills automatically:** relevant files/modules (via grep/git), dependencies (via git log + imports), current behavior (via code reading), labels (via repo label list + inference), estimated size (via affected file count and complexity).

**Human confirms/adjusts:** acceptance criteria, out-of-scope definition, technical approach suggestion, estimated size. The agent pre-populates these with suggestions — the human edits rather than invents from scratch.

---

## Publication

The skill attempts publication in the following priority order:

### 1. CLI (preferred)

- GitHub: `gh issue create --title "..." --body "..." --label "..." `
- GitLab: `glab issue create --title "..." --description "..."`
- Requires: CLI installed and authenticated (`gh auth status` / `glab auth status`)
- On auth failure: instructs user to run `gh auth login` / `glab auth login`

### 2. MCP (fallback when CLI unavailable)

- GitHub: `mcp__github` tools
- GitLab: `mcp__gitlab` tools
- Used automatically when CLI is not available in the environment (e.g., cloud agents)

### 3. File fallback (when neither CLI nor MCP available)

- Saves draft to `docs/issues/<timestamp>-<slug>.md`
- Instructs the user to publish manually
- Does not lose any filled content

### Pre-publication validation

- All `*` fields are non-empty and non-generic (rejects fields containing: `TODO`, `TBD`, `<placeholder>`, raw angle-bracket tokens like `<text>`, or unchanged template prose)
- Provider detected correctly from git remote
- Labels suggested from existing repo labels only — no new labels created automatically

---

## Error Handling

| Situation | Behavior |
|-----------|----------|
| CLI not installed | Falls back to MCP silently |
| MCP not available | Falls back to file draft |
| Required field empty | Lists missing fields, does not publish |
| API error during publish | Saves draft to `docs/issues/`, reports error |
| No git remote detected | Asks user to specify provider manually |
| No `docs/issues/` directory | Creates it before saving |

---

## Provider Detection

```
git remote get-url origin
  → contains "github.com"  → use gh / mcp__github
  → contains "gitlab.com"  → use glab / mcp__gitlab
  → neither / multiple     → ask user to confirm provider
```

---

## Out of Scope

- Creating labels that don't exist in the repo
- Splitting one issue into multiple automatically
- Integration with project management tools (Linear, Jira, etc.)
- Issue templates defined in `.github/ISSUE_TEMPLATE/` (skill uses its own template)
