---
title: API Protocol Selection
type: concept
created: 2026-06-14
tags:
  - concept
  - api
  - protocol
  - rest
  - graphql
  - grpc
  - websocket
  - system-design
---

# API Protocol Selection

No single protocol fits every use case. The best architectures use multiple protocols at the layer where they belong: REST for public APIs, GraphQL for complex frontends, gRPC for internal communication, and WebSockets for realtime bidirectional streaming.

## Protocol Comparison

| Protocol | Transport | Serialization | Caching | Streaming | Browser Native |
|----------|-----------|---------------|---------|-----------|----------------|
| REST | HTTP/1.1+ | JSON | Native HTTP | No | Yes |
| GraphQL | HTTP/1.1+ | JSON (query) | None by default | Subscriptions | Yes |
| gRPC | HTTP/2 | Protocol Buffers | No | Bidirectional | No (needs gRPC-Web) |
| WebSocket | TCP (upgraded) | Custom framing | No | Bidirectional | Yes |

## Performance Benchmarks

Node.js 22 benchmark (user + 5 orders payload):

| Metric | REST | GraphQL | gRPC |
|--------|------|---------|------|
| P50 latency | 12ms | 15ms | 4ms |
| Payload size | 1,247 bytes | 834 bytes | 312 bytes |
| Over-fetching | ~30% | None | None |
| Code generation | None | GraphQL Codegen | protoc |

For browser-to-server calls the gap is negligible. gRPC pulls ahead only in service-to-service high-frequency calls.

## Decision Framework

### Default to REST

REST is the default for public APIs because:
- Most widely understood by client developers.
- HTTP caching works natively (ETags, Cache-Control).
- Tooling ecosystem (curl, Postman, every HTTP client).
- Mature security (rate limiting per endpoint, API key scoping).

Use REST at the **public/external API layer**.

### Add GraphQL When...

- Multiple client types (mobile, web, third-party) need different data shapes.
- The frontend team is bottlenecked on backend endpoint changes.
- Over-fetching is measurable and costly (mobile bandwidth).
- The product has rapidly changing UIs.

Risks: N+1 queries (resolve each field independently), query complexity analysis required, caching is harder.

### Add gRPC When...

- Service-to-service calls dominate the request volume.
- Profiling shows serialization or latency is a bottleneck.
- Strong typing across service boundaries is valuable (contract-first).
- Native streaming is needed (server streaming, bidirectional).

Risks: does not work natively in browsers, requires HTTP/2, tooling is less mature for non-service callers.

### Add WebSockets When...

- Real-time bidirectional communication is needed (chat, live updates, collaborative editing).
- Polling or long-polling overhead is measurable.
- The operational cost of persistent connections is acceptable.

Risks: stateful connections complicate load balancing, no built-in reconnection, memory pressure per connection, weak caching.

## Layered Architecture

```
[Public Clients] → REST / GraphQL (HTTP/1.1)
                         ↓
              [API Gateway / BFF]
                         ↓
              [Internal Services] → gRPC (HTTP/2)
                         ↓
              [Realtime Feeds] → WebSocket
```

Each layer uses the protocol best suited to its consumers and performance requirements. The gateway translates between them as needed.

## Links

- Parent concept: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/api-management|API Management and Gateway Patterns]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Source: [[sources/rest-vs-graphql-vs-grpc|REST vs GraphQL vs gRPC]]
- Source: [[sources/intro-to-websockets|Intro to WebSockets]]
- Source: [[sources/latency-gambler-day-11|API Gateway & Proxy Patterns]]
