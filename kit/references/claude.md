# Claude Code — Provider Reference

## Installing skills

The installer copies each skill to two locations:

| Path | How it works |
|------|-------------|
| `~/.claude/commands/<name>.md` | Native slash command (`/<name>`), no plugin needed |
| `~/.claude/skills/<name>/skill.md` | Discovered by superpowers `Skill` tool |

For project-local install, replace `~/` with the project root.

## Tool name mapping

| Generic action   | Claude Code tool  |
|------------------|-------------------|
| Read a file      | `Read`            |
| Edit a file      | `Edit`            |
| Write a new file | `Write`           |
| Run a command    | `Bash`            |
| Search files     | `Glob` / `Grep`   |

## Notes

- With superpowers: invoke via `Skill` tool or `/<name>` slash command
- Without superpowers: invoke via `/<name>` slash command only
