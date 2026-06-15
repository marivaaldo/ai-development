---
name: eng-runbook
description: Write operational runbooks that an on-call engineer can follow under pressure
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Runbook

A runbook is the operational documentation an on-call engineer follows when an alert fires. A good runbook eliminates guesswork under pressure: it names the alert, explains what is likely wrong, provides step-by-step diagnosis, and defines when to escalate.

## When to invoke

- Writing documentation for a new alert or automated job
- Reviewing an existing runbook before an on-call rotation
- An incident revealed that the existing runbook was incomplete or wrong
- Setting up the `runbooks/` directory in a new service

## One runbook, one alert

Each runbook covers exactly one alert or one operational procedure (deployment, rollback, data migration). Do not combine multiple alerts into a single document — on-call engineers arrive at an alert link, not a table of contents.

## Runbook structure

```markdown
# <Alert or Procedure Name>

**Alert:** <exact alert name as it appears in the monitoring tool>
**Owner:** <team or person responsible>
**Last reviewed:** YYYY-MM-DD
**Severity:** P1 / P2 / P3

---

## What this alert means

<1–3 sentences. What is the system measuring? What threshold triggered this?>

## Likely causes

1. <Most common cause>
2. <Second most common cause>
3. <Rare but critical cause>

## Diagnosis steps

### Step 1 — Verify the alert is real

<Link to the dashboard or query to confirm the metric is actually elevated>

### Step 2 — Check recent deployments

<Link to deployment log or command to list recent deploys>

### Step 3 — Inspect logs

<Exact log query or command to run. Include the log level, time window, and fields to filter>

### Step 4 — Check dependencies

<Links to status pages or internal dashboards for upstream services>

## Resolution

### If cause A (most common):
<Exact steps to fix. Include commands, not just descriptions.>

### If cause B:
<Steps>

### If unknown:
<Fallback: collect the following information before escalating...>

## Escalation

Escalate to <team/person> if:
- The issue is not resolved within <N minutes>
- Any of the following conditions are met: <list>

**Escalation contact:** <name, Slack handle, PagerDuty rotation>

## Post-incident

- File an incident report: <link to template>
- Update this runbook if a new cause was found
```

## Writing guidelines

**Write for someone who has never seen this service.**
Assume the on-call engineer is unfamiliar with this component. Every command must be complete and copy-pasteable.

**Link, don't describe.**
"Check the database dashboard" is useless. "Open [this Grafana panel](link)" is actionable.

**Describe what good looks like.**
After each diagnosis step, state the expected value if nothing is wrong. This lets the engineer confirm the step is complete.

**Keep diagnosis steps ordered from fast to slow.**
Start with the checks that take 30 seconds. End with the ones that take 10 minutes. The engineer should be able to rule out the common cases quickly.

**Separate diagnosis from resolution.**
Do not mix "how to find the problem" with "how to fix it". Engineers need to complete diagnosis before choosing a resolution path.

## Implementation checklist

- [ ] Runbook is linked from the alert definition (annotation, description, or comment in the monitoring config)
- [ ] Each diagnosis step includes the exact command or link to run
- [ ] Each resolution path is tested — not just written
- [ ] Escalation criteria and contacts are current
- [ ] The runbook was reviewed by someone who did not write it
- [ ] "Last reviewed" date is set and tracked

## Review checklist

- [ ] No step that says "check the logs" without specifying which logs, what to search for, and what constitutes a finding
- [ ] No "contact the team" without naming a specific person or rotation
- [ ] No resolution steps that assume tools or access the on-call engineer may not have
- [ ] Alert name in the runbook matches exactly the alert name in the monitoring tool
- [ ] Runbook covers what to do if none of the listed causes apply

## Common mistakes

- Writing runbooks after the incident instead of before the alert goes live — the on-call engineer is the first reader, not the author
- Documenting what the system does instead of what to do when it breaks — runbooks are operational, not architectural
- Linking to a Confluence page that requires VPN and SSO — links must be reachable at 3am on a mobile device if necessary
- Not updating the runbook after an incident reveals a new cause — stale runbooks erode trust and get ignored
- One mega-runbook for an entire service — on-call engineers cannot navigate it under pressure
