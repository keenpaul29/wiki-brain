---
title: Wiki Index
type: index
created: 2026-04-28
updated: 2026-06-14
---

# Wiki Index

This wiki compiles the current `raw/` sources into linked notes about AI-assisted engineering, personal knowledge systems, learning practice, system design, and LLM architecture.

## Synthesis

- [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] - A synthesis tying together AI-era engineering judgment, structured learning, system design, and wiki-based knowledge management.

## Concepts

- [[concepts/agent-memory-architecture|Agent Memory Architecture]] - Retrieve vs compile vs act: the three paradigms for persistent agent memory across sessions.
- [[concepts/ai-coding-workflow-productivity|AI Coding Workflow and Productivity]] - Context-first workflow, implementation planning, cognitive modes, and bottleneck awareness.
- [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] - The shift from syntax production toward architecture, debugging, accountability, and human alignment.
- [[concepts/api-management|API Management and Gateway Patterns]] - API gateways, rate limiting, versioning, BFF patterns, and protocol mediation for production APIs.
- [[concepts/api-protocol-selection|API Protocol Selection]] - REST vs GraphQL vs gRPC vs WebSocket: layered decision framework and performance benchmarks.
- [[concepts/career-growth-meta-skills|Career Growth and Meta-Skills]] - Non-technical growth skills: communication, feedback, patience, learning, mentorship, and scope.
- [[concepts/ci-cd-pipeline-and-deployment|CI/CD Pipeline and Deployment Strategy]] - Pipeline stages, deployment strategies, rollback, container optimization, and DORA metrics.
- [[concepts/cloud-devboxes-for-agent-execution|Cloud Devboxes for Agent Execution]] - VM-isolated environments for background coding agents, declarative specs, and scoped credentials.
- [[concepts/code-quality-and-ai-slop|Code Quality and AI Slop Management]] - Traditional code smells, AI-generated anti-patterns, and quality discipline for the LLM era.
- [[concepts/command-line-and-git-productivity|Command-Line and Git Productivity]] - Terminal efficiency patterns and advanced Git timeline mechanics for robust workflow execution.
- [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]] - Monoliths, microservices, event-driven systems, queues, pub/sub, REST, GraphQL, gRPC, and realtime patterns.
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]] - Storage types, database families, replication, sharding, transactions, and consistency tradeoffs.
- [[concepts/distributed-coordination|Distributed Coordination and Consensus]] - Leader election, Raft consensus, vector clocks, conflict resolution, and coordination primitives.
- [[concepts/event-driven-architecture|Event-Driven Architecture]] - CQRS, CDC, event sourcing, projections, sagas, and message-driven service decomposition.
- [[concepts/fishdb|FishDB]] - LinkedIn's Rust-based storage and retrieval engine for Feed, using Tokio, jemalloc, and hashbrown.
- [[concepts/frontend-build-performance|Frontend Build Performance]] - Tree shaking, module-system migration, bundle footprint, and rollout strategy for frontend optimization.
- [[concepts/infrastructure-primitives|Infrastructure Primitives]] - Networking, traffic, compute, delivery, and service-discovery building blocks.
- [[concepts/incident-management-sre|Incident Management and SRE Practice]] - Incident lifecycle, ICS roles, on-call engineering, blameless postmortems, and DORA metrics.
- [[concepts/integration-testing-and-test-strategy|Integration Testing and Test Strategy]] - Test pyramid, Testcontainers, Toxiproxy, CI test layering, contract testing, and AI-generated tests.
- [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] - A persistent markdown knowledge base maintained by an LLM instead of one-off retrieval.
- [[concepts/local-first-architecture|Local-First Architecture]] - Local reads/writes with background sync, optimistic UI, and multi-tab coordination.
- [[concepts/local-llm-serving|Local LLM Serving]] - Prefill/decode, KV cache, context length, scheduler, and observability patterns for local model serving.
- [[concepts/memory-safety-strategy|Memory Safety and Defense-in-Depth]] - Memory-safe language adoption, attack-surface reduction, and Rust security migrations.
- [[concepts/microservices-architecture|Microservices Architecture]] - Service boundaries, decomposition strategies, inter-service communication, orchestration vs choreography, and the Netflix OSS stack.
- [[concepts/ml-recommendation-systems|ML Recommendation Systems at Scale]] - Retrieval, Two Tower embeddings, staged ranking, precomputation, and reranking controls.
- [[concepts/multi-agent-orchestration|Multi-Agent Orchestration]] - Router graphs, planning-execution separation, agent harnesses, and multi-agent communication patterns.
- [[concepts/observability-and-monitoring|Observability and Monitoring]] - Three pillars, four golden signals, structured logging, distributed tracing, SLO burn-rate alerting, and observability-driven diagnosis.
- [[concepts/performance-engineering|Performance Engineering]] - Profiling, load testing, database optimization, caching strategy, performance budgets, and cross-layer debugging.
- [[concepts/production-ai-operations|Production AI Operations]] - AI failure modes, retrieval engineering, inference latency, cost management, model selection, and evaluation pipelines.
- [[concepts/project-operating-architecture|Project Operating Architecture]] - The local GBrain, wiki, codebase, and agent handoff architecture for this checkout.
- [[concepts/recurrent-depth-transformers|Recurrent-Depth Transformers]] - Looped transformer architectures, latent reasoning, stability, MoE breadth, and inference-time depth.
- [[concepts/reliability-and-operations|Reliability and Operations]] - Availability, fault tolerance, rate limiting, circuit breakers, SLOs, disaster recovery, and identity/security.
- [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]] - Retry with backoff, circuit breakers, bulkheads, timeouts, fallback chains, graceful degradation, and layered resilience.
- [[concepts/security-patterns|Security Patterns]] - Defense in depth, JWT, OAuth 2.0, RBAC/ABAC, TLS, API key management, request signing, and security checklist.
- [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]] - Capturing user corrections and turning repeated feedback into persistent agent rules.
- [[concepts/shared-engineering-language|Shared Engineering Language]] - A lightweight CONTEXT-style glossary for recurring project terms and durable engineering decisions.
- [[concepts/software-design-patterns|Software Design Patterns]] - Choosing design patterns from concrete creation, structure, or behavior pain.
- [[concepts/structured-learning-and-retention|Structured Learning and Retention]] - Using curricula, practice, spaced repetition, and source synthesis to make learning compound.
- [[concepts/system-design|System Design]] - Principles, primitives, scaling patterns, and interview-style design workflows.
- [[concepts/system-design-case-studies|System Design Case Studies]] - URL shortener, WhatsApp, Twitter, Netflix, and GenAI shopping-assistant design patterns.
- [[concepts/system-design-interview-workflow|System Design Interview Workflow]] - A repeatable flow for requirements, estimates, data models, APIs, components, deep dives, and bottlenecks.
- [[concepts/team-topologies|Team Topologies]] - Engineering organization design with stream-aligned, enabling, complicated-subsystem, and platform team types.
- [[concepts/vector-semantic-search-architecture|Vector and Semantic Search Architecture]] - Embedding-based retrieval, HNSW indexes, multimodal search, and hybrid retrieval pipelines.

## Sources

- [[sources/llm-wiki-idea-file|LLM Wiki Idea File]] - The operating pattern for compiling raw sources into a living wiki.
- [[sources/prod-web-application-components|Key Components of a Prod Web Application]] - A big-picture view of the essential components (CI/CD, DNS, LB, CDN, APIs, DBs, caches, queues, search, monitoring) in a production web stack.
- [[sources/latency-gambler-day-10|Caching Patterns]] - Day 10: Core caching, invalidation, multi-level cache, and stampede prevention strategies.
- [[sources/latency-gambler-day-11|API Gateway & Proxy Patterns]] - Day 11: API gateways, forward/reverse proxies, rate limiting, versioning, and BFF patterns.
- [[sources/latency-gambler-day-12|Message Queue Patterns]] - Day 12: Pub/sub, message queues vs topics, command pattern, DLQ, deduplication, and priority queues.
- [[sources/latency-gambler-day-13|Event Sourcing & CQRS Patterns]] - Day 13: Event sourcing, CQRS, Saga pattern, event snapshotting, and projection rebuilding.
- [[sources/latency-gambler-day-14|Monitoring & Observer Patterns]] - Day 14: Three pillars of observability, observer-based monitoring, structured logging, distributed tracing, and alerting.
- [[sources/latency-gambler-day-15|Microservices Patterns]] - Day 15: Service registry/discovery, API gateway, Bulkhead pattern, and Netflix OSS stack.
- [[sources/latency-gambler-day-16|Distributed System Patterns]] - Day 16: Leader election, Raft consensus, Vector clocks, and conflict resolution.
- [[sources/latency-gambler-day-17|Resilience Patterns]] - Day 17: Retry with backoff, timeout, fallback chains, graceful degradation, and layered resilience.
- [[sources/latency-gambler-day-18|Caching & CDN Patterns]] - Day 18: Multi-level caching hierarchy, cache warming, CDN patterns, cache stampede prevention, and production tips.
- [[sources/latency-gambler-day-19|Database Scaling Patterns]] - Day 19: Read replicas, sharding strategies, database per service, and hybrid scaling approaches.
- [[sources/latency-gambler-day-20|Security Patterns]] - Day 20: Defense in depth, JWT, OAuth 2.0, RBAC, ABAC, TLS, API keys, request signing, and security checklist.
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
- [[sources/ai-remote-development|Enhance Productivity with AI + Remote Dev]] - VS Code remote development workflows with AI context, chat participants, and tool approvals.
- [[sources/ai-brain-never-forgets|How To Build An AI Brain That Never Forgets]] - A local markdown AI brain built from raw files, wiki pages, schema files, queues, logs, and cadenced automation.
- [[sources/ai-work-safety|How to Use AI at Work Without Breaking Your Systems]] - AI coding assistant guardrails for production access, destructive commands, backups, and deployment gates.
- [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]] - Selecting OO design patterns by identifying creation, structure, or behavior pain.
- [[sources/developer-time-management|Developer Time Management]] - Deep work, GTD for developers, calendar blocking, maker vs manager schedule, burnout prevention, and a productivity checklist.
- [[sources/dictionary-problem-fast-lookups|The Dictionary Problem - Fast Lookups in Large Collections]] - Data-structure tradeoffs for membership and key-value lookup workloads.
- [[sources/ai-coding-workflow-context-first|Context-First AI Coding Workflow]] - A plan-first, context-rich AI coding workflow with review gates and clarification loops.
- [[sources/exception-handling-patterns|Exception Handling Patterns Over Blanket try-catch]] - Validation-first error handling, typed exceptions, centralized handlers, and expected-failure result types.
- [[sources/dont-outsource-learning|Don't Outsource the Learning]] - A research-backed warning about cognitive debt when AI coding closes tasks without preserving engineering understanding.
- [[sources/no-code-ai-platforms|No-Code AI Development Platforms]] - Evaluates the shift in AI product creation enabled by modern no-code platforms.
- [[sources/caching-patterns|Essential Caching Patterns and Strategies]] - Explains critical caching architectures and eviction schemes, highlighting performance trade-offs.
- [[sources/code-cheap-judgement-not|AI Code Leverage and Engineering Judgement]] - Highlights the value of engineering judgment, feature curation, and refusal as code implementation costs drop.
- [[sources/end-of-legacy-code|Eradicating Legacy Code via AI-Driven Testing]] - Proposes continuously generated AI behavior-based testing to eliminate human memory decay and technical debt.
- [[sources/kensho-multi-agent|Kensho Financial Multi-Agent Retrieval Architecture]] - Outlines Kensho's LangGraph routing framework for structured data retrieval.
- [[sources/madrigal-multi-agent|Madrigal Pharmaceuticals Agentic Research Platform]] - Details a modular agentic pharma research platform utilizing LangChain, LangGraph, and LangSmith.
- [[sources/netflix-multimodal-video-search|Netflix Multimodal Video Search Architecture]] - Illustrates video indexing and CLIP/CLAP multimodal embedding search frameworks at scale.
- [[sources/remote-data-migration-agent|Remote Data Migration Agentic Architecture]] - Explores sandboxed Python code execution agents mapping and migrating HR spreadsheets in WebAssembly.
- [[sources/snapchat-billion-predictions|Snapchat Bento ML Platform Architecture]] - Covers Snapchat's Bento platform serving high-frequency recommendation predictions.
- [[sources/monolith-to-service-migration|Monolith to Service Migration Strategies]] - Outlines Strangler Fig, Parallel Run, Collaborator, and CDC migration patterns.
- [[sources/effective-git|Effective Git Workflows and Commands]] - Advanced Git habits including interactive staging, bisecting, worktrees, and reflogs.
- [[sources/effective-terminal|Effective Terminal Workflows and Productivity]] - Terminal shortcuts, configurations, and multiplexing to boost development workflow.
- [[sources/latency-gambler-day-1|Building the System Architect Mindset]] - Day 1 of a system design curriculum reinterpreting SOLID principles for distributed failure isolation.
- [[sources/latency-gambler-day-2|Strategy and Observer Patterns for System Design]] - Day 2 covering Strategy selection and decoupled event Observer designs.
- [[sources/latency-gambler-day-3|Decorator and Proxy Patterns for System Design]] - Day 3 outlining dynamic wrappers and Virtual/Remote proxy interceptors.
- [[sources/latency-gambler-day-4|Singleton and Builder Patterns for System Design]] - Day 4 on thread-safe JVM Singleton structures and immutable Builder validations.
- [[sources/latency-gambler-day-5|Command and Template Method Patterns for System Design]] - Day 5 encapsulating tasks as objects and organizing extensible template methods.
- [[sources/latency-gambler-day-6|Adapter and Facade Patterns for System Design]] - Day 6 bridging legacy integrations and taming microservice subsystem complexity.
- [[sources/latency-gambler-day-7|Chain of Responsibility & State Patterns]] - Day 7 mastering request-processing pipelines and explicit state-machine transitions.
- [[sources/latency-gambler-day-8|Load Balancing & Circuit Breaker Patterns]] - Day 8 covering load balancing traffic distribution and fault tolerance with circuit breakers.
- [[sources/latency-gambler-day-9|Database Patterns & Repository Pattern]] - Day 9 on clean data persistence layers, repositories, connection pooling, and connection factories.
- [[sources/meta-webrtc-fork-modernization|Escaping the Fork: Meta WebRTC Modernization]] - Meta's dual-stack WebRTC shim migration for escaping a long-lived upstream fork.
- [[sources/ai-slop-game-refactor|Scrubbing AI Slop From a Game Codebase]] - A Godot/LLM refactor case study on removing comments, instrumentation, and architecture drift.
- [[sources/localhost-cloud-dev-agents|The Last Year of Localhost]] - Cloud development environments as the execution substrate for parallel background coding agents.
- [[sources/quic-head-of-line-blocking|The Packet Drop That Froze Three Requests at Once]] - QUIC, HTTP/3, head-of-line blocking, 0-RTT, connection migration, and UDP deployment tradeoffs.
- [[sources/cqrs-read-write-separation|The Read That Was Killing the Write]] - CQRS as a separation between authoritative write models and optimized read projections.
- [[sources/change-data-capture-event-log|Your Database Has Been Writing an Event Log the Whole Time]] - CDC from WAL/binlog streams for search, cache, audit, and service synchronization.
- [[sources/tracking-ai-usage-goodharts-law|Goodhart's Law in Corporate AI Usage Tracking]] - Critique of tracking developer token usage, leading to gaming metrics ("tokenmaxxing").
- [[sources/anatomy-agent-harness|Anatomy of an AI Agent Harness]] - Explains filesystems, bash sandboxes, self-verification loops, and memory architectures that enable agent autonomy.
- [[sources/google-l7-system-design|Google L7 System Design Interview Insights]] - Humble URL shortener design feedback stressing system physics and vertical node optimization over defaults.
- [[sources/dropbox-beyond-code-generation|Beyond Code Generation: Dropbox Nova]] - Dropbox's Nova agent platform: 1-in-12 PRs agent-produced, bottleneck shift, 4-stage measurement model.
- [[sources/linkedin-prompt-engineering-playgrounds|Collaborative Prompt Engineering Playgrounds]] - LinkedIn's Jupyter prompt engineering workflow bridging engineers and domain experts.
- [[sources/linkedin-fishdb-retrieval-engine|FishDB: LinkedIn Feed Retrieval Engine]] - Rust-based document-oriented storage and retrieval engine powering LinkedIn's Feed.
- [[sources/dropbox-edison-web-performance|Dropbox Edison: Local-First Web Client]] - Edison sync engine bringing local-first performance to dropbox.com.
- [[sources/medium-10x-dev-llm-coding-faster|10x Dev: LLM Coding Faster Without Slop]] - Structured approach to LLM-assisted coding with review discipline.
- [[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]] - GPU-accelerated embedding-based retrieval and Cross-Encoder SLM ranking at millions QPS.
- [[sources/linkedin-58m-key-hashmap-freeze|The 58-Million-Key Freeze]] - HashMap resize → mmap_lock contention → async runtime freeze case study.
- [[sources/production-firewalls-rust|Production Firewall Architecture in Rust]] - Multi-layer Rust Web Application Firewall (WAF) async TCP and Regex signature inspection engine.
- [[sources/system-design-study-roadmap|Curated System Design Study Roadmap]] - Structured learning path using engineering blogs and case studies to develop real architectural tradeoff intuition.
- [[sources/rest-vs-graphql-vs-grpc|REST vs GraphQL vs gRPC]] - A practical decision framework for choosing REST, GraphQL, and gRPC across public, frontend, and internal service layers.

- [[sources/engineering-blogs-2025|Engineering Blogs To Follow in 2025]] - A curated map of company engineering blogs for ongoing case-study learning.
- [[sources/junior-to-senior-engineer|Going from Junior to Senior Engineer in 2 Years]] - Career-growth tactics around reliable delivery, documentation, leadership, public learning, and mentorship.
- [[sources/whatsapp-rust-security|Rust at Scale: WhatsApp Security]] - WhatsApp's Rust media consistency library as a cross-platform defense-in-depth security layer.
- [[sources/instagram-explore-recommendations|Scaling Instagram Explore Recommendations]] - Instagram Explore's multi-stage recommendation funnel with Two Tower retrieval and staged ranking.
- [[sources/image-transformations-for-developers|Image Transformations for Developers]] - Cloudinary's dynamic image transformation via URL parameters, smart cropping, automatic format selection, and CDN caching.
- [[sources/integration-testing-real-services|Testing with Real Services]] - Integration testing with Testcontainers, Toxiproxy error injection, clean-before strategy, and the 50/40/10 coverage pyramid.
- [[sources/successful-software-engineer-passive-skills|What Really Makes a Successful Software Engineer]] - Passive career skills: patience, determination, student mindset, feedback, and communication.
- [[sources/observability-in-distributed-systems|Observability in Distributed Systems]] - Three pillars (logs/metrics/traces), four golden signals, OpenTelemetry, and SLO burn-rate alerting.
- [[sources/postgresql-advanced-indexing|PostgreSQL Advanced Indexing Guide]] - GIN, GiST, BRIN, Partial, and Expression index types with PostgreSQL operational discipline.
- [[sources/raft-consensus-explained|Raft Consensus Explained]] - Leader election, log replication, ConflictTerm backtracking, quorum math, and production operations for etcd-based distributed consensus.
- [[sources/backend-performance-engineering|Backend Performance Engineering]] - Performance budgets, profiling with flame graphs, load testing types, database optimization, N+1 queries, indexing strategy, and caching discipline.
- [[sources/bulletproof-ci-cd-pipeline|Building a Bulletproof CI/CD Pipeline]] - Trunk-based development, immutable artifacts, deployment strategies, rollback automation, and DORA metrics for resilient pipelines.
- [[sources/byte-storage-vs-io|Byte Storage vs. I/O]] - Separates raw capacity from throughput and IOPS as storage design constraints.
- [[sources/code-smells-refactoring-techniques|Code Smells and Refactoring Techniques]] - A catalog of code smell families (bloaters, OO abusers, change preventers, dispensables, couplers) and refactoring techniques to fix them.
- [[sources/developer-time-management|Developer Time Management]] - Deep work, GTD for developers, calendar blocking, maker vs manager schedule, burnout prevention, and a productivity checklist.
- [[sources/intro-to-websockets|Intro to WebSockets]] - Realtime communication primer covering polling, the WebSocket handshake, full-duplex channels, and operational tradeoffs.
- [[sources/netflix-open-connect-cdn-strategy|Netflix Open Connect CDN Strategy]] - Netflix Open Connect as an edge CDN case study with ISP-local appliances, predictive fill, and control/data-plane separation.
- [[sources/software-estimation-techniques|Software Estimation Techniques]] - Story points, Planning Poker, T-shirt sizing, Monte Carlo simulation, affinity estimation, and velocity tracking for forecasting engineering work.
- [[sources/sre-incident-management|SRE Incident Management]] - Incident lifecycle, Incident Command System, on-call engineering, blameless postmortem culture, and action item discipline.
- [[sources/structured-engineering-hiring|Structured Engineering Hiring]] - Rubric-based scoring, behavioral and hypothetical questions, score-first debrief, bias mitigation, and process design for consistent hiring.
- [[sources/team-topologies-org-design|Team Topologies: Engineering Organization Design]] - Four team types (stream-aligned, enabling, complicated-subsystem, platform), interaction modes, Conway's Law, and cognitive load management.
- [[sources/garry-tan-claude-code-senior-engineer-prompt|Garry Tan's Claude Code Senior Engineer Prompt]] - Plan Mode prompt with four engineering review pillars for AI-assisted development.
- [[sources/hld-network-protocols|HLD Fundamentals #1 - Network Protocols]] - Network protocol fundamentals for system design: TCP, UDP, QUIC, HTTP/3, DNS, and WebSocket tradeoffs.
- [[sources/incremental-rollup-tables|Incremental Rollup Tables for Dashboard Analytics]] - Materialized incremental rollup tables replacing full-query refreshes for sub-50ms dashboard analytics.
- [[sources/pcell-agent-society-a2a-protocol|pcell Agent-to-Agent Protocol]] - Decentralized agent knowledge economy with 135 agents, A2A protocol, and emergent specialization.
- [[sources/sycophancy-drift-reflective-layer|Sycophancy Drift — A Reflective Layer]] - The AI agreement bias and a reflective-layer mitigation for LLM-assisted decision making.
 
## Newest Sources

- [[sources/garry-tan-claude-code-senior-engineer-prompt|Garry Tan's Claude Code Senior Engineer Prompt]]
- [[sources/prod-web-application-components|Key Components of a Prod Web Application]]
- [[sources/latency-gambler-day-10|Caching Patterns]]
- [[sources/latency-gambler-day-11|API Gateway & Proxy Patterns]]
- [[sources/latency-gambler-day-12|Message Queue Patterns]]
- [[sources/latency-gambler-day-13|Event Sourcing & CQRS Patterns]]
- [[sources/latency-gambler-day-14|Monitoring & Observer Patterns]]
- [[sources/latency-gambler-day-15|Microservices Patterns]]
- [[sources/latency-gambler-day-16|Distributed System Patterns]]
- [[sources/latency-gambler-day-17|Resilience Patterns]]
- [[sources/latency-gambler-day-18|Caching & CDN Patterns]]
- [[sources/latency-gambler-day-19|Database Scaling Patterns]]
- [[sources/latency-gambler-day-20|Security Patterns]]
- [[sources/observability-in-distributed-systems|Observability in Distributed Systems]]
- [[sources/postgresql-advanced-indexing|PostgreSQL Advanced Indexing Guide]]
- [[sources/raft-consensus-explained|Raft Consensus Explained]]
- [[sources/integration-testing-real-services|Testing with Real Services]]
- [[sources/bulletproof-ci-cd-pipeline|Building a Bulletproof CI/CD Pipeline]]
- [[sources/backend-performance-engineering|Backend Performance Engineering]]
- [[sources/code-smells-refactoring-techniques|Code Smells and Refactoring Techniques]]
- [[sources/developer-time-management|Developer Time Management]]
- [[sources/software-estimation-techniques|Software Estimation Techniques]]
- [[sources/sre-incident-management|SRE Incident Management]]
- [[sources/structured-engineering-hiring|Structured Engineering Hiring]]
- [[sources/team-topologies-org-design|Team Topologies: Engineering Organization Design]]
- [[sources/hld-network-protocols|HLD Fundamentals #1 - Network Protocols]]
- [[sources/incremental-rollup-tables|Incremental Rollup Tables for Dashboard Analytics]]
- [[sources/pcell-agent-society-a2a-protocol|pcell Agent-to-Agent Protocol]]
- [[sources/sycophancy-drift-reflective-layer|Sycophancy Drift — A Reflective Layer]]
 
## Maintenance Notes

- [[maintenance|Maintenance]] - Everyday workflow for ingesting, querying, and linting the wiki.
- [[automation|Daily Auto Update Workflow]] - Automated scan, ingest, link-check, and state-commit routine.
- Raw sources remain immutable in `raw/`.
- Wiki pages are generated and maintained in `wiki/`.
- On each ingest, update this index, add or revise source summaries, update relevant concept pages, and append to [[log]].
- Prefer backlinks like `[[concepts/system-design|System Design]]` when relating pages.
