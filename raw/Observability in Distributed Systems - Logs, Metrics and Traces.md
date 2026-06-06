---
title: "Observability in Distributed Systems: Diagnosing Failures with Logs, Metrics and Traces"
source: "https://rahulsuryawanshi.com/distributed-systems/fault-tolerance-high-availability/observability/"
author:
  - "Rahul Suryawanshi"
published: 2026-04-02
created: 2026-06-06
description: "A comprehensive guide to observability in distributed systems covering the three pillars (logs, metrics, traces), the four golden signals, OpenTelemetry, SLO-based alerting, and the incident diagnosis workflow."
tags:
  - "clippings"
---

## Observability in Distributed Systems: Diagnosing Failures with Logs, Metrics and Traces

### Monitoring vs Observability

**Monitoring** answers: is the system working? Based on known failure modes — threshold-based alerts.

**Observability** answers: why is the system behaving this way? Allows engineers to ask new questions without modifying code.

Both are required. Monitoring detects that something is wrong. Observability explains what happened, where, and why.

### The Three Pillars

**Logs:** Timestamped records of discrete events. Structured logging (JSON) with mandatory fields: timestamp, severity, service, trace_id, span_id, request_id, message. Unstructured logs are nearly useless in distributed systems.

**Metrics:** Numerical measurements at regular intervals. Three types: counters (monotonically increase), gauges (current state), histograms (distributions for latency percentiles).

**Four Golden Signals** (Google SRE):
- Latency: measured at p50/p95/p99/p99.9, distinguish success vs error latency
- Traffic: requests per second, establishes demand baseline
- Errors: explicit errors (5xx) + implicit errors (semantically wrong but successful status)
- Saturation: utilisation of the most constrained resource

**Traces:** A distributed trace follows a single request across services. A span represents one unit of work. The trace ID connects all three signals.

### OpenTelemetry

Vendor-neutral instrumentation standard (CNCF). Three components: API (instrumentation interface), SDK (configurable exporters/samplers), Collector (standalone agent). Instrument once, export to any backend.

### Incident Diagnosis Workflow

**Step 1 - Metrics** identify what is broken and its scope. Error rate spike, latency spike, saturation spike, traffic anomaly.

**Step 2 - Traces** identify where it is broken. Which specific downstream calls contribute to latency or errors.

**Step 3 - Logs** identify why it is broken. Error messages, stack traces, request parameters for specific spans.

### Alerting Principles

Alert on symptoms not causes. Use SLO burn rate alerting (fires when error budget consumed too fast, not on transient spikes). Set meaningful thresholds based on historical data.

### Key Takeaways

- Monitoring detects known failures; observability investigates unknown ones
- Logs explain why, metrics show what at scale, traces show where
- Four golden signals first before service-specific metrics
- OpenTelemetry avoids vendor lock-in
- Trace ID propagation through all service calls and logs enables cross-service investigation
- Metrics → traces → logs workflow reduces MTTR
- SLO-based alerting reduces false positives
