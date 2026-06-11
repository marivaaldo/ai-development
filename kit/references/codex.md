# Codex / Copilot CLI — Provider Reference

## Installing skills

Skills are referenced via the `skill` tool in Copilot CLI.
Skills are auto-discovered from installed plugins.

## Tool name mapping

| Generic action   | Copilot CLI tool  |
|------------------|-------------------|
| Read a file      | `read_file`       |
| Edit a file      | `edit_file`       |
| Write a new file | `write_file`      |
| Run a command    | `run_command`     |
| Search files     | `search_files`    |

## Notes

- The `skill` tool works the same as Claude Code's `Skill` tool
- Skills invoke before any response or action
