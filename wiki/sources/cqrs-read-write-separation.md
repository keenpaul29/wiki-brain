---
title: "The Read That Was Killing the Write"
type: source
created: 2026-06-01
source: https://systemdesignprimer.substack.com/p/the-read-that-was-killing-the-write
tags:
  - source
---

# The Read That Was Killing the Write

## Summary

This source frames CQRS as a response to read/write workload conflict. A write model enforces business rules and consistency; a read model answers query-shaped, denormalized, pre-aggregated questions. Separating them prevents analytical reads from contending with latency-sensitive writes.

## Key Ideas

- **One model cannot serve both masters**: A normalized write schema is not ideal for dashboard aggregation, while denormalized read shapes are unsafe for authoritative writes.
- **Read replicas only move load**: They preserve the same schema shape, so complex joins and aggregations still happen at query time.
- **Command and query models**: Writes update the command model and emit events; projectors consume those events to update optimized read models.
- **Eventual consistency is explicit**: The read model lags the write model. UI and API flows must decide whether to accept lag, read command state after writes, or return enough command-response data to render success immediately.
- **Rebuildable projections**: Durable event history allows read models to be dropped and rebuilt after schema changes or projection bugs.
- **Operational risks**: Projection lag and silent drift need monitoring, fast rebuilds, and idempotent projection logic.
- **Use selectively**: CQRS is justified when read and write access patterns differ in schema shape, scale, or consistency needs; simple CRUD rarely benefits.

## Links

- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[concepts/system-design|System Design]]

