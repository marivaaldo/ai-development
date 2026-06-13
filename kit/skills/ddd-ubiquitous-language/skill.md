---
name: ddd-ubiquitous-language
description: Build and enforce shared domain vocabulary between code and domain experts
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Ubiquitous Language

A shared, precise vocabulary used identically by domain experts and in the codebase. When experts use a term, the code uses that exact term — no translation, no synonyms.

## When to invoke

- Naming a new class, method, or field in a domain model
- Reviewing whether code names match domain expert conversations
- Refactoring terminology after a domain discovery session
- Detecting translation gaps (code says `Purchase`, experts say `Order`)

## Core concepts

- **One term, one concept** — no synonyms; pick one word and use it everywhere
- **Code mirrors conversation** — names in the domain layer must come from expert vocabulary
- **Living language** — when experts rename a concept, rename it in code too
- **No leaking technical terms** — the domain layer uses `Invoice`, not `InvoiceEntity` or `InvoiceDTO`

## Implementation checklist

- [ ] Identify the exact term domain experts use (workshop, interview, or documentation)
- [ ] Verify no synonym for the same concept already exists in the codebase
- [ ] Use the domain term verbatim — no abbreviations, no generic suffixes (Manager, Handler, Helper)
- [ ] Update the project glossary with definition, examples, and context
- [ ] Search for old synonyms and rename them across the codebase

## Review checklist

- [ ] Domain layer names match the language domain experts use today
- [ ] No dual terminology for the same concept across the codebase
- [ ] No persistence or framework terms in domain class names
- [ ] Glossary reflects the current state of the model

## Common mistakes

- Using technical suffixes (`InvoiceRecord`, `UserObject`) in domain class names
- Letting synonyms accumulate because renaming "takes too long"
- Silently translating between expert language and code inside methods
- Treating the glossary as a one-time artifact instead of a living document
