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
- [[concepts/system-design-case-studies|System Design Case Studies]] - URL shortener, WhatsApp, Twitter, Netflix, and GenAI shopping-assistant design patterns.
- [[concepts/recurrent-depth-transformers|Recurrent-Depth Transformers]] - Looped transformer architectures, latent reasoning, stability, MoE breadth, and inference-time depth.
- [[concepts/frontend-build-performance|Frontend Build Performance]] - Tree shaking, module-system migration, bundle footprint, and rollout strategy for frontend optimization.
- [[concepts/local-llm-serving|Local LLM Serving]] - Prefill/decode, KV cache, context length, scheduler, and observability patterns for local model serving.

## Sources

- [[sources/llm-wiki-idea-file|LLM Wiki Idea File]] - The operating pattern for compiling raw sources into a living wiki.
- [[sources/karpathy-second-brain-article|Karpathy Second Brain Article]] - A popular explanation of Karpathy's LLM-built research wiki workflow.
- [[sources/ai-replaced-80-percent-coding|AI Replaced 80% of Coding]] - Seven human engineering skills that remain valuable as code generation becomes cheap.
- [[sources/learn-from-course-content|How to Learn from Course Content Without Paying for It]] - A learning strategy based on extracting structure from course curricula.
- [[sources/retaining-cs-knowledge|Retaining Computer Science Knowledge]] - A spaced repetition and practice workflow for retaining CS concepts.
- [[sources/system-design-course|System Design Course]] - A broad system design curriculum and set of large-scale design examples.
- [[sources/openmythos|OpenMythos]] - A speculative open-source reconstruction of a recurrent-depth transformer architecture.
- [[sources/self-evolving-hooks|Self-Evolving Hooks]] - A hook-based workflow for turning repeated user corrections into persistent agent rules.
- [[sources/google-stitch-design-md-claude-code|Google Stitch design.md + Claude Code]] - Using an agent-readable design-system file to reduce UI drift in generated code.
- [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]] - A production GenAI assistant case study: domain LLM, RAG, feedback loops, and low-latency inference infra.
- [[sources/gpt-5-5-agents-replaced-python-backend|GPT-5.5 Agents Replaced My Python Backend]] - A selective agent-backend migration case study with deterministic boundaries.
- [[sources/microservices-vs-monoliths|Microservices vs. Monoliths]] - Architecture choice guidance for monolith-first, microservices, and hybrid extraction paths.
- [[sources/agent-skills-real-engineers|Agent Skills for Real Engineers]] - Small composable skills for aligning coding agents through questions, shared language, and ADRs.
- [[sources/stop-feeding-me-ai-slop|Stop Feeding Me AI Slop]] - A critique of AI-generated technical communication that lacks human judgment and distillation.
- [[sources/create-tunnel-dashboard|Create a tunnel (dashboard)]] - Cloudflare Tunnel setup via Zero Trust dashboard, publishing apps, or connecting private networks.
- [[sources/webpack-tree-shaking-performance|Improving Site Performance With Webpack Tree Shaking]] - Coursera's staged ES module migration and Webpack tree-shaking rollout for smaller bundles.
- [[sources/fastapi-0-115-migration|FastAPI 0.115 Migration Breakages]] - A production upgrade case covering stricter dependencies, response validation, CORS, WebSockets, background tasks, and rollout.
- [[sources/production-ai-failure-modes|Beyond Shipped - Production AI Failure Modes]] - Production AI risks around grounding, retrieval, latency, memory, agents, tools, security, cost, and evaluation.
- [[sources/claude-code-best-practices|Claude Code Best Practices]] - Agentic engineering patterns for scoped instructions, commands, agents, skills, hooks, context, worktrees, and verification.
- [[sources/claude-folder-structure|How to Structure .claude Folder]] - Organizing Claude Code instructions, settings, rules, hooks, commands, skills, agents, and local overrides.
- [[sources/podman-python-deploys|Podman for Faster Python Deploys]] - A Python deployment case study focused on container build speed, rootless operation, and systemd integration.
- [[sources/electron-screen-capture-protection|Electron Screen Capture Protection]] - OS-level and Electron window-management patterns for content-protected overlays and capture testing.
- [[sources/docker-image-security-optimization|Docker Image Security and Optimization]] - Multi-stage builds, lightweight bases, cacheable Dockerfiles, rootless mode, daemon protection, and image scanning.
- [[sources/local-llm-serving-mental-model|Local LLM Serving Mental Model]] - Prefill/decode, KV cache math, hidden queues, continuous batching, PagedAttention, and model loading phases.
- [[sources/local-llm-serving-operational-playbook|Local LLM Serving Operational Playbook]] - Context sizing, quantization, prefix caching, keep-alive, observability, benchmarking, and reverse-proxy controls.
- [[sources/rag-llm-wiki-gbrain|RAG, LLM Wiki, or GBrain]] - A comparison of retrieve, compile, and act memory architectures for agents.
- [[sources/stop-using-wrong-llm|Stop Using the Wrong LLM]] - A model-selection framework based on cognitive task fit and known unreliable task classes.
- [[sources/unlock-system-design-production|Unlock Production System Design Case Study]] - A rewards-platform outage and recovery showing why implementation skill and system design must reinforce each other.
- [[sources/ai-developer-cognitive-archetypes|AI Developer Cognitive Archetypes]] - A reflection framework for supportive, mixed, and risky AI use in developer workflows.
- [[sources/frontend-skills-2026|Frontend Skills Beyond React in 2026]] - TypeScript, App Router, Tailwind, AI UX, and performance skills beyond baseline React knowledge.

## Maintenance Notes

- [[maintenance|Maintenance]] - Everyday workflow for ingesting, querying, and linting the wiki.
- [[automation|Daily Auto Update Workflow]] - Automated scan, ingest, link-check, and state-commit routine.
- Raw sources remain immutable in `raw/`.
- Wiki pages are generated and maintained in `wiki/`.
- On each ingest, update this index, add or revise source summaries, update relevant concept pages, and append to [[log]].
- Prefer backlinks like `[[concepts/system-design|System Design]]` when relating pages.
