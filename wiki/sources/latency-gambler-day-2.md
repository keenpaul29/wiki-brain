---
title: "Strategy and Observer Patterns for System Design"
type: source
created: 2026-05-26
source: https://freedium-mirror.cfd/medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf
tags:
  - source
---

# Strategy and Observer Patterns for System Design

## Summary

Explores how Strategy and Observer design patterns serve as critical system architecture blocks, enabling runtime runtime behavior switching without downtime and decoupling event-driven architectures.

## Key Ideas

- Strategy Pattern: Isolates algorithms or behaviors behind a common interface, allowing runtime selection without downtime or deployments (e.g. adding new payment methods).
- Configuration-Driven Strategy: Reading active strategy names from configurations (e.g. application.yml) to switch fraud detection or recommendation behaviors on the fly.
- Composite Strategy Pipeline: Chaining multiple strategies sequentially (e.g. IP check -> velocity check -> ML model) to process transactions.
- Observer Pattern: A key primitive for event-driven architectures, decoupling core logic (like user registration) from downstream side-effects (welcome emails, CRM syncs).
- Push vs. Pull Observer Models: Push sends all data to observers (fast but bandwidth heavy), whereas Pull sends minimal IDs and forces observers to fetch what they need (efficient but increases network calls).
- Async Observers: Moving observer execution out of the main thread pool via ExecutorServices to avoid blocking user requests, while managing error isolation.
- Distributed Event Sourcing Observers: Persisting events to an event store and publishing them to message brokers (e.g., Kafka) for consumption by distributed microservice observers.
- Anti-Patterns & Risks: Strategy Hell (over-engineering trivial logic), Observer Hell (untraceable event storms), and memory leaks from strong references in observer lists (solved via WeakReferences).

## Links

- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/software-design-patterns|Software Design Patterns]]
- Connects to [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]]
