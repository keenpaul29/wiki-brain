---
title: Stop Memorizing Design Patterns - Use This Decision Tree Instead
type: source
created: 2026-05-08
source: https://freedium-mirror.cfd/medium.com/womenintechnology/stop-memorizing-design-patterns-use-this-decision-tree-instead-e84f22fca9fa
tags:
  - source
  - software-design
  - design-patterns
---

# Stop Memorizing Design Patterns - Use This Decision Tree Instead

## Summary

This source reframes object-oriented design patterns as responses to concrete code pain rather than patterns to memorize. The decision tree starts by locating the friction: object creation, object structure, or behavior that changes across cases.

## Key Ideas

- A pattern is useful when it reduces recurring change cost, test brittleness, boundary leakage, constructor complexity, or duplicated logic.
- The decision tree enforces a first step before pattern choice: name the friction precisely, then pick the smallest abstraction that localizes it.
- Creational patterns fit construction pain: Builder for complex setup, Factory Method or Abstract Factory for context-based implementation selection, Prototype for cloning configured objects, and Singleton only for truly shared safe state.
- Structural patterns fit boundary and composition pain: Adapter for incompatible interfaces, Facade for safe subsystem access, Decorator for optional features, Proxy for stand-ins, Composite for trees, Flyweight for shared repeated state, and Bridge for independent dimensions of variation.
- Behavioral patterns fit changing rules and workflows: Chain of Responsibility for pipelines, Command for queueable or undoable actions, Strategy for swappable algorithms, State for mode-specific behavior, Observer for notifications, Memento for restore points, Mediator for coordination, and Visitor for operations over stable structures.
- Common applied scenarios include notification channel strategy, request middleware chains, and report-generation builders plus format strategies.
- The repeated warning is to avoid pattern-driven over-engineering; start from the pain and pick the smallest abstraction that localizes the cost.

## Links

- Connects to [[concepts/software-design-patterns|Software Design Patterns]] (decision tree and pattern selection)
- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]] (architecture patterns and component boundaries)
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] (human design judgment around generated code)
