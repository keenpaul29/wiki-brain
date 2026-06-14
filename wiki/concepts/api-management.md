---
title: API Management and Gateway Patterns
type: concept
created: 2026-06-14
tags:
  - concept
  - api
  - gateway
  - rate-limiting
  - system-design
---

# API Management and Gateway Patterns

API management encompasses the patterns for routing, securing, transforming, and controlling traffic to backend services. Without an API gateway, every microservice would need to independently implement authentication, rate limiting, logging, and monitoring — leading to duplicated code, inconsistent security, and complex client logic.

## API Gateway Pattern

An API gateway is a single entry point for all client requests in a microservices architecture. Instead of clients calling multiple services directly, they call the gateway, which routes requests to the appropriate backend service.

### What the Gateway Handles

- **Request routing**: Map incoming paths to backend services.
- **Authentication and authorization**: Single point to validate tokens, API keys, or sessions.
- **Rate limiting**: Protect downstream services from abuse.
- **Request/response transformation**: Convert between API versions, protocols, or data formats.
- **Circuit breaking**: Fail fast when downstream services are unhealthy.
- **Request aggregation**: Combine responses from multiple services into a single response.
- **Protocol translation**: HTTP to gRPC, REST to GraphQL, etc.

### Gateway Architecture

```
[Client] → [CDN] → [Load Balancer] → [API Gateway] → [Service A]
                                              ├→ [Service B]
                                              └→ [Service C]

Gateway layers:
  1. CDN Layer: static content, geographic routing
  2. Load Balancer: SSL termination, DDoS protection
  3. API Gateway: routing, auth, rate limits, transformation
  4. Service Mesh: service-to-service communication
```

### Gateway Types

| Type | Purpose | Examples |
|------|---------|----------|
| **Edge Gateway** | Internet-facing, first point of contact. SSL/TLS, DDoS, geo-routing, CDN integration | Cloudflare, AWS CloudFront |
| **Internal Gateway** | Service-to-service communication within the cluster. Service discovery, load balancing, circuit breaking | Istio, Linkerd, Kong |
| **Backend for Frontend (BFF)** | Client-specific API aggregation. Mobile vs. web each get their own BFF. Reduces chattiness, handles client-specific transformations | GraphQL gateway, custom BFF services |

## Rate Limiting Algorithms

Rate limiting prevents a single client or a small set of clients from overwhelming the system. Each algorithm balances accuracy, memory, and burst behavior differently.

### Token Bucket

A bucket holds tokens. Each request consumes a token. Tokens refill at a fixed rate. Bursts are allowed up to the bucket capacity.

**Pros:** Allows burst traffic, smooth rate control, low memory.
**Cons:** More complex than fixed window.
**Use when:** You need to allow natural traffic bursts within limits.

### Sliding Window Log

Track timestamps of each request in a sorted log. Count requests within a sliding time window.

**Pros:** Most accurate, no edge-case bursts.
**Cons:** High memory usage (stores all timestamps).
**Use when:** Accuracy is critical and traffic volume is moderate.

### Sliding Window Counter

Approximate the sliding window by weighting the previous window's count. Redis sorted sets with expiration are a common implementation.

**Pros:** More accurate than fixed window, lower memory than sliding log.
**Cons:** Approximation, not exact.
**Use when:** Distributed rate limiting that needs to be efficient.

### Fixed Window

Count requests in discrete time windows (e.g., 1000 requests per minute, resetting at :00).

**Pros:** Simple, low memory.
**Cons:** Allows burst at window boundary (990 requests at :59, 990 at :00 = 1980 in 2 seconds).
**Use when:** Simplicity matters and burst tolerance is acceptable.

## API Versioning Strategies

| Strategy | Mechanism | Pros | Cons |
|----------|-----------|------|------|
| URL path | `/v1/users`, `/v2/users` | Simple, explicit in URLs | URL pollution, can't mix versions in one client |
| Header | `Accept: application/vnd.api+json;version=2` | Clean URLs, client controls version | Harder to test, discoverable |
| Query param | `/users?version=v1` | Simple to implement | Cache unfriendly |
| Content type | `application/vnd.company.user-v2+json` | RESTful, versioned media type | Requires client content negotiation |

**Best practice:** Use URL path versioning for public APIs (most discoverable). Use header-based versioning for internal APIs (cleanest separation).

## Backend for Frontend (BFF) Pattern

Each client type gets its own lightweight backend layer:

- **Mobile BFF**: Returns smaller payloads, reduces round trips over cellular networks, handles mobile-specific auth flows.
- **Web BFF**: Returns full HTML or data for rich browser UIs, handles session cookies, CSR/cookie auth.
- **IoT BFF**: Handles device-specific protocols (MQTT, CoAP), binary payload formats.

The BFF pattern prevents a single monolithic API from being simultaneously optimized for mobile, web, and third-party clients. It also isolates client-specific security concerns.

## Server-Side Request Aggregation

The gateway can aggregate data from multiple services in a single client call:

```
Client → GET /api/dashboard/{userId}
  Gateway parallel calls:
    → user-service: GET /users/{userId}
    → order-service: GET /orders?userId={userId}
    → recommendation-service: GET /recs/{userId}
  Gateway merges responses:
    { user: {...}, orders: [...], recommendations: [...] }
```

Implement with timeouts and partial responses. If one service is slow, return a degraded dashboard with the available data rather than failing the entire request.

## Protocol Translation in the Gateway

The gateway is a natural place for protocol translation. Common translations:

| Client Protocol | Backend Protocol | Use Case |
|---|---|---|
| HTTP/REST | gRPC | Web/mobile clients calling microservices with binary contracts |
| GraphQL | REST | Rich frontends needing client-shaped queries backed by legacy REST services |
| WebSocket | HTTP/SSE | Real-time clients bridged to event-driven backends |
| MQTT/CoAP | HTTP | IoT devices calling cloud services |

Protocol translation adds latency (serialization/deserialization) and increases gateway complexity. Measure the overhead before adopting — for latency-sensitive paths, consider bypassing the gateway for protocol-specific traffic.

## Distributed Rate Limiting

In a multi-instance gateway deployment, local rate limiting (per-node counters) is insufficient — a client can exceed the global limit by spreading requests across instances. Distributed rate limiting coordinates counters across gateway nodes:

### Redis-Based Sliding Window

The standard distributed rate limiter uses Redis sorted sets:

```
key = "ratelimit:{client_id}:{endpoint}"
score = current_timestamp
member = unique_request_id

# Remove expired entries
ZREMRANGEBYSCORE key 0 (now - window_seconds)

# Count entries in window
count = ZCARD key

# If under limit, add this request
if count < limit:
    ZADD key score member
    EXPIRE key window_seconds
    allow()
else:
    deny()
```

**Pros**: Exact sliding window, works across any number of gateway instances.
**Cons**: Redis latency per request (1-2ms), Redis memory grows with request volume per window.

### Optimizations:

- **Local cache + periodic sync**: maintain a local counter with an allowance buffer. Sync with Redis periodically (every 10-100ms). Redis is the source of truth; the local counter is a best-effort cache.
- **Leaky bucket at each node**: allocate each node a quota based on the number of nodes. Each node enforces its own quota locally. Works when node count is stable.
- **Client-side backpressure**: include `Retry-After` headers in rate-limit responses so well-behaved clients back off without retry loops.

### Rate Limiting as Backpressure

Rate limiting is not only for abuse prevention — it is also a system-to-system backpressure mechanism. When a downstream service is under load, it can respond with `429 Too Many Requests` and a `Retry-After` header, telling the upstream caller to slow down. This is the HTTP equivalent of TCP congestion control: the receiver controls the sender's rate.

## Common Pitfalls

**Gateway as bottleneck:** A single gateway instance becomes a bottleneck under high traffic. Scale horizontally — run multiple gateway instances behind a load balancer.

**Feature creep in gateway:** The gateway accumulates business logic and becomes a monolith. Keep the gateway thin — only cross-cutting concerns. Move business logic to dedicated services. Use BFF for client-specific logic.

**Poor error handling in gateway:** Gateway failures cascade to all clients. Use circuit breakers for downstream services. Implement graceful degradation — return partial responses with error indicators rather than 500 errors.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]]
- Related: [[concepts/microservices-architecture|Microservices Architecture]]
- Related: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/microservices-architecture|Microservices Architecture]]
- Related: [[concepts/security-patterns|Security Patterns]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Source: [[sources/latency-gambler-day-11|API Gateway & Proxy Patterns]]
- Source: [[sources/prod-web-application-components|Key Components of a Prod Web Application]]
- Source: [[sources/latency-gambler-day-15|Microservices Patterns]]
