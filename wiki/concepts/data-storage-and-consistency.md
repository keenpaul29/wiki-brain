---
title: Data Storage and Consistency
type: concept
created: 2026-04-28
tags:
  - concept
  - databases
  - system-design
---

# Data Storage and Consistency

Data choices determine much of a system's scalability, correctness, and operational complexity. The system design source covers storage types, SQL and NoSQL databases, replication, partitioning, normalization, transactions, and consistency tradeoffs.

## Storage Types

- File storage: hierarchical files and folders.
- Block storage: fixed-size blocks used by databases and virtual disks.
- Object storage: blob-like objects with metadata, useful for media and large files.
- NAS and distributed file systems: shared or distributed access patterns.

## Database Families

- SQL databases: relational schema, structured queries, strong consistency patterns, and joins.
- Document databases: nested document records, flexible schema.
- Key-value stores: fast access by key, common for cache and session data.
- Graph databases: relationships as first-class data.
- Time-series databases: optimized for measurements over time.
- Wide-column stores: scalable column-family storage.
- Multi-model databases: multiple data models under one system.

## Consistency and Transactions

- ACID prioritizes atomicity, consistency, isolation, and durability.
- BASE prioritizes basic availability, soft state, and eventual consistency.
- CAP frames the tradeoff between consistency and availability under partition.
- PACELC extends the framing: if partitioned, choose availability or consistency; else choose latency or consistency.
- Distributed transactions can use two-phase commit, three-phase commit, or saga patterns, each with coordination tradeoffs.

## Scaling Data

- Replication improves read capacity and availability but introduces lag or conflict risk.
- Sharding splits data across partitions to scale writes and storage.
- Consistent hashing reduces remapping when nodes are added or removed.
- Federation splits data by function or domain.
- Indexes speed reads but add write cost and storage overhead.
- Normalization reduces redundancy; denormalization can improve read performance.

## Specialized Index Structures

Retrieval engines at scale use specialized index types beyond simple B-trees and hash tables:

- **Sorted-set indexes (B-tree)**: support efficient point lookups and range scans on ordered fields. Used by FishDB for primary-key to document-reference mapping.
- **Bit-sliced indexes**: accelerate numeric range queries by storing each bit of a value separately across slices, enabling fast bitwise range filters. Used by FishDB for numeric field filtering.
- **Inverted indexes with skip-list posting lists**: enable full-text search by mapping terms to document lists, with skip lists enabling efficient skipping over common terms.
- **Skip-list based posting lists**: instead of linear scanning, posting lists use skip pointers so union/intersection operations on common terms skip irrelevant segments.

The memory-footprint interaction with the allocator matters at scale. A `hashbrown::HashMap` (SwissTable) at ~58.7M entries per shard consumed ~1.75 GB. Resizing this map triggered jemalloc `brk()` → kernel `mmap_lock` contention. Pre-allocating with `HashMap::with_capacity()` prevents resize events entirely.

## Vector Embeddings and Semantic Search

Search at scale increasingly uses dense vector representations for semantic understanding:

- **Embedding-based retrieval (EBR)**: queries and documents are encoded into fixed-size vectors via neural encoders. Retrieval becomes approximate or exhaustive nearest-neighbor search in a shared embedding space.
- **GPU-accelerated exhaustive search**: at LinkedIn's scale, EBR runs exhaustive vector search on CUDA-enabled GPUs for maximum recall.
- **Hybrid feature pipeline**: embeddings are generated offline (Spark, Flyte) and updated nearline (Flink) to balance throughput and latency.
- **Context compression**: reduces the input token count passed through expensive cross-encoder models during ranking, improving cost and latency.

## Client-Side Storage (Local-First)

Local-first web architectures introduce new storage patterns:

- **IndexedDB as durable store**: schema designed for file metadata and content, enabling reads without network round-trips.
- **Shared storage layer**: all components (file lists, search, content previews) read/write through a unified local representation rather than independent server fetches.
- **Multi-tab persistence**: BroadcastChannel API coordinates cross-tab cache invalidation and state synchronization.
- **Sync-engine-backed writes**: mutations apply to local state immediately (optimistic UI), then propagate to server asynchronously.

## Lookup Structures

Dictionary-style lookups are a basic form of data-system design. Unsorted arrays optimize simplicity and appends but make membership checks O(n). Sorted arrays support binary-search lookups with low memory overhead but make inserts and deletes expensive. Hash tables are the default for unordered membership and key-value access because average lookup, insert, and delete are O(1), while balanced binary search trees preserve ordering for range queries and predecessor/successor operations.

## Data Access and Connection Patterns

- **Repository Pattern**: Establishes a clean contract between business logic and persistence logic, shielding domain entities from raw database schema details and facilitating unit testing.
- **Connection Pool**: Manages a recycled pool of database connections to minimize connection handshaking overhead. Pool sizing, timeouts, and leak detection are critical to prevent system exhaustion.
- **Connection Factory**: Centralizes connection creation to orchestrate advanced routing, such as directing writes to a primary database and reads to read replicas, and executing fallback logic if a database node goes down.
- **CQRS**: Splits command/write models from query/read models when business-rule enforcement and dashboard-style queries need fundamentally different schemas, performance profiles, or consistency guarantees.
- **Change Data Capture**: Reads committed row changes from database transaction logs, producing reliable event streams for search indexing, cache invalidation, audit logs, projections, and service synchronization without fragile application-level dual writes.

## Projection and Event Streams

Read models and downstream indexes must be treated as rebuildable projections. CQRS projectors need projection-lag monitoring and idempotent handling. CDC consumers need schema-evolution discipline, replication-slot monitoring, and idempotency keys such as LSNs or transaction IDs because delivery is at least once.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/system-design-case-studies|System Design Case Studies]]
- Related: [[concepts/fishdb|FishDB]]
- Related: [[concepts/local-first-architecture|Local-First Architecture]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Source: [[sources/system-design-course|System Design Course]]
- Source: [[sources/dictionary-problem-fast-lookups|The Dictionary Problem - Fast Lookups in Large Collections]]
- Source: [[sources/latency-gambler-day-9|Database Patterns & Repository Pattern]]
- Source: [[sources/cqrs-read-write-separation|The Read That Was Killing the Write]]
- Source: [[sources/change-data-capture-event-log|Your Database Has Been Writing an Event Log the Whole Time]]
- Source: [[sources/linkedin-fishdb-retrieval-engine|FishDB: LinkedIn Feed Retrieval Engine]]
- Source: [[sources/linkedin-58m-key-hashmap-freeze|The 58-Million-Key Freeze: HashMap Resize at Scale]]
- Source: [[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]]
- Source: [[sources/dropbox-edison-web-performance|Dropbox Edison: Local-First Web Client]]
