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
- Edge appliances inside ISP networks for high-volume video bytes.
- Control plane/data plane split: cloud services authorize playback and steer clients; edge caches serve the media segments.
- Predictive off-peak fill: pre-position likely content before demand spikes.
- Client-side fallback across ranked edge endpoints.
- Per-title encoding and adaptive bitrate variants.
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

## WebSocket Realtime Applications

Core problem: deliver low-latency bidirectional updates without repeated request/response overhead.

Useful patterns:

- **Protocol upgrade**: start with HTTP, then switch protocols through the WebSocket handshake.
- **Full-duplex channel**: both client and server can send messages independently.
- **Heartbeat management**: ping/pong frames detect dead connections.
- **Stateful connection operations**: load balancing and failover need sticky routing or shared state.
- **Use-case fit**: chat, collaboration, multiplayer games, financial ticks, and live score/media updates.

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

## Instagram Explore Recommendations

Core problem: recommend relevant media in real time from billions of possible items to hundreds of millions of users.

Useful patterns:

- **Multi-stage funnel**: retrieval, first-stage ranking, second-stage ranking, final reranking.
- **Mixed retrieval sources**: heuristic, real-time, pre-generated, and ML-based candidate sources combined with tunable weights.
- **Two Tower retrieval**: cacheable user and item embeddings support efficient ANN lookup without scanning all items.
- **Distilled first-stage ranker**: lightweight model predicts which items the heavier second-stage model would select.
- **MTML second-stage ranker**: heavier model consumes user-item interaction features and predicts multiple engagement outcomes.
- **Value model scoring**: combines positive and negative predicted outcomes with tunable weights.
- **Final reranking**: integrity filters, diversity rules, and business constraints adjust the scored list before presentation.

## WhatsApp Rust Media Security

Core problem: protect billions of users from malicious or malformed media files even when downstream OS or app libraries may contain parser vulnerabilities.

Useful patterns:

- **Defense in depth**: inspect media consistency before downstream libraries process untrusted files.
- **Memory-safe rewrite**: replace high-risk C++ parsing code with Rust where untrusted inputs are processed automatically.
- **Parallel implementation**: build Rust alongside C++ to preserve compatibility during migration.
- **Differential fuzzing**: compare implementations to catch behavior mismatches.
- **Risk-aware file checks**: detect malformed structures, risky PDF features, spoofed MIME/extension mismatches, and known dangerous file types.
- **Cross-platform rollout discipline**: handle binary size, build-system support, and compatibility across mobile, desktop, browser, and wearable targets.

## Cloudinary Image Transformations

Core problem: deliver dynamically transformed images (resize, crop, format, effects) on the fly from a single source image, served through a global CDN with caching.

Useful patterns:

- **URL-based transformation syntax**: parameters encoded in the delivery URL (`/c_thumb,g_face,h_200,w_200/r_max/f_auto/`), enabling on-the-fly derived asset generation without pre-processing.
- **Chained transformations**: each action applies to the result of the previous one (`fill → round → optimize`), composed via slash-separated URL components.
- **Action/qualifier separation**: action parameters perform operations (crop, resize, effect); qualifier parameters adjust behavior (gravity, color, position). One action per component, qualifiers in the same component.
- **Automatic format selection** (`f_auto`): delivers WebP or AVIF based on browser support. Quality auto (`q_auto`): balances file size and visual quality.
- **Smart cropping**: face detection (`g_face`), auto gravity (`g_auto`), and thumbnails (`c_thumb`) focus crops on the most relevant region.
- **CDN caching and versioning**: derived assets cached at edge; version component bypasses cache for updated assets. Transformation operations count toward billing.

## API Protocol Decision Framework

Core problem: choose and compose API protocols across public, frontend, and internal service boundaries to balance performance, maintainability, and compatibility.

Useful patterns:

- **Layer-specific protocol selection**: REST for public/external APIs (universal compatibility, HTTP caching), GraphQL for frontend-to-backend (flexible queries, no over-fetching), gRPC for service-to-service (binary protocol, streaming, strong contracts).
- **Performance layering**: benchmarks show gRPC ~4x smaller payloads than REST and ~3x lower P50 latency for service-to-service calls, but for browser-to-server the gap is negligible — network latency dominates.
- **Decision framework**: default to REST; add GraphQL when the frontend team is bottlenecked by endpoint changes; add gRPC when internal service latency profiling shows a bottleneck.
- **Migration path**: start simple (REST), add complexity only when specific pain justifies it. API gateway translates between layers.

## Monolith-to-Service Migration Patterns

Core problem: safely decompose a monolithic application into decoupled, scale-independent microservices without risking operational downtime.

Useful patterns:
- Strangler Fig Pattern: Intercepting request traffic at an API gateway/proxy, redirecting specific paths to new microservices while legacy logic is phased out.
- Parallel Run Pattern: Routing traffic concurrently to both monolith and service to verify output equivalence before final cutover.
- Collaborator Pattern: Decorating monolithic modules with service wrappers instead of changing legacy codebase logic directly.
- Change Data Capture (CDC): Streaming real-time database write streams (e.g. from transaction logs) to synchronise microservice databases.

## Observability in Distributed Systems

Core problem: diagnose failures in distributed systems where a single user request spans multiple services, each generating its own signals.

Useful patterns:
- **Three pillars**: logs (structured JSON with trace_id/span_id), metrics (counters, gauges, histograms), traces (distributed spans linked by trace ID).
- **Four golden signals** (Google SRE): latency at p50/p95/p99/p99.9, requests per second (traffic), error rate (explicit 5xx + implicit failures), and saturation of the most constrained resource.
- **Diagnosis workflow**: metrics identify scope → traces identify location → logs identify root cause.
- **OpenTelemetry**: instrument once via API/SDK, export to any backend via the Collector. Avoids vendor lock-in.
- **SLO burn-rate alerting**: fires when error budget is consumed too fast, reducing false positives from transient spikes.

## Raft Consensus

Core problem: maintain a consistent replicated log across nodes that tolerate (N-1)/2 failures without split-brain, used by etcd (Kubernetes), Consul, CockroachDB, and TiKV.

Useful patterns:
- **Leader election**: randomized timeouts (150-300ms) prevent split-brain. Candidates need up-to-date logs (higher last-term wins, longer log on tie).
- **Log replication**: leader appends uncommitted entries, sends AppendEntries to followers in parallel, commits on majority ack. ConflictTerm backtracking skips entire terms on rejection.
- **Commit index rule**: only advance commitIndex for current-term entries; prior-term entries commit transitively via the Log Matching Property (Raft paper Figure 8).
- **Production operations**: alert on leader churn (`etcd_server_leader_changes_seen_total[10m] > 3`), separate Raft timeout from request context, practice snapshot/restore quarterly.
- **Quorum math**: 3 nodes → 1 failure, 5 nodes → 2, 7 nodes → 3. CP system — minority rejects reads/writes during partition.

## Integration Testing with Real Services

Core problem: catch schema mismatches, network failures, database constraints, auth flow issues, and serialization errors that mock-heavy suites miss.

Useful patterns:
- **Testcontainers + Docker**: spin up real databases/services with exact production versions. Run actual migration scripts.
- **Credential hierarchy**: local `.env.test` → CI vault → secret manager. Tests degrade gracefully when credentials are missing.
- **Clean before tests**: crashed tests never run after-cleanup. Use try-finally for external services. Unique identifiers (`test-${pid}-${counter}`) for parallel test isolation.
- **Toxiproxy error injection**: latency → test retry logic, connection reset → test circuit breakers, rate limiting → test backoff behavior.
- **Coverage pyramid**: 50-60% unit (fast, business logic), 30-40% integration (real services), 5-10% E2E (critical journeys only).
- **CI staging**: unit on every commit, integration on main/ready PRs, E2E on main only. Cache Docker layers, parallelize independent suites.

## Code Smells and Refactoring

Core problem: code accumulates structural problems (smells) that increase maintenance cost and bug rate. A systematic approach is needed to identify and fix these patterns without changing observable behavior.

Useful patterns:

- **Smell families**: bloaters (Long Method, Large Class), OO abusers (Switch Statements, Temporary Field), change preventers (Shotgun Surgery), dispensables (Duplicate Code, Dead Code, Lazy Class, Speculative Generality), couplers (Feature Envy, Message Chains, Middle Man).
- **Extract Method**: when a comment explains a block, extract it into a method named after the comment. The most frequently useful refactoring.
- **Replace Conditional with Polymorphism**: eliminate switch/if-else chains on type codes.
- **Replace Magic Number with Symbolic Constant**: simplest high-impact readability refactoring.
- **Operational discipline**: identify smells during code review, apply one refactoring at a time with test verification, never conflate restructuring with feature work.
- **Refactoring is not adding features** — observable behavior must remain identical before and after.

## Software Estimation

Core problem: predict how long engineering work will take, given that uncertainty grows with task size and human bias distorts single-point forecasts.

Useful patterns:

- **Story points + modified Fibonacci**: relative sizing (1, 2, 3, 5, 8, 13, 20, 40, 100). Larger gaps reflect lower precision for larger tasks.
- **Planning Poker**: simultaneous independent estimates neutralize anchoring bias. Estimates within 20% of actual ~60% of the time.
- **T-shirt sizing** (XS-XXL): deliberately imprecise, best for roadmap-level planning and cross-functional communication.
- **Monte Carlo simulation**: probability distributions from historical throughput ("85% within 14 weeks") over deterministic dates.
- **Affinity estimation**: silent card sorting for large backlogs — 50-80 stories in under an hour.
- **Velocity tracking**: after 5-6 sprints, velocity stabilizes enough to forecast capacity.
- **Common mistakes**: converting points to hours, comparing team velocities, precise scales for uncertain work, switching scales mid-project.

## Backend Performance Engineering

Core problem: systematically identify and eliminate performance bottlenecks in backend services while maintaining correctness and reliability.

Useful patterns:

- **Performance budget**: define p50/p95/p99 latency, error rate, throughput targets before tuning.
- **Observe → Profile → Fix → Verify**: measure first, optimize second. Percentiles over averages.
- **CPU flame graphs**: wider frames consume more CPU time. Profile under realistic load, not isolation.
- **Load testing types**: smoke (basic verification), load (normal peak), stress (breaking point), spike (instant surge), soak (long-term stability), breakpoint (exact capacity).
- **N+1 query fix**: eager loading (JOIN), prefetch (batch IN), DataLoader (auto-batch).
- **Indexing discipline**: find slow queries via pg_stat_statements, use EXPLAIN ANALYZE, composite indexes with most selective column first, CREATE INDEX CONCURRENTLY.
- **Connection pool sizing**: (core_count × 2) + effective_spindle_count. 10-20 is sufficient. Increase when utilization >80%.
- **80/20 rule**: proper indexing solves ~80% of database performance problems. Read every slow query's execution plan.
- **Caching**: frequently-read rarely-changed data, 30-60 sec TTL, monitor hit rate (below 80% means ineffective).

## Bulletproof CI/CD Pipeline

Core problem: build a deployment pipeline that fails safely, fails early, recovers quickly, and never surprises production.

Useful patterns:
- **Core principles**: consistency (same path for every change), automation by default, fast feedback (<10-15 min CI), least privilege, and observability.
- **Trunk-based development**: short-lived branches, small frequent commits, mandatory but lightweight code review.
- **Build once, deploy everywhere**: immutable artifacts built exactly once. Never modify a built artifact.
- **Deployment strategies**: rolling (gradual updates), blue-green (traffic switch), canary (subset exposure). The safest strategy is the one your team understands under pressure.
- **Rollback**: single command or automated trigger. Feature flags complement rollback by allowing feature disable without redeploy.
- **DORA metrics**: deployment frequency, change failure rate, lead time for changes, mean time to recovery. Metrics guide improvement, not punishment.
- **Security integration**: SAST, dependency scanning, secrets scanning in CI. Ephemeral build agents, short-lived credentials.

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
- Source: [[sources/netflix-open-connect-cdn-strategy|Netflix Open Connect CDN Strategy]]
- Source: [[sources/intro-to-websockets|Intro to WebSockets]]
- Source: [[sources/production-firewalls-rust|Production Firewall Architecture in Rust]]
- Source: [[sources/monolith-to-service-migration|Monolith to Service Migration Strategies]]
- Source: [[sources/kensho-multi-agent|Kensho Financial Multi-Agent Retrieval Architecture]]
- Source: [[sources/madrigal-multi-agent|Madrigal Pharmaceuticals Agentic Research Platform]]
- Source: [[sources/dropbox-beyond-code-generation|Beyond Code Generation: Dropbox Nova]]
- Source: [[sources/dropbox-edison-web-performance|Dropbox Edison: Local-First Web Client]]
- Source: [[sources/linkedin-fishdb-retrieval-engine|FishDB: LinkedIn Feed Retrieval Engine]]
- Source: [[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]]
- Source: [[sources/linkedin-58m-key-hashmap-freeze|The 58-Million-Key Freeze: HashMap Resize at Scale]]
- Source: [[concepts/memory-safety-strategy|Memory Safety and Defense-in-Depth]]
- Source: [[concepts/ml-recommendation-systems|ML Recommendation Systems at Scale]]
- Source: [[sources/image-transformations-for-developers|Image Transformations for Developers]]
- Source: [[sources/rest-vs-graphql-vs-grpc|REST vs GraphQL vs gRPC]]
- Source: [[sources/observability-in-distributed-systems|Observability in Distributed Systems]]
- Source: [[sources/raft-consensus-explained|Raft Consensus Explained]]
- Source: [[sources/integration-testing-real-services|Testing with Real Services]]
- Source: [[sources/bulletproof-ci-cd-pipeline|Building a Bulletproof CI/CD Pipeline]]
- Source: [[sources/code-smells-refactoring-techniques|Code Smells and Refactoring Techniques]]
- Source: [[sources/software-estimation-techniques|Software Estimation Techniques]]
- Source: [[sources/backend-performance-engineering|Backend Performance Engineering]]
- Source: [[sources/sre-incident-management|SRE Incident Management]]
- Source: [[sources/team-topologies-org-design|Team Topologies: Engineering Organization Design]]
