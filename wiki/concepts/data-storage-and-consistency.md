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

Capacity and I/O are different design axes. Byte storage answers how much data can be held; I/O answers how fast the system can move data under active reads and writes. Throughput matters for large sequential transfers such as media files and backups. IOPS matters for many small, fragmented operations such as transactional database lookups. A system can have plenty of unused storage capacity and still fail because provisioned IOPS is exhausted.

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

## PostgreSQL Advanced Indexing

PostgreSQL offers six index types beyond B-tree and hash:

- **GIN (Generalized Inverted Index)**: inverted index for JSONB containment queries (`@>`, `?`), full-text search (`tsvector`), and array indexing. High write overhead — tune `gin_pending_list_limit` and use `fastupdate=on`.
- **GiST (Generalized Search Tree)**: extensible R-tree framework for spatial queries (PostGIS `ST_DWithin`), range type operators (`&&` overlap), and KNN search (`<->` with `ORDER BY ... LIMIT`). Searches follow multiple paths due to overlapping bounding boxes.
- **BRIN (Block Range Index)**: min/max summary per physical block range. A 50M-row time-series index can be 128 KB vs 1 GB for B-tree (~8500x smaller). Requires strong column-to-storage correlation (check `pg_stats.correlation`). Best for append-only time-series.
- **Partial Index**: indexes only a subset of rows (`WHERE status IN ('pending', 'processing')`), reducing size and write overhead.
- **Expression Index**: indexes function results (`lower(email)`, `(metadata->>'category')`). Query must use the exact same expression.

Operational discipline: check `pg_stat_user_indexes` for unused scans (`idx_scan = 0`), monitor bloat via `pgstatindex()` (reindex when >20%), and use `REINDEX CONCURRENTLY` to avoid table locks.

## Vector Embeddings and Semantic Search

Search at scale increasingly uses dense vector representations for semantic understanding:

- **Embedding-based retrieval (EBR)**: queries and documents are encoded into fixed-size vectors via neural encoders. Retrieval becomes approximate or exhaustive nearest-neighbor search in a shared embedding space.
- **GPU-accelerated exhaustive search**: at LinkedIn's scale, EBR runs exhaustive vector search on CUDA-enabled GPUs for maximum recall.
- **Hybrid feature pipeline**: embeddings are generated offline (Spark, Flyte) and updated nearline (Flink) to balance throughput and latency.
- **Context compression**: reduces the input token count passed through expensive cross-encoder models during ranking, improving cost and latency.

## Recommendation Embedding Stores

Recommendation systems use the same embedding-storage idea in a personalized setting. Instagram Explore stores item embeddings from a Two Tower model in an ANN service and computes fresh user embeddings online. The cacheability tradeoff is important: user-item interaction features are powerful, but they cannot be consumed by Two Tower retrieval without losing independently cacheable user/item embeddings.

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

## Database Scaling Patterns

When a single database instance is insufficient, three primary scaling patterns apply:

### Read Replicas

For read-heavy workloads (90:10 read-to-write ratio typical), add read replicas that asynchronously replicate from a primary. Writes go to the primary; reads go to replicas.

**Replication lag problem:** If a user writes to the primary and immediately reads from a replica, the read may return stale data. Solutions include:
- **Read-your-own-writes**: Force reads for the writing user to the primary for N seconds after a write.
- **Session affinity** (sticky sessions): Route the same user to the same replica during a session.
- **Write confirmation**: Wait for the write to be confirmed by at least one replica before returning.

### Sharding Strategies

Sharding splits data across multiple databases horizontally. No single approach is universally best:

| Strategy | Distribution | Range Queries | Resharding |
|----------|-------------|---------------|------------|
| **Hash-based** (`user_id % N`) | Even | Impossible | Hard — reshuffles all data |
| **Range-based** (`A–M`, `N–Z`) | Uneven possible | Natural | Easier — add ranges |
| **Geographic** (region-based) | Natural for geo | Regional | Data sovereignty friendly |

**Shard key selection is the most critical decision in sharding.** A bad shard key causes hot spots and makes resharding painful. Prefer keys that distribute evenly and colocate related data. `user_id` is common. Timestamps are poor choices because recent data dominates.

**Cross-shard operations break:**
- **Joins across shards**: Not possible in SQL. Use denormalization (store user name with each post) or application-level joins.
- **Distributed transactions**: Avoid ACID across shards. Use sagas or eventual consistency with compensating actions.
- **Unique constraints**: Only enforceable per shard. Use globally unique IDs (UUIDs, Snowflake).

**Tooling:** Vitess (YouTube), Citus (Postgres extension), and MongoDB's built-in sharding handle shard management, query routing, and resharding. Rolling your own sharding is rarely justified.

### Database Per Service (Microservices)

Each microservice owns its database. No shared databases. Benefits: technology flexibility (Postgres for users, MongoDB for inventory, Redis for sessions), independent scaling, and fault isolation. Cost: cross-service queries require API composition or CQRS read models.

### Hybrid Strategies

Production systems combine patterns. Example: read replicas for hot data + hash sharding for user posts + separate database for messaging + geographic sharding for cross-region deployment.

## Multi-Level Caching Hierarchy

Caching operates at four levels, each with different latency and scope:

| Level | Latency | Scope | Example |
|-------|---------|-------|---------|
| Browser cache | 0–5ms | Per user | HTTP cache headers, ETags |
| CDN cache | 20–50ms | Geographic region | Cloudflare, CloudFront |
| Application cache | 1–5ms | Per service instance | Redis, Memcached, Caffeine |
| Database query cache | 10–20ms | Per database | Shared buffers, query cache |

**Cache invalidation strategies:**
- **TTL-based**: Simplest — data expires after a fixed duration. Risk of serving stale data.
- **Event-based**: Explicitly invalidate on data mutation. Publish invalidation events so all cache layers can evict stale entries.
- **Tag-based**: Group cached items by tags for bulk invalidation (e.g., invalidate all items tagged with a department when that department's data changes).

**Cache stampede prevention:** When a hot key expires under load, N concurrent requests all miss cache and hit the database. Solutions:
- **Request coalescing**: Only one thread/request fetches from DB; others wait for that result.
- **Probabilistic early expiration**: Refresh the cache before expiry with some probability.
- **Distributed locking for cache reload**: Only one instance loads the data; others wait briefly and recheck cache.

**Cache warming:** Pre-populate caches before traffic arrives. Patterns: scheduled warm-up (cron before peak hour), write-through warming (cache on every write), background refresh (serve stale data while refetching async).

**When not to cache:**
- Rapidly changing data (stock prices, live scores)
- User-specific data with low reuse probability
- Queries that are already fast (< 5ms) — caching overhead may exceed the query cost

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
- Related: [[concepts/ml-recommendation-systems|ML Recommendation Systems at Scale]]
- Source: [[sources/instagram-explore-recommendations|Scaling Instagram Explore Recommendations]]
- Source: [[sources/byte-storage-vs-io|Byte Storage vs. I/O]]
- Source: [[sources/netflix-open-connect-cdn-strategy|Netflix Open Connect CDN Strategy]]
- Source: [[sources/postgresql-advanced-indexing|PostgreSQL Advanced Indexing Guide]]
- Source: [[sources/latency-gambler-day-10|Caching Patterns]]
- Source: [[sources/latency-gambler-day-13|Event Sourcing & CQRS Patterns]]
- Source: [[sources/latency-gambler-day-16|Distributed System Patterns]]
- Source: [[sources/latency-gambler-day-18|Caching & CDN Patterns]]
- Source: [[sources/latency-gambler-day-19|Database Scaling Patterns]]
