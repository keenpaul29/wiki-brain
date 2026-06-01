---
title: Infrastructure Primitives
type: concept
created: 2026-04-28
tags:
  - concept
  - infrastructure
  - system-design
---

# Infrastructure Primitives

Infrastructure primitives are the reusable building blocks that appear across system designs. The system design source covers them as foundational vocabulary before moving into larger architectures.

## Networking

- IP addresses identify devices on networks.
- OSI layers provide a shared model for reasoning about network behavior.
- TCP provides ordered, reliable delivery with more overhead.
- UDP provides lower-latency, connectionless delivery without guaranteed delivery.
- QUIC builds reliable encrypted transport on UDP, giving HTTP/3 transport-native multiplexed streams, shorter TLS-integrated handshakes, userspace congestion-control updates, and connection migration through opaque connection IDs.
- DNS maps human-readable names to network addresses through resolvers, root servers, TLD nameservers, and authoritative nameservers.

## Traffic and Delivery

- Load balancers distribute traffic across servers and reduce single points of failure.
- CDNs place static or cacheable content closer to users.
- Forward proxies act on behalf of clients.
- Reverse proxies act on behalf of servers.
- Tunnels let a connector establish outbound connectivity so local services or private network ranges can be reached through a managed edge without opening direct inbound ports.
- API gateways centralize cross-cutting concerns such as routing, authentication, rate limits, and request shaping.

## Compute and Deployment

- Virtual machines isolate full operating environments through a hypervisor.
- Containers package application processes and dependencies more lightly than VMs.
- Cloud development environments become an infrastructure primitive for background agents: agents need isolated, reproducible, fully provisioned environments that can run many build/test loops in parallel.
- Dev Container specs codify runtime dependencies, tools, ports, lifecycle hooks, and setup steps so human and agent environments can be recreated consistently.
- Container image construction affects both delivery speed and security: multi-stage builds, lightweight bases, `.dockerignore`, and stable layer ordering keep images smaller and builds more cacheable.
- Docker and Podman share much of the Dockerfile surface, but differ operationally around daemon use, rootless workflows, systemd integration, Compose compatibility, volume permissions, and registry auth.
- Service discovery lets services find each other dynamically in changing environments.
- Service meshes manage service-to-service traffic, observability, and security in microservice systems.

## Storage Engine Design

At feed-scale retrieval, the storage engine itself becomes an infrastructure primitive. LinkedIn's FishDB demonstrates key design choices:

- **Document-oriented data model**: typed field collections supporting multiple use cases (Feed, Notification Center, Jobs) from a single engine.
- **Indexing strategy**: sorted-set indexes for point lookups, bit-sliced indexes for numeric range queries, inverted indexes for full-text — chosen per field type rather than one-size-fits-all.
- **Memory allocator interaction**: using jemalloc as the Rust allocator means HashMap resize events can trigger `brk()` syscalls, which acquire the kernel `mmap_lock` and can freeze the async runtime under contention. Pre-allocation avoids resize syscalls entirely.
- **Async runtime coupling**: Tokio's cooperative scheduling means any task blocking on a kernel lock blocks all tasks. The allocator, data structure choices, and runtime are not independent.

## Client-Side Sync Infrastructure

Local-first web applications introduce infrastructure primitives on the client side:

- **IndexedDB as local durable store**: specialized schemas for file metadata and content, replacing independent server fetches.
- **BroadcastChannel API**: cross-tab state synchronization without server round-trips.
- **WebSocket change notifications**: persistent connections for propagating server-side changes to all connected clients.
- **Optimistic updates**: mutations apply locally first, then sync — the infrastructure must support rollback and conflict resolution.

## GPU-Accelerated Vector Search

At scale, keyword-based retrieval is supplemented or replaced by embedding-based retrieval (EBR) using dense vector representations. LinkedIn's semantic search infrastructure runs GPU-accelerated exhaustive vector search on CUDA-enabled GPUs at millions of QPS. Query embeddings are compared against document embeddings using exhaustive search for maximum recall, then refined through a Cross-Encoder SLM for ranking. Key architectural components:
- Hybrid inference pipeline: offline (Spark, Flyte) for large-scale embedding generation, nearline (Flink) for low-latency updates.
- Score caching, ranking-depth controllers, and traffic shaping to manage cost and latency.
- Context compression to reduce the input size passed through expensive models.

## AI Inference at Scale

- Accelerators (GPUs/TPUs/custom chips) are often required for low-latency LLM serving.
- Compilers and runtimes matter: graph compilation and kernel selection can materially change throughput/latency.
- Batching strategies are part of the serving architecture; continuous batching can reduce tail latency under load.
- Streaming responses improve perceived latency, but require careful client/server coordination.
- Local LLM serving capacity depends on prefill, decode, KV cache size, context length, quantization, model residency, and scheduler design.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/local-llm-serving|Local LLM Serving]]
- Related: [[concepts/fishdb|FishDB]]
- Related: [[concepts/local-first-architecture|Local-First Architecture]]
- Source: [[sources/system-design-course|System Design Course]]
- Related source: [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]]
- Related source: [[sources/create-tunnel-dashboard|Create a tunnel (dashboard)]]
- Related source: [[sources/docker-image-security-optimization|Docker Image Security and Optimization]]
- Related source: [[sources/podman-python-deploys|Podman for Faster Python Deploys]]
- Related source: [[sources/local-llm-serving-mental-model|Local LLM Serving Mental Model]]
- Related source: [[sources/quic-head-of-line-blocking|The Packet Drop That Froze Three Requests at Once]]
- Related source: [[sources/localhost-cloud-dev-agents|The Last Year of Localhost]]
- Related source: [[sources/meta-webrtc-fork-modernization|Escaping the Fork: Meta WebRTC Modernization]]
- Related: [[concepts/local-llm-serving|Local LLM Serving]]
- Related source: [[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]]
- Related source: [[sources/linkedin-fishdb-retrieval-engine|FishDB: LinkedIn Feed Retrieval Engine]]
- Related source: [[sources/linkedin-58m-key-hashmap-freeze|The 58-Million-Key Freeze: HashMap Resize at Scale]]
- Related source: [[sources/dropbox-edison-web-performance|Dropbox Edison: Local-First Web Client]]
