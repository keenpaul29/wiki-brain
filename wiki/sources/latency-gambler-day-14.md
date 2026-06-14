---
title: "Monitoring & Observer Patterns"
type: source
created: 2026-06-14
source: https://archive.is/xZVQT
tags:
  - source
---

# Monitoring & Observer Patterns

## Summary

Day 14 of The Latency Gambler's system design series. Covers the three pillars of observability (logs, metrics, traces), Observer pattern implementation for monitoring, structured logging, metrics collection patterns, distributed tracing, alerting conditions, multi-channel notification systems, and production considerations.

## Key Ideas

- **Three Pillars of Observability**: Logs (what happened), Metrics (how much/how fast), Traces (where requests go).
- **Observer Pattern for Monitoring**: System components notify interested monitoring systems about events, state changes, and performance metrics automatically.
- **Structured Logging**: Machine-readable JSON logs with traceId, spanId, service name, and attributes for better searching and analysis.
- **Metrics Collection**: Counters (monotonically increasing), Timers (duration/rate), Gauges (current value), Distribution Summaries (value distribution).
- **Distributed Tracing**: Track requests across multiple services with spans and trace IDs. Identifies performance bottlenecks and error propagation.
- **Alerting**: Alert conditions evaluate monitoring events against thresholds. Multi-channel notifications (Slack, Email, SMS) with severity levels (CRITICAL, WARNING, INFO).
- **Alert Fatigue Prevention**: Cooldown periods to suppress duplicate alerts within time windows.
- **Performance Considerations**: Lock-free data structures for high-throughput events, sampling for high-volume events, backpressure to prevent memory issues.
- **Synthetic Monitoring**: Probes that simulate user traffic from multiple geographic regions catch outages before real users are affected. Heartbeat checks (ping every 30s), transaction scripts (log in → search → purchase), and assertion-based validation form the synthetic monitoring pyramid.
- **SLI / SLO / SLA Framework**: Service Level Indicators (latency p99, error rate, throughput) feed Service Level Objectives (p99 latency < 200ms over 30 days). Alerting thresholds should be set conservatively relative to SLOs — page when burn rate suggests SLO breach within the observation window.
- **Observability-Driven Incident Response**: Structured logs with correlation IDs enable rapid root-cause analysis. On-call runbooks codify triage steps, escalation paths, and remediation actions so that any engineer can respond to a page without deep system expertise.

## Links

- Connects to [[concepts/reliability-and-operations|Reliability and Operations]]
- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[concepts/observability-and-monitoring|Observability and Monitoring]]
- Connects to [[concepts/incident-management-sre|Incident Management and SRE Practice]]
- Connects to [[concepts/performance-engineering|Performance Engineering]]
