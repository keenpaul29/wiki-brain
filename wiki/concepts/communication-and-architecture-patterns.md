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

- REST is resource-oriented and widely interoperable. Best for public/external APIs (Stripe, GitHub, Twitter). HTTP caching works naturally. Over-fetches ~30% in complex UIs.
- GraphQL lets clients request shaped data but can add server complexity. Best when multiple client types need different data shapes. Adds resolver layer, schema, query complexity analysis, and N+1 hazard.
- gRPC uses strongly typed contracts (Protocol Buffers) and efficient binary transport over HTTP/2. Best for internal service-to-service communication at high frequency. Payloads ~4x smaller than REST JSON. Native streaming, code generation. Does not work natively in browsers (needs gRPC-Web or ConnectRPC).
- Long polling simulates realtime updates over repeated requests.
- WebSockets provide bidirectional persistent communication after an HTTP `Upgrade: websocket` handshake and `101 Switching Protocols` response.
- Server-Sent Events provide server-to-client streaming over HTTP.

WebSockets remove repeated polling overhead for high-frequency updates, but they replace stateless request handling with persistent connection management. Designs must account for heartbeats, disconnect detection, load balancing, sticky routing or shared connection state, and the fact that WebSocket messages are not cacheable like static HTTP responses.

### API Protocol Decision Framework

Default to REST; add GraphQL when the frontend team is bottlenecked by endpoint changes; add gRPC when internal service latency profiling shows a bottleneck. Benchmarks (Node.js 22, user + 5 orders): gRPC P50 4ms / 312 bytes, GraphQL 15ms / 834 bytes, REST 12ms / 1247 bytes. For browser-to-server calls the performance gap is negligible — network latency dominates. The best architectures use all three at the layer where they belong.

## Design Warning

Microservices are not a default upgrade. The source explicitly warns about distributed monoliths and notes that many systems do not need microservices until team, scale, or domain boundaries justify the operational cost.

The microservices-vs-monoliths source reinforces the same rule from a team-and-operations angle: start simple when the system and organization are still small, then extract services only when independent scaling, deployment, ownership, or technology choices justify the added failure modes.

Object-oriented design patterns follow the same caution. Adapter, Facade, Strategy, Chain of Responsibility, and related patterns are useful when they respond to a named friction such as boundary mismatch, unsafe subsystem access, or changing behavior. Used without that pain, they add indirection without improving the architecture.

CQRS and CDC are similarly conditional tools. They are valuable when read/write model shapes conflict, when multiple systems need reliable reactions to database changes, or when application-level dual writes have become a consistency hazard. They add projection lag, schema-evolution work, idempotency requirements, and event-stream operations, so simple CRUD flows should stay simple.

## Service Discovery Patterns

In dynamic microservice environments where instances auto-scale, deploy, and fail, services need to find each other without hard-coded endpoints:

1. **Registration**: Service instances register with a registry on startup, providing host, port, health endpoint, and metadata tags.
2. **Heartbeat**: Registered instances send periodic heartbeats (10–30s interval). The registry marks instances unhealthy when heartbeats are missed.
3. **Discovery**: Consumers query the registry for healthy instances. The registry returns live endpoints.
4. **Cleanup**: The registry removes instances that fail to heartbeat within a timeout window.

**Client-side discovery** (the client queries the registry directly) adds per-language client logic but removes a network hop. **Server-side discovery** (a load balancer or mesh proxy does the lookup) is language-agnostic but adds latency and a potential bottleneck. In practice, server-side via a service mesh (Istio, Linkerd) is more maintainable at scale.

## Gateway as Cross-Cutting Concern Layer

An [[concepts/api-management|API Gateway]] centralizes concerns that every service would otherwise duplicate: authentication, rate limiting, logging, request shaping, and protocol translation. In a microservice architecture, the gateway also integrates with service discovery to route to healthy instances without hard-coded addresses.

The gateway should remain thin — only cross-cutting concerns and routing. Business logic, data aggregation, and client-specific transformations belong in dedicated services or [[concepts/api-management|BFF layers]].

## Async Messaging: Queue vs. Topic vs. Command

Beyond the basic pub/sub model, production messaging systems distinguish three patterns:

| Pattern | Delivery | Use Case |
|---------|----------|----------|
| **Message Queue** | Each message consumed by exactly one worker. FIFO ordering if configured. | Work distribution (image processing, report gen), load balancing across workers |
| **Topic (Pub/Sub)** | Each message delivered to all subscribers. | Event broadcasting, real-time updates, audit logging |
| **Command Pattern** | Operations serialized as message objects with retry, audit, and scheduling metadata. | Task queues, workflow engines, sagas |

**Dead Letter Queue (DLQ):** Messages that exhaust their retry attempts move to a DLQ for manual investigation. Never lose a DLQ message — log, alert, and store for reprocessing.

**Message deduplication:** Use idempotency keys stored in Redis with TTL (24h window). Check `SET key NX` before processing — if the key exists, the message is a duplicate.

## Event-Driven Error Handling

Event-driven systems need explicit error handling for poisoned events:

- **Retry with backoff**: Use `@RetryableTopic` on event listeners with exponential backoff.
- **Dead letter topic**: Events that fail after N retries land in a DLQ topic for manual inspection.
- **Monitoring**: Track event processing lag, retry counts, and DLQ depth. Rising DLQ is an early warning sign of systemic issues.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/software-design-patterns|Software Design Patterns]]
- Sub-concept: [[concepts/api-protocol-selection|API Protocol Selection]]
- Sub-concept: [[concepts/event-driven-architecture|Event-Driven Architecture]]
- Source: [[sources/system-design-course|System Design Course]]
- Source: [[sources/microservices-vs-monoliths|Microservices vs. Monoliths]]
- Source: [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]]
- Source: [[sources/cqrs-read-write-separation|The Read That Was Killing the Write]]
- Source: [[sources/change-data-capture-event-log|Your Database Has Been Writing an Event Log the Whole Time]]
- Source: [[sources/dropbox-edison-web-performance|Dropbox Edison: Local-First Web Client]]
- Source: [[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]]
- Source: [[sources/linkedin-fishdb-retrieval-engine|FishDB: LinkedIn Feed Retrieval Engine]]
- Source: [[sources/intro-to-websockets|Intro to WebSockets]]
- Source: [[sources/rest-vs-graphql-vs-grpc|REST vs GraphQL vs gRPC]]
- Source: [[sources/latency-gambler-day-11|API Gateway & Proxy Patterns]]
- Source: [[sources/latency-gambler-day-12|Message Queue Patterns]]
- Source: [[sources/latency-gambler-day-13|Event Sourcing & CQRS Patterns]]
- Source: [[sources/latency-gambler-day-15|Microservices Patterns]]
- Source: [[sources/latency-gambler-day-19|Database Scaling Patterns]]
- Source: [[sources/latency-gambler-day-20|Security Patterns]]
- Source: [[sources/prod-web-application-components|Key Components of a Prod Web Application]]
