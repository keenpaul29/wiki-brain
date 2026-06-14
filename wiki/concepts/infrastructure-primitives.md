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
- Purpose-built edge CDNs can move the data plane into ISP networks while keeping authorization, manifests, and steering in a cloud control plane.
- Dynamic media CDNs (such as the Cloudinary model) embed transformation parameters directly in delivery URLs, generating derived images on the fly and caching them at the edge. Automatic format selection, smart cropping, and quality optimization happen at request time without pre-processing.
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

## Persistent Realtime Connections

WebSockets upgrade an HTTP request into a long-lived TCP channel. They are useful when clients and servers both need to push updates, such as chat, collaborative editing, games, live financial data, and live media. The infrastructure cost is connection state: heartbeats, memory per active connection, load balancing, failover, and session/state sharing.

## Multi-Level Caching

Caching operates as a hierarchy from closest to furthest from the user:

1. **Browser cache** (0–5ms): HTTP cache headers (`Cache-Control`, `ETag`) enable browsers to serve repeated requests without a network round trip. ETags enable conditional requests — the browser sends `If-None-Match` and the server returns `304 Not Modified` with no body if the content is unchanged.

2. **CDN cache** (20–50ms): Edge servers cache static assets and, increasingly, dynamic content. Modern CDNs (Cloudflare Workers, AWS Lambda@Edge) run code at edge locations for personalization by geography, device type, or A/B test variant.

3. **Application cache** (1–5ms): In-memory caches (Redis, Memcached, Caffeine) sitting between application servers and databases. This is where the majority of cache engineering effort goes — pattern selection (cache-aside, write-through, write-behind), TTL tuning, eviction policies, and stampede prevention.

4. **Database query cache** (10–20ms): Built-in database mechanisms (MySQL Query Cache, PostgreSQL shared buffers). Least controllable but provides baseline improvements automatically.

**Cache invalidation** is the hard problem. Three strategies:
- **TTL**: Time-based expiry. Simple but risks stale data.
- **Event-based**: Explicit eviction on data mutation, with invalidation events propagating through all layers.
- **Tag-based**: Group cache entries by tags for bulk invalidation (e.g., invalidate all entries tagged `dept:engineering`).

**Cache stampede prevention:** When a popular key expires and N concurrent requests all miss cache, the database is hammered. Mitigations include request coalescing (one thread loads, others wait), probabilistic early expiration (refresh before expiry with random probability), and distributed locking around cache reload.

**Cache warming:** Pre-populate caches before expected traffic. Three patterns: scheduled (cron at 8am daily), write-through (cache on every write), and lazy with background refresh (serve stale data while async-refetching the latest).

## Content Delivery Network (CDN) Patterns

Beyond basic static asset caching, CDNs serve as a global infrastructure layer:

- **Edge computing**: Cloudflare Workers, Lambda@Edge run request-time logic — URL rewriting, A/B testing, geo-personalization, authentication checks — without returning to origin.
- **Cache invalidation**: On data update, purge the CDN path (`cdnService.purge("/api/products/" + id)`). Use surrogate keys for group invalidation.
- **Cache key design**: Include relevant request attributes (language, currency, device) in the cache key so different variants are cached separately. Avoid including irrelevant attributes that fragment the cache.
- **Dynamic content caching**: Cache API responses at the edge with short TTLs (30–300 seconds) for read-heavy endpoints. Monitor cache hit ratio — below 50% suggests the CDN layer is adding latency without benefit.

## Rate Limiting Algorithms

Rate limiting protects infrastructure from abuse and accidental traffic spikes. Each algorithm has different properties:

| Algorithm | Memory | Burst Tolerance | Accuracy |
|-----------|--------|-----------------|----------|
| **Token Bucket** | Low (one counter per client) | High (bucket capacity) | Good |
| **Sliding Window Log** | High (stores all timestamps) | Low | Best |
| **Sliding Window Counter** | Medium (scores in Redis) | Medium | Good |
| **Fixed Window** | Low (one counter per window) | High at boundaries | Poor at edges |

**Token Bucket** is the most common production choice — it allows natural traffic bursts while maintaining a long-term rate limit. For distributed rate limiting, Redis with sorted sets (sliding window) is the reference implementation.

## Storage Performance Provisioning

Storage infrastructure must provision both capacity and access velocity. Throughput measures large sequential transfer volume; IOPS measures discrete operation count. Databases and highly concurrent workloads can saturate IOPS while using little of the available byte capacity, which is why cloud storage products price provisioned IOPS separately from raw GB/TB.

## GPU-Accelerated Vector Search

At scale, keyword-based retrieval is supplemented or replaced by embedding-based retrieval (EBR) using dense vector representations. LinkedIn's semantic search infrastructure runs GPU-accelerated exhaustive vector search on CUDA-enabled GPUs at millions of QPS. Query embeddings are compared against document embeddings using exhaustive search for maximum recall, then refined through a Cross-Encoder SLM for ranking. Key architectural components:
- Hybrid inference pipeline: offline (Spark, Flyte) for large-scale embedding generation, nearline (Flink) for low-latency updates.
- Score caching, ranking-depth controllers, and traffic shaping to manage cost and latency.
- Context compression to reduce the input size passed through expensive models.

## Recommendation Retrieval Infrastructure

Large-scale recommendation systems use retrieval infrastructure to avoid ranking the whole universe of content. Instagram Explore combines heuristic, real-time, pre-generated, and ML-based candidate sources. Two Tower models split user and item representations so item embeddings can be generated offline and cached, while online user embeddings can query an ANN service such as FAISS or HNSW. This makes heavier downstream ranking possible without violating latency budgets.

## Client-Side Security Libraries

Client applications also carry infrastructure primitives when they process untrusted input at scale. WhatsApp's Rust media consistency library is a cross-platform security layer distributed across phones, desktops, browsers, and wearables. Its job is to detect malformed, spoofed, risky, or dangerous attachments before downstream OS or app libraries process them.

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
- Related: [[concepts/memory-safety-strategy|Memory Safety and Defense-in-Depth]]
- Related: [[concepts/ml-recommendation-systems|ML Recommendation Systems at Scale]]
- Related source: [[sources/intro-to-websockets|Intro to WebSockets]]
- Related source: [[sources/byte-storage-vs-io|Byte Storage vs. I/O]]
- Related source: [[sources/netflix-open-connect-cdn-strategy|Netflix Open Connect CDN Strategy]]
- Related source: [[sources/prod-web-application-components|Key Components of a Prod Web Application]]
- Related source: [[sources/latency-gambler-day-10|Caching Patterns]]
- Related source: [[sources/latency-gambler-day-11|API Gateway & Proxy Patterns]]
- Related source: [[sources/latency-gambler-day-18|Caching & CDN Patterns]]
