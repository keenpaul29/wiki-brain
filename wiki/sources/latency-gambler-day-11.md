---
title: "API Gateway & Proxy Patterns"
type: source
created: 2026-06-14
source: https://archive.is/E3eS8
tags:
  - source
---

# API Gateway & Proxy Patterns

## Summary

Day 11 of The Latency Gambler's system design series. Covers API Gateway as a single entry point for microservices, forward/reverse proxy patterns, rate limiting (token bucket and sliding window algorithms), request/response transformation, API versioning, edge gateway vs internal gateway vs BFF patterns, and production considerations.

## Key Ideas

- **API Gateway Pattern**: Single entry point routing requests to backend services, centralizing authentication, logging, rate limiting, and cross-cutting concerns.
- **Forward Proxy**: Client-side intermediary for corporate firewalls, content filtering, anonymization, and caching.
- **Reverse Proxy**: Server-side intermediary (e.g., Nginx) for load balancing, SSL termination, static content serving, and web acceleration.
- **Rate Limiting**: Token Bucket (allows burst traffic, smooth rate control) and Sliding Window (more accurate, prevents edge-case bursts) algorithms.
- **Request/Response Transformation**: Gateway adapts legacy API formats to modern client expectations.
- **API Versioning**: URL path, header, query parameter, and content-type strategies.
- **Gateway Types**: Edge Gateway (internet-facing, SSL/DDoS), Internal Gateway (service-to-service, discovery), BFF (client-specific aggregation and transformation).
- **Backend for Frontend (BFF)**: Client-specific API aggregation, reduced chattiness, and client-specific transformations.
- **Gateway Security Layer**: API gateways serve as the first line of defense — terminating TLS, validating JWT tokens, enforcing OAuth scopes, and applying Web Application Firewall (WAF) rules before traffic reaches internal services. This centralizes security policy rather than scattering it across every microservice.
- **GraphQL Federation & Gateway**: Gateway can stitch multiple GraphQL services into a single schema using Apollo Federation or schema stitching, letting frontend teams query across bounded contexts without backend coordination.
- **Service Mesh Comparison**: Gateway patterns overlap with sidecar proxies in a service mesh (Istio, Linkerd). The key distinction: gateways manage north-south traffic (external → internal), while service meshes manage east-west traffic (service → service) with mutual TLS, traffic shifting, and observability.

## Links

- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/api-management|API Management and Gateway Patterns]]
- Connects to [[concepts/api-protocol-selection|API Protocol Selection]]
- Connects to [[concepts/security-patterns|Security Patterns]]
