---
title: Integration Testing and Test Strategy
type: concept
created: 2026-06-14
tags:
  - concept
  - testing
  - integration-testing
  - ci-cd
  - reliability
---

# Integration Testing and Test Strategy

A test strategy decides what to test, at what level, with what tools, and how fast the feedback loop must be. Integration testing is the most neglected layer — mocked unit tests miss real behavior, E2E tests are too slow to run frequently. Integration tests with real services provide the best cost-benefit ratio for most distributed systems.

## The Test Pyramid

### 50/40/10 Rule

| Layer | Coverage | Speed | Confidence | Feedback |
|-------|----------|-------|------------|----------|
| **Unit tests** | 50% | Milliseconds | Low (isolated) | Immediate |
| **Integration tests** | 40% | Seconds | High (real deps) | Per commit |
| **E2E tests** | 10% | Minutes | Very high | Per deployment |

The exact ratios matter less than the shape: a broad base of fast tests with a narrow peak of slow, full-system tests. The common mistake is an inverted pyramid: many slow, flaky E2E tests and few unit/integration tests.

### Unit Tests

Test one function or class in isolation. Mock all external dependencies. Fast (sub-millisecond per test). Run on every file save.

**Rules:**
- No network calls, no database, no filesystem.
- Test logic only: transformations, validations, branching.
- If the test requires complex mocking, the code may be poorly factored.

### Integration Tests

Test a service with real dependencies (database, cache, message queue). Use lightweight containers (Testcontainers) or embedded servers. Seconds per test. Run on every commit.

**Rules:**
- Database: use a real database in a container. In-memory SQLite is not a substitute for PostgreSQL.
- Cache: use a real Redis container.
- Message queue: use a real Kafka/RabbitMQ container.
- External HTTP APIs: use a mock server (WireMock) or a recording proxy (VCR).

### E2E Tests

Test the full system from external interface to external interface. Minutes per test. Run on every deployment.

**Rules:**
- Cover the most critical user journeys (login, checkout, search).
- Do not test every edge case at this level — that belongs in integration tests.
- Use production-like data volumes for realistic behavior.

## Testing with Real Services

### Testcontainers Pattern

Testcontainers spins up disposable Docker containers for each test suite:

```python
# pytest + testcontainers
@pytest.fixture(scope="class")
def postgres(request):
    container = PostgresContainer("postgres:16")
    container.start()
    request.addfinalizer(container.stop)
    return container

def test_order_query(postgres):
    db = create_engine(postgres.get_connection_url())
    result = db.execute("SELECT count(*) FROM orders")
    assert result.scalar() == 0
```

**Benefits:**
- Tests against the real database version used in production.
- Each test suite gets a fresh, clean database.
- No shared state between tests — no test-order dependencies.

### Toxiproxy for Failure Injection

Toxiproxy is a TCP proxy that simulates network failures:

```python
# chaos testing with Toxiproxy
proxy = toxiproxy.ToxicProxy("localhost:8474")
db_proxy = proxy.create_proxy("db", "postgres-host:5432")
db_proxy.add_toxic("latency", latency=5000)  # 5 second delay
# Now all database operations through this proxy are 5s slower
```

Use Toxiproxy to test:
- Timeouts (add latency or drop connections)
- Connection resets
- Network partitions (disconnect the proxy entirely)
- Slow responses (throttle bandwidth)

### Clean-Before Strategy

Never share database state between integration tests. The clean-before strategy ensures isolation:

1. Before each test class: create a fresh schema.
2. Before each test method: truncate all tables.
3. Seed only the data the test needs.

This prevents test-order dependencies and makes tests deterministic.

## Testing in CI/CD

### Layered Test Execution

```yaml
# CI pipeline stages
stages:
  - lint                # static analysis, format check
  - unit                # fast, no external deps
  - integration         # with real services in containers
  - security            # SAST, dependency scan, secrets scan
  - build               # immutable artifact
  - e2e                 # against deployed artifact in staging
  - deploy              # to production with gradual rollout
```

### Fast Feedback

- CI should complete in under 10-15 minutes.
- Unit tests run on every push (seconds).
- Integration tests run on every commit to main (minutes).
- E2E tests run before deployment (minutes).
- Security scans run daily or on dependency changes.

### Flaky Test Management

A flaky test that fails intermittently erodes trust in the entire test suite.

**Process:**
1. Detect: run tests 3-5 times in CI. If any run fails, flag as flaky.
2. Quarantine: move flaky tests to a separate CI step that does not block deployment.
3. Fix: assign ownership, set a deadline, track in the bug tracker.
4. Never ignore: a quarantined flaky test must be fixed, not forgotten.

## AI-Generated Tests

### Behavioral Tests

AI-generated tests shift from implementation testing to behavioral testing:

```python
# AI generates behavior tests from examples
# Instead of testing the function internals, test the observable behavior

@behaviortest
def test_order_total_with_tax():
    # AI generates: given these inputs, the output must be this
    order = create_order(items=[{"price": 10.0, "qty": 2}], tax_rate=0.08)
    assert order.total == 21.6  # (10 × 2) × 1.08
```

### Continuous Test Generation

Instead of writing tests once and maintaining them, generate tests continuously from the current behavior:

- AI watches code changes and generates new tests for modified functions.
- Tests are validated by running them against the current codebase.
- When behavior changes intentionally, the tests update.

### Risks

- AI-generated tests may test the wrong behavior (encode the bug).
- Generated tests may be low-value (test trivial getters/setters).
- Test maintenance becomes AI-tool maintenance.

## Contract Testing

For microservice boundaries, contract testing verifies that the producer and consumer agree on the API:

- **Producer contract**: the service's OpenAPI/gRPC spec, including all fields and constraints.
- **Consumer contract**: what fields and endpoints a specific consumer actually uses.
- **Pact-style testing**: run consumer tests against a mock producer, capture the interactions, then verify the producer matches.

Contract testing catches breaking changes before deployment: when the producer changes a field the consumer depends on, the contract test fails.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/microservices-architecture|Microservices Architecture]]
- Related: [[concepts/ci-cd-pipeline-and-deployment|CI/CD Pipeline and Deployment Strategy]]
- Source: [[sources/integration-testing-real-services|Testing with Real Services]]
- Source: [[sources/bulletproof-ci-cd-pipeline|Building a Bulletproof CI/CD Pipeline]]
- Source: [[sources/end-of-legacy-code|Eradicating Legacy Code via AI-Driven Testing]]
- Source: [[sources/production-ai-failure-modes|Production AI Failure Modes]]
