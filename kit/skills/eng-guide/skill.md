---
name: eng-guide
description: Choose the right engineering practice skill for your current problem
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Engineering Practices Guide

A decision guide for selecting the right engineering practice skill. Describe your problem and get directed to the most relevant skill.

## Available Engineering Practice skills

| Skill | Use when |
|---|---|
| `/eng-security-review` | Reviewing for injection, auth, secrets, or input validation issues |
| `/eng-lgpd` | Handling personal data, retention, anonymization, or data subject rights |
| `/eng-api-design` | Designing or reviewing REST endpoints, versioning, pagination, status codes |
| `/eng-db-migration` | Writing or reviewing a database schema migration |
| `/eng-testing-strategy` | Designing a test suite or reviewing test quality |
| `/eng-observability` | Adding logging, metrics, or tracing to a service |
| `/eng-twelve-factor` | Reviewing a service for cloud-native and deployment readiness |
| `/eng-cicd-review` | Reviewing or building a CI/CD pipeline |

## Quick decision tree

**I need to review security →**
- Code-level vulnerabilities (injection, auth, secrets)? → `/eng-security-review`
- Personal data, privacy, LGPD compliance? → `/eng-lgpd`

**I need to design or review an API →** `/eng-api-design`

**I need to change the database schema →** `/eng-db-migration`

**I need to write or review tests →** `/eng-testing-strategy`
- For Clean Architecture layer-specific testing: also see `/ca-testing-strategy`

**I need to add observability →** `/eng-observability`
- Personal data in logs? Also see `/eng-lgpd`

**I need to prepare a service for production or cloud →** `/eng-twelve-factor`

**I need to review or build a CI/CD pipeline →** `/eng-cicd-review`

## Cross-skill combinations

Some problems touch multiple skills:

| Problem | Skills to combine |
|---|---|
| New feature with personal data | `/eng-security-review` + `/eng-lgpd` + `/eng-observability` |
| New REST API | `/eng-api-design` + `/eng-security-review` + `/eng-testing-strategy` |
| Database migration on large table | `/eng-db-migration` + `/eng-observability` (monitor locks) |
| New microservice | `/eng-twelve-factor` + `/eng-cicd-review` + `/eng-observability` |
| Security hardening sprint | `/eng-security-review` + `/eng-lgpd` + `/eng-cicd-review` |

## Other skill families

- **DDD patterns** (Vaughn Vernon) → `/ddd-guide`
- **Clean Architecture** (Robert C. Martin) → `/ca-guide`
- **Architecture Decision Records** → `/adr-writer`, `/adr-reader`
- **Code review** → `/code-review`
