---
title: "Caching Patterns"
type: source
created: 2026-06-14
source: https://archive.is/IVN9B
tags:
  - source
---

# Caching Patterns

## Summary

Day 10 of The Latency Gambler's system design series. Covers core caching patterns (cache-aside, write-through, write-behind, read-through, refresh-ahead, multi-level), cache invalidation strategies (TTL, event-based, tag-based), performance patterns (warming, stampede prevention, circuit breaker for cache), monitoring, and anti-patterns.

## Key Ideas

- **Cache-Aside (Lazy Loading)**: Application manages cache and database manually. Cache miss penalty but full control and cache failures don't break the app.
- **Write-Through**: Every write goes to both cache and database synchronously. Strong consistency but higher write latency.
- **Write-Behind (Write-Back/Async)**: Write to cache immediately, database writes happen asynchronously. Excellent write performance but risk of data loss.
- **Read-Through**: Cache automatically loads on miss via a loading cache.
- **Refresh-Ahead**: Refreshes cache entries before they expire, reducing miss penalty.
- **Multi-Level Caching (L1 + L2 + L3)**: Application-level local cache (fastest), distributed Redis cache, and database as last resort.
- **Cache Invalidation**: TTL-based, event-based (invalidate on update events), tag-based (bulk invalidation by tag).
- **Cache Stampede Prevention**: Distributed locking to prevent thundering herd when a popular cache entry expires.
- **Cache Monitoring**: Track hit ratio (>80%), eviction rate, load time, and memory usage.
- **Local-First Caching with LRU/LFU Eviction**: In-memory caches (Caffeine, Guava) use modern eviction policies — TinyLFU with admission window — that adapt to workload access patterns better than simple LRU. Window-TinyLFU achieves near-optimal hit rates with low overhead.
- **Database Query Cache Tradeoffs**: MySQL query cache (removed in 8.0) and application-layer result caching can cause stale reads when underlying data changes. Invalidation granularity is the hard problem — coarse invalidation (flush all) kills hit rate, fine-grained invalidation adds complexity.
- **Cache for ML Inference**: Model serving pipelines cache embedding vectors and inference results to avoid recomputation. Embedding caches use approximate nearest neighbor (ANN) indexes as a pre-filter, caching only the top-K results per query vector.

## Links

- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Connects to [[concepts/performance-engineering|Performance Engineering]]
- Connects to [[concepts/local-first-architecture|Local-First Architecture]]
- Connects to [[concepts/local-llm-serving|Local LLM Serving]]
