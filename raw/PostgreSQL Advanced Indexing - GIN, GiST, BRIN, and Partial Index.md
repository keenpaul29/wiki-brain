---
title: "PostgreSQL Advanced Indexing Guide: GIN, GiST, BRIN, and Partial Index in Practice"
source: "https://www.youngju.dev/blog/database/2026-03-10-postgresql-advanced-indexing-gin-gist-brin.en"
author:
  - "Youngju Kim"
published: 2026-03-10
created: 2026-06-06
description: "Beyond B-tree: a practical guide to PostgreSQL advanced indexing covering GIN, GiST, BRIN, Partial Index, and Expression Index with EXPLAIN ANALYZE performance data."
tags:
  - "clippings"
---

## PostgreSQL Advanced Indexing Guide

PostgreSQL offers six index types: B-tree, Hash, GIN, GiST, SP-GiST, and BRIN. Most tutorials stop at B-tree, but real-world applications encounter problems B-tree alone cannot solve.

### Index Types Overview

| Type | Structure | Best Use | Size | Write Cost |
|------|-----------|----------|------|-----------|
| B-tree | Balanced tree | Equality, range, sort, UNIQUE | Medium | Low |
| GIN | Inverted index | JSONB, arrays, tsvector | Large | High |
| GiST | Generalized search tree | Spatial data, ranges, proximity | Medium | Medium |
| BRIN | Block range summary | Time-series, append-only large tables | Very small | Very low |
| Hash | Hash table | Pure equality lookups | Small | Low |
| SP-GiST | Space-partitioned tree | Phone numbers, IPs, unbalanced trees | Medium | Medium |

### GIN (Generalized Inverted Index)

Uses an inverted index structure. Builds a B-tree over key values; leaf nodes store TID lists. Best for JSONB containment queries (`@>`, `?`, `?|`), full-text search (`tsvector`), and array indexing.

- `fastupdate=on`: new entries go to a Pending List, batch-merged during VACUUM
- `jsonb_path_ops` is smaller and faster for `@>` but does not support key-existence checks
- Write overhead is high — tune `gin_pending_list_limit` for production

### GiST (Generalized Search Tree)

An extensible R-tree framework. Supports spatial queries (PostGIS `ST_DWithin`, `ST_Contains`), range type operators (`&&` overlap, `@>` contains), and KNN search (`<->` with `ORDER BY ... LIMIT`).

Bounding boxes (MBR) organise data hierarchically. Ranges can overlap, so searches may follow multiple index paths.

### BRIN (Block Range Index)

Stores min/max summary per physical block range (default 128 pages). Tiny index size — a BRIN on a 50M-row time-series table can be 128 KB vs 1 GB for B-tree (~8500x smaller).

Requires strong correlation between column values and physical storage order (check `pg_stats.correlation`). Best for append-only time-series data. Tune `pages_per_range` to balance accuracy vs size.

Not suitable for: random-insert data, UPDATE-heavy workloads, or point-query primary workloads.

### Partial and Expression Indexes

**Partial Index:** Index only a subset of rows (`WHERE status IN ('pending', 'processing')`). Reduces size and write overhead. Query WHERE clause must imply the index predicate.

**Expression Index:** Index function/transformation results (`lower(email)`, `(metadata->>'category')`). Query must use the exact same expression.

**Combined:** Lower(email) WHERE last_login > now() - interval '7 days' — isolates the working set and the transformation.

### Operational Checklist

- Check `pg_stat_user_indexes` for unused indexes (`idx_scan = 0`)
- Monitor bloat via `pgstatindex()`; REINDEX when bloat exceeds 20%
- Use `REINDEX CONCURRENTLY` to avoid table locks
- Verify with `EXPLAIN (ANALYZE, BUFFERS)` before and after
- Check for stale statistics, type mismatches, and selectivity issues
