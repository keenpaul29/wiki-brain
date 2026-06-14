---
title: "Microservices Patterns"
type: source
created: 2026-06-14
source: https://archive.is/ijoWZ
tags:
  - source
---

# Microservices Patterns

## Summary

Day 15 of The Latency Gambler's system design series. Covers Service Registry & Discovery (dynamic service location), API Gateway with service discovery, Bulkhead pattern for failure isolation, and Netflix OSS stack patterns (Eureka, Zuul, Hystrix, Ribbon).

## Key Ideas

- **Service Registry & Discovery**: Dynamic service location for auto-scaling deployments. Services register with a registry and clients discover healthy instances via service discovery.
- **Service Registry Implementation**: In-memory registry with heartbeat-based health checks and automatic cleanup of unhealthy instances.
- **API Gateway with Service Discovery**: Single entry point for routing, authentication, rate limiting, and aggregation. Parallel calls to multiple services with timeout.
- **Bulkhead Pattern**: Isolates resources (threads, connections, memory) so failure in one area doesn't affect others. Named after ship bulkheads preventing water from flooding the entire ship.
- **Thread Pool Bulkhead**: Each service gets its own isolated thread pool with configurable size, queue capacity, and keep-alive.
- **Netflix OSS Stack**: Eureka (service discovery), Zuul (API Gateway), Hystrix (circuit breaker/bulkhead), Ribbon (client-side load balancing).
- **Health Checks**: Services expose health endpoints checking database connectivity, disk space, and registry status.
- **Graceful Shutdown**: Deregister from service registry, wait for in-flight requests, then close resources.
- **Domain-Driven Design (DDD) Bounded Contexts**: Microservice boundaries should align with DDD bounded contexts — each service owns its data, domain logic, and ubiquitous language. This prevents the "distributed big ball of mud" where services share databases or leak internal models.
- **Service Mesh for East-West Traffic**: Beyond basic service discovery, a service mesh (Istio, Consul Connect) provides mutual TLS, traffic shifting for canary deployments, circuit breaking, and detailed telemetry at the infrastructure layer without modifying application code.
- **Deployment Strategies for Microservices**: Canary releases (route 5% of traffic to new version), blue-green deployments (full cutover with instant rollback), and feature flags (runtime toggles) are essential for safely evolving independently deployed services.

## Links

- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[concepts/reliability-and-operations|Reliability and Operations]]
- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/microservices-architecture|Microservices Architecture]]
- Connects to [[concepts/team-topologies|Team Topologies]]
- Connects to [[concepts/ci-cd-pipeline-and-deployment|CI/CD Pipeline and Deployment Strategy]]
- Connects to [[concepts/observability-and-monitoring|Observability and Monitoring]]
