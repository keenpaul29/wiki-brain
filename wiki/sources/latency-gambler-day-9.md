---
title: "Database Patterns & Repository Pattern"
type: source
created: 2026-05-27
source: https://archive.is/eaS3M
tags:
  - source
---

# Database Patterns & Repository Pattern

## Summary

This article is Day 9 of The Latency Gambler's system design series. It focuses on clean data persistence layers, detailing the **Repository Pattern** to decouple business logic from storage mechanisms, connection management strategies (Connection Pool and Connection Factory), and database choice frameworks (SQL vs. NoSQL).

## Key Ideas

- **Repository Pattern**: An abstraction layer between business logic and database persistence. It hides query specifics, simplifies testing through mocking, and separates domain models from database schemas.
- **Database Selection Framework**:
  - **SQL**: Chosen for ACID compliance, complex relationships, structured schemas, joins, and reporting workloads.
  - **NoSQL**: Chosen for horizontal scaling, flexible/dynamic schemas, high throughput, and simple key-value/document-retrieval patterns.
- **Database Connection Patterns**:
  - **Connection Pool**: Reuses a pool of active database connections (using tools like HikariCP) to avoid the high overhead of establishing raw connections.
  - **Connection Factory**: Manages retrieval of connections, facilitating read/write separation (routing writes to primary and reads to replicas) and executing failover/circuit-breaking logic.
- **Production Lessons**:
  - Keep repositories focused (one repository per aggregate root).
  - Use batch operations to scale write workloads.
  - Separate read and write workloads early using read replicas.
  - Set proper connection timeouts to prevent hanging connections and monitor connection pool exhaustion.

## Links

- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Connects to [[sources/latency-gambler-day-8|Load Balancing & Circuit Breaker Patterns]]
