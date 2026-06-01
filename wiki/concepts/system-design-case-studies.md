---
title: System Design Case Studies
type: concept
created: 2026-04-28
tags:
  - concept
  - case-studies
  - system-design
---

# System Design Case Studies

The system design course uses case studies to turn primitives into reusable design judgment. Each case study follows a similar pattern: requirements, estimates, data model, APIs, high-level architecture, detailed design, and bottlenecks.

## URL Shortener

Core problem: generate unique short aliases for long URLs and redirect reads with low latency. The source frames it as read-heavy and highlights expiration, abuse prevention, analytics, encoding, key generation, caching, data partitioning, cleanup, and security.

Useful patterns:

- Read-heavy design.
- Cache hot redirects.
- Key generation service.
- API keys for client control and abuse prevention.
- Cleanup for expired links.

## WhatsApp-Like Messaging

Core problem: real-time chat with users, groups, message history, notifications, read receipts, media, and high availability.

Useful patterns:

- Persistent realtime connections.
- Message storage and partitioning.
- Notification pipeline.
- Media storage plus CDN.
- API gateway and cache for supporting reads.

## Twitter-Like Social Feed

Core problem: posting, following, feed generation, ranking, search, media, trends, and notifications.

Useful patterns:

- Fan-out on write, fan-out on read, or hybrid feeds.
- Ranking based on relevance, recency, and engagement.
- Search infrastructure for text and trends.
- Graph queries for relationships.
- Caching top traffic and paginating feeds.

## Netflix-Like Video Streaming

Core problem: upload, process, store, search, and stream video at huge read scale with low latency and high reliability.

Useful patterns:

- Object storage for media.
- CDN for video delivery.
- Resume playback state.
- Geo-blocking.
- Analytics and metrics.
- High storage and bandwidth estimation.

## GenAI Shopping Assistant

Core problem: answer open-ended shopping questions with low latency, evidence grounding, and useful product-aware rendering at very large concurrency. The Rufus source frames this as a full production system: domain data preparation, custom LLM training, RAG over trusted shopping sources, feedback-driven improvement, accelerator-backed inference, continuous batching, and token-level streaming with response hydration.

Useful patterns:

- Domain-specialized model or adaptation.
- RAG over source-specific evidence with relevance by question type.
- Feedback loop for response-quality improvement.
- Accelerator and compiler/runtime work for low-latency inference.
- Continuous batching for high-throughput LLM serving.
- Streaming responses plus structured markup for product-aware UX.

## Agent-Backed Backend Slice

Core problem: replace frequently changing backend behavior with agent workflows while preserving deterministic boundaries. The GPT-5.5 backend source frames a candidate slice around validation, recommendation, reporting, and scheduling, with traditional code retained for auth, writes, payments, and compliance.

Useful patterns:

- Run agents side-by-side with existing code before cutover.
- Validate behavior with output suites rather than only implementation-level unit tests.
- Log agent decisions and tool calls for observability.
- Monitor token/API costs as part of system cost.
- Keep critical security and mutation paths deterministic.

## Rewards Platform Flash Sale

Core problem: a consumer rewards platform grew from MVP traffic to major partner flash-sale traffic without revisiting its original monolithic architecture. The outage pattern was a classic scale transition: one application instance, one primary database, no cache, no rate limits, no circuit breakers, and insufficient observability.

Useful patterns:

- Treat early feature velocity as different from production readiness.
- Add cache and read replicas before predictable high-read spikes.
- Use rate limits and circuit breakers around high-volume and third-party paths.
- Split service boundaries only where scaling and fault isolation justify the cost.
- Add metrics, dashboards, tracing, backups, and failure drills before the next major event.

## Snapchat Bento ML Platform

Core problem: serve over a billion ranking predictions per second for content recommendations while optimizing infrastructure splits and feature delivery speeds.

Useful patterns:
- Candidate Retrieval vs. Deep Ranking: Two-stage prediction pipeline filtering millions of items down to hundreds before deep scoring.
- CPU/GPU Splitting: Running neural net operations on GPUs while handling memory-intensive embedding lookups on CPUs.
- Co-location of Features: Keeping candidate features inside inference engine memory to eliminate network fanout.
- Offline-Online Sync: Synchronizing analytical store features (Apache Iceberg) with low-latency key-value stores (Robusta on Spark).
- Raw Byte Transfer: Deferring feature deserialization and sending raw bytes directly to the inference engine to minimize serialisation overhead.

## Netflix Multimodal Video Search

Core problem: allow creative editors to search millions of video frames and audio clips using natural language queries with sub-second latency.

Useful patterns:
- Multimodal Space Fusion: Encoding text, visual frames (Vision Transformers / CLIP ViT), and audio tracks (CLAP) into a shared embedding space.
- Fusion Alignment: Tuning fusion pipelines to prevent model representation mismatch and search query skew.
- Temporal Segment Hashing: Hashing video chunks temporally to index and retrieve precise frame sequences.

## Production Web Application Firewall (WAF)

Core problem: intercept and inspect high-throughput HTTP requests to filter malicious payloads (SQL Injection, XSS) on latency-critical packet paths.

Useful patterns:
- Tokio Asynchronous Threading: Using non-blocking executors in Rust to parse and route requests at scale.
- 5-Layer WAF Model: Layering TCP Listening, HTTP parsing, rule-based signature checks, upstream proxying (Hyper), and structured tracing.
- Signature Pre-compilation: Pre-compiling rule regular expressions at startup to avoid runtime compilation pauses.

## Dropbox Nova: AI Agent Platform at Scale

Core problem: let engineers describe tasks in plain language and run agentic workflows in a controlled environment, with the agent producing ~1 in 12 pull requests at Dropbox.

Useful patterns:

- **Bottleneck shift**: accelerating generation shifts pressure to review, CI systems, validation workflows, and release coordination — not eliminating the SDLC bottleneck, just moving it.
- **4-stage measurement model**: Fuel (AI usage) → Adoption (workflow changes) → Output (production contributions) → Impact (customer value).
- **Agent scope**: migrations, flaky test remediation, bug investigation, dependency updates alongside feature work.
- **System advantage**: comes from context, internal tooling, quality controls, and workflows built around models, not model access itself.
- **Upstream pressure**: agentic engineering moves more pressure into product and design — sharper problem framing is required when agents handle implementation.

## Dropbox Edison: Local-First Sync Engine

Core problem: transform a thin web UI client (dropbox.com) into a capable local-first application that can read, write, and sync asynchronously, supporting offline use and optimistic UI.

Useful patterns:

- **Two-layer architecture**: Edison Engine (local-first sync engine) + Sync Service (persistent WebSocket connection).
- **Multi-tab coordination**: BroadcastChannel API for cross-tab state synchronization.
- **Durable store**: IndexedDB with specialized schema for file metadata and content.
- **Optimistic UI**: user actions applied immediately to local state, then synced to server.
- **Conflict resolution**: handling concurrent edits across devices and tabs.
- **Change propagation**: WebSocket-based notifications from server to all connected clients.
- **Unified storage layer**: all components read/write through a shared layer instead of independent server fetches.

## LinkedIn FishDB: Feed Retrieval Engine

Core problem: serve LinkedIn's Feed for over a billion members with reliable millisecond latency, using a Rust-based storage and retrieval engine deployed across 48 shards.

Useful patterns:

- **Document-oriented model**: each document is a typed field collection, supporting Feed, Notification Center, and Jobs with a single engine.
- **Two-phase query execution**: pre-filtering (index scanning) + result processing (projection, sorting, pagination).
- **Index diversity**: sorted-set indexes (B-tree) for point lookups and range scans, bit-sliced indexes for numeric range queries, inverted indexes for full-text search.
- **Memory allocation at scale**: hashbrown::HashMap at ~56-59M entries per shard (~1.75 GB). Resize at 58.7M keys triggered jemalloc `brk()` → kernel `mmap_lock` contention → Tokio runtime freeze (see [[sources/linkedin-58m-key-hashmap-freeze|58M-key freeze case study]]).
- **Fix**: pre-allocation with `HashMap::with_capacity()`.

## LinkedIn Semantic Search: GPU-Accelerated EBR

Core problem: replace keyword matching with semantic search using LLMs at LinkedIn's scale — millions of real-time queries per second.

Useful patterns:

- **GPU-accelerated exhaustive vector search**: embedding-based retrieval on CUDA-enabled GPUs.
- **Two-stage ranking**: Cross-Encoder SLM on SGLang for relevance/engagement scoring after EBR candidate retrieval.
- **Hybrid feature pipeline**: offline (Spark, Flyte) for large-scale embedding generation + nearline (Flink) for low-latency feature updates.
- **Latency optimization**: score caching, ranking-depth controllers, traffic shaping, context compression.
- **Auction layer**: budget and pacing strategies balance relevance, engagement, and business metrics.

## HashMap Freeze: Cross-Layer Debugging at Scale

Core problem: intermittent 15-second freezes in FishDB (LinkedIn's Rust feed retrieval engine) with no logs, no obvious trigger, and no reproducible test case — each freeze breaching the 99.9% availability SLO for a minute before self-recovering.

Useful patterns:

- **Automated profiling instrumentation**: record stack traces at 1ms intervals with low overhead to catch intermittent events.
- **Cross-layer analysis**: trace from application data structure (HashMap) → allocator (jemalloc `brk()`) → kernel (`mmap_lock` contention) → async runtime (Tokio task freeze).
- **Root cause**: a single HashMap resize at ~58.7M keys. `HashMap::resize` → jemalloc calls `brk()` → acquires kernel `mmap_lock`. Page faults in any Tokio task contend on same lock → entire async runtime freezes.
- **Fix**: pre-allocate with `HashMap::with_capacity()`.

## Monolith-to-Service Migration Patterns

Core problem: safely decompose a monolithic application into decoupled, scale-independent microservices without risking operational downtime.

Useful patterns:
- Strangler Fig Pattern: Intercepting request traffic at an API gateway/proxy, redirecting specific paths to new microservices while legacy logic is phased out.
- Parallel Run Pattern: Routing traffic concurrently to both monolith and service to verify output equivalence before final cutover.
- Collaborator Pattern: Decorating monolithic modules with service wrappers instead of changing legacy codebase logic directly.
- Change Data Capture (CDC): Streaming real-time database write streams (e.g. from transaction logs) to synchronise microservice databases.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Source: [[sources/system-design-course|System Design Course]]
- Source: [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]]
- Source: [[sources/gpt-5-5-agents-replaced-python-backend|GPT-5.5 Agents Replaced My Python Backend]]
- Source: [[sources/unlock-system-design-production|Unlock Production System Design Case Study]]
- Source: [[sources/snapchat-billion-predictions|Snapchat Bento ML Platform Architecture]]
- Source: [[sources/netflix-multimodal-video-search|Netflix Multimodal Video Search Architecture]]
- Source: [[sources/production-firewalls-rust|Production Firewall Architecture in Rust]]
- Source: [[sources/monolith-to-service-migration|Monolith to Service Migration Strategies]]
- Source: [[sources/kensho-multi-agent|Kensho Financial Multi-Agent Retrieval Architecture]]
- Source: [[sources/madrigal-multi-agent|Madrigal Pharmaceuticals Agentic Research Platform]]
- Source: [[sources/dropbox-beyond-code-generation|Beyond Code Generation: Dropbox Nova]]
- Source: [[sources/dropbox-edison-web-performance|Dropbox Edison: Local-First Web Client]]
- Source: [[sources/linkedin-fishdb-retrieval-engine|FishDB: LinkedIn Feed Retrieval Engine]]
- Source: [[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]]
- Source: [[sources/linkedin-58m-key-hashmap-freeze|The 58-Million-Key Freeze: HashMap Resize at Scale]]
