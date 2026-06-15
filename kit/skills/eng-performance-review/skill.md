---
name: eng-performance-review
description: Diagnose N+1 queries, missing indexes, ineffective caching, and slow endpoints
providers:
  claude: native
  gemini: see kit/references/gemini.md
  codex: see kit/references/codex.md
  windsurf: see kit/references/windsurf.md
---

# Performance Review

Performance problems in web services fall into a small number of repeating categories. This skill covers diagnosis and remediation of the most common ones: N+1 queries, missing indexes, ineffective caching, unbounded list endpoints, and connection pool exhaustion.

## When to invoke

- Diagnosing a slow endpoint or high database CPU
- Reviewing code before it reaches production on a large dataset
- Adding caching to an existing feature
- Evaluating query correctness for a list or aggregation endpoint

## Core concepts

### N+1 query detection

An N+1 occurs when code loads a list of N records and then executes one additional query per record:

```
SELECT * FROM orders               -- 1 query → 100 orders
for order in orders:
  SELECT * FROM items WHERE order_id = ?  -- 100 queries
```

**Detection:** Enable query logging in development. A spike of repetitive, parameterized queries on the same table within one request is an N+1.

**Fix:** Use eager loading (JOIN, `IN` clause, or ORM `includes`/`prefetch_related`). Batch the secondary lookup into a single query:
```
SELECT * FROM items WHERE order_id IN (1, 2, 3, ..., 100)
```

### Query plan analysis

Before adding an index or rewriting a query, read the query plan. Use `EXPLAIN ANALYZE` (PostgreSQL), `EXPLAIN` (MySQL/MariaDB), or the equivalent for your engine.

| Plan node to watch | What it means |
|---|---|
| `Seq Scan` on a large table | Full table scan — likely missing an index |
| `Nested Loop` with large row estimates | Potential N+1 in the query itself |
| High `rows` estimate with low `actual rows` | Stale table statistics; run `ANALYZE` |
| `Sort` without an index | Sort is done in memory or on disk |

Never add an index without first reading the query plan. Unnecessary indexes slow down writes.

### Index strategy

| Scenario | Index type |
|---|---|
| Single-column filter: `WHERE status = 'active'` | Single-column index |
| Multi-column filter: `WHERE tenant_id = ? AND status = ?` | Composite index — put the most selective column first |
| Filter + sort: `WHERE status = ? ORDER BY created_at` | Composite index covering both columns in that order |
| Avoid returning to the table: `SELECT id, name WHERE email = ?` | Covering index: `(email) INCLUDE (id, name)` |
| Low-cardinality column with small table | Likely not worth indexing |

Adding a composite index `(a, b)` does NOT replace a separate index on `(a)` alone for queries that filter only on `a`. In most engines, `(a, b)` can be used for filters on `a` alone, but verify with your engine.

### Caching

Cache only when a profile or query plan confirms a performance problem. Premature caching adds complexity without measurable benefit.

**What to cache:**

| Data | Cache layer | Typical TTL |
|---|---|---|
| Computed aggregates (counts, totals) | In-process or distributed | 1–60 min |
| Reference data (country list, config) | In-process | Until restart or invalidation event |
| User session / auth token | Distributed (Redis) | Session duration |
| Rendered fragments or API responses | CDN or reverse proxy | Seconds to minutes |

**Invalidation strategies:**

- **TTL-based:** simple, accepts stale data within the TTL window
- **Event-driven:** invalidate on write (cache-aside or write-through); requires event infrastructure
- **Version key:** embed a version counter in the cache key; bump on change (cache buster)

Avoid caching data that changes faster than the TTL. A 1-minute TTL on a balance that changes every second provides no correctness guarantee and only marginal latency benefit.

### Pagination on large datasets

Unbounded list endpoints (`SELECT * FROM orders`) will eventually cause out-of-memory errors or timeouts.

| Strategy | Performance characteristic |
|---|---|
| **Offset** (`LIMIT 20 OFFSET 1000`) | Degrades linearly — the DB must scan and discard the first 1000 rows |
| **Cursor** (`WHERE id > last_seen_id ORDER BY id LIMIT 20`) | Constant time — uses the index directly |

Use cursor pagination for any list that may exceed a few thousand rows. Offset pagination is acceptable for admin UIs with bounded datasets.

Always enforce a maximum page size. Never return unbounded lists.

### Connection pool sizing

Too few connections → queued requests → latency spike.
Too many connections → database CPU saturated by context switching.

A practical starting formula for thread-per-request servers:
```
pool_size = (core_count * 2) + effective_spindle_count
```
For async/non-blocking services, the pool can be smaller since threads do not block on I/O.

Monitor pool wait time (`pool_checkout_timeout`) in your observability stack. If requests queue for connections, the pool is undersized — but first verify that queries are not just slow.

## Implementation checklist

- [ ] Query logging is enabled in development; N+1s are caught before code review
- [ ] Every new query has been reviewed with `EXPLAIN ANALYZE` on a realistic dataset
- [ ] Indexes cover all columns in `WHERE`, `JOIN ON`, and `ORDER BY` clauses for hot queries
- [ ] No composite index was added without verifying it is actually used by the query plan
- [ ] List endpoints have a maximum page size and use cursor pagination for large datasets
- [ ] Caching is backed by a performance measurement, not added speculatively
- [ ] Cache invalidation strategy is explicit and tested

## Review checklist

- [ ] No loop that executes a database query per iteration
- [ ] No `SELECT *` on large tables (fetches unused columns, prevents covering indexes)
- [ ] No list endpoint without a `LIMIT` clause or page size constraint
- [ ] No index added without a query plan showing it is necessary
- [ ] No cache with an unbounded or unreasonably long TTL on frequently changing data
- [ ] Connection pool settings are documented and tuned for the deployment environment

## Common mistakes

- Adding an index on a column with very low cardinality (e.g., boolean `is_active`) — rarely helps, always costs write overhead
- Caching the output of a query that is already fast (< 5 ms) — the cache overhead can be larger than the saving
- Using `OFFSET` pagination on a table with millions of rows and wondering why page 500 is slow
- Fixing an N+1 by adding a cache instead of fixing the query — the cache masks the problem and will eventually be wrong
- Not testing with production-scale data — an index that helps on 1,000 rows may be unnecessary on 100 rows and critical on 10,000,000
