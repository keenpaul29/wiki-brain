---
title: Resilience and Fault Tolerance Patterns
type: concept
created: 2026-06-14
tags:
  - concept
  - resilience
  - fault-tolerance
  - system-design
---

# Resilience and Fault Tolerance Patterns

In distributed systems, failures are inevitable — networks blip, databases time out, services crash, and memory fills. Resilience patterns expect failure and handle it gracefully. The goal is never to eliminate failures (impossible) but to ensure that failures are contained, isolated, and recovered from without visible impact to users.

Approximately 70% of production failures are transient — they resolve on their own if given time. The remaining 30% require active fallback, degradation, or circuit-breaking. The patterns below address both categories.

## Retry Pattern

### When to Retry

Retry is the first and simplest resilience pattern. It handles transient failures: network timeouts, connection resets, database deadlocks, and temporary service unavailability. Critical rule: **only retry idempotent operations**. If the operation has side effects (e.g., charging a credit card), retrying could cause duplicate charges.

### Exponential Backoff

Naive retry (retrying immediately or at fixed intervals) can overwhelm an already-stressed system. Exponential backoff spaces retries further apart:

```
attempt 1 → wait 1s
attempt 2 → wait 2s
attempt 3 → wait 4s
attempt 4 → wait 8s
```

### Jitter

Without jitter, all clients retry on the same schedule, creating a **thundering herd** that can collapse the recovering service. Add random jitter to spread retries:

```
delay = exponential_backoff(attempt) + random(0, delay)
```

Full jitter (random between 0 and max delay) is often more effective than additive jitter for preventing herd behavior.

### Retry Eligibility

Not all failures should be retried:

| Retryable | Non-Retryable |
|-----------|---------------|
| Socket timeout | Invalid input |
| Connection refused | Authentication failure |
| Transient DB error (deadlock victim) | Insufficient funds |
| HTTP 503, 429, 502, 504 | HTTP 400, 401, 403, 404 |

### Max Retries and Circuit Breaking

Retry has a cost — each attempt consumes resources. Set a maximum retry count (typically 3). Beyond that, the operation should fail immediately or trigger a circuit breaker. Retry without a ceiling can mask systemic failures and delay incident detection.

## Timeout Pattern

### Why Timeouts Are Critical

Without timeouts, an operation can hang indefinitely, holding threads, connections, and memory. A single slow external service can exhaust the entire application's thread pool, causing a cascade failure across unrelated features.

### Three Layers of Timeout

1. **Connection timeout**: How long to wait to establish a connection. Set low (1–2 seconds). If the server is unreachable, fail fast.
2. **Read/request timeout**: How long to wait for a response after the connection is established. Set based on the service's P99 latency + buffer (3–10 seconds).
3. **Overall timeout**: The maximum time for the entire operation, including retries. This is the safety net that prevents unbounded execution.

### Layered Timeout in Practice

```
External service call → Connection timeout (2s) → Read timeout (5s)
  → Circuit breaker timeout → Overall timeout (10s)
  → Fallback if exceeded
```

Each layer has a shorter timeout than the one wrapping it. The innermost timeout triggers first; the outermost is the last resort.

### Timeout vs. Cancellation

A timeout should not just return an error — it should cancel the underlying operation. Cancel the `Future`, abort the HTTP request, close the database statement. Otherwise, the operation continues consuming resources even though the caller has moved on.

## Circuit Breaker Pattern

### Three States

| State | Behavior |
|-------|----------|
| **CLOSED** | Normal operation. Requests pass through. Failures are counted. |
| **OPEN** | Failures exceeded threshold. Requests fail immediately without calling the downstream service. A timer starts. |
| **HALF_OPEN** | After the timer expires, a probe request is allowed through. If it succeeds, transition to CLOSED. If it fails, back to OPEN and reset the timer. |

### Configuration Parameters

- **Failure threshold**: Number of failures before opening (e.g., 5 failures in 10 seconds).
- **Success threshold**: Number of successes in HALF_OPEN to close (e.g., 3 consecutive successes).
- **Open duration**: How long the circuit stays open before transitioning to HALF_OPEN (e.g., 30 seconds).
- **Metrics window**: The sliding time window for counting failures.

### Circuit Breaker for Cache

Apply circuit breakers to cache operations too. If the cache (Redis, Memcached) is slow or failing, the circuit breaker falls through to the database directly. This prevents cache failures from cascading into application failures.

## Fallback Pattern

A fallback provides an alternative response when the primary operation fails. Fallbacks are chained in priority order:

### Fallback Strategy Hierarchy

1. **Cached data**: Return the last known good value from cache. Acceptable for read-heavy, eventually-consistent use cases.
2. **Degraded service**: Call a simpler, cheaper, or more reliable alternative. For example, fall back from personalized ML recommendations to popular products.
3. **Default value**: Return a sensible default (empty list, anonymous user, cached template).
4. **Error response**: Only as the last resort — return a clear, user-friendly error rather than an exception page.

### Fallback Chain Execution

```
Primary operation → fails
  → Fallback 1: Cached data → succeeds (return)
  → Fallback 2: Degraded service → fails
  → Fallback 3: Default value → succeeds (return)
```

Each fallback should be independently failure-isolated. The failure of a fallback should not prevent trying the next fallback.

## Graceful Degradation

Graceful degradation is the system-level pattern of maintaining partial functionality instead of complete failure. It is implemented by classifying features by criticality:

### Feature Classification

| Tier | Behavior on Failure | Examples |
|------|---------------------|----------|
| **Critical** | Must succeed. Failure blocks the request and returns an error to the user. | Login, checkout, payment |
| **Important** | Degrade gracefully with best-effort data. Return partial response. | Order history, user profile |
| **Nice-to-have** | Skip entirely if slow or failing. Return empty or null. | Recommendations, personalized content |
| **Fire-and-forget** | Never block the request. Log failure silently. | Analytics tracking, audit logs |

### Implementation Pattern

```
def get_dashboard(user_id):
    # Critical: fail if this doesn't work
    user = user_service.get_user(user_id)

    # Important: degrade with empty list on failure
    try:
        orders = order_service.get_orders(user_id, timeout=2s)
    except:
        orders = []
        degraded_features.add("orders")

    # Nice-to-have: skip on failure, short timeout
    try:
        recommendations = rec_service.get_recs(user_id, timeout=500ms)
    except:
        recommendations = []

    # Fire-and-forget: never wait for this
    async analytics_service.track_dashboard_view(user_id)

    return Dashboard(user, orders, recommendations, degraded_features)
```

### Feature Flags

Feature flags enable dynamic degradation without redeployment. When a downstream service degrades, the feature flag for that feature can be toggled off at the infrastructure level.

## Bulkhead Pattern

### What It Solves

Without isolation, a single slow or failing dependency can exhaust the entire thread pool, blocking all other features. The Bulkhead pattern isolates resources into pools so failure in one area cannot consume resources from another.

### Thread Pool Isolation

Each downstream service gets its own thread pool with dedicated limits:

| Service | Thread Pool Size | Queue Capacity |
|---------|-----------------|----------------|
| User Service (critical) | 10 | 100 |
| Order Service (important) | 10 | 100 |
| Recommendation Service (nice-to-have) | 5 | 50 |

When the recommendation service's thread pool is exhausted, only recommendation features degrade — the user and order services continue normally.

### Semaphore Bulkhead

For lightweight isolation without thread pools, use semaphores. Semaphore bulkheads limit concurrent calls without creating new threads. Use semaphores for in-memory operations; use thread pools for I/O-bound operations.

## Combined Resilience Stack

In production, these patterns compose into a layered stack:

```
Client Request
  → [1] Circuit Breaker: is the downstream service known to be failing?
        If OPEN → Skip to fallback immediately.
  → [2] Retry: attempt the operation up to N times with backoff + jitter.
        If all retries exhausted → proceed.
  → [3] Timeout: hard time limit per attempt.
        If timeout → proceed.
  → [4] Fallback Chain: try cache → degraded → default → error.
  → [5] Wrap in Bulkhead: each service call uses its own isolated thread pool.
```

Each layer is independently observable. Track how many requests flow through each resilience layer vs. succeeding on first attempt.

## Production Circuit Breaker Tuning

Real-world circuit breakers are rarely one-size-fits-all. The failure threshold, open duration, and metrics window must be tuned per service.

### Failure Threshold Decision

The failure threshold depends on each service's normal error rate:

| Service | Normal Error Rate | Failure Threshold | Rationale |
|---------|------------------|-------------------|-----------|
| Payment gateway | < 0.1% | 3 failures / 10s | Low tolerance — any increase indicates a real problem |
| Recommendation engine | < 5% | 20 failures / 60s | Higher baseline noise, needs wider window to avoid false positives |
| Analytics writer | < 1% | 50 failures / 120s | Tolerates bursts during traffic spikes |

**Common mistake**: setting a single global threshold for all services. Each service has its own error profile. Use per-service configuration.

### Open Duration Tuning

The open duration should be long enough for the downstream to recover, but short enough that the circuit does not stay open unnecessarily:

- **Rapid recovery services** (cache, in-memory DB): 5–10 seconds. These restart quickly.
- **Database-backed services**: 30–60 seconds. Need time to restart and warm caches.
- **External API dependencies**: 60–300 seconds. External services may take minutes to restore.
- **Unknown services**: start at 30 seconds, then tune based on observed recovery time.

### Half-Open Probing Strategy

In HALF_OPEN, the probe request is critical — it should test real functionality, not just connectivity. Send 1-3 probe requests; all must succeed before closing. Use a dedicated probe client with its own timeout (shorter than the production timeout).

### Metrics Window Shape

The sliding window can be either:

- **Count-based**: last N requests (e.g., last 100). Good for high-traffic services. Bad for low-traffic — a 100-request window may take hours to fill.
- **Time-based**: last N seconds (e.g., last 30). Consistent regardless of traffic. Bad for bursty traffic — a slow request can slide out before the circuit trips.

Hybrid approach: time-based window with a minimum request count floor. The circuit does not open until both conditions are met.

## Health Endpoint Pattern

Every service should expose two health check endpoints, distinguished by purpose:

### Liveness Probe

```
GET /health/live
```
- **Purpose**: Is the process alive? Quick check (sub-millisecond).
- **Implementation**: return `200 OK` immediately. No dependency checks.
- **Consumers**: orchestration platform (Kubernetes, Nomad) decides pod restart.
- **Danger**: a liveness probe that checks dependencies causes restarts during transient DB slowdowns, cascading into full cluster restarts.

### Readiness Probe

```
GET /health/ready
```
- **Purpose**: Is the service ready to serve traffic? Includes dependency verification.
- **Implementation**: check database connectivity, cache connection, message queue, critical downstream health. Return `200 OK` only if all pass.
- **Consumers**: load balancer, service registry. Takes instance out of rotation when unhealthy.
- **Timeout**: 2-3 seconds total. Do not wait for slow dependencies — report failure upstream.

### Why Separate Probes

The two probes solve different problems. Restarting a process ("liveness failed") is drastic for a transient network blip. Separating probes lets the orchestrator restart only truly dead processes and handle service failures with traffic routing.

### Health Observability

Track per-probe metrics:

- `health_check_duration_seconds{probe, service}`
- `health_check_status{probe, service}`
- `health_check_dependency_status{service, dependency}` — per-dependency health for incident triage

Alert on readiness failures persisting > 30 seconds (service degradation) and liveness failures at any duration (process crash).

## Graceful Shutdown Sequence

When a service instance is terminated (scale-down, rolling update, failure):

1. **Deregister from service registry**: stop receiving new traffic.
2. **Signal load balancer**: return `503` from readiness probes. Drains in-flight connections.
3. **Wait for in-flight requests**: allow existing requests to complete, up to graceful shutdown timeout.
4. **Close resources in dependency order**: stop accepting connections, drain message queue consumers, close database pools, close cache connections.
5. **Exit** with code 0 (intentional) or non-zero (unexpected).

### Shutdown Configuration

```yaml
server:
  shutdown: graceful
  graceful_shutdown_timeout: 30s
```

Too short: in-flight requests fail with `Connection reset`. Too long: deployments stall. Start at 30 seconds and adjust based on the service's P99 + 5s buffer.

### SIGTERM Handler

```python
def handle_sigterm(signum, frame):
    deregister_from_registry()
    mark_readiness_not_ready()
    wait_for_in_flight_requests(timeout=30)
    close_database_pools()
    close_cache_connections()
    sys.exit(0)

signal.signal(signal.SIGTERM, handle_sigterm)
```

SIGKILL cannot be caught. Assume orchestrator sends SIGTERM first, then SIGKILL after the graceful timeout.

## Rate Limiting as Backpressure

Rate limiting is not only for abuse prevention — it is also a service-to-service backpressure mechanism. When a downstream is under load, it responds with `429 Too Many Requests` and `Retry-After` header. The upstream must respect this and slow down.

### Backpressure Flow

```
Request → Upstream → Downstream (under load)
                ↓
       Downstream responds: 429 Retry-After: 5
                ↓
       Upstream delays 5s before retrying
                ↓
       Downstream recovers during the pause
```

Without backpressure, a slow downstream triggers retries from all callers simultaneously, creating a retry storm. `Retry-After` gives the downstream time to recover.

### Client-Side Rate Limiting

Well-behaved clients implement their own rate limiter to stay within the service's capacity, preventing overload even without explicit `429` responses.

## Monitoring Resilience

Track these metrics for every resilient operation:

- **Retry rate**: percentage of operations requiring retries. Rising trend suggests instability.
- **Circuit breaker trips**: frequency of circuit-opening events. Correlate with deployment windows.
- **Fallback activation rate**: how often fallbacks are used. High rate indicates persistent issues.
- **Bulkhead rejection rate**: how often the bulkhead rejects requests. Indicates pool sizing issues.
- **Operation duration (p50/p95/p99)**: split by success vs. success-after-retry.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/distributed-coordination|Distributed Coordination and Consensus]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/microservices-architecture|Microservices Architecture]]
- Source: [[sources/latency-gambler-day-17|Resilience Patterns]]
- Source: [[sources/latency-gambler-day-8|Load Balancing & Circuit Breaker Patterns]]
- Source: [[sources/latency-gambler-day-15|Microservices Patterns]]
- Source: [[sources/latency-gambler-day-18|Caching & CDN Patterns]]
- Source: [[sources/prod-web-application-components|Key Components of a Prod Web Application]]
