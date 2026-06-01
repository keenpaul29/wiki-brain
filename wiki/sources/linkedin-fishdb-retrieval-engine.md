---
title: "FishDB: A Generic Retrieval Engine for Scaling LinkedIn's Feed"
type: source
created: 2026-06-01
tags:
  - source
  - linkedin
  - fishdb
  - feed
  - rust
  - retrieval
---

# FishDB: A Generic Retrieval Engine for Scaling LinkedIn's Feed

## Summary

LinkedIn introduces FishDB, a Rust-based storage and retrieval engine designed to scale their Feed. FishDB is built around a document-oriented data model where each document is a collection of typed fields, providing a unified abstraction that supports multiple use cases (Feed, Notification Center, Jobs) with a single engine.

FishDB's query engine uses a combination of index scanning and custom expression evaluation. It supports relational operators (AND, OR, NOT), comparison operators, IN/REGEXP, and full-text search over string fields. The engine precomputes indexes for efficient execution: sorted-set indexes, bit-sliced indexes for numeric range queries, and inverted indexes for full-text search. Upcoming features include tiered storage and snapshot isolation transactions.

## Key Ideas

- FishDB is the foundational storage and retrieval layer for LinkedIn's Feed, deployed across 48 shards.
- Written in Rust with jemalloc as its memory allocator and Tokio as its async runtime.
- Uses Envoy proxy sidecar for traffic management.
- Query execution follows a two-phase model: pre-filtering (index scanning) and result processing (projection, sorting, pagination).
- B-tree based sorted-set indexes support efficient point lookups and range scans.
- Bit-sliced indexes accelerate numeric range queries by storing each bit of a value separately.
- Inverted indexes enable full-text search via skip-list based posting lists.

## Links

- Supports [[concepts/fishdb|FishDB]]
- Supports [[concepts/system-design|System Design]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Supports [[concepts/infrastructure-primitives|Infrastructure Primitives]]
