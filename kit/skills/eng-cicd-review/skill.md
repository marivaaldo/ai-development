---
name: eng-cicd-review
description: Review CI/CD pipelines for quality gates, security scanning, and secrets hygiene
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# CI/CD Pipeline Review

A CI/CD pipeline is a security and quality boundary. This skill reviews pipeline configurations for required quality gates, security scanning (SAST, SCA, secrets), artifact integrity, and branch protection.

## When to invoke

- Reviewing a new or modified pipeline configuration
- Evaluating a pipeline before a team starts shipping to production
- Adding security scanning or quality gates to an existing pipeline
- Diagnosing why a failing gate is being bypassed or ignored

## Core concepts

### Required pipeline stages

A production-grade pipeline should include, in order:

| Stage | What it checks |
|---|---|
| **Lint / format** | Code style; catches trivial issues fast |
| **Unit tests** | Business logic correctness |
| **Integration tests** | Component interactions; may require services |
| **SAST** | Static Application Security Testing — code-level vulnerabilities |
| **SCA** | Software Composition Analysis — known CVEs in dependencies |
| **Secret scanning** | Credentials or tokens committed to the repository |
| **Build / package** | Produces the deployable artifact |
| **Deploy to staging** | Smoke test against a real environment |
| **Deploy to production** | Gated; requires all above stages to pass |

### SAST (Static Application Security Testing)

Analyzes source code for patterns that indicate vulnerabilities (injection, insecure deserialization, path traversal, etc.) without executing the code. Must run on every push to a protected branch.

### SCA (Software Composition Analysis)

Checks third-party dependencies against known vulnerability databases (NVD, OSV, GitHub Advisory). Block on CRITICAL or HIGH severity by default; review MEDIUM manually.

### Secret scanning

Detects credentials, API keys, and tokens committed to source code. Must run before code is merged. Never use `--no-verify` to bypass pre-commit hooks.

> **Platform note (GitLab CI):** Use `include: template: Security/SAST.gitlab-ci.yml` and `template: Security/Dependency-Scanning.gitlab-ci.yml` for built-in scanning. Store secrets in **CI/CD Variables** (masked + protected); never use `variables:` in `.gitlab-ci.yml` for sensitive values. Use `rules: - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH` to gate production deployments. Use `needs:` to express explicit job dependencies and enable parallel execution. Protected branches should require a passing pipeline and at least one approval before merge.

### Branch protection

- The default/main branch must require a passing CI pipeline before merge
- Force-push must be disabled on protected branches
- At least one code review approval required for merges

### Artifact integrity

- Build artifacts should be signed or checksummed
- Never rebuild from source at deploy time — deploy the exact artifact produced by the build stage
- Store artifacts in a registry with immutable tags (avoid `latest` for production)

## Implementation checklist

- [ ] All stages (lint, unit, integration, SAST, SCA, secrets) are present and required to pass
- [ ] Secrets are stored in the CI/CD secrets store — not in pipeline YAML or environment files
- [ ] No hardcoded credentials in pipeline configuration files
- [ ] Production deployment requires all gates to pass; no manual override without audit trail
- [ ] Branch protection is enabled on the main branch (pipeline required + approval required)
- [ ] Dependency scanning runs on every merge request; CVE threshold is enforced

## Review checklist

- [ ] No `allow_failure: true` on security scanning stages
- [ ] No secrets or tokens visible in pipeline YAML or job logs
- [ ] Artifact version is pinned and traceable back to the commit that produced it
- [ ] SAST and SCA scans are not skipped for "quick" pipelines
- [ ] Pipeline fails on CRITICAL/HIGH CVEs — it does not just report them

## Common mistakes

- Running security scans only nightly instead of on every merge request
- Marking SAST as `allow_failure: true` to unblock a delivery (permanently accepted risk)
- Storing secrets as plain-text `variables:` in `.gitlab-ci.yml` committed to the repo
- Deploying from a developer's local machine to production, bypassing the pipeline
- Not pinning the versions of CI pipeline images or actions (supply chain risk)
