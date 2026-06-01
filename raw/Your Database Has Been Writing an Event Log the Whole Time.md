---
title: "Your Database Has Been Writing an Event Log the Whole Time"
source: "https://systemdesignprimer.substack.com/p/your-database-has-been-writing-an"
author:
  - "[[System Design Primer]]"
published: 2026-05-18
created: 2026-05-30
description: "Every write to a PostgreSQL or MySQL database — every INSERT, UPDATE, DELETE — is recorded in a transaction log before it touches the actual data."
tags:
  - "clippings"
---
> Every write to a PostgreSQL or MySQL database — every INSERT, UPDATE, DELETE — is recorded in a transaction log before it touches the actual data. This log exists for crash recovery: if the database crashes mid-write, it replays the log to restore a consistent state. It is not a new feature. PostgreSQL’s Write-Ahead Log has existed since version 7.1 in 2001. MySQL’s binary log has existed since version 3.23 in 2000.
> 
> What changed is that we figured out how to read these logs as a stream of events and route them to other systems — without touching a line of application code. This is Change Data Capture.

---

## Why “Just Add an Event Publisher” Doesn’t Work

The obvious alternative to CDC is dual writing: when your application updates the database, it also publishes an event to Kafka. You control the event content, you control the timing, you control what gets published. Clean and simple.

Dual writing fails at the atomicity boundary. You cannot atomically update a database and publish to Kafka — they are separate systems. If the application crashes after the database write but before the Kafka publish, the event is lost. If Kafka is temporarily unavailable, the application has to decide between holding back the database write (slowing your service) or proceeding without the publish (losing the event). If a developer adds a new code path that updates the database without the corresponding publish, that code path silently bypasses your event stream.

That last failure mode is the one that causes the most pain. In a codebase with multiple teams, maintaining the discipline that every database write has a corresponding event publish requires ongoing coordination and enforcement. It leaks. A migration script runs directly against the database. An admin panel updates records without going through the application layer. A background job modifies data without the event publication path. Each of these produces a database state that is inconsistent with the event stream — and the inconsistency is invisible until something downstream breaks.

CDC sidesteps all of these by reading the transaction log rather than instrumenting the application. **Every write that reaches the database is in the log.** Not the writes that went through the correct code path. Not the writes that remembered to call the event publisher. Every write, from every source, without exception.

---

## What the WAL Actually Contains

In PostgreSQL, every write operation produces one or more entries in the Write-Ahead Log (WAL). Each entry contains:

- The **Log Sequence Number (LSN)** — a monotonically increasing identifier for this position in the log. This is what CDC tools use as a bookmark: “I have read everything up to LSN 0/16B46B8. Give me everything after that.”
- The **operation type** — INSERT, UPDATE, or DELETE.
- The **table name** and schema.
- The **before image** (for UPDATE and DELETE) — the row values before the change.
- The **after image** (for INSERT and UPDATE) — the row values after the change.
- The **transaction ID** — linking this change to the transaction it belongs to.

By default, PostgreSQL’s WAL does not include the before and after images at the column level — it records enough for crash recovery but not enough for CDC. To enable full column-level logging, you set `wal_level = logical` in `postgresql.conf`. This tells PostgreSQL to write enough detail in the WAL for logical replication and CDC tools to reconstruct the exact row-level changes.

MySQL’s equivalent is the binary log with `binlog_format = ROW` — row-level format writes the actual row values rather than the SQL statements, which is what CDC tools need to reconstruct changes without re-executing potentially non-deterministic SQL.

A Debezium connector subscribes to the database as a logical replication client. PostgreSQL sends it WAL entries in sequence. Debezium transforms each WAL entry into a structured event — typically a JSON or Avro document — and publishes it to a Kafka topic. The Kafka message looks like:

```markup
{
  "op": "c",
  "ts_ms": 1715123456789,
  "before": null,
  "after": {
    "id": 42,
    "customer_id": 8824,
    "amount": 9900,
    "status": "pending"
  },
  "source": {
    "table": "orders",
    "lsn": "0/16B46B8",
    "txId": 491
  }
}
```

`op: "c"` is create (INSERT). `op: "u"` is update. `op: "d"` is delete. The before image is null for inserts. The after image is null for deletes. For updates, both are present — which is what makes CDC events useful for downstream systems that need to know not just what the new value is, but what it changed from.

---

## The Fan-Out That Makes CDC Powerful

![](https://substackcdn.com/image/fetch/$s_!oiJY!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F7a60cabd-b2b9-4ef2-9f38-f9d337c15ac1_760x460.gif)

The value of routing database changes through Kafka is that a single event stream can serve many independent consumers without any coupling between them.

**Search index synchronisation.** An Elasticsearch index on the `orders` table needs to stay in sync with the database. Without CDC, you either query the database on a schedule (slow, misses deletes), add application-layer publishing (the dual-write problem), or run a full re-index periodically (expensive, and the index is stale between runs). With CDC, a Kafka consumer reads the orders change events and applies them to Elasticsearch in near-real-time. Inserts add documents. Updates modify them. Deletes remove them. The search index is typically 50–500 milliseconds behind the database — close enough for every practical use case.

**Cache invalidation.** Redis caching a user’s profile or product details needs to know when the underlying database record changes. With CDC, a cache invalidation consumer reads the relevant table’s change events and evicts or updates the cache entry on every change. This is more reliable than TTL-based expiry (which leaves stale data for the full TTL period) and more reliable than application-layer cache invalidation (which has the same dual-write problems as event publishing).

**Audit logging.** Compliance requirements often mandate a complete, tamper-evident log of all data changes. CDC provides this automatically: every change to every row is captured in the WAL, transformed into a structured event, and can be durably stored in S3, a data warehouse, or a dedicated audit database. No application code needs to implement audit logging; it happens at the infrastructure layer.

**Microservice synchronisation.** In a microservices architecture where the orders service owns the orders table but the fulfilment service needs to react to new orders, CDC provides a clean decoupling: the orders service’s database changes produce events that the fulfilment service consumes, without the orders service needing to know the fulfilment service exists.

---

## The Three Failure Modes to Understand Before Deploying

**Replication slot bloat.** In PostgreSQL, Debezium creates a logical replication slot. The slot holds the LSN position of the last event Debezium has confirmed processing. PostgreSQL cannot remove WAL entries until all replication slots have confirmed they no longer need them. If Debezium is stopped, restarts, or falls behind — and the slot is not actively consuming WAL — PostgreSQL accumulates WAL entries indefinitely. The WAL directory grows until the disk fills, at which point PostgreSQL stops accepting writes.

This is the most dangerous operational hazard in CDC deployments. The mitigation: monitor `pg_replication_slots` and alert when `pg_wal_lsn_diff(pg_current_wal_lsn(), confirmed_flush_lsn)` exceeds a threshold (typically a few GB). If Debezium is going to be stopped for an extended period, drop the replication slot rather than leaving it open. When restarted, Debezium will perform a snapshot of the current table state and resume from the current WAL position.

**Schema changes breaking the pipeline.** CDC events carry the schema of the source table at the time of the change. When you `ALTER TABLE` to add a column, the event schema changes — and downstream consumers that expect the old schema will fail to deserialise the new events. This requires a schema evolution strategy: either schema registry (Confluent Schema Registry, AWS Glue Schema Registry) with compatibility rules that enforce backward or forward compatibility, or consumer-side tolerance for unknown fields.

Destructive schema changes — dropping a column, changing a column’s type — require coordinated rollout: update consumer code to handle both schemas, deploy the schema change, then remove the old handling code. This is the same challenge as API versioning applied to event schemas, and it requires the same discipline.

**At-least-once delivery and idempotent consumers.** CDC delivers each WAL entry at least once. Debezium may restart after a crash and re-deliver events that were published but not confirmed. This means CDC consumers must be idempotent: applying the same event twice should produce the same result as applying it once. For a search index, re-applying an INSERT or UPDATE is idempotent — the document is upserted. For a counter or an audit log append, it is not — the counter increments twice, the audit log has a duplicate entry.

The pattern for non-idempotent operations is to use the event’s LSN or transaction ID as an idempotency key, storing the last-processed LSN in the consumer’s own database and skipping events with an LSN at or below the stored value. This is the same idempotency key pattern from Lesson 3 (Exactly-Once Semantics) applied at the infrastructure layer rather than the application layer.

---

## The Initial Snapshot Problem

When you first enable CDC on an existing table, you face a bootstrapping problem: the WAL only contains changes from the point where you started the replication slot. The existing rows in the table are not in the WAL. Downstream systems starting from an empty state need to be populated with existing data before they can consume incremental changes.

Debezium solves this with an initial snapshot: when a connector is first configured, it reads the full table in a consistent snapshot (using a consistent read transaction in PostgreSQL, or the `REPEATABLE READ` isolation level in MySQL) and publishes each row as a synthetic `CREATE` event. After the snapshot completes, it switches to real-time WAL consumption from the LSN at which the snapshot started.

For large tables, the initial snapshot is the bottleneck. A table with 500 million rows takes hours to snapshot. During that time, Debezium is reading from the database but not consuming the WAL — meaning the WAL is accumulating. If the snapshot takes longer than the WAL retention period, entries are purged before Debezium can read them. The standard mitigation is to configure PostgreSQL to retain at least 24 hours of WAL (`wal_keep_size` in PostgreSQL 13+, `wal_keep_segments` in older versions), giving snapshot time headroom.

For very large tables, the alternative is a manual bootstrap: export the table to the target system directly (using `COPY` to S3 and then loading into the destination), then start Debezium at the LSN corresponding to the export timestamp, applying only changes that occurred after the export. This is operationally more complex but avoids the snapshot bottleneck entirely.

---

CDC is the infrastructure pattern that makes “the database as the source of truth” actually work in a distributed system. Every system that needs to react to data changes gets a reliable, ordered stream of those changes, derived from the one source that cannot miss a write — the database transaction log.

The alternative — trying to maintain consistency between multiple systems by publishing events from application code — fails quietly and consistently. CDC fails loudly when it fails, which is a much better property.