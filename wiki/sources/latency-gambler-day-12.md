---
title: "Message Queue Patterns"
type: source
created: 2026-06-14
source: https://archive.is/0Q7ky
tags:
  - source
---

# Message Queue Patterns

## Summary

Day 12 of The Latency Gambler's system design series. Covers async communication with pub/sub pattern, message queue vs topic patterns, command pattern for async operations, dead letter queues, message deduplication, priority queues, and production best practices for message-based architectures.

## Key Ideas

- **Synchronous Problem**: Tight coupling, cascade failures, performance bottlenecks, and scaling issues.
- **Pub/Sub Pattern**: Publishers send messages to topics; subscribers receive messages they're interested in. Complete decoupling, easy to extend, parallel processing, failure isolation.
- **Message Queue (Point-to-Point)**: One-to-one communication, each message consumed by exactly one consumer. Used for work distribution, load balancing, and sequential processing.
- **Topic (Publish-Subscribe)**: One-to-many broadcast. Used for event broadcasting, real-time updates, and audit logging.
- **Command Pattern for Async**: Turns operations into queuable, schedulable, retryable, auditable message objects. Backbone of task queues and workflow engines.
- **Dead Letter Queue (DLQ)**: Special queue for messages that can't be processed after multiple attempts.
- **Message Deduplication**: Uses Redis to track processed message IDs for idempotent processing.
- **Priority Queues**: Messages processed in priority order based on assigned priority levels.
- **Technology Comparison**: RabbitMQ (general messaging), Apache Kafka (high-throughput streaming), Amazon SQS (simple task queues), Redis Pub/Sub (real-time notifications), Apache Pulsar (multi-tenant, geo-replication).

## Links

- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[concepts/reliability-and-operations|Reliability and Operations]]
- Connects to [[concepts/system-design|System Design]]
