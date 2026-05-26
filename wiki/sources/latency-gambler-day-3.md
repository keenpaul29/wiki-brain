---
title: "Decorator and Proxy Patterns for System Design"
type: source
created: 2026-05-26
source: https://freedium-mirror.cfd/medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164
tags:
  - source
---

# Decorator and Proxy Patterns for System Design

## Summary

Details how Decorator and Proxy structural patterns add cross-cutting concerns (logging, security, metrics, caching) and control resource access without modifying the core service logic.

## Key Ideas

- Decorator Pattern: Extends an object's responsibilities dynamically by wrapping it. Keeps business logic pure while layering on cross-cutting concerns (logging, metrics, security).
- Decorator Ordering: Crucial in production; e.g., security checks must execute before cache lookups, and metrics should wrap everything to capture all traffic.
- Proxy Pattern: Controls access to a resource. It implements the same interface as the target, making it transparent to clients.
- Types of Proxies: Virtual Proxy (lazy loading, caching), Remote Proxy (handles network IPC like gRPC, circuit breaking), Protection Proxy (authorization and data masking), and Smart Proxy (connection pooling, statement caching).
- Dynamic Proxies: Created at runtime using reflection (Java dynamic proxies) or bytecode manipulation (CGLIB) to intercept method calls for transactions (@Transactional) or caching (@Cacheable).
- API Gateway & Microservice Proxies: Feign clients, Hystrix, and API Gateways serve as proxies combining routing, service discovery, load balancing, rate limiting, and circuit breaking.
- Anti-patterns: Decorator/Proxy Hell (deeply nested wrappers that degrade readability) and Transparency Violation (proxies altering core behavior unpredictably).

## Links

- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/software-design-patterns|Software Design Patterns]]
- Connects to [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]]
