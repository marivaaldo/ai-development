# Adopting ai-development in Your Project

## Option 1 — Manual copy

Best for: one-off projects, trying things out.

```bash
git clone <repo-url> ai-development
cp -r ai-development/kit/skills/ your-project/skills/
cp -r ai-development/kit/prompts/ your-project/prompts/
cp -r ai-development/kit/templates/ your-project/templates/
```

Copy only what you need. No ongoing sync.

## Option 2 — Init script

Best for: new projects that want the full recommended structure.

```bash
./scripts/init.sh /path/to/your/project
```

This copies the `example/` directory structure into your project and initializes
empty placeholder files. You own the result — no dependency on this repo.

## Option 3 — Git submodule

Best for: teams that want to pull updates as the collection evolves.

```bash
git submodule add <repo-url> .ai-development
```

Reference skills directly from the submodule path, or symlink into your project.

## Option 4 — Combination

Submodule for active skills and prompts (get updates), manual copy for
docs and templates (own and customize locally).

## After adopting

1. Copy `example/adr/INDEX.md` to your `adr/INDEX.md`
2. Install the `adr-writer` skill for your provider (see `kit/references/`)
3. Start with Phase 0 of `docs/guide.md` — don't create structure you don't need yet
