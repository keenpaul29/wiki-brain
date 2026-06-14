---
title: "Database Scaling Patterns"
type: source
created: 2026-06-14
source: https://archive.is/5Vr4f
tags:
  - source
---

# Database Scaling Patterns

## Summary

Day 19 of The Latency Gambler's system design series. Covers Read Replicas (read-your-own-writes pattern, replication lag), Database Sharding (hash-based, range-based, geographic), Database Per Service for microservices, hybrid strategies, and practical considerations for scaling databases horizontally.

## Key Ideas

- **Read Replicas**: Most apps have 90:10 read-to-write ratio. Send reads to replicas, writes to primary. Simple win for read-heavy workloads.
- **Replication Lag**: Replication isn't instant. Read-Your-Own-Writes pattern forces reads to primary after writes. Session affinity tracks recent writes.
- **Hash-Based Sharding**: Distributes data evenly across shards using hash of shard key. Even distribution but resharding is difficult and range queries don't work across shards.
- **Range-Based Sharding**: Data distributed by range (e.g., A-M on shard 1, N-Z on shard 2). Supports range queries but can have uneven distribution.
- **Geographic Sharding**: Data sharded by geographic region. Perfect for global apps but cross-region queries are expensive.
- **Sharding Pain Points**: Joins across shards are impossible (use denormalization or application-level joins). Distributed transactions don't work across shards (use eventual consistency).
- **Database Per Service**: Each microservice gets its own database. Technology flexibility, independent scaling, fault isolation, and team autonomy.
- **Hybrid Strategy**: Real-world systems combine read replicas, sharding, and separate databases (e.g., profile replicas + post shards + separate message DB).
- **Auto-Sharding Tools**: Vitess, Citus, MongoDB built-in sharding instead of rolling your own.
- **Connection Pooling & Proxy Layers**: At scale, database connection overhead becomes significant. Connection poolers (PgBouncer, ProxySQL) sit between application servers and databases, multiplexing thousands of client connections through a smaller pool of persistent database connections.
- **Change Data Capture (CDC) for Read Replicas**: Tools like Debezium stream database mutations to consumer services via Kafka, keeping read replicas, caches, and search indexes eventually consistent with the primary. This decouples read model freshness from the query path latency.
- **Online Schema Migrations**: Scaling databases requires schema changes without downtime. Strategies include shadow tables (dual-write old and new, migrate readers gradually), gh-ost / pt-online-schema-change for MySQL, and using nullable columns with application-level backfill.

## Links

- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/performance-engineering|Performance Engineering]]
- Connects to [[concepts/reliability-and-operations|Reliability and Operations]]
- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]]
