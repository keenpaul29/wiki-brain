---
title: "The Read That Was Killing the Write"
source: "https://systemdesignprimer.substack.com/p/the-read-that-was-killing-the-write"
author:
  - "[[System Design Primer]]"
published: 2026-05-23
created: 2026-06-01
description: "Your order service is slow."
tags:
  - "clippings"
---
> Your order service is slow. Not just slow — unpredictably slow. Placing an order sometimes takes 40ms, sometimes 400ms. You add database indexes. You tune the connection pool. The p99 improves a little, then gets worse again.
> 
> You add some logging and discover something: the slowdowns correlate with spikes in your analytics dashboard traffic. Every time a manager opens the “orders by region” report, the order placement latency spikes. Same table. Same database. Two completely different operations fighting over the same resources.
> 
> The problem is not the index or the connection pool. The problem is that your write operation and your read operation have fundamentally different requirements, and you are forcing them to share a single data model.

---

## Why One Model Cannot Serve Two Masters

> When you write an order, you need something specific: a model that enforces business rules. Is the customer’s payment method valid? Does the inventory exist? Is this a duplicate request? These questions require the current, authoritative state of the data, strict consistency, and often multiple table reads before the write commits. Speed matters, but correctness matters more.
> 
> When you read orders for a dashboard, you need something completely different: pre-aggregated, denormalised data that answers the question in one database call. “Show me total orders by region, by hour, for the last 30 days” requires joining the orders table with the customers table with the regions table, then grouping, then aggregating. It is a fundamentally different shape of query. And it does not need to be perfectly consistent — a dashboard showing data that is 500ms old is completely acceptable.
> 
> One data model cannot be optimised for both simultaneously. A schema optimised for writes — normalised, enforcing constraints, with appropriate indexes for the write access pattern — is inefficient for complex reads. A schema optimised for reads — denormalised, pre-aggregated, flattened — is wrong for writes because you lose the consistency constraints and end up with update anomalies everywhere.
> 
> The traditional solution is to add read replicas. They help, but they do not solve the shape problem. A read replica has the same schema as the primary. The complex join is still complex. The aggregation still happens at query time. You have distributed the load but you have not fixed the mismatch.

---

## Two Models, Two Jobs, One Event Between Them

Command Query Responsibility Segregation — CQRS — is the pattern that formalises this separation. Maintain two distinct models. The **command model** handles writes. It enforces business rules, maintains consistency, and is optimised for the write access pattern. The **query model** handles reads. It is structured specifically for the queries you need to answer, denormalised, pre-computed where useful, optimised purely for read performance.

The two models stay in sync through an event. When a command (write) succeeds, it emits an event — `OrderPlaced`, `OrderShipped`, `OrderCancelled`. A projection function consumes that event and updates the query model accordingly.

```markup
Client → Command → validate → write → emit event
                                          ↓
                                      event bus
                                          ↓
                              projector → update read model
                                          ↓
                              Client ← query ← read model
```

The write path touches the command model and emits an event. The read path touches only the read model. They never touch the same data store at query time. The manager’s dashboard query hits the read model. The order placement hits the command model. They cannot interfere with each other.

---

## The Consistency Gap You Have to Design For

![](https://substackcdn.com/image/fetch/$s_!j7IS!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fbc20c567-6f8e-4cf9-b450-6a34b47a3cdc_760x460.gif)

The read model is updated asynchronously, after the write commits and the event propagates. There is a window — typically milliseconds, occasionally seconds under load — where the command model has committed a write that the read model does not yet reflect.

This is eventual consistency, and it is the trade-off CQRS asks you to accept explicitly. Most teams discover it implicitly: a user places an order, is redirected to the order list page, and their new order is not there yet. The write succeeded. The read model has not caught up.

Three standard responses to this gap:

**Accept it and set expectations.** Many applications tolerate “your order will appear within a few seconds.” This is the simplest approach and correct for most use cases.

**Read from the command model immediately after a write.** For the specific read that immediately follows a write — “show me what I just created” — bypass the read model and query the command model directly. For all subsequent reads, use the read model.

**Return the result directly from the command.** The command handler returns enough data in its response to populate the UI without a subsequent read. The client uses the response to render the success state, and later reads hit the eventually consistent model once projection catches up.

The mistake teams make is trying to eliminate the consistency gap entirely — by making projection synchronous, by using distributed transactions across both models. This defeats the purpose and adds significant operational overhead. The gap is the trade-off. Design for it.

---

## What the Read Model Actually Looks Like

The power of CQRS is that the read model can be whatever shape the queries need, independent of the command model’s normalised schema.

For an “orders by region” dashboard that previously required a three-table join and GROUP BY, the read model is a single table: `region`, `hour`, `order_count`, `total_revenue` — pre-computed and updated by the projector on every `OrderPlaced` event. The dashboard query is `SELECT * FROM order_summary WHERE region = ? AND hour >= ?`. One table, no joins, no aggregation at read time. The query takes 2ms regardless of how many orders exist.

The read model does not need to be a relational database. A read model serving full-text search might be an Elasticsearch index. One serving a mobile app might be DynamoDB documents. One serving a real-time dashboard might be Redis hashes. Each query use case can have a read model optimised specifically for it, with no concessions to what the write side needs.

This flexibility is where CQRS delivers its most concrete value. The read model is not a compromise between what writes need and what reads need. It is designed purely for reads, with no concessions.

---

## Three Production Problems Worth Knowing in Advance

**Projection lag during high write volume.** The projector consumes events and updates the read model. Under heavy write load, events queue up faster than the projector can process them. The read model falls behind — not by milliseconds but by seconds or minutes. Projection lag — the age of the oldest unprocessed event — is the critical operational metric. If it exceeds your consistency tolerance, scale the projector or optimise its logic.

**Read model rebuild as a normal operation.** One of CQRS’s underappreciated advantages: the read model can be rebuilt at any time from the full event history. Need to change the read model schema, add a field, fix a projection bug? Delete the read model and replay all events from the beginning. The projector processes them in order and produces the corrected model. No data migration. No schema change on the command side.

This only works if your event history is durable and complete. If you discard events after projecting them, you lose this ability. Store events permanently.

**Silent drift when the projector has a bug.** If the projector handles an edge case incorrectly, the read model silently drifts from command model state. The fix requires correcting the projector bug and rebuilding the read model from scratch. Treating rebuild as routine — not emergency — requires it to be fast. If rebuilding takes 6 hours, teams avoid it and let drift accumulate. Keep rebuild time short enough that doing it regularly is not painful.

---

## When CQRS Is the Wrong Answer

CQRS adds complexity: two models, an event bus, a projection layer, eventual consistency to reason about. This complexity pays off when write and read access patterns differ genuinely in shape, scale, or consistency requirements. It does not pay off when they do not.

A simple CRUD service where reads and writes hit the same data with similar query shapes does not need CQRS. The test: do my read queries require a fundamentally different schema from what my write constraints need? If reads need denormalised data that writes need normalised — yes. If reads need pre-aggregation that writes cannot support — yes. If reads and writes have different performance requirements that a single model cannot satisfy — yes. Otherwise, CQRS is complexity in search of a problem.

The dashboard-vs-order-placement contention was a design problem, not a performance problem. One model doing two contradictory jobs. CQRS gives each job its own model, optimised for its own requirements. The 400ms order placement that correlated with dashboard traffic disappears — because the dashboard is no longer competing with order placement for the same resources.