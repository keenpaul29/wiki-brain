---
title: System Design Interview Workflow
type: concept
created: 2026-04-28
tags:
  - concept
  - system-design
  - interviews
---

# System Design Interview Workflow

System design interviews test how a candidate turns a vague product prompt into a reasoned technical design. The source emphasizes that there is rarely one correct answer; the interview is a two-way conversation about requirements, constraints, tradeoffs, and bottlenecks.

## Workflow

1. Clarify requirements.
2. Estimate scale and constraints.
3. Design the data model.
4. Define APIs.
5. Sketch high-level components.
6. Drill into the risky or interesting parts.
7. Identify bottlenecks and failure modes.

## Requirement Types

- Functional requirements: user-visible behavior the system must support.
- Non-functional requirements: latency, availability, scalability, reliability, security, maintainability, and similar quality constraints.
- Extended requirements: nice-to-have features such as analytics, monitoring, or secondary product behaviors.

## Good Interview Habits

- Ask scope questions before designing.
- State assumptions explicitly.
- Start simple, then scale the design.
- Present tradeoffs instead of claiming one technology is always better.
- Spend detail time where the system is most constrained or most likely to fail.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Source: [[sources/system-design-course|System Design Course]]

