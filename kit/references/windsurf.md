# Windsurf (Devin) — Provider Reference

## Installing skills

Skills are project-scoped only. Place skill files at:

```
.windsurf/skills/<skill-name>/skill.md
```

Use the install script to do this automatically:

```bash
./scripts/install.sh --provider windsurf --skill adr-writer
```

## Tool name mapping

| Generic action   | Windsurf / Cascade tool |
|------------------|-------------------------|
| Read a file      | `read_file`             |
| Edit a file      | `edit_file`             |
| Write a new file | `write_file`            |
| Run a command    | `run_command`           |
| Search files     | `search_files`          |

## Notes

- Windsurf does not support global skill installation — skills are always project-local
- Skill content is provider-agnostic; no changes to `skill.md` are needed
