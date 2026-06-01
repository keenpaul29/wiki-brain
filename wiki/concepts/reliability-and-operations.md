---
title: Reliability and Operations
type: concept
created: 2026-04-28
tags:
  - concept
  - reliability
  - operations
  - system-design
---

# Reliability and Operations

Reliability and operations convert an architecture from a diagram into a system that survives load, failures, abuse, and change. The system design source covers availability, fault tolerance, rate limiting, disaster recovery, security, and observability-oriented service management.

## Availability and Failure

- Availability measures how often a system is usable.
- Reliability measures whether the system performs correctly over time.
- Fault tolerance means the system continues operating despite component failures.
- Redundant load balancers, replicas, caches, and service instances reduce single points of failure.

## Control and Protection

- **Load Balancing**: Distributes incoming traffic across instances. Strategies include:
  - *Round Robin*: Simple sequential routing.
  - *Weighted Round Robin*: Allocates requests based on pre-assigned server capacities.
  - *Least Connections*: Routes traffic to the instance with the minimum active connection count.
  - *Intelligent/Composite*: Scores healthy nodes based on active connections, CPU utilization, and latency.
- **Rate Limiting**: Protects systems from abuse, traffic spikes, and noisy clients. Algorithms include leaky bucket, token bucket, fixed window, sliding log, and sliding window.
- **Circuit Breakers**: Stop cascading failures by failing fast. They transition through three states:
  - `CLOSED`: Normal operation; all requests pass through.
  - `OPEN`: Failures exceed threshold; requests fail fast immediately, avoiding downstream service load.
  - `HALF_OPEN`: Periodically passes probe requests to test downstream recovery.
- **Fallback Logic**: Resolves open-circuit failures gracefully by returning cached data, default models, or static profiles.
- **Composite Resilience**: Combines load balancing with per-instance circuit breakers to isolate and bypass specific failing nodes while preserving overall cluster availability.
- **Protocol Resilience**: QUIC avoids TCP-level head-of-line blocking by making streams a transport-layer concept, and connection IDs let mobile clients migrate between networks without resetting the application connection.
- **Backpressure**: Prevents producers from overwhelming consumers.
- **Microservice Boundaries**: Turn local function calls into fallible network calls, so retries, timeouts, circuit breakers, and monitoring become part of the architecture rather than optional polish.

## Service Operations

- SLA: external promise to users or customers.
- SLO: internal or external target for reliability.
- SLI: measured indicator used to judge whether the target is met.
- Disaster recovery uses RTO and RPO to reason about recovery time and acceptable data loss.
- Cold sites, hot sites, and backups represent different cost/recovery tradeoffs.

## Traffic Shaping and Ranking Controllers

At search scale, reliability engineering extends beyond basic rate limiting into traffic shaping:

- **Ranking-depth controllers**: dynamically manage how many candidates progress from retrieval to deeper ranking stages, preventing expensive models from being invoked unnecessarily.
- **Score caching**: caches relevance scores so repeated or near-identical queries skip expensive re-scoring.
- **Traffic shaping**: balances load during peak times by adjusting query volume to downstream ranking and auction systems.
- **Auction layer with pacing**: budget and pacing strategies balance relevance, engagement, and business metrics — a form of reliability-aware load management.

## Conflict Resolution and Offline Resilience

Local-first architectures shift reliability requirements to the client:

- **Optimistic UI**: mutations apply immediately to local state. Reliability depends on the sync layer's ability to detect and resolve conflicts when the server state diverges.
- **Multi-tab coordination**: BroadcastChannel API synchronizes state across tabs, preventing stale-read hazards without server involvement.
- **Offline operation**: the local store (IndexedDB) serves reads without network. The sync layer must handle reconnection, queue management, and conflict resolution when connectivity returns.
- **Durable store schema**: IndexedDB with specialized schemas for file metadata and content, designed for recovery and consistency across sessions.

## Agent Operations

Agent-backed production paths need reliability controls that ordinary request handlers may not expose by default: decision logs, tool-call traces, output validation, fallback paths, latency distribution monitoring, and API cost tracking. Debugging shifts from stack traces alone toward reconstructing the agent's context, instructions, tools, and intermediate decisions.

Production AI systems add specific failure modes: weak retrieval, hallucinated answers, agent loops, tool-call failures, prompt injection, runaway inference cost, inconsistent output format, and missing evaluation gates. Mature systems separate probabilistic decisions from deterministic execution, enforce step limits, validate tool inputs and outputs, replay traces, and run both offline regression evals and online drift checks.

AI-assisted engineering also needs operational guardrails before code reaches production. Destructive commands, database resets, infrastructure deletion, and deployment changes should require human review, scoped credentials, backups, staging, CI/CD gates, and auditable approval steps. Remote or containerized agent environments reduce blast radius only when their credentials and mounts are also bounded.

Background coding agents add an environment-reliability requirement: an agent that cannot run the app, reach required services, seed data, execute tests, and validate changes in an isolated environment will produce diffs rather than merge-ready work. VM isolation, short-lived credentials, and policy enforcement limit blast radius when agents execute arbitrary code.

Local LLM serving needs its own operational telemetry. Prefill duration, decode duration, token counts, queue depth, GPU memory, loaded models, truncation checks, and p50/p95/p99 latency by request type are required to distinguish prefill, decode, queuing, eviction, and memory pressure problems.

## Security and Identity

- OAuth 2.0 delegates authorization.
- OpenID Connect adds identity on top of OAuth.
- SSO centralizes authentication across services.
- TLS secures transport; mTLS authenticates both sides and is common in zero-trust microservice environments.
- Zero Trust tunnels should pair exposed hostnames with explicit access policy where needed, and connector health states should be monitored after setup.
- Container operations should avoid unnecessary daemon exposure, prefer rootless execution where practical, scan images during the lifecycle, and protect remote engine access with SSH or TLS.
- Model-serving endpoints such as Ollama should not be exposed directly without a reverse proxy, TLS, authentication, and rate limits.
- Screen capture protection combines OS-level and application-level controls. Electron's `setContentProtection(true)` maps to `SetWindowDisplayAffinity(WDA_EXCLUDEFROMCAPTURE)` on Windows and `NSWindowSharingNone` on macOS. Transparent overlays, click-through states, and focus management prevent sensitive UI from appearing in screen-sharing streams.

## Migration and Release Risk

Framework upgrades can make systems safer while still breaking production behavior. FastAPI `0.115` examples include stricter dependency signatures, response validation, CORS enforcement, WebSocket disconnect handling, optional query typing, and serializer changes. The safe pattern is to categorize failures, fix critical paths first, test with real frontend/configuration behavior, and roll out gradually with monitoring.

Large dependency-fork migrations need the same rollout discipline at library scale. Meta's WebRTC migration used a dual-stack shim, runtime flavor dispatch, generated adapters, and A/B testing so old and new implementations could coexist until the upstream-based path proved safe.

## Kernel-Level Lock Contention in Async Runtimes

Async runtimes (Tokio, async-std) with stackless coroutines share a single address space, making them vulnerable to kernel-level lock contention. A case study from LinkedIn's FishDB service: a Rust HashMap resize at ~58.7M keys caused jemalloc to call `brk()` to extend the heap, which acquires the kernel's `mmap_lock`. This same lock is acquired during page faults. Any page fault in any task would contend on the same lock held by the resizing thread, freezing the entire async runtime for up to 15 seconds.

Key lessons:
- Pre-allocate collections with `HashMap::with_capacity()` when size is known in advance.
- Cross-layer debugging (application → allocator → kernel) is essential for intermittent performance issues.
- Automated profiling instrumentation (1ms stack trace recording) can catch elusive events without high overhead.

## Exception Taxonomy and Error Surfacing

Operational reliability depends on classifying failures correctly. Expected business outcomes should remain explicit control flow, while exceptional failures should propagate into centralized handlers, structured logs, and alerting paths. Blanket `try-catch` blocks that swallow context reduce observability and delay incident detection.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Source: [[sources/system-design-course|System Design Course]]
- Source: [[sources/gpt-5-5-agents-replaced-python-backend|GPT-5.5 Agents Replaced My Python Backend]]
- Source: [[sources/microservices-vs-monoliths|Microservices vs. Monoliths]]
- Source: [[sources/create-tunnel-dashboard|Create a tunnel (dashboard)]]
- Source: [[sources/fastapi-0-115-migration|FastAPI 0.115 Migration Breakages]]
- Source: [[sources/production-ai-failure-modes|Beyond Shipped - Production AI Failure Modes]]
- Source: [[sources/local-llm-serving-mental-model|Local LLM Serving Mental Model]]
- Source: [[sources/local-llm-serving-operational-playbook|Local LLM Serving Operational Playbook]]
- Source: [[sources/docker-image-security-optimization|Docker Image Security and Optimization]]
- Source: [[sources/podman-python-deploys|Podman for Faster Python Deploys]]
- Source: [[sources/unlock-system-design-production|Unlock Production System Design Case Study]]
- Source: [[sources/ai-work-safety|How to Use AI at Work Without Breaking Your Systems]]
- Source: [[sources/ai-remote-development|Enhance Productivity with AI + Remote Dev]]
- Source: [[sources/exception-handling-patterns|Exception Handling Patterns Over Blanket try-catch]]
- Source: [[sources/latency-gambler-day-8|Load Balancing & Circuit Breaker Patterns]]
- Source: [[sources/quic-head-of-line-blocking|The Packet Drop That Froze Three Requests at Once]]
- Source: [[sources/localhost-cloud-dev-agents|The Last Year of Localhost]]
- Source: [[sources/meta-webrtc-fork-modernization|Escaping the Fork: Meta WebRTC Modernization]]
- Source: [[sources/linkedin-58m-key-hashmap-freeze|The 58-Million-Key Freeze: HashMap Resize at Scale]]
- Source: [[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]]
- Source: [[sources/dropbox-edison-web-performance|Dropbox Edison: Local-First Web Client]]
- Source: [[sources/electron-screen-capture-protection|Electron Screen Capture Protection]]
