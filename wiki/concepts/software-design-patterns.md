---
title: Software Design Patterns
type: concept
created: 2026-05-08
tags:
  - concept
  - software-design
  - architecture
---

# Software Design Patterns

Software design patterns are reusable ways to localize recurring change costs. They are useful when they answer a concrete pain in the codebase, not when they are applied as generic sophistication.

## Selection Heuristic

Start by naming the friction:

- Creation pain: constructors, defaults, configuration, or implementation selection are spreading through callers.
- Structure pain: components do not fit cleanly, external APIs leak into domain logic, or subsystem usage is too error-prone.
- Behavior pain: rules, algorithms, states, or workflows keep changing and conditionals are multiplying.

The smallest pattern that makes the pain explicit is usually better than a broad abstraction.

## SOLID Principles for Distributed Systems

Class-level SOLID principles map to architectural concerns when systems are decomposed into network-separated services.

| Principle | Class-Level Meaning | Distributed-System Interpretation |
|---|---|---|
| **Single Responsibility** | One class, one reason to change | One service should fail independently. If a component goes down, its failure should not cascade. Databases, caches, and compute should be independently deployable and independently crashable. |
| **Open / Closed** | Open for extension, closed for modification | New behavior is added by deploying new service instances or configuring existing ones (feature flags, pluggable middleware), not by rewriting the core service. |
| **Liskov Substitution** | Subtypes must be substitutable for base types | Services exposing the same contract (e.g., a cache interface) must be swappable — Redis for local cache, or Memcached for Redis — without callers changing. This requires strict interface contracts (protobuf, OpenAPI) and behavioral equivalence guarantees. |
| **Interface Segregation** | Many specific interfaces > one general interface | Service boundaries should be narrow and focused. A user-service should not expose payment methods. Bounded contexts in domain-driven design enforce this at the architectural level. |
| **Dependency Inversion** | Depend on abstractions, not concretions | High-level business logic should not import database drivers or HTTP clients directly. Repository interfaces, message abstractions, and dependency injection containers decouple policy from mechanism. |

Patterns become insurance policies against wrong assumptions — that load is fixed, the database never goes down, requirements won't change. Each pattern explicitly accommodates a class of future change.

## Pattern Families

### Creational Patterns

Creational patterns abstract the instantiation process, making systems independent of how their objects are created and configured.

#### Singleton Pattern
- **Objective**: Ensures a class has only one instance per JVM and provides global access.
- **Production Implementation**: The **Enum Singleton** is the recommended thread-safe, reflection-proof, and automatically serialized approach. Alternatively, the **Initialization-on-demand holder idiom** leverages a static inner class to achieve lazy loading without synchronization overhead.
- **Distributed Caveat**: The "one instance" guarantee breaks down in clustered environments. Microservices must rely on dependency injection containers or external distributed coordination services (Consul, etcd) to manage lifecycle.

#### Builder Pattern
- **Objective**: Assembles complex objects with many optional parameters, avoiding telescope constructor anti-patterns.
- **Key Practices**: Perform all validations inside the `build()` method to ensure constructed objects are immutable and valid. Self-referential generics can support builder inheritance hierarchy.

### Structural Patterns

Structural patterns concern how classes and objects are composed to form larger, flexible structures.

#### Decorator Pattern
- **Objective**: Wraps an object to dynamically add or modify responsibilities without modifying original code.
- **Ordering Constraint**: Wrapped layers must execute in a strict logical sequence (e.g. security verification checks must run before caching lookup decorators, and latency metrics must wrap the entire call boundary to capture all traffic).

#### Proxy Pattern
- **Objective**: Controls access to a resource by acting as an intermediary.
- **Types**:
  - *Virtual Proxy*: Lazy-loads expensive objects or caches responses.
  - *Remote Proxy*: Intercepts network queries (e.g., gRPC, adding circuit breakers).
  - *Protection Proxy*: Manages authorization constraints and data masking.
  - *Dynamic Proxy*: Generates interceptors at runtime via reflection or bytecode manipulation (e.g. Spring `@Transactional` or `@Cacheable`).

#### Adapter Pattern
- **Objective**: Maps incompatible interfaces to enable third-party vendor integrations. Composition-based Object Adapters are preferred over inheritance-based Class Adapters.
- **Adapter Factory**: Pairs with the Factory and Strategy patterns to dynamically resolve and construct adapters at runtime (e.g., payment gateways).

#### Facade Pattern
- **Objective**: Simplifies client interaction by providing a single, consolidated entry point to a complex subsystem.
- **API Gateway Facade**: Aggregates calls to multiple microservices in parallel, handling fallbacks and circuit breakers gracefully.

#### Repository Pattern
- **Objective**: Mediates between domain and data mapping layers, presenting a collection-like interface to the domain for accessing persisted objects.
- **Aggregate Roots**: One repository per aggregate root. Repositories should not cross aggregate boundaries — load the aggregate root and its direct relations together.
- **Read/Write Separation**: For read-heavy workloads, separate read-only repositories backed by denormalized projections from write repositories backed by normalized models (CQRS).
- **Testing Benefits**: Repository interfaces make business-logic tests mockable without database setup. The in-memory repository implementation is the most common test double.
- **Production Considerations**: Batch write operations for bulk inserts. Set explicit connection timeouts to prevent hung connections. Monitor pool exhaustion as an early symptom of slow queries or connection leaks.

#### Connection Pool Pattern
- **Objective**: Reuses a pre-allocated set of database connections to avoid the overhead of establishing a raw TCP connection (handshake, authentication, SSL negotiation) per request.
- **Pool Tuning**: HikariCP (Java) and PgBouncer (Postgres proxy) are production standards. Pool size should be tuned against max database connections, not against request concurrency — a small pool (10-20 connections per CPU core) often outperforms a large one because it keeps the database from thrashing.
- **Monitoring**: Track active vs. idle connections, pending queue depth, connection acquisition wait time, and timeout rate. A growing pending queue signals a query-performance or connection-leak problem.

#### Connection Factory Pattern
- **Objective**: Abstracts connection creation and routing so callers do not know whether a connection targets a primary, a read replica, or a failover node.
- **Read/Write Routing**: Writes go to the primary; reads go to replicas. The factory encapsulates the routing decision, health checks, and failover logic.
- **Failover Integration**: When the primary endpoint fails, the factory promotes a replica or falls back to a degraded read-only mode. Combine with retry logic for transient failures.

### Behavioral Patterns

Behavioral patterns deal with algorithms and the assignment of responsibilities between objects.

#### Strategy Pattern
- **Objective**: Encapsulates interchangeable algorithms behind a common interface, allowing systems to switch behaviors at runtime without code changes (e.g., changing recommendation logic or payment providers).
- **Execution**: Can read active strategy names from configurations or chain strategies in a composite validation pipeline.

#### Observer Pattern
- **Objective**: Establishes a one-to-many dependency, notifying subscribers automatically when a subject state changes. Key for event-driven systems.
- **Push vs. Pull**: Push models broadcast all data to observers immediately, while Pull models broadcast minimal IDs and prompt observers to fetch specific details.
- **Reliability & Memory Safety**: Observers should run asynchronously (via executor pools) to prevent blocking main threads. Use `WeakReference` in observer lists to avoid garbage collection memory leaks.

#### Command Pattern
- **Objective**: Encapsulates requests as objects, supporting queuing, scheduling, undo operations, and auditing.
- **Command Queue**: Submits operations to thread pools using `BlockingQueue` and dead-letter queues (DLQ) for error isolation.

#### Template Method Pattern
- **Objective**: Outlines algorithm skeletons in base classes, deferring concrete steps to subclasses.
- **Hooks vs. Abstract Methods**: Abstract methods force subclasses to implement steps, while Hook methods provide optional behavior overrides.

#### Chain of Responsibility Pattern
- **Objective**: Passes requests along a chain of decoupled handlers. Each handler decides whether to process the request or delegate it to the next in line (e.g., HTTP middleware pipelines).
- **Control & Branching**: Handlers can terminate the chain early (e.g. returning cached response) or branch conditionally. Keep handlers fully independent and order-agnostic.

#### State Pattern
- **Objective**: Encapsulates state-dependent behaviors inside separate state classes, making transitions explicit and eliminating nested if-else/switch blocks.
- **Side Effects**: Transitions should trigger event broadcasts rather than embedding complex side-effect code (like database updates) directly inside state objects.

---

## Engineering Judgment

Design patterns should improve reviewability and testability. If a pattern hides dependencies, creates a global state problem, turns simple flows into ceremony, or makes control flow harder to trace, it is probably solving the wrong problem.

LLM-assisted coding can multiply pattern misuse because models reproduce existing local structure without understanding whether it is intentional. When state ownership, event signals, or service startup order matter, those constraints need to be explicit in project instructions and reviewed as architecture, not as incidental code style.

## Links

- Source: [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]]
- Source: [[sources/latency-gambler-day-1|Building the System Architect Mindset]]
- Source: [[sources/latency-gambler-day-2|Strategy and Observer Patterns for System Design]]
- Source: [[sources/latency-gambler-day-3|Decorator and Proxy Patterns for System Design]]
- Source: [[sources/latency-gambler-day-4|Singleton and Builder Patterns for System Design]]
- Source: [[sources/latency-gambler-day-5|Command and Template Method Patterns for System Design]]
- Source: [[sources/latency-gambler-day-6|Adapter and Facade Patterns for System Design]]
- Source: [[sources/latency-gambler-day-7|Chain of Responsibility & State Patterns]]
- Source: [[sources/latency-gambler-day-8|Load Balancing & Circuit Breaker Patterns]]
- Source: [[sources/latency-gambler-day-9|Database Patterns & Repository Pattern]]
- Source: [[sources/ai-slop-game-refactor|Scrubbing AI Slop From a Game Codebase]]
- Related: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Related: [[concepts/system-design|System Design]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]

