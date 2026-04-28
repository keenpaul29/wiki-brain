---
title: Communication and Architecture Patterns
type: concept
created: 2026-04-28
tags:
  - concept
  - architecture
  - system-design
---

# Communication and Architecture Patterns

Communication and architecture patterns shape how system components interact. The system design source treats these as central design choices rather than implementation details.

## Architecture Styles

- Monolith: simpler deployment and local reasoning, but can become hard to scale or change.
- Modular monolith: keeps one deployable while enforcing internal boundaries.
- Microservices: independent services and data ownership, with added distributed-systems complexity.
- Event-driven architecture: components communicate through events and asynchronous reactions.
- N-tier architecture: separates presentation, application, and data responsibilities.

## Messaging Patterns

- Message brokers decouple producers from consumers.
- Queues support asynchronous work, backpressure, retries, ordering choices, dead-letter queues, and task processing.
- Publish-subscribe fans events out to multiple subscribers.
- Event streaming records append-only event logs for real-time and replayable processing.
- Event sourcing stores state changes as events.
- CQRS separates command/write models from query/read models.

## API and Realtime Patterns

- REST is resource-oriented and widely interoperable.
- GraphQL lets clients request shaped data but can add server complexity.
- gRPC uses strongly typed contracts and efficient binary transport.
- Long polling simulates realtime updates over repeated requests.
- WebSockets provide bidirectional persistent communication.
- Server-Sent Events provide server-to-client streaming over HTTP.

## Design Warning

Microservices are not a default upgrade. The source explicitly warns about distributed monoliths and notes that many systems do not need microservices until team, scale, or domain boundaries justify the operational cost.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Source: [[sources/system-design-course|System Design Course]]

