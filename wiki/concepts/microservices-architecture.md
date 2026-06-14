---
title: Microservices Architecture
type: concept
created: 2026-06-14
tags:
  - concept
  - microservices
  - architecture
  - system-design
---

# Microservices Architecture

Microservices are independently deployable, failure-isolated services with their own data stores, communicating over the network. They are not small services — they are autonomously owned units organized around business capabilities. Without proper patterns, microservices become a distributed monolith with all the complexity of distribution and none of the benefits.

## Service Registry and Discovery

### The Problem

In a dynamic environment with auto-scaling, rolling deployments, and failures, service instances change constantly. Hard-coded endpoints break. Services need to find each other without manual configuration.

### How Service Discovery Works

1. **Registration**: Each service instance registers itself with the service registry on startup, providing host, port, health endpoint, and metadata.
2. **Heartbeat**: Registered instances send periodic heartbeats (every 10–30 seconds). The registry marks instances as unhealthy if heartbeats are missed.
3. **Discovery**: Consumers query the registry for healthy instances of a service. The registry returns a list of live endpoints.
4. **Cleanup**: The registry removes instances that fail to heartbeat within a timeout window.

### Service Registry Implementations

| Registry | Consensus | Use Case |
|----------|-----------|----------|
| **Eureka** | Peer-to-peer replication, AP | Netflix ecosystem, Java services |
| **Consul** | Raft, CP | Multi-datacenter, health checks, DNS interface |
| **etcd** | Raft, CP | Kubernetes native, gRPC interface |
| **ZooKeeper** | ZAB, CP | Coordination-heavy, Java ecosystem |

### Client-Side vs. Server-Side Discovery

| Approach | How It Works | Pros | Cons |
|----------|-------------|------|------|
| **Client-side** | Client queries registry, selects instance directly | Fewer network hops, no extra proxy | Client needs discovery logic per language |
| **Server-side** | Load balancer/router queries registry and forwards | Language-agnostic client | Extra hop, load balancer is a bottleneck |

## API Gateway in Microservices

The API gateway pattern is essential in microservices to centralize cross-cutting concerns. See [[concepts/api-management|API Management]] for the full gateway treatment. In a microservices context, the gateway additionally handles:

- **Service discovery integration**: The gateway queries the registry to route to healthy instances, rather than using hard-coded addresses.
- **Integration-style responses**: The gateway may aggregate multiple service responses into a single client-friendly payload.
- **Client-type differentiation**: Mobile, web, and third-party clients get different gateway configurations.

## Bulkhead Pattern

### Rationale

Without isolation, a single failing service (e.g., a slow recommendation engine) can exhaust the entire application's thread pool, blocking all features including healthy ones like login or checkout.

### Thread Pool Isolation

Each downstream service gets a dedicated thread pool with size limits tuned to its criticality:

| Service | Thread Pool | Queue | Criticality |
|---------|-------------|-------|-------------|
| User Service | 10 threads | 100 | Critical |
| Order Service | 15 threads | 200 | Critical |
| Payment Service | 10 threads | 100 | Critical |
| Recommendation Service | 5 threads | 50 | Non-critical |

If the recommendation service's pool fills up, only recommendations degrade. The other services continue unaffected.

### Semaphore Isolation

For lightweight isolation, semaphores limit concurrent calls without creating new threads. Use semaphores when:
- The operation is in-memory (no I/O wait).
- Thread context switching overhead would dominate.
- You need very fast rejection of excess calls.

## Health Checks and Graceful Shutdown

### Health Check Endpoints

Every microservice should expose at least two health check endpoints:

```
GET /health/liveness  → Is the service process alive? (quick check)
GET /health/readiness → Is the service ready to handle traffic? (includes dependency checks)
```

The liveness check should be cheap (process is running). The readiness check should verify database connections, cache connections, and critical dependencies.

### Graceful Shutdown Sequence

When a service instance is about to be terminated (scaled down, deployment, failure):

1. **Deregister from service registry**: Stop receiving new traffic.
2. **Signal load balancer**: Return `503` from health checks so the load balancer drains connections.
3. **Wait for in-flight requests**: Allow existing requests to complete, up to a timeout.
4. **Close resources**: Close database connections, message queue consumers, thread pools.
5. **Exit**.

The total shutdown time should be configurable and monitored. Instances that take too long to drain may need to be force-terminated.

## Netflix OSS Stack

Netflix open-sourced the patterns that power their global microservices architecture. While the specific libraries (Eureka, Zuul, Hystrix, Ribbon) have been superseded by newer tools, the patterns remain the industry standard reference.

| Component | Pattern | Modern Alternative |
|-----------|---------|-------------------|
| Eureka | Service Discovery | Consul, etcd, Kubernetes DNS |
| Zuul | API Gateway | Spring Cloud Gateway, Kong, Envoy |
| Hystrix | Circuit Breaker + Bulkhead | Resilience4j, Istio |
| Ribbon | Client-Side Load Balancing | Spring Cloud LoadBalancer, Envoy |
| Archaius | Configuration Management | Spring Cloud Config, Kubernetes ConfigMap |

### Standard Architecture

```
[Client] → [Zuul Gateway] → [Eureka Discovery] → [Hystrix Protection] → [Microservice]
              ↓                    ↓                      ↓
        [Auth/Rate Limit]    [Service Registry]    [Circuit Breaker]
              ↓                    ↓                      ↓
        [Request Filter]      [Health Checks]       [Bulkhead Isolation]
```

## Orchestration vs. Choreography

Service coordination can follow two fundamentally different patterns:

### Orchestration

A central coordinator (orchestrator) tells each service what to do and in what order:

```
[Orchestrator] → step 1: Order Service (create order)
               → step 2: Payment Service (process payment)
               → step 3: Inventory Service (reserve items)
               → step 4: Notification Service (send confirmation)
```

**When to use**: workflows with strict ordering, multi-step transactions (sagas), or when rollout control is needed. The orchestrator is a single point of control and failure.

**Common implementation**: a dedicated saga orchestrator service, Step Functions / Temporal / Camunda.

**Tradeoffs**: central logic creates a single responsibility boundary (good) and a potential bottleneck (bad). The orchestrator must be stateless and idempotent to avoid becoming a SPOF.

### Choreography

Services react to events published by other services, with no central coordinator:

```
[Order Service] → emits "order.created" event
[Payment Service] ← subscribes to "order.created"
                → emits "payment.completed"
[Inventory Service] ← subscribes to "payment.completed"
```

**When to use**: loosely coupled systems where services can process independently, or event-driven architectures with bounded contexts.

**Common implementation**: message broker (Kafka, RabbitMQ, SQS/SNS) with event schemas (Avro, Protobuf, CloudEvents).

**Tradeoffs**: high decoupling (good), but distributed tracing requires correlation IDs across the event chain. Harder to reason about the overall flow. Event schema evolution must be backward-compatible.

### Decision Table

| Factor | Orchestration | Choreography |
|--------|--------------|--------------|
| Workflow complexity | Complex, multi-step | Simple, linear |
| Coupling | Tighter (knows coordinator) | Loose (knows events only) |
| Traceability | Central log of steps | Requires distributed tracing |
| Rollback | Orchestrator can compensate | Each service handles rollback independently |
| Latency | Sequential steps, higher | Parallel event processing possible |
| Failure isolation | Coordinator is a SPOF | Failures isolated per service |

## Event-Driven Microservices

Event-driven communication is often preferable to synchronous HTTP calls for microservices that need loose coupling:

### Event Schema and Contracts

Events must have a well-defined schema that evolves without breaking consumers:

```json
{
  "specversion": "1.0",
  "type": "order.created",
  "source": "/orders/v2",
  "id": "d94f3a17-3a8f-4f9b-8f0a-2e1c5d6b7a8c",
  "time": "2026-06-14T14:30:00Z",
  "datacontenttype": "application/json",
  "data": {
    "order_id": "ORD-12345",
    "customer_id": "CUST-678",
    "items": [{"sku": "ABC", "qty": 2}],
    "total": 49.99
  }
}
```

Use CloudEvents standard for interoperability. Use schema registry (Apicurio, Confluent Schema Registry) to enforce compatibility.

### At-Least-Once Delivery

Message brokers guarantee at-least-once delivery by default. Services must handle duplicate events:

- **Idempotency key**: include `id` in the event. Each consumer tracks processed event IDs and skips duplicates.
- **Retry with backoff**: if processing fails, retry (n times) then send to a dead-letter queue.
- **Exactly-once processing**: use the consumer's offset management (Kafka consumer offsets committed only after successful processing).

### Event Sourcing

Instead of storing current state, store the sequence of events. Current state is derived by replaying all events:

- **Pros**: complete audit trail, time-travel debugging, natural event-driven integration.
- **Cons**: event store becomes a bottleneck, replaying events for state reconstruction is slow at scale, schema migration is challenging.
- **When to use**: audit-heavy domains (finance, compliance), systems that need point-in-time queries.

### Saga Pattern

For distributed transactions across services, the Saga pattern compensates for failures:

```
Saga: Create Order
  1. Order Service: create order (PENDING)
  2. Payment Service: reserve payment
  3. Inventory Service: reserve inventory
  4. Order Service: mark order as CONFIRMED

On failure at step 3:
  → Compensating transaction: Payment Service releases reservation
  → Compensating transaction: Order Service marks order as FAILED
```

Sagas come in two forms:
- **Choreographed**: each service emits events and handles rollback. Simple but hard to trace.
- **Orchestrated**: a saga coordinator manages the flow and compensation. More complex but traceable.

## Service Mesh Deployment Pattern

Service mesh (Istio, Linkerd, Consul Connect) moves infrastructure concerns from the application to a sidecar proxy:

### Sidecar Pattern

Each service instance has a sidecar container (Envoy, Linkerd-proxy) that intercepts all network traffic:

```
[Mesh: Istio / Linkerd]
  ┌──────────────────────────┐
  │ [Service Container]      │
  │    ↓ ↑                   │
  │ [Sidecar Proxy (Envoy)]  │ ← all traffic goes through here
  └──────────────────────────┘
              ↓
        [Control Plane]
     (Pilot, Mixer, Citadel)
```

### What the Service Mesh Handles

| Concern | Without Mesh | With Mesh |
|---------|-------------|-----------|
| mTLS | Application code or library | Automatic sidecar-to-sidecar encryption |
| Traffic routing | Load balancer config | Weighted routing, canary, header-based |
| Circuit breaking | Library (Hystrix, Resilience4j) | Proxy-level, no code change |
| Retry / timeout | Library configuration | Proxy-level policy |
| Observability | Manual metrics, tracing | Automatic mTLS, telemetry per request |

### When to Use a Mesh

- **Polyglot services**: different languages need consistent resilience — the mesh provides it without per-language libraries.
- **Zero trust security**: mesh provides automatic mTLS between all services.
- **Traffic management**: blue-green, canary, A/B testing without application changes.

**Cost**: sidecar proxies add latency (5-15ms per hop) and resource overhead (100-250MB RAM per sidecar). The control plane is a critical dependency.

## Migration Strategies

Extracting microservices from a monolith requires a gradual, safe approach:

### Strangler Fig Pattern

Gradually replace monolith functionality with microservices, routing traffic selectively:

```
Phase 1: [Monolith] handles all traffic
Phase 2: [Monolith] + [New Service A] → router sends /api/v2/orders to A
Phase 3: [New Service A] + [New Service B] → A and B handle their domains
Phase 4: [New Service A] [B] [C] [D] → monolith is decommissioned
```

**Rules:**
- New functionality goes directly in the new service, not the monolith.
- Migrate one bounded context at a time. Extract the least coupled domain first.
- Keep the old and new paths running in parallel until you are confident in the new service.
- Feature flags route specific users to the new service for controlled rollouts.

### Parallel Run

For high-risk migrations (payment, billing), run both old and new implementations side by side:

1. Route traffic to both the monolith and the new service simultaneously.
2. Compare responses. Log discrepancies. Do not use the new service's response yet.
3. When discrepancies fall to zero (or acceptable), switch to the new service.
4. Keep the monolith running for 30 days as a rollback target.

### Database Per Service

Database decomposition is the hardest part of the migration:

1. Start with a shared database (monolith).
2. Extract database access into repository modules. The service knows only its own domain objects.
3. Use database views or triggers to expose only the data a service needs.
4. Extract physical databases one at a time. Each service gets its own schema, then its own DB instance.
5. Use events or an API gateway for cross-service data access.

## When NOT to Use Microservices

Microservices add significant operational complexity: distributed transactions, network failures, latency, debugging difficulty, and deployment coordination. They are worth the cost when:

- **Team size**: Multiple teams need to work independently on different parts of the system.
- **Independent scaling**: Different parts of the system have different scaling requirements.
- **Technology diversity**: Different services benefit from different technology stacks.
- **Failure isolation**: Failure in one part should not bring down the whole system.

Microservices are not appropriate for:
- Small teams (< 10 people) building a new product.
- Simple CRUD applications with low traffic.
- Systems where network overhead dominates the performance budget.
- Teams without strong DevOps and observability infrastructure.

Start with a modular monolith. Extract services when a clear boundary, scaling need, or team ownership requirement justifies the cost.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/api-management|API Management]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]]
- Related: [[concepts/distributed-coordination|Distributed Coordination and Consensus]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/event-driven-architecture|Event-Driven Architecture]]
- Related: [[concepts/team-topologies|Team Topologies]]
- Source: [[sources/latency-gambler-day-15|Microservices Patterns]]
- Source: [[sources/latency-gambler-day-11|API Gateway & Proxy Patterns]]
- Source: [[sources/latency-gambler-day-12|Message Queue Patterns]]
- Source: [[sources/latency-gambler-day-17|Resilience Patterns]]
- Source: [[sources/latency-gambler-day-19|Database Scaling Patterns]]
- Source: [[sources/prod-web-application-components|Key Components of a Prod Web Application]]
