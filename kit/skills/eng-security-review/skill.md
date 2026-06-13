---
name: eng-security-review
description: Review code for OWASP ASVS security risks — injection, auth, secrets, PII
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Security Review

A security review guided by OWASP Application Security Verification Standard (ASVS). Covers injection, input validation, authentication, authorization, secrets management, and data exposure. For personal data and LGPD-specific concerns, invoke `/eng-lgpd`.

## When to invoke

- Reviewing a pull request that touches auth, input handling, data access, or external integrations
- Adding a new API endpoint, form, or data ingestion path
- Pre-release security checklist
- Evaluating third-party library usage for known vulnerabilities

## Core concepts

### Injection (ASVS V5)
- **SQL injection** — user input must never be concatenated into SQL; use parameterized queries or prepared statements
- **NoSQL injection** — sanitize and type-check all query filters; never pass raw user objects to query engines
- **Command injection** — never pass user input to shell commands; use language-native APIs with argument lists, not shell strings
- **Template injection** — treat user-supplied strings as data, never as templates

### Input Validation (ASVS V5)
- Validate at the entry point (controller/adapter), not only inside business logic
- Prefer allowlists over denylists
- Validate type, length, range, and format before processing
- Reject and log invalid input; do not silently sanitize

### Authentication (ASVS V2)
- Passwords must be hashed with bcrypt, scrypt, or Argon2 — never MD5, SHA-1, or reversible encryption
- Multi-factor authentication for sensitive operations
- Session tokens must be cryptographically random, minimum 128 bits
- Token expiration and revocation must be implemented

### Authorization (ASVS V4)
- Enforce access control server-side on every request — never trust client-supplied roles or IDs
- Apply principle of least privilege: grant only what is needed
- Check authorization before loading the resource (fail early)
- Distinguish authentication (who are you?) from authorization (what can you do?)

### Secrets Management (ASVS V6)
- Secrets (API keys, passwords, certificates) must never appear in source code, logs, or version control
- Inject secrets via environment variables, a secrets manager (Vault, AWS Secrets Manager, Azure Key Vault), or a CI/CD secrets store
- Rotate secrets regularly; have a rotation runbook
- Scan commits for secrets before merge (secret scanning in CI)

### Data Exposure
- Do not log personal data — see `/eng-lgpd`
- Mask sensitive fields in error messages and API responses (no stack traces in production)
- Apply TLS for all data in transit; encrypt at rest for sensitive data

## Review checklist

- [ ] No string concatenation in SQL/NoSQL queries — parameterized queries only
- [ ] No user input passed to shell commands or template engines without strict sanitization
- [ ] Input validation at the entry point (type, length, format, allowlist)
- [ ] Passwords hashed with bcrypt/scrypt/Argon2
- [ ] Authorization checked server-side on every sensitive endpoint
- [ ] No secrets in source code, config files, or logs
- [ ] No PII or secrets in error messages or stack traces returned to clients
- [ ] Dependencies checked for known CVEs (SCA scan)

## Common mistakes

- Relying on client-side validation only (must be enforced server-side)
- Using MD5 or SHA-256 for password hashing (not designed for passwords — use Argon2)
- Checking authorization only in the UI, not in the API
- Storing secrets in `.env` files committed to version control
- Logging request bodies without filtering PII or secrets fields
