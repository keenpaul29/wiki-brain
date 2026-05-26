---
title: "Learn System Design With Me . | by The Latency Gambler"
source: "https://freedium-mirror.cfd/medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48"
author:
published:
created: 2026-05-26
description: "This is Day 6 of our 30-day journey from code writer to system architect. Start with Day 1 to..."
tags:
  - "clippings"
---
[< Go to the original](https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/0*n2_MzKiKo4PWx4KC)

## Learn System Design With Me.

## This is Day 6 of our 30-day journey from code writer to system architect. Start with Day 1 to build the foundation, then progress through…

a11y-light · September 18, 2025 (Updated: September 18, 2025) · Free: No

### Learn System Design With Me. Day 6: Adapter & Facade Patterns Integration Heroes & Complexity Tamers

*This is Day 6 of our 30-day journey from code writer to system architect. Start with* *[Day 1](https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)* *to build the foundation, then progress through* *[Day 2](https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)**,* *[Day 3](https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)**,* *[Day 4](https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)**, and* *[Day 5](https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*

We've mastered behavioral and creational patterns. Today, we complete the structural patterns trinity with **Adapter and Facade**, the **integration heroes** of system architecture.

Here's the architect's perspective: **Adapter makes incompatible systems work together. Facade hides complexity behind simple interfaces.** These patterns solve the two biggest challenges in enterprise systems: legacy integration and complexity management.

![None](https://miro.medium.com/v2/resize:fit:700/0*n2_MzKiKo4PWx4KC)

Think payment gateways (adapters for different providers) and microservice facades (hiding distributed complexity). Let's master them.

#### Adapter Pattern: Making Incompatible Systems Compatible

#### The Problem It Solves

You have existing code that expects one interface, but you need to use a class with a different interface. **Don't change either side create an adapter.**

Classic example: Your system expects `PaymentProcessor`, but you need to integrate Stripe's SDK with completely different method names.

#### Basic Adapter Implementation

```java
// Target Interface - What your system expects
public interface PaymentProcessor {
    PaymentResult processPayment(PaymentRequest request);
    boolean refundPayment(String transactionId, BigDecimal amount);
    PaymentStatus getPaymentStatus(String transactionId);
}

// Adaptee - The existing class you want to integrate (Stripe SDK)
public class StripePaymentService {
    public StripeCharge createCharge(String token, int amountInCents, String currency) {
        // Stripe's API call
        return StripeAPI.createCharge(token, amountInCents, currency);
    }
    
    public StripeRefund createRefund(String chargeId, int amountInCents) {
        return StripeAPI.createRefund(chargeId, amountInCents);
    }
    
    public StripeCharge retrieveCharge(String chargeId) {
        return StripeAPI.retrieveCharge(chargeId);
    }
}
// Object Adapter - Composition-based
public class StripePaymentAdapter implements PaymentProcessor {
    private final StripePaymentService stripeService;
    
    public StripePaymentAdapter(StripePaymentService stripeService) {
        this.stripeService = stripeService;
    }
    
    @Override
    public PaymentResult processPayment(PaymentRequest request) {
        try {
            // Adapt the interface
            String token = request.getPaymentToken();
            int amountInCents = request.getAmount().multiply(BigDecimal.valueOf(100)).intValue();
            String currency = request.getCurrency().name().toLowerCase();
            
            StripeCharge charge = stripeService.createCharge(token, amountInCents, currency);
            
            return PaymentResult.builder()
                .transactionId(charge.getId())
                .status(mapStripeStatus(charge.getStatus()))
                .amount(BigDecimal.valueOf(charge.getAmount()).divide(BigDecimal.valueOf(100)))
                .currency(Currency.valueOf(charge.getCurrency().toUpperCase()))
                .timestamp(Instant.ofEpochSecond(charge.getCreated()))
                .build();
                
        } catch (StripeException e) {
            return PaymentResult.failed(request.getAmount(), e.getMessage());
        }
    }
    
    @Override
    public boolean refundPayment(String transactionId, BigDecimal amount) {
        try {
            int amountInCents = amount.multiply(BigDecimal.valueOf(100)).intValue();
            StripeRefund refund = stripeService.createRefund(transactionId, amountInCents);
            return "succeeded".equals(refund.getStatus());
        } catch (StripeException e) {
            log.error("Refund failed for transaction: {}", transactionId, e);
            return false;
        }
    }
    
    @Override
    public PaymentStatus getPaymentStatus(String transactionId) {
        try {
            StripeCharge charge = stripeService.retrieveCharge(transactionId);
            return mapStripeStatus(charge.getStatus());
        } catch (StripeException e) {
            return PaymentStatus.UNKNOWN;
        }
    }
    
    private PaymentStatus mapStripeStatus(String stripeStatus) {
        return switch (stripeStatus) {
            case "succeeded" -> PaymentStatus.SUCCESS;
            case "pending" -> PaymentStatus.PENDING;
            case "failed" -> PaymentStatus.FAILED;
            default -> PaymentStatus.UNKNOWN;
        };
    }
}
```

#### System Architecture: Payment Gateway Adapters

```
[Payment Service] ──┐
                    ├── [Stripe Adapter] ──> [Stripe SDK]
                    ├── [PayPal Adapter] ──> [PayPal SDK]
                    └── [Square Adapter] ──> [Square SDK]
```

#### Advanced Adapter: Two-Way Adapter

```java
// Bidirectional Adapter for complex integrations
public class LegacySystemAdapter implements ModernInterface, LegacyInterface {
    private final LegacySystem legacySystem;
    private final DataMapper dataMapper;
    
    // Modern to Legacy adaptation
    @Override
    public ModernResponse processModernRequest(ModernRequest request) {
        // Transform modern request to legacy format
        LegacyRequest legacyRequest = dataMapper.mapToLegacy(request);
        
        // Call legacy system
        LegacyResponse legacyResponse = legacySystem.processRequest(legacyRequest);
        
        // Transform legacy response back to modern format
        return dataMapper.mapToModern(legacyResponse);
    }
    
    // Legacy to Modern adaptation (for callbacks)
    @Override
    public LegacyResponse processLegacyRequest(LegacyRequest request) {
        ModernRequest modernRequest = dataMapper.mapToModern(request);
        ModernResponse modernResponse = modernService.process(modernRequest);
        return dataMapper.mapToLegacy(modernResponse);
    }
}
```

#### Class Adapter with Inheritance

```java
// When you control the adaptee and can extend it
public class PayPalPaymentAdapter extends PayPalSDK implements PaymentProcessor {
    
    @Override
    public PaymentResult processPayment(PaymentRequest request) {
        // Direct access to parent methods
        PayPalPayment paypalPayment = new PayPalPayment(
            request.getAmount().toString(),
            request.getCurrency().name(),
            "sale"
        );
        
        PayPalResponse response = super.executePayment(paypalPayment);
        
        return PaymentResult.builder()
            .transactionId(response.getTransactionId())
            .status(mapPayPalStatus(response.getState()))
            .amount(request.getAmount())
            .currency(request.getCurrency())
            .build();
    }
}
```

#### Adapter Factory Pattern

```java
// Factory for creating payment adapters
@Component
public class PaymentAdapterFactory {
    private final Map<PaymentProvider, Supplier<PaymentProcessor>> adapterMap;
    
    @Autowired
    public PaymentAdapterFactory(StripePaymentService stripeService,
                               PayPalSDK paypalSdk,
                               SquareClient squareClient) {
        this.adapterMap = Map.of(
            PaymentProvider.STRIPE, () -> new StripePaymentAdapter(stripeService),
            PaymentProvider.PAYPAL, () -> new PayPalPaymentAdapter(paypalSdk),
            PaymentProvider.SQUARE, () -> new SquarePaymentAdapter(squareClient)
        );
    }
    
    public PaymentProcessor createAdapter(PaymentProvider provider) {
        Supplier<PaymentProcessor> adapterSupplier = adapterMap.get(provider);
        if (adapterSupplier == null) {
            throw new UnsupportedPaymentProviderException(provider);
        }
        return adapterSupplier.get();
    }
}

// Usage with Strategy Pattern
@Service
public class PaymentService {
    private final PaymentAdapterFactory adapterFactory;
    
    public PaymentResult processPayment(PaymentRequest request) {
        PaymentProcessor processor = adapterFactory.createAdapter(request.getProvider());
        return processor.processPayment(request);
    }
}
```

#### Facade Pattern: Simplifying Complex Subsystems

#### The Problem It Solves

You have multiple subsystems that clients need to interact with, but the complexity is overwhelming. **Facade provides a simple, unified interface.**

#### Basic Facade Implementation

```java
// Complex Subsystems
@Component
public class OrderValidationService {
    public ValidationResult validateOrder(Order order) {
        // Complex validation logic
        return ValidationResult.success();
    }
}

@Component
public class InventoryService {
    public boolean reserveItems(List<OrderItem> items) {
        // Complex inventory management
        return true;
    }
    
    public void releaseReservation(String reservationId) {
        // Release reserved items
    }
}
@Component
public class PaymentService {
    public PaymentResult processPayment(PaymentDetails payment) {
        // Complex payment processing
        return PaymentResult.success("txn-123");
    }
}
@Component
public class ShippingService {
    public ShippingLabel createShippingLabel(Order order) {
        // Complex shipping label creation
        return new ShippingLabel("label-456");
    }
}
@Component
public class NotificationService {
    public void sendOrderConfirmation(String email, Order order) {
        // Send confirmation email
    }
}
// Facade - Simplified Interface
@Service
public class OrderProcessingFacade {
    private final OrderValidationService validationService;
    private final InventoryService inventoryService;
    private final PaymentService paymentService;
    private final ShippingService shippingService;
    private final NotificationService notificationService;
    private final OrderRepository orderRepository;
    
    @Transactional
    public OrderResult processOrder(OrderRequest request) {
        try {
            // Step 1: Create order entity
            Order order = Order.fromRequest(request);
            
            // Step 2: Validate order
            ValidationResult validation = validationService.validateOrder(order);
            if (!validation.isValid()) {
                return OrderResult.validationFailed(validation.getErrors());
            }
            
            // Step 3: Reserve inventory
            boolean inventoryReserved = inventoryService.reserveItems(order.getItems());
            if (!inventoryReserved) {
                return OrderResult.inventoryUnavailable();
            }
            
            String reservationId = order.getInventoryReservationId();
            
            try {
                // Step 4: Process payment
                PaymentResult paymentResult = paymentService.processPayment(
                    order.getPaymentDetails());
                    
                if (!paymentResult.isSuccess()) {
                    inventoryService.releaseReservation(reservationId);
                    return OrderResult.paymentFailed(paymentResult.getError());
                }
                
                order.setPaymentTransactionId(paymentResult.getTransactionId());
                
                // Step 5: Create shipping label
                ShippingLabel shippingLabel = shippingService.createShippingLabel(order);
                order.setShippingLabelId(shippingLabel.getId());
                
                // Step 6: Save order
                Order savedOrder = orderRepository.save(order);
                
                // Step 7: Send confirmation
                notificationService.sendOrderConfirmation(
                    order.getCustomerEmail(), savedOrder);
                
                return OrderResult.success(savedOrder.getId());
                
            } catch (Exception e) {
                // Rollback inventory reservation on any failure
                inventoryService.releaseReservation(reservationId);
                throw e;
            }
            
        } catch (Exception e) {
            log.error("Order processing failed for request: {}", request, e);
            return OrderResult.processingFailed(e.getMessage());
        }
    }
    
    // Additional facade methods
    public OrderStatus getOrderStatus(String orderId) {
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new OrderNotFoundException(orderId));
        return order.getStatus();
    }
    
    public boolean cancelOrder(String orderId) {
        // Coordinate cancellation across all subsystems
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new OrderNotFoundException(orderId));
            
        if (!order.isCancellable()) {
            return false;
        }
        
        // Reverse all operations
        inventoryService.releaseReservation(order.getInventoryReservationId());
        paymentService.refundPayment(order.getPaymentTransactionId(), order.getTotal());
        shippingService.cancelShipment(order.getShippingLabelId());
        notificationService.sendCancellationConfirmation(order.getCustomerEmail(), order);
        
        order.cancel();
        orderRepository.save(order);
        
        return true;
    }
}
```

#### System Architecture: Microservice Facade

```
[Client] → [Order Facade] → [Validation Service]
                         → [Inventory Service]
                         → [Payment Service]
                         → [Shipping Service]
                         → [Notification Service]
```

#### Advanced Facade: API Gateway Pattern

```kotlin
// Microservices Facade with Circuit Breaker
@RestController
@RequestMapping("/api/v1")
public class ApiGatewayFacade {
    private final UserServiceClient userService;
    private final OrderServiceClient orderService;
    private final ProductServiceClient productService;
    private final CircuitBreakerRegistry circuitBreakerRegistry;
    
    @GetMapping("/dashboard/{userId}")
    public DashboardResponse getDashboard(@PathVariable String userId) {
        // Parallel calls to multiple services with circuit breakers
        CompletableFuture<UserProfile> userFuture = CompletableFuture.supplyAsync(() ->
            circuitBreakerRegistry.circuitBreaker("user-service")
                .executeSupplier(() -> userService.getProfile(userId))
        );
        
        CompletableFuture<List<Order>> ordersFuture = CompletableFuture.supplyAsync(() ->
            circuitBreakerRegistry.circuitBreaker("order-service")
                .executeSupplier(() -> orderService.getRecentOrders(userId))
        );
        
        CompletableFuture<List<Product>> recommendationsFuture = CompletableFuture.supplyAsync(() ->
            circuitBreakerRegistry.circuitBreaker("product-service")
                .executeSupplier(() -> productService.getRecommendations(userId))
        );
        
        try {
            // Wait for all services to respond
            CompletableFuture.allOf(userFuture, ordersFuture, recommendationsFuture)
                .get(5, TimeUnit.SECONDS);
            
            return DashboardResponse.builder()
                .user(userFuture.get())
                .recentOrders(ordersFuture.get())
                .recommendations(recommendationsFuture.get())
                .build();
                
        } catch (Exception e) {
            // Graceful degradation
            return createFallbackDashboard(userId, e);
        }
    }
    
    private DashboardResponse createFallbackDashboard(String userId, Exception e) {
        log.warn("Dashboard service degraded for user: {}", userId, e);
        
        return DashboardResponse.builder()
            .user(UserProfile.anonymous())
            .recentOrders(Collections.emptyList())
            .recommendations(Collections.emptyList())
            .degraded(true)
            .message("Some features are temporarily unavailable")
            .build();
    }
}
```

#### Facade with Caching Layer

```kotlin
@Service
public class CachedUserFacade {
    private final UserService userService;
    private final ProfileService profileService;
    private final PreferencesService preferencesService;
    private final Cache<String, CompleteUserInfo> userCache;
    
    public CachedUserFacade(UserService userService,
                           ProfileService profileService,
                           PreferencesService preferencesService) {
        this.userService = userService;
        this.profileService = profileService;
        this.preferencesService = preferencesService;
        this.userCache = Caffeine.newBuilder()
            .maximumSize(10_000)
            .expireAfterWrite(Duration.ofMinutes(15))
            .refreshAfterWrite(Duration.ofMinutes(5))
            .buildAsync(this::loadCompleteUserInfo);
    }
    
    public CompleteUserInfo getCompleteUserInfo(String userId) {
        try {
            return userCache.get(userId).get(2, TimeUnit.SECONDS);
        } catch (Exception e) {
            log.warn("Cache miss or timeout for user: {}", userId);
            return loadCompleteUserInfo(userId);
        }
    }
    
    private CompleteUserInfo loadCompleteUserInfo(String userId) {
        // Aggregate data from multiple services
        CompletableFuture<User> userFuture = 
            CompletableFuture.supplyAsync(() -> userService.getUser(userId));
            
        CompletableFuture<UserProfile> profileFuture = 
            CompletableFuture.supplyAsync(() -> profileService.getProfile(userId));
            
        CompletableFuture<UserPreferences> preferencesFuture = 
            CompletableFuture.supplyAsync(() -> preferencesService.getPreferences(userId));
        
        try {
            CompletableFuture.allOf(userFuture, profileFuture, preferencesFuture)
                .get(5, TimeUnit.SECONDS);
                
            return CompleteUserInfo.builder()
                .user(userFuture.get())
                .profile(profileFuture.get())
                .preferences(preferencesFuture.get())
                .build();
                
        } catch (Exception e) {
            throw new UserInfoLoadException("Failed to load complete user info", e);
        }
    }
}
```

#### Combining Adapter + Facade: Enterprise Integration

```java
// Enterprise Facade that uses Adapters for legacy integration
@Service
public class EnterpriseOrderFacade {
    private final ModernOrderService modernOrderService;
    private final PaymentAdapterFactory paymentAdapterFactory;
    private final LegacyInventoryAdapter legacyInventoryAdapter;
    private final ModernShippingService shippingService;
    
    public OrderResult processHybridOrder(OrderRequest request) {
        // Use modern service for order management
        Order order = modernOrderService.createOrder(request);
        
        // Use adapter for legacy inventory system
        boolean inventoryAvailable = legacyInventoryAdapter.checkAvailability(
            order.getItems());
            
        if (!inventoryAvailable) {
            return OrderResult.inventoryUnavailable();
        }
        
        // Use adapter factory for payment processing
        PaymentProcessor paymentProcessor = paymentAdapterFactory
            .createAdapter(request.getPaymentProvider());
        PaymentResult paymentResult = paymentProcessor.processPayment(
            request.getPaymentDetails());
            
        if (!paymentResult.isSuccess()) {
            return OrderResult.paymentFailed(paymentResult.getError());
        }
        
        // Use modern service for shipping
        ShippingLabel label = shippingService.createLabel(order);
        
        return OrderResult.success(order.getId());
    }
}
```

#### Anti-Patterns: What Goes Wrong

#### Adapter Anti-Patterns

1\. Leaky Abstraction

```typescript
// DON'T DO THIS - Exposing adaptee details
public class BadStripeAdapter implements PaymentProcessor {
    public PaymentResult processPayment(PaymentRequest request) {
        // Returns Stripe-specific error codes instead of generic ones
        throw new StripeCardException("card_declined"); // Leaky!
    }
}
```

2\. Over-Adaptation

```typescript
// DON'T DO THIS - Adapter doing too much business logic
public class OverComplexAdapter implements PaymentProcessor {
    public PaymentResult processPayment(PaymentRequest request) {
        // Validation (business logic - doesn't belong here)
        // Fraud detection (business logic)
        // Tax calculation (business logic)
        // Currency conversion (maybe business logic)
        
        // Finally, the actual adaptation
        return stripeService.charge(request);
    }
}
```

#### Facade Anti-Patterns

1\. God Facade

```csharp
// DON'T DO THIS - Facade that does everything
public class GodFacade {
    public void processOrder() { /* 500 lines */ }
    public void manageInventory() { /* 300 lines */ }
    public void handlePayments() { /* 200 lines */ }
    public void manageUsers() { /* 400 lines */ }
    // ... does everything
}
```

2\. Anemic Facade

```typescript
// DON'T DO THIS - Facade that adds no value
public class AnémicFacade {
    public UserResult getUser(String id) {
        return userService.getUser(id); // Just delegation, no simplification
    }
}
```

#### Production Lessons: What I Learned

#### Adapter Lessons

1. **Keep adapters thin**: Only adapt interfaces, don't add business logic
2. **Handle errors gracefully**: Transform exceptions to your domain
3. **Version your adapters**: External APIs change, your interface shouldn't
4. **Use factories for multiple adapters**: Strategy + Factory + Adapter combo

#### Facade Lessons

1. **Don't expose internals**: Clients shouldn't know about subsystems
2. **Handle failures gracefully**: One subsystem failure shouldn't break everything
3. **Consider performance**: Parallel calls where possible
4. **Cache when appropriate**: Avoid repeated expensive operations

#### System Design Applications

### Microservices Architecture

- **Adapter**: Integrate with external APIs (payment, shipping, notifications)
- **Facade**: API Gateway that hides service complexity from clients

#### Legacy System Integration

- **Adapter**: Bridge old and new systems without changing either
- **Facade**: Provide modern interface to legacy functionality

#### Third-Party Integration

- **Adapter**: Standardize different vendor APIs
- **Facade**: Simplify complex third-party SDK usage

#### Tomorrow's Preview

Day 7: "Chain of Responsibility & State Patterns" How to build flexible request processing pipelines and manage object state transitions elegantly.

#### Your Architect Assignment

Examine your current system:

1. **Find incompatible interfaces** that need adapters
2. **Identify complex subsystem interactions** that could benefit from facades
3. **Look for repeated third-party integrations** that could be standardized
4. **Spot areas where clients know too much** about internal complexity

Remember: **Adapter makes things work together. Facade makes complex things simple. Both are essential for maintainable enterprise systems.**

*Previous articles:*

- *[Day 1 — Building Your Architect Mindset](https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)*
- *[Day 2 — Strategy & Observer Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*
- *[Day 3 — Decorator & Proxy Patterns](https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*
- *[Day 4 — Singleton & Builder Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*
- *[Day 5 — Command & Template Method Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*

*Follow along daily as we master the structural patterns that create flexible, maintainable architectures.*

[< Go to the original](https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48#bypass)