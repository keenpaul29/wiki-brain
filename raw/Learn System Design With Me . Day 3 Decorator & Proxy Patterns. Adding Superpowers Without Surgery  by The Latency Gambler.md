---
title: "Learn System Design With Me . Day 3: Decorator & Proxy Patterns. Adding Superpowers Without Surgery | by The Latency Gambler"
source: "https://freedium-mirror.cfd/medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164"
author:
  - "[[The Latency Gambler]]"
published:
created: 2026-05-26
description: "This is Day 3 of our 30-day journey from code writer to system architect. Catch up on Day 1 and..."
tags:
  - "clippings"
---
[< Go to the original](https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/0*HO-3QDQIMGZyxtoH)

## Learn System Design With Me. Day 3: Decorator & Proxy Patterns. Adding Superpowers Without Surgery

## This is Day 3 of our 30-day journey from code writer to system architect. Catch up on Day 1 and Day 2

a11y-light · September 15, 2025 (Updated: September 15, 2025) · Free: No

Yesterday, we mastered Strategy and Observer for runtime flexibility and event-driven architectures. Today, we're diving into the **surgical precision patterns**: Decorator and Proxy.

Here's the architect's perspective: **Sometimes you need to enhance existing objects without breaking them open.** Think Netflix adding monitoring to every microservice call, or Amazon wrapping services with caching layers. That's where these patterns become system design superpowers.

#### Why These Patterns Matter for System Architects

Most developers see these as wrapper patterns. **Architects see them as cross-cutting concern solutions:**

- **Decorator Pattern**: Add features layer by layer (logging, caching, security, monitoring)
- **Proxy Pattern**: Control access and add behavior transparently (load balancing, lazy loading, security)

> Let me show you how production systems actually use them.

#### Decorator Pattern: Layered Enhancement

#### The System Design Problem

Your payment service works perfectly. Now your PM wants logging. Then security team wants audit trails. Then ops wants metrics. Traditional approach? Modify the core payment logic each time. **Architect approach? Decorator Pattern.**

```java
// Component Interface - Your System Contract
public interface PaymentProcessor {
    PaymentResult process(PaymentRequest request);
}

// Core Implementation - Your Business Logic
public class StripePaymentProcessor implements PaymentProcessor {
    @Override
    public PaymentResult process(PaymentRequest request) {
        // Core payment logic - stays untouched
        return callStripeAPI(request);
    }
}

// Base Decorator - Framework for Enhancement
public abstract class PaymentProcessorDecorator implements PaymentProcessor {
    protected final PaymentProcessor processor;
    
    public PaymentProcessorDecorator(PaymentProcessor processor) {
        this.processor = processor;
    }
    
    @Override
    public PaymentResult process(PaymentRequest request) {
        return processor.process(request);
    }
}

// Concrete Decorators - Your Cross-Cutting Concerns
public class LoggingDecorator extends PaymentProcessorDecorator {
    public LoggingDecorator(PaymentProcessor processor) {
        super(processor);
    }
    
    @Override
    public PaymentResult process(PaymentRequest request) {
        log.info("Processing payment: {}", request.getId());
        try {
            PaymentResult result = super.process(request);
            log.info("Payment processed: {} - {}", request.getId(), result.getStatus());
            return result;
        } catch (Exception e) {
            log.error("Payment failed: {}", request.getId(), e);
            throw e;
        }
    }
}

public class MetricsDecorator extends PaymentProcessorDecorator {
    private final MeterRegistry meterRegistry;
    
    @Override
    public PaymentResult process(PaymentRequest request) {
        Timer.Sample sample = Timer.start(meterRegistry);
        try {
            PaymentResult result = super.process(request);
            meterRegistry.counter("payment.success").increment();
            return result;
        } catch (Exception e) {
            meterRegistry.counter("payment.failure").increment();
            throw e;
        } finally {
            sample.stop(Timer.builder("payment.duration").register(meterRegistry));
        }
    }
}
```

#### System Architecture: Layered Enhancement

```
[Client] → [Security Decorator] → [Metrics Decorator] → [Logging Decorator] → [Cache Decorator] → [Core Service]
```

**Architecture Benefit**: Each layer adds one concern. Core business logic stays pure.

#### Advanced Decorator: Spring AOP Integration

```
// Spring's Decorator Pattern Implementation
@Component
public class PaymentService {
    
    @Audit // Decorator via annotation
    @Cacheable("payments") // Decorator via annotation
    @Timed // Decorator via annotation
    public PaymentResult processPayment(PaymentRequest request) {
        return stripeProcessor.process(request);
    }
}

// Behind the scenes, Spring creates:
// AuditDecorator(CacheDecorator(TimedDecorator(PaymentService)))
```

#### Decorator Ordering: Critical for Production

```java
@Configuration
public class PaymentProcessorConfig {
    
    @Bean
    public PaymentProcessor paymentProcessor() {
        PaymentProcessor core = new StripePaymentProcessor();
        
        // Order matters! Security → Metrics → Logging → Cache → Core
        return new SecurityDecorator(
            new MetricsDecorator(
                new LoggingDecorator(
                    new CacheDecorator(core)
                )
            )
        );
    }
}
```

> **Production Lesson**: Security checks must happen before caching. Metrics should capture all requests, not just cache misses.

#### Runtime Decoration: Dynamic Behavior

```typescript
public class DynamicPaymentProcessor {
    private PaymentProcessor processor;
    
    @PostConstruct
    public void initializeProcessor() {
        processor = new StripePaymentProcessor();
        
        // Add decorators based on configuration
        if (config.isLoggingEnabled()) {
            processor = new LoggingDecorator(processor);
        }
        
        if (config.isMetricsEnabled()) {
            processor = new MetricsDecorator(processor);
        }
        
        // A/B test: 10% get fraud detection
        if (experimentService.isEnabled("fraud-detection", 0.1)) {
            processor = new FraudDetectionDecorator(processor);
        }
    }
}
```

#### Proxy Pattern: Transparent Control

#### The System Design Reality

Your database queries are getting slow. You need caching but don't want to change 200+ service classes. **Proxy Pattern to the rescue.**

```typescript
// Subject Interface - Your System Contract
public interface UserRepository {
    User findById(String id);
    List<User> findByEmail(String email);
    void save(User user);
}

// Real Subject - Your Actual Implementation
public class DatabaseUserRepository implements UserRepository {
    @Override
    public User findById(String id) {
        return jdbcTemplate.queryForObject(
            "SELECT * FROM users WHERE id = ?", 
            userRowMapper, 
            id
        );
    }
    
    @Override
    public void save(User user) {
        // Database save logic
        jdbcTemplate.update("INSERT INTO users...", user);
    }
}

// Virtual Proxy - Lazy Loading & Caching
public class CachingUserRepositoryProxy implements UserRepository {
    private final UserRepository repository;
    private final Cache<String, User> cache;
    
    public CachingUserRepositoryProxy(UserRepository repository) {
        this.repository = repository;
        this.cache = Caffeine.newBuilder()
            .maximumSize(10_000)
            .expireAfterWrite(Duration.ofMinutes(15))
            .build();
    }
    
    @Override
    public User findById(String id) {
        return cache.get(id, key -> {
            log.debug("Cache miss for user: {}", id);
            return repository.findById(key);
        });
    }
    
    @Override
    public void save(User user) {
        repository.save(user);
        // Invalidate cache on write
        cache.invalidate(user.getId());
        
        // Also invalidate email-based lookups
        cache.invalidateAll();
    }
}
```

#### Types of Proxies in Production Systems

#### 1\. Remote Proxy: Distributed Systems

```java
// gRPC Remote Proxy
public class GrpcUserServiceProxy implements UserService {
    private final UserServiceGrpc.UserServiceBlockingStub stub;
    
    @Override
    public User getUser(String id) {
        GetUserRequest request = GetUserRequest.newBuilder()
            .setUserId(id)
            .build();
            
        GetUserResponse response = stub.getUser(request);
        return mapToUser(response.getUser());
    }
}

// Circuit Breaker Proxy for Resilience
public class CircuitBreakerUserServiceProxy implements UserService {
    private final UserService userService;
    private final CircuitBreaker circuitBreaker;
    
    @Override
    public User getUser(String id) {
        return circuitBreaker.executeSupplier(() -> userService.getUser(id));
    }
}
```

#### 2\. Protection Proxy: Security Control

```java
public class SecurityUserRepositoryProxy implements UserRepository {
    private final UserRepository repository;
    private final SecurityContext securityContext;
    
    @Override
    public User findById(String id) {
        if (!securityContext.hasPermission("USER_READ")) {
            throw new AccessDeniedException("Insufficient permissions");
        }
        
        User user = repository.findById(id);
        
        // Data masking for non-admin users
        if (!securityContext.hasRole("ADMIN")) {
            user.setEmail(maskEmail(user.getEmail()));
            user.setSsn(null);
        }
        
        return user;
    }
}
```

#### 3\. Smart Proxy: Performance Optimization

```typescript
public class SmartDatabaseProxy implements DatabaseConnection {
    private final DatabaseConnection connection;
    private final Map<String, PreparedStatement> statementCache = new ConcurrentHashMap<>();
    
    @Override
    public ResultSet executeQuery(String sql) {
        // Connection pooling
        if (connection.isClosed()) {
            connection = connectionPool.getConnection();
        }
        
        // Statement caching
        PreparedStatement stmt = statementCache.computeIfAbsent(sql, 
            connection::prepareStatement);
        
        // Query result caching
        String cacheKey = sql + Arrays.toString(parameters);
        return queryCache.get(cacheKey, () -> stmt.executeQuery());
    }
}
```

#### Dynamic Proxies: Runtime Magic

```java
// Java Reflection Proxy - Runtime Interface Implementation
public class DynamicLoggingProxy {
    
    @SuppressWarnings("unchecked")
    public static <T> T createProxy(T target, Class<T> interfaceType) {
        return (T) Proxy.newProxyInstance(
            interfaceType.getClassLoader(),
            new Class[]{interfaceType},
            (proxy, method, args) -> {
                long start = System.currentTimeMillis();
                
                log.info("Calling method: {} with args: {}", 
                    method.getName(), Arrays.toString(args));
                
                try {
                    Object result = method.invoke(target, args);
                    log.info("Method {} completed in {}ms", 
                        method.getName(), System.currentTimeMillis() - start);
                    return result;
                } catch (Exception e) {
                    log.error("Method {} failed", method.getName(), e);
                    throw e;
                }
            }
        );
    }
}

// Usage
UserService userService = new DatabaseUserService();
UserService proxiedService = DynamicLoggingProxy.createProxy(userService, UserService.class);
```

#### CGLIB Proxy: Class-Based Proxying

```kotlin
// When you don't have interfaces - Spring's magic
public class CglibMethodInterceptor implements MethodInterceptor {
    
    @Override
    public Object intercept(Object obj, Method method, Object[] args, 
                          MethodProxy proxy) throws Throwable {
        
        if (method.isAnnotationPresent(Transactional.class)) {
            return executeInTransaction(() -> proxy.invokeSuper(obj, args));
        }
        
        return proxy.invokeSuper(obj, args);
    }
}

// Spring creates these automatically for @Transactional, @Cacheable, etc.
```

#### Combining Decorator + Proxy: Production Power

```
@Service
public class EnhancedPaymentService {
    
    // Spring creates: 
    // TransactionProxy(
    //   CacheProxy(
    //     SecurityDecorator(
    //       MetricsDecorator(
    //         LoggingDecorator(PaymentService)))))
    
    @Transactional  // Proxy for transaction management
    @Cacheable      // Proxy for caching
    @PreAuthorize("hasRole('PAYMENT_PROCESSOR')") // Security proxy
    @Timed         // Decorator for metrics
    @Audit         // Decorator for audit logging
    public PaymentResult processPayment(PaymentRequest request) {
        return corePaymentLogic(request);
    }
}
```

#### System Architecture: Real-World Application

#### API Gateway Pattern with Proxy

```typescript
[Client] → [API Gateway Proxy] → [Rate Limiting Proxy] → [Auth Proxy] → [Load Balancer Proxy] → [Service]

// Zuul/Spring Cloud Gateway implementation
@Component
public class APIGatewayProxy implements RequestHandler {
    
    public ResponseEntity<?> handleRequest(HttpServletRequest request) {
        // Chain of proxies
        RequestHandler handler = new RateLimitProxy(
            new AuthenticationProxy(
                new LoadBalancerProxy(
                    new TargetServiceProxy()
                )
            )
        );
        
        return handler.handle(request);
    }
}
```

#### Microservices with Netflix's Approach

```kotlin
// Netflix Hystrix + Ribbon + Eureka
@FeignClient(name = "user-service")
public interface UserServiceClient extends UserService {
    // Feign creates a proxy that includes:
    // - Service discovery (Eureka)
    // - Load balancing (Ribbon) 
    // - Circuit breaking (Hystrix)
    // - Request/response logging
}
```

#### Anti-Patterns: What Goes Wrong

#### Decorator Hell

```java
// DON'T DO THIS - Unreadable, unmaintainable
PaymentProcessor processor = 
    new SecurityDecorator(
        new ValidationDecorator(
            new AuditDecorator(
                new LoggingDecorator(
                    new MetricsDecorator(
                        new CacheDecorator(
                            new RetryDecorator(
                                new CircuitBreakerDecorator(
                                    new TimeoutDecorator(
                                        new CorePaymentProcessor()
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    );
```

> **Solution**: Use builder pattern or configuration-based decoration.

#### Proxy Hell

```java
// DON'T DO THIS - Proxy inception
Object finalProxy = 
    SecurityProxy.wrap(
        CacheProxy.wrap(
            TransactionProxy.wrap(
                LoggingProxy.wrap(
                    ValidationProxy.wrap(target)
                )
            )
        )
    );
```

> **Solution**: Consolidate related concerns or use AOP frameworks.

#### Transparency Violation

```typescript
// BAD - Proxy changes behavior unexpectedly
public class BadCachingProxy implements UserService {
    @Override
    public User getUser(String id) {
        // Returns cached version that might be stale
        // Client has no idea caching is happening
        // No cache control options
    }
}
```

#### Distributed Systems: Advanced Scenarios

#### Event Sourcing with Decorator

```java
public class EventSourcingDecorator implements OrderService {
    private final OrderService orderService;
    private final EventStore eventStore;
    
    @Override
    public void updateOrder(Order order) {
        // Capture state before
        Order before = orderService.getOrder(order.getId());
        
        // Execute operation
        orderService.updateOrder(order);
        
        // Store event
        OrderUpdatedEvent event = new OrderUpdatedEvent(before, order);
        eventStore.append(event);
    }
}
```

#### Reactive Streams with Proxy

```typescript
public class BackpressureUserServiceProxy implements ReactiveUserService {
    private final ReactiveUserService userService;
    
    @Override
    public Flux<User> getUsers(Flux<String> userIds) {
        return userIds
            .buffer(100) // Batch requests
            .delayElements(Duration.ofMillis(100)) // Rate limiting
            .flatMap(batch -> userService.getUsers(Flux.fromIterable(batch)))
            .onBackpressureBuffer(1000); // Handle backpressure
    }
}
```

#### Production Lessons: What I Learned

1. **Decorator order matters**: Security before caching, metrics before logging
2. **Proxy transparency**: Users should never know they're talking to a proxy
3. **Performance impact**: Each layer adds overhead — measure everything
4. **Error handling**: Decorators/proxies can mask original exceptions
5. **Testing complexity**: Mocking becomes harder with multiple layers

#### Tomorrow's Preview

Day 4: "Singleton & Builder Patterns (The Right Way)". Why Singleton is dangerous in distributed systems and how Builder pattern becomes your configuration superhero.

#### Your Architect Assignment

Examine your current system:

1. **Find repeated cross-cutting concerns** that scream for decorators
2. **Identify places where you modify classes** instead of extending them
3. **Spot opportunities for transparent enhancement** with proxies

> Remember: **Great architects enhance systems without breaking them. These patterns are your surgical tools.**

*Previous:* *[Day 2 — Strategy & Observer Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*

*Start from:* *[Day 1 — Building Your Architect Mindset](https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)*

*Follow along daily as we master the patterns that power scalable systems.*

[< Go to the original](https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164#bypass)