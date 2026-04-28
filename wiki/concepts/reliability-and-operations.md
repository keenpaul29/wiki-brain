---
title: Reliability and Operations
type: concept
created: 2026-04-28
tags:
  - concept
  - reliability
  - operations
  - system-design
---

# Reliability and Operations

Reliability and operations convert an architecture from a diagram into a system that survives load, failures, abuse, and change. The system design source covers availability, fault tolerance, rate limiting, disaster recovery, security, and observability-oriented service management.

## Availability and Failure

- Availability measures how often a system is usable.
- Reliability measures whether the system performs correctly over time.
- Fault tolerance means the system continues operating despite component failures.
- Redundant load balancers, replicas, caches, and service instances reduce single points of failure.

## Control and Protection

- Rate limiting protects systems from abuse, traffic spikes, and noisy clients.
- Common rate-limit algorithms include leaky bucket, token bucket, fixed window, sliding log, and sliding window.
- Circuit breakers stop repeated calls into failing dependencies and allow controlled recovery.
- Backpressure prevents producers from overwhelming consumers.

## Service Operations

- SLA: external promise to users or customers.
- SLO: internal or external target for reliability.
- SLI: measured indicator used to judge whether the target is met.
- Disaster recovery uses RTO and RPO to reason about recovery time and acceptable data loss.
- Cold sites, hot sites, and backups represent different cost/recovery tradeoffs.

## Security and Identity

- OAuth 2.0 delegates authorization.
- OpenID Connect adds identity on top of OAuth.
- SSO centralizes authentication across services.
- TLS secures transport; mTLS authenticates both sides and is common in zero-trust microservice environments.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Source: [[sources/system-design-course|System Design Course]]

