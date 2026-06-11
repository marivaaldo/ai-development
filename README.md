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
