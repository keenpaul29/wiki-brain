---
title: "Backend Performance Engineering"
type: source
created: 2026-06-06
source: https://www.youngju.dev/blog/culture/2026-04-14-backend-performance-engineering-optimization-profiling-guide-2025.en
author: "Youngju Kim"
tags:
  - source
  - performance
  - profiling
  - database
  - system-design
---

# Backend Performance Engineering

## Summary

A practitioner's guide to backend performance engineering covering performance budgets, CPU/memory/I/O profiling with flame graphs, six load testing types (smoke, load, stress, spike, soak, breakpoint), database optimization (N+1 queries, indexing strategy, connection pool sizing, query patterns), caching strategy, and the 80/20 rule of database tuning.

## Key Ideas

- Performance budget before tuning: define p50/p95/p99 latency, error rate, throughput, query latency, connection pool utilization targets.
- The loop: Observe → Profile → Fix → Verify. Measure first, optimize second. Percentiles over averages — p95 and p99 show what users actually experience.
- Profiling: CPU flame graphs (wider frame = more CPU time), memory allocation tracking (high allocation → GC pauses), I/O latency measurement.
- Six load testing types: Smoke (minimal), Load (normal peak), Stress (breaking point), Spike (instant surge), Soak (long-term), Breakpoint (exact capacity).
- N+1 query fixes: eager loading (JOIN), prefetch (batch via IN), DataLoader pattern (auto-batch).
- Indexing strategy: find slow queries via pg_stat_statements, use EXPLAIN ANALYZE, composite indexes with most selective column first, CREATE INDEX CONCURRENTLY, check for unused indexes.
- Connection pool: HikariCP formula = (core_count × 2) + effective_spindle_count. 10-20 is generally sufficient.
- Caching: frequently-read rarely-changed data, 30-60 sec TTL, monitor hit rate (below 80% means cache is barely working).
- 80/20 rule: proper indexing solves ~80% of database performance problems.

## Links

- Supports [[concepts/reliability-and-operations|Reliability and Operations]]
- Supports [[concepts/system-design|System Design]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
