---
name: eng-lgpd
description: Ensure LGPD compliance — legal basis, retention, anonymization, data subject rights
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# LGPD Compliance

Brazil's Lei Geral de Proteção de Dados (Law 13.709/2018) governs the processing of personal data. This skill covers legal basis, sensitive data, retention, anonymization, data subject rights, and log hygiene. Referenced by `/eng-security-review` and `/eng-observability`.

## When to invoke

- A feature collects, stores, processes, or transmits personal data
- Reviewing logging, analytics, or monitoring configurations
- Designing a data retention or deletion policy
- Responding to a data subject request (access, correction, deletion)

## Core concepts

### Personal Data vs Sensitive Data

- **Personal data** — any information that identifies or can identify a natural person: name, CPF, email, IP address, device ID, behavioral data
- **Sensitive data (dados sensíveis)** — special category requiring heightened protection: racial/ethnic origin, religious belief, political opinion, union membership, health or sexual life data, biometric and genetic data

### Legal Bases (Art. 7 — ordinary data; Art. 11 — sensitive data)

| Base | When applicable |
|---|---|
| Consent | Freely given, specific, informed, and unambiguous; can be withdrawn at any time |
| Contract | Processing necessary to fulfill a contract with the data subject |
| Legal obligation | Required by law |
| Legitimate interest | Controller's interest, balanced against data subject rights; document the balancing test |
| Vital interest | Protection of life |

Always document the chosen legal basis in the system's data processing inventory (ROPA).

### Anonymization vs Pseudonymization

- **Anonymization** — irreversible removal of identifying elements; anonymized data falls outside LGPD scope
- **Pseudonymization** — replacing identifiers with tokens; the original data can be re-identified with the mapping key; still governed by LGPD
- Prefer anonymization for analytics, testing, and logs; use pseudonymization only when re-identification is a genuine operational need

### Retention and Deletion

- Define a retention period for every personal data category — do not store "indefinitely"
- Implement automated deletion or anonymization at the end of the retention period
- After contract or consent is terminated, delete or anonymize data unless a legal obligation requires retention

### Data Subject Rights (Art. 18)

Data subjects have the right to: confirmation, access, correction, anonymization/deletion of unnecessary data, portability, information about sharing, and revocation of consent. Implement an internal process to fulfill these requests within a reasonable timeframe (ANPD recommends ≤15 days).

### Logs and Personal Data

- Do not log personal data (name, CPF, email, IP, user ID linked to identity) unless strictly necessary and documented
- If logging is necessary, apply masking or tokenization at the logging layer
- Retain logs only for the minimum period required; do not route logs containing personal data to third-party analytics tools without a data processing agreement (DPA)

## Implementation checklist

- [ ] Every personal data field has a documented legal basis and retention period
- [ ] Sensitive data has explicit consent or another Art. 11 basis documented
- [ ] Anonymization is used wherever re-identification is not needed (analytics, tests, logs)
- [ ] Data deletion or anonymization is automated at end of retention period
- [ ] No personal data (name, CPF, email, IP) appears in unmasked log entries
- [ ] A process exists to respond to data subject requests within 15 days
- [ ] Third-party processors have a signed DPA (Data Processing Agreement)

## Review checklist

- [ ] New data fields are mapped to a legal basis in the ROPA before release
- [ ] Log statements do not include personal identifiers in plain text
- [ ] Test fixtures and seeds do not use real personal data
- [ ] Data exports and reports apply anonymization before leaving the system
- [ ] Retention job is tested and monitored (not just scheduled and forgotten)

## Common mistakes

- Storing personal data "just in case" without a documented purpose or legal basis
- Using pseudonymization and calling it anonymization (they are not the same legally)
- Logging user IDs, emails, or IP addresses without masking in observability tools
- Not having a consent withdrawal flow (if consent is the legal basis, withdrawal must be possible)
- Relying on deletion of application records without also purging backups, replicas, and caches
