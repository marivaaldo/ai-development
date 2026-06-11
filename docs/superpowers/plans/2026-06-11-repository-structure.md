# Repository Structure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold the `ai-development` repository with the full directory structure, README, docs, templates, skills skeleton, and scripts defined in the design spec.

**Architecture:** Provider-agnostic kit (`kit/`) holds all reusable artefacts; `docs/` holds guides and patterns; `example/` is a live working example of the structure a consuming project should adopt; `scripts/` provides init and index-generation automation.

**Tech Stack:** Markdown, Bash (POSIX sh for scripts), Git

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `README.md` | Modify | Root entry point for humans and AI agents |
| `docs/guide.md` | Create (move `guide.md`) | AI-first project evolution guide |
| `docs/adr-pattern.md` | Create | ADR format and token-efficient read strategy |
| `docs/skills-pattern.md` | Create | How to write provider-agnostic skills for this repo |
| `docs/adoption.md` | Create | How to adopt this repo in a project |
| `kit/skills/adr-writer/skill.md` | Create | ADR writer skill (provider-agnostic) |
| `kit/skills/code-review/skill.md` | Create | Code review skill skeleton |
| `kit/skills/architecture-review/skill.md` | Create | Architecture review skill skeleton |
| `kit/prompts/adr.md` | Create | ADR creation prompt |
| `kit/prompts/code-review.md` | Create | Code review prompt |
| `kit/templates/adr.md` | Create | ADR file template |
| `kit/templates/spec.md` | Create | Spec file template |
| `kit/references/claude.md` | Create | Claude Code installation/usage guide |
| `kit/references/gemini.md` | Create | Gemini CLI usage guide |
| `kit/references/codex.md` | Create | Codex/Copilot usage guide |
| `example/README.md` | Create | Example project README |
| `example/adr/INDEX.md` | Create | ADR index template (empty table) |
| `example/glossary/README.md` | Create | Glossary placeholder |
| `example/specs/README.md` | Create | Specs placeholder |
| `example/runbooks/README.md` | Create | Runbooks placeholder |
| `example/skills/README.md` | Create | Skills placeholder |
| `example/prompts/README.md` | Create | Prompts placeholder |
| `scripts/init.sh` | Create | Copies example/ into a target directory |
| `scripts/update-adr-index.sh` | Create | Regenerates adr/INDEX.md from all ADR headers |

---

## Task 1: Move guide.md to docs/ and update README

**Files:**
- Modify: `README.md`
- Create: `docs/guide.md` (from existing `guide.md`)

- [ ] **Step 1: Move guide.md into docs/**

```bash
mkdir -p docs
git mv guide.md docs/guide.md
```

- [ ] **Step 2: Verify move**

```bash
ls docs/guide.md
```
Expected: file present.

- [ ] **Step 3: Rewrite README.md**

Replace entire content of `README.md` with:

```markdown
# ai-development

Provider-agnostic collection of skills, prompts, templates, and patterns for AI-first projects.

## Contents

| Folder      | Purpose                                            |
|-------------|----------------------------------------------------|
| `kit/`      | Reusable skills, prompts, templates, references    |
| `docs/`     | Guides and patterns (ADR, skills, adoption)        |
| `example/`  | Live example of the recommended project structure  |
| `scripts/`  | Automation (project init, ADR index generation)    |

## How to adopt

**Manual copy:** Clone and copy what you need from `kit/` and `example/`

**Script:**
```bash
./scripts/init.sh /path/to/your/project
```

**Git submodule:**
```bash
git submodule add <repo-url> ai-development
```

## Supported providers

Skills work with: **Claude Code · Gemini CLI · Codex · Copilot CLI**

See `kit/references/` for provider-specific installation instructions.

## Recommended project structure

See `docs/guide.md` for the full AI-first project evolution guide and `example/` for a working reference.
```

- [ ] **Step 4: Commit**

```bash
git add README.md docs/guide.md
git commit -m "feat: move guide to docs/ and rewrite README"
```

---

## Task 2: Create docs/ pattern files

**Files:**
- Create: `docs/adr-pattern.md`
- Create: `docs/skills-pattern.md`
- Create: `docs/adoption.md`

- [ ] **Step 1: Create docs/adr-pattern.md**

```markdown
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
| 0001 | Architecture   | DDD                    | Organização por domínio          |
| 0002 | Infrastructure | PostgreSQL             | Banco relacional principal       |
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
```

- [ ] **Step 2: Create docs/skills-pattern.md**

```markdown
# Skills Pattern

Skills in `kit/skills/` are provider-agnostic. They are written once and work
across Claude Code, Gemini CLI, Codex, and Copilot CLI.

## File structure

```text
kit/skills/<name>/
└── skill.md
```

## Frontmatter

Every skill starts with YAML frontmatter:

```yaml
---
name: skill-name
description: One-line description — used by the provider to decide when to invoke this skill
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
---
```

## Writing provider-agnostic content

- Use generic action language: "read file", "edit file", "run command"
- Do not reference provider-specific tool names (e.g. avoid "use the Bash tool")
- When a step requires provider-specific behavior, add a note:
  `> Provider note: see kit/references/ for how to run shell commands on your provider.`

## Provider references

`kit/references/<provider>.md` explains:
- How to install/register skills for that provider
- Tool name equivalents (e.g. Claude's `Bash` = Gemini's `run_shell_command`)
- Any behavioral differences to be aware of

## Naming conventions

- Skill folder: `kebab-case`
- Skill name in frontmatter: `kebab-case`
- Description: imperative, ≤ 12 words
```

- [ ] **Step 3: Create docs/adoption.md**

```markdown
# Adopting ai-development in Your Project

## Option 1 — Manual copy

Best for: one-off projects, trying things out.

```bash
git clone <repo-url> ai-development
cp -r ai-development/kit/skills/ your-project/skills/
cp -r ai-development/kit/prompts/ your-project/prompts/
cp -r ai-development/kit/templates/ your-project/templates/
```

Copy only what you need. No ongoing sync.

## Option 2 — Init script

Best for: new projects that want the full recommended structure.

```bash
./scripts/init.sh /path/to/your/project
```

This copies the `example/` directory structure into your project and initializes
empty placeholder files. You own the result — no dependency on this repo.

## Option 3 — Git submodule

Best for: teams that want to pull updates as the collection evolves.

```bash
git submodule add <repo-url> .ai-development
```

Reference skills directly from the submodule path, or symlink into your project.

## Option 4 — Combination

Submodule for active skills and prompts (get updates), manual copy for
docs and templates (own and customize locally).

## After adopting

1. Copy `example/adr/INDEX.md` to your `adr/INDEX.md`
2. Install the `adr-writer` skill for your provider (see `kit/references/`)
3. Start with Phase 0 of `docs/guide.md` — don't create structure you don't need yet
```

- [ ] **Step 4: Commit**

```bash
git add docs/adr-pattern.md docs/skills-pattern.md docs/adoption.md
git commit -m "feat: add docs pattern files (adr, skills, adoption)"
```

---

## Task 3: Create kit/ structure — skills

**Files:**
- Create: `kit/skills/adr-writer/skill.md`
- Create: `kit/skills/code-review/skill.md`
- Create: `kit/skills/architecture-review/skill.md`

- [ ] **Step 1: Create kit/skills/adr-writer/skill.md**

```markdown
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
```

- [ ] **Step 2: Create kit/skills/code-review/skill.md**

```markdown
---
name: code-review
description: Review code changes for correctness, clarity, and consistency
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
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
```

- [ ] **Step 3: Create kit/skills/architecture-review/skill.md**

```markdown
---
name: architecture-review
description: Review a proposed or existing architecture for soundness and alignment with ADRs
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
---

# Architecture Review

Review an architectural proposal or existing system architecture.

## Before reviewing

1. Read `adr/INDEX.md`
2. Read headers of relevant ADRs
3. Understand the bounded contexts and their boundaries

## What to evaluate

1. **Alignment with decisions** — does the architecture follow existing ADRs?
2. **Boundaries** — are responsibilities clearly separated?
3. **Dependencies** — are dependency directions intentional and documented?
4. **Scalability concerns** — are there obvious bottlenecks for the stated scale?
5. **Missing decisions** — are there open architectural questions that should become ADRs?

## Output format

- Summary of what was reviewed
- Findings (aligned / misaligned / unclear) per ADR
- Open questions that should become ADRs
- Recommendation: approve | approve with notes | needs revision
```

- [ ] **Step 4: Commit**

```bash
git add kit/skills/
git commit -m "feat: add adr-writer, code-review, architecture-review skills"
```

---

## Task 4: Create kit/ structure — prompts and templates

**Files:**
- Create: `kit/prompts/adr.md`
- Create: `kit/prompts/code-review.md`
- Create: `kit/templates/adr.md`
- Create: `kit/templates/spec.md`

- [ ] **Step 1: Create kit/prompts/adr.md**

```markdown
# ADR Prompt

Use this prompt when you want to create an ADR without using the full adr-writer skill.

---

Create an Architecture Decision Record for the following decision:

**Decision topic:** [describe the decision]

**Context:** [what situation requires this decision]

Follow the project's ADR format from `docs/adr-pattern.md`.
Before writing, read `adr/INDEX.md` to identify the next number and any related ADRs.
After writing, append a row to `adr/INDEX.md`.
```

- [ ] **Step 2: Create kit/prompts/code-review.md**

```markdown
# Code Review Prompt

Use this prompt for a quick code review without the full code-review skill.

---

Review the following code/diff for:
1. Correctness — logic bugs, missing edge cases
2. Consistency — follows codebase patterns
3. Security — no injection, no exposed secrets

For each issue found, state: file:line, severity (critical/warning/suggestion), and a concrete fix.
```

- [ ] **Step 3: Create kit/templates/adr.md**

```markdown
# ADR-XXXX

Title: 
Status: Proposed
Category: 
Tags: []
Keywords: 
Summary: 
Related: 
Date: YYYY-MM-DD

---

## Context



## Decision



## Consequences



## Alternatives Considered

1. **Option A** — rejected because ...
2. **Option B** — rejected because ...
```

- [ ] **Step 4: Create kit/templates/spec.md**

```markdown
# Spec: [Feature Name]

Date: YYYY-MM-DD
Status: Draft | Approved

---

## Overview

[One paragraph describing what this feature does and why it exists]

## Requirements

- [ ] Requirement 1
- [ ] Requirement 2

## Out of Scope

- Item 1
- Item 2

## Technical Notes

[Architecture decisions, constraints, dependencies]

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
```

- [ ] **Step 5: Commit**

```bash
git add kit/prompts/ kit/templates/
git commit -m "feat: add prompts and templates to kit/"
```

---

## Task 5: Create kit/references/

**Files:**
- Create: `kit/references/claude.md`
- Create: `kit/references/gemini.md`
- Create: `kit/references/codex.md`

- [ ] **Step 1: Create kit/references/claude.md**

```markdown
# Claude Code — Provider Reference

## Installing skills

Place skill files in `~/.claude/skills/<skill-name>/skill.md` for global use,
or `.claude/skills/<skill-name>/skill.md` for project-local use.

Invoke via the `Skill` tool or `/skill-name` slash command in Claude Code.

## Tool name mapping

| Generic action     | Claude Code tool |
|--------------------|-----------------|
| Read a file        | `Read`          |
| Edit a file        | `Edit`          |
| Write a new file   | `Write`         |
| Run a command      | `Bash`          |
| Search files       | `Glob` / `Grep` |

## Notes

- Skills loaded from `~/.claude/skills/` are available in all projects
- Skills in `.claude/skills/` are project-local
- The `Skill` tool loads skill content on demand — always read current version
```

- [ ] **Step 2: Create kit/references/gemini.md**

```markdown
# Gemini CLI — Provider Reference

## Installing skills

Skills are loaded via GEMINI.md or the `activate_skill` tool.
Place skill content where GEMINI.md can reference it.

## Tool name mapping

| Generic action     | Gemini CLI tool            |
|--------------------|---------------------------|
| Read a file        | `read_file`               |
| Edit a file        | `replace_in_file`         |
| Write a new file   | `write_file`              |
| Run a command      | `run_shell_command`       |
| Search files       | `find_files` / `grep`     |

## Notes

- Gemini CLI loads skill metadata at session start
- Full skill content is activated on demand via `activate_skill`
```

- [ ] **Step 3: Create kit/references/codex.md**

```markdown
# Codex / Copilot CLI — Provider Reference

## Installing skills

Skills are referenced via the `skill` tool in Copilot CLI.
Skills are auto-discovered from installed plugins.

## Tool name mapping

| Generic action     | Copilot CLI tool           |
|--------------------|---------------------------|
| Read a file        | `read_file`               |
| Edit a file        | `edit_file`               |
| Write a new file   | `write_file`              |
| Run a command      | `run_command`             |
| Search files       | `search_files`            |

See `references/copilot-tools.md` in the Superpowers plugin for full mapping.

## Notes

- The `skill` tool works the same as Claude Code's `Skill` tool
- Skills invoke before any response or action
```

- [ ] **Step 4: Commit**

```bash
git add kit/references/
git commit -m "feat: add provider references (claude, gemini, codex)"
```

---

## Task 6: Create example/ directory

**Files:**
- Create: `example/README.md`
- Create: `example/adr/INDEX.md`
- Create: `example/glossary/README.md`
- Create: `example/specs/README.md`
- Create: `example/runbooks/README.md`
- Create: `example/skills/README.md`
- Create: `example/prompts/README.md`
- Create subdirectories: `example/adr/architecture/`, `example/adr/infrastructure/`, `example/adr/ai/`, `example/adr/product/`

- [ ] **Step 1: Create example/README.md**

```markdown
# Example Project

This directory demonstrates the recommended structure for an AI-first project
that has adopted `ai-development`.

It represents a project at **Phase 1** (architecture consolidated) of the
maturity roadmap in `docs/guide.md`.

## Structure

```text
example/
├── adr/            ← Architecture Decision Records
├── specs/          ← Feature specifications
├── runbooks/       ← Operational procedures
├── glossary/       ← Domain terminology
├── skills/         ← Project-specific AI skills
└── prompts/        ← Shared prompts
```

## Using this as a starting point

```bash
# From the ai-development root:
./scripts/init.sh /path/to/your/new-project
```

Or copy manually — you own the structure, customize freely.
```

- [ ] **Step 2: Create example/adr/INDEX.md**

```markdown
# ADR Index

| ADR  | Category       | Title | Summary |
|------|----------------|-------|---------|

<!-- This file is maintained by the adr-writer skill. -->
<!-- Run scripts/update-adr-index.sh to regenerate from existing ADR headers. -->
```

- [ ] **Step 3: Create placeholder READMEs**

`example/glossary/README.md`:
```markdown
# Glossary

Define domain terms here. Each entry should be unambiguous and stable.

## Format

```text
**Term:** Definition in one or two sentences.
```

## Why this matters

Consistent terminology reduces ambiguity for both humans and AI agents
working in the codebase.
```

`example/specs/README.md`:
```markdown
# Specs

Feature specifications live here. Use the template at `kit/templates/spec.md`.

## Structure

```text
specs/
└── feature-name/
    ├── requirements.md
    ├── acceptance-criteria.md
    └── technical-notes.md
```

Every relevant new feature should have a spec before implementation begins.
```

`example/runbooks/README.md`:
```markdown
# Runbooks

Operational procedures live here. Write a runbook when a procedure:
- Is done more than once
- Involves multiple steps
- Has a non-obvious order or preconditions

## Examples

- `deployment.md`
- `rollback.md`
- `rotate-secrets.md`
- `incident-response.md`
```

`example/skills/README.md`:
```markdown
# Skills

Project-specific AI skills live here. These complement the shared skills
in `kit/skills/` but are tailored to this project's domain.

## Format

Follow the pattern in `docs/skills-pattern.md`.

```text
skills/
└── <skill-name>/
    └── skill.md
```
```

`example/prompts/README.md`:
```markdown
# Prompts

Shared prompts for this project. These are simpler than full skills —
use them for one-off or infrequent tasks.

Base prompts are available in `kit/prompts/`.
```

- [ ] **Step 4: Create ADR subdirectory placeholders**

Create `.gitkeep` files to preserve empty directories:

```bash
mkdir -p example/adr/architecture example/adr/infrastructure example/adr/ai example/adr/product
touch example/adr/architecture/.gitkeep
touch example/adr/infrastructure/.gitkeep
touch example/adr/ai/.gitkeep
touch example/adr/product/.gitkeep
```

- [ ] **Step 5: Commit**

```bash
git add example/
git commit -m "feat: add example/ directory with recommended project structure"
```

---

## Task 7: Create scripts/

**Files:**
- Create: `scripts/init.sh`
- Create: `scripts/update-adr-index.sh`

- [ ] **Step 1: Create scripts/init.sh**

```bash
#!/usr/bin/env sh
# Copies the example/ project structure into a target directory.
# Usage: ./scripts/init.sh /path/to/target

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EXAMPLE_DIR="$REPO_ROOT/example"

TARGET="$1"

if [ -z "$TARGET" ]; then
  echo "Usage: $0 <target-directory>" >&2
  exit 1
fi

if [ ! -d "$EXAMPLE_DIR" ]; then
  echo "Error: example/ directory not found at $EXAMPLE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET"

cp -r "$EXAMPLE_DIR/." "$TARGET/"

# Remove .gitkeep files — they exist only to preserve empty dirs in git
find "$TARGET" -name ".gitkeep" -delete

echo "Project structure initialized at: $TARGET"
echo "Next steps:"
echo "  1. Review docs/guide.md for the maturity roadmap"
echo "  2. Install the adr-writer skill (see kit/references/ for your provider)"
echo "  3. Start with Phase 0 — don't create structure you don't need yet"
```

- [ ] **Step 2: Make init.sh executable**

```bash
chmod +x scripts/init.sh
```

- [ ] **Step 3: Create scripts/update-adr-index.sh**

```bash
#!/usr/bin/env sh
# Regenerates adr/INDEX.md from the headers of all ADR files.
# Run from the root of a project that uses the ADR pattern.
# Usage: ./scripts/update-adr-index.sh [adr-dir]
#
# Reads the first 25 lines of each ADR file to extract:
#   Title, Category, Summary
# Writes adr/INDEX.md with a full table.

set -e

ADR_DIR="${1:-adr}"

if [ ! -d "$ADR_DIR" ]; then
  echo "Error: ADR directory not found: $ADR_DIR" >&2
  exit 1
fi

INDEX_FILE="$ADR_DIR/INDEX.md"

# Header
cat > "$INDEX_FILE" <<'EOF'
# ADR Index

| ADR  | Category | Title | Summary |
|------|----------|-------|---------|
EOF

# Find all ADR markdown files, sorted numerically
find "$ADR_DIR" -name "*.md" ! -name "INDEX.md" | sort | while read -r file; do
  # Extract ADR number from filename (e.g. 0021-qdrant.md → 0021)
  filename="$(basename "$file" .md)"
  adr_number="$(echo "$filename" | grep -oE '^[0-9]+')"
  [ -z "$adr_number" ] && continue

  # Read first 25 lines for header fields
  header="$(head -25 "$file")"

  title="$(echo "$header" | grep -i '^Title:' | sed 's/^[Tt]itle: *//')"
  category="$(echo "$header" | grep -i '^Category:' | sed 's/^[Cc]ategory: *//')"
  summary="$(echo "$header" | grep -i '^Summary:' | sed 's/^[Ss]ummary: *//')"

  [ -z "$title" ] && title="(no title)"
  [ -z "$category" ] && category="(no category)"
  [ -z "$summary" ] && summary="(no summary)"

  echo "| $adr_number | $category | $title | $summary |" >> "$INDEX_FILE"
done

echo "INDEX.md regenerated at $INDEX_FILE"
```

- [ ] **Step 4: Make update-adr-index.sh executable**

```bash
chmod +x scripts/update-adr-index.sh
```

- [ ] **Step 5: Commit**

```bash
git add scripts/
git commit -m "feat: add init.sh and update-adr-index.sh scripts"
```

---

## Task 8: Final verification

- [ ] **Step 1: Verify full directory tree**

```bash
find . -not -path './.git/*' -not -path './docs/superpowers/*' | sort
```

Expected output includes:
```
./README.md
./docs/guide.md
./docs/adr-pattern.md
./docs/skills-pattern.md
./docs/adoption.md
./example/README.md
./example/adr/INDEX.md
./example/adr/architecture/
./example/adr/infrastructure/
./example/adr/ai/
./example/adr/product/
./example/glossary/README.md
./example/prompts/README.md
./example/runbooks/README.md
./example/skills/README.md
./example/specs/README.md
./kit/prompts/adr.md
./kit/prompts/code-review.md
./kit/references/claude.md
./kit/references/codex.md
./kit/references/gemini.md
./kit/skills/adr-writer/skill.md
./kit/skills/architecture-review/skill.md
./kit/skills/code-review/skill.md
./kit/templates/adr.md
./kit/templates/spec.md
./scripts/init.sh
./scripts/update-adr-index.sh
```

- [ ] **Step 2: Test init.sh**

```bash
./scripts/init.sh /tmp/test-project
ls /tmp/test-project
```

Expected: `adr/ glossary/ prompts/ runbooks/ skills/ specs/ README.md` — no `.gitkeep` files.

- [ ] **Step 3: Test update-adr-index.sh on example/**

```bash
./scripts/update-adr-index.sh example/adr
cat example/adr/INDEX.md
```

Expected: INDEX.md with header and empty table (no ADRs exist yet).

- [ ] **Step 4: Clean up test output**

```bash
rm -rf /tmp/test-project
```

- [ ] **Step 5: Final commit**

```bash
git add -A
git status
# Verify nothing unexpected is staged
git commit -m "chore: verify full structure complete"
```
