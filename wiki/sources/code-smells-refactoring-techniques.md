---
title: "Code Smells and Refactoring Techniques"
type: source
created: 2026-06-06
source: https://refactoring.guru/refactoring/catalog
author: "Refactoring.Guru"
tags:
  - source
  - refactoring
  - code-quality
  - software-design
---

# Code Smells and Refactoring Techniques

## Summary

A comprehensive catalog of code smells organized into five families (bloaters, OO abusers, change preventers, dispensables, couplers) and the corresponding refactoring techniques (composing methods, moving features, organizing data, simplifying conditionals and method calls, dealing with generalization). Emphasizes operational discipline: identify smells during code review, apply one refactoring at a time with test verification, and never conflate restructuring with feature work.

## Key Ideas

- Five smell families: bloaters (Long Method, Large Class), OO abusers (Switch Statements, Temporary Field), change preventers (Shotgun Surgery, Divergent Change), dispensables (Duplicate Code, Dead Code, Lazy Class, Speculative Generality), couplers (Feature Envy, Message Chains, Middle Man).
- Extract Method is the most frequently useful refactoring: when a comment explains a block, extract it into a method named after the comment.
- Replace Conditional with Polymorphism eliminates switch/if-else chains on type codes.
- Replace Magic Number with Symbolic Constant is the simplest high-impact readability refactoring.
- Refactoring is restructuring without changing observable behavior — not feature work.

## Links

- Supports [[concepts/system-design|System Design]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[concepts/software-design-patterns|Software Design Patterns]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
