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

## Back-of-the-Envelope Reference

Common estimates that ground design decisions:

| Calculation | Formula | Example |
|---|---|---|
| QPS from DAU | (DAU × avg_actions_per_user) / seconds_in_day | 100M DAU × 10 actions / 86400 ≈ 11.6K QPS |
| Peak QPS | avg_QPS × 5-10x peak factor | 11.6K × 5 ≈ 58K peak |
| Storage per day | QPS_write × avg_write_size | 1K writes/s × 1KB × 86400 ≈ 86 GB/day |
| Bandwidth | avg_response_size × QPS | 50KB × 10K QPS ≈ 500 MB/s |
| Cache memory | working_set × replication_factor | 10M objects × 1KB × 2 replicas ≈ 20 GB |

The interviewer cares about the reasoning, not the precise number. Rounding to orders of magnitude (10K QPS, 100 GB/day) is fine.

## Follow-Up Question Patterns

Interviewers probe depth through specific follow-up categories:

- **Failure modes**: "What happens when the database goes down?" — tests understanding of failover, degradation, and graceful fallback.
- **Scale leap**: "What breaks at 10x this traffic?" — tests whether the design has linear scaling or hits a hard wall.
- **Consistency choice**: "Can you use weaker consistency here?" — tests whether the candidate understands what the consistency tradeoff actually costs.
- **Cost sensitivity**: "This design costs too much. Where do you cut?" — tests ability to distinguish essential from nice-to-have.
- **Team topology**: "How many teams would need to own parts of this?" — tests Conway's Law awareness and organizational feasibility.

## Presenting Tradeoffs

The strongest interview responses follow a three-part structure:

1. **State the constraint**: "Our primary requirement is P99 latency under 100ms."
2. **Name the options**: "We could use in-memory cache (fast, expensive, lossy) or read replicas (slower, cheaper, consistent)."
3. **Choose with justification**: "I'll start with cache because the latency requirement is strict. If the cache miss rate exceeds 20%, we'll promote hot data to read replicas."

Avoid claiming one technology is universally superior. Every choice is a tradeoff; naming the tradeoff explicitly is the signal the interviewer looks for.

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

