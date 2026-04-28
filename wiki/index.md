---
title: Wiki Index
type: index
created: 2026-04-28
updated: 2026-04-28
---

# Wiki Index

This wiki compiles the current `raw/` sources into linked notes about AI-assisted engineering, personal knowledge systems, learning practice, system design, and LLM architecture.

## Synthesis

- [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] - A synthesis tying together AI-era engineering judgment, structured learning, system design, and wiki-based knowledge management.

## Concepts

- [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]] - Capturing user corrections and turning repeated feedback into persistent agent rules.
- [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] - A persistent markdown knowledge base maintained by an LLM instead of one-off retrieval.
- [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] - The shift from syntax production toward architecture, debugging, accountability, and human alignment.
- [[concepts/structured-learning-and-retention|Structured Learning and Retention]] - Using curricula, practice, spaced repetition, and source synthesis to make learning compound.
- [[concepts/system-design|System Design]] - Principles, primitives, scaling patterns, and interview-style design workflows.
- [[concepts/system-design-interview-workflow|System Design Interview Workflow]] - A repeatable flow for requirements, estimates, data models, APIs, components, deep dives, and bottlenecks.
- [[concepts/infrastructure-primitives|Infrastructure Primitives]] - Networking, traffic, compute, delivery, and service-discovery building blocks.
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]] - Storage types, database families, replication, sharding, transactions, and consistency tradeoffs.
- [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]] - Monoliths, microservices, event-driven systems, queues, pub/sub, REST, GraphQL, gRPC, and realtime patterns.
- [[concepts/reliability-and-operations|Reliability and Operations]] - Availability, fault tolerance, rate limiting, circuit breakers, SLOs, disaster recovery, and identity/security.
- [[concepts/system-design-case-studies|System Design Case Studies]] - URL shortener, WhatsApp, Twitter, and Netflix design patterns.
- [[concepts/recurrent-depth-transformers|Recurrent-Depth Transformers]] - Looped transformer architectures, latent reasoning, stability, MoE breadth, and inference-time depth.

## Sources

- [[sources/llm-wiki-idea-file|LLM Wiki Idea File]] - The operating pattern for compiling raw sources into a living wiki.
- [[sources/karpathy-second-brain-article|Karpathy Second Brain Article]] - A popular explanation of Karpathy's LLM-built research wiki workflow.
- [[sources/ai-replaced-80-percent-coding|AI Replaced 80% of Coding]] - Seven human engineering skills that remain valuable as code generation becomes cheap.
- [[sources/learn-from-course-content|How to Learn from Course Content Without Paying for It]] - A learning strategy based on extracting structure from course curricula.
- [[sources/retaining-cs-knowledge|Retaining Computer Science Knowledge]] - A spaced repetition and practice workflow for retaining CS concepts.
- [[sources/system-design-course|System Design Course]] - A broad system design curriculum and set of large-scale design examples.
- [[sources/openmythos|OpenMythos]] - A speculative open-source reconstruction of a recurrent-depth transformer architecture.
- [[sources/self-evolving-hooks|Self-Evolving Hooks]] - A hook-based workflow for turning repeated user corrections into persistent agent rules.

## Maintenance Notes

- [[maintenance|Maintenance]] - Everyday workflow for ingesting, querying, and linting the wiki.
- [[automation|Daily Auto Update Workflow]] - Automated scan, ingest, link-check, and state-commit routine.
- Raw sources remain immutable in `raw/`.
- Wiki pages are generated and maintained in `wiki/`.
- On each ingest, update this index, add or revise source summaries, update relevant concept pages, and append to [[log]].
- Prefer backlinks like `[[concepts/system-design|System Design]]` when relating pages.
