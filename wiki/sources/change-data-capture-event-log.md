---
title: "Your Database Has Been Writing an Event Log the Whole Time"
type: source
created: 2026-06-01
source: https://systemdesignprimer.substack.com/p/your-database-has-been-writing-an
tags:
  - source
---

# Your Database Has Been Writing an Event Log the Whole Time

## Summary

This source explains Change Data Capture (CDC) as the practice of reading database transaction logs, such as PostgreSQL WAL or MySQL binlog, and publishing row-level changes to downstream systems. CDC avoids the dual-write problem because every committed database write is already in the transaction log.

## Key Ideas

- **Dual writes are not atomic**: Updating a database and publishing to Kafka can fail between systems, and out-of-band writes can silently bypass application-level event publishing.
- **Transaction logs are authoritative**: WAL/binlog entries include operation type, table, transaction position, and row images when configured for logical or row-level replication.
- **Debezium-style pipeline**: A connector reads the log as a replication client, transforms changes into structured events, and publishes them to Kafka or another stream.
- **Fan-out use cases**: Search indexing, cache invalidation, audit logging, and microservice synchronization can consume the same database change stream independently.
- **Replication slot bloat**: If CDC consumers fall behind, retained WAL can fill disk and stop writes; replication lag and slot age must be monitored.
- **Schema evolution**: Downstream event consumers need schema compatibility rules or tolerant readers, especially for destructive database changes.
- **Idempotent consumers**: CDC delivery is at least once, so consumers should use LSN, transaction ID, or event keys to avoid duplicate side effects.
- **Initial snapshot**: Existing rows must be bootstrapped before incremental log consumption; large tables may need retained WAL headroom or manual export-based bootstrap.

## Links

- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[sources/monolith-to-service-migration|Monolith to Service Migration Strategies]]

