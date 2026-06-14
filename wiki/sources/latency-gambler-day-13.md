---
title: "Event Sourcing & CQRS Patterns"
type: source
created: 2026-06-14
source: https://archive.is/zquSs
tags:
  - source
---

# Event Sourcing & CQRS Patterns

## Summary

Day 13 of The Latency Gambler's system design series. Covers Event Sourcing (immutable event log for complete audit trails and time travel), CQRS (separating read and write models for independent scaling), Saga pattern for distributed transactions, and production considerations including event snapshotting, event versioning, and projection rebuilding.

## Key Ideas

- **Event Sourcing**: Stores the sequence of events that led to current state instead of just the current state. Provides complete audit trail, time travel, debugging capability, and analytics.
- **CQRS (Command Query Responsibility Segregation)**: Separates write model (commands) from read model (queries). Optimized models, independent scaling, and denormalized read models for fast queries.
- **Saga Pattern**: Manages distributed transactions across multiple services using compensating actions instead of distributed locks. Loosely coupled, eventually consistent, fault-tolerant.
- **Event Snapshotting**: Periodically saves aggregate state to avoid replaying thousands of events.
- **Event Versioning**: Event schemas evolve over time with backward compatibility.
- **Projection Rebuilding**: Fix projection bugs or add new read models by replaying all events.
- **Avoid When**: Simple CRUD applications, strong consistency absolutely required, team lacks event-driven experience.
- **Event Store as Source of Truth**: The event log is the single source of truth — the read model is a derived projection that can be rebuilt entirely from scratch by replaying events. This makes event sourcing naturally auditable and enables temporal queries ("what did the system look like at time T?").
- **CQRS Read Model Optimization**: Read models can be denormalized into exactly the shape each query needs — a dashboard widget gets a pre-joined table, a search endpoint gets an inverted index, and a mobile feed gets a flattened document. Writes and reads scale independently.
- **Process Managers & Sagas**: A saga coordinator (process manager) listens for events and issues commands across services. Orchestration-based sagas centralize coordination in a dedicated service; choreography-based sagas rely entirely on event subscriptions and are harder to reason about but more loosely coupled.

## Links

- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/event-driven-architecture|Event-Driven Architecture]]
- Connects to [[concepts/microservices-architecture|Microservices Architecture]]
