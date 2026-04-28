---
title: Microservices vs. Monoliths
type: source
source_path: "raw/Microservices vs. Monoliths When to Choose What (and Why It Matters).md"
source_url: "https://medium.com/@SoftwareEngineering/microservices-vs-monoliths-when-to-choose-what-and-why-it-matters-6d2117d5d021"
author: "Software Engineering Guy!!"
published: 2025-01-07
created: 2026-04-28
tags:
  - source
  - architecture
  - system-design
---

# Microservices vs. Monoliths

## Summary

This source compares monoliths and microservices as situational architecture choices rather than status symbols. It argues that monoliths are often the right starting point for small or medium projects because they are easier to build, debug, deploy, and transact against when one team owns one codebase and one database.

Microservices become useful when an application, organization, or domain is large enough to justify independent service ownership, independent scaling, technology diversity, and fault isolation. The tradeoff is distributed-systems complexity: network calls, retries, observability, deployment automation, data consistency, and DevOps maturity.

The source's practical recommendation is to avoid treating microservices as a default upgrade. Start with a monolith when requirements, team boundaries, and scaling needs are still uncertain; extract services later around real domain or operational pressure.

## Key Ideas

- Start with a monolith when scope, team size, and scaling needs are still unclear.
- Consider microservices when different parts of the system need independent scaling, ownership, or technology choices.
- Microservices require serious investment in automation, containerization, orchestration, monitoring, and operational skill.
- Data consistency and inter-service communication are often the hidden costs.
- A hybrid path can start as a monolith and extract services only where boundaries and scaling pressure become real.
- In a monolith, local calls and single-database transactions keep early development simple.
- In microservices, network calls require resilience patterns such as retries and circuit breakers.

## Links

- Supports [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/reliability-and-operations|Reliability and Operations]]
