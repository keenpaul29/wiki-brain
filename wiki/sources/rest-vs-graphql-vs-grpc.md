---
title: "REST vs GraphQL vs gRPC: Which Should You Actually Use"
type: source
created: 2026-06-06
source: https://grindengineer.com/p/rest-vs-graphql-vs-grpc
author: "Aditya Singh Sisodiya"
tags:
  - source
  - api
  - system-design
  - architecture
---

# REST vs GraphQL vs gRPC: Which Should You Actually Use

## Summary

Compares REST, GraphQL, and gRPC with benchmarks (payload size, serialization time, P50/P99 latency, over-fetching) and a practical decision framework. Argues the best architectures use all three at the layer where they belong: REST for public/external APIs, GraphQL for complex frontends, gRPC for internal service-to-service communication.

## Key Ideas

- REST is resource-oriented, most widely understood, and the default for public APIs (Stripe, GitHub, Twitter). HTTP caching works naturally. Over-fetches by ~30% in complex UIs.
- GraphQL lets the client declare exact field requirements, eliminating over- and under-fetching. Adds resolver layer, schema, query complexity analysis, and N+1 hazard. Best when multiple client types need different data shapes.
- gRPC uses Protocol Buffers over HTTP/2 with code generation, native streaming, and strong type contracts. Payloads are ~4x smaller than REST JSON. Does not work natively in browsers (needs gRPC-Web or ConnectRPC).
- Benchmarks (Node.js 22, user + 5 orders): gRPC P50 4ms / 312 bytes, GraphQL 15ms / 834 bytes, REST 12ms / 1247 bytes. For browser-to-server calls the performance gap is negligible — gRPC only pulls ahead in service-to-service high-frequency calls.
- Decision framework: default to REST; add GraphQL when frontend team is bottlenecked on endpoint changes; add gRPC when internal service latency profiling shows a bottleneck.

## Links

- Supports [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Supports [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Supports [[concepts/system-design|System Design]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
