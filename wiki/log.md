---
title: Wiki Log
type: log
created: 2026-04-28
updated: 2026-06-14
---

# Wiki Log

## [2026-06-14] ingest | Prod web app components, caching, gateway, message queues, event sourcing, monitoring, microservices, distributed systems, resilience, CDN, DB scaling, and security patterns

Processed 12 new raw sources: the Prod Web App overview and Days 10-20 of The Latency Gambler's system design series.

Added source summaries:

- [[sources/prod-web-application-components|Key Components of a Prod Web Application]] (CI/CD, DNS, LB, CDN, APIs, DBs, caches, queues, search, monitoring, alerting — the full production stack).
- [[sources/latency-gambler-day-10|Caching Patterns]] (cache-aside, write-through, write-behind, read-through, refresh-ahead, multi-level caching, invalidation, stampede prevention).
- [[sources/latency-gambler-day-11|API Gateway & Proxy Patterns]] (API gateway, forward/reverse proxy, token bucket/sliding window rate limiting, BFF, versioning).
- [[sources/latency-gambler-day-12|Message Queue Patterns]] (pub/sub, message queue vs topic, command pattern, DLQ, deduplication, priority queues).
- [[sources/latency-gambler-day-13|Event Sourcing & CQRS Patterns]] (event sourcing, CQRS, Saga pattern, event snapshotting, versioning, projection rebuilding).
- [[sources/latency-gambler-day-14|Monitoring & Observer Patterns]] (three pillars, observer-based monitoring, structured logging, distributed tracing, alerting with multi-channel notifications).
- [[sources/latency-gambler-day-15|Microservices Patterns]] (service registry/discovery, API gateway pattern, Bulkhead, Netflix OSS stack).
- [[sources/latency-gambler-day-16|Distributed System Patterns]] (leader election, Raft consensus, vector clocks, conflict detection and resolution).
- [[sources/latency-gambler-day-17|Resilience Patterns]] (retry with exponential backoff + jitter, layered timeouts, fallback chains, graceful degradation).
- [[sources/latency-gambler-day-18|Caching & CDN Patterns]] (multi-level cache hierarchy, cache warming, CDN edge patterns, cache stampede prevention, ETags).
- [[sources/latency-gambler-day-19|Database Scaling Patterns]] (read replicas, hash/range/geographic sharding, DB per service, hybrid real-world strategies).
- [[sources/latency-gambler-day-20|Security Patterns]] (defense in depth, JWT, OAuth 2.0, RBAC, ABAC, TLS, API key management, request signing).

Updated concept pages with new source references: [[concepts/system-design|System Design]], [[concepts/system-design-case-studies|System Design Case Studies]], [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]], [[concepts/reliability-and-operations|Reliability and Operations]], [[concepts/data-storage-and-consistency|Data Storage and Consistency]], [[concepts/infrastructure-primitives|Infrastructure Primitives]].

Updated [[index]], [[log]].

## [2026-06-06] ingest | Code smells, estimation, incident management, team topologies, hiring, time management, and backend performance

Processed 7 new raw sources covering entry-, mid-, and senior-level engineering topics:

- `raw/Code Smells and Refactoring Techniques - A Practical Catalog.md`
- `raw/Software Estimation Techniques - Story Points T-Shirt Sizing and Beyond.md`
- `raw/SRE Incident Management - From Detection to Blameless Postmortem.md`
- `raw/Team Topologies - Engineering Organization Design for Fast Flow.md`
- `raw/Structured Engineering Hiring - A Practical Guide.md`
- `raw/Developer Time Management - Deep Work GTD Calendar Blocking and Burnout Prevention.md`
- `raw/Backend Performance Engineering - Profiling Bottleneck Analysis and Optimization.md`

Added source summaries: [[sources/code-smells-refactoring-techniques|Code Smells and Refactoring Techniques]] (five smell families, refactoring categories, operational discipline), [[sources/software-estimation-techniques|Software Estimation Techniques]] (story points, Planning Poker, T-shirt sizing, Monte Carlo, affinity estimation), [[sources/sre-incident-management|SRE Incident Management]] (five-phase lifecycle, Incident Command System, blameless postmortem culture), [[sources/team-topologies-org-design|Team Topologies: Engineering Organization Design]] (four team types, three interaction modes, Conway's Law, TVP), [[sources/structured-engineering-hiring|Structured Engineering Hiring]] (rubric scoring, behavioral/hypothetical questions, score-first debrief, bias mitigation), [[sources/developer-time-management|Developer Time Management]] (deep work, GTD, calendar blocking, burnout prevention, 12-item checklist), and [[sources/backend-performance-engineering|Backend Performance Engineering]] (performance budgets, profiling, load testing, N+1 fixes, indexing strategy, caching).

Created new concept page: [[concepts/team-topologies|Team Topologies]] (org design with stream-aligned, enabling, complicated-subsystem, and platform team types).

Updated concept pages:
- [[concepts/reliability-and-operations|Reliability and Operations]]: added SRE Incident Management section (incident lifecycle, ICS roles, on-call, blameless postmortem, action item discipline) and Backend Performance Engineering section (performance budgets, profiling, load testing types, database optimization, caching).
- [[concepts/career-growth-meta-skills|Career Growth and Meta-Skills]]: added Developer Time Management section (deep work, GTD, calendar blocking, maker vs manager, burnout prevention) and Structured Engineering Hiring section (rubric-based interviews, process design, bias mitigation).
- [[concepts/system-design-case-studies|System Design Case Studies]]: added three new case studies — Code Smells and Refactoring (smell families, Extract Method, Replace Conditional with Polymorphism), Software Estimation (relative sizing, Planning Poker, Monte Carlo, affinity estimation), Backend Performance Engineering (profiling, load testing, N+1 fixes, indexing, connection pooling, caching).

Added content to [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] with a coverage analysis across entry (time management), mid (refactoring, estimation, performance), and senior (incident mgmt, org design, hiring) levels.

Updated [[index]], [[log]].

## [2026-06-06] ingest | Observability, Postgres indexing, Raft, integration testing, and CI/CD pipelines

Processed new raw sources:

- `raw/Observability in Distributed Systems - Logs, Metrics and Traces.md`
- `raw/PostgreSQL Advanced Indexing - GIN, GiST, BRIN, and Partial Index.md`
- `raw/Raft Consensus Explained for Engineers.md`
- `raw/Integration Testing with Real Services - A Pragmatic Guide.md`
- `raw/Building a Bulletproof CI CD Pipeline.md`

Added source summaries: [[sources/observability-in-distributed-systems|Observability in Distributed Systems]] (three pillars, four golden signals, OpenTelemetry, SLO burn-rate alerting), [[sources/postgresql-advanced-indexing|PostgreSQL Advanced Indexing Guide]] (GIN, GiST, BRIN, Partial, Expression indexes with operational discipline), [[sources/raft-consensus-explained|Raft Consensus Explained]] (leader election, log replication, ConflictTerm backtracking, quorum math, production etcd operations), [[sources/integration-testing-real-services|Testing with Real Services]] (Testcontainers, Toxiproxy, clean-before strategy, 50/40/10 coverage pyramid), and [[sources/bulletproof-ci-cd-pipeline|Building a Bulletproof CI/CD Pipeline]] (trunk-based development, immutable artifacts, deployment strategies, DORA metrics).

Added 4 new case studies to [[concepts/system-design-case-studies|System Design Case Studies]]: Observability Diagnosis Workflow, Raft Consensus, Integration Testing with Real Services, and Bulletproof CI/CD Pipeline. Expanded [[concepts/data-storage-and-consistency|Data Storage and Consistency]] with a PostgreSQL Advanced Indexing section covering all six index types. Added Observability and CI/CD Pipeline Reliability sections to [[concepts/reliability-and-operations|Reliability and Operations]]. Updated [[concepts/system-design|System Design]] with four new building blocks and eight new case study references. Updated [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], [[index]], and [[log]].

## [2026-06-06] ingest | API protocol decision framework and image transformations

Processed new raw sources:

- `raw/REST vs GraphQL vs gRPC Which Should You Actually Use.md`
- `raw/Image Transformations for Developers.md`

Added source summaries: [[sources/rest-vs-graphql-vs-grpc|REST vs GraphQL vs gRPC]] (protocol comparison with benchmarks and layered architecture decision framework) and [[sources/image-transformations-for-developers|Image Transformations for Developers]] (Cloudinary URL-based dynamic image transformation model with CDN caching, smart cropping, and automatic format selection).

Added two new case studies to [[concepts/system-design-case-studies|System Design Case Studies]]: API Protocol Decision Framework (layered REST/GraphQL/gRPC architecture) and Cloudinary Image Transformations (CDN-based on-the-fly media transformation). Expanded [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]] with the API decision framework and updated [[concepts/infrastructure-primitives|Infrastructure Primitives]] with dynamic media CDN patterns. Updated [[concepts/system-design|System Design]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-06-05] ingest | Storage, realtime transport, and CDN delivery

Processed new/changed raw sources:

- `raw/Byte Storage vs. IO.md`
- `raw/Intro to WebSockets.md`
- `raw/Netflix's CDN Strategy Delivering Video to 300M Users Instantly.md`
- `raw/What Really Makes a Succesful Software Engineer.md` (changed)

Added source summaries for storage capacity vs. I/O performance, WebSocket realtime communication, and Netflix Open Connect CDN delivery. Refreshed the successful-software-engineer summary with the planning-before-PR-review point.

Updated [[concepts/data-storage-and-consistency|Data Storage and Consistency]], [[concepts/infrastructure-primitives|Infrastructure Primitives]], [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]], [[concepts/system-design-case-studies|System Design Case Studies]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-06-04] ingest | Engineering learning and Meta-scale case studies

Processed new raw sources:

- `raw/70+ Engineering Blogs To Follow in 2025.md`
- `raw/Going from Junior - Senior engineer in 2 years.md`
- `raw/Rust at Scale An Added Layer of Security for WhatsApp.md`
- `raw/Scaling the Instagram Explore recommendations system.md`
- `raw/What Really Makes a Succesful Software Engineer.md`

Added source summaries for engineering-blog reading streams, junior-to-senior career growth, WhatsApp's Rust media-security rollout, Instagram Explore recommendations, and passive software-engineering success skills.

Created new concept pages: [[concepts/career-growth-meta-skills|Career Growth and Meta-Skills]], [[concepts/memory-safety-strategy|Memory Safety and Defense-in-Depth]], and [[concepts/ml-recommendation-systems|ML Recommendation Systems at Scale]].

Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/structured-learning-and-retention|Structured Learning and Retention]], [[concepts/shared-engineering-language|Shared Engineering Language]], [[concepts/system-design|System Design]], [[concepts/system-design-case-studies|System Design Case Studies]], [[concepts/infrastructure-primitives|Infrastructure Primitives]], [[concepts/reliability-and-operations|Reliability and Operations]], [[concepts/data-storage-and-consistency|Data Storage and Consistency]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-06-01] ingest | Agents, transport, data projections, and fork migration

Processed new/changed raw sources:

- `raw/Escaping the Fork How Meta Modernized WebRTC Across 50+ Use Cases.md`
- `raw/How I Scrubbed 100% of the AI Slop From My Game & Cut Code by 45%.md`
- `raw/Learn System Design With Me . Day 7 Chain of Responsibility & State Patterns .  by The Latency Gambler.md` (changed)
- `raw/Learn System Design With Me . Day 8 Load Balancing & Circuit Breaker….md`
- `raw/Learn System Design With Me . Day 9 Database Patterns & Repository P….md`
- `raw/The last year of localhost.md`
- `raw/The Packet Drop That Froze Three Requests at Once.md`
- `raw/The Read That Was Killing the Write.md`
- `raw/Your Database Has Been Writing an Event Log the Whole Time.md`

Added source summaries for Meta's WebRTC dual-stack fork migration, AI slop cleanup in a Godot game, cloud development environments for background agents, QUIC/HTTP3 head-of-line blocking, CQRS read/write separation, and CDC over database transaction logs. Preserved the existing Day 7-9 Latency Gambler summaries and linked the newly scanned Day 8-9 raw sources.

Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/infrastructure-primitives|Infrastructure Primitives]], [[concepts/reliability-and-operations|Reliability and Operations]], [[concepts/data-storage-and-consistency|Data Storage and Consistency]], [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]], [[concepts/software-design-patterns|Software Design Patterns]], [[concepts/system-design|System Design]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-25] ingest | AI learning posture refresh

Processed changed raw source:

- `raw/Don't Outsource the Learning.md`

Refreshed [[sources/dont-outsource-learning|Don't Outsource the Learning]] with stronger study-backed evidence, the order-of-operations risk from early LLM problem framing, and the point that learning-oriented AI modes are useful for experienced engineers entering unfamiliar domains. Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/structured-learning-and-retention|Structured Learning and Retention]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-19] decision | Shared engineering language page

Decision: yes, the wiki should maintain a shared engineering language page, similar to a lightweight `CONTEXT.md`, for recurring project terms and durable engineering decisions.

Added [[concepts/shared-engineering-language|Shared Engineering Language]] with initial definitions for raw sources, wiki pages, source summaries, concept pages, synthesis pages, project operating architecture, brain/source routing, ship-and-learn, and context-first workflow. Updated [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] and [[index]].

## [2026-05-19] ingest | AI coding learning ownership

Processed new raw source:

- `raw/Don't Outsource the Learning.md`

Added [[sources/dont-outsource-learning|Don't Outsource the Learning]] for Addy Osmani's warning that AI coding workflows can trade present-day speed for future engineering capability when engineers skip hypothesis formation, explanation, review, and reconstruction. Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/structured-learning-and-retention|Structured Learning and Retention]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-04-28] ingest | Initial raw source compilation

Processed the initial source set:

- `llm-wiki.md`
- `AI Replaced 80% of Coding - Master These 7 Skills Instead. by Prakash Sharma.md`
- `Andrej Karpathy Stopped Using AI to Write Code. He's Using It to Build a Second Brain Instead by Nikhil in Neural Notions.md`
- `How to Learn from Course Content Without Paying for It.md`
- `Learn how to design systems at scale and prepare for system design interviews.md`
- `OpenMythos - a theoretical reconstruction of the Claude Mythos architecture, built from first principles using the available research literature.md`
- `Retaining Computer Science Knowledge.md`

Created initial index, source summaries, concept pages, and synthesis page. Main cross-source theme: use AI to reduce mechanical work, but preserve human judgment through structured learning, system design practice, source-grounded knowledge compilation, and accountability.

## [2026-04-28] ingest | Expanded system design course map

Expanded the broad [[sources/system-design-course|System Design Course]] into six reference pages:

- [[concepts/system-design-interview-workflow|System Design Interview Workflow]]
- [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- [[concepts/reliability-and-operations|Reliability and Operations]]
- [[concepts/system-design-case-studies|System Design Case Studies]]

Updated [[index]], [[concepts/system-design|System Design]], and [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] to make these pages navigable.

## [2026-04-28] ingest | Self-Evolving Hooks and daily automation workflow

Added workflow support for daily updates:

- Created `scripts/update-wiki-state.ps1` to scan `raw/`, compare source hashes, and write `wiki/_state/daily-scan.md`.
- Created [[automation]] to document the automated daily scan, ingest, link-check, and state-commit routine.
- Created `AGENTS.md` so future Codex sessions know the wiki-maintenance workflow.

Ingested `raw/Self-Evolving Hooks.md` as [[sources/self-evolving-hooks|Self-Evolving Hooks]] and added [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]. Updated [[index]], [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]], and [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]].

## [2026-04-28] ingest | Design specs for agents + Rufus engineering notes

Processed new/changed raw sources:

- `raw/How to Use Google Stitch's Design.md File with Claude Code for Consistent UI.md`
- `raw/The technology behind Amazon’s GenAI-powered shopping assistant, Rufus.md`
- `raw/Self-Evolving Hooks.md` (updated)

Added new source summaries: [[sources/google-stitch-design-md-claude-code|Google Stitch design.md + Claude Code]] and [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]]. Updated [[sources/self-evolving-hooks|Self-Evolving Hooks]] to better reflect the hook roles.

Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] and [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] with the "persistent context file" pattern, and expanded [[concepts/infrastructure-primitives|Infrastructure Primitives]] with inference-at-scale notes from Rufus. Updated [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] and [[index]] accordingly.

## [2026-04-28] ingest | Rufus production assistant case study

Processed changed source:

- `raw/The technology behind Amazon's GenAI-powered shopping assistant, Rufus.md`

Refined [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]] with source metadata and additional details on public-web data, Stores APIs, response hydration, and upstream data pipelines. Expanded [[concepts/system-design-case-studies|System Design Case Studies]] with a GenAI shopping-assistant case study covering domain model adaptation, RAG, feedback loops, accelerator-backed inference, continuous batching, and streaming structured UX. Updated [[index]].

## [2026-04-28] ingest | Agent backend boundaries, architecture choice, and AI communication quality

Processed new raw sources:

- `raw/GPT-5.5 Agents Replaced My Python Backend. 83% Cost Cut.  by inprogrammer.md`
- `raw/Microservices vs. Monoliths When to Choose What (and Why It Matters).md`
- `raw/Skills for Real Engineers. Straight from my .claude directory.md`
- `raw/Stop Feeding Me AI Slop.md`

Added source summaries: [[sources/gpt-5-5-agents-replaced-python-backend|GPT-5.5 Agents Replaced My Python Backend]], [[sources/microservices-vs-monoliths|Microservices vs. Monoliths]], [[sources/agent-skills-real-engineers|Agent Skills for Real Engineers]], and [[sources/stop-feeding-me-ai-slop|Stop Feeding Me AI Slop]].

Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] with agent boundary and communication-quality notes, [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]] with monolith-vs-microservices guidance, [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] with shared-language and anti-slop rules, [[concepts/system-design-case-studies|System Design Case Studies]] with an agent-backed backend slice, [[concepts/reliability-and-operations|Reliability and Operations]] with agent observability notes, [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-04-28] maintenance | Link-check script

Added `scripts/check-wiki-links.ps1` so wiki link validation is a reusable command instead of an inline snippet in [[automation]]. Updated [[maintenance]] and `README.md` with the command.

## [2026-04-28] maintenance | LLM wiki source refinement

Re-read `llm-wiki.md` and expanded [[sources/llm-wiki-idea-file|LLM Wiki Idea File]] with the human/LLM role split, broader application areas, query-output formats, optional tooling, and practical Obsidian notes. Updated [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] and [[maintenance]] to reflect those operating details.

## [2026-04-28] ingest | Microservices source metadata refresh

Re-read `raw/Microservices vs. Monoliths When to Choose What (and Why It Matters).md`, added source metadata and missing operational details to [[sources/microservices-vs-monoliths|Microservices vs. Monoliths]], and linked its retry/circuit-breaker implications into [[concepts/reliability-and-operations|Reliability and Operations]].

## [2026-04-28] maintenance | Orphan-page lint script

Added `scripts/lint-wiki.ps1` to detect orphan wiki pages with no inbound links (excluding index/log/workflow/state pages). Updated [[automation]], [[maintenance]], and `README.md` with the command.

## [2026-05-02] ingest | Cloudflare Tunnel source

Processed new raw source:

- `raw/Create a tunnel (dashboard).md`

Added [[sources/create-tunnel-dashboard|Create a tunnel (dashboard)]] documenting Cloudflare Tunnel setup via Zero Trust dashboard. Connected to [[concepts/infrastructure-primitives|Infrastructure Primitives]] and [[concepts/reliability-and-operations|Reliability and Operations]]. Updated [[index]].

## [2026-05-05] ingest | Webpack tree shaking and tunnel refresh

Processed new/changed raw sources:

- `raw/Improving Site Performance With Webpack Tree Shaking.md`
- `raw/Create a tunnel (dashboard).md`

Added [[sources/webpack-tree-shaking-performance|Improving Site Performance With Webpack Tree Shaking]] and [[concepts/frontend-build-performance|Frontend Build Performance]] for ES module migration, tree shaking requirements, codemod review, and incremental performance rollout. Refreshed [[sources/create-tunnel-dashboard|Create a tunnel (dashboard)]] with current dashboard flow, published application/private network options, Access policy note, and connector health states. Updated [[concepts/infrastructure-primitives|Infrastructure Primitives]], [[concepts/reliability-and-operations|Reliability and Operations]], [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-05] ingest | Production AI, local LLMs, agent memory, containers, and frontend skills

Processed new raw sources:

- `raw/A FastAPI Update Broke My Production App. Here Is the Fix.  by inprogrammer  in Artificial Intelligence in Plain English.md`
- `raw/Beyond Shipped What Actually Breaks in Production AI.md`
- `raw/Claude Code Best Practices 12 Patterns Agentic Engineers Use  by huizhou92  in Level Up Coding.md`
- `raw/Docker Was Slowing My Deploys. Podman Fixed It in 45 Seconds.  by inprogrammer.md`
- `raw/How I Made a Desktop App Invisible to Screen Sharing (Electron + OS-Level Tricks).md`
- `raw/How to Secure and Optimize Docker images  Best Practices.md`
- `raw/I Deployed Local LLMs in Production for a Year. Part 1 The Mental Model  by Mustafa Genc  in AI Advances.md`
- `raw/I Deployed Local LLMs in Production for a Year. Part 2 The Operational Playbook  by Mustafa Genc  in AI Advances.md`
- `raw/RAG, LLM Wiki, or Gbrain -  How Your Agent Remembers Changes Everything.md`
- `raw/Stop Using the Wrong LLM  by Jose Crespo, PhD  in AI Advances.md`
- `raw/tech skills vs system design Unlock case study in Production.md`
- `raw/The 4 Cognitive Archetypes of Developers Using AI.md`
- `raw/Top Skills Frontend Developers Need in 2026 (Beyond React)  by Kevin - MERN Stack Developer.md`

Added source summaries for FastAPI migration risk, production AI failure modes, Claude Code practices, Podman deploys, Electron screen-capture protection, Docker image security, local LLM serving mental model and operations, RAG/wiki/GBrain memory architectures, LLM task-fit selection, the Unlock system-design case study, AI developer cognitive archetypes, and frontend skills beyond React.

Created [[concepts/local-llm-serving|Local LLM Serving]]. Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/reliability-and-operations|Reliability and Operations]], [[concepts/infrastructure-primitives|Infrastructure Primitives]], [[concepts/system-design|System Design]], [[concepts/system-design-case-studies|System Design Case Studies]], [[concepts/frontend-build-performance|Frontend Build Performance]], [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]], [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]], [[concepts/structured-learning-and-retention|Structured Learning and Retention]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-05] ingest | Claude folder structure and Unlock refresh

Processed new/changed raw sources:

- `raw/How to Structure .claude Folder for Maximum Efficiency.md`
- `raw/tech skills vs system design Unlock case study in Production.md`

Added [[sources/claude-folder-structure|How to Structure .claude Folder]] for Claude Code project structure: root instructions, `.claude/settings.json`, modular rules, hooks, commands, skills, agents, and local overrides. Refreshed [[sources/unlock-system-design-production|Unlock Production System Design Case Study]] with source publication metadata and a sharper note on the false dichotomy between implementation skill and system design. Updated [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]], [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-08] ingest | Remote AI, AI safety, wiki cadence, patterns, and lookup structures

Processed new raw sources:

- `raw/Enhance productivity with AI + Remote Dev.md`
- `raw/How To Build An AI Brain That Never Forgets.md`
- `raw/How to Use AI at Work Without Breaking Your Systems.md`
- `raw/Stop Memorizing Design Patterns Use This Decision Tree Instead  by Alina Kovtun✨  in Women in Technology.md`
- `raw/The Dictionary Problem Fast Lookups in Large Collections.md`

Added source summaries for AI-aware remote development, local AI brain architecture, workplace AI safety guardrails, design-pattern selection, and dictionary lookup data structures. Created [[concepts/software-design-patterns|Software Design Patterns]]. Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]], [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]], [[concepts/reliability-and-operations|Reliability and Operations]], [[concepts/data-storage-and-consistency|Data Storage and Consistency]], [[concepts/system-design|System Design]], [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-09] ingest | Context-first AI coding and exception handling patterns

Processed new/changed raw sources:

- `raw/How I Get 100% Out of AI When Coding — The Workflow Nobody Taught Me  by Udara Abeythilake  in Level Up Coding.md`
- `raw/Junior Devs Use try-catch Everywhere. Senior Devs Use These 4 Exception Handling Patterns.md`
- `raw/Stop Memorizing Design Patterns Use This Decision Tree Instead  by Alina Kovtun✨  in Women in Technology.md` (changed)

Added new source summaries: [[sources/ai-coding-workflow-context-first|Context-First AI Coding Workflow]] and [[sources/exception-handling-patterns|Exception Handling Patterns Over Blanket try-catch]]. Refreshed [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]] with stronger decision-tree framing and applied scenarios.

Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/reliability-and-operations|Reliability and Operations]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]] to integrate planning-first AI execution and explicit expected-vs-exceptional failure handling.

## [2026-05-14] architecture | Project, wiki, GBrain, and sync architecture pass

Modified the project architecture across four layers:

- Added `docs/architecture/project-operating-architecture.md` as the canonical local operating architecture.
- Added [[concepts/project-operating-architecture|Project Operating Architecture]] to the wiki and linked it from [[index]].
- Updated [[automation]] so wiki maintenance ends by syncing the attached GBrain source `brain`.
- Updated `BRAIN_CONTEXT.md`, `SESSION_HANDOFF.md`, `GBRAIN_DEV_WORKFLOW.md`, and `AGENTS.md` with the new source-routing and handoff model.
- Refactored source-scoped sync/import so `sourceId` is carried into page, version, tag, and chunk writes instead of only being used for sync bookmarks.

Verification: `bun run typecheck` and `bun test --timeout 180000 test/sync.test.ts` passed.

## [2026-05-26] ingest | 23 new sources, software design patterns, and CLI/Git productivity

Processed 23 new raw sources:

- 10 no-code AI platforms, caching patterns, cheap code vs. judgment shift, end of legacy code through AI behavior testing, agent harness components, multi-agent frameworks (Kensho, Madrigal, Remote), Snapchat Bento prediction architecture, Netflix multimodal video search, and monolith-to-service migration patterns.
- Version control and terminal tips: effective Git (bisect, worktrees, reflogs, interactive staging) and terminal efficiency hacks.
- Google L7 system design URLs, Rust WAF firewalls, and active study roadmaps.

Created [[concepts/command-line-and-git-productivity|Command-Line and Git Productivity]].
Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]], [[concepts/system-design|System Design]], [[concepts/system-design-case-studies|System Design Case Studies]], [[concepts/software-design-patterns|Software Design Patterns]], and [[index]].

Verification: Verified all links resolved and committed raw scanner state. Sync'd DB source `brain`.

## [2026-05-27] ingest & fix | Day 7 Ingestion, Sync Exclusions & Windows Test Fixes

Processed 1 new raw source:
- `raw/Learn System Design With Me . Day 7 Chain of Responsibility & State Patterns .  by The Latency Gambler.md`

Created [[sources/latency-gambler-day-7|Chain of Responsibility & State Patterns]] summary.
Updated [[concepts/software-design-patterns|Software Design Patterns]] with Chain of Responsibility and State Pattern descriptions, and linked Day 7.
Updated [[index]] to list the new source.

Fixed sync and test bugs:
- Added `test` and `tests` directories to the sync/import walkers to prevent indexing of test fixtures (resolved `SLUG_MISMATCH` blocks in `bun run pull`).
- Resolved Windows-specific path separator issues and skipped privilege-restricted symlink tests in `test/sync-walker-symlink.test.ts`.

Verification: Checked that `bun test test/sync-walker-symlink.test.ts` runs clean on Windows and `bun run pull` successfully completes.

## [2026-06-01] ingest | AI coding workflow, Dropbox Nova, LinkedIn search & FishDB deep dives

Processed 7 new raw sources:

- `raw/Beyond code generation rethinking engineering productivity in the age of AI agents.md`
- `raw/Building collaborative prompt engineering playgrounds using Jupyter Notebook.md`
- `raw/FishDB - a generic retrieval engine for scaling LinkedIn's feed.md`
- `raw/How Edison is helping us build a faster, more powerful Dropbox on the web.md`
- `raw/I'm a 10x Dev. Here's How I Use a $250Month LLM To Code 250% Faster Without Generating "Slop".md`
- `raw/Reimagining LinkedIn's search tech stack.md`
- `raw/The 58-Million-Key Freeze What a HashMap Resize Taught Us About Memory Allocation at Scale.md`

Added source summaries for Dropbox's Nova agent platform (1-in-12 PRs agent-produced, bottleneck shift from generation to review/testing), LinkedIn's collaborative Jupyter prompt engineering playgrounds, FishDB Rust-based feed retrieval engine, Dropbox Edison local-first sync engine for the web, structured LLM coding without slop, LinkedIn's GPU-accelerated semantic search rebuild, and the HashMap → `mmap_lock` → async runtime freeze case study at 58.7M keys.

Created [[concepts/fishdb|FishDB]] and [[concepts/local-first-architecture|Local-First Architecture]].

Updated **11 concept pages** with cross-source synthesis:

- [[concepts/system-design-case-studies|System Design Case Studies]] — added 5 new case studies: Dropbox Nova (agent platform), Dropbox Edison (local-first sync), FishDB (feed retrieval engine), LinkedIn semantic search (GPU EBR), HashMap freeze (cross-layer debugging).
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]] — added specialized index structures (B-tree, bit-sliced, inverted with skip lists), vector embeddings and EBR, client-side IndexedDB storage.
- [[concepts/infrastructure-primitives|Infrastructure Primitives]] — added storage engine design (document model, allocator interaction, async runtime coupling), client-side sync infrastructure.
- [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]] — added local-first communication patterns (BroadcastChannel, WebSocket sync, optimistic UI) and EBR pipeline stages.
- [[concepts/reliability-and-operations|Reliability and Operations]] — added traffic shaping/ranking controllers and conflict resolution/offline resilience.
- [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] — added bottleneck-shift, collaborative prompt engineering, structured LLM coding workflow, GPU semantic search sections.
- [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]] — added production agent platform section (Dropbox Nova, 4-stage measurement model).
- [[concepts/structured-learning-and-retention|Structured Learning and Retention]] — added speed-vs-retention tension in AI-assisted coding.
- [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] — added collaborative notebooks as prompt engineering surface, agent-produced content as wiki source material.
- [[concepts/shared-engineering-language|Shared Engineering Language]] — added 5 new terms: bottleneck shift, slop, collaborative prompt engineering playground, local-first sync engine, Fuel→Adoption→Output→Impact.
- [[concepts/system-design|System Design]] — added deeper sub-concepts (FishDB, Local-First Architecture) and 4 new case study references.

Updated [[index]].

Deep content pass:
- Updated [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] with full synthesis of all 7 new sources — bottleneck-shift insight, local-first architecture, FishDB+Rust+Tokio case study, GPU semantic search, collaborative prompt engineering, cross-layer debugging. Added FishDB and Local-First Architecture to the system design study spine.
- Added concept-to-concept cross-links across 6 pages: `system-design` (sub-concept links), `infrastructure-primitives` (→ fishdb, local-first-architecture), `data-storage-and-consistency` (→ fishdb, local-first-architecture), `system-design-interview-workflow` (→ infrastructure-primitives, comm-patterns, case-studies), `frontend-build-performance` (→ system-design), `recurrent-depth-transformers` (→ ai-era-software-engineering, llm-maintained-wiki).
- Verified bidirectional integrity: all 77 sources referenced by ≥1 concept page, all concept pages reference ≥1 source (except project-operating-architecture, which is internal architecture).

Cross-reference pass over all 77 source summaries:
- Fixed orphan `electron-screen-capture-protection` → linked to [[concepts/reliability-and-operations|Reliability and Operations]].
- Expanded thin source references: `learn-from-course-content`, `llm-wiki-idea-file`, and all 7 new summaries now link to 3-6 concept pages each (was 1-2).
- Added missing source backlinks to `system-design-interview-workflow` (added `system-design-study-roadmap`, `google-l7-system-design`, `latency-gambler-day-1`).

## [2026-05-27] ingest | Day 8 and Day 9 Ingestion

Processed 2 new raw sources:
- `raw/Learn System Design With Me . Day 8 Load Balancing & Circuit Breaker….md`
- `raw/Learn System Design With Me . Day 9 Database Patterns & Repository P….md`

Created source summaries:
- [[sources/latency-gambler-day-8|Load Balancing & Circuit Breaker Patterns]]
- [[sources/latency-gambler-day-9|Database Patterns & Repository Pattern]]

Updated concept pages:
- [[concepts/reliability-and-operations|Reliability and Operations]] with load balancing strategies, circuit breaker states, and fallback resilience patterns.
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]] with the Repository Pattern, Connection Pools, and Connection Factories.

Updated [[index]] to list the new sources.

## [2026-06-14] deep analysis | Coverage gap analysis, 5 new concept pages, deep content expansion

Analyzed coverage gaps from the 12 Latency Gambler (Days 10-20) + Prod Web App sources. Identified that while individual patterns were captured by existing concept pages, no pages existed for five cross-cutting topic clusters.

Created 5 new concept pages:

- [[concepts/api-management|API Management and Gateway Patterns]] — API gateways, forward/reverse proxies, rate limiting (token bucket, sliding window), BFF, API versioning, and protocol mediation.
- [[concepts/distributed-coordination|Distributed Coordination and Consensus]] — Leader election, Raft consensus details (term, quorum, log replication, ConflictTerm backtracking), Vector clocks, gossip protocols, ZooKeeper/etcd patterns.
- [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]] — Retry with exponential backoff + jitter, circuit breaker (closed/open/half-open), bulkhead isolation, timeout budgets, fallback chains, graceful degradation, and layered resilience stack.
- [[concepts/security-patterns|Security Patterns]] — Defense in depth, JWT structure and validation, OAuth 2.0 grant types, RBAC vs ABAC, TLS termination, API key management with rotation, HMAC request signing, and production security checklist.
- [[concepts/microservices-architecture|Microservices Architecture]] — Service boundaries and decomposition, inter-service communication (sync/async), service registry and discovery, API gateway routing, orchestration vs choreography, Bulkhead isolation, and Netflix OSS stack.

Expanded existing concept pages with deep content:

- [[concepts/system-design|System Design]] — Added 5 new building blocks (API Gateway, Rate Limiting, Service Discovery/Registry, Distributed Consensus/Raft, Bulkhead Isolation) and 8 new case study references from Latency Gambler Days 10-20.
- [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]] — Added new pattern-specific sections: API Gateways (routing, cross-cutting concerns), Rate Limiting (token bucket, sliding window, distributed), CQRS with Event Sourcing, Event versioning and schema evolution, DLQ + poison message handling, Producer/consumer flow observability.
- [[concepts/reliability-and-operations|Reliability and Operations]] — Added new sections: Graceful Shutdown pattern (deregister, drain, close, exit), Graceful Degradation (feature flags, degraded responses, fallbacks), Observability for reliability (health endpoints, structured logging in production), production security checklist.
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]] — Added new sections: CQRS (read model vs write model separation, eventual consistency window), Projection Rebuilding (full rebuild vs incremental update, versioned events), Cache Invalidation strategies (TTL, write-through, write-behind, refresh-ahead, stampede prevention).
- [[concepts/infrastructure-primitives|Infrastructure Primitives]] — Added new sections: CDN Edge patterns (Static offload, Dynamic acceleration, API caching at edge, Geo-distributed origin pull), Cache Hierarchy patterns (L1/L2/L3, multi-tier TTL, origin shielding, cache stampede prevention).
- [[concepts/system-design-case-studies|System Design Case Studies]] — Added 3 new case studies: Prod Web App Architecture (full production stack from CI/CD to alerting), Microservices with Netflix OSS Stack (service registry, API gateway, bulkhead, circuit breaker, graceful shutdown), and Production Web Application Stack (integrated CI/CD/DNS/LB/CDN/API/DB/cache/queue/search/monitoring).

Updated [[index]], [[log]].

## [2026-06-14] deep content | 50-pass expansion series — Part 1: 8 untouched concept pages deepened

Performed 8 deep-content expansion passes on concept pages that had been created but not yet deepened with cross-source content:

**Pass 1 — [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]**: Added Kensho federated multi-agent architecture (RouterGraph, LangGraph tracing, multi-stage eval) and Madrigal modular agent platform (standardized tool interfaces, evaluative feedback loops). Cross-referenced Dropbox Nova and Claude Code practices sources.

**Pass 2 — [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]]**: Added AI Brain operating model sections (control files: _hot.md, _pending.md, _log.md), daily/weekly/monthly cadence tiers with risk profiles, and multi-source compilation rules. Cross-referenced AI brain architecture and RAG/wiki/GBrain sources.

**Pass 3 — [[concepts/system-design-interview-workflow|System Design Interview Workflow]]**: Added Google L7 common pitfalls (memorizing patterns, horizontal scaling as default, hot key/thundering herd, cache utility math) and structured preparation strategy. Cross-referenced Google L7 system design study roadmap.

**Pass 4 — [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]**: Added No-Code AI Platforms section (validation signal, integration-layer value) and Cognitive Archetypes section (supportive/mixed/risky/abstinence modes with task-fit guidance). Cross-referenced AI developer cognitive archetypes and Unlock case study.

**Pass 5 — [[concepts/recurrent-depth-transformers|Recurrent Depth Transformers]]**: Added latent-reasoning vs chain-of-thought comparison (no intermediate token trace, compute efficiency, untruncated reasoning), stability mechanisms (gating, residual scaling, LayerNorm placement), adaptive halting, and production considerations.

**Pass 6 — [[concepts/shared-engineering-language|Shared Engineering Language]]**: Added 8 new terms: Cognitive Debt, Bottleneck Shift (Engineering), Tokenmaxxing, PagedAttention, Two-Instance Serving Pattern, Feature Co-location, Order-of-Operations Risk, Defense in Depth (Security).

**Pass 7 — [[concepts/fishdb|FishDB]]**: Expanded with Document Data Model section, fully fleshed Index Types (B-tree sorted-set, bit-sliced for numeric ranges, inverted with skip-list posting lists), detailed cross-layer Key Incident analysis table (Application/Allocator/Kernel/Runtime layers), and Production Deployment section (48 shards, Envoy sidecars, monitoring axes).

**Pass 8 — [[concepts/team-topologies|Team Topologies]]**: Added Cognitive Load Management table (intrinsic/extraneous/germane mapped to team topology mitigations), Team Interaction Modes in Practice (discovery→collaboration, stable interface→X-as-a-Service, capability building→facilitation), and Inverse Conway Maneuver section.

Link check and lint pass clean.

## [2026-06-14] deep content | 50-pass expansion series — Part 3: 9 new concept pages created

Created 9 new concept pages from cross-source synthesis of previously uncaptured topics:

**Pass 14 — [[concepts/observability-and-monitoring|Observability and Monitoring]]**: Three pillars (logs/metrics/traces), four golden signals (latency/traffic/errors/saturation), structured logging with required fields, metrics collection (counter/gauge/histogram/summary), distributed tracing with W3C traceparent propagation, SLO burn-rate alerting with multi-window approach, diagnostic workflow (metrics→traces→logs), dashboard tiers and anti-patterns, alert severity levels and anti-patterns.

**Pass 15 — [[concepts/production-ai-operations|Production AI Operations]]**: AI failure mode taxonomy (hallucination/grounding, retrieval failures, inference latency, cost management), cost-per-successful-outcome metric, model selection by cognitive task, deterministic agent orchestration with state machines, tool security (input/output validation, trust boundaries), evaluation offline in CI/CD and online in production, memory tiers (session/working/long-term/ephemeral).

**Pass 16 — [[concepts/agent-memory-architecture|Agent Memory Architecture]]**: Three paradigms (RAG retrieval, LLM Wiki compilation, fat skills/GBrain action-embedded) with hybrid architecture decision flowchart, short-term vs long-term memory tiers (session context, working memory, long-term, ephemeral state), memory quality metrics (precision, recall, synthesis accuracy, staleness, reuse rate), and nine common failure modes in agent memory.

**Pass 17 — [[concepts/event-driven-architecture|Event-Driven Architecture]]**: Events vs commands vs messages, pub/sub vs message queues, CQRS with dual-write problem solution via CDC, Change Data Capture from WAL/binlog with Debezium pipeline and operational risks, Event Sourcing with snapshots and versioning, projections (full rebuild vs incremental), Saga pattern (choreographed vs orchestrated), CloudEvents standard for schema interoperability.

**Pass 18 — [[concepts/multi-agent-orchestration|Multi-Agent Orchestration]]**: Four agent topologies (router graph, planning-execution separation, peer-to-peer/debate, hierarchical), structured inter-agent communication protocols, shared context surface via filesystem, agent harness architecture (filesystem, sandbox, tool registry, memory manager, self-verification, Ralph Loop), evaluation at router/specialist/end-to-end/latency/cost levels.

**Pass 19 — [[concepts/code-quality-and-ai-slop|Code Quality and AI Slop Management]]**: Traditional code smell families (bloaters, OO abusers, change preventers, dispensables, couplers) with refactoring techniques, AI-specific quality problems (comment slop, instrumentation slop, vibe architecture, architecture drift multiplier), anti-slop pillars (context completeness, human-owned architecture, review gates, anti-pattern rules file, no speculative generation, instrumentation discipline), expected vs exceptional failure distinction.

**Pass 20 — [[concepts/performance-engineering|Performance Engineering]]**: The performance engineering loop (budget→measure→bottleneck→fix→verify), performance budgets by metric, CPU/memory/I/O profiling with flame graphs, six load test types with anti-patterns, database performance (80/20 rule, indexing strategy, N+1 query fixes, connection pool sizing), caching strategy, and cross-layer debugging (LinkedIn HashMap freeze case study spanning application→allocator→kernel→async runtime).

**Pass 21 — [[concepts/integration-testing-and-test-strategy|Integration Testing and Test Strategy]]**: 50/40/10 test pyramid (unit/integration/E2E), Testcontainers pattern for real-service integration tests, Toxiproxy failure injection, clean-before strategy, CI test layering with fast feedback, flaky test management, AI-generated behavioral tests, and contract testing with Pact-style verification.

**Pass 22 — [[concepts/incident-management-sre|Incident Management and SRE Practice]]**: Incident lifecycle (detection→triage→mitigation→resolution→postmortem), ICS roles (IC, Scribe, SME, Comms Lead), severity definitions, mitigation vs resolution distinction, blameless postmortem template, on-call rotation structures and pager budgets, alert hygiene, and DORA metrics.

Updated [[index]] with all 9 new entries, link check and lint pass clean.

## [2026-06-14] deep content | 50-pass expansion series — Part 3 continued: 5 more new concept pages

**Pass 23 — [[concepts/api-protocol-selection|API Protocol Selection]]**: REST vs GraphQL vs gRPC vs WebSocket comparison with benchmarks, layered decision framework (default REST, add GraphQL for frontend bottlenecks, add gRPC for internal service calls, add WebSocket for realtime), and layered architecture pattern.

**Pass 24 — [[concepts/ci-cd-pipeline-and-deployment|CI/CD Pipeline and Deployment Strategy]]**: Pipeline stages (commit→lint→test→build→integration→security→staging→e2e→production), immutable artifacts, deployment strategies (rolling/blue-green/canary/feature flags), rollback automation, container multi-stage build optimization, and DORA metrics.

**Pass 25 — [[concepts/vector-semantic-search-architecture|Vector and Semantic Search Architecture]]**: Search spectrum (keyword→hybrid→semantic), embedding pipeline, vector index types (HNSW, IVF, DiskANN), multimodal search with CLIP/CLAP, hybrid retrieval with RRF, LinkedIn-scale semantic search architecture.

**Pass 26 — [[concepts/ai-coding-workflow-productivity|AI Coding Workflow and Productivity]]**: Context-first workflow (context→plan→review→execute→test), cognitive modes (supportive/mixed/exploratory/review-only), bottleneck shift awareness, and learning-oriented AI use patterns.

**Pass 27 — [[concepts/cloud-devboxes-for-agent-execution|Cloud Devboxes for Agent Execution]]**: Cloud devbox architecture for parallel agent execution, VM isolation, declarative devcontainer specs, automated lifecycle, scoped credentials, and network context for agent environments.

Updated [[index]] with all 5 new entries, link check and lint pass clean.

## [2026-06-14] deep content | 50-pass expansion series — Part 2: 5 new concept pages deepened

Performed 5 deep-content expansion passes on concept pages created in the previous session:

**Pass 9 — [[concepts/api-management|API Management and Gateway Patterns]]**: Added Protocol Translation section (HTTP→gRPC, GraphQL→REST, WebSocket→SSE, MQTT→HTTP with decision criteria) and Distributed Rate Limiting section (Redis sliding window, local cache + periodic sync, leaky bucket per node, rate limiting as backpressure). Cross-referenced latency-gambler-day-11 and prod-web-application-components.

**Pass 10 — [[concepts/distributed-coordination|Distributed Coordination and Consensus]]**: Added Raft in Production section (disk I/O sensitivity, quorum math, leader election storms, defragmentation) and Gossip Protocols section (SWIM/Serf pattern, membership detection, when to use vs Raft). Cross-referenced raft-consensus-explained.

**Pass 11 — [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]]**: Added Production Circuit Breaker Tuning (per-service failure threshold, open duration, half-open probing strategy, metrics window shape), Health Endpoint Pattern (liveness vs readiness with observability), Graceful Shutdown Sequence (deregister, drain, close, exit), and Rate Limiting as Backpressure. Cross-referenced latency-gambler-days 8, 15, 17, and prod-web-application-components.

**Pass 12 — [[concepts/security-patterns|Security Patterns]]**: Added OAuth 2.0 Grant Type Decision Tree, API Key Rotation Mechanics (overlapping rotation pattern with overlap period management, key hash storage), TLS Termination Decisions table, and Cloudflare Tunnel pattern for ingress security. Cross-referenced latency-gambler-day-20, create-tunnel-dashboard, docker-image-security-optimization.

**Pass 13 — [[concepts/microservices-architecture|Microservices Architecture]]**: Added Orchestration vs Choreography comparison with decision table, Event-Driven Microservices section (event schema, CloudEvents, at-least-once delivery, idempotency, Saga pattern with choreographed vs orchestrated forms), Service Mesh Deployment (sidecar pattern, what mesh handles, when to use mesh), and Migration Strategies (Strangler Fig, Parallel Run, Database Per Service). Cross-referenced latency-gambler-days 12, 13, 15.

Link check and lint pass clean.

## [2026-06-14] deep content | 10-pass deep content expansion across 9 concept pages

Performed 10 deep-content expansion passes across the wiki concept and synthesis pages, cross-referencing the full source set for each:

**Pass 1 — [[concepts/software-design-patterns|Software Design Patterns]]**: Added SOLID principles for distributed systems, Repository Pattern, Connection Pool tuning, and Connection Factory read/write routing.

**Pass 2 — [[concepts/structured-learning-and-retention|Structured Learning and Retention]]**: Added Cognitive Debt and the Order-of-Operations Risk, Context-First Workflow as a Learning System, System Design Study Roadmap.

**Pass 3 — [[concepts/career-growth-meta-skills|Career Growth and Meta-Skills]]**: Added Software Estimation as a Senior Skill, Engineering Judgment When Code Is Cheap.

**Pass 4 — [[concepts/local-llm-serving|Local LLM Serving]]**: Added PagedAttention, Quantization Strategy table, 5-phase Model Loading, Production Serving Architecture.

**Pass 5 — [[concepts/ml-recommendation-systems|ML Recommendation Systems at Scale]]**: Added Snapchat Bento, Netflix Multimodal Video Search, LinkedIn Semantic Search, cross-platform comparison table.

**Pass 6 — [[concepts/memory-safety-strategy|Memory Safety and Defense-in-Depth]]**: Added Rust WAF case study, Container Defense-in-Depth, Memory Safety Beyond Rust (HashMap freeze).

**Pass 7 — [[concepts/local-first-architecture|Local-First Architecture]]**: Expanded Edison architecture, Conflict Resolution Strategies (LWW vs OT vs CRDT), Offline Resilience patterns.

**Pass 8 — [[concepts/frontend-build-performance|Frontend Build Performance]]**: Added TypeScript modeling, App Router mental model, AI UX Patterns, Performance Infrastructure Integration table.

**Pass 9 — [[concepts/command-line-and-git-productivity|Command-Line and Git Productivity]]**: Added Remote/Cloud Dev Environments, Cloud Devboxes for Agent Fleets, VM isolation model.

**Pass 10 — [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]**: Extended with all 9 passes, expanded study spine from 11 to 16 building blocks.

Updated [[index]], [[log]]. Link check and lint pass clean.


## 2026-06-14 13:11 daily cycle | Auto-deepen: 9 thin concept(s) flagged

## 2026-06-14 13:12 daily cycle | Wiki state committed

## [2026-06-14] ingest | Garry Tan's Claude Code Senior Engineer Prompt

Processed new raw source: Garry Tan's Claude Code Senior Engineer Prompt — a Plan Mode prompt template using four review pillars (architecture, code quality, tests, performance) with structured issue reporting and BIG/SMALL change branching.

Added source summary: [[sources/garry-tan-claude-code-senior-engineer-prompt|Garry Tan's Claude Code Senior Engineer Prompt]].

Updated [[index]], [[log]].

## [2026-06-14] ingest | HLD network protocols, incremental rollup tables, pcell A2A protocol, sycophancy drift

Processed 4 new raw sources covering network protocol fundamentals, materialized rollup table analytics, agent-to-agent knowledge economies, and LLM sycophancy bias.

Added source summaries:
- [[sources/hld-network-protocols|HLD Fundamentals #1 - Network Protocols]] (TCP, UDP, QUIC, HTTP/3, DNS, WebSocket tradeoffs for system design).
- [[sources/incremental-rollup-tables|Incremental Rollup Tables for Dashboard Analytics]] (materialized precomputed rollups replacing full-query refreshes).
- [[sources/pcell-agent-society-a2a-protocol|pcell Agent-to-Agent Protocol]] (decentralized agent society with emergent specialization).
- [[sources/sycophancy-drift-reflective-layer|Sycophancy Drift — A Reflective Layer]] (agreement bias in LLMs and reflective-layer mitigation).

Updated [[index]], [[log]].
