---
title: "Load Balancing & Circuit Breaker Patterns"
type: source
created: 2026-05-27
source: https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed
tags:
  - source
---

# Load Balancing & Circuit Breaker Patterns

## Summary

This article is Day 8 of The Latency Gambler's system design series. It covers two foundational patterns for distributed system resilience: **Load Balancing** (for intelligent traffic distribution) and **Circuit Breaker** (for failure management and preventing cascading failures).

## Key Ideas

- **Load Balancing Pattern**: Distributes traffic across multiple server instances to avoid hotspots, cascading failures, and resource exhaustion.
- **Load Balancing Strategies**:
  - **Round Robin**: Simple, sequential routing; doesn't account for load or weights.
  - **Weighted Round Robin**: Routes traffic proportionally based on server weight.
  - **Least Connections**: Sends requests to the instance with the fewest active connections.
  - **Intelligent (Composite) Strategy**: Selects servers by scoring multiple factors (e.g., active connections, CPU utilization, response time).
- **Circuit Breaker Pattern**: Prevents a failing downstream service from exhausting upstream resources by failing fast.
- **Circuit Breaker States**:
  - **CLOSED**: Normal operation; requests pass through.
  - **OPEN**: Failures exceed the threshold; requests fail fast immediately without hitting the downstream service.
  - **HALF_OPEN**: Periodically tests the downstream service with a limited number of requests to check if it has recovered.
- **Fallback Logic**: Returning cached data or static/default placeholders when a circuit is open, turning hard failures into graceful degradation.
- **Combined Pattern**: Combining a Load Balancer with independent per-server Circuit Breakers to bypass specific unhealthy instances while keeping the overall service available.
- **Production Lessons**: Carefully tune timeouts and thresholds; monitor state transitions; always implement graceful fallbacks.

## Links

- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/reliability-and-operations|Reliability and Operations]]
- Connects to [[sources/latency-gambler-day-7|Chain of Responsibility & State Patterns]]
