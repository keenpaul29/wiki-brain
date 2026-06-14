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

## Common Pitfalls (from Google L7)

[[sources/google-l7-system-design|Google L7 System Design Interview Insights]] identifies specific mistakes that even experienced candidates make:

- **Memorizing patterns instead of reasoning**: copying the Netflix tech stack or default-adding Redis/NoSQL to every design is a signal that the candidate cannot evaluate whether the tool fits the problem. The interview evaluates physics and constraints — latency, throughput, consistency — not pattern recall.
- **Horizontal scaling as default**: adding nodes increases coordination overhead and network hops. A single optimized vertical node can outperform a distributed cluster for many workloads. The right scaling strategy depends on the bottleneck, not on a preference for distributed systems.
- **Hot key and thundering herd blindness**: at massive scale (a viral URL shortener link), scaling out app servers can worsen database/cache row contention. Request collapsing (coalescing identical reads) or adaptive caching are needed, not more instances.
- **Cache utility math**: Effective Latency = (Hit Rate × Cache Latency) + ((1 − Hit Rate) × DB Latency). If 90% of items are read only once, a cache slows the system by adding checks before the database miss. Caching every query is worse than no cache.
- **No "right" answers, only tradeoffs**: Consistency vs. Availability, Latency vs. Cost, Complexity vs. Team Maintainability. The strongest interviews name these tradeoffs explicitly and choose based on the specific requirement constraints.

## Preparation Strategy

[[sources/system-design-study-roadmap|Curated System Design Study Roadmap]] recommends a structured approach against passive video consumption:

1. **Foundations**: System Design Primer for vocabulary and building blocks.
2. **Applied concepts**: Alex Xu volumes for worked design examples with tradeoff analysis.
3. **Pattern recognition**: designgurus.io for identifying repeated patterns across problems.
4. **Real depth**: company engineering blogs and High Scalability for real post-mortems.
5. **Calibration**: LeetCode System Design discussions for interview feedback.
6. **Verbal practice**: recorded mock interviews with live requirement extraction under time pressure.

Accumulating technical vocabulary without practicing verbal tradeoff reasoning under time pressure is the mistake most candidates make.

## Good Interview Habits

- Ask scope questions before designing.
- Write down assumptions explicitly before making decisions based on them.
- Start simple (single server), then scale. Name what breaks at each stage.
- Present tradeoffs instead of claiming one technology is always better. "We use X because the requirements need Y and the alternatives fail on Z."
- Spend detail time where the system is most constrained or most likely to fail.
- Use back-of-the-envelope calculations (QPS, storage, bandwidth) to validate choices rather than relying on intuition.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/system-design-case-studies|System Design Case Studies]]
- Source: [[sources/system-design-course|System Design Course]]
- Source: [[sources/system-design-study-roadmap|Curated System Design Study Roadmap]]
- Source: [[sources/google-l7-system-design|Google L7 System Design Interview Insights]]
- Source: [[sources/latency-gambler-day-1|Building the System Architect Mindset]]

