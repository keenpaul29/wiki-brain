---
title: "Caching & CDN Patterns"
type: source
created: 2026-06-14
source: https://archive.is/gYSXT
tags:
  - source
---

# Caching & CDN Patterns

## Summary

Day 18 of The Latency Gambler's system design series. Covers multi-level caching hierarchy (browser, CDN, application, database query cache), cache warming patterns (scheduled, write-through, lazy loading with background refresh), CDN patterns for global distribution, cache invalidation strategies, cache stampede prevention, and production tips.

## Key Ideas

- **Multi-Level Caching Hierarchy**: Browser cache (0-5ms, HTTP cache headers + ETags), CDN cache (20-50ms, edge servers), Application cache (1-5ms, Redis/Memcached), Database query cache (10-20ms).
- **Cache Warming**: Scheduled warm-up (pre-populate before traffic), Write-through warming (cache on write), Lazy loading with background refresh (serve stale data while refreshing).
- **CDN Patterns**: Static asset optimization with content hashes for cache busting, dynamic content at the edge (Cloudflare Workers, Lambda@Edge), and cache invalidation strategies.
- **Cache Stampede Prevention**: Request coalescing with CompletableFuture — only one DB query for 1,000 concurrent cache misses.
- **When NOT to Cache**: Rapidly changing data (stock prices), user-specific data with low reuse, small/fast queries (3ms DB queries).
- **Production Tips**: Track hit rate/miss rate/eviction rate, set appropriate TTLs, use cache-aside for flexibility, and compress large values to reduce memory costs by up to 70%.
- **Cache Topology Patterns**: Side cache (cache-aside alongside DB), inline cache (layer between client and origin), and reverse cache (sitting in front of a service). Each topology changes failure semantics and consistency guarantees.
- **Edge Computing Drift**: CDN vendors have evolved from static asset delivery to full compute at the edge (Cloudflare Workers, Fastly Compute@Edge, AWS Lambda@Edge). This enables per-request personalization, API aggregation, and A/B testing at CDN latencies.
- **Cache Invalidation Strategies in Depth**: Time-based TTL is simplest but causes synchronized expiry spikes. Event-driven invalidation (purge on write via pub/sub) gives fresher data at the cost of invalidation channel complexity. Tag-based invalidation using surrogate keys allows bulk purging of related resources.

## Links

- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/performance-engineering|Performance Engineering]]
- Connects to [[concepts/frontend-build-performance|Frontend Build Performance]]
