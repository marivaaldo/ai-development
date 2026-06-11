# Claude Code — Provider Reference

## Installing skills

Place skill files in `~/.claude/skills/<skill-name>/skill.md` for global use,
or `.claude/skills/<skill-name>/skill.md` for project-local use.

Invoke via the `Skill` tool or `/<skill-name>` slash command in Claude Code.

## Tool name mapping

| Generic action   | Claude Code tool  |
|------------------|-------------------|
| Read a file      | `Read`            |
| Edit a file      | `Edit`            |
| Write a new file | `Write`           |
| Run a command    | `Bash`            |
| Search files     | `Glob` / `Grep`   |

## Notes

- Skills loaded from `~/.claude/skills/` are available in all projects
- Skills in `.claude/skills/` are project-local
- The `Skill` tool loads skill content on demand — always reads the current version
