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
