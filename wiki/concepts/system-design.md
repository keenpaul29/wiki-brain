---
title: System Design
type: concept
created: 2026-04-28
tags:
  - concept
  - system-design
---

# System Design

System design is the practice of defining architecture, interfaces, data, and operational behavior for a system that satisfies requirements. It is one of the main places where human engineering judgment remains valuable in AI-assisted software work.

## Design Flow

1. Clarify functional requirements.
2. Clarify non-functional requirements such as latency, availability, durability, throughput, cost, and consistency.
3. Estimate traffic, storage, bandwidth, and request rates.
4. Define APIs and data models.
5. Choose architecture and service boundaries.
6. Select storage, cache, communication, and delivery patterns.
7. Identify bottlenecks, single points of failure, and scaling paths.
8. Revisit tradeoffs as constraints change.

## Building Blocks

Important primitives from the source include IP, OSI layers, TCP/UDP, DNS, load balancing, caching, CDN, proxies, API styles, message brokers, databases, replication, sharding, consistency, rate limiting, service discovery, and observability.

## Subpages

- [[concepts/system-design-interview-workflow|System Design Interview Workflow]]
- [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- [[concepts/reliability-and-operations|Reliability and Operations]]
- [[concepts/system-design-case-studies|System Design Case Studies]]

## Link to AI-Era Work

The [[sources/ai-replaced-80-percent-coding|AI Replaced 80% of Coding]] source argues that architecture and distributed debugging are exactly where AI tools struggle. That makes system design practice a priority skill for working well with code-generation agents.

## Production Balance

Implementation skill and system design are complementary. The Unlock case study shows how a team can ship quickly with strong coding ability while still carrying hidden architecture risk: one instance, one database, no caching, no rate limits, no circuit breakers, and no observability. System design turns feature velocity into production durability by making scaling paths, failure modes, and operational controls explicit before traffic proves the gap.

## Caching and High-Scale Tradeoffs

Caching is a core primitive for low-latency scale, but it introduces consistency and load hazards:
- **Patterns**: Cache-Aside (lazy load), Read-Through, Write-Through (high consistency), Write-Back (high write performance, crash risk), and Write-Around (avoids cache pollution).
- **Pre-warming & Refresh**: Refresh-Ahead uses predictive models to refresh keys asynchronously before they expire.
- **Stampedes**: If hot keys expire under load, simultaneous database lookups can collapse backends. Mitigation involves locking, early probabilistic expiration, or background pre-warming.
- **Physics of Scale**: Adding nodes (horizontal scaling) is not a cure-all. It introduces coordination overhead, network hops, and row contention. High-scale design requires calculating cache hit rates (`Effective Latency = Hit Rate x Cache Latency + (1 - Hit Rate) x DB Latency`). If hit rates are low, caches slow down system performance.

## Active Study vs. Passive Watching

Mastering system design requires active mental model construction and tradeoff evaluation under pressure. Relying on passive video consumption leads to poor retention. Candidates should practice live mock sessions, QPS estimation, and reading engineering post-mortems to develop architect intuition.

## Access Pattern First

Even small data-structure choices follow system-design logic: start from access patterns. Pure membership checks point toward hash sets; mostly static ordered data can use sorted arrays and binary search; ordered range queries need tree-like structures; memory-constrained membership may justify probabilistic structures.

## Source Support

- [[sources/system-design-course|System Design Course]]
- [[sources/ai-replaced-80-percent-coding|AI Replaced 80% of Coding]]
- [[sources/unlock-system-design-production|Unlock Production System Design Case Study]]
- [[sources/dictionary-problem-fast-lookups|The Dictionary Problem - Fast Lookups in Large Collections]]
- [[sources/caching-patterns|Essential Caching Patterns and Strategies]]
- [[sources/google-l7-system-design|Google L7 System Design Interview Insights]]
- [[sources/system-design-study-roadmap|Curated System Design Study Roadmap]]

