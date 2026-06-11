# Example Project

This directory demonstrates the recommended structure for an AI-first project
that has adopted `ai-development`.

It represents a project at **Phase 1** (architecture consolidated) of the
maturity roadmap in `docs/guide.md`.

## Structure

```text
example/
├── adr/            ← Architecture Decision Records
├── specs/          ← Feature specifications
├── runbooks/       ← Operational procedures
├── glossary/       ← Domain terminology
├── skills/         ← Project-specific AI skills
└── prompts/        ← Shared prompts
```

## Using this as a starting point

```bash
# From the ai-development root:
./scripts/init.sh /path/to/your/new-project
```

Or copy manually — you own the structure, customize freely.
