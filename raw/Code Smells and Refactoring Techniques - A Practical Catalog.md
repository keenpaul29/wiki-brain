---
title: "Code Smells and Refactoring Techniques: A Practical Catalog"
source: "https://refactoring.guru/refactoring/catalog"
author:
  - "Refactoring.Guru"
published: 2026-06-06
created: 2026-06-06
description: "A comprehensive catalog of code smells and refactoring techniques organized by pattern families — bloaters, object-orientation abusers, change preventers, dispensables, couplers, and the refactoring techniques to fix each."
tags:
  - "clippings"
---

## Code Smells and Refactoring Techniques

### Code Smells

**Bloaters:** Code, methods, and classes that have grown to unmanageable proportions. Include Long Method, Large Class, Primitive Obsession, Long Parameter List, and Data Clumps. Usually accumulate over time when nobody makes an effort to eradicate them.

**Object-Orientation Abusers:** Incomplete or incorrect application of OOP principles. Include Switch Statements, Temporary Field, Refused Bequest, and Alternative Classes with Different Interfaces.

**Change Preventers:** Changes in one place force many changes elsewhere. Include Divergent Change, Shotgun Surgery, and Parallel Inheritance Hierarchies.

**Dispensables:** Pointless and unneeded elements whose removal would make code cleaner. Include Comments (used to explain bad code), Duplicate Code, Data Class, Dead Code, Lazy Class, and Speculative Generality.

**Couplers:** Excessive coupling or excessive delegation. Include Feature Envy, Inappropriate Intimacy, Message Chains, Middle Man, and Incomplete Library Class.

### Refactoring Techniques by Category

**Composing Methods:** Techniques for streamlining methods — the root of all evil is usually excessively long methods. Include Extract Method, Inline Method, Extract Variable, Inline Temp, Replace Temp with Query, Split Temporary Variable, Remove Assignments to Parameters, Replace Method with Method Object, and Substitute Algorithm.

**Moving Features Between Objects:** Safely moving functionality between classes, creating new classes, and hiding implementation details. Include Move Method, Move Field, Extract Class, Inline Class, Hide Delegate, Remove Middle Man, Introduce Foreign Method, and Introduce Local Extension.

**Organizing Data:** Data handling techniques that replace primitives with rich class functionality and untangle class associations. Include Self Encapsulate Field, Replace Data Value with Object, Change Value to Reference, Change Reference to Value, Replace Array with Object, Encapsulate Field, Encapsulate Collection, Replace Magic Number with Symbolic Constant, Replace Type Code with Class/Subclasses/State/Strategy, and Replace Subclass with Fields.

**Simplifying Conditional Expressions:** Techniques for complex conditionals. Include Decompose Conditional, Consolidate Conditional Expression, Consolidate Duplicate Conditional Fragments, Remove Control Flag, Replace Nested Conditional with Guard Clauses, Replace Conditional with Polymorphism, Introduce Null Object, and Introduce Assertion.

**Simplifying Method Calls:** Making method calls simpler and interfaces easier to understand. Include Rename Method, Add/Remove Parameter, Separate Query from Modifier, Parameterize Method, Introduce Parameter Object, Preserve Whole Object, Remove Setting Method, Replace Parameter with Explicit Methods/Call, Hide Method, Replace Constructor with Factory Method, Replace Error Code with Exception, and Replace Exception with Test.

**Dealing with Generalization:** Abstraction techniques for moving functionality along inheritance hierarchies. Include Pull Up Field/Method/Constructor Body, Push Down Field/Method, Extract Subclass/Superclass/Interface, Collapse Hierarchy, Form Template Method, Replace Inheritance with Delegation, and Replace Delegation with Inheritance.

### Operational Discipline

- Identify code smells during code review, not after the system is in production
- Apply one refactoring technique at a time and verify behavior with tests between each change
- Refactoring is not adding features — it is restructuring existing code without changing observable behavior
- Use the Replace Conditional with Polymorphism technique to eliminate switch/if-else chains on type codes
- Extract Method is the most frequently useful refactoring: when you see a comment explaining a block, extract that block into a method named after the comment
- Replace Magic Number with Symbolic Constant is the simplest high-impact refactoring for code readability
