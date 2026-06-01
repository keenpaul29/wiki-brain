---
title: "Chain of Responsibility & State Patterns"
type: source
created: 2026-05-27
source: https://freedium-mirror.cfd/medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18
tags:
  - source
---

# Chain of Responsibility & State Patterns

## Summary

This article is Day 7 of The Latency Gambler's system design series. It focuses on two behavioral patterns: the **Chain of Responsibility** pattern for building flexible request-processing pipelines (like middleware) and the **State Pattern** for managing state machines explicitly without complex nested conditionals.

## Key Ideas

- **Chain of Responsibility Pattern**: Creates a processing pipeline of decoupled handlers. Each handler performs its operation (e.g. Authentication, Authorization, Validation, Rate Limiting, Caching) and either passes the request to the next handler or terminates/completes it.
- **Branching & Conditional Chains**: Handlers can conditionally run based on request metadata or terminate execution early (e.g. Caching handler returning cached response directly).
- **Spring/Dependency-injection Integration**: Handlers can be managed as beans and sorted dynamically (e.g., using `@Order`) to build the chain dynamically at application start.
- **State Pattern**: Eliminates complex conditional checks (`if-else`/`switch`) by encapsulating state-dependent behavior inside explicit state classes (e.g. Order states: `PendingState`, `PaidState`, `ShippedState`, `DeliveredState`).
- **Chain of Responsibility Anti-patterns**:
  - **Broken Chain**: A handler forgets to call the next handler, breaking the pipeline.
  - **Handler Order Dependency**: A handler makes assumptions about metadata set by a specific previous handler, creating brittle ordering.
- **State Pattern Anti-patterns**:
  - **State Explosion**: Creating too many overly specific states.
  - **Leaky State Logic**: Placing complex business logic (e.g. tax calculations, inventory updates) inside state classes instead of delegating to domain services.
- **Production Lessons**: Keep states simple, use events to handle state-transition side effects, design for state persistence/restoration, and keep pipeline handlers completely independent.

## Links

- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/software-design-patterns|Software Design Patterns]]
- Connects to [[sources/latency-gambler-day-6|Adapter and Facade Patterns for System Design]]
- Connects to [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]]
