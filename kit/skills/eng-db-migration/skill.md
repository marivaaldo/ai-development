---
name: eng-db-migration
description: Review database migrations for safety — breaking changes, locks, and zero-downtime risks
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Database Migration Review

Database migrations are high-risk operations in production. This skill reviews migrations for breaking changes, lock contention, missing indexes, and zero-downtime safety before they reach production.

## When to invoke

- Reviewing a pull request that includes a schema migration
- Planning a migration on a large or high-traffic table
- Evaluating whether a migration is safe to run without downtime
- Reviewing a schema diff or ORM-generated migration script

## Core concepts

### Forward-only migrations

Never use down/rollback migrations in production. Instead, write **forward-only** migrations that are safe to run incrementally. Roll forward with a fix, not backward to an unknown state.

### The Expand/Contract pattern

The safest approach for zero-downtime column changes:

1. **Expand** — add the new column (nullable, with default); deploy the app that writes to both old and new columns
2. **Migrate** — backfill existing rows; deploy the app that reads from the new column
3. **Contract** — drop the old column once no code references it

Never rename or change the type of a column in a single migration on a live system.

### Lock risks

Most DDL operations acquire table-level or access-exclusive locks that block reads and writes:

| Operation | Lock risk |
|---|---|
| `ADD COLUMN` with default (nullable) | Low — most engines avoid a full table rewrite |
| `ADD COLUMN NOT NULL` without default | High — rewrites entire table |
| `ALTER COLUMN` type change | High — rewrites entire table |
| `DROP COLUMN` | Low (logical only; no rewrite in most engines) |
| `CREATE INDEX` (blocking) | High — blocks writes during build |
| `CREATE INDEX` (non-blocking) | Low — does not block reads/writes; use if your engine supports it |
| `ADD FOREIGN KEY` | Medium — validates existing data; some engines support deferred validation |

> **Note:** The exact DDL syntax and locking behaviour vary by database engine. Check your engine's documentation for non-blocking DDL options (e.g., online index builds, deferred constraint validation) before running any of the high-risk operations above on a live table.

### Missing indexes

- Every foreign key column should have an index (databases do not create these automatically in most engines)
- Columns appearing in `WHERE`, `ORDER BY`, or `JOIN` clauses on large tables need indexes
- Adding an index without the non-blocking option blocks the table during build

### Backfilling large tables

- Never `UPDATE` millions of rows in a single migration — it holds locks, fills the transaction log, and may time out
- Backfill in batches (e.g., 1,000–10,000 rows per batch) with a loop and short sleeps
- Consider a background job for very large tables instead of inline migration

## Implementation checklist

- [ ] Migration is forward-only (no `DOWN` / rollback section)
- [ ] Breaking changes (rename, type change, NOT NULL without default) use expand/contract pattern
- [ ] New indexes use the non-blocking index build option supported by your database engine, if available
- [ ] `ADD COLUMN NOT NULL` always has a DEFAULT or is split into add-nullable + backfill + add-constraint
- [ ] Large-table backfills are batched, not a single bulk UPDATE
- [ ] New foreign keys use deferred constraint validation if your engine supports it
- [ ] Migration has been tested on a production-sized data sample

## Review checklist

- [ ] No single migration drops or renames a column while the current app still references it
- [ ] No blocking index creation on tables with existing data
- [ ] No `ALTER COLUMN` type changes that rewrite the table without a maintenance window
- [ ] No unbounded UPDATE or DELETE in the migration script
- [ ] Tooling-reported data-loss warnings (if any) are reviewed, not suppressed

## Common mistakes

- Adding `NOT NULL` to a large existing column in a single step (locks the table for minutes/hours)
- Creating indexes synchronously during peak traffic hours
- Dropping a column while the deployed application still selects it (results in runtime errors before deployment completes)
- Running a `UPDATE SET new_col = old_col` on 50M rows in one transaction
- Forgetting that foreign key columns need their own index (causes full table scans on joins)
