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

- Creational: Builder, Factory Method, Abstract Factory, Prototype, and cautious Singleton usage.
- Structural: Adapter, Facade, Decorator, Proxy, Composite, Flyweight, and Bridge.
- Behavioral: Chain of Responsibility, Command, Strategy, State, Observer, Memento, Mediator, and Visitor.

## Engineering Judgment

Design patterns should improve reviewability and testability. If a pattern hides dependencies, creates a global state problem, turns simple flows into ceremony, or makes control flow harder to trace, it is probably solving the wrong problem.

## Links

- Source: [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]]
- Related: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]

