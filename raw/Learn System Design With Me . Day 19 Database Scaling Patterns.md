---
title: "Learn System Design With Me . Day 19: Database Scaling Patterns"
source: "https://archive.is/5Vr4f"
author:
  - "[[The Latency Gambler]]"
published: 2025-10-17
created: 2026-06-14
description:
tags:
  - "clippings"
---

*Welcome back! If you’re just joining, start with* [*Day 1: Building Your Architect Mindset*](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build your foundation.*

I’ll never forget the day our main database hit 100% CPU at 2 AM. Queries that took 50ms were now taking 30 seconds. Users were angry. My phone wouldn’t stop ringing. We threw more RAM at it, optimized indexes, added read replicas bought ourselves maybe two weeks. Then we hit the wall again.

![](https://d8dld75579mgyb.archive.is/5Vr4f/92464080a7f04e6337b48f11962de8f640c75276.webp)

Ai Generated Image

That’s when I learned the hard truth: **you can’t vertically scale forever**. Eventually, your database becomes your system’s bottleneck, and no amount of optimization will save you. You need to think horizontally.

Today, we’re diving into database scaling patterns, the strategies that take you from handling thousands to billions of records. This is where architecture gets real.

## Why Single Database Fails (The Wake-Up Call)

Let’s be clear: a single database server can handle A LOT. Modern hardware with 128GB RAM and NVMe SSDs can serve millions of requests daily. But physics has limits:

- **Storage limits:** Even with 10TB drives, you’ll run out of space
- **Memory limits:** Can’t cache everything once data exceeds RAM
- **CPU bottleneck:** One CPU can only process so many queries
- **I/O throughput:** Disk can only read/write so fast
- **Network bandwidth:** Single NIC has a ceiling
- **Geographic latency:** Users in Australia waiting for US database

> The solution? **Distribute the load**. But how you distribute matters tremendously.

### Pattern 1: Read Replicas (The Easiest Win)

Most applications have a 90:10 read-to-write ratio. Instagram users scroll (reads) far more than they post (writes). So why send reads and writes to the same database?

**Architecture:**

```html
┌──────────────┐
                │    Client    │
                └───────┬──────┘
                        │
                ┌───────▼──────────┐
                │  Load Balancer   │
                └───────┬──────────┘
                        │
     ┌──────────────────┼──────────────────┐
     │                  │                  │
┌────▼────┐       ┌────▼────┐       ┌────▼────┐
│  App    │       │  App    │       │  App    │
│ Server  │       │ Server  │       │ Server  │
└────┬────┘       └────┬────┘       └────┬────┘
     │                  │                  │
     │ WRITE            │ READ             │ READ
     │                  │                  │
┌────▼────────────────────────────────────▼────┐
│           PRIMARY DATABASE                   │
│         (Single source of truth)             │
└────────────────┬─────────────────────────────┘
                 │
                 │ Replication (Async/Sync)
                 │
     ┌───────────┼───────────┐
     │           │           │
┌────▼────┐ ┌───▼─────┐ ┌──▼──────┐
│ READ    │ │ READ    │ │ READ    │
│ REPLICA │ │ REPLICA │ │ REPLICA │
└─────────┘ └─────────┘ └─────────┘
```

### Implementation:

```html
@Service
public class UserService {
    @Autowired
    @Qualifier("primaryDataSource")
    private DataSource primaryDB;
    
    @Autowired
    @Qualifier("replicaDataSource")
    private DataSource replicaDB;
    
    // Writes go to primary
    @Transactional
    public User createUser(UserRequest request) {
        User user = new User(request);
        JdbcTemplate primary = new JdbcTemplate(primaryDB);
        primary.update("INSERT INTO users (id, name, email) VALUES (?, ?, ?)",
            user.getId(), user.getName(), user.getEmail());
        return user;
    }
    
    // Reads from replica
    @Transactional(readOnly = true)
    public User getUser(String userId) {
        JdbcTemplate replica = new JdbcTemplate(replicaDB);
        return replica.queryForObject(
            "SELECT * FROM users WHERE id = ?",
            new UserRowMapper(),
            userId
        );
    }
}
```

## The Replication Lag Problem

Here’s the gotcha: replication isn’t instant. If a user updates their profile and immediately views it, they might see old data (read from replica that hasn’t synced yet).

**Solution: Read-Your-Own-Writes Pattern**

```html
public User updateAndGetUser(String userId, UserUpdate update) {
    // Write to primary
    updateUser(userId, update);
    
    // Force read from primary for this specific user
    return getUserFromPrimary(userId);
}

// Alternative: Use session affinity
public User getUser(String userId, String sessionId) {
    // If user just wrote something, read from primary for 5 seconds
    if (recentlyWrote(sessionId)) {
        return getUserFromPrimary(userId);
    }
    return getUserFromReplica(userId);
}
```

### Pattern 2: Database Sharding (The Real Deal)

When read replicas aren’t enough and your data doesn’t fit on one machine, it’s time to shard. **Sharding** means splitting your data across multiple databases horizontally.

## Sharding Strategies:

**1\. Hash-Based Sharding**

```html
public class HashShardingStrategy {
    private List<DataSource> shards;
    
    public DataSource getShardForUser(String userId) {
        int hash = userId.hashCode();
        int shardIndex = Math.abs(hash % shards.size());
        return shards.get(shardIndex);
    }
    
    public User getUser(String userId) {
        DataSource shard = getShardForUser(userId);
        JdbcTemplate jdbc = new JdbcTemplate(shard);
        return jdbc.queryForObject(
            "SELECT * FROM users WHERE id = ?",
            new UserRowMapper(),
            userId
        );
    }
}
```

**Pros:** Even distribution  
**Cons:** Can’t easily add/remove shards (resharding nightmare), can’t do range queries efficiently

**2\. Range-Based Sharding**

```html
public class RangeShardingStrategy {
    // Users A-M go to shard1, N-Z go to shard2
    public DataSource getShardForUser(String userId) {
        char firstChar = userId.charAt(0);
        if (firstChar <= 'M') {
            return shard1;
        } else {
            return shard2;
        }
    }
}
```

**Pros:** Range queries work, easy to add shards  
**Cons:** Uneven distribution (what if most users start with ‘A’?)

**3\. Geographic Sharding**

```html
┌─────────────────────────────────────────┐
│          Application Layer              │
└──────────────┬──────────────────────────┘
               │
    ┌──────────┼──────────┐
    │          │          │
┌───▼───┐  ┌──▼────┐  ┌──▼────┐
│ US    │  │ EU    │  │ ASIA  │
│ Shard │  │ Shard │  │ Shard │
│ (PST) │  │ (CET) │  │ (JST) │
└───────┘  └───────┘  └───────┘

Users in California → US Shard
Users in Germany → EU Shard
Users in Japan → ASIA Shard
```

**Perfect for:** Global applications like Netflix, Uber  
**Challenge:** Cross-region queries are expensive

## The Painful Truth About Sharding

Sharding isn’t magic, it’s complexity. Here’s what breaks:

**Joins Across Shards:**

```html
// This query is IMPOSSIBLE with sharding
// Users and posts are on different shards
SELECT users.name, posts.title 
FROM users 
JOIN posts ON users.id = posts.user_id
WHERE posts.created_at > '2025-01-01';
```

**Solution: Denormalization or Application-Level Joins**

```html
// Store user info with post (denormalized)
@Entity
public class Post {
    private String postId;
    private String content;
    
    // Denormalized user data
    private String userId;
    private String userName;  // Duplicated!
    private String userAvatar; // Duplicated!
}

// Or do joins in application
public PostWithUser getPostWithUser(String postId) {
    Post post = getPost(postId);  // From posts shard
    User user = getUser(post.getUserId());  // From users shard
    return new PostWithUser(post, user);
}
```

**Distributed Transactions:**

Forget ACID across shards. Use eventual consistency instead.

```html
@Service
public class OrderService {
    public void createOrder(Order order) {
        // Write to orders shard
        orderRepository.save(order);
        
        // Update inventory on different shard (async)
        eventPublisher.publish(new OrderCreatedEvent(order));
        
        // Inventory service listens and updates its shard
        // If it fails, retry with idempotency
    }
}
```

### Pattern 3: Database Per Service (Microservices)

In microservices, each service gets its own database. No shared databases. Period.

```html
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   User       │     │   Order      │     │   Inventory  │
│   Service    │     │   Service    │     │   Service    │
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       │                    │                    │
       │                    │                    │
┌──────▼───────┐     ┌──────▼───────┐     ┌──────▼───────┐
│   User DB    │     │   Order DB   │     │ Inventory DB │
│  (Postgres)  │     │   (MySQL)    │     │   (MongoDB)  │
└──────────────┘     └──────────────┘     └──────────────┘
```

**Benefits:**

- **Technology flexibility:** Use Postgres for users, MongoDB for inventory, Redis for sessions
- **Independent scaling:** Scale order database without touching user database
- **Fault isolation:** User DB crashes don’t kill orders
- **Team autonomy:** Each team owns their database schema

**The Challenge: Cross-Service Queries**

```html
// How do you get user's order history with their profile?
@Service
public class UserProfileService {
    @Autowired
    private UserClient userClient;
    
    @Autowired
    private OrderClient orderClient;
    
    public UserProfile getProfile(String userId) {
        // Call user service
        User user = userClient.getUser(userId);
        
        // Call order service
        List<Order> orders = orderClient.getOrdersByUser(userId);
        
        return new UserProfile(user, orders);
    }
}
```

> Or use **API Composition Pattern** or **CQRS with Read Models**.

### Hybrid Strategy: The Real-World Approach

Nobody uses just one pattern. Here’s how Instagram might do it:

```html
@Service
public class InstagramScalingStrategy {
    // Read replicas for profile views
    private DataSource profileReplicas;
    
    // Sharded by userId for posts
    private List<DataSource> postShards;
    
    // Separate database for messages
    private DataSource messageDB;
    
    public Post getPost(String postId, String userId) {
        // Determine shard from userId
        DataSource shard = getShardForUser(userId);
        
        // Read from replica if available
        DataSource replica = getReplicaForShard(shard);
        
        return fetchPost(replica, postId);
    }
}
```

## Practical Considerations

**1\. Auto-Sharding with Tools**

Use Vitess (YouTube’s sharding layer), Citus (Postgres extension), or MongoDB’s built-in sharding instead of rolling your own.

**2\. Shard Keys Matter**

Choose shard keys carefully, you can’t change them easily.

```html
// BAD: Sharding by timestamp (uneven distribution)
int shard = timestamp.hashCode() % numShards;

// GOOD: Sharding by userId (even distribution, user data co-located)
int shard = userId.hashCode() % numShards;
```

**3\. Monitor Everything**

```html
@Aspect
public class DatabaseMetricsAspect {
    @Around("@annotation(Transactional)")
    public Object measureQuery(ProceedingJoinPoint joinPoint) {
        long start = System.currentTimeMillis();
        Object result = joinPoint.proceed();
        long duration = System.currentTimeMillis() - start;
        
        metrics.recordQueryTime(duration);
        if (duration > 1000) {
            logger.warn("Slow query detected: {} ms", duration);
        }
        return result;
    }
}
```

### When to Use What?

Pattern Use When Avoid When Read Replicas 90%+ reads, simple queries Need strong consistency Hash Sharding Even data distribution needed Need range queries Range Sharding Range queries common Data is unevenly distributed Geo Sharding Global users, latency matters Need cross-region queries DB per Service Microservices architecture Simple monolith

### Tomorrow: Security Patterns

We’ll dive into authentication, authorization, and secure communication patterns. Because a fast, scalable system that gets hacked is useless.

**Remember:** Database scaling is about trade-offs. You’re trading simplicity for scalability, consistency for availability, and joins for flexibility. Choose wisely.

## Previous Articles in This Series

- [Day 1: Building Your Architect Mindset](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [Day 2: Strategy & Observer Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [Day 3: Decorator & Proxy Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [Day 4: Singleton & Builder Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [Day 5: Command & Template Method Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [Day 6: Adapter & Facade Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [Day 7: Chain of Responsibility & State Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [Day 9: Database Patterns & Repository](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)
- [Day 10: Caching Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)
- [Day 11: API Gateway & Proxy Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)
- [Day 12: Message Queue Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)
- [Day 13: Event Sourcing & CQRS](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)
- [Day 14: Monitoring & Observer Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-14-monitoring-observer-patterns-cdd2bba68d9f)
- [Day 15: Microservices Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-15-microservices-patterns-532c7a4ab899)
- [Day 16: Distributed System Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-16-distributed-system-patterns-87d47197b01a)
- [Day 17: Resilience Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-17-resilience-patterns-66cdacce397e)
- [Day 18: Caching & CDN Patterns](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-18-caching-cdn-patterns-58e21237a7e9)

*Keep scaling, keep learning. See you tomorrow!*

## Responses (1)

Write a response[What are your thoughts?](https://archive.is/o/5Vr4f/https://medium.com/@kanishks772/learn-system-design-with-me-day-19-database-scaling-patterns-e2d03daf0250)

```html
Hitting 100% CPU and seeing queries jump from 50ms to 30 seconds really highlights vertical scaling limits.
```

[0%](https://archive.is/5Vr4f#0%) [10%](https://archive.is/5Vr4f#10%) [20%](https://archive.is/5Vr4f#20%) [30%](https://archive.is/5Vr4f#30%) [40%](https://archive.is/5Vr4f#40%) [50%](https://archive.is/5Vr4f#50%) [60%](https://archive.is/5Vr4f#60%) [70%](https://archive.is/5Vr4f#70%) [80%](https://archive.is/5Vr4f#80%) [90%](https://archive.is/5Vr4f#90%) [100%](https://archive.is/5Vr4f#100%)