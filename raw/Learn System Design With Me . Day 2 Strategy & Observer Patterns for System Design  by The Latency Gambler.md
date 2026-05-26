---
title: "Learn System Design With Me . Day 2: Strategy & Observer Patterns for System Design | by The Latency Gambler"
source: "https://freedium-mirror.cfd/medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf"
author:
  - "[[The Latency Gambler]]"
published:
created: 2026-05-26
description: "This is Day 2 of our 30-day journey from code writer to system architect. Missed Day 1? Start here"
tags:
  - "clippings"
---
[< Go to the original](https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/0*5PBgg3KM74EnlVN0)

## Learn System Design With Me. Day 2: Strategy & Observer Patterns for System Design

## This is Day 2 of our 30-day journey from code writer to system architect. Missed Day 1? Start here

a11y-light · September 14, 2025 (Updated: September 14, 2025) · Free: No

Yesterday, we talked about rewiring your brain to think like an architect. Today, we dive into two behavioral patterns that are the **backbone of every scalable system**: Strategy and Observer.

But here's the thing, I won't teach you the textbook "Duck flying behavior" examples. We're going straight to production-grade implementations that power companies like Netflix, Uber, and Amazon.

#### Why These Patterns Matter for System Architects

Most developers learn Strategy and Observer as code organization tools. **Architects use them as system design weapons.**

- **Strategy Pattern**: Runtime behavior switching without downtime
- **Observer Pattern**: Event-driven architectures that scale to millions of users

Let me show you how.

#### Strategy Pattern: Runtime Flexibility at Scale

#### The System Design Problem

Imagine you're building a payment system. Today you support credit cards. Tomorrow, your PM wants PayPal. Next week, cryptocurrency. Traditional approach? Modify core logic every time. **Architect approach? Strategy Pattern.**

```typescript
// The Strategy Interface - Your System Contract
public interface PaymentStrategy {
    PaymentResult process(PaymentRequest request);
    boolean supports(PaymentType type);
}

// Concrete Strategies - Pluggable Behaviors
public class CreditCardStrategy implements PaymentStrategy {
    @Override
    public PaymentResult process(PaymentRequest request) {
        // Stripe/Square integration logic
        return processWithStripe(request);
    }
    
    @Override
    public boolean supports(PaymentType type) {
        return type == PaymentType.CREDIT_CARD;
    }
}

public class PayPalStrategy implements PaymentStrategy {
    @Override
    public PaymentResult process(PaymentRequest request) {
        // PayPal SDK integration
        return processWithPayPal(request);
    }
    
    @Override
    public boolean supports(PaymentType type) {
        return type == PaymentType.PAYPAL;
    }
}

// Context - Your System Core
public class PaymentProcessor {
    private final List<PaymentStrategy> strategies;
    
    public PaymentProcessor(List<PaymentStrategy> strategies) {
        this.strategies = strategies;
    }
    
    public PaymentResult processPayment(PaymentRequest request) {
        PaymentStrategy strategy = strategies.stream()
            .filter(s -> s.supports(request.getType()))
            .findFirst()
            .orElseThrow(() -> new UnsupportedPaymentException());
            
        return strategy.process(request);
    }
}
```

> **System Architecture Impact**: New payment methods become configuration changes, not code deployments.

#### Advanced Strategy: Configuration-Driven Behavior

```kotlin
@Component
public class StrategyFactory {
    
    @Value("${fraud.detection.strategy:basic}")
    private String fraudStrategy;
    
    @Autowired
    private Map<String, FraudDetectionStrategy> strategies;
    
    public FraudDetectionStrategy getStrategy() {
        return strategies.get(fraudStrategy);
    }
}

// In application.yml
fraud:
  detection:
    strategy: "advanced" # Switch strategies without deployment
```

> This is how Netflix switches recommendation algorithms in production, zero downtime, instant rollback capability.

#### Strategy + Dependency Injection (Spring Framework)

```java
@Service
public class NotificationService {
    
    @Autowired
    @Qualifier("email")
    private NotificationStrategy emailStrategy;
    
    @Autowired  
    @Qualifier("sms")
    private NotificationStrategy smsStrategy;
    
    public void notify(User user, Message message) {
        NotificationStrategy strategy = selectStrategy(user.getPreferences());
        strategy.send(message);
    }
}
```

#### Multi-Level Strategy: Composite Patterns

Real systems need strategy pipelines:

```kotlin
public class FraudDetectionPipeline {
    private final List<FraudStrategy> strategies;
    
    public FraudResult analyze(Transaction transaction) {
        return strategies.stream()
            .map(strategy -> strategy.analyze(transaction))
            .reduce(FraudResult::combine)
            .orElse(FraudResult.CLEAN);
    }
}

// Chain: IP Check → Velocity Check → ML Model → Manual Review
```

#### Strategy with Functional Programming (Java 8+)

```dart
// Traditional Strategy Classes
Map<PaymentType, PaymentStrategy> strategies = Map.of(
    CREDIT_CARD, new CreditCardStrategy(),
    PAYPAL, new PayPalStrategy()
);

// Functional Approach
Map<PaymentType, Function<PaymentRequest, PaymentResult>> strategies = Map.of(
    CREDIT_CARD, this::processCreditCard,
    PAYPAL, this::processPayPal
);
```

> **When to use which**: Classes for complex logic with state, functions for simple transformations.

#### Observer Pattern: Event-Driven Architecture Foundation

#### The System Design Reality

Every scalable system is event-driven. User registers → send email, update analytics, sync CRM, trigger recommendations. **Observer pattern is how you decouple these concerns.**

```csharp
// Subject - Your System's Event Source  
public class UserService {
    private final List<UserEventObserver> observers = new ArrayList<>();
    
    public void addObserver(UserEventObserver observer) {
        observers.add(observer);
    }
    
    public void registerUser(User user) {
        // Core business logic
        userRepository.save(user);
        
        // Notify all interested parties
        UserRegisteredEvent event = new UserRegisteredEvent(user);
        observers.forEach(observer -> observer.onUserRegistered(event));
    }
}

// Observer Interface - Your Event Contract
public interface UserEventObserver {
    void onUserRegistered(UserRegisteredEvent event);
    void onUserUpdated(UserUpdatedEvent event);
}

// Concrete Observers - Decoupled Services
@Component
public class EmailNotificationObserver implements UserEventObserver {
    @Override
    public void onUserRegistered(UserRegisteredEvent event) {
        emailService.sendWelcomeEmail(event.getUser());
    }
}

@Component  
public class AnalyticsObserver implements UserEventObserver {
    @Override
    public void onUserRegistered(UserRegisteredEvent event) {
        analyticsService.track("user_registered", event.getUser().getId());
    }
}
```

#### System Architecture Diagram

```
[User Service] ──┐
                 ├─ [Email Service]
                 ├─ [Analytics Service]  
                 ├─ [CRM Sync Service]
                 └─ [Recommendation Service]
```

> **Architecture Benefit**: Adding new functionality doesn't touch existing code. Pure extensibility.

#### Advanced Observer: Push vs Pull Models

```csharp
// Push Model - Subject sends all data
public interface PushObserver {
    void notify(UserEvent event); // Gets complete event data
}

// Pull Model - Observer requests what it needs
public interface PullObserver {
    void notify(String userId); // Gets minimal data, pulls rest if needed
    
    default void handleEvent(String userId) {
        User user = userService.getUser(userId); // Pull what you need
        processUser(user);
    }
}
```

> **Trade-off**: Push is faster but wastes bandwidth. Pull is efficient but requires more network calls.

#### Async Observers: Production-Grade Performance

```java
@Service
public class AsyncUserService {
    private final ExecutorService observerExecutor = 
        Executors.newFixedThreadPool(10);
    
    private void notifyObservers(UserEvent event) {
        observers.forEach(observer -> 
            observerExecutor.submit(() -> {
                try {
                    observer.handleEvent(event);
                } catch (Exception e) {
                    log.error("Observer failed", e);
                    // Continue with other observers
                }
            })
        );
    }
}
```

#### Observer Prioritization: Critical Systems

```csharp
public class PrioritizedObserverManager {
    private final Map<Priority, List<Observer>> observersByPriority;
    
    public void notifyObservers(Event event) {
        // High priority first (risk monitoring, fraud detection)
        notifyPriority(Priority.HIGH, event);
        
        // Then medium (business logic)
        notifyPriority(Priority.MEDIUM, event);
        
        // Finally low (logging, analytics)
        async(() -> notifyPriority(Priority.LOW, event));
    }
}
```

#### Observer in Distributed Systems: Event Sourcing

```typescript
// Event Store - Your System of Record
@Entity
public class UserEvent {
    private String eventId;
    private String aggregateId; // User ID
    private String eventType;   // "UserRegistered", "UserUpdated"
    private String eventData;   // JSON payload
    private LocalDateTime timestamp;
}

// Event Sourcing with Observer
@Service
public class EventSourcingUserService {
    
    public void registerUser(User user) {
        // 1. Store event
        UserRegisteredEvent event = new UserRegisteredEvent(user);
        eventStore.append(event);
        
        // 2. Publish to message bus (Kafka/RabbitMQ)
        eventPublisher.publish("user-events", event);
    }
}

// Distributed Observers (Different Microservices)
@KafkaListener(topics = "user-events")
public class EmailServiceObserver {
    public void handleUserEvent(UserEvent event) {
        if (event.getType().equals("UserRegistered")) {
            sendWelcomeEmail(event.getUser());
        }
    }
}
```

#### Spring Framework Integration

```typescript
// Spring's Built-in Observer Pattern
@Component
public class UserService {
    
    @Autowired
    private ApplicationEventPublisher eventPublisher;
    
    public void registerUser(User user) {
        userRepository.save(user);
        
        // Publish event - Spring handles observer notification
        eventPublisher.publishEvent(new UserRegisteredEvent(user));
    }
}

@EventListener
@Component
public class EmailService {
    public void handleUserRegistration(UserRegisteredEvent event) {
        // Automatically called when event is published
        sendWelcomeEmail(event.getUser());
    }
}
```

#### Combining Strategy + Observer: Real-World Power

```java
@Service
public class OrderProcessor {
    private final PaymentStrategyFactory paymentFactory;
    private final List<OrderObserver> observers;
    
    public void processOrder(Order order) {
        try {
            // Strategy Pattern: Choose payment method
            PaymentStrategy strategy = paymentFactory.getStrategy(order.getPaymentType());
            PaymentResult result = strategy.process(order.getPayment());
            
            if (result.isSuccess()) {
                order.markAsPaid();
                
                // Observer Pattern: Notify all interested services
                OrderPaidEvent event = new OrderPaidEvent(order);
                observers.forEach(observer -> observer.onOrderPaid(event));
            }
        } catch (PaymentException e) {
            // Strategy for failure handling
            FailureStrategy failureStrategy = failureFactory.getStrategy(e.getType());
            failureStrategy.handle(order, e);
        }
    }
}
```

#### Anti-Patterns to Avoid

#### Strategy Hell

```java
// DON'T DO THIS - Over-engineering
public interface AdditionStrategy {
    int add(int a, int b);
}

public class SimpleAdditionStrategy implements AdditionStrategy {
    public int add(int a, int b) { return a + b; } // Seriously?
}
```

> **Rule**: Use Strategy when you have genuinely different algorithms, not trivial variations.

#### Observer Hell

```typescript
// DON'T DO THIS - Event storms
public void updateUser(User user) {
    // 50 different observers all triggering more events
    // System becomes impossible to debug
}
```

> **Rule**: Limit observer chains. Use event correlation IDs for traceability.

#### Memory Leaks in Observer

```swift
// PROBLEM - Strong references prevent garbage collection
private final List<Observer> observers = new ArrayList<>();

// SOLUTION - Weak references
private final List<WeakReference<Observer>> observers = new ArrayList<>();
```

#### Production Lessons: What I Learned the Hard Way

1. **Observer Order Matters**: In financial systems, risk checks must run before order processing
2. **Strategy Fallbacks**: Always have a default strategy. Systems fail when no strategy matches
3. **Event Deduplication**: In distributed systems, events can arrive multiple times
4. **Backpressure**: High-frequency events can overwhelm observers implement throttling

#### Tomorrow's Preview

Day 3: "Decorator & Proxy Patterns" How to add superpowers to your objects without touching their code. We'll explore Netflix's service decoration for monitoring and Amazon's proxy patterns for load balancing.

#### Your Architect Assignment

Look at your current codebase:

1. **Find hard-coded behavior** that could be strategies
2. **Identify tight coupling** that could benefit from observer pattern
3. **Spot repeated notification logic** that screams for event-driven design

> Remember: **You're not just writing code anymore. You're designing systems that evolve.**

*Day 1:* *[Building Your Architect Mindset](https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)*

*Follow along daily as we master the patterns that power modern distributed systems.*

[< Go to the original](https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf#bypass)