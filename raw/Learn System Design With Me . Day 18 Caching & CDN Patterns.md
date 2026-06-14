---
title: "Learn System Design With Me . Day 18: Caching & CDN Patterns"
source: "https://archive.is/gYSXT"
author:
  - "[[The Latency Gambler]]"
published: 2025-10-10
created: 2026-06-14
description:
tags:
  - "clippings"
---
<table><tbody><tr><td rowspan="2"></td><td>Saved from</td><td></td><td rowspan="1"></td></tr><tr><td colspan="1">All snapshots</td><td colspan="2" rowspan="2"><b>from host</b> <a href="https://archive.is/medium.com">medium.com</a></td></tr><tr><td colspan="2" rowspan="2"><a href="https://archive.is/gYSXT">Webpage</a> <a href="https://archive.is/gYSXT/image">Screenshot</a></td></tr><tr><td colspan="2"><a href="https://archive.is/gYSXT/share">share</a> <a href="https://archive.is/download/gYSXT.zip">download.zip</a> <a href="https://archive.is/gYSXT/abuse">report bug or abuse</a> <a href="monero:84vJcSqoqf2Uyfv3vKmQLmVM2fEQU5nCq9bsrpB8enHuhVcR2fXZAgmDX1REwWRh68bGQJgKh2SSZQfsoCWTG6qFGvSuUjy">Buy me a coffee</a></td></tr></tbody></table>

[Sign in](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-18-caching-cdn-patterns-58e21237a7e9)

11 hours ago

*Welcome back! If you’ve been following along, check out* [*Day 1: Building Your Architect Mindset*](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to start from the beginning.*

You know what’s funny? I once spent three weeks optimizing a database query that took 800ms. Cut it down to 200ms. Felt like a hero. Then my teammate added a simple cache layer and boom 5ms response time. That’s when I realized: **sometimes the best optimization is not computing at all.**

![](https://d27qpmil38f6n6.archive.is/gYSXT/7709da633e50dd484f4aa2a9bde0c83a2fd3e0f9.webp)

Ai Generated Image

Today, we’re diving deep into caching and CDN patterns, the unsung heroes that make the internet feel instant. We’ll go from absolute basics to production-grade strategies used by companies serving billions of requests.

### Why Caching Matters (The Reality Check)

Let’s start with brutal honesty: **your database is slow**. Not because it’s bad, but because physics exists. A database query involves disk I/O, network round trips, query parsing, and execution. Even a blazing-fast query takes 10–50ms. Now multiply that by 10,000 requests per second. You’re looking at serious infrastructure costs and user frustration.

> Caching is simple in concept: store frequently accessed data closer to where it’s needed. But the devil’s in the details.

### The Multi-Level Caching Hierarchy

Think of caching like a library system. You don’t go to the national archive for every book, you check your bookshelf first, then the local library, then regional archives. Same principle applies to web systems.

### Level 1: Browser Cache (0–5ms)

The fastest cache is the one you don’t control. Browsers automatically cache static assets with proper HTTP headers.

```html
// Spring Boot controller with cache headers
@GetMapping("/api/profile")
public ResponseEntity<User> getProfile(@PathVariable String userId) {
    User user = userService.getUser(userId);
    
    return ResponseEntity.ok()
        .cacheControl(CacheControl.maxAge(5, TimeUnit.MINUTES))
        .eTag(user.getVersion())  // Enable conditional requests
        .body(user);
}
```

> **Pro tip:** Use ETags for dynamic content. The browser sends `If-None-Match` headers, and you return `304 Not Modified` if nothing changed. Saves bandwidth and compute.

### Level 2: CDN Cache (20–50ms)

CDNs are distributed caching networks positioned globally. When a user in Tokyo requests your content, they hit a Tokyo edge server, not your Oregon data center.

```html
User Request Flow:
Tokyo User → Tokyo CDN Edge (MISS) → Origin Server (Oregon)
              ↓ (cache for 1 hour)
Tokyo User → Tokyo CDN Edge (HIT) → Response in 20ms ✨
```

**Architecture Diagram:**

```html
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │
┌──────▼──────┐
│  CDN Edge   │ (Closest geographic location)
│  (L2 Cache) │
└──────┬──────┘
       │ (On MISS)
┌──────▼──────┐
│ Application │
│   Server    │
└──────┬──────┘
       │
┌──────▼──────┐
│  Redis/     │ (L3 Cache)
│  Memcached  │
└──────┬──────┘
       │ (On MISS)
┌──────▼──────┐
│  Database   │ (Source of truth)
└─────────────┘
```

### Level 3: Application Cache (1–5ms)

In-memory caches like Redis or Memcached sit between your application and database. This is where the magic happens for dynamic content.

```html
@Service
public class UserService {
    private final RedisTemplate<String, User> redisTemplate;
    private final UserRepository userRepository;
    
    public User getUser(String userId) {
        String cacheKey = "user:" + userId;
        
        // Try cache first
        User cachedUser = redisTemplate.opsForValue().get(cacheKey);
        if (cachedUser != null) {
            return cachedUser; // Cache hit - 2ms response
        }
        
        // Cache miss - fetch from database
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new UserNotFoundException(userId));
        
        // Store in cache for 10 minutes
        redisTemplate.opsForValue()
            .set(cacheKey, user, 10, TimeUnit.MINUTES);
        
        return user;
    }
}
```

### Level 4: Database Query Cache (10–20ms)

Most databases have query result caching. MySQL’s query cache, PostgreSQL’s shared buffers, etc. This is automatic but least controllable.

### Cache Warming Patterns (The Proactive Approach)

Here’s a problem I learned the hard way: launching a feature at 9 AM means everyone hits cold caches simultaneously. Your response times spike to 500ms, users complain, and you’re frantically restarting services.

> **Cache warming** solves this by pre-populating caches before traffic arrives.

### Pattern 1: Scheduled Warm-Up

```html
@Component
public class CacheWarmer {
    @Scheduled(cron = "0 0 8 * * *")  // Every day at 8 AM
    public void warmPopularContent() {
        List<String> topProducts = analyticsService.getTop100Products();
        
        topProducts.parallelStream().forEach(productId -> {
            Product product = productRepository.findById(productId);
            cacheService.set("product:" + productId, product);
        });
        
        logger.info("Warmed cache with {} products", topProducts.size());
    }
}
```

### Pattern 2: Write-Through Warming

Every time you write data, immediately cache it. Perfect for user-generated content.

```html
@Service
public class PostService {
    public Post createPost(PostRequest request) {
        Post post = postRepository.save(new Post(request));
        
        // Immediately warm the cache
        cacheService.set("post:" + post.getId(), post, 1, TimeUnit.HOURS);
        
        // Also update user's timeline cache
        cacheService.addToList("timeline:" + post.getAuthorId(), post.getId());
        
        return post;
    }
}
```

### Pattern 3: Lazy Loading with Background Refresh

Serve stale data while refreshing in the background. Users never wait.

```html
public User getUserWithBackgroundRefresh(String userId) {
    String cacheKey = "user:" + userId;
    CachedUser cached = redisTemplate.opsForValue().get(cacheKey);
    
    if (cached != null) {
        // Check if cache is stale (older than 5 minutes)
        if (cached.getTimestamp() < System.currentTimeMillis() - 300000) {
            // Refresh in background
            CompletableFuture.runAsync(() -> refreshUserCache(userId));
        }
        return cached.getUser();
    }
    
    // Cache miss - synchronous load
    return loadAndCacheUser(userId);
}
```

### CDN Patterns for Global Distribution

CDNs are more than just caching, they’re your global infrastructure without the infrastructure costs.

### Pattern 1: Static Asset Optimization

```html
// webpack.config.js - Add content hash for cache busting
module.exports = {
  output: {
    filename: '[name].[contenthash].js',
    path: path.resolve(__dirname, 'dist')
  }
};
```

> When you deploy new code, the filename changes. Old cached versions remain accessible (no broken pages), and new versions are fetched automatically. Beautiful.

### Pattern 2: Dynamic Content at the Edge

Modern CDNs (Cloudflare Workers, AWS Lambda@Edge) let you run code at edge locations.

```html
// Cloudflare Worker - Personalize content at the edge
addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const country = request.cf.country;
  const currency = getCurrencyForCountry(country);
  
  // Fetch from origin with cache key including country
  const cacheKey = new URL(request.url);
  cacheKey.searchParams.append('currency', currency);
  
  return fetch(cacheKey, { cf: { cacheTtl: 300 } });
}
```

### Pattern 3: Cache Invalidation Strategy

Phil Karlton once said: “There are only two hard things in Computer Science: cache invalidation and naming things.” He wasn’t joking.

```html
@Service
public class ProductService {
    public void updateProduct(String productId, ProductUpdate update) {
        Product product = productRepository.findById(productId);
        product.apply(update);
        productRepository.save(product);
        
        // Invalidate all related caches
        cacheService.delete("product:" + productId);
        cacheService.delete("category:" + product.getCategoryId());
        
        // Purge CDN cache
        cdnService.purge("/api/products/" + productId);
        cdnService.purge("/products/" + productId + ".html");
        
        // Publish event for other services
        eventPublisher.publish(new ProductUpdatedEvent(productId));
    }
}
```

### The Cache Stampede Problem (And How to Fix It)

Picture this: a popular cache entry expires. Suddenly, 1,000 concurrent requests all miss the cache and hammer your database simultaneously. Your DB melts.

**Solution: Request Coalescing**

```html
private final Map<String, CompletableFuture<User>> inflightRequests = 
    new ConcurrentHashMap<>();

public CompletableFuture<User> getUser(String userId) {
    // If another request is already fetching this user, wait for it
    return inflightRequests.computeIfAbsent(userId, id -> 
        CompletableFuture.supplyAsync(() -> {
            try {
                return fetchUserFromDB(id);
            } finally {
                inflightRequests.remove(id);
            }
        })
    );
}
```

> Only one database query happens, even with 1,000 concurrent requests. The rest wait for the result.

### Real-World Production Tips

**1\. Cache Metrics Matter**

Track hit rate, miss rate, and eviction rate. A cache with 60% hit rate might be worse than no cache (overhead without benefit).

**2\. Set Appropriate TTLs**

User profiles? 10 minutes. Product inventory? 30 seconds. Homepage content? 5 minutes. There’s no one-size-fits-all.

**3\. Use Cache Aside Pattern for Flexibility**

Let your application control caching logic, not your cache provider. This makes debugging and evolving easier.

**4\. Compress Large Values**

```html
public void cacheWithCompression(String key, Object value) {
    byte[] serialized = serialize(value);
    byte[] compressed = compress(serialized);
    redisTemplate.opsForValue().set(key, compressed);
}
```

> Redis charges by memory. Compression can reduce costs by 70%.

### When NOT to Cache

Yes, sometimes caching makes things worse:

- **Rapidly changing data:** Stock prices, sports scores
- **User-specific data with low reuse:** Your unique API request probably won’t be requested again
- **Small, fast queries:** If your DB query takes 3ms and caching adds 2ms latency overhead, why bother?

### Tomorrow’s Challenge

We’re moving to Day 19: Database Scaling Patterns. We’ll explore sharding, replication, and how to handle data that doesn’t fit on one machine. The fun really begins.

> **Remember:** Caching is an optimization, not a solution. Fix your slow queries, optimize your algorithms, then add caching as the cherry on top.

## Previous Articles in This Series

- [Day 1: Building Your Architect Mindset](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [Day 2: Strategy & Observer Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [Day 3: Decorator & Proxy Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [Day 4: Singleton & Builder Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [Day 5: Command & Template Method Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [Day 6: Adapter & Facade Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [Day 7: Chain of Responsibility & State Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [Day 9: Database Patterns & Repository](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)
- [Day 10: Caching Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)
- [Day 11: API Gateway & Proxy Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)
- [Day 12: Message Queue Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)
- [Day 13: Event Sourcing & CQRS](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)
- [Day 14: Monitoring & Observer Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-14-monitoring-observer-patterns-cdd2bba68d9f)
- [Day 15: Microservices Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-15-microservices-patterns-532c7a4ab899)
- [Day 16: Distributed System Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-16-distributed-system-patterns-87d47197b01a)
- [Day 17: Resilience Patterns](https://archive.is/o/gYSXT/https://medium.com/@kanishks772/learn-system-design-with-me-day-17-resilience-patterns-66cdacce397e)

*Keep building, keep learning. See you tomorrow!*

[0%](https://archive.is/gYSXT#0%) [10%](https://archive.is/gYSXT#10%) [20%](https://archive.is/gYSXT#20%) [30%](https://archive.is/gYSXT#30%) [40%](https://archive.is/gYSXT#40%) [50%](https://archive.is/gYSXT#50%) [60%](https://archive.is/gYSXT#60%) [70%](https://archive.is/gYSXT#70%) [80%](https://archive.is/gYSXT#80%) [90%](https://archive.is/gYSXT#90%) [100%](https://archive.is/gYSXT#100%)