---
title: "Essential Caching Patterns and Strategies"
type: source
created: 2026-05-26
source: https://designgurus.substack.com/p/12-caching-patterns-in-one-visual?utm_source=substack&publication_id=6702521&post_id=199051195&utm_medium=email&utm_content=share&utm_campaign=email-share&triggerShare=true&isFreemail=true&r=34xgnu&triedRedirect=true
published: 2026-05-25
tags:
  - source
---

# Essential Caching Patterns and Strategies

## Summary

Explains critical caching architectures and eviction schemes, highlighting trade-offs in data consistency, load performance, and system latency.

## Key Ideas

- Cache-Aside (Lazy Loading) queries the cache first, updates it upon DB read on misses, but risks initial read delays and stale cache states.
- Read-Through caches decouple the database fetching logic from the client by delegating database queries directly to the cache handler on cache misses.
- Write-Through caches update the cache and database simultaneously to prevent stale cache entries at the cost of higher write latency.
- Write-Back (Write-Behind) caches queue DB updates asynchronously to achieve maximum write performance, but risk data loss during cache crashes.
- Write-Around prevents cache pollution by writing directly to the database, ensuring only read-heavy items populate the cache.
- Refresh-Ahead uses predictive patterns to pre-load and refresh values in cache before they officially expire, reducing latency for hot items.
- Cache Stampedes occur when high-volume expired keys trigger simultaneous database lookups; mitigation includes locks, probabilistic early expiration, or background pre-warming.

## Links

- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
