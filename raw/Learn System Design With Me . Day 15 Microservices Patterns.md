---
title: "Learn System Design With Me . Day 15: Microservices Patterns"
source: "https://archive.is/ijoWZ"
author:
  - "[[The Latency Gambler]]"
published: 2025-10-01
created: 2026-06-14
description:
tags:
  - "clippings"
---
## Netflix-Scale Service Architecture

*This is Day 15 of our 30-day journey from code writer to system architect. Start with* [*Day 1*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build the foundation, then progress through* [*Day 2*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*,* [*Day 3*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*,* [*Day 4*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*,* [*Day 5*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*,* [*Day 6*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*,* [*Day 7*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)*,* [*Day 8*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)*,* [*Day 9*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)*,* [*Day 10*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)*,* [*Day 11*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)*,* [*Day 12*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)*,* [*Day 13*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)*, and* [*Day 14*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-14-monitoring-observer-patterns-cdd2bba68d9f)

We’ve mastered observability. Today, we tackle **microservices architecture patterns**: the patterns that power Netflix, Uber, and Amazon at scale. This is **Week 3** of our journey, we’re now handling **enterprise-level complexity**.

![](https://da2gnc2darzsq8.archive.is/ijoWZ/def4cb7f4c8cbf2325658f4f962af15dee0fb96c.webp)

Here’s the architect reality: **Microservices aren’t just small services. They’re independently deployable, failure-isolated, and dynamically discoverable. Without proper patterns, they become a distributed monolith nightmare.**

### Service Registry & Discovery: Dynamic Service Location

### The Microservices Problem

In a microservices architecture with hundreds of services:

- **Service instances change dynamically**: Auto-scaling, deployments, failures
- **Hard-coded endpoints don’t work**: IP addresses change constantly
- **Load balancing is complex**: Need to know all healthy instances
- **Service dependencies are unclear**: Who calls whom?

### What Service Discovery Solves

**Service Discovery** allows services to find each other dynamically without hard-coded locations. Think of it as **DNS for microservices, but smarter**.

### Service Registry Implementation

```html
// Service Instance Metadata
@Data
@Builder
public class ServiceInstance {
    private String serviceId;
    private String instanceId;
    private String host;
    private int port;
    private Map<String, String> metadata;
    private HealthStatus healthStatus;
    private LocalDateTime registeredAt;
    private LocalDateTime lastHeartbeat;
    
    public String getServiceUrl() {
        return String.format("http://%s:%d", host, port);
    }
    
    public boolean isHealthy() {
        return healthStatus == HealthStatus.UP &&
               Duration.between(lastHeartbeat, LocalDateTime.now()).toSeconds() < 30;
    }
}

// Service Registry Interface
public interface ServiceRegistry {
    void register(ServiceInstance instance);
    void deregister(String serviceId, String instanceId);
    List<ServiceInstance> getInstances(String serviceId);
    List<ServiceInstance> getHealthyInstances(String serviceId);
    void updateHeartbeat(String serviceId, String instanceId);
    Map<String, List<ServiceInstance>> getAllServices();
}

// In-Memory Service Registry (Production uses Eureka, Consul, etcd)
@Component
public class InMemoryServiceRegistry implements ServiceRegistry {
    private final Map<String, Map<String, ServiceInstance>> registry = new ConcurrentHashMap<>();
    private final ScheduledExecutorService healthCheckExecutor = Executors.newScheduledThreadPool(2);
    
    @PostConstruct
    public void startHealthChecks() {
        // Remove unhealthy instances every 30 seconds
        healthCheckExecutor.scheduleAtFixedRate(this::cleanupUnhealthyInstances, 30, 30, TimeUnit.SECONDS);
    }
    
    @Override
    public void register(ServiceInstance instance) {
        registry.computeIfAbsent(instance.getServiceId(), k -> new ConcurrentHashMap<>())
                .put(instance.getInstanceId(), instance);
                
        log.info("Registered service instance: {}:{} at {}:{}", 
                instance.getServiceId(), instance.getInstanceId(), 
                instance.getHost(), instance.getPort());
    }
    
    @Override
    public void deregister(String serviceId, String instanceId) {
        Map<String, ServiceInstance> instances = registry.get(serviceId);
        if (instances != null) {
            instances.remove(instanceId);
            log.info("Deregistered service instance: {}:{}", serviceId, instanceId);
        }
    }
    
    @Override
    public List<ServiceInstance> getHealthyInstances(String serviceId) {
        Map<String, ServiceInstance> instances = registry.get(serviceId);
        if (instances == null) {
            return Collections.emptyList();
        }
        
        return instances.values().stream()
                .filter(ServiceInstance::isHealthy)
                .collect(Collectors.toList());
    }
    
    @Override
    public void updateHeartbeat(String serviceId, String instanceId) {
        Map<String, ServiceInstance> instances = registry.get(serviceId);
        if (instances != null) {
            ServiceInstance instance = instances.get(instanceId);
            if (instance != null) {
                instance.setLastHeartbeat(LocalDateTime.now());
                instance.setHealthStatus(HealthStatus.UP);
            }
        }
    }
    
    private void cleanupUnhealthyInstances() {
        registry.values().forEach(instances -> 
            instances.entrySet().removeIf(entry -> !entry.getValue().isHealthy())
        );
    }
}

// Service Registration Component (runs in each microservice)
@Component
public class ServiceRegistrationManager {
    private final ServiceRegistry serviceRegistry;
    private final ServiceInstance currentInstance;
    private final ScheduledExecutorService heartbeatExecutor = Executors.newScheduledThreadPool(1);
    
    @PostConstruct
    public void registerService() {
        // Build instance metadata
        currentInstance = ServiceInstance.builder()
                .serviceId(applicationName)
                .instanceId(UUID.randomUUID().toString())
                .host(InetAddress.getLocalHost().getHostAddress())
                .port(serverPort)
                .metadata(Map.of(
                    "version", applicationVersion,
                    "region", deploymentRegion,
                    "az", availabilityZone
                ))
                .healthStatus(HealthStatus.UP)
                .registeredAt(LocalDateTime.now())
                .lastHeartbeat(LocalDateTime.now())
                .build();
        
        // Register with service registry
        serviceRegistry.register(currentInstance);
        
        // Start heartbeat
        heartbeatExecutor.scheduleAtFixedRate(this::sendHeartbeat, 10, 10, TimeUnit.SECONDS);
        
        log.info("Service registered successfully: {}", currentInstance.getInstanceId());
    }
    
    private void sendHeartbeat() {
        try {
            serviceRegistry.updateHeartbeat(
                currentInstance.getServiceId(), 
                currentInstance.getInstanceId()
            );
        } catch (Exception e) {
            log.error("Failed to send heartbeat", e);
        }
    }
    
    @PreDestroy
    public void deregisterService() {
        serviceRegistry.deregister(
            currentInstance.getServiceId(), 
            currentInstance.getInstanceId()
        );
        heartbeatExecutor.shutdown();
        log.info("Service deregistered: {}", currentInstance.getInstanceId());
    }
}
```

### Service Discovery Client

```html
// Service Discovery Client
@Component
public class ServiceDiscoveryClient {
    private final ServiceRegistry serviceRegistry;
    private final LoadBalancer loadBalancer;
    private final CircuitBreakerRegistry circuitBreakerRegistry;
    
    public <T> T callService(String serviceId, String path, Class<T> responseType) {
        // Get healthy instances
        List<ServiceInstance> healthyInstances = serviceRegistry.getHealthyInstances(serviceId);
        
        if (healthyInstances.isEmpty()) {
            throw new NoAvailableServiceException("No healthy instances for: " + serviceId);
        }
        
        // Load balance across instances
        ServiceInstance selectedInstance = loadBalancer.select(healthyInstances);
        
        // Call with circuit breaker
        CircuitBreaker circuitBreaker = circuitBreakerRegistry.circuitBreaker(serviceId);
        
        return circuitBreaker.executeSupplier(() -> {
            String url = selectedInstance.getServiceUrl() + path;
            
            try {
                return restTemplate.getForObject(url, responseType);
            } catch (Exception e) {
                log.error("Service call failed: {} - {}", serviceId, url, e);
                throw new ServiceCallException("Failed to call " + serviceId, e);
            }
        });
    }
}

// Usage in Business Service
@Service
public class OrderService {
    private final ServiceDiscoveryClient discoveryClient;
    
    public Order createOrder(CreateOrderRequest request) {
        // Call user service (service discovery handles instance selection)
        User user = discoveryClient.callService("user-service", "/users/" + request.getUserId(), User.class);
        
        // Call inventory service
        InventoryResponse inventory = discoveryClient.callService(
            "inventory-service", 
            "/inventory/check", 
            InventoryResponse.class
        );
        
        // Process order...
        return processOrder(user, inventory, request);
    }
}
```

### API Gateway Pattern: Single Entry Point

### What API Gateway Provides

**API Gateway** is the **single entry point** for all client requests, providing:

- **Request routing** to appropriate microservices
- **Authentication & Authorization** (single point of security)
- **Rate limiting & Throttling**
- **Request/Response transformation**
- **Protocol translation** (REST to gRPC, etc.)

### API Gateway with Service Discovery

```html
@RestController
@RequestMapping("/api/v1")
public class ApiGatewayController {
    private final ServiceDiscoveryClient discoveryClient;
    private final AuthenticationService authService;
    private final RateLimitService rateLimitService;
    
    @GetMapping("/users/{userId}")
    public ResponseEntity<?> getUser(@PathVariable String userId, 
                                    HttpServletRequest request) {
        // 1. Authentication
        User currentUser = authService.authenticate(request);
        
        // 2. Authorization
        if (!authService.canAccessUser(currentUser, userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ErrorResponse.of("Access denied"));
        }
        
        // 3. Rate Limiting
        if (!rateLimitService.allowRequest(currentUser.getId())) {
            return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS)
                .body(ErrorResponse.of("Rate limit exceeded"));
        }
        
        // 4. Service Discovery & Routing
        try {
            User user = discoveryClient.callService("user-service", "/users/" + userId, User.class);
            return ResponseEntity.ok(user);
        } catch (NoAvailableServiceException e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(ErrorResponse.of("Service temporarily unavailable"));
        } catch (CircuitBreakerOpenException e) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(ErrorResponse.of("Service circuit breaker open"));
        }
    }
    
    // Aggregation pattern - single API call fetches from multiple services
    @GetMapping("/dashboard/{userId}")
    public ResponseEntity<DashboardResponse> getUserDashboard(@PathVariable String userId) {
        // Parallel calls to multiple services
        CompletableFuture<User> userFuture = CompletableFuture.supplyAsync(() ->
            discoveryClient.callService("user-service", "/users/" + userId, User.class)
        );
        
        CompletableFuture<List<Order>> ordersFuture = CompletableFuture.supplyAsync(() ->
            discoveryClient.callService("order-service", "/orders/user/" + userId, OrderList.class).getOrders()
        );
        
        CompletableFuture<List<Recommendation>> recommendationsFuture = CompletableFuture.supplyAsync(() ->
            discoveryClient.callService("recommendation-service", "/recommendations/" + userId, RecommendationList.class).getRecommendations()
        );
        
        try {
            // Wait for all services (with timeout)
            CompletableFuture.allOf(userFuture, ordersFuture, recommendationsFuture)
                .get(5, TimeUnit.SECONDS);
            
            DashboardResponse dashboard = DashboardResponse.builder()
                .user(userFuture.get())
                .recentOrders(ordersFuture.get())
                .recommendations(recommendationsFuture.get())
                .build();
                
            return ResponseEntity.ok(dashboard);
            
        } catch (TimeoutException e) {
            // Partial response with available data
            return ResponseEntity.ok(buildPartialDashboard(userFuture, ordersFuture, recommendationsFuture));
        }
    }
}
```

### Bulkhead Pattern: Failure Isolation

### The Problem

Without isolation, a **single failing dependency can bring down your entire system**:

- Thread pool exhaustion from slow service
- Memory leaks spreading across services
- Cascade failures affecting unrelated features

### What Bulkhead Pattern Solves

**Bulkhead pattern** isolates resources (threads, connections, memory) so **failure in one area doesn’t affect others**. Named after ship bulkheads that prevent water from flooding entire ship.

### Bulkhead Implementation

```html
// Bulkhead Configuration
@Configuration
public class BulkheadConfig {
    
    @Bean
    public ThreadPoolBulkhead userServiceBulkhead() {
        ThreadPoolBulkheadConfig config = ThreadPoolBulkheadConfig.custom()
            .maxThreadPoolSize(10)
            .coreThreadPoolSize(5)
            .queueCapacity(100)
            .keepAliveDuration(Duration.ofMillis(1000))
            .build();
            
        return ThreadPoolBulkhead.of("user-service", config);
    }
    
    @Bean
    public ThreadPoolBulkhead orderServiceBulkhead() {
        ThreadPoolBulkheadConfig config = ThreadPoolBulkheadConfig.custom()
            .maxThreadPoolSize(20)  // More threads for critical service
            .coreThreadPoolSize(10)
            .queueCapacity(200)
            .build();
            
        return ThreadPoolBulkhead.of("order-service", config);
    }
    
    @Bean
    public ThreadPoolBulkhead recommendationServiceBulkhead() {
        ThreadPoolBulkheadConfig config = ThreadPoolBulkheadConfig.custom()
            .maxThreadPoolSize(5)   // Fewer threads for non-critical service
            .coreThreadPoolSize(2)
            .queueCapacity(50)
            .build();
            
        return ThreadPoolBulkhead.of("recommendation-service", config);
    }
}

// Bulkhead-Isolated Service Client
@Component
public class ResilientServiceClient {
    private final Map<String, ThreadPoolBulkhead> bulkheads;
    private final Map<String, CircuitBreaker> circuitBreakers;
    
    public <T> CompletableFuture<T> callServiceAsync(String serviceId, Supplier<T> serviceCall) {
        ThreadPoolBulkhead bulkhead = bulkheads.get(serviceId);
        CircuitBreaker circuitBreaker = circuitBreakers.get(serviceId);
        
        // Wrap call in bulkhead and circuit breaker
        Supplier<CompletionStage<T>> decoratedSupplier = 
            Decorators.ofSupplier(() -> CompletableFuture.supplyAsync(serviceCall))
                .withThreadPoolBulkhead(bulkhead)
                .withCircuitBreaker(circuitBreaker)
                .withFallback(Arrays.asList(
                    BulkheadFullException.class,
                    CircuitBreakerOpenException.class
                ), throwable -> {
                    log.warn("Service call failed: {} - Using fallback", serviceId);
                    return CompletableFuture.completedFuture(getFallbackResponse(serviceId));
                })
                .decorate();
        
        try {
            return decoratedSupplier.get().toCompletableFuture();
        } catch (BulkheadFullException e) {
            log.error("Bulkhead full for service: {}", serviceId);
            throw new ServiceOverloadedException("Service temporarily overloaded: " + serviceId);
        }
    }
}
// Usage with Isolation
@Service
public class DashboardService {
    private final ResilientServiceClient serviceClient;
    
    public DashboardData getDashboard(String userId) {
        // Each service call uses its own isolated thread pool
        CompletableFuture<User> userFuture = serviceClient.callServiceAsync(
            "user-service",
            () -> userServiceClient.getUser(userId)
        );
        
        CompletableFuture<List<Order>> ordersFuture = serviceClient.callServiceAsync(
            "order-service",
            () -> orderServiceClient.getOrders(userId)
        );
        
        CompletableFuture<List<Product>> recommendationsFuture = serviceClient.callServiceAsync(
            "recommendation-service",
            () -> recommendationServiceClient.getRecommendations(userId)
        );
        
        // If recommendation service is slow/failing, it won't block user/order calls
        try {
            return DashboardData.builder()
                .user(userFuture.get(2, TimeUnit.SECONDS))
                .orders(ordersFuture.get(2, TimeUnit.SECONDS))
                .recommendations(recommendationsFuture.get(1, TimeUnit.SECONDS)) // Shorter timeout for non-critical
                .build();
        } catch (TimeoutException e) {
            // Graceful degradation - return partial data
            return buildPartialDashboard(userFuture, ordersFuture);
        }
    }
}
```

### Netflix’s Microservice Patterns

### Netflix OSS Stack

Netflix pioneered many microservice patterns and open-sourced their tools:

**1\. Eureka (Service Discovery)**

- Self-registration and discovery
- Peer-to-peer replication
- Client-side load balancing

**2\. Zuul (API Gateway)**

- Dynamic routing
- Request filtering
- Authentication/Authorization

**3\. Hystrix (Circuit Breaker & Bulkhead)**

- Fault tolerance
- Fallback mechanisms
- Real-time monitoring

**4\. Ribbon (Load Balancing)**

- Client-side load balancing
- Multiple strategies (round-robin, weighted, zone-aware)

### Netflix Architecture Pattern

```html
[Client] → [Zuul Gateway] → [Eureka Discovery] → [Hystrix Protection] → [Microservice]
              ↓                    ↓                      ↓
        [Auth/Rate Limit]    [Service Registry]    [Circuit Breaker]
              ↓                    ↓                      ↓
        [Request Filter]      [Health Checks]       [Bulkhead Isolation]
```

### Real Netflix-Style Implementation

```html
// Netflix-Style Service Configuration
@Configuration
@EnableEurekaClient
@EnableCircuitBreaker
public class NetflixStyleConfig {
    
    @Bean
    @LoadBalanced  // Ribbon load balancing
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
    
    @Bean
    public HystrixCommandProperties.Setter hystrixProperties() {
        return HystrixCommandProperties.Setter()
            .withExecutionTimeoutInMilliseconds(3000)
            .withCircuitBreakerRequestVolumeThreshold(20)
            .withCircuitBreakerErrorThresholdPercentage(50)
            .withCircuitBreakerSleepWindowInMilliseconds(5000);
    }
}

// Hystrix Command with Fallback
@HystrixCommand(
    fallbackMethod = "getUserFallback",
    commandProperties = {
        @HystrixProperty(name = "execution.isolation.thread.timeoutInMilliseconds", value = "3000"),
        @HystrixProperty(name = "circuitBreaker.requestVolumeThreshold", value = "20")
    },
    threadPoolProperties = {
        @HystrixProperty(name = "coreSize", value = "10"),
        @HystrixProperty(name = "maxQueueSize", value = "50")
    }
)
public User getUser(String userId) {
    return restTemplate.getForObject("http://user-service/users/" + userId, User.class);
}
public User getUserFallback(String userId, Throwable throwable) {
    log.warn("User service fallback triggered for: {}", userId, throwable);
    
    // Return cached data or default user
    return cacheService.getCachedUser(userId)
        .orElse(User.anonymous());
}
```

### Complete Microservices Architecture

```html
[Mobile/Web Clients]
        ↓
[CDN & Load Balancer]
        ↓
[API Gateway (Zuul)] ←─────────────┐
        ↓                          │
[Service Registry (Eureka)] ←──────┼─ Service Registration
        ↓                          │
[Service Mesh Layer]               │
        ├─ [User Service] ─────────┘
        ├─ [Order Service] ────────┐
        ├─ [Payment Service] ──────┼─ Service Discovery
        ├─ [Inventory Service] ────┤
        └─ [Notification Service] ─┘
                ↓
        [Message Queue]
                ↓
        [Databases (per service)]
```

### Production Best Practices

### Health Checks

```html
@RestController
public class HealthCheckController {
    private final ServiceRegistry serviceRegistry;
    private final DataSource dataSource;
    
    @GetMapping("/health")
    public ResponseEntity<HealthStatus> health() {
        HealthStatus status = HealthStatus.builder()
            .status("UP")
            .checks(Map.of(
                "database", checkDatabase(),
                "diskSpace", checkDiskSpace(),
                "serviceRegistry", checkServiceRegistry()
            ))
            .build();
            
        return ResponseEntity.ok(status);
    }
    
    private String checkDatabase() {
        try {
            dataSource.getConnection().close();
            return "UP";
        } catch (Exception e) {
            return "DOWN";
        }
    }
}
```

### Graceful Shutdown

```html
@Component
public class GracefulShutdownManager {
    private final ServiceRegistrationManager registrationManager;
    
    @PreDestroy
    public void shutdown() {
        log.info("Initiating graceful shutdown");
        
        // 1. Deregister from service registry
        registrationManager.deregisterService();
        
        // 2. Wait for in-flight requests to complete
        Thread.sleep(10000);
        
        // 3. Close resources
        closeConnections();
        
        log.info("Graceful shutdown complete");
    }
}
```

### Decision Framework

**Use Service Discovery when:**

- Dynamic service instances (auto-scaling)
- Multiple service versions deployed
- Services deployed across regions/zones
- Need client-side load balancing

**Use API Gateway when:**

- Multiple client types (mobile, web, IoT)
- Cross-cutting concerns (auth, rate limiting)
- Need request aggregation
- Protocol translation required

**Use Bulkhead Pattern when:**

- Services have different SLAs
- Failure isolation is critical
- Shared resources need protection
- Non-critical services shouldn’t affect critical ones

### Tomorrow’s Preview

Day 16: “Database Scaling Patterns”. Sharding patterns and strategies, Read replica patterns, and Database per service pattern for microservices data management.

### Your Architect Assignment

1. **Map your service dependencies** Who calls whom?
2. **Identify single points of failure** What happens when each service fails?
3. **Check resource isolation** Are thread pools shared or isolated?
4. **Review service discovery** How do services find each other?

Remember: **Microservices are about independence deployment, failure, and scaling. Service Discovery makes them dynamic, API Gateway makes them accessible, Bulkhead makes them resilient. Netflix proved these patterns work at global scale.**

*Previous articles:*

- [*Day 1 Building Your Architect Mindset*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [*Day 2 Strategy & Observer Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [*Day 3 Decorator & Proxy Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [*Day 4 Singleton & Builder Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [*Day 5 Command & Template Method Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [*Day 6 Adapter & Facade Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [*Day 7 Chain of Responsibility & State Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [*Day 8 Load Balancing & Circuit Breaker Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)
- [*Day 9 Database Patterns & Repository Pattern*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)
- [*Day 10 Caching Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)
- [*Day 11 API Gateway & Proxy Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)
- [*Day 12 Message Queue Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)
- [*Day 13 Event Sourcing & CQRS Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)
- [*Day 14 Monitoring & Observer Patterns*](https://archive.is/o/ijoWZ/https://medium.com/@kanishks772/learn-system-design-with-me-day-14-monitoring-observer-patterns-cdd2bba68d9f)

> *Follow along daily as we master microservices patterns that power Netflix, Uber, and Amazon at global scale.*

[0%](https://archive.is/ijoWZ#0%) [10%](https://archive.is/ijoWZ#10%) [20%](https://archive.is/ijoWZ#20%) [30%](https://archive.is/ijoWZ#30%) [40%](https://archive.is/ijoWZ#40%) [50%](https://archive.is/ijoWZ#50%) [60%](https://archive.is/ijoWZ#60%) [70%](https://archive.is/ijoWZ#70%) [80%](https://archive.is/ijoWZ#80%) [90%](https://archive.is/ijoWZ#90%) [100%](https://archive.is/ijoWZ#100%)