---
title: "Resilience Patterns"
type: source
created: 2026-06-14
source: https://archive.is/Tin0A
tags:
  - source
---

# Resilience Patterns

## Summary

Day 17 of The Latency Gambler's system design series. Covers Retry pattern with exponential backoff and jitter, Timeout pattern with layered timeouts, Fallback and Graceful Degradation patterns with fallback chains, and the combination of all resilience patterns into an ultra-resilient service client.

## Key Ideas

- **Retry Pattern**: Automatically retries failed operations with intelligent backoff. Exponential backoff with jitter prevents thundering herd problems. Distinguishes retryable (transient) from non-retryable (business logic) exceptions.
- **Transient Failures**: ~70% of failures are transient (network blips, temporary overload). Retry pattern handles these effectively.
- **Timeout Pattern**: Prevents indefinite waiting by setting maximum wait time. Layered timeouts: connection timeout, read timeout, connection request timeout, and overall operation timeout.
- **Fallback Pattern**: Provides alternative responses when primary operations fail. Fallback chain: cached data → simpler algorithm → generic defaults → degraded service → empty response.
- **Graceful Degradation**: Maintains partial functionality instead of complete failure. Feature flags control which features are enabled. Critical features don't degrade; important features degrade with timeouts; nice-to-have features are skipped entirely.
- **Ultra-Resilient Client**: Combines circuit breaker (fail fast), retry (handle transient failures), timeout (prevent hanging), and fallback (graceful degradation) in layered defense.
- **Resilience Monitoring**: Track retry attempts, timeouts, fallback usage, and circuit breaker state transitions.
- **Circuit Breaker Integration**: Complements retry by failing fast when a downstream service is unhealthy. Three states (Closed → Open → Half-Open) with configurable failure thresholds, cooldown windows, and probe requests prevent cascading failures across service boundaries.
- **Bulkhead Resource Isolation**: Beyond thread pools, bulkhead patterns apply to connection pools (per-database connection limits), downstream service client pools, and disk I/O. Resilience frameworks (Resilience4j, Hystrix) implement semaphore-based and thread-pool-based bulkheads.
- **Chaos Engineering for Resilience Validation**: Patterns should be tested through controlled fault injection (network latency, process crashes, resource exhaustion). Tools like Chaos Monkey and Litmus prove that resilience configurations actually work before production incidents.

## Links

- Connects to [[concepts/reliability-and-operations|Reliability and Operations]]
- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]]
- Connects to [[concepts/observability-and-monitoring|Observability and Monitoring]]
- Connects to [[concepts/incident-management-sre|Incident Management and SRE Practice]]
