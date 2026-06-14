---
title: Event-Driven Architecture
type: concept
created: 2026-06-14
tags:
  - concept
  - event-driven
  - cqrs
  - cdc
  - event-sourcing
  - system-design
---

# Event-Driven Architecture

Event-driven architecture decouples producers from consumers through an intermediary event channel. Instead of one service calling another directly, a service emits an event describing what happened, and interested services react independently. This pattern is foundational for scalable, loosely-coupled systems.

## Core Concepts

### Events vs Messages

| | Event | Command | Message |
|---|---|---|---|
| **Intent** | Something happened | Do something | Deliver data |
| **Producer** | Does not know who consumes | Names a specific consumer | May or may not name consumer |
| **Consumer** | Decides what to do | Expected to execute | Processes data |
| **Example** | `order.placed` | `send.invoice` | `{"order_id": 123}` |
| **Failure** | May be stale or out of order | Must be retried | Depends on queue config |

Events are always in past tense. They are facts that have already occurred. Commands are requests for future action. This distinction matters for error handling: events cannot fail (they already happened), but commands can.

### Pub/Sub Pattern

Publishers send events to topics. Subscribers receive events they are interested in:

```
[Order Service] → publishes "order.placed" → [Topic: orders]
                                                 ↓            ↓
                                        [Payment Svc]  [Inventory Svc]
```

Key properties:
- N publishers to N subscribers, one-to-many.
- Publishers do not know subscriber identity.
- Subscribers do not affect the publisher's flow.
- Easy to add new subscribers without changing publishers.

### Message Queues

Queues differ from pub/sub: each message is consumed by exactly one consumer from a competing consumer group:

```
[Order Service] → "send.invoice" → [Queue] → [Invoice Worker 1]
                                               [Invoice Worker 2]
                                               [Invoice Worker 3]
```

Use queues for work distribution (parallel processing of tasks). Use topics for event broadcasting (multiple independent reactions).

## CQRS (Command Query Responsibility Segregation)

### Concept

Separate the write model from the read model:

```
[Client] → Command → [Write Model (normalized)]
                         ↓
                   [Event Store or DB]
                         ↓
                   [Read Model (denormalized)]
[Client] → Query  → [Read Model]  (faster reads)
```

The write model handles commands (inserts, updates, deletes) with validation and business logic. The read model handles queries with optimized, denormalized data structures.

### When to Use CQRS

- Read and write workloads have different shapes (write-heavy vs read-heavy).
- Different read models needed for different queries.
- Team needs to optimize read performance without affecting write logic.
- The read model can be rebuilt from the event log.

### When NOT to Use CQRS

- Simple CRUD applications — CQRS adds complexity without benefit.
- Strong eventual consistency requirements — read model is always behind writes.
- Small team without event-driven experience.

### Dual-Write Problem

The fundamental challenge with CQRS: how do you atomically write to the database AND emit an event?

**Wrong approach**: write to DB then publish event. If the publish fails, the DB write is committed but no event is emitted.

```
1. UPDATE orders SET status = 'confirmed' WHERE id = 123;  ✓
2. kafka.publish("order.confirmed", data);                   ✗ (kafka is down)
→ DB is inconsistent with event stream
```

**Solution**: use the database transaction log as the event source (CDC — see below). The write proves the event.

## Change Data Capture (CDC)

CDC reads the database transaction log (PostgreSQL WAL, MySQL binlog) and publishes row changes as events:

```
[Application] → writes to DB → [Transaction Log (WAL)]
                                    ↓
                              [CDC Connector (Debezium)]
                                    ↓
                              [Kafka Topic: db.orders]
                                    ↓                     ↓
                            [Search Index]          [Cache Refresh]
```

### Advantages Over Dual-Write

- **Atomic**: The transaction log is the authoritative record of every committed write.
- **Complete**: Every row change is captured, even changes made outside the application (SQL console, migrations, batch jobs).
- **No application changes**: The database emits events without modifying application code.

### Fan-Out Use Cases

A single CDC stream feeds multiple consumers independently:

- Search indexing (update Elasticsearch when order status changes).
- Cache invalidation (clear Redis cache entries).
- Audit logging (append-only log of all changes).
- Microservice synchronization (other services react to data changes).
- Analytics pipeline (stream changes to data warehouse).

### Operational Risks

| Risk | Cause | Mitigation |
|------|-------|------------|
| Replication slot bloat | Consumer falls behind | Monitor slot age and lag |
| Schema changes break consumers | Column rename or drop | Schema registry, tolerant readers |
| Startup bootstrap missing events | Large tables need initial snapshot | Manual snapshot + WAL offset tracking |
| At-least-once delivery | Duplicate events possible | Idempotent consumers (LSN tracking) |

## Event Sourcing

### Concept

Store the sequence of events that led to current state, not just the current state:

```
Traditional:  order_table = {id: 123, status: "confirmed", total: 49.99}
Event Store:  [
  {type: "order.created",  data: {id: 123, total: 49.99}, timestamp: T1},
  {type: "order.confirmed", data: {id: 123},              timestamp: T2},
  {type: "item.shipped",   data: {id: 123, sku: "ABC"},   timestamp: T3}
]
```

Current state is derived by replaying all events. This is called a **projection**.

### Advantages

- **Complete audit trail**: every state change is recorded and immutable.
- **Time travel**: query the system as of any point in time.
- **Debugging**: replay events to reproduce bugs.
- **Analytics**: mine the event stream for business insights.

### Event Snapshotting

Replaying thousands of events on every read is slow. Snapshots store the aggregate state at periodic intervals:

```
Snapshot at version 1000: order_123 = {status: "confirmed", items: [...]}
New events after snapshot: events 1001-1050
→ Load snapshot + replay 50 events instead of 1050
```

Take snapshots every N events (e.g., every 100) or by time (e.g., daily). Store the snapshot version alongside the snapshot.

### Event Versioning

Event schemas evolve over time. Strategies for backward compatibility:

| Strategy | Behavior | When to Use |
|----------|----------|-------------|
| New field (optional) | Add field with default | Safe, most common |
| New event type | Create `order.placed.v2` | Breaking changes |
| Upcaster | Read old format, transform on load | Must keep old events |
| Versioned envelope | Each event carries a schema version | Strict schema governance |

Rule: never modify or delete events. Append-only. To "delete" data, write a deletion event and exclude from projections.

## Projections

A projection reads events and builds a derived view:

```python
def order_projection(events):
    state = {"status": None, "items": [], "total": 0}
    for event in events:
        if event.type == "order.created":
            state["items"] = event.data["items"]
            state["total"] = event.data["total"]
        elif event.type == "order.confirmed":
            state["status"] = "confirmed"
        elif event.type == "item.shipped":
            # track shipped items
            state["shipped"] = state.get("shipped", []) + [event.data["sku"]]
    return state
```

### Rebuilding Projections

When a projection bug is found or a new read model is needed, rebuild from the full event log:

```
1. Start with empty state.
2. Read all events from the event store.
3. Apply each event in order.
4. Write the new projection.
```

For large event stores, rebuild time is significant. Use snapshotting to bound replay to recent events.

### Incremental Projections

Instead of full rebuilds, keep the projection up to date with new events:

```
1. Load last projection + the version it represents.
2. Read events after that version.
3. Apply new events to the existing projection.
4. Save new projection with updated version.
```

## Saga Pattern

For distributed transactions across services, sagas use compensating actions instead of distributed locks:

### Choreographed Saga

Each service reacts to events and emits its own events:

```
1. Order Service: create order (PENDING) → emit "order.created"
2. Payment Service: reserve payment → emit "payment.reserved"
3. Inventory Service: reserve inventory → emit "inventory.reserved"
4. Order Service: mark order as CONFIRMED

On failure at step 3:
  → Inventory Service emits "inventory.reservation.failed"
  → Payment Service listens, releases payment
  → Order Service listens, marks order as FAILED
```

### Orchestrated Saga

A central saga coordinator manages the flow:

```
[Saga Coordinator]
  → Step 1: call Order Service → "order.created"
  → Step 2: call Payment Service → "payment.reserved"
  → Step 3: call Inventory Service → FAILED
  → Compensate: call Payment Service → "payment.released"
  → Compensate: call Order Service → "order.failed"
```

### Decision Table

| Factor | Choreographed | Orchestrated |
|--------|--------------|-------------|
| Coupling | Loose (events only) | Tighter (knows coordinator) |
| Traceability | Hard (distributed across services) | Easy (central coordinator log) |
| Rollback | Implicit (compensation events) | Explicit (coordinator commands) |
| Complexity per service | Higher (each handles compensation) | Lower (coordinator handles logic) |

## Event Schema and CloudEvents

Events must have a defined schema to evolve without breaking consumers. The CloudEvents standard provides a common envelope:

```json
{
  "specversion": "1.0",
  "type": "order.created",
  "source": "/orders/v2",
  "id": "d94f3a17-3a8f-4f9b-8f0a-2e1c5d6b7a8c",
  "datacontenttype": "application/json",
  "data": {
    "order_id": "ORD-12345",
    "customer_id": "CUST-678",
    "total": 49.99
  }
}
```

Schema registry (Apicurio, Confluent Schema Registry) enforces compatibility and prevents producers from breaking consumers.

## Links

- Parent concept: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/microservices-architecture|Microservices Architecture]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Source: [[sources/latency-gambler-day-13|Event Sourcing & CQRS Patterns]]
- Source: [[sources/latency-gambler-day-12|Message Queue Patterns]]
- Source: [[sources/change-data-capture-event-log|Your Database Has Been Writing an Event Log]]
- Source: [[sources/monolith-to-service-migration|Monolith to Service Migration Strategies]]
