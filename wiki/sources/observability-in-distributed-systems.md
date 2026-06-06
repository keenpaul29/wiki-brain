---
title: "Observability in Distributed Systems"
type: source
created: 2026-06-06
source: https://rahulsuryawanshi.com/distributed-systems/fault-tolerance-high-availability/observability/
author: "Rahul Suryawanshi"
tags:
  - source
  - observability
  - system-design
  - reliability
---

# Observability in Distributed Systems

## Summary

Covers the three pillars of observability (logs, metrics, traces), the four golden signals (latency, traffic, errors, saturation), OpenTelemetry as a vendor-neutral instrumentation standard, and the metrics→traces→logs incident diagnosis workflow. Introduces SLO burn-rate alerting as an alternative to threshold-based alerting.

## Key Ideas

- Monitoring detects known failures; observability investigates unknown ones. Both are required.
- Structured logging (JSON) with mandatory trace_id, span_id, service, severity, and request_id fields enables cross-service correlation.
- Four golden signals from Google SRE: latency at p50/p95/p99/p99.9, requests per second, error rate (explicit + implicit), and saturation of the most constrained resource.
- OpenTelemetry instruments once and exports to any backend via its API + SDK + Collector architecture.
- Diagnostic workflow: metrics identify scope → traces identify location → logs identify root cause.
- SLO burn-rate alerting fires when error budget is consumed too fast, reducing false positives from transient spikes.

## Links

- Supports [[concepts/system-design|System Design]]
- Supports [[concepts/reliability-and-operations|Reliability and Operations]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
