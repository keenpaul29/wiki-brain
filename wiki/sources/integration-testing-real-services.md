---
title: "Testing with Real Services: Integration Testing Without Mocks"
type: source
created: 2026-06-06
source: https://www.kanaeru.ai/blog/2025-10-06-real-service-integration-testing
author: "Integra (Kanaeru Labs)"
tags:
  - source
  - testing
  - integration-testing
  - quality
  - system-design
---

# Testing with Real Services: Integration Testing Without Mocks

## Summary

A pragmatic guide to integration testing with real services using Docker + Testcontainers, credential management hierarchies, cleanup strategies (clean-before, try-finally, data isolation via unique identifiers), error scenario testing with Toxiproxy (latency injection, connection reset, rate limiting), and the balanced coverage pyramid (50-60% unit, 30-40% integration, 5-10% E2E). Covers CI/CD multi-stage pipeline integration with parallel execution and cache optimisation.

## Key Ideas

- Mock-heavy tests miss schema mismatches, network failures, database constraints, auth flow issues, and serialization problems.
- Use mocks at boundaries, test the integration. Mocks are appropriate for third-party services, failure scenarios (Toxiproxy), and isolating specific components.
- Testcontainers + Docker spin up real services with exact production versions. Run actual migration scripts against test databases.
- Credential hierarchy: local `.env.test` → CI vault → secret manager. Tests degrade gracefully when credentials are missing.
- Clean before tests (not after) — crashed tests never run after-cleanup. Use try-finally for external services.
- Data isolation for parallel tests: use unique identifiers (`test-${pid}-${counter}`).
- Toxiproxy injects latency, connection resets, and rate limiting into real service calls to test retry/circuit-breaker/backoff behavior.
- Coverage pyramid: unit (fast, business logic) → integration (component interactions) → E2E (critical journeys only).
- Multi-stage CI: unit on every commit, integration on main/ready PRs, E2E on main only.

## Links

- Supports [[concepts/system-design|System Design]]
- Supports [[concepts/reliability-and-operations|Reliability and Operations]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
