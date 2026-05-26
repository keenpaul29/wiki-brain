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

---

## Engineering Judgment

Design patterns should improve reviewability and testability. If a pattern hides dependencies, creates a global state problem, turns simple flows into ceremony, or makes control flow harder to trace, it is probably solving the wrong problem.

## Links

- Source: [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]]
- Source: [[sources/latency-gambler-day-1|Building the System Architect Mindset]]
- Source: [[sources/latency-gambler-day-2|Strategy and Observer Patterns for System Design]]
- Source: [[sources/latency-gambler-day-3|Decorator and Proxy Patterns for System Design]]
- Source: [[sources/latency-gambler-day-4|Singleton and Builder Patterns for System Design]]
- Source: [[sources/latency-gambler-day-5|Command and Template Method Patterns for System Design]]
- Source: [[sources/latency-gambler-day-6|Adapter and Facade Patterns for System Design]]
- Related: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Related: [[concepts/system-design|System Design]]


