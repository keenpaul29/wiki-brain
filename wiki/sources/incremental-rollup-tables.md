---
title: "From 5 Seconds to 50ms — Incremental Rollup Tables for Dashboard Analytics"
type: source
created: 2026-06-14
source_url: "https://dev.to/akashpattnaik/from-5-seconds-to-50ms-how-i-stopped-nuking-my-database-every-time-i-deleted-an-order-30l0"
---

# From 5 Seconds to 50ms — Incremental Rollup Tables

A hands-on case study of fixing a slow Next.js + Supabase admin dashboard. The root cause was reading raw order tables with JSONB parsing on every request. The fix was **incremental rollup tables** — write-time pre-aggregation that keeps dashboard reads O(N_days) instead of O(N_orders).

## Key Ideas

- Raw tables are ledgers, not reporting tables. Maintain separate pre-aggregated rollup tables optimized for reads.
- Move complexity to write time: a slightly more complex write path (incremental UPSERT on rollups) pays for itself thousands of times over in fast reads.
- On delete, surgically decrement affected rollup counters instead of full rebuild. Clamp to zero with `Math.max(0, ...)`.
- Clean up empty rollup rows to keep tables lean.
- Keep granular queries available for narrow date-range inspection with proper indexes.

## Design

Four lightweight rollup tables: `daily_stats`, `hourly_orders`, `product_sales`, `user_stats`. Each with atomic UPDATE statements that touch exactly the rows affected by the mutation — no joins, no JSON parsing, no discount math.

## Links

- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/performance-engineering|Performance Engineering]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
