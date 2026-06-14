---
title: "Security Patterns"
type: source
created: 2026-06-14
source: https://archive.is/mxIBa
tags:
  - source
---

# Security Patterns

## Summary

Day 20 of The Latency Gambler's system design series. Covers defense-in-depth security layers, authentication patterns (session-based, JWT, OAuth 2.0), authorization patterns (RBAC, ABAC), secure communication patterns (TLS, API keys, request signing), and a real-world security checklist.

## Key Ideas

- **Defense in Depth**: Multiple security barriers: network security, transport security, authentication, authorization, data encryption, and audit logging.
- **Session-Based Authentication**: Server stores session, client sends cookie. Simple but doesn't scale horizontally and not suitable for microservices.
- **JWT (JSON Web Tokens)**: Stateless authentication with signed tokens containing claims. Use short expiration times (15-60 min) and refresh tokens for long-lived sessions.
- **OAuth 2.0**: Delegated authorization with authorization code flow. Users log in with Google, GitHub, etc., without sharing passwords.
- **RBAC (Role-Based Access Control)**: Users have roles, roles have permissions. Simple and effective for most applications.
- **ABAC (Attribute-Based Access Control)**: Access decisions based on user, resource, and context attributes. More flexible than RBAC for complex policies.
- **TLS/HTTPS**: Encrypt all communication in transit. Force HTTPS in production.
- **API Key Management**: Validate and rate limit API keys on every request. Return 429 (Too Many Requests) when rate limited.
- **Request Signing**: HMAC-based request signing with timestamps prevents replay attacks.
- **Security Checklist**: bcrypt for passwords, account lockout, refresh tokens, least privilege, input validation, CORS, secure cookies, encrypt data at rest, never log secrets.

## Links

- Connects to [[concepts/reliability-and-operations|Reliability and Operations]]
- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[concepts/system-design|System Design]]
