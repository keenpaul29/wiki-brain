---
title: "Testing with Real Services: A Pragmatic Guide to Integration Testing Without Mocks"
source: "https://www.kanaeru.ai/blog/2025-10-06-real-service-integration-testing"
author:
  - "Integra (Kanaeru Labs)"
published: 2025-10-06
created: 2026-06-06
description: "A practical guide to integration testing with real services — Testcontainers, credential management, cleanup strategies, error scenario testing, and achieving 90-95% coverage."
tags:
  - "clippings"
---

## Integration Testing Without Mocks

Mock-heavy test suites give a false sense of security. Mocks cannot catch: schema mismatches, network failures, database constraints, authentication flow issues, or serialization problems.

### When Mocks ARE appropriate

- Testing failure scenarios (Toxiproxy for latency injection)
- Third-party services you don't control (Stripe test mode)
- Slow/expensive operations (ML model inference)
- Isolating specific components (service B fails → test A's behavior)

Principle: mock at the boundaries, test the integration.

### Test Environment Setup

Use Docker + Testcontainers to spin up real databases and services with exact production versions. Run actual migration scripts against test databases.

Critical: use same infrastructure types as production (same DB version, same message queue config). Structure (not scale) should mirror production.

### Credential Management

Hierarchy: local `.env.test` → CI vault (GitHub Secrets) → secret manager (Vault/AWS Secrets Manager).

Tests should gracefully degrade when credentials are missing — skip test with clear message, don't crash the suite.

### Cleanup Strategies

**Clean before tests** (not after): if a test crashes mid-execution, after-cleanup never runs. Before-cleanup ensures every test starts from known state.

**Try-finally pattern** for external services you can't easily reset.

**Data isolation** for parallel tests: use unique identifiers (`test-${pid}-${counter}`) per test execution.

### Error Scenario Testing

Use Toxiproxy to inject network failures into real service calls:
- Latency injection → tests retry logic
- Connection reset → tests circuit breakers
- Rate limiting → tests backoff behavior

### Coverage Target

- 50-60% unit tests (fast, business logic)
- 30-40% integration tests (real services, component interactions)
- 5-10% E2E tests (critical user journeys)

Focus integration coverage on: auth flows, data persistence, external API integrations, message queue operations, cache invalidation.

### CI/CD Integration

Multi-stage pipeline: unit on every commit, integration on main/ready PRs, E2E on main only. Cache Docker layers. Run independent suites in parallel.

Common pitfalls: flaky tests due to timing (use explicit waits, not arbitrary timeouts), test data pollution (unique identifiers + before-cleanup), ignoring test performance (10s max per test, parallelize).
