---
title: "Adapter and Facade Patterns for System Design"
type: source
created: 2026-05-26
source: https://freedium-mirror.cfd/medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48
tags:
  - source
---

# Adapter and Facade Patterns for System Design

## Summary

Explains how Adapter and Facade patterns tame system integration and subsystem complexity by mapping incompatible interfaces and encapsulating distributed microservices behind simplified APIs.

## Key Ideas

- Adapter Pattern: Translates one interface into another that the client expects (composition-based Object Adapter is preferred over class-based inheritance Adapter).
- Bidirectional (Two-Way) Adapter: Bridges modern-to-legacy and legacy-to-modern formatting, useful for bi-directional communications like web callbacks.
- Adapter Factory Pattern: Combines Adapter with Strategy and Factory patterns to dynamically select and construct payment/vendor adapters at runtime.
- Facade Pattern: Simplifies client interaction by providing a single, unified interface to a set of interfaces in a complex subsystem (e.g. Order Processing Facade).
- API Gateway Facade: In microservices, aggregates responses from multiple services concurrently, wrapping them with circuit breakers and handling graceful degradation/fallbacks.
- Caching Facade: Consolidates profile, preference, and user services, performing parallel fetches and caching aggregated profiles (e.g., via Caffeine cache).
- Leaky Abstraction & Over-Adaptation: Anti-patterns where adapters leak implementation details (e.g., throwing vendor-specific exceptions) or incorporate core business logic.
- God Facade & Anemic Facade: Anti-patterns where facades either accumulate too much custom business logic or add zero simplification value beyond plain delegation.

## Links

- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/software-design-patterns|Software Design Patterns]]
- Connects to [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]]
