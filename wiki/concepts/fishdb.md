---
title: FishDB
type: concept
created: 2026-06-01
tags:
  - concept
  - linkedin
  - storage
  - retrieval
  - rust
---

# FishDB

FishDB is LinkedIn's Rust-based storage and retrieval engine powering their Feed platform. It provides a document-oriented data model where each document is a collection of typed fields, supporting multiple use cases (Feed, Notification Center, Jobs) with a single engine. It is one of the most complete system-design case studies in this wiki because it spans application architecture, index design, runtime interaction, and kernel-level debugging in a single narrative.

## Architecture

- Written in Rust with jemalloc as its memory allocator and Tokio as its async runtime.
- Deployed across 48 shards, using an Envoy proxy sidecar for traffic management.
- Maintains index structures in memory: a HashMap mapping primary keys to internal document references (~56-59M entries, ~1.75 GB per shard).
- Uses hashbrown::HashMap (Rust's standard HashMap, based on Google's SwissTable).

## Document Data Model

FishDB models all data as documents with typed fields. A document for a Feed post includes fields like `author_id` (integer), `created_at` (timestamp), `content` (text), `engagement_score` (float), and `visibility` (enum). Each field type determines which indexes can accelerate queries on that field:

- **Integer/timestamp fields**: sorted-set (B-tree) or bit-sliced indexes for range and equality queries.
- **Text fields**: inverted indexes with skip-list posting lists for full-text search and token matching.
- **Composite queries**: the query engine combines multiple indexes via relational operators (AND, OR, NOT) in a cost-based optimizer.

## Query Engine

Two-phase execution model:

1. **Pre-filtering (index scanning)**: the engine identifies candidate documents by scanning the relevant index structures. Each index returns a set of primary key references. The engine combines these sets using the query's boolean operators.
2. **Result processing**: the candidate set is projected (selected fields are read from the document store), sorted, and paginated. This phase is I/O-bound for large result sets because it accesses the primary document storage.

This separation means that expensive document reads only happen for candidates that survive the index scan — the typical pattern for any production search or retrieval system.

## Index Types

### Sorted-Set Indexes (B-Tree)

Standard B-tree structures for equality and range queries on ordered fields (timestamps, scores, IDs). Each entry maps a field value to a set of document IDs. Range scans (`WHERE created_at > X AND created_at < Y`) walk the B-tree leaf nodes.

### Bit-Sliced Indexes

A specialized index for numeric range queries. Each numeric field value is stored as a bit-slice — one bit per value per bit position. A range query like `engagement_score BETWEEN 100 AND 200` can be answered by comparing the high-order bit-slices first, skipping documents that cannot be in range without reading their full values.

Advantage: extremely fast range queries on high-cardinality numeric fields without scanning a B-tree. Tradeoff: only useful for numeric types, and the index size grows with value precision.

### Inverted Indexes with Skip-List Posting Lists

Full-text search over string fields. Each term maps to a posting list — a sorted list of document IDs containing that term. The posting lists are stored as skip lists (linked lists with express lanes) that support fast union and intersection operations without scanning every entry.

When a query searches for "rust deployment", the engine intersects the posting lists for "rust" and "deployment" using the skip pointers to skip non-matching document IDs.

## Key Incident: The 58-Million-Key Freeze

A HashMap resize at ~58.7M keys triggered a chain reaction across the entire stack:

1. **Application layer**: Rust's `HashMap` (hashbrown) reached its load factor threshold and triggered a resize. `HashMap::resize` allocates a new, larger backing array and rehashes all entries into it.
2. **Allocator layer**: jemalloc (Rust's default allocator) could not satisfy the large allocation from its free lists and called `brk()` to extend the program's data segment.
3. **Kernel layer**: `brk()` acquires the kernel's `mmap_lock` — a global lock protecting the process's virtual memory layout. On a machine with many cores, this lock is also contended by concurrent page faults from the Tokio async runtime.
4. **Runtime layer**: Tokio tasks that triggered page faults (reading data from memory-mapped files, allocating new objects) blocked on `mmap_lock`, which was already held by the HashMap resize. Every Tokio task stalled, freezing the entire async runtime.

**Fix**: replace `HashMap::new()` with `HashMap::with_capacity(60_000_000)` — pre-allocate the HashMap's backing array at startup, eliminating the need for run-time resize.

### Cross-Layer Lessons

The FishDB freeze is one of the most instructive production incidents in this wiki because it crosscuts four system layers simultaneously:

| Layer | Role in Incident | Lesson |
|---|---|---|
| Application (HashMap) | Triggered resize at load factor threshold | Pre-allocate large collections to known size |
| Allocator (jemalloc) | Fell back to `brk()` for large allocation | Understand allocator behavior for large heap growth |
| Kernel (mmap_lock) | Global lock serialized all page table operations | `mmap_lock` contention is a multi-core risk |
| Runtime (Tokio) | Async tasks froze on `mmap_lock` | Async runtimes are not immune to kernel-level synchronization |

The fix was a single line of code. Understanding why that line was necessary required debugging from application logic through allocator internals to kernel lock semantics.

## Production Deployment

- **48 shards** with Envoy proxy sidecars for traffic routing, health checking, and load shedding.
- **Shard-level isolation**: each shard has its own HashMap, index structures, and Tokio runtime. A resize incident on one shard does not affect others.
- **Traffic shaping**: Envoy provides circuit breaking, retry budgets, and connection pooling per shard. Combined with FishDB's own health metrics, the system can shed shard traffic before lock contention or memory pressure becomes critical.
- **Monitoring axes**: per-shard HashMap load factor, `mmap` growth rate, Tokio task queue depth, and jemalloc fragmentation ratio. The incident revealed that HashMap load factor was not on the monitoring dashboard.

## Sources

- [[sources/linkedin-fishdb-retrieval-engine|FishDB: A Generic Retrieval Engine for Scaling LinkedIn's Feed]]
- [[sources/linkedin-58m-key-hashmap-freeze|The 58-Million-Key Freeze: HashMap Resize at Scale]]
