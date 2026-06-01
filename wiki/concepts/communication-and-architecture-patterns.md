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
- CDC turns database transaction logs into event streams, allowing downstream systems to react to every committed write without relying on application code to publish a second message.

## Local-First Communication Patterns

Local-first architectures introduce new communication patterns for web clients:

- **Two-layer sync architecture**: a local sync engine (handles reads/writes against a local representation) + a sync service (persistent WebSocket connection for change propagation).
- **BroadcastChannel API**: enables cross-tab state synchronization without server involvement — when one tab mutates data, other tabs receive the update via browser-native broadcast.
- **Optimistic UI with async sync**: user actions apply to local state immediately; the sync layer propagates changes to the server asynchronously and handles conflict resolution.
- **Unified storage layer**: all components (file lists, search, previews) communicate through a shared local representation instead of independent data-fetch protocols.

## Embedding-Based Retrieval Pipeline

Search infrastructure at LinkedIn's scale uses a multi-stage pipeline with distinct communication patterns between stages:

- **Query understanding → EBR**: query text is encoded into a dense embedding, then compared against document embeddings via GPU-accelerated exhaustive vector search.
- **EBR → Cross-Encoder SLM**: candidate documents from EBR are passed to a Cross-Encoder Small Language Model for fine-grained relevance scoring.
- **SLM → Auction layer**: scored candidates enter an auction layer that applies budget and pacing strategies for the final ranking.
- **Hybrid feature pipeline**: offline (Spark, Flyte) generates embeddings at scale; nearline (Flink) provides low-latency feature updates to the ranking models.

## API and Realtime Patterns

- REST is resource-oriented and widely interoperable.
- GraphQL lets clients request shaped data but can add server complexity.
- gRPC uses strongly typed contracts and efficient binary transport.
- Long polling simulates realtime updates over repeated requests.
- WebSockets provide bidirectional persistent communication.
- Server-Sent Events provide server-to-client streaming over HTTP.

## Design Warning

Microservices are not a default upgrade. The source explicitly warns about distributed monoliths and notes that many systems do not need microservices until team, scale, or domain boundaries justify the operational cost.

The microservices-vs-monoliths source reinforces the same rule from a team-and-operations angle: start simple when the system and organization are still small, then extract services only when independent scaling, deployment, ownership, or technology choices justify the added failure modes.

Object-oriented design patterns follow the same caution. Adapter, Facade, Strategy, Chain of Responsibility, and related patterns are useful when they respond to a named friction such as boundary mismatch, unsafe subsystem access, or changing behavior. Used without that pain, they add indirection without improving the architecture.

CQRS and CDC are similarly conditional tools. They are valuable when read/write model shapes conflict, when multiple systems need reliable reactions to database changes, or when application-level dual writes have become a consistency hazard. They add projection lag, schema-evolution work, idempotency requirements, and event-stream operations, so simple CRUD flows should stay simple.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/software-design-patterns|Software Design Patterns]]
- Source: [[sources/system-design-course|System Design Course]]
- Source: [[sources/microservices-vs-monoliths|Microservices vs. Monoliths]]
- Source: [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]]
- Source: [[sources/cqrs-read-write-separation|The Read That Was Killing the Write]]
- Source: [[sources/change-data-capture-event-log|Your Database Has Been Writing an Event Log the Whole Time]]
- Source: [[sources/dropbox-edison-web-performance|Dropbox Edison: Local-First Web Client]]
- Source: [[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]]
- Source: [[sources/linkedin-fishdb-retrieval-engine|FishDB: LinkedIn Feed Retrieval Engine]]
