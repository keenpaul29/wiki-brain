---
title: Observability and Monitoring in Distributed Systems
type: concept
created: 2026-06-14
tags:
  - concept
  - observability
  - monitoring
  - sre
  - system-design
---

# Observability and Monitoring in Distributed Systems

Monitoring detects known failures. Observability investigates unknown ones. Both are required in distributed systems, but they serve different purposes: monitoring is dashboards and alerts for what you expect to go wrong; observability is the tooling and data model to answer questions you did not think to ask.

## Three Pillars of Observability

| Pillar | What It Answers | Format | Storage |
|--------|----------------|--------|---------|
| **Logs** | What happened at a specific moment? | Structured text (JSON) | ELK, Loki, CloudWatch |
| **Metrics** | How much, how fast, how often? | Numeric time series | Prometheus, Datadog, Grafana |
| **Traces** | Where did the request go? | Span trees with timing | Jaeger, Tempo, X-Ray |

Each pillar has a distinct cost, retention, and query pattern. Metrics are cheap and retained long-term. Logs are expensive and sampled at high volume. Traces bridge the gap by carrying correlation IDs.

## The Four Golden Signals

Google SRE defines four metrics every system should expose:

| Signal | What It Measures | Key Questions |
|--------|-----------------|---------------|
| **Latency** | Time to serve a request (p50/p95/p99/p99.9) | Is the system getting slower? |
| **Traffic** | Requests per second, concurrent connections | Is demand growing or spiking? |
| **Errors** | Explicit (HTTP 5xx) + implicit (200 but wrong) | Is the system producing correct results? |
| **Saturation** | Utilization of the most constrained resource | Is there headroom left? |

### Latency Percentiles

Percentiles matter more than averages. A service with 100ms average latency can have 2-second p99 — the slowest 1% of users experience 20x the median. Track p50 (typical), p95 (almost everyone), and p99 (worst case). For latency-critical services, also track p99.9.

### Error Rate Types

- **Explicit errors**: HTTP 5xx, uncaught exceptions, gRPC status codes.
- **Implicit errors**: HTTP 200 with wrong data, stale cache, silently dropped messages.
- **Client-visible errors**: errors that reach the user vs internal errors handled by fallbacks.

## Diagnostic Workflow

Use a structured approach to move from symptom to root cause:

```
1. Metrics identify scope
   → Dashboard shows latency spike on /api/orders
   → Narrowed to the "payment" service

2. Traces identify location
   → Trace shows 4 second pause in payment-gateway call
   → The actual gRPC call to Stripe took 3.8 seconds

3. Logs identify root cause
   → Payment service logs: "connection reset by peer at 14:32:05"
   → Correlated with Stripe's maintenance window
```

This workflow is the standard operating procedure in mature observability systems. Metrics give the "what and when." Traces give the "where." Logs give the "why."

## Structured Logging

### Required Fields

Every log entry should include:

```json
{
  "timestamp": "2026-06-14T14:30:00.123Z",
  "level": "ERROR",
  "service": "payment-service",
  "trace_id": "d94f3a17-3a8f-4f9b-8f0a-2e1c5d6b7a8c",
  "span_id": "a1b2c3d4",
  "request_id": "req-abc123",
  "message": "payment gateway connection timeout after 5s",
  "duration_ms": 5023,
  "gateway": "stripe",
  "error_kind": "timeout"
}
```

### Structured vs Unstructured

| | Unstructured | Structured (JSON) |
|---|---|---|
| Search | Grep only | Full-text + field queries |
| Aggregation | Impossible | count by service, p99 by error_kind |
| Schema | None | Validate on write |
| Tooling | tail, grep | Logstash, Loki, CloudWatch Logs Insights |

### Log Levels in Practice

- **ERROR**: user-visible failure. Alert immediately.
- **WARN**: degraded but handled. Investigate if sustained.
- **INFO**: notable state changes (deployment, config reload). Keep minimal.
- **DEBUG**: verbose diagnostic detail. Off in production by default. Enable per-service via feature flag.

### Common Anti-Patterns

- **Logging sensitive data** (passwords, tokens, PII). Log scrubbing and redaction are essential.
- **Logging inside hot loops**. A loop that runs 100k times/second should not log per iteration.
- **String interpolation before log-level check**. Use lazy evaluation or structured logging to avoid formatting costs when the log level is disabled:
  ```python
  # Bad: always evaluates the expression
  log.debug(f"Processing user {user.get_full_profile()}")
  
  # Good: only evaluates if debug is enabled
  log.debug("Processing user %s", user.id)
  ```

## Metrics Collection

### Metric Types

| Type | Behavior | Use Case |
|------|----------|----------|
| **Counter** | Monotonically increasing | Request count, error count, bytes sent |
| **Gauge** | Current value, goes up and down | Memory usage, queue depth, active connections |
| **Histogram** | Value distribution in buckets | Request latency, response size |
| **Summary** | Pre-computed percentile estimates | p50/p95/p99 latency (client-side) |

### Instrumentation Pattern

```python
# Counter
requests_total = Counter("http_requests_total", "Total HTTP requests", ["method", "path"])
requests_total.labels(method="GET", path="/api/orders").inc()

# Histogram
request_duration = Histogram("http_request_duration_seconds", "Request duration", ["service"])
request_duration.labels(service="orders").observe(0.235)
```

### Metrics Collection Architecture

```
[Application] → /metrics endpoint → [Prometheus scrape]
                                         ↓
                                   [Prometheus TSDB]
                                         ↓
                                   [Grafana dashboards]
                                         ↓
                                   [Alertmanager → PagerDuty/Slack]
```

The pull model (Prometheus scrapes targets) scales better than the push model because the monitoring system controls collection frequency and handles unreachable targets gracefully.

## Distributed Tracing

### Trace Structure

A trace is a tree of spans. Each span represents a unit of work:

```
Trace: GET /api/orders/123
  Span: gateway.handle_request (1ms)
    Span: orders.validate_auth (2ms)
      Span: auth.check_token (1ms)
    Span: orders.get_order (15ms)
      Span: db.query (12ms)
    Span: orders.get_items (8ms)
      Span: db.query (6ms)
```

Each span has: trace_id, span_id, parent_span_id, operation_name, start_time, duration, and optional tags (status_code, error flag, database statement).

### Context Propagation

The trace context must propagate across service boundaries:

```
Service A → sends HTTP request with header: traceparent: 00-d94f3a17...-a1b2c3d4-01
              ↓
Service B → extracts traceparent from header, creates child span
              ↓
Service C → the same traceparent header, another child span
```

OpenTelemetry standardizes this with the W3C `traceparent` header. Every HTTP client and server library must propagate this header.

### Sampling Strategies

| Strategy | Behavior | Use Case |
|----------|----------|----------|
| **Head-based** | Sample decision at request start (e.g., 1%) | Low-traffic systems |
| **Tail-based** | Store all spans, sample after completion | High-traffic, need error captures |
| **Rate-limited** | Capture N traces per second, oldest first | Budget-constrained systems |

Head-based sampling is simpler but misses rare errors. Tail-based sampling captures all errors but requires more storage. The standard compromise: head-based at 1% for general traces, + 100% sampling for traces with errors.

## SLOs and SLIs

### Definitions

- **SLI** (Service Level Indicator): the actual measurement (e.g., p99 latency = 200ms).
- **SLO** (Service Level Objective): the target (e.g., p99 latency < 300ms, 99.9% of the time over 30 days).
- **Error Budget**: the allowed failure window = 100% - SLO%. For a 99.9% SLO, the error budget is 0.1% (43 minutes/month).

### Burn-Rate Alerting

Threshold-based alerting (latency > 500ms → page) generates false positives on transient spikes. Burn-rate alerting fires when the error budget is consumed faster than expected:

| Burn Rate | Time to Budget Exhaustion | Alert Severity |
|-----------|--------------------------|----------------|
| 1x (budget consumed at expected rate) | 30 days | No alert — normal |
| 2x | 15 days | Warning ticket |
| 10x | 3 days | Page on-call |
| 100x | 7 hours | Critical page, wake up |

A 5-minute latency spike at 100x burn rate consumes error budget equal to 500 minutes of normal operation. The burn-rate alert catches this immediately rather than waiting for the monthly SLO to breach.

### Multi-Window Approach

Use multiple evaluation windows to avoid both false negatives (too slow to detect) and false positives (transient spike triggers page):

```
Short window (5 min) at high burn rate: detect fast, need high threshold to avoid noise
Long window (1 hour) at moderate burn rate: confirm sustained issue
```

Alert when both windows exceed their thresholds. The short window catches the problem early; the long window confirms it is real.

## Dashboards

### Dashboard Tiers

| Tier | Audience | Purpose | Update Frequency |
|------|----------|---------|-----------------|
| **Operational** | On-call engineers | Current system health | Real-time (seconds) |
| **Tactical** | Engineering teams | Recent trends (hours-days) | Minutes |
| **Strategic** | Management | Monthly/quarterly trends | Hours-days |

### Dashboard Anti-Patterns

- **Everything on one dashboard**: information overload. Follow the "five graphs per screen" rule.
- **No time-series context**: a latency graph without yesterday's baseline is useless. Always overlay current vs previous week.
- **Using averages**: a 200ms average latency could mask 99.9th percentile at 5 seconds. Use percentiles.
- **No annotation**: mark deployments, config changes, and incident windows on dashboards. Otherwise, it is impossible to correlate changes with metric shifts.

## Alerting

### Alert Severity Levels

| Level | Response Time | Channel | Example |
|-------|---------------|---------|---------|
| SEV-1 | Immediate (wake up) | Phone/SMS | Service down, data loss |
| SEV-2 | < 15 minutes | Slack/PagerDuty | Latency p99 > SLO, error rate > 1% |
| SEV-3 | < 1 hour | Slack/ticket | Disk > 80%, cert expires in 7 days |
| SEV-4 | Next business day | Ticket only | Deprecation warning, tech debt |

### Alert Anti-Patterns

- **Alert fatigue**: too many alerts, most false. Engineers ignore or silence alerts. Fix by raising thresholds or consolidating.
- **Dead alerts**: configured but never fired in months. They will fail when needed. Test alert paths periodically.
- **No runbook**: an alert without a runbook forces the on-call to investigate from scratch. Every alert should link to a runbook.
- **Static thresholds**: a service that normally runs at 10% CPU would page at 80%, but a 50% CPU spike is anomalous. Use dynamic baselines.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/incident-management-sre|Incident Management and SRE Practice]]
- Source: [[sources/observability-in-distributed-systems|Observability in Distributed Systems]]
- Source: [[sources/sre-incident-management|SRE Incident Management]]
- Source: [[sources/backend-performance-engineering|Backend Performance Engineering]]
- Source: [[sources/bulletproof-ci-cd-pipeline|Building a Bulletproof CI/CD Pipeline]]
- Source: [[sources/latency-gambler-day-14|Monitoring & Observer Patterns]]
