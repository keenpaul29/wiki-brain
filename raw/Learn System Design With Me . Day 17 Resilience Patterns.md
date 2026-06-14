---
title: "Learn System Design With Me . Day 17: Resilience Patterns"
source: "https://archive.is/Tin0A"
author:
  - "[[The Latency Gambler]]"
published: 2025-10-07
created: 2026-06-14
description:
tags:
  - "clippings"
---


## Building Systems That Never Truly Fail

*This is Day 17 of our 30-day journey from code writer to system architect. Start with* [*Day 1*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build the foundation, then progress through* [*Day 2*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*,* [*Day 3*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*,* [*Day 4*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*,* [*Day 5*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*,* [*Day 6*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*,* [*Day 7*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)*,* [*Day 8*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)*,* [*Day 9*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)*,* [*Day 10*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)*,* [*Day 11*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)*,* [*Day 12*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)*,* [*Day 13*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)*,* [*Day 14*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-14-monitoring-observer-patterns-cdd2bba68d9f)*,* [*Day 15*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-15-microservices-patterns-532c7a4ab899)*, and* [*Day 16*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-16-distributed-system-patterns-87d47197b01a)

We’ve mastered distributed coordination. Today, we tackle **resilience patterns**: how to build systems that **gracefully handle failures** instead of crashing spectacularly.

![](https://d1gg06srkavypg.archive.is/Tin0A/c853ae244e26fc8a97ab062fc425036fbad4ce01.webp)

Ai Generated Image

Here’s the production reality: **Everything fails networks, databases, APIs, servers. Resilient systems expect failure and handle it gracefully. Fragile systems assume perfection and crash hard.**

### Why Resilience Patterns Matter

## The Failure Reality

In distributed systems:

- **Transient failures**: Network blips, temporary overload (70% of failures)
- **Timeout failures**: Slow responses that waste resources
- **Cascading failures**: One service failure triggers others
- **Permanent failures**: Service completely unavailable

### The Cost of Non-Resilience

Without resilience patterns:

- **User-facing errors**: 500 errors instead of degraded functionality
- **Resource exhaustion**: Threads waiting indefinitely
- **Cascade failures**: Entire system goes down
- **Revenue loss**: Every minute of downtime costs money

### Retry Pattern: Handling Transient Failures

### What It Solves

**Retry pattern** automatically **retries failed operations** with intelligent backoff, handling temporary network issues, database deadlocks, and service overload.

### Basic Retry Implementation

```html
// Retry Configuration
@Data
@Builder
public class RetryConfig {
    private int maxAttempts;
    private long initialDelayMs;
    private long maxDelayMs;
    private double backoffMultiplier;
    private Set<Class<? extends Exception>> retryableExceptions;
    private Set<Class<? extends Exception>> nonRetryableExceptions;
}

// Retry Executor
@Component
public class RetryExecutor {
    
    public <T> T executeWithRetry(Supplier<T> operation, RetryConfig config) {
        int attempt = 0;
        long delay = config.getInitialDelayMs();
        Exception lastException = null;
        
        while (attempt < config.getMaxAttempts()) {
            attempt++;
            
            try {
                T result = operation.get();
                
                if (attempt > 1) {
                    log.info("Operation succeeded on attempt {}", attempt);
                }
                
                return result;
                
            } catch (Exception e) {
                lastException = e;
                
                // Check if exception is retryable
                if (!isRetryable(e, config)) {
                    log.error("Non-retryable exception occurred", e);
                    throw e;
                }
                
                if (attempt >= config.getMaxAttempts()) {
                    log.error("Max retry attempts {} reached", config.getMaxAttempts());
                    break;
                }
                
                log.warn("Operation failed on attempt {}/{}. Retrying after {}ms", 
                        attempt, config.getMaxAttempts(), delay, e);
                
                // Wait before retry
                sleep(delay);
                
                // Exponential backoff
                delay = Math.min(
                    (long) (delay * config.getBackoffMultiplier()),
                    config.getMaxDelayMs()
                );
            }
        }
        
        throw new MaxRetriesExceededException(
            "Operation failed after " + config.getMaxAttempts() + " attempts", 
            lastException
        );
    }
    
    private boolean isRetryable(Exception e, RetryConfig config) {
        Class<? extends Exception> exceptionClass = e.getClass();
        
        // Non-retryable takes precedence
        if (config.getNonRetryableExceptions().stream()
                .anyMatch(nonRetryable -> nonRetryable.isAssignableFrom(exceptionClass))) {
            return false;
        }
        
        // Check if explicitly retryable
        return config.getRetryableExceptions().stream()
                .anyMatch(retryable -> retryable.isAssignableFrom(exceptionClass));
    }
    
    private void sleep(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Retry interrupted", e);
        }
    }
}

// Usage Example
@Service
public class PaymentService {
    private final RetryExecutor retryExecutor;
    private final PaymentGateway paymentGateway;
    
    public PaymentResult processPayment(PaymentRequest request) {
        RetryConfig config = RetryConfig.builder()
            .maxAttempts(3)
            .initialDelayMs(1000)
            .maxDelayMs(10000)
            .backoffMultiplier(2.0)
            .retryableExceptions(Set.of(
                SocketTimeoutException.class,
                ConnectException.class,
                TransientDatabaseException.class
            ))
            .nonRetryableExceptions(Set.of(
                InvalidCardException.class,
                InsufficientFundsException.class,
                AuthenticationException.class
            ))
            .build();
        
        return retryExecutor.executeWithRetry(
            () -> paymentGateway.charge(request),
            config
        );
    }
}
```

### Advanced Retry with Jitter

**Why jitter?** Without jitter, all retries happen simultaneously, creating **thundering herd** problem.

```html
@Component
public class AdvancedRetryExecutor {
    private final Random random = new Random();
    
    public <T> T executeWithRetry(Supplier<T> operation, RetryConfig config) {
        int attempt = 0;
        long baseDelay = config.getInitialDelayMs();
        
        while (attempt < config.getMaxAttempts()) {
            attempt++;
            
            try {
                return operation.get();
            } catch (Exception e) {
                if (!isRetryable(e, config) || attempt >= config.getMaxAttempts()) {
                    throw e;
                }
                
                // Exponential backoff with jitter
                long exponentialDelay = (long) (baseDelay * Math.pow(config.getBackoffMultiplier(), attempt - 1));
                long cappedDelay = Math.min(exponentialDelay, config.getMaxDelayMs());
                
                // Add jitter: random value between 0 and full delay
                long jitter = (long) (cappedDelay * random.nextDouble());
                long actualDelay = cappedDelay + jitter;
                
                log.warn("Retry attempt {}/{} after {}ms (jitter: {}ms)", 
                        attempt, config.getMaxAttempts(), actualDelay, jitter);
                
                sleep(actualDelay);
            }
        }
        
        throw new MaxRetriesExceededException("Max retries exceeded");
    }
}
```

### Timeout Pattern: Preventing Resource Exhaustion

### What It Solves

**Timeout pattern** prevents indefinite waiting by **setting maximum wait time** for operations, protecting against:

- Slow external services
- Database query hangs
- Thread pool exhaustion
- Memory leaks from waiting threads

### Timeout Implementation

```html
// Timeout Executor
@Component
public class TimeoutExecutor {
    private final ExecutorService executorService = Executors.newCachedThreadPool();
    
    public <T> T executeWithTimeout(Supplier<T> operation, Duration timeout) {
        Future<T> future = executorService.submit(() -> operation.get());
        
        try {
            return future.get(timeout.toMillis(), TimeUnit.MILLISECONDS);
            
        } catch (TimeoutException e) {
            future.cancel(true);
            throw new OperationTimeoutException(
                "Operation timed out after " + timeout.toMillis() + "ms", e);
                
        } catch (ExecutionException e) {
            throw new RuntimeException("Operation failed", e.getCause());
            
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Operation interrupted", e);
        }
    }
    
    // Async version with CompletableFuture
    public <T> CompletableFuture<T> executeWithTimeoutAsync(Supplier<T> operation, Duration timeout) {
        CompletableFuture<T> future = CompletableFuture.supplyAsync(operation);
        
        CompletableFuture<T> timeoutFuture = new CompletableFuture<>();
        
        // Schedule timeout
        executorService.schedule(() -> {
            if (!future.isDone()) {
                timeoutFuture.completeExceptionally(
                    new OperationTimeoutException("Async operation timed out"));
                future.cancel(true);
            }
        }, timeout.toMillis(), TimeUnit.MILLISECONDS);
        
        // Complete with whichever finishes first
        future.whenComplete((result, throwable) -> {
            if (throwable != null) {
                timeoutFuture.completeExceptionally(throwable);
            } else {
                timeoutFuture.complete(result);
            }
        });
        
        return timeoutFuture;
    }
}

// Usage with different timeout strategies
@Service
public class UserService {
    private final TimeoutExecutor timeoutExecutor;
    private final UserRepository userRepository;
    private final RecommendationService recommendationService;
    
    public User getUserWithRecommendations(String userId) {
        // Critical operation - strict timeout
        User user = timeoutExecutor.executeWithTimeout(
            () -> userRepository.findById(userId),
            Duration.ofSeconds(2)
        );
        
        // Non-critical operation - longer timeout with fallback
        try {
            List<Product> recommendations = timeoutExecutor.executeWithTimeout(
                () -> recommendationService.getRecommendations(userId),
                Duration.ofSeconds(1)
            );
            user.setRecommendations(recommendations);
        } catch (OperationTimeoutException e) {
            log.warn("Recommendations timed out, using empty list");
            user.setRecommendations(Collections.emptyList());
        }
        
        return user;
    }
}
```

### Layered Timeout Strategy

```html
@Component
public class LayeredTimeoutService {
    
    public Response callExternalService(Request request) {
        // Layer 1: Connection timeout (fast fail if can't connect)
        RestTemplate restTemplate = new RestTemplate();
        HttpComponentsClientHttpRequestFactory requestFactory = 
            new HttpComponentsClientHttpRequestFactory();
        requestFactory.setConnectTimeout(2000);        // 2s to establish connection
        requestFactory.setReadTimeout(5000);           // 5s to read response
        requestFactory.setConnectionRequestTimeout(1000); // 1s to get connection from pool
        restTemplate.setRequestFactory(requestFactory);
        
        // Layer 2: Circuit breaker timeout (fail fast if service is down)
        CircuitBreaker circuitBreaker = circuitBreakerRegistry.circuitBreaker("external-service");
        
        // Layer 3: Overall operation timeout (absolute maximum)
        return timeoutExecutor.executeWithTimeout(() -> {
            return circuitBreaker.executeSupplier(() -> {
                return restTemplate.postForObject(serviceUrl, request, Response.class);
            });
        }, Duration.ofSeconds(10));
    }
}
```

### Fallback and Graceful Degradation Patterns

### What They Solve

**Fallback patterns** provide **alternative responses** when primary operations fail. **Graceful degradation** maintains **partial functionality** instead of complete failure.

### Fallback Implementation

```html
// Fallback Strategy Interface
public interface FallbackStrategy<T> {
    T getFallback(Exception cause);
    String getStrategyName();
}

// Cached Data Fallback
public class CachedDataFallback<T> implements FallbackStrategy<T> {
    private final Cache<String, T> cache;
    private final String cacheKey;
    
    @Override
    public T getFallback(Exception cause) {
        T cachedValue = cache.getIfPresent(cacheKey);
        
        if (cachedValue != null) {
            log.info("Using cached fallback for key: {}", cacheKey);
            return cachedValue;
        }
        
        log.warn("No cached fallback available for key: {}", cacheKey);
        return null;
    }
    
    @Override
    public String getStrategyName() {
        return "CachedDataFallback";
    }
}
// Default Value Fallback
public class DefaultValueFallback<T> implements FallbackStrategy<T> {
    private final T defaultValue;
    
    @Override
    public T getFallback(Exception cause) {
        log.info("Using default value fallback");
        return defaultValue;
    }
    
    @Override
    public String getStrategyName() {
        return "DefaultValueFallback";
    }
}
// Degraded Service Fallback
public class DegradedServiceFallback<T> implements FallbackStrategy<T> {
    private final Supplier<T> degradedOperation;
    
    @Override
    public T getFallback(Exception cause) {
        log.info("Using degraded service fallback");
        try {
            return degradedOperation.get();
        } catch (Exception e) {
            log.error("Degraded service also failed", e);
            return null;
        }
    }
    
    @Override
    public String getStrategyName() {
        return "DegradedServiceFallback";
    }
}
// Resilient Executor with Fallback Chain
@Component
public class ResilientExecutor {
    
    public <T> T executeWithFallbackChain(
            Supplier<T> primaryOperation,
            List<FallbackStrategy<T>> fallbackStrategies) {
        
        Exception lastException = null;
        
        // Try primary operation
        try {
            return primaryOperation.get();
        } catch (Exception e) {
            lastException = e;
            log.warn("Primary operation failed: {}", e.getMessage());
        }
        
        // Try fallback strategies in order
        for (FallbackStrategy<T> fallback : fallbackStrategies) {
            try {
                log.info("Attempting fallback strategy: {}", fallback.getStrategyName());
                
                T result = fallback.getFallback(lastException);
                
                if (result != null) {
                    log.info("Fallback strategy {} succeeded", fallback.getStrategyName());
                    return result;
                }
            } catch (Exception e) {
                log.error("Fallback strategy {} failed", fallback.getStrategyName(), e);
                lastException = e;
            }
        }
        
        throw new AllFallbacksFailedException("All fallback strategies exhausted", lastException);
    }
}
// Real-World Usage: Product Recommendations
@Service
public class RecommendationService {
    private final ResilientExecutor resilientExecutor;
    private final MLRecommendationService mlService;
    private final PopularProductsService popularService;
    private final Cache<String, List<Product>> cache;
    
    public List<Product> getRecommendations(String userId) {
        List<FallbackStrategy<List<Product>>> fallbacks = List.of(
            // Fallback 1: Use cached recommendations
            new CachedDataFallback<>(cache, "recommendations:" + userId),
            
            // Fallback 2: Use simpler recommendation algorithm
            new DegradedServiceFallback<>(() -> 
                popularService.getPopularProductsForUser(userId)
            ),
            
            // Fallback 3: Generic popular products
            new DegradedServiceFallback<>(() -> 
                popularService.getGlobalPopularProducts()
            ),
            
            // Fallback 4: Empty list (graceful degradation)
            new DefaultValueFallback<>(Collections.emptyList())
        );
        
        return resilientExecutor.executeWithFallbackChain(
            () -> mlService.getPersonalizedRecommendations(userId),
            fallbacks
        );
    }
}
```

### Graceful Degradation Pattern

```html
// Feature Flag-Based Degradation
@Service
public class DashboardService {
    private final FeatureFlagService featureFlags;
    private final UserService userService;
    private final OrderService orderService;
    private final RecommendationService recommendationService;
    private final AnalyticsService analyticsService;
    
    public DashboardResponse getDashboard(String userId) {
        DashboardResponse.Builder dashboard = DashboardResponse.builder();
        
        // Critical feature - always include
        try {
            User user = userService.getUser(userId);
            dashboard.user(user);
        } catch (Exception e) {
            log.error("Failed to load user - critical failure", e);
            throw e; // Don't degrade, this is essential
        }
        
        // Important feature - degrade if slow or failing
        try {
            if (featureFlags.isEnabled("orders.feature")) {
                List<Order> orders = timeoutExecutor.executeWithTimeout(
                    () -> orderService.getRecentOrders(userId),
                    Duration.ofSeconds(2)
                );
                dashboard.orders(orders);
            } else {
                log.info("Orders feature disabled by feature flag");
                dashboard.orders(Collections.emptyList());
            }
        } catch (Exception e) {
            log.warn("Orders feature degraded", e);
            dashboard.orders(Collections.emptyList());
            dashboard.degradedFeature("orders");
        }
        
        // Nice-to-have feature - skip if problematic
        try {
            if (featureFlags.isEnabled("recommendations.feature")) {
                List<Product> recommendations = timeoutExecutor.executeWithTimeout(
                    () -> recommendationService.getRecommendations(userId),
                    Duration.ofMillis(500) // Shorter timeout for non-critical
                );
                dashboard.recommendations(recommendations);
            }
        } catch (Exception e) {
            log.info("Recommendations feature unavailable", e);
            // Don't include recommendations - graceful degradation
        }
        
        // Fire-and-forget feature - don't wait
        CompletableFuture.runAsync(() -> {
            try {
                analyticsService.trackDashboardView(userId);
            } catch (Exception e) {
                log.debug("Analytics tracking failed", e);
            }
        });
        
        return dashboard.build();
    }
}
```

### Combining All Resilience Patterns

```html
// Complete Resilient Service Client
@Component
public class UltraResilientServiceClient {
    private final RetryExecutor retryExecutor;
    private final TimeoutExecutor timeoutExecutor;
    private final CircuitBreaker circuitBreaker;
    
    public <T> T call(String serviceName, Supplier<T> operation, ResilientConfig config) {
        // Layer 1: Circuit Breaker (fail fast if service is known to be down)
        return circuitBreaker.executeSupplier(() -> {
            
            // Layer 2: Retry with exponential backoff
            return retryExecutor.executeWithRetry(() -> {
                
                // Layer 3: Timeout (prevent hanging)
                return timeoutExecutor.executeWithTimeout(() -> {
                    
                    // Layer 4: Actual operation
                    try {
                        T result = operation.get();
                        
                        // Update cache on success
                        if (config.isCacheable()) {
                            cache.put(config.getCacheKey(), result);
                        }
                        
                        return result;
                        
                    } catch (Exception e) {
                        // Layer 5: Fallback
                        if (config.hasFallback()) {
                            log.warn("Primary operation failed, using fallback");
                            return config.getFallbackStrategy().getFallback(e);
                        }
                        throw e;
                    }
                    
                }, config.getTimeout());
                
            }, config.getRetryConfig());
        });
    }
}
```

### System Architecture: Complete Resilience Stack

```html
[Client Request]
      ↓
[Circuit Breaker] ──(open)──> [Fallback Response]
      ↓ (closed)
[Retry Logic] ──(max retries)──> [Fallback Response]
      ↓
[Timeout Guard] ──(timeout)──> [Fallback Response]
      ↓
[Primary Service] ──(success)──> [Cache Update] ──> [Response]
```

### Production Best Practices

### Monitoring Resilience

```html
@Component
public class ResilienceMetrics {
    private final MeterRegistry registry;
    
    public void recordRetry(String operation, int attempt, boolean success) {
        registry.counter("resilience.retry.total",
            "operation", operation,
            "attempt", String.valueOf(attempt),
            "result", success ? "success" : "failure").increment();
    }
    
    public void recordTimeout(String operation, long durationMs) {
        registry.counter("resilience.timeout.total",
            "operation", operation).increment();
            
        registry.timer("resilience.timeout.duration",
            "operation", operation).record(durationMs, TimeUnit.MILLISECONDS);
    }
    
    public void recordFallback(String operation, String fallbackStrategy) {
        registry.counter("resilience.fallback.total",
            "operation", operation,
            "strategy", fallbackStrategy).increment();
    }
}
```

### Decision Framework

**Use Retry Pattern when:**

- Transient failures are common (network blips)
- Operation is idempotent (safe to retry)
- External service has rate limits
- Cost of retry is acceptable

**Use Timeout Pattern when:**

- Operations can hang indefinitely
- Resource exhaustion is a risk
- User experience requires responsiveness
- SLAs require predictable latency

**Use Fallback Pattern when:**

- Partial functionality is better than none
- Cached or stale data is acceptable
- Multiple data sources available
- Feature can be disabled safely

## Tomorrow’s Preview

Day 18: “Caching & CDN Patterns”. Multi-level caching strategies, Cache warming patterns, CDN patterns for global distribution

## Your Architect Assignment

1. **Audit retry logic** Are you retrying non-idempotent operations?
2. **Check timeouts** Do all external calls have timeouts?
3. **Map fallbacks** What happens when each dependency fails?
4. **Measure degradation** How does your system behave under stress?

Remember: **Resilient systems expect failure. They retry transient errors, timeout hanging operations, and fallback to degraded functionality. Users never see 500 errors — they see slightly degraded experiences while systems recover.**

*Previous articles:*

- [*Day 1 Building Your Architect Mindset*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [*Day 2 Strategy & Observer Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [*Day 3 Decorator & Proxy Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [*Day 4 Singleton & Builder Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [*Day 5 Command & Template Method Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [*Day 6 Adapter & Facade Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [*Day 7 Chain of Responsibility & State Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [*Day 8 Load Balancing & Circuit Breaker Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)
- [*Day 9 Database Patterns & Repository Pattern*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)
- [*Day 10 Caching Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)
- [*Day 11 API Gateway & Proxy Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)
- [*Day 12 Message Queue Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)
- [*Day 13 Event Sourcing & CQRS Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)
- [*Day 14 Monitoring & Observer Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-14-monitoring-observer-patterns-cdd2bba68d9f)
- [*Day 15 Microservices Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-15-microservices-patterns-532c7a4ab899)
- [*Day 16 Distributed System Patterns*](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-16-distributed-system-patterns-87d47197b01a)

## Responses (1)

Write a response[What are your thoughts?](https://archive.is/o/Tin0A/https://medium.com/@kanishks772/learn-system-design-with-me-day-17-resilience-patterns-66cdacce397e)

```html
Noting that 70% of failures are transient really highlights where resilience efforts should be prioritized first.
```

[0%](https://archive.is/Tin0A#0%) [10%](https://archive.is/Tin0A#10%) [20%](https://archive.is/Tin0A#20%) [30%](https://archive.is/Tin0A#30%) [40%](https://archive.is/Tin0A#40%) [50%](https://archive.is/Tin0A#50%) [60%](https://archive.is/Tin0A#60%) [70%](https://archive.is/Tin0A#70%) [80%](https://archive.is/Tin0A#80%) [90%](https://archive.is/Tin0A#90%) [100%](https://archive.is/Tin0A#100%)