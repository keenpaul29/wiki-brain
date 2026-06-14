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

The 2026-06-06 ingest adds four new building blocks. **Observability** (logs/metrics/traces + four golden signals + SLO burn-rate alerting) turns reactive monitoring into structured investigation. **Integration testing with real services** (Testcontainers, Toxiproxy, clean-before strategy) catches schema and network failures that mocks miss. **CI/CD pipeline design** (trunk-based development, immutable artifacts, deployment strategies, DORA metrics) formalizes the path from commit to production. **Raft consensus** (leader election, log replication, quorum math, CP semantics) explains how etcd and similar stores maintain correctness across node failures.

Recent networking and data-pattern sources sharpen two of those primitives: QUIC/HTTP3 fixes TCP-level head-of-line blocking by moving stream multiplexing into the transport layer, while CQRS and CDC show how event streams and projection models prevent reads, writes, and downstream consumers from fighting over one schema.

## Deeper Sub-Concepts

Several new sources add specialized design areas:

- **[[concepts/fishdb|FishDB]]** — LinkedIn's Rust-based feed retrieval engine: document-oriented storage, bitmap and inverted indexes, memory-allocator interaction at scale.
- **[[concepts/local-first-architecture|Local-First Architecture]]** — local reads/writes with background sync, optimistic UI, offline resilience, multi-tab coordination via BroadcastChannel.

## New Case Studies

- **Dropbox Nova** ([[sources/dropbox-beyond-code-generation|Beyond Code Generation]]): agent platform producing ~1-in-12 PRs, 4-stage measurement model, bottleneck-shift insight.
- **Dropbox Edison** ([[sources/dropbox-edison-web-performance|Edison Web Performance]]): local-first sync engine on the web — IndexedDB, BroadcastChannel, optimistic UI.
- **FishDB** ([[sources/linkedin-fishdb-retrieval-engine|FishDB]] + [[sources/linkedin-58m-key-hashmap-freeze|58M-Key Freeze]]): Rust feed retrieval engine, HashMap resize → kernel lock → async freeze.
- **LinkedIn Semantic Search** ([[sources/linkedin-semantic-search-rebuild|Search Tech Stack Rebuild]]): GPU EBR + Cross-Encoder SLM, hybrid Spark/Flink pipeline, auction layer.

- **Instagram Explore** ([[sources/instagram-explore-recommendations|Scaling Instagram Explore Recommendations]]): multi-stage recommendation funnel, Two Tower retrieval, cached embeddings, MTML ranking, value-model scoring, final integrity/diversity reranking.
- **WhatsApp Rust Security** ([[sources/whatsapp-rust-security|Rust at Scale: WhatsApp Security]]): client-side defense-in-depth for untrusted media, differential fuzzing, memory-safe rewrite, and large-scale cross-platform rollout.
- **API Protocol Decision Framework** ([[sources/rest-vs-graphql-vs-grpc|REST vs GraphQL vs gRPC]]): layered protocol architecture with benchmarks and decision criteria for REST, GraphQL, and gRPC at public, frontend, and internal layers.
- **Cloudinary Image Transformations** ([[sources/image-transformations-for-developers|Image Transformations for Developers]]): CDN-based dynamic image transformation via URL parameters, chained transformations, automatic format selection, face detection, and smart cropping.
- **Observability Diagnosis Workflow** ([[sources/observability-in-distributed-systems|Observability in Distributed Systems]]): three pillars plus four golden signals with metrics→traces→logs investigation pipeline and SLO burn-rate alerting.
- **Raft Consensus** ([[sources/raft-consensus-explained|Raft Consensus Explained]]): leader election, log replication, ConflictTerm backtracking, commit index rule, quorum math, and CP semantics for etcd/CockroachDB.
- **Integration Testing Without Mocks** ([[sources/integration-testing-real-services|Testing with Real Services]]): Testcontainers, Toxiproxy failure injection, clean-before strategy, and the 50/40/10 coverage pyramid.
- **Bulletproof CI/CD Pipeline** ([[sources/bulletproof-ci-cd-pipeline|Building a Bulletproof CI/CD Pipeline]]): trunk-based development, immutable artifacts, deployment strategies, rollback automation, and DORA metrics.

## Subpages

- [[concepts/system-design-interview-workflow|System Design Interview Workflow]]
- [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- [[concepts/fishdb|FishDB]] (sub-concept: storage engine architecture)
- [[concepts/local-first-architecture|Local-First Architecture]] (sub-concept: client-side data patterns)
- [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- [[concepts/reliability-and-operations|Reliability and Operations]]
- [[concepts/system-design-case-studies|System Design Case Studies]]
- [[concepts/distributed-coordination|Distributed Coordination and Consensus]]
- [[concepts/security-patterns|Security Patterns]]
- [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]]
- [[concepts/api-management|API Management]]
- [[concepts/microservices-architecture|Microservices Architecture]]

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

Engineering blogs are a practical case-study stream for that active practice. [[sources/engineering-blogs-2025|Engineering Blogs To Follow in 2025]] is valuable mainly as a source map: read company blogs for real constraints, migrations, and failures, then distill each article into reusable primitives or case studies.

## Access Pattern First

Even small data-structure choices follow system-design logic: start from access patterns. Pure membership checks point toward hash sets; mostly static ordered data can use sorted arrays and binary search; ordered range queries need tree-like structures; memory-constrained membership may justify probabilistic structures.

## Sub-Concept Links

- [[concepts/fishdb|FishDB]] — storage engine architecture (Rust, Tokio, jemalloc, index design)
- [[concepts/local-first-architecture|Local-First Architecture]] — client-side sync engines, optimistic UI, offline resilience
- [[concepts/local-llm-serving|Local LLM Serving]] — inference latency, KV cache, context length, serving operations
- [[concepts/frontend-build-performance|Frontend Build Performance]] — bundle optimization, migration strategy, tree shaking
- [[concepts/software-design-patterns|Software Design Patterns]] — selecting abstractions from code pain
- [[concepts/distributed-coordination|Distributed Coordination and Consensus]] — leader election, Raft, vector clocks, consensus algorithms
- [[concepts/security-patterns|Security Patterns]] — authentication, authorization, defense in depth, secure communication
- [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]] — retry, timeout, circuit breaker, fallback, graceful degradation, bulkhead
- [[concepts/api-management|API Management]] — API gateway, rate limiting, versioning, BFF pattern
- [[concepts/microservices-architecture|Microservices Architecture]] — service discovery, bulkhead, Netflix OSS patterns, health checks
- [[concepts/api-protocol-selection|API Protocol Selection]] — REST vs GraphQL vs gRPC decision framework
- [[concepts/event-driven-architecture|Event-Driven Architecture]] — events, CQRS, CDC, event sourcing, sagas
- [[concepts/performance-engineering|Performance Engineering]] — profiling, load testing, caching, database optimization
- [[concepts/team-topologies|Team Topologies]] — Conway's Law, team types, cognitive load, platform teams

## Source Support

- [[sources/system-design-course|System Design Course]]
- [[sources/ai-replaced-80-percent-coding|AI Replaced 80% of Coding]]
- [[sources/unlock-system-design-production|Unlock Production System Design Case Study]]
- [[sources/dictionary-problem-fast-lookups|The Dictionary Problem - Fast Lookups in Large Collections]]
- [[sources/caching-patterns|Essential Caching Patterns and Strategies]]
- [[sources/quic-head-of-line-blocking|The Packet Drop That Froze Three Requests at Once]]
- [[sources/cqrs-read-write-separation|The Read That Was Killing the Write]]
- [[sources/change-data-capture-event-log|Your Database Has Been Writing an Event Log the Whole Time]]
- [[sources/google-l7-system-design|Google L7 System Design Interview Insights]]
- [[sources/system-design-study-roadmap|Curated System Design Study Roadmap]]
- [[sources/dropbox-beyond-code-generation|Beyond Code Generation: Dropbox Nova]]
- [[sources/dropbox-edison-web-performance|Dropbox Edison: Local-First Web Client]]
- [[sources/linkedin-fishdb-retrieval-engine|FishDB: LinkedIn Feed Retrieval Engine]]
- [[sources/linkedin-58m-key-hashmap-freeze|The 58-Million-Key Freeze: HashMap Resize at Scale]]
- [[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]]
- [[concepts/memory-safety-strategy|Memory Safety and Defense-in-Depth]]
- [[concepts/ml-recommendation-systems|ML Recommendation Systems at Scale]]
- [[sources/rest-vs-graphql-vs-grpc|REST vs GraphQL vs gRPC]]
- [[sources/image-transformations-for-developers|Image Transformations for Developers]]
- [[sources/observability-in-distributed-systems|Observability in Distributed Systems]]
- [[sources/raft-consensus-explained|Raft Consensus Explained]]
- [[sources/integration-testing-real-services|Testing with Real Services]]
- [[sources/bulletproof-ci-cd-pipeline|Building a Bulletproof CI/CD Pipeline]]
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
