# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A provider-agnostic kit of skills, prompts, templates, and patterns for AI-first projects. It is not a framework — it is a kit to be adopted into other projects. No build system, no tests, no package manager.

## Scripts

```bash
# Scaffold a new project from the example/ structure
./scripts/init.sh /path/to/target          # Linux/macOS
./scripts/init.ps1 /path/to/target         # Windows

# Install skills into an AI provider's config directory
./scripts/install.sh                       # interactive
./scripts/install.sh --provider claude --skill adr-writer
./scripts/install.sh --provider claude --skill all
```

`install.sh` supports `--provider` (`claude|gemini|codex|windsurf`) and `--skill` (name or `all`). Without flags it prompts interactively.

## Architecture

### Kit layout

```
kit/
  skills/<name>/skill.md    # Provider-agnostic skill definition (frontmatter + instructions)
  fragments/<name>.<provider>.md  # Snippets appended to project config files (CLAUDE.md, GEMINI.md, etc.)
  references/<provider>.md  # Per-provider installation instructions
  templates/                # ADR and spec markdown templates
  prompts/                  # Shared prompt files
```

### How install.sh places skills

For **Claude**: copies `skill.md` to both `~/.claude/commands/<name>.md` (native slash command) and `~/.claude/skills/<name>/skill.md` (superpowers Skill tool discovery). Project scope uses `.claude/` instead of `~/.claude/`.

For **Gemini/Codex/Windsurf**: copies the skill directory into the provider's skills folder and prints manual steps for registering it in `GEMINI.md` / plugin config.

### Fragments

`kit/fragments/<skill>.<provider>.md` are appended to the project's agent config file (`CLAUDE.md`, `GEMINI.md`, `AGENTS.md`) during project-scope installs. Appending is idempotent — skipped if the fragment's first heading is already present.

### Example project

`example/` is a reference project structure copied by `init.sh`. It contains `adr/`, `glossary/`, `specs/`, `prompts/`, `runbooks/`, and `skills/` — the recommended layout described in `docs/guide.md`.

## Skill format

Each skill lives in `kit/skills/<name>/skill.md` with YAML frontmatter:

```yaml
---
name: <slug>
description: <one-line — used by AI to decide relevance>
providers:
  claude: native
  gemini: see kit/references/gemini.md
---
```

The body is the instruction content delivered to the AI at invocation time.

## Script parity rule

`scripts/init.sh` and `scripts/init.ps1` must always be kept in sync. Any change to one — new flags, changed defaults, added steps, updated output messages — must be applied to the other in the same commit. The two scripts are the Linux/macOS and Windows implementations of the same operation; they must stay functionally identical.

Same rule applies if an `install.ps1` is ever added alongside `install.sh`.

## Language

All content in this repository must be written in English: skill files, fragments, templates, prompts, documentation, script output messages, and comments. This is a provider-agnostic kit intended for broad adoption — English is the lingua franca.

## Adding a new skill

1. Create `kit/skills/<name>/skill.md` with frontmatter and instructions.
2. Optionally add `kit/fragments/<name>.<provider>.md` for each provider that needs a project-config snippet.
3. `install.sh` picks it up automatically via `find kit/skills -mindepth 1 -maxdepth 1 -type d`.
