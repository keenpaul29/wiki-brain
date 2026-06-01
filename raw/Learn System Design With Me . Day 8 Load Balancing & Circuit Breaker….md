---
title: "Learn System Design With Me . Day 8: Load Balancing & Circuit Breaker…"
source: https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed
author: "[[The Latency Gambler]]"
published: 2025-09-22
created: 2026-05-27
description:
tags:
  - clippings
---

## Learn System Design With Me. Day 8: Load Balancing & Circuit Breaker Patterns

## Building Resilient Distributed Systems

1 day ago

*This is Day 8 of our 30-day journey from code writer to system architect. Start with* [*Day 1*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build the foundation, then progress through* [*Day 2*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*,* [*Day 3*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*,* [*Day 4*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*,* [*Day 5*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*,* [*Day 6*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*, and* [*Day 7*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)

We’ve mastered design patterns for flexible systems. Today, we enter the realm of **system architecture patterns**: Load Balancing and Circuit Breaker patterns that handle the two biggest challenges in distributed systems **traffic distribution and failure management**.

![](https://dazrarxkq80yhy.archive.is/WC6CY/311c8c75270f0d56e22f782b2b89dd71c0560f03.webp)

Here’s the hard truth: **Your perfectly designed patterns mean nothing if your system can’t handle load or fails catastrophically when dependencies go down.** These patterns are your safety nets for production systems.

> Let me show you how Netflix, Amazon, and Google keep their systems running under massive load and constant failures.

## Load Balancing Pattern: Intelligent Traffic Distribution

### The Problem It Solves

Multiple server instances need to handle incoming requests, but naive distribution leads to hotspots, cascading failures, and poor user experience. **Load balancing isn’t just about round-robin, it’s about intelligent decision-making.**

### Basic Load Balancer Implementation

```html
// Load Balancer Interface
public interface LoadBalancer {
    ServerInstance selectServer(Request request);
    void addServer(ServerInstance server);
    void removeServer(ServerInstance server);
    void updateServerHealth(String serverId, HealthStatus status);
}

// Server Instance
public class ServerInstance {
    private final String id;
    private final String host;
    private final int port;
    private volatile HealthStatus healthStatus;
    private volatile int currentConnections;
    private volatile double cpuUtilization;
    private volatile long responseTime;
    private final AtomicLong requestCount;
    
    public ServerInstance(String id, String host, int port) {
        this.id = id;
        this.host = host;
        this.port = port;
        this.healthStatus = HealthStatus.HEALTHY;
        this.currentConnections = 0;
        this.requestCount = new AtomicLong(0);
    }
    
    public void incrementConnections() {
        this.currentConnections++;
        this.requestCount.incrementAndGet();
    }
    
    public void decrementConnections() {
        this.currentConnections = Math.max(0, this.currentConnections - 1);
    }
    
    public boolean isHealthy() {
        return healthStatus == HealthStatus.HEALTHY;
    }
    
    // Getters and setters...
}

// Round Robin Load Balancer
public class RoundRobinLoadBalancer implements LoadBalancer {
    private final List<ServerInstance> servers = new CopyOnWriteArrayList<>();
    private final AtomicInteger currentIndex = new AtomicInteger(0);
    
    @Override
    public ServerInstance selectServer(Request request) {
        List<ServerInstance> healthyServers = servers.stream()
            .filter(ServerInstance::isHealthy)
            .collect(Collectors.toList());
            
        if (healthyServers.isEmpty()) {
            throw new NoHealthyServersException("No healthy servers available");
        }
        
        int index = currentIndex.getAndIncrement() % healthyServers.size();
        return healthyServers.get(index);
    }
    
    @Override
    public void addServer(ServerInstance server) {
        servers.add(server);
        log.info("Added server: {} to load balancer", server.getId());
    }
    
    @Override
    public void removeServer(ServerInstance server) {
        servers.remove(server);
        log.info("Removed server: {} from load balancer", server.getId());
    }
    
    @Override
    public void updateServerHealth(String serverId, HealthStatus status) {
        servers.stream()
            .filter(s -> s.getId().equals(serverId))
            .findFirst()
            .ifPresent(server -> {
                server.setHealthStatus(status);
                log.info("Updated server {} health to: {}", serverId, status);
            });
    }
}
```

### Advanced Load Balancing Strategies

### 1\. Weighted Round Robin

```html
public class WeightedRoundRobinLoadBalancer implements LoadBalancer {
    private final Map<ServerInstance, Integer> serverWeights = new ConcurrentHashMap<>();
    private final Map<ServerInstance, Integer> currentWeights = new ConcurrentHashMap<>();
    
    public void setWeight(ServerInstance server, int weight) {
        serverWeights.put(server, weight);
        currentWeights.put(server, 0);
    }
    
    @Override
    public ServerInstance selectServer(Request request) {
        List<ServerInstance> healthyServers = getHealthyServers();
        
        if (healthyServers.isEmpty()) {
            throw new NoHealthyServersException();
        }
        
        ServerInstance selected = null;
        int totalWeight = 0;
        
        for (ServerInstance server : healthyServers) {
            int weight = serverWeights.getOrDefault(server, 1);
            int current = currentWeights.get(server);
            
            currentWeights.put(server, current + weight);
            totalWeight += weight;
            
            if (selected == null || currentWeights.get(server) > currentWeights.get(selected)) {
                selected = server;
            }
        }
        
        currentWeights.put(selected, currentWeights.get(selected) - totalWeight);
        return selected;
    }
}
```

### 2\. Least Connections Load Balancer

```html
public class LeastConnectionsLoadBalancer implements LoadBalancer {
    private final List<ServerInstance> servers = new CopyOnWriteArrayList<>();
    
    @Override
    public ServerInstance selectServer(Request request) {
        List<ServerInstance> healthyServers = getHealthyServers();
        
        if (healthyServers.isEmpty()) {
            throw new NoHealthyServersException();
        }
        
        return healthyServers.stream()
            .min(Comparator.comparingInt(ServerInstance::getCurrentConnections))
            .orElseThrow(() -> new NoHealthyServersException());
    }
}
```

### 3\. Intelligent Load Balancer with Multiple Factors

```html
public class IntelligentLoadBalancer implements LoadBalancer {
    private final List<ServerInstance> servers = new CopyOnWriteArrayList<>();
    private final LoadBalancingStrategy strategy;
    
    public IntelligentLoadBalancer(LoadBalancingStrategy strategy) {
        this.strategy = strategy;
    }
    
    @Override
    public ServerInstance selectServer(Request request) {
        List<ServerInstance> healthyServers = getHealthyServers();
        
        if (healthyServers.isEmpty()) {
            throw new NoHealthyServersException();
        }
        
        return strategy.selectServer(healthyServers, request);
    }
}

// Strategy for server selection
public interface LoadBalancingStrategy {
    ServerInstance selectServer(List<ServerInstance> servers, Request request);
}

// Composite scoring strategy
public class CompositeLoadBalancingStrategy implements LoadBalancingStrategy {
    
    @Override
    public ServerInstance selectServer(List<ServerInstance> servers, Request request) {
        return servers.stream()
            .min(Comparator.comparingDouble(this::calculateScore))
            .orElseThrow(() -> new NoHealthyServersException());
    }
    
    private double calculateScore(ServerInstance server) {
        // Composite score based on multiple factors
        double connectionScore = server.getCurrentConnections() * 0.4;
        double cpuScore = server.getCpuUtilization() * 0.3;
        double responseTimeScore = server.getResponseTime() / 1000.0 * 0.3;
        
        return connectionScore + cpuScore + responseTimeScore;
    }
}
```

### System Architecture: Load Balancing Layers

```html
[Client] → [DNS Load Balancer] → [L7 Load Balancer] → [L4 Load Balancer] → [Server Instances]
              ↓                        ↓                      ↓
         [Geographic]              [HTTP/HTTPS]         [TCP/UDP]
         [Distribution]           [Content-based]      [Connection-based]
```

### Circuit Breaker Pattern: Preventing Cascading Failures

### The Problem It Solves

When downstream services fail, your system should fail fast instead of hanging and consuming resources. **Circuit breaker acts like an electrical circuit breaker it opens when failures exceed threshold, preventing cascade failures.**

### Basic Circuit Breaker Implementation

```html
// Circuit Breaker States
public enum CircuitState {
    CLOSED,    // Normal operation
    OPEN,      // Failing fast
    HALF_OPEN  // Testing if service recovered
}

// Circuit Breaker Configuration
public class CircuitBreakerConfig {
    private final int failureThreshold;
    private final long timeoutInMillis;
    private final long retryTimeoutInMillis;
    private final int successThreshold; // For half-open state
    
    public CircuitBreakerConfig(int failureThreshold, long timeoutInMillis, 
                               long retryTimeoutInMillis, int successThreshold) {
        this.failureThreshold = failureThreshold;
        this.timeoutInMillis = timeoutInMillis;
        this.retryTimeoutInMillis = retryTimeoutInMillis;
        this.successThreshold = successThreshold;
    }
    
    // Getters...
}

// Circuit Breaker Implementation
public class CircuitBreaker {
    private final String name;
    private final CircuitBreakerConfig config;
    private volatile CircuitState state = CircuitState.CLOSED;
    private final AtomicInteger failureCount = new AtomicInteger(0);
    private final AtomicInteger successCount = new AtomicInteger(0);
    private volatile long lastFailureTime = 0;
    
    public CircuitBreaker(String name, CircuitBreakerConfig config) {
        this.name = name;
        this.config = config;
    }
    
    public <T> T execute(Supplier<T> operation) throws CircuitBreakerOpenException {
        if (state == CircuitState.OPEN) {
            if (shouldAttemptReset()) {
                state = CircuitState.HALF_OPEN;
                successCount.set(0);
                log.info("Circuit breaker {} moved to HALF_OPEN", name);
            } else {
                throw new CircuitBreakerOpenException("Circuit breaker is OPEN for: " + name);
            }
        }
        
        try {
            T result = executeWithTimeout(operation);
            onSuccess();
            return result;
        } catch (Exception e) {
            onFailure();
            throw e;
        }
    }
    
    private <T> T executeWithTimeout(Supplier<T> operation) {
        CompletableFuture<T> future = CompletableFuture.supplyAsync(operation);
        
        try {
            return future.get(config.getTimeoutInMillis(), TimeUnit.MILLISECONDS);
        } catch (TimeoutException e) {
            future.cancel(true);
            throw new ServiceTimeoutException("Operation timed out after " + 
                                            config.getTimeoutInMillis() + "ms");
        } catch (Exception e) {
            throw new ServiceException("Operation failed", e);
        }
    }
    
    private void onSuccess() {
        failureCount.set(0);
        
        if (state == CircuitState.HALF_OPEN) {
            int currentSuccessCount = successCount.incrementAndGet();
            
            if (currentSuccessCount >= config.getSuccessThreshold()) {
                state = CircuitState.CLOSED;
                log.info("Circuit breaker {} moved to CLOSED", name);
            }
        }
    }
    
    private void onFailure() {
        int currentFailureCount = failureCount.incrementAndGet();
        lastFailureTime = System.currentTimeMillis();
        
        if (currentFailureCount >= config.getFailureThreshold()) {
            if (state == CircuitState.CLOSED) {
                state = CircuitState.OPEN;
                log.warn("Circuit breaker {} moved to OPEN after {} failures", 
                         name, currentFailureCount);
            } else if (state == CircuitState.HALF_OPEN) {
                state = CircuitState.OPEN;
                log.warn("Circuit breaker {} moved back to OPEN from HALF_OPEN", name);
            }
        }
    }
    
    private boolean shouldAttemptReset() {
        return (System.currentTimeMillis() - lastFailureTime) >= config.getRetryTimeoutInMillis();
    }
    
    public CircuitState getState() {
        return state;
    }
    
    public CircuitBreakerStats getStats() {
        return CircuitBreakerStats.builder()
            .name(name)
            .state(state)
            .failureCount(failureCount.get())
            .successCount(successCount.get())
            .lastFailureTime(lastFailureTime)
            .build();
    }
}
```

### Advanced Circuit Breaker with Fallback

```html
// Circuit Breaker with Fallback Support
public class ResilientCircuitBreaker extends CircuitBreaker {
    private final Function<Exception, Object> fallbackFunction;
    
    public ResilientCircuitBreaker(String name, CircuitBreakerConfig config,
                                 Function<Exception, Object> fallbackFunction) {
        super(name, config);
        this.fallbackFunction = fallbackFunction;
    }
    
    @SuppressWarnings("unchecked")
    public <T> T executeWithFallback(Supplier<T> operation) {
        try {
            return execute(operation);
        } catch (Exception e) {
            log.warn("Circuit breaker {} executing fallback due to: {}", 
                     getName(), e.getMessage());
            return (T) fallbackFunction.apply(e);
        }
    }
}

// Usage example
public class UserService {
    private final ResilientCircuitBreaker userServiceCircuitBreaker;
    private final ResilientCircuitBreaker recommendationServiceCircuitBreaker;
    
    public UserService() {
        this.userServiceCircuitBreaker = new ResilientCircuitBreaker(
            "user-service",
            new CircuitBreakerConfig(5, 2000, 10000, 3),
            this::userServiceFallback
        );
        
        this.recommendationServiceCircuitBreaker = new ResilientCircuitBreaker(
            "recommendation-service", 
            new CircuitBreakerConfig(3, 1000, 5000, 2),
            this::recommendationServiceFallback
        );
    }
    
    public UserProfile getUserProfile(String userId) {
        return userServiceCircuitBreaker.executeWithFallback(() -> {
            // Call external user service
            return externalUserService.getProfile(userId);
        });
    }
    
    public List<Product> getRecommendations(String userId) {
        return recommendationServiceCircuitBreaker.executeWithFallback(() -> {
            return externalRecommendationService.getRecommendations(userId);
        });
    }
    
    private UserProfile userServiceFallback(Exception e) {
        // Return cached profile or anonymous profile
        return cacheService.getCachedProfile(userId)
            .orElse(UserProfile.anonymous());
    }
    
    private List<Product> recommendationServiceFallback(Exception e) {
        // Return popular products or empty list
        return popularProductsService.getPopularProducts()
            .stream()
            .limit(10)
            .collect(Collectors.toList());
    }
}
```

### Health Checks and Service Discovery Integration

```html
// Health Check Interface
public interface HealthCheck {
    HealthCheckResult check();
}

public class HealthCheckResult {
    private final boolean healthy;
    private final String message;
    private final Map<String, Object> details;
    private final long timestamp;
    
    public static HealthCheckResult healthy(String message) {
        return new HealthCheckResult(true, message, Map.of(), System.currentTimeMillis());
    }
    
    public static HealthCheckResult unhealthy(String message, Map<String, Object> details) {
        return new HealthCheckResult(false, message, details, System.currentTimeMillis());
    }
    
    // Constructor and getters...
}

// Database Health Check
public class DatabaseHealthCheck implements HealthCheck {
    private final DataSource dataSource;
    
    @Override
    public HealthCheckResult check() {
        try (Connection connection = dataSource.getConnection()) {
            // Simple query to test connectivity
            try (Statement stmt = connection.createStatement()) {
                stmt.executeQuery("SELECT 1").close();
            }
            
            return HealthCheckResult.healthy("Database connection successful");
            
        } catch (SQLException e) {
            Map<String, Object> details = Map.of(
                "error", e.getMessage(),
                "sqlState", e.getSQLState(),
                "errorCode", e.getErrorCode()
            );
            
            return HealthCheckResult.unhealthy("Database connection failed", details);
        }
    }
}

// Service Health Monitor
@Component
public class ServiceHealthMonitor {
    private final List<HealthCheck> healthChecks;
    private final LoadBalancer loadBalancer;
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(2);
    
    @PostConstruct
    public void startHealthChecks() {
        // Check health every 30 seconds
        scheduler.scheduleAtFixedRate(this::performHealthChecks, 0, 30, TimeUnit.SECONDS);
    }
    
    private void performHealthChecks() {
        for (HealthCheck healthCheck : healthChecks) {
            CompletableFuture.supplyAsync(healthCheck::check)
                .thenAccept(this::updateServerHealth)
                .exceptionally(throwable -> {
                    log.error("Health check failed", throwable);
                    return null;
                });
        }
    }
    
    private void updateServerHealth(HealthCheckResult result) {
        HealthStatus status = result.isHealthy() ? HealthStatus.HEALTHY : HealthStatus.UNHEALTHY;
        
        // Update load balancer
        loadBalancer.updateServerHealth(getServerId(), status);
        
        // Publish health change event
        if (!result.isHealthy()) {
            eventPublisher.publish(new ServiceUnhealthyEvent(getServerId(), result));
        }
    }
}
```

### Combining Load Balancer + Circuit Breaker

```html
// Resilient Service Client
@Service
public class ResilientServiceClient {
    private final LoadBalancer loadBalancer;
    private final Map<String, CircuitBreaker> circuitBreakers = new ConcurrentHashMap<>();
    private final RestTemplate restTemplate;
    
    public <T> T callService(String serviceName, String path, Class<T> responseType) {
        ServerInstance server = loadBalancer.selectServer(new ServiceRequest(serviceName));
        CircuitBreaker circuitBreaker = getOrCreateCircuitBreaker(server.getId());
        
        return circuitBreaker.execute(() -> {
            server.incrementConnections();
            long startTime = System.currentTimeMillis();
            
            try {
                String url = "http://" + server.getHost() + ":" + server.getPort() + path;
                T response = restTemplate.getForObject(url, responseType);
                
                // Update server metrics
                long responseTime = System.currentTimeMillis() - startTime;
                server.setResponseTime(responseTime);
                
                return response;
                
            } finally {
                server.decrementConnections();
            }
        });
    }
    
    private CircuitBreaker getOrCreateCircuitBreaker(String serverId) {
        return circuitBreakers.computeIfAbsent(serverId, id -> 
            new CircuitBreaker(
                "service-" + id,
                new CircuitBreakerConfig(5, 3000, 30000, 3)
            )
        );
    }
}
```

### System Architecture: Complete Resilient System

```html
[Client] → [API Gateway + Load Balancer] → [Service A + Circuit Breaker] → [Database]
                     ↓                              ↓                           ↓
              [Health Checks]                [Fallback Logic]              [Health Check]
                     ↓                              ↓                           ↓
              [Service Registry]              [Metrics & Monitoring]        [Backup Database]
```

### Production Lessons: What I Learned

### Load Balancing Lessons

1. **Consider request characteristics**: Not all requests are equal some are CPU intensive, others are I/O heavy
2. **Monitor server health continuously**: Static configuration isn’t enough
3. **Use multiple load balancing layers**: DNS → L7 → L4 for different purposes
4. **Implement gradual traffic shifting**: Don’t dump all traffic on a new server immediately

### Circuit Breaker Lessons

1. **Tune thresholds carefully**: Too sensitive = frequent outages, too loose = slow failure detection
2. **Implement proper fallbacks**: Circuit breaker without fallback is just fast failure
3. **Monitor circuit breaker states**: Open circuits indicate system health issues
4. **Use different timeouts**: Network timeout!= Circuit breaker timeout

### Tomorrow’s Preview

Day 9: “Database Patterns & Repository Pattern”. How to abstract data access properly and choose the right database patterns for your use case.

### Your Architect Assignment

Examine your current system:

1. **Find single points of failure** that need load balancing
2. **Identify external dependencies** that could benefit from circuit breakers
3. **Look for places where failures cascade** through your system
4. **Check if you have proper health monitoring** and failover mechanisms

Remember: **Load balancing distributes the load intelligently. Circuit breakers prevent cascading failures. Together, they make your systems resilient at scale.**

*Previous articles:*

- [*Day 1 — Building Your Architect Mindset*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [*Day 2 — Strategy & Observer Patterns*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [*Day 3 — Decorator & Proxy Patterns*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [*Day 4 — Singleton & Builder Patterns*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [*Day 5 — Command & Template Method Patterns*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [*Day 6 — Adapter & Facade Patterns*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [*Day 7 — Chain of Responsibility & State Patterns*](https://archive.is/o/WC6CY/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)

> *Follow along daily as we master the system architecture patterns that keep distributed systems running reliably at scale.*

[0%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#0%) [10%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#10%) [20%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#20%) [30%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#30%) [40%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#40%) [50%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#50%) [60%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#60%) [70%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#70%) [80%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#80%) [90%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#90%) [100%](https://archive.is/20250922150612/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed#100%)