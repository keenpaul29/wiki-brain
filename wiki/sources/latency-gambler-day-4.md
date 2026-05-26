---
title: "Singleton and Builder Patterns for System Design"
type: source
created: 2026-05-26
source: https://freedium-mirror.cfd/medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4
tags:
  - source
---

# Singleton and Builder Patterns for System Design

## Summary

Examines the proper implementations of Singleton and Builder creational patterns, emphasizing thread safety, immutability, and dependency injection over global mutable state.

## Key Ideas

- Singleton Pattern: Ensures a class has only one instance and provides global access. Real-world cases focus on expensive resources (database connection pools, configuration managers) rather than just global variables.
- Enum Singleton: Joshua Bloch's recommended implementation—thread-safe by default, reflection-proof, and automatically handles serialization.
- Initialization-on-demand holder idiom: Thread-safe lazy loading pattern without synchronization cost using a static inner class.
- Singleton in Distributed Systems: The 'one instance per JVM' rule breaks down in microservices. External distributed configuration stores (Consul, etcd) or Dependency Injection containers (Spring/Guice) must manage lifecycle.
- Builder Pattern: Assembles complex objects with many optional parameters, avoiding telescope constructor anti-patterns.
- Fluent Builder & Validation: Validations should occur during construction inside the build() method to ensure immutability and valid configurations.
- Self-Referential Generics: Abstract base builder implementation that supports inheritance across subclass builders.
- Lombok @Builder & Java Records: Language-level tools to eliminate builder boilerplate while ensuring immutability and defensive copying.

## Links

- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/software-design-patterns|Software Design Patterns]]
- Connects to [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]]
