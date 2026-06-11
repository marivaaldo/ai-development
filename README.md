# ai-development

A collection of skills, prompts, templates, and patterns for AI-first projects — provider-agnostic (Claude Code, Gemini CLI, Codex, Copilot CLI).

This is not a framework. It is a kit you adopt into your own project, taking only what you need.

## Quick start

**1. Scaffold a new project:**
```bash
git clone <repo-url> ai-development
./ai-development/scripts/init.sh /path/to/your/project
```

**2. Install skills** for your AI provider:
```bash
./ai-development/scripts/install.sh
```
The script detects installed providers, asks which skill to install, and whether to install globally or per-project. Manual reference: `kit/references/`.

**3. Start small.** Open `docs/guide.md` and follow Phase 0 — README, glossary, specs, and ADRs are all you need to begin.

---

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

Skills work with: **Claude Code · Gemini CLI · Codex · Copilot CLI · Windsurf**

See `kit/references/` for provider-specific installation instructions.

## Recommended project structure

See `docs/guide.md` for the full AI-first project evolution guide and `example/` for a working reference.

## When to create each folder

Don't create structure you don't need yet. Use this as a guide:

| Folder         | Create when                                      |
|----------------|--------------------------------------------------|
| `README`       | ✅ Always — day one                              |
| `docs/`        | ✅ Always — day one                              |
| `glossary/`    | ✅ Always — define your domain terms early       |
| `specs/`       | ✅ Always — before implementing any feature      |
| `adr/`         | ✅ Always — record decisions as they happen      |
| `architecture/`| 🟡 Soon — once the system shape is clear         |
| `skills/`      | 🟡 When you find yourself repeating AI prompts   |
| `runbooks/`    | 🟡 When you have recurring operational tasks     |
| `workflows/`   | 🔵 When development processes have stabilized    |
| `rag/`         | 🔵 When you have a large, queryable knowledge base |
| `agents/`      | 🔵 After workflows are defined and working       |
| `mcp/`         | 🔵 When you need AI to integrate with external systems |
