---
title: "Learn System Design With Me . Day 10: Caching Patterns"
source: "https://archive.is/IVN9B"
author:
  - "[[The Latency Gambler]]"
published: 2025-09-23
created: 2026-06-14
description:
tags:
  - "clippings"
---
## Performance Multipliers for Scalable Systems

*This is Day 10 of our 30-day journey from code writer to system architect. Start with* [*Day 1*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build the foundation, then progress through* [*Day 2*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*,* [*Day 3*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*,* [*Day 4*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*,* [*Day 5*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*,* [*Day 6*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*,* [*Day 7*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)*,* [*Day 8*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)*, and* [*Day 9*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)

We’ve mastered data access patterns. Today, we tackle the **performance multiplier**: **Caching Patterns**. The difference between 100 RPS and 10,000 RPS often comes down to caching strategy.

![](https://d3067dkfzdwhbw.archive.is/IVN9B/81e8a04b930df78d1eab791d584410ccff457c61.webp)

Here’s the architect truth: **Bad caching creates more problems than no caching** stale data, thundering herds, memory leaks. **Master caching gets you Netflix-scale performance.**

### Core Caching Patterns (The Big 3)

### 1\. Cache-Aside Pattern (Lazy Loading)

**How it works**: Application manages both cache and database manually.

```html
@Service
public class CacheAsideService {
    private final Cache<String, User> cache = Caffeine.newBuilder()
        .maximumSize(10_000)
        .expireAfterWrite(Duration.ofMinutes(30))
        .recordStats() // Essential for monitoring
        .build();
    
    public User getUser(String userId) {
        // 1. Try cache first
        User user = cache.getIfPresent(userId);
        if (user != null) return user; // Cache hit
        
        // 2. Cache miss - load from DB
        user = userRepository.findById(userId);
        
        // 3. Store in cache
        cache.put(userId, user);
        return user;
    }
    
    @Transactional
    public User updateUser(String userId, UserRequest request) {
        User user = userRepository.save(buildUser(userId, request));
        cache.invalidate(userId); // Invalidate to avoid stale data
        return user;
    }
}
```

**Pros**: Full control, cache failures don’t break app  
**Cons**: Cache miss penalty, potential inconsistency  
**Use when**: Read-heavy workloads, can tolerate occasional stale data

### 2\. Write-Through Pattern (Immediate Consistency)

**How it works**: Every write goes to both cache and database synchronously.

```html
@Service
public class WriteThroughService {
    public User updateUser(String userId, UserRequest request) {
        try {
            // 1. Write to database first
            User user = userRepository.save(buildUser(userId, request));
            
            // 2. Write to cache immediately
            cache.put(userId, user);
            
            return user;
        } catch (Exception e) {
            cache.invalidate(userId); // Clean up on failure
            throw e;
        }
    }
}
```

**Pros**: Strong consistency, no stale data  
**Cons**: Higher write latency, cache write failures affect performance  
**Use when**: Consistency critical, moderate write volume

### 3\. Write-Behind Pattern (Write-Back/Async)

**How it works**: Write to cache immediately, database writes happen later asynchronously.

```html
@Service
public class WriteBehindService {
    private final Queue<WriteOperation> writeQueue = new ConcurrentLinkedQueue<>();
    private final ScheduledExecutorService executor = Executors.newScheduledThreadPool(2);
    
    @PostConstruct
    public void init() {
        // Batch process every 5 seconds
        executor.scheduleAtFixedRate(this::flushWrites, 5, 5, TimeUnit.SECONDS);
    }
    
    public User updateUser(String userId, UserRequest request) {
        User user = buildUser(userId, request);
        
        // 1. Update cache immediately (fast response)
        cache.put(userId, user);
        
        // 2. Queue for async DB write
        writeQueue.offer(new WriteOperation(userId, user));
        
        return user;
    }
    
    private void flushWrites() {
        List<WriteOperation> batch = pollBatch(100);
        if (!batch.isEmpty()) {
            userRepository.saveAll(batch.stream()
                .map(WriteOperation::getUser)
                .collect(Collectors.toList()));
        }
    }
}
```

**Pros**: Excellent write performance, high throughput  
**Cons**: Risk of data loss, eventual consistency only  
**Use when**: Write-heavy workloads, can tolerate data loss

### Advanced Caching Patterns

### 4\. Read-Through Pattern

```html
// Cache automatically loads on miss
private final LoadingCache<String, User> cache = Caffeine.newBuilder()
    .maximumSize(10_000)
    .expireAfterWrite(Duration.ofMinutes(30))
    .build(userId -> userRepository.findById(userId)); // Auto-loading

public User getUser(String userId) {
    return cache.get(userId); // Cache handles miss automatically
}
```

### 5\. Refresh-Ahead Pattern

```html
private final LoadingCache<String, User> cache = Caffeine.newBuilder()
    .refreshAfterWrite(Duration.ofMinutes(25)) // Refresh before expiry
    .build(this::loadUser);

private User loadUser(String userId) {
    // This runs async when refresh is triggered
    return userRepository.findById(userId);
}
```

### 6\. Multi-Level Caching (L1 + L2 + L3)

```html
@Service
public class MultiLevelCacheService {
    private final Cache<String, User> l1Cache; // Local (fastest)
    private final RedisTemplate<String, User> l2Cache; // Distributed
    private final UserRepository l3Database; // Slowest
    
    public User getUser(String userId) {
        // L1: Application cache (fastest)
        User user = l1Cache.getIfPresent(userId);
        if (user != null) {
            recordCacheHit("L1");
            return user;
        }
        
        // L2: Redis cache
        user = l2Cache.opsForValue().get("user:" + userId);
        if (user != null) {
            recordCacheHit("L2");
            l1Cache.put(userId, user); // Populate L1
            return user;
        }
        
        // L3: Database (last resort)
        recordCacheMiss();
        user = l3Database.findById(userId);
        
        // Populate all levels (async to avoid blocking)
        CompletableFuture.runAsync(() -> {
            l1Cache.put(userId, user);
            l2Cache.opsForValue().set("user:" + userId, user, Duration.ofHours(1));
        });
        
        return user;
    }
}
```

### Cache Invalidation Strategies (The Hard Problem)

### 1\. TTL-Based Invalidation

```html
// Simple time-based expiry
cache.put(key, value, Duration.ofMinutes(30));
```

### 2\. Event-Based Invalidation

```html
@EventListener
public void onUserUpdated(UserUpdatedEvent event) {
    cache.invalidate(event.getUserId());
    // Invalidate related caches
    profileCache.invalidate(event.getUserId());
    recommendationCache.evictAll(); // If recommendations depend on user data
}
```

### 3\. Tag-Based Invalidation

```html
// Redis with tags
public void cacheUserWithTags(String userId, User user) {
    redisTemplate.opsForValue().set("user:" + userId, user);
    // Tag for bulk invalidation
    redisTemplate.opsForSet().add("tag:users", userId);
    redisTemplate.opsForSet().add("tag:dept:" + user.getDepartment(), userId);
}

public void invalidateByTag(String tag) {
    Set<String> userIds = redisTemplate.opsForSet().members(tag);
    String[] keys = userIds.stream()
        .map(id -> "user:" + id)
        .toArray(String[]::new);
    redisTemplate.delete(Arrays.asList(keys));
}
```

### Cache Performance Patterns

### Cache Warming (Proactive Loading)

```html
@EventListener
public void onApplicationReady(ApplicationReadyEvent event) {
    // Warm most accessed data
    List<String> hotKeys = analyticsService.getHotKeys(1000);
    
    hotKeys.parallelStream()
        .forEach(key -> {
            try {
                getUser(key); // This will populate cache
                Thread.sleep(10); // Rate limit to avoid overwhelming DB
            } catch (Exception e) {
                log.warn("Cache warming failed for: {}", key);
            }
        });
}
```

### Cache Stampede Prevention

```html
// Distributed locking to prevent thundering herd
public User getUserWithStampedeProtection(String userId) {
    String lockKey = "lock:user:" + userId;
    
    Boolean lockAcquired = redisTemplate.opsForValue()
        .setIfAbsent(lockKey, "1", Duration.ofSeconds(10));
        
    if (Boolean.TRUE.equals(lockAcquired)) {
        try {
            // Only one thread/instance loads the data
            User user = userRepository.findById(userId);
            cache.put(userId, user);
            return user;
        } finally {
            redisTemplate.delete(lockKey);
        }
    } else {
        // Wait briefly and check cache again
        Thread.sleep(50);
        return cache.get(userId, id -> userRepository.findById(id));
    }
}
```

### Circuit Breaker for Cache

```html
@Component
public class ResilientCacheService {
    private final CircuitBreaker cacheCircuitBreaker;
    
    public User getUserResilient(String userId) {
        return cacheCircuitBreaker.executeSupplier(() -> {
            // Try cache first
            return cache.get(userId);
        }).recover(throwable -> {
            // Cache failed, go directly to database
            log.warn("Cache circuit open, accessing database directly");
            return userRepository.findById(userId);
        });
    }
}
```

### Cache Types by Use Case

### 1\. Application-Level Cache

```html
// Caffeine for local caching
Cache<String, User> localCache = Caffeine.newBuilder()
    .maximumSize(1_000)
    .expireAfterWrite(Duration.ofMinutes(10))
    .build();
```

### 2\. Distributed Cache

```html
// Redis for shared caching
@Cacheable(value = "users", key = "#userId")
public User getUser(String userId) {
    return userRepository.findById(userId);
}
```

### 3\. HTTP Cache Headers

```html
@GetMapping("/users/{id}")
public ResponseEntity<User> getUser(@PathVariable String id) {
    User user = userService.getUser(id);
    
    return ResponseEntity.ok()
        .cacheControl(CacheControl.maxAge(Duration.ofMinutes(5)))
        .eTag(Integer.toString(user.hashCode()))
        .body(user);
}
```

### 4\. Database Query Cache

```html
@Query(value = "SELECT * FROM users WHERE department = ?1", nativeQuery = true)
@QueryHints(@QueryHint(name = "org.hibernate.cacheable", value = "true"))
List<User> findByDepartment(String department);
```

### Production Architecture

```html
[CDN] → [Load Balancer] → [App Server] → [Database]
  ↓           ↓              ↓             ↓
[Static]  [Reverse Proxy] [L1: Local]  [Query Cache]
[Assets]     [Cache]      [L2: Redis]      
                         [L3: Database]
```

### Cache Monitoring & Metrics

### Essential Metrics

1. **Hit Ratio**: Should be > 80% for effective caches
2. **Eviction Rate**: High evictions = undersized cache
3. **Cache Load Time**: How long cache misses take
4. **Memory Usage**: Prevent OOM issues
```html
// Monitoring with Micrometer
@Component
public class CacheMetrics {
    private final MeterRegistry registry;
    
    @EventListener
    public void recordCacheHit(CacheHitEvent event) {
        registry.counter("cache.hit", 
            "cache", event.getCacheName(),
            "key", event.getKey()).increment();
    }
    
    @Scheduled(fixedRate = 60000)
    public void recordCacheStats() {
        CacheStats stats = cache.stats();
        registry.gauge("cache.size", cache.estimatedSize());
        registry.gauge("cache.hit.ratio", stats.hitRate());
        registry.gauge("cache.eviction.count", stats.evictionCount());
    }
}
```

### Anti-Patterns to Avoid

1. **Cache Everything**: Only cache expensive operations
2. **Ignoring TTL**: Set appropriate expiration times
3. **No Monitoring**: Always track cache performance
4. **Synchronous Cache Operations**: Use async for non-critical paths
5. **Single Point of Failure**: Ensure cache failures don’t break app

### Decision Framework

Pattern Consistency Performance Complexity Use Case Cache-Aside Eventual Good Low General purpose Write-Through Strong Moderate Low Critical data Write-Behind Eventual Excellent High High throughput Read-Through Eventual Good Low Read-heavy Multi-Level Configurable Excellent High Global apps

### Tomorrow’s Preview

Day 11: “API Gateway & Proxy Patterns”. Centralized API management, request routing, and cross-cutting concerns for microservices architecture.

### Your Architect Assignment

1. **Identify bottlenecks**: Find slow database queries that need caching
2. **Measure first**: Establish baseline performance before adding cache
3. **Choose the right pattern**: Match caching strategy to consistency needs
4. **Monitor relentlessly**: Track hit ratios, evictions, and performance impact

Remember: **Caching is about choosing the right trade-off between consistency, performance, and complexity. Start simple with cache-aside, evolve based on requirements.**

*Previous articles:*

- [*Day 1 Building Your Architect Mindset*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [*Day 2 Strategy & Observer Patterns*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [*Day 3 Decorator & Proxy Patterns*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [*Day 4 Singleton & Builder Patterns*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [*Day 5 Command & Template Method Patterns*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [*Day 6 Adapter & Facade Patterns*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [*Day 7 Chain of Responsibility & State Patterns*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [*Day 8 Load Balancing & Circuit Breaker Patterns*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)
- [*Day 9 Database Patterns & Repository Pattern*](https://archive.is/o/IVN9B/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)

*Follow along daily as we master the caching patterns that multiply system performance.*

[0%](https://archive.is/IVN9B#0%) [10%](https://archive.is/IVN9B#10%) [20%](https://archive.is/IVN9B#20%) [30%](https://archive.is/IVN9B#30%) [40%](https://archive.is/IVN9B#40%) [50%](https://archive.is/IVN9B#50%) [60%](https://archive.is/IVN9B#60%) [70%](https://archive.is/IVN9B#70%) [80%](https://archive.is/IVN9B#80%) [90%](https://archive.is/IVN9B#90%) [100%](https://archive.is/IVN9B#100%)