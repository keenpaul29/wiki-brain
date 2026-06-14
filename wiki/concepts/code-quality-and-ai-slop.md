---
title: Code Quality and AI Slop Management
type: concept
created: 2026-06-14
tags:
  - concept
  - code-quality
  - refactoring
  - ai-slop
  - software-engineering
---

# Code Quality and AI Slop Management

Code quality has a new dimension in the AI era. Traditional code smells and refactoring techniques remain essential, but AI-generated code introduces a distinct category of quality problems: "slop" — plausible-looking code that is verbose, over-instrumented, architecturally misaligned, or substitutes volume for judgment.

## Traditional Code Smells

The five smell families from Refactoring Guru, ranked by frequency in real codebases:

### Bloaters (Most Common)

Code that has grown too large to work with effectively:

| Smell | Symptom | Refactoring |
|-------|---------|-------------|
| Long Method | Method does multiple things, needs scrolling | Extract Method |
| Large Class | Class has too many responsibilities | Extract Class |
| Long Parameter List | Hard to read, easy to misorder | Introduce Parameter Object |
| Data Clumps | Same group of fields passed around together | Extract Parameter Object |

### OO Abusers

Incomplete or incorrect application of object-oriented principles:

| Smell | Symptom | Refactoring |
|-------|---------|-------------|
| Switch Statements | Same switch/if-else chain in multiple places | Replace Conditional with Polymorphism |
| Temporary Field | Field set only in some code paths | Extract Class for the conditional logic |
| Refused Bequest | Subclass does not use inherited members | Replace Inheritance with Delegation |

### Change Preventers

Code that makes a single change require many modifications:

| Smell | Symptom | Refactoring |
|-------|---------|-------------|
| Divergent Change | One class changed for different reasons | Extract Class per concern |
| Shotgun Surgery | One change requires edits in many classes | Move Method, Move Field |
| Parallel Inheritance | Adding a subclass requires subclass in another hierarchy | Remove duplication via delegation |

### Dispensables

Code that is unnecessary and adds maintenance cost:

| Smell | Cost |
|-------|------|
| Duplicate Code | Every bug found in one copy must be fixed in all copies |
| Dead Code | Dead weight in compilation, analysis, and reading |
| Lazy Class | A class that does too little to justify its existence |
| Speculative Generality | Hooks, interfaces, and abstractions for features that never came |

### Couplers

Excessive coupling between classes:

| Smell | Refactoring |
|-------|-------------|
| Feature Envy | A method uses more features of another class than its own → Move Method |
| Message Chains | `a.getB().getC().getD()` → Hide Delegate |
| Middle Man | A class that mostly delegates to another → Remove Middle Man |

## AI-Specific Quality Problems

AI-generated code introduces distinct anti-patterns that traditional catalogs do not cover:

### Comment Slop

Generated comments that restate the code or encode prompt-debugging artifacts:

```python
# Bad: AI-generated comment that says nothing
# Check if user is admin
if user.role == 'admin':
    process_admin_request(request)

# Good: comment that explains WHY, not WHAT
# Admins bypass rate limiting during incident response
if user.role == 'admin':
    process_admin_request(request)
```

**Rule**: keep only comments that (a) prevent a repeated bug, (b) explain a non-obvious ordering constraint, or (c) document a design decision the code cannot express.

### Instrumentation Slop

LLMs tend to add excessive `print`, `log`, and diagnostic statements:

```python
# Bad: every function has entrance/exit logging
def process_order(order_id):
    logger.info(f"Starting process_order for {order_id}")
    result = _do_work(order_id)
    logger.info(f"Completed process_order for {order_id}: {result}")
    return result

# Good: log only at meaningful boundaries
def process_order(order_id):
    result = _do_work(order_id)
    logger.info(f"Order {order_id} processed: status={result.status}")
    return result
```

**Rule**: log at transitions (success, failure, degraded) not at function entry/exit. Remove debug prints after verification.

### Vibe Architecture

LLM-amplified architectural drift — the model does not know the system's architecture, so it generates code that fits the immediate prompt but not the overall design:

| Symptom | Description | Fix |
|---------|-------------|-----|
| Duplicated state | Same data stored in multiple places | Single source of truth |
| Race-prone startup | Code assumes initialization order | Explicit lifecycle management |
| Scattered handling | Input validation in every function | Centralized boundary validation |
| Unnecessary signals | Events fired that no consumer uses | Event audit |

**Root cause**: the LLM was not given the architecture context. When the state chart file dropped out of the prompt bundle, the model did not ask for it — it generated new behavior outside the intended architecture.

### Architecture Drift Multiplier

AI coding accelerates implementation speed, which multiplies the rate of architecture drift. A human writing one file per hour makes one architectural mistake per file. An AI writing ten files per hour makes ten mistakes per file. The review burden grows proportionally.

## Anti-Slop Pillars

Convert each discovered failure mode into a durable rule:

1. **Context completeness**: the prompt bundle must include architecture docs, state charts, type definitions, and conventions. The model must not guess.
2. **Human-owned architecture**: the engineer defines the architecture; the LLM implements within it. The LLM never defines new abstractions or patterns without human approval.
3. **Review gates**: every AI-generated file gets the same review as human-written code. No "trust but verify" — verify always.
4. **Anti-pattern rules file**: maintain a `CLAUDE.md` or equivalent that documents known anti-patterns, coding conventions, and quality rules. The LLM reads this before starting any task.
5. **No speculative generation**: the LLM should not add hooks, abstractions, or interfaces for features that are not in the current requirements.
6. **Instrumentation discipline**: development-time debug prints are removed before commit. Production logging follows the service's logging conventions.

## Refactoring Discipline

### Never Conflate Refactoring with Feature Work

A commit should either refactor or add features, never both. Mixing them makes:
- Code review harder (reviewer cannot distinguish structural changes from logic changes).
- Rollback riskier (reverting a feature also reverts the refactoring).
- Blame unclear (git bisect shows a giant commit).

### One Refactoring at a Time

Apply one refactoring transformation, verify with tests, then apply the next. A single refactoring should not change more than one thing.

### Test Coverage Before Refactoring

Before refactoring, ensure the code has adequate test coverage. If it does not, add characterization tests that capture current behavior before changing the structure.

## Expected vs Exceptional Failures

Distinguish between failures that are part of normal operation and failures that indicate a bug:

- **Expected failures**: validation errors, not-found, conflict, rate-limited. Use result types, not exceptions.
- **Exceptional failures**: network timeout, database connection lost, out of memory. Use exceptions, log them, alert on them.

This distinction matters because AI-generated code tends to throw exceptions for expected conditions (over-use of exceptions) or swallow exceptional conditions (blanket try-catch).

## Links

- Parent concept: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Related: [[concepts/software-design-patterns|Software Design Patterns]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/shared-engineering-language|Shared Engineering Language]]
- Source: [[sources/code-smells-refactoring-techniques|Code Smells and Refactoring Techniques]]
- Source: [[sources/exception-handling-patterns|Exception Handling Patterns]]
- Source: [[sources/ai-slop-game-refactor|Scrubbing AI Slop From a Game Codebase]]
- Source: [[sources/stop-feeding-me-ai-slop|Stop Feeding Me AI Slop]]
- Source: [[sources/code-cheap-judgement-not|AI Code Leverage and Engineering Judgement]]
- Source: [[sources/dont-outsource-learning|Don't Outsource the Learning]]
