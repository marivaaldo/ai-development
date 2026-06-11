# Gemini CLI — Provider Reference

## Installing skills

Skills are loaded via `GEMINI.md` or the `activate_skill` tool.
Place skill content where `GEMINI.md` can reference it.

## Tool name mapping

| Generic action   | Gemini CLI tool        |
|------------------|------------------------|
| Read a file      | `read_file`            |
| Edit a file      | `replace_in_file`      |
| Write a new file | `write_file`           |
| Run a command    | `run_shell_command`    |
| Search files     | `find_files` / `grep`  |

## Notes

- Gemini CLI loads skill metadata at session start
- Full skill content is activated on demand via `activate_skill`
