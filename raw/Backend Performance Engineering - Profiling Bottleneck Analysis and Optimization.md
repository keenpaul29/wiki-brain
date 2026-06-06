---
title: "Backend Performance Engineering: Profiling, Bottleneck Analysis, and Optimization"
source: "https://www.youngju.dev/blog/culture/2026-04-14-backend-performance-engineering-optimization-profiling-guide-2025.en"
author:
  - "Youngju Kim"
published: 2026-04-14
created: 2026-06-06
description: "A practitioner's guide to backend performance engineering covering performance budgets, CPU/memory/I/O profiling (flame graphs), load testing types (smoke/load/stress/spike/soak/breakpoint), database optimization (N+1 queries, indexing, connection pooling, read replicas), and caching strategies."
tags:
  - "clippings"
---

## Backend Performance Engineering

### Performance Budget

Define measurable targets before tuning:

```
p50_latency_ms: 50
p95_latency_ms: 200
p99_latency_ms: 500
error_rate_percent: 0.1
throughput_rps: 1000
query_p95_ms: 50
connection_pool_utilization: 70%
```

### The Loop

Observe → Profile → Fix → Verify. Measure first, optimize second. Percentiles over averages — p95 and p99 show what users actually experience.

### Profiling

**CPU Profiling and Flame Graphs:** Visually show where CPU time is spent. The wider a frame on a flame graph, the more CPU time it consumes. Profile under realistic load, not in isolation.

**Memory Profiling:** Track allocation rates (high allocation causes GC pauses), object retention, and leak candidates.

**I/O Profiling:** Measure disk read/write latency, network I/O, and database call duration.

### Load Testing Types

| Type | Purpose | Load Pattern |
|------|---------|-------------|
| Smoke | Verify basic functionality | Minimal load |
| Load | Expected peak behavior | Normal peak traffic |
| Stress | Find breaking point | Ramp beyond expected |
| Spike | Sudden traffic surge | Instant high load |
| Soak | Long-term stability | Sustained over hours |
| Breakpoint | Exact capacity limit | Ramp until failure |

### Database Optimization

**N+1 Query Problem:** After querying N parent entities, each child is queried individually — 100 orders triggers 101 DB queries.

**Fixes:** Eager loading (JOIN for 1:1/N:1), prefetch (batch via IN clause for 1:N/M:N), DataLoader pattern (auto-batch).

**Indexing Strategy:**
- Find slow queries via pg_stat_statements, sorted by total execution time
- Use EXPLAIN (ANALYZE, BUFFERS) to check for Seq Scan on large tables
- Composite indexes with most selective column first
- Partial indexes for WHERE subset queries
- CREATE INDEX CONCURRENTLY to avoid table locks
- Check pg_stat_user_indexes for unused indexes (idx_scan = 0)

**Connection Pool Sizing:**
- HikariCP formula: connections = (core_count * 2) + effective_spindle_count
- 10-20 is generally sufficient. Too-large pools increase DB context switching costs
- Increase when utilization exceeds 80%, immediately when waiting threads appear

**Query Patterns:**
- Convert subqueries to JOINs where possible
- Use cursor-based pagination (WHERE id > cursor LIMIT N) instead of OFFSET for deep pages
- Batch writes — 1000 individual INSERTs vs one batch INSERT = ~100x throughput difference

### Caching Strategy

Cache at the right level: in-memory or Redis for frequently-read, rarely-changed data. Set appropriate TTLs (start with 30-60 seconds). Monitor hit rate — below 80% means cache is barely doing its job.

### The 80/20 of Database Tuning

Proper indexing solves ~80% of database performance problems. Not schema redesign, not hardware upgrades, not switching databases. Read every slow query's execution plan, check for full table scans, index the WHERE clause columns, prefer composite indexes.

### Key Takeaways

- Measure first, optimize second. Observability is a prerequisite.
- Percentiles over averages.
- Fix boring stuff first: N+1 queries, missing indexes, over-fetching account for most latency.
- If it doesn't need to happen before the response, move it out of the request cycle.
- Make one change at a time, measure impact, iterate.
- Profile under realistic load, not in isolation.
- Set alerting thresholds: p75/p95/p99 exceeding target for >5 minutes.
