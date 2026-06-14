---
title: "Learn System Design With Me . Day 11: API Gateway & Proxy Patterns"
source: "https://archive.is/E3eS8"
author:
  - "[[The Latency Gambler]]"
published: 2025-09-25
created: 2026-06-14
description:
tags:
  - "clippings"
---
*This is Day 11 of our 30-day journey from code writer to system architect. Start with* [*Day 1*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build the foundation, then progress through* [*Day 2*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*,* [*Day 3*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*,* [*Day 4*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*,* [*Day 5*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*,* [*Day 6*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*,* [*Day 7*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)*,* [*Day 8*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)*,* [*Day 9*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)*, and* [*Day 10*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)

We’ve mastered caching for performance. Today, we tackle the **traffic control center** of modern systems: **API Gateway and Proxy Patterns**. These patterns are the difference between a chaotic microservice mesh and an organized, secure, observable system.

![](https://d6m8wf8x5rc3sl.archive.is/E3eS8/7849a7e08b2ab5ef262a58439d747a3288080d0f.webp)

Here’s the architect reality: **Without proper API gateway patterns, your microservices become an unmaintainable spaghetti of cross-cutting concerns scattered everywhere.** Gateway patterns centralize what should be centralized.

### API Gateway Pattern: The Single Entry Point

### What It Is

API Gateway is a **single entry point** for all client requests in a microservices architecture. Instead of clients calling multiple services directly, they call the gateway, which routes requests to appropriate backend services while handling cross-cutting concerns like authentication, logging, and rate limiting.

### Why You Need It

Without API Gateway, every microservice needs its own authentication, rate limiting, logging, and monitoring. This leads to:

- **Duplicated code** across services
- **Inconsistent security** implementations
- **Complex client logic** to handle multiple endpoints
- **Operational nightmare** with scattered concerns

### Basic Implementation

```html
@RestController
@RequestMapping("/api/v1")
public class ApiGateway {
    private final ServiceRegistry serviceRegistry;
    private final AuthenticationService authService;
    private final RateLimitService rateLimitService;
    
    @GetMapping("/users/{id}")
    public ResponseEntity<?> getUser(@PathVariable String id, 
                                   HttpServletRequest request) {
        // 1. Authentication & Authorization
        User currentUser = authService.authenticate(request);
        
        // 2. Rate Limiting  
        if (!rateLimitService.allowRequest(currentUser.getId())) {
            return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS).build();
        }
        
        // 3. Service Discovery & Routing
        ServiceInstance userService = serviceRegistry.getService("user-service");
        String serviceUrl = buildServiceUrl(userService, "/users/" + id);
        
        // 4. Forward Request with Circuit Breaker
        return circuitBreaker.execute(() ->
            restTemplate.getForEntity(serviceUrl, User.class)
        );
    }
}
```

**Key Benefits:**

- **Single entry point** for all client requests
- **Centralized cross-cutting concerns** (auth, logging, rate limiting)
- **Request routing** and load balancing
- **Protocol translation** (HTTP to gRPC, etc.)

### Proxy Patterns: Traffic Direction and Control

### Forward Proxy: Client-Side Intermediary

**What It Is:** Forward proxy sits between clients and servers. Clients know they’re using a proxy and configure requests to go through it.

**Real-world example:** Corporate proxy servers that filter internet access.

```html
// Forward Proxy - Client explicitly uses proxy
@Component
public class ForwardProxyService {
    
    public ResponseEntity<String> proxyRequest(String targetUrl, HttpMethod method) {
        // Client -> Forward Proxy -> Internet/Server
        
        // 1. URL filtering (corporate firewalls)
        if (isBlocked(targetUrl)) {
            throw new BlockedUrlException("URL blocked by policy");
        }
        
        // 2. Caching (speed up repeated requests)
        String cached = cache.get(targetUrl);
        if (cached != null) return ResponseEntity.ok(cached);
        
        // 3. Add proxy headers and forward
        HttpHeaders headers = new HttpHeaders();
        headers.add("X-Forwarded-For", getClientIP());
        
        ResponseEntity<String> response = restTemplate.exchange(
            targetUrl, method, new HttpEntity<>(headers), String.class);
            
        cache.put(targetUrl, response.getBody());
        return response;
    }
}
```

**Use Cases:**

- **Corporate firewalls** and content filtering
- **Anonymization** of client requests
- **Caching** frequently requested content
- **Bandwidth optimization** and compression

### Reverse Proxy: Server-Side Intermediary

**What It Is:** Reverse proxy sits in front of servers. Clients don’t know they’re talking to a proxy, they think they’re talking directly to the server.

**Real-world example:** Nginx in front of your application servers.

```html
// Reverse Proxy - Transparent to clients
@Component
public class ReverseProxyService {
    
    @RequestMapping("/**")
    public ResponseEntity<?> proxyToBackend(HttpServletRequest request) {
        // Internet/Client -> Reverse Proxy -> Backend Servers
        
        String path = request.getRequestURI();
        
        // 1. Load balancing - select healthy backend
        ServiceInstance backend = selectHealthyBackend();
        
        // 2. SSL termination (handled at infrastructure level)
        
        // 3. Header manipulation
        HttpHeaders headers = buildProxyHeaders(request);
        String backendUrl = buildBackendUrl(backend, path);
        
        // 4. Forward with circuit breaker
        return circuitBreaker.execute(() ->
            restTemplate.exchange(backendUrl, 
                HttpMethod.valueOf(request.getMethod()), 
                new HttpEntity<>(getRequestBody(request), headers), 
                byte[].class)
        );
    }
    
    private HttpHeaders buildProxyHeaders(HttpServletRequest request) {
        HttpHeaders headers = new HttpHeaders();
        
        // Add reverse proxy headers
        headers.add("X-Real-IP", getClientIP(request));
        headers.add("X-Forwarded-For", buildForwardedFor(request));
        headers.add("X-Forwarded-Proto", request.getScheme());
        
        return headers;
    }
}
```

**Use Cases:**

- **Load balancing** across multiple servers
- **SSL termination** and certificate management
- **Static content** serving and caching
- **Web acceleration** and compression

### Rate Limiting: Protecting Your APIs

### Why Rate Limiting Matters

Without rate limiting, a single client can overwhelm your system, causing:

- **Service degradation** for other users
- **Resource exhaustion** (CPU, memory, database connections)
- **Security vulnerabilities** (DoS attacks)
- **Cost overruns** in cloud environments

### Token Bucket Algorithm

**How it works:** Each client gets a bucket with tokens. Requests consume tokens. Tokens refill at a fixed rate. No tokens = request rejected.

```html
@Component
public class TokenBucketRateLimiter {
    private final Map<String, TokenBucket> buckets = new ConcurrentHashMap<>();
    
    public boolean allowRequest(String clientId) {
        TokenBucket bucket = buckets.computeIfAbsent(clientId, 
            id -> new TokenBucket(100, 10)); // 100 requests, refill 10/second
        return bucket.tryConsume();
    }
    
    private static class TokenBucket {
        private final long capacity; // Maximum tokens
        private final long refillRate; // Tokens per second
        private volatile long tokens;
        private volatile long lastRefill;
        
        public synchronized boolean tryConsume() {
            refill(); // Add tokens based on time passed
            if (tokens > 0) {
                tokens--;
                return true; // Request allowed
            }
            return false; // Request rejected
        }
        
        private void refill() {
            long now = System.currentTimeMillis();
            long tokensToAdd = ((now - lastRefill) / 1000) * refillRate;
            tokens = Math.min(capacity, tokens + tokensToAdd);
            lastRefill = now;
        }
    }
}
```

> **Pros:** Allows burst traffic, smooth rate control **Cons:** More complex than fixed window

### Sliding Window Rate Limiter

**How it works:** Track requests in a sliding time window. Reject if window exceeds limit.

```html
@Component
public class SlidingWindowRateLimiter {
    private final RedisTemplate<String, String> redis;
    
    public boolean allowRequest(String clientId) {
        String key = "rate_limit:" + clientId;
        long now = System.currentTimeMillis();
        long windowStart = now - Duration.ofMinutes(1).toMillis();
        
        return redis.execute((RedisCallback<Boolean>) connection -> {
            // Remove old entries outside window
            connection.zRemRangeByScore(key.getBytes(), 0, windowStart);
            
            // Count current requests in window
            Long count = connection.zCard(key.getBytes());
            
            if (count < 1000) { // 1000 requests per minute limit
                // Add current request to window
                connection.zAdd(key.getBytes(), now, UUID.randomUUID().toString().getBytes());
                connection.expire(key.getBytes(), 60);
                return true;
            }
            return false;
        });
    }
}
```

> **Pros:** More accurate than fixed window, prevents edge case bursts **Cons:** Requires more storage (Redis), higher complexity

### Advanced Gateway Features

### Request/Response Transformation

**Why needed:** Legacy APIs have different formats than modern clients expect. Gateway can transform data on the fly.

```html
@Component
public class ApiTransformationService {
    
    // Transform legacy user format to modern API
    public Object transformUserResponse(String legacyResponse, String apiVersion) {
        JsonNode legacy = objectMapper.readTree(legacyResponse);
        
        if ("v2".equals(apiVersion)) {
            // Modern format
            ObjectNode modern = objectMapper.createObjectNode();
            modern.put("id", legacy.get("user_id").asText());
            modern.put("fullName", legacy.get("first_name").asText() + 
                                  " " + legacy.get("last_name").asText());
            modern.put("email", legacy.get("email_address").asText());
            return modern;
        }
        
        return legacy; // Return as-is for v1
    }
}
```

### API Versioning Strategies

**Why important:** APIs evolve, but clients upgrade at different rates. Gateway handles multiple API versions.

```html
@Component
public class ApiVersioningRouter {
    
    public ServiceEndpoint routeRequest(String path, String version) {
        // 1. Header-based versioning
        if ("v1".equals(version)) {
            return new ServiceEndpoint("user-service-v1", path);
        }
        
        // 2. URL path versioning  
        if (path.startsWith("/v2/")) {
            return new ServiceEndpoint("user-service-v2", path.substring(3));
        }
        
        // 3. Default to latest
        return new ServiceEndpoint("user-service-latest", path);
    }
}
```

**Versioning Strategies:**

- **URL Path:** `/v1/users`, `/v2/users`
- **Header:** `Accept: application/vnd.api+json;version=2`
- **Query Parameter:** `/users?version=v1`
- **Content Type:** `application/vnd.company.user-v2+json`

### System Architecture: Complete Gateway Solution

```html
[Mobile App] ──┐
               ├─→ [CDN] → [Load Balancer] → [API Gateway] ──┐
[Web App] ─────┘                                             ├→ [User Service]
                                   ↓                         ├→ [Order Service] 
                            [Cross-cutting:]                 └→ [Payment Service]
                            • Authentication
                            • Rate Limiting  
                            • Logging/Metrics
                            • Circuit Breaking
```

**Architecture Layers:**

1. **CDN Layer:** Static content, geographic distribution
2. **Load Balancer:** SSL termination, DDoS protection
3. **API Gateway:** Business logic routing, transformation
4. **Service Mesh:** Service-to-service communication

### Gateway Types and When to Use

### Edge Gateway (Internet-facing)

**Purpose:** First point of contact for external clients **Features:**

- **SSL/TLS termination**
- **DDoS protection and firewall**
- **Geographic routing** (route EU users to EU servers)
- **CDN integration** for static assets

**Example:** CloudFlare, AWS CloudFront

### Internal Gateway (Service-to-service)

**Purpose:** Communication between internal microservices **Features:**

- **Service discovery** and registration
- **Load balancing** between service instances
- **Circuit breaking** for resilience
- **Distributed tracing** and observability

**Example:** Istio, Linkerd, Kong

### Backend for Frontend (BFF)

**Purpose:** Client-specific API aggregation **Features:**

- **Data aggregation** from multiple services
- **Client-specific transformations** (mobile vs web)
- **Reduced chattiness** (one call instead of many)
- **Authentication delegation**

**Example:** GraphQL gateway, custom BFF services

### Production Considerations

### Monitoring and Observability

```html
@Component
public class GatewayMetrics {
    
    public void recordRequest(String service, int status, long duration) {
        // Track request latency
        registry.timer("gateway.request.duration",
            "service", service,
            "status", String.valueOf(status))
            .record(duration, TimeUnit.MILLISECONDS);
            
        // Track success/error rates
        registry.counter("gateway.request.total",
            "service", service,
            "result", status < 400 ? "success" : "error")
            .increment();
    }
}
```

**Essential Metrics:**

- **Request throughput** (requests per second)
- **Error rates** (4xx, 5xx responses)
- **Response latency** (P50, P95, P99)
- **Circuit breaker states** (open/closed)

### Security Best Practices

- **Authentication:** JWT tokens, API keys, OAuth 2.0
- **Authorization:** Role-based access control (RBAC)
- **Input validation:** Prevent injection attacks
- **Rate limiting:** Prevent abuse and DoS
- **HTTPS enforcement:** Encrypt all communication

### Common Pitfalls and Solutions

### 1\. Gateway Becomes a Bottleneck

**Problem:** Single gateway handling all traffic **Solution:**

- Horizontal scaling with multiple gateway instances
- Caching frequently accessed data
- Async processing where possible

### 2\. Feature Creep in Gateway

**Problem:** Gateway becomes a monolith with business logic **Solution:**

- Keep gateway thin only cross-cutting concerns
- Move business logic to dedicated services
- Use BFF pattern for client-specific logic

### 3\. Poor Error Handling

**Problem:** Gateway failures cascade to all services **Solution:**

- Circuit breakers for downstream services
- Graceful degradation and fallback responses
- Proper timeout configurations

### Decision Framework

Pattern Use Case Complexity Best For Forward Proxy Client-side filtering, caching Low Corporate networks Reverse Proxy Load balancing, SSL Medium Web applications API Gateway Microservices, cross-cutting High Distributed systems Service Mesh Service-to-service Very High Complex architectures

### Tomorrow’s Preview

Day 12: “Message Queue Patterns” Publisher-Subscriber pattern, Message Queue vs Topic patterns, and building resilient async communication systems.

### Your Architect Assignment

1. **Map your cross-cutting concerns** Find auth, logging, rate limiting scattered across services
2. **Identify client complexity** Where clients call multiple services that could be aggregated
3. **Analyze traffic patterns** Which services need rate limiting and circuit breaking
4. **Review security implementations** Look for inconsistent auth/authz across services

Remember: **API Gateway is your system’s bouncer, translator, and traffic cop all in one. It centralizes what should be centralized while keeping services focused on business logic.**

*Previous articles:*

- [*Day 1 Building Your Architect Mindset*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [*Day 2 Strategy & Observer Patterns*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [*Day 3 Decorator & Proxy Patterns*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [*Day 4 Singleton & Builder Patterns*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [*Day 5 Command & Template Method Patterns*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [*Day 6 Adapter & Facade Patterns*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [*Day 7 Chain of Responsibility & State Patterns*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [*Day 8 Load Balancing & Circuit Breaker Patterns*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)
- [*Day 9 Database Patterns & Repository Pattern*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)
- [*Day 10 Caching Patterns*](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)

*Follow along daily as we master the gateway patterns that control traffic in distributed systems.*

## Responses (1)

Write a response[What are your thoughts?](https://archive.is/o/E3eS8/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)

```html
Can you map this process with MCP servers ?
```

[0%](https://archive.is/E3eS8#0%) [10%](https://archive.is/E3eS8#10%) [20%](https://archive.is/E3eS8#20%) [30%](https://archive.is/E3eS8#30%) [40%](https://archive.is/E3eS8#40%) [50%](https://archive.is/E3eS8#50%) [60%](https://archive.is/E3eS8#60%) [70%](https://archive.is/E3eS8#70%) [80%](https://archive.is/E3eS8#80%) [90%](https://archive.is/E3eS8#90%) [100%](https://archive.is/E3eS8#100%)