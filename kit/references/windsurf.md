# Windsurf — Provider Reference

## Directory structure

| Scope   | Path |
|---------|------|
| Project | `.windsurf/` |
| Global  | `~/.codeium/windsurf/` |

Skills, workflows (commands), and other configuration live inside these directories.

## Installing skills

### Project-scoped

Place skill files at:

```
.windsurf/skills/<skill-name>/skill.md
```

Use the install script to do this automatically:

```bash
./scripts/install.sh --provider windsurf --scope project --skill adr-writer
```

### Global (available in all workspaces)

Place skill files at:

```
~/.codeium/windsurf/skills/<skill-name>/skill.md
```

Pass `--scope global` to the install script:

```bash
./scripts/install.sh --provider windsurf --scope global --skill adr-writer
```

## Workflows (commands)

Windsurf uses **workflows** instead of slash commands. Place workflow files at:

- Project: `.windsurf/workflows/<workflow-name>.md`
- Global: `~/.codeium/windsurf/workflows/<workflow-name>.md`

## Tool name mapping

| Generic action   | Windsurf / Cascade tool |
|------------------|-------------------------|
| Read a file      | `read_file`             |
| Edit a file      | `edit_file`             |
| Write a new file | `write_file`            |
| Run a command    | `run_command`           |
| Search files     | `search_files`          |

## Notes

- Skill content is provider-agnostic; no changes to `skill.md` are needed
