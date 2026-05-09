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

## Lookup Structures

Dictionary-style lookups are a basic form of data-system design. Unsorted arrays optimize simplicity and appends but make membership checks O(n). Sorted arrays support binary-search lookups with low memory overhead but make inserts and deletes expensive. Hash tables are the default for unordered membership and key-value access because average lookup, insert, and delete are O(1), while balanced binary search trees preserve ordering for range queries and predecessor/successor operations.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/system-design-case-studies|System Design Case Studies]]
- Source: [[sources/system-design-course|System Design Course]]
- Source: [[sources/dictionary-problem-fast-lookups|The Dictionary Problem - Fast Lookups in Large Collections]]
