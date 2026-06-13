---
name: eng-twelve-factor
description: Review applications against the twelve-factor methodology for cloud-native readiness
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Twelve-Factor App

The twelve-factor methodology (Heroku, 2011) describes practices for building software-as-a-service applications that are portable, scalable, and maintainable. Violations are common causes of environment drift, scaling failures, and secret leaks.

## When to invoke

- Reviewing a new service for cloud-native readiness
- Diagnosing environment-specific bugs ("works on my machine")
- Preparing an application for containerization or autoscaling
- Evaluating CI/CD or infrastructure configuration

## The twelve factors

| # | Factor | Core rule |
|---|---|---|
| I | **Codebase** | One codebase per app tracked in version control; many deploys |
| II | **Dependencies** | Explicitly declare all dependencies; never rely on system-installed packages |
| III | **Config** | Store config in environment variables; never in code |
| IV | **Backing services** | Treat databases, queues, caches as attached resources; swap without code change |
| V | **Build, release, run** | Strictly separate build → release → run stages; never modify code at runtime |
| VI | **Processes** | Execute the app as stateless processes; share nothing |
| VII | **Port binding** | Export services via port binding; do not rely on runtime-injected web servers |
| VIII | **Concurrency** | Scale out via the process model; handle concurrency with more processes, not threads |
| IX | **Disposability** | Fast startup and graceful shutdown; tolerate sudden process termination |
| X | **Dev/prod parity** | Keep development, staging, and production as similar as possible |
| XI | **Logs** | Treat logs as event streams; write to stdout; never manage log files |
| XII | **Admin processes** | Run admin/management tasks as one-off processes; ship them with the app |

## Most commonly violated factors

### III — Config
- **Violation**: database URLs, API keys, or feature flags hardcoded in source files or committed `.env` files
- **Fix**: read all config from environment variables; use a secrets manager for sensitive values; provide a `.env.example` with no real values

### VI — Processes (stateless)
- **Violation**: storing user sessions, file uploads, or cached computation in local process memory or the local filesystem
- **Fix**: sessions in Redis or a DB; files in object storage (S3, GCS); local disk only for ephemeral scratch space

### IX — Disposability
- **Violation**: the app takes 60+ seconds to start; it does not handle `SIGTERM` gracefully; in-flight requests are dropped on shutdown
- **Fix**: optimize cold start; listen for `SIGTERM`, drain in-flight requests, close DB connections, then exit

### X — Dev/prod parity
- **Violation**: dev uses SQLite, prod uses PostgreSQL; dev skips message queues and calls services synchronously
- **Fix**: use Docker Compose or similar to run the same backing services locally; keep versions aligned

## Review checklist

- [ ] **I**: single repository per service; no "monorepo one branch per environment"
- [ ] **II**: all dependencies declared in a manifest (`package.json`, `requirements.txt`, `pom.xml`); no `pip install` in Dockerfiles without pinning
- [ ] **III**: no credentials or environment-specific config in source code or committed files
- [ ] **IV**: all backing services (DB, cache, queue) are referenced via URLs from environment config
- [ ] **VI**: no state stored in local memory or filesystem that must survive a process restart
- [ ] **IX**: app starts in under 10 seconds; handles SIGTERM with graceful drain
- [ ] **X**: dev environment uses the same database engine and major version as production
- [ ] **XI**: app writes logs to stdout/stderr; no log file management code

## Common mistakes

- Committing a `.env` file with real credentials to version control (violates III)
- Using `localhost` as the database host in any non-local configuration (violates IV)
- Storing uploaded files on the container's local disk (lost on restart — violates VI)
- Not implementing graceful shutdown, causing data loss during deployments (violates IX)
- Using a different database engine in tests than in production (violates X; queries may differ)
