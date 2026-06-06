---
title: "PostgreSQL Advanced Indexing Guide"
type: source
created: 2026-06-06
source: https://www.youngju.dev/blog/database/2026-03-10-postgresql-advanced-indexing-gin-gist-brin.en
author: "Youngju Kim"
tags:
  - source
  - databases
  - postgresql
  - indexing
  - system-design
---

# PostgreSQL Advanced Indexing Guide

## Summary

A practical guide to PostgreSQL advanced index types beyond B-tree: GIN (inverted index for JSONB/full-text), GiST (generalized search tree for spatial/range data), BRIN (block range summary for time-series), Partial Indexes (subset of rows), and Expression Indexes (function results). Includes EXPLAIN ANALYZE performance data, operational checklist (bloat monitoring, concurrent reindex, unused index detection), and the memory-footprint interaction with the allocator.

## Key Ideas

- Six index types in PostgreSQL: B-tree (equality/range/unique), GIN (JSONB/arrays/tsvector), GiST (spatial/range/proximity), BRIN (time-series append-only), Hash (pure equality), SP-GiST (unbalanced trees/phone numbers).
- GIN is powerful but has high write overhead — tune `gin_pending_list_limit` and use `fastupdate=on` for production.
- GiST organizes data via Minimum Bounding Rectangles; searches may follow multiple index paths due to overlapping ranges.
- BRIN stores min/max per block range — a 50M-row time-series index can be 128 KB vs 1 GB for B-tree (~8500x smaller). Requires strong physical correlation with column values.
- Partial indexes reduce size and write overhead by indexing only a subset of rows (`WHERE status IN ('pending', 'processing')`).
- Expression indexes index function results (`lower(email)`, `(metadata->>'category')`) and require exact query match.
- Operational checklist: check `pg_stat_user_indexes` for unused indexes, monitor bloat with `pgstatindex()`, use `REINDEX CONCURRENTLY` to avoid table locks.

## Links

- Supports [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Supports [[concepts/system-design|System Design]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
