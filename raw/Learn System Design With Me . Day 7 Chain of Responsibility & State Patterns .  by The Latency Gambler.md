---
title: "Learn System Design With Me . Day 7: Chain of Responsibility & State Patterns . | by The Latency Gambler"
source: "https://freedium-mirror.cfd/medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18"
author:
  - "[[The Latency Gambler]]"
published:
created: 2026-05-26
description: "Request Pipelines & State Machines"
tags:
  - "clippings"
---
[< Go to the original](https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/0*S__Hzyk6bdwJ3FAc)

## Learn System Design With Me. Day 7: Chain of Responsibility & State Patterns.

## Request Pipelines & State Machines

a11y-light · September 19, 2025 (Updated: September 19, 2025) · Free: No

*This is Day 7 of our 30-day journey from code writer to system architect. Start with* *[Day 1](https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)* *to build the foundation, then progress through* *[Day 2](https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)**,* *[Day 3](https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)**,* *[Day 4](https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)**,* *[Day 5](https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)**, and* *[Day 6](https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*

We've covered structural patterns that integrate and simplify. Today, we master two behavioral patterns that handle **dynamic processing and state management**: Chain of Responsibility and State patterns.

![None](https://miro.medium.com/v2/resize:fit:700/0*S__Hzyk6bdwJ3FAc)

Ai Generated Image

Here's the architect's insight: **Chain of Responsibility creates flexible request processing pipelines where handlers can be added, removed, or reordered without changing client code. State Pattern eliminates complex if-else chains by making state transitions explicit and manageable.**

> Think middleware chains in web frameworks and order state machines in e-commerce. These patterns power the most flexible systems.

#### Chain of Responsibility Pattern: Request Processing Pipelines

#### The Problem It Solves

You have a request that could be handled by multiple objects, but you don't know which one until runtime. Traditional approach: Complex if-else chains. **Architect approach**: Chain of handlers where each decides whether to process or pass along.

#### Basic Chain Implementation

```java
// Handler Interface - Your Processing Contract
public abstract class RequestHandler {
    protected RequestHandler nextHandler;
    
    public void setNext(RequestHandler nextHandler) {
        this.nextHandler = nextHandler;
    }
    
    public abstract void handleRequest(Request request);
    
    protected void passToNext(Request request) {
        if (nextHandler != null) {
            nextHandler.handleRequest(request);
        } else {
            throw new UnhandledRequestException("No handler found for: " + request);
        }
    }
}

// Request Types
public class Request {
    private final RequestType type;
    private final String content;
    private final User user;
    private final Map<String, Object> metadata;
    
    // Constructor, getters, builder pattern...
}

// Concrete Handlers
public class AuthenticationHandler extends RequestHandler {
    private final AuthenticationService authService;
    
    @Override
    public void handleRequest(Request request) {
        if (request.requiresAuthentication()) {
            log.info("Authenticating request from user: {}", request.getUser().getId());
            
            if (!authService.isAuthenticated(request.getUser())) {
                throw new AuthenticationException("User not authenticated");
            }
            
            log.info("Authentication successful for user: {}", request.getUser().getId());
        }
        
        // Pass to next handler regardless of whether we processed
        passToNext(request);
    }
}

public class AuthorizationHandler extends RequestHandler {
    private final AuthorizationService authzService;
    
    @Override
    public void handleRequest(Request request) {
        if (request.requiresAuthorization()) {
            log.info("Authorizing request: {} for user: {}", 
                     request.getType(), request.getUser().getId());
                     
            if (!authzService.hasPermission(request.getUser(), request.getRequiredPermission())) {
                throw new AuthorizationException("Insufficient permissions");
            }
            
            log.info("Authorization successful");
        }
        
        passToNext(request);
    }
}

public class ValidationHandler extends RequestHandler {
    private final RequestValidator validator;
    
    @Override
    public void handleRequest(Request request) {
        log.info("Validating request: {}", request.getType());
        
        ValidationResult result = validator.validate(request);
        if (!result.isValid()) {
            throw new ValidationException("Request validation failed: " + result.getErrors());
        }
        
        log.info("Request validation successful");
        passToNext(request);
    }
}

public class BusinessLogicHandler extends RequestHandler {
    private final BusinessService businessService;
    
    @Override
    public void handleRequest(Request request) {
        log.info("Processing business logic for request: {}", request.getType());
        
        // This is typically the final handler
        Response response = businessService.process(request);
        
        // Store response in request context for retrieval
        request.setResponse(response);
        
        // Could pass to next for post-processing (logging, metrics, etc.)
        if (nextHandler != null) {
            passToNext(request);
        }
    }
}

// Chain Builder
public class RequestProcessorChain {
    private RequestHandler firstHandler;
    
    public static RequestProcessorChain create() {
        return new RequestProcessorChain();
    }
    
    public RequestProcessorChain addHandler(RequestHandler handler) {
        if (firstHandler == null) {
            firstHandler = handler;
        } else {
            RequestHandler current = firstHandler;
            while (current.nextHandler != null) {
                current = current.nextHandler;
            }
            current.setNext(handler);
        }
        return this;
    }
    
    public void processRequest(Request request) {
        if (firstHandler == null) {
            throw new IllegalStateException("No handlers configured");
        }
        firstHandler.handleRequest(request);
    }
}
```

#### System Architecture: Middleware Pipeline

```
[Client Request] → [Auth Handler] → [Authz Handler] → [Validation Handler] → [Business Handler] → [Logging Handler]
                        ↓               ↓                   ↓                    ↓                ↓
                   [Pass/Fail]    [Pass/Fail]        [Pass/Fail]          [Process]        [Log & Metrics]
```

#### Advanced Chain: Conditional and Branching Chains

```java
// Smart Handler with Conditional Processing
public abstract class ConditionalHandler extends RequestHandler {
    
    @Override
    public final void handleRequest(Request request) {
        if (shouldHandle(request)) {
            log.debug("Handler {} processing request {}", 
                      this.getClass().getSimpleName(), request.getId());
            doHandle(request);
        } else {
            log.debug("Handler {} skipping request {}", 
                      this.getClass().getSimpleName(), request.getId());
        }
        
        passToNext(request);
    }
    
    protected abstract boolean shouldHandle(Request request);
    protected abstract void doHandle(Request request);
}

// Rate Limiting Handler
public class RateLimitingHandler extends ConditionalHandler {
    private final RateLimiter rateLimiter;
    
    @Override
    protected boolean shouldHandle(Request request) {
        return request.getUser() != null && !request.getUser().isVip();
    }
    
    @Override
    protected void doHandle(Request request) {
        String userId = request.getUser().getId();
        if (!rateLimiter.tryAcquire(userId)) {
            throw new RateLimitException("Rate limit exceeded for user: " + userId);
        }
    }
}

// Caching Handler
public class CacheHandler extends ConditionalHandler {
    private final Cache<String, Response> responseCache;
    
    @Override
    protected boolean shouldHandle(Request request) {
        return request.isCacheable();
    }
    
    @Override
    protected void doHandle(Request request) {
        String cacheKey = generateCacheKey(request);
        Response cachedResponse = responseCache.getIfPresent(cacheKey);
        
        if (cachedResponse != null) {
            log.info("Cache hit for request: {}", request.getId());
            request.setResponse(cachedResponse);
            request.setCacheHit(true);
            // Don't pass to next - request is complete
            return;
        }
        
        // Continue processing and cache the result
        processAndCache(request, cacheKey);
    }
    
    private void processAndCache(Request request, String cacheKey) {
        // Create a callback chain to cache after processing
        RequestHandler originalNext = this.nextHandler;
        this.nextHandler = new CacheResultHandler(originalNext, responseCache, cacheKey);
    }
}
```

#### Chain with Spring Integration

```java
// Spring-managed Chain
@Configuration
public class RequestProcessingConfig {
    
    @Bean
    @Order(1)
    public RequestHandler authenticationHandler(AuthenticationService authService) {
        return new AuthenticationHandler(authService);
    }
    
    @Bean
    @Order(2)
    public RequestHandler authorizationHandler(AuthorizationService authzService) {
        return new AuthorizationHandler(authzService);
    }
    
    @Bean
    @Order(3)
    public RequestHandler rateLimitingHandler(RateLimiter rateLimiter) {
        return new RateLimitingHandler(rateLimiter);
    }
    
    @Bean
    @Order(4)
    public RequestHandler validationHandler(RequestValidator validator) {
        return new ValidationHandler(validator);
    }
    
    @Bean
    @Order(5)
    public RequestHandler businessLogicHandler(BusinessService businessService) {
        return new BusinessLogicHandler(businessService);
    }
    
    @Bean
    public RequestProcessorChain requestProcessorChain(List<RequestHandler> handlers) {
        RequestProcessorChain chain = RequestProcessorChain.create();
        handlers.stream()
            .sorted(Comparator.comparing(h -> 
                h.getClass().getAnnotation(Order.class).value()))
            .forEach(chain::addHandler);
        return chain;
    }
}
```

#### State Pattern: Elegant State Machines

#### The Problem It Solves

Objects change behavior based on internal state, leading to complex if-else or switch statements. **State Pattern encapsulates states as objects, making transitions explicit and extensible.**

#### Basic State Implementation

```typescript
// Context - The object whose behavior changes
public class Order {
    private OrderState currentState;
    private String orderId;
    private BigDecimal amount;
    private List<OrderItem> items;
    private String customerId;
    private LocalDateTime createdAt;
    
    public Order(String orderId, String customerId, List<OrderItem> items) {
        this.orderId = orderId;
        this.customerId = customerId;
        this.items = new ArrayList<>(items);
        this.amount = calculateTotal(items);
        this.createdAt = LocalDateTime.now();
        this.currentState = new PendingState(); // Initial state
    }
    
    // State transition methods
    public void payOrder(PaymentDetails paymentDetails) {
        currentState.payOrder(this, paymentDetails);
    }
    
    public void shipOrder(ShippingDetails shippingDetails) {
        currentState.shipOrder(this, shippingDetails);
    }
    
    public void deliverOrder() {
        currentState.deliverOrder(this);
    }
    
    public void cancelOrder(String reason) {
        currentState.cancelOrder(this, reason);
    }
    
    public void returnOrder(String reason) {
        currentState.returnOrder(this, reason);
    }
    
    // State management
    public void changeState(OrderState newState) {
        log.info("Order {} transitioning from {} to {}", 
                 orderId, currentState.getStateName(), newState.getStateName());
        this.currentState = newState;
    }
    
    public String getStatus() {
        return currentState.getStateName();
    }
    
    public boolean canBeCancelled() {
        return currentState.canCancel();
    }
    
    // Getters and other methods...
}

// State Interface
public interface OrderState {
    void payOrder(Order order, PaymentDetails paymentDetails);
    void shipOrder(Order order, ShippingDetails shippingDetails);
    void deliverOrder(Order order);
    void cancelOrder(Order order, String reason);
    void returnOrder(Order order, String reason);
    
    String getStateName();
    boolean canCancel();
    
    default void throwInvalidTransition(String action, String currentState) {
        throw new InvalidStateTransitionException(
            String.format("Cannot %s order in %s state", action, currentState));
    }
}
// Concrete States
public class PendingState implements OrderState {
    
    @Override
    public void payOrder(Order order, PaymentDetails paymentDetails) {
        log.info("Processing payment for order: {}", order.getOrderId());
        
        // Validate payment
        PaymentResult result = paymentService.processPayment(paymentDetails);
        if (result.isSuccess()) {
            order.setPaymentTransactionId(result.getTransactionId());
            order.changeState(new PaidState());
            
            // Trigger events
            eventPublisher.publish(new OrderPaidEvent(order));
        } else {
            throw new PaymentFailedException("Payment failed: " + result.getError());
        }
    }
    
    @Override
    public void cancelOrder(Order order, String reason) {
        log.info("Cancelling pending order: {} - Reason: {}", order.getOrderId(), reason);
        
        order.setCancellationReason(reason);
        order.changeState(new CancelledState());
        
        eventPublisher.publish(new OrderCancelledEvent(order));
    }
    
    @Override
    public void shipOrder(Order order, ShippingDetails shippingDetails) {
        throwInvalidTransition("ship", getStateName());
    }
    
    @Override
    public void deliverOrder(Order order) {
        throwInvalidTransition("deliver", getStateName());
    }
    
    @Override
    public void returnOrder(Order order, String reason) {
        throwInvalidTransition("return", getStateName());
    }
    
    @Override
    public String getStateName() {
        return "PENDING";
    }
    
    @Override
    public boolean canCancel() {
        return true;
    }
}
public class PaidState implements OrderState {
    
    @Override
    public void shipOrder(Order order, ShippingDetails shippingDetails) {
        log.info("Shipping order: {}", order.getOrderId());
        
        // Reserve inventory
        inventoryService.reserveItems(order.getItems());
        
        // Create shipping label
        ShippingLabel label = shippingService.createLabel(shippingDetails);
        order.setShippingLabelId(label.getId());
        order.setShippedAt(LocalDateTime.now());
        
        order.changeState(new ShippedState());
        
        eventPublisher.publish(new OrderShippedEvent(order));
    }
    
    @Override
    public void cancelOrder(Order order, String reason) {
        log.info("Cancelling paid order: {} - Processing refund", order.getOrderId());
        
        // Process refund
        RefundResult refund = paymentService.refund(
            order.getPaymentTransactionId(), order.getAmount());
            
        if (refund.isSuccess()) {
            order.setCancellationReason(reason);
            order.setRefundTransactionId(refund.getTransactionId());
            order.changeState(new CancelledState());
            
            eventPublisher.publish(new OrderCancelledEvent(order));
        } else {
            throw new RefundFailedException("Refund failed: " + refund.getError());
        }
    }
    
    @Override
    public void payOrder(Order order, PaymentDetails paymentDetails) {
        throwInvalidTransition("pay", getStateName());
    }
    
    @Override
    public void deliverOrder(Order order) {
        throwInvalidTransition("deliver", getStateName());
    }
    
    @Override
    public void returnOrder(Order order, String reason) {
        throwInvalidTransition("return", getStateName());
    }
    
    @Override
    public String getStateName() {
        return "PAID";
    }
    
    @Override
    public boolean canCancel() {
        return true;
    }
}
public class ShippedState implements OrderState {
    
    @Override
    public void deliverOrder(Order order) {
        log.info("Delivering order: {}", order.getOrderId());
        
        order.setDeliveredAt(LocalDateTime.now());
        order.changeState(new DeliveredState());
        
        eventPublisher.publish(new OrderDeliveredEvent(order));
    }
    
    @Override
    public void cancelOrder(Order order, String reason) {
        // More complex cancellation - need to recall shipment
        log.info("Cancelling shipped order: {} - Recalling shipment", order.getOrderId());
        
        boolean recalled = shippingService.recallShipment(order.getShippingLabelId());
        if (recalled) {
            RefundResult refund = paymentService.refund(
                order.getPaymentTransactionId(), order.getAmount());
                
            if (refund.isSuccess()) {
                inventoryService.releaseReservation(order.getInventoryReservationId());
                order.setCancellationReason(reason);
                order.changeState(new CancelledState());
            }
        } else {
            throw new CancellationFailedException("Cannot recall shipped order");
        }
    }
    
    @Override
    public void payOrder(Order order, PaymentDetails paymentDetails) {
        throwInvalidTransition("pay", getStateName());
    }
    
    @Override
    public void shipOrder(Order order, ShippingDetails shippingDetails) {
        throwInvalidTransition("ship", getStateName());
    }
    
    @Override
    public void returnOrder(Order order, String reason) {
        throwInvalidTransition("return", getStateName());
    }
    
    @Override
    public String getStateName() {
        return "SHIPPED";
    }
    
    @Override
    public boolean canCancel() {
        return true; // But more complex
    }
}
public class DeliveredState implements OrderState {
    
    @Override
    public void returnOrder(Order order, String reason) {
        log.info("Processing return for delivered order: {}", order.getOrderId());
        
        // Check return window
        if (isWithinReturnWindow(order.getDeliveredAt())) {
            order.setReturnReason(reason);
            order.setReturnInitiatedAt(LocalDateTime.now());
            order.changeState(new ReturnedState());
            
            eventPublisher.publish(new OrderReturnedEvent(order));
        } else {
            throw new ReturnWindowExpiredException("Return window has expired");
        }
    }
    
    private boolean isWithinReturnWindow(LocalDateTime deliveredAt) {
        return deliveredAt.isAfter(LocalDateTime.now().minusDays(30));
    }
    
    @Override
    public void payOrder(Order order, PaymentDetails paymentDetails) {
        throwInvalidTransition("pay", getStateName());
    }
    
    @Override
    public void shipOrder(Order order, ShippingDetails shippingDetails) {
        throwInvalidTransition("ship", getStateName());
    }
    
    @Override
    public void deliverOrder(Order order) {
        throwInvalidTransition("deliver", getStateName());
    }
    
    @Override
    public void cancelOrder(Order order, String reason) {
        throwInvalidTransition("cancel", getStateName());
    }
    
    @Override
    public String getStateName() {
        return "DELIVERED";
    }
    
    @Override
    public boolean canCancel() {
        return false;
    }
}
```

#### State Machine Diagram

```
[PENDING] ──pay──> [PAID] ──ship──> [SHIPPED] ──deliver──> [DELIVERED]
    │                 │                 │                      │
    │                 │                 │                      │
  cancel           cancel            cancel                  return
    │                 │                 │                      │
    │                 │                 │                      │
    └─────────────────┴─────────────────┴──> [CANCELLED]       │
                                                               │
                                                               ▼
                                                         [RETURNED]
```

#### Advanced State: State Factory and Persistence

```java
// State Factory for creation and restoration
@Component
public class OrderStateFactory {
    
    private final PaymentService paymentService;
    private final ShippingService shippingService;
    private final InventoryService inventoryService;
    
    public OrderState createState(String stateName) {
        return switch (stateName.toUpperCase()) {
            case "PENDING" -> new PendingState();
            case "PAID" -> new PaidState();
            case "SHIPPED" -> new ShippedState();
            case "DELIVERED" -> new DeliveredState();
            case "CANCELLED" -> new CancelledState();
            case "RETURNED" -> new ReturnedState();
            default -> throw new IllegalArgumentException("Unknown state: " + stateName);
        };
    }
    
    // For complex states that need initialization
    public OrderState createInitializedState(String stateName, Order order) {
        OrderState state = createState(stateName);
        
        if (state instanceof StatefulOrderState) {
            ((StatefulOrderState) state).initialize(order);
        }
        
        return state;
    }
}

// State with History Tracking
public class OrderWithHistory extends Order {
    private final List<StateTransition> stateHistory = new ArrayList<>();
    
    @Override
    public void changeState(OrderState newState) {
        String oldState = currentState != null ? currentState.getStateName() : "INITIAL";
        String newStateName = newState.getStateName();
        
        StateTransition transition = StateTransition.builder()
            .fromState(oldState)
            .toState(newStateName)
            .timestamp(LocalDateTime.now())
            .user(getCurrentUser()) // From security context
            .build();
            
        stateHistory.add(transition);
        
        super.changeState(newState);
        
        // Persist state change
        stateAuditService.recordTransition(this.getOrderId(), transition);
    }
    
    public List<StateTransition> getStateHistory() {
        return Collections.unmodifiableList(stateHistory);
    }
}
```

#### Anti-Patterns: What Goes Wrong

#### Chain of Responsibility Anti-Patterns

#### 1\. Broken Chain

```java
// DON'T DO THIS - Forgetting to call next handler
public class BadHandler extends RequestHandler {
    @Override
    public void handleRequest(Request request) {
        doSomeProcessing(request);
        // Forgot to call passToNext(request) - chain breaks!
    }
}
```

#### 2\. Handler Order Dependency

```java
// DON'T DO THIS - Handlers that depend on specific order
public class OrderDependentHandler extends RequestHandler {
    @Override
    public void handleRequest(Request request) {
        // Assumes previous handler set specific data
        Object data = request.getMetadata("previous_handler_data");
        if (data == null) {
            throw new IllegalStateException("Previous handler didn't run!");
        }
    }
}
```

#### State Pattern Anti-Patterns

#### 1\. State Explosion

```java
// DON'T DO THIS - Too many specific states
public class VerySpecificState implements OrderState {
    // PaidOnTuesdayDuringRainWithCouponState
    // This is over-engineering!
}
```

#### 2\. Leaky State Logic

```
// DON'T DO THIS - Business logic in wrong places
public class LeakyState implements OrderState {
    @Override
    public void payOrder(Order order, PaymentDetails payment) {
        // State should not handle complex business logic
        calculateTax(order);
        applyDiscounts(order);
        updateInventory(order);
        sendEmails(order);
        // This belongs in services, not states!
    }
}
```

#### Production Lessons: What I Learned

#### Chain of Responsibility Lessons

1. **Always call next handler**: Unless you're explicitly terminating the chain
2. **Keep handlers independent**: No assumptions about previous handlers
3. **Use for cross-cutting concerns**: Authentication, logging, validation
4. **Consider performance**: Long chains can be slow

#### State Pattern Lessons

1. **Keep states simple**: They should coordinate, not contain business logic
2. **Use events for side effects**: State transitions trigger events, events trigger actions
3. **Plan for state persistence**: States need to be serializable and restorable
4. **Document valid transitions**: Make state machine behavior explicit

#### Tomorrow's Preview

Day 8: "Load Balancing & Circuit Breaker Patterns". How to distribute load effectively and build resilient systems that gracefully handle failures.

#### Your Architect Assignment

Examine your current system:

1. **Find complex if-else chains** that could become Chain of Responsibility
2. **Identify objects with state-dependent behavior** that need State Pattern
3. **Look for request processing pipelines** that could benefit from handler chains
4. **Spot state management code** that could be cleaner with State Pattern

Remember: **Chain of Responsibility creates flexible request processing. State Pattern makes complex state machines manageable. Both eliminate conditional complexity.**

*Previous articles:*

- *[Day 1 Building Your Architect Mindset](https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)*
- *[Day 2 Strategy & Observer Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*
- *[Day 3 Decorator & Proxy Patterns](https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*
- *[Day 4 Singleton & Builder Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*
- *[Day 5 Command & Template Method Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*
- *[Day 6 Adapter & Facade Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*

> *Follow along daily as we master the behavioral patterns that create intelligent, flexible systems.*

[< Go to the original](https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18#bypass)