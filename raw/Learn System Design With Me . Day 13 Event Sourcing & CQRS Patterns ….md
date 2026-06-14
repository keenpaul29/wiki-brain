---
title: "Learn System Design With Me . Day 13: Event Sourcing & CQRS Patterns …"
source: "https://archive.is/zquSs"
author:
  - "[[The Latency Gambler]]"
published: 2025-11-01
created: 2026-06-14
description:
tags:
  - "clippings"
---

## Learn System Design With Me. Day 13: Event Sourcing & CQRS Patterns

## The Ultimate Audit Trail & Scalability

*This is Day 13 of our 30-day journey from code writer to system architect. Start with* [*Day 1*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build the foundation, then progress through* [*Day 2*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*,* [*Day 3*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*,* [*Day 4*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*,* [*Day 5*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*,* [*Day 6*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*,* [*Day 7*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)*,* [*Day 8*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)*,* [*Day 9*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)*,* [*Day 10*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)*,* [*Day 11*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)*, and* [*Day 12*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)

![](https://dfjhcyajj5d8zi.archive.is/zquSs/3dd33049696e066694e76837326db9b3e68b2d11.webp)

We’ve mastered async messaging. Today, we tackle the **most advanced data patterns**: **Event Sourcing and CQRS**. These patterns solve complex problems in financial systems, audit requirements, and high-scale applications.

Here’s the architect reality: **Traditional CRUD systems lose history and don’t scale reads independently. Event Sourcing captures every change as an immutable fact. CQRS separates reads from writes for ultimate scalability.**

### Event Sourcing: Never Lose Data Again

### What It Is

**Event Sourcing** stores the **sequence of events** that led to the current state, instead of storing just the current state. Think of it as your **system’s complete history book**.

**Traditional approach:** User balance = $1000 (lost history) **Event Sourcing:** AccountCreated($0) → Deposited($500) → Deposited($300) → Withdrew($200) → **Balance = $1000** (complete audit trail)

### Why You Need It

**Problems with traditional CRUD:**

- **Lost history**: Can’t recreate how you got to current state
- **No audit trail**: Compliance and debugging nightmares
- **Concurrent updates**: Lost update problems
- **Hard to debug**: Can’t replay scenarios

**Event Sourcing benefits:**

- **Complete audit trail**: Every change is recorded
- **Time travel**: Recreate state at any point in time
- **Debugging**: Replay events to understand issues
- **Analytics**: Rich data for business intelligence

### Basic Event Store Implementation

```html
// Domain Event
public abstract class DomainEvent {
    private final String eventId = UUID.randomUUID().toString();
    private final String aggregateId;
    private final long version;
    private final LocalDateTime timestamp = LocalDateTime.now();
    
    public DomainEvent(String aggregateId, long version) {
        this.aggregateId = aggregateId;
        this.version = version;
    }
    
    // Getters...
}

// Concrete Events
public class MoneyDepositedEvent extends DomainEvent {
    private final BigDecimal amount;
    private final String description;
    
    public MoneyDepositedEvent(String aggregateId, long version, 
                             BigDecimal amount, String description) {
        super(aggregateId, version);
        this.amount = amount;
        this.description = description;
    }
    
    // Getters...
}
// Event Store
@Repository
public class EventStore {
    private final JdbcTemplate jdbcTemplate;
    
    public void saveEvents(String aggregateId, List<DomainEvent> events, long expectedVersion) {
        // Optimistic concurrency control
        Long currentVersion = getCurrentVersion(aggregateId);
        if (currentVersion != expectedVersion) {
            throw new ConcurrencyException("Version mismatch");
        }
        
        // Save events atomically
        String sql = "INSERT INTO event_store (event_id, aggregate_id, event_type, event_data, version) VALUES (?, ?, ?, ?, ?)";
        
        events.forEach(event -> {
            jdbcTemplate.update(sql,
                event.getEventId(),
                event.getAggregateId(), 
                event.getClass().getSimpleName(),
                serializeEvent(event),
                event.getVersion()
            );
        });
        
        // Publish events for projections
        events.forEach(eventPublisher::publish);
    }
    
    public List<DomainEvent> getEventsForAggregate(String aggregateId) {
        String sql = "SELECT * FROM event_store WHERE aggregate_id = ? ORDER BY version";
        return jdbcTemplate.query(sql, this::mapToEvent, aggregateId);
    }
}
// Aggregate with Event Sourcing
public class BankAccount {
    private String accountId;
    private BigDecimal balance = BigDecimal.ZERO;
    private long version = 0;
    private List<DomainEvent> uncommittedEvents = new ArrayList<>();
    
    // Constructor for rebuilding from events
    public BankAccount(String accountId, List<DomainEvent> events) {
        this.accountId = accountId;
        events.forEach(this::applyEvent);
    }
    
    // Business method
    public void deposit(BigDecimal amount, String description) {
        if (amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new InvalidAmountException("Amount must be positive");
        }
        
        MoneyDepositedEvent event = new MoneyDepositedEvent(
            accountId, version + 1, amount, description);
            
        applyEvent(event);
        uncommittedEvents.add(event);
    }
    
    // Apply event to change state
    private void applyEvent(DomainEvent event) {
        switch (event.getClass().getSimpleName()) {
            case "MoneyDepositedEvent":
                MoneyDepositedEvent depositEvent = (MoneyDepositedEvent) event;
                this.balance = this.balance.add(depositEvent.getAmount());
                break;
            case "MoneyWithdrawnEvent":
                MoneyWithdrawnEvent withdrawEvent = (MoneyWithdrawnEvent) event;
                this.balance = this.balance.subtract(withdrawEvent.getAmount());
                break;
        }
        this.version = event.getVersion();
    }
    
    public List<DomainEvent> getUncommittedEvents() {
        return new ArrayList<>(uncommittedEvents);
    }
    
    public void markEventsAsCommitted() {
        uncommittedEvents.clear();
    }
}
```

### CQRS: Separate Reads from Writes

### What It Is

**Command Query Responsibility Segregation (CQRS)** separates the **write model** (commands) from the **read model** (queries). Instead of using the same model for both, you optimize each for its specific purpose.

### Why You Need CQRS

**Traditional problems:**

- **Same model for reads and writes**: Compromised optimization
- **Complex queries**: JOIN-heavy queries on normalized data
- **Scaling issues**: Reads and writes have different scaling needs

**CQRS benefits:**

- **Optimized models**: Write model for consistency, read model for queries
- **Independent scaling**: Scale reads and writes separately
- **Performance**: Denormalized read models for fast queries

### CQRS Implementation

```html
// Command Side (Write Model)
@Service
public class AccountCommandService {
    private final EventStore eventStore;
    
    @Transactional
    public void deposit(DepositMoneyCommand command) {
        // Load aggregate from events
        List<DomainEvent> events = eventStore.getEventsForAggregate(command.getAccountId());
        BankAccount account = new BankAccount(command.getAccountId(), events);
        
        // Execute business logic
        account.deposit(command.getAmount(), command.getDescription());
        
        // Save new events
        eventStore.saveEvents(command.getAccountId(), 
                            account.getUncommittedEvents(), 
                            account.getVersion() - 1);
        account.markEventsAsCommitted();
    }
}

// Query Side (Read Model)
public class AccountSummaryProjection {
    private String accountId;
    private String accountNumber;
    private BigDecimal currentBalance;
    private int transactionCount;
    private LocalDateTime lastTransactionDate;
    
    // Getters, setters...
}
@Service
public class AccountQueryService {
    private final JdbcTemplate jdbcTemplate;
    
    public AccountSummaryProjection getAccountSummary(String accountId) {
        String sql = """
            SELECT account_id, account_number, current_balance, 
                   transaction_count, last_transaction_date
            FROM account_summary_view WHERE account_id = ?
            """;
        return jdbcTemplate.queryForObject(sql, this::mapToSummary, accountId);
    }
    
    public List<TransactionHistory> getTransactionHistory(String accountId) {
        String sql = """
            SELECT * FROM transaction_history_view 
            WHERE account_id = ? ORDER BY timestamp DESC
            """;
        return jdbcTemplate.query(sql, this::mapToTransaction, accountId);
    }
}
// Projection Updater
@Component
public class AccountProjectionUpdater {
    
    @EventListener
    public void handleMoneyDeposited(MoneyDepositedEvent event) {
        // Update denormalized read model
        jdbcTemplate.update("""
            UPDATE account_summary_view 
            SET current_balance = current_balance + ?,
                transaction_count = transaction_count + 1,
                last_transaction_date = ?
            WHERE account_id = ?
            """, 
            event.getAmount(), 
            event.getTimestamp(), 
            event.getAggregateId()
        );
        
        // Add to transaction history
        jdbcTemplate.update("""
            INSERT INTO transaction_history_view 
            (account_id, type, amount, description, timestamp)
            VALUES (?, 'DEPOSIT', ?, ?, ?)
            """,
            event.getAggregateId(),
            event.getAmount(),
            event.getDescription(),
            event.getTimestamp()
        );
    }
}
```

### Saga Pattern: Distributed Transactions

### What It Is

**Saga Pattern** manages **distributed transactions** across multiple services without using distributed locks. Instead of traditional ACID transactions, it uses **compensating actions** to handle failures.

### Why You Need Sagas

**Distributed transaction problems:**

- **Two-phase commit**: Blocking, not fault-tolerant
- **Distributed locks**: Performance bottlenecks

**Saga benefits:**

- **Loosely coupled**: Services coordinate via events
- **Eventually consistent**: Better availability
- **Fault tolerant**: Compensating actions handle failures

### Saga Implementation

```html
// Saga Orchestrator
public class OrderProcessingSaga {
    private String sagaId;
    private String orderId;
    private SagaStatus status;
    private List<SagaStep> completedSteps = new ArrayList<>();
    
    public void start(String orderId) {
        this.orderId = orderId;
        this.status = SagaStatus.IN_PROGRESS;
        executeStep(new ReserveInventoryStep());
    }
    
    public void handleStepCompleted(String stepName, Map<String, Object> result) {
        switch (stepName) {
            case "ReserveInventory":
                executeStep(new ProcessPaymentStep());
                break;
            case "ProcessPayment":
                executeStep(new CreateShipmentStep());
                break;
            case "CreateShipment":
                completeSaga();
                break;
        }
    }
    
    public void handleStepFailed(String stepName, String error) {
        this.status = SagaStatus.COMPENSATING;
        startCompensation();
    }
    
    private void startCompensation() {
        // Execute compensating actions in reverse order
        Collections.reverse(completedSteps);
        
        for (SagaStep step : completedSteps) {
            try {
                step.compensate(orderId);
            } catch (Exception e) {
                log.error("Compensation failed for step: {}", step.getName(), e);
            }
        }
        
        this.status = SagaStatus.FAILED;
    }
}

// Saga Step
public interface SagaStep {
    String getName();
    void execute(String orderId, String sagaId);
    void compensate(String orderId);
}
public class ReserveInventoryStep implements SagaStep {
    
    @Override
    public void execute(String orderId, String sagaId) {
        try {
            Order order = orderService.getOrder(orderId);
            inventoryService.reserveItems(order.getItems());
            
            eventPublisher.publish(new SagaStepCompletedEvent(sagaId, getName()));
        } catch (Exception e) {
            eventPublisher.publish(new SagaStepFailedEvent(sagaId, getName(), e.getMessage()));
        }
    }
    
    @Override
    public void compensate(String orderId) {
        inventoryService.releaseReservations(orderId);
        log.info("Compensated inventory for order: {}", orderId);
    }
}
public class ProcessPaymentStep implements SagaStep {
    
    @Override
    public void execute(String orderId, String sagaId) {
        try {
            Order order = orderService.getOrder(orderId);
            PaymentResult result = paymentService.processPayment(
                order.getCustomerId(), order.getTotalAmount());
                
            if (result.isSuccess()) {
                eventPublisher.publish(new SagaStepCompletedEvent(sagaId, getName()));
            } else {
                eventPublisher.publish(new SagaStepFailedEvent(sagaId, getName(), 
                    "Payment failed: " + result.getError()));
            }
        } catch (Exception e) {
            eventPublisher.publish(new SagaStepFailedEvent(sagaId, getName(), e.getMessage()));
        }
    }
    
    @Override
    public void compensate(String orderId) {
        Order order = orderService.getOrder(orderId);
        if (order.getPaymentTransactionId() != null) {
            paymentService.refundPayment(order.getPaymentTransactionId());
            log.info("Compensated payment for order: {}", orderId);
        }
    }
}
```

### System Architecture: Complete Event-Driven System

```html
[Commands] ──> [Write Model] ──> [Event Store] ──> [Event Bus] ──┬─> [Read Model 1: Summary]
                                      │                          ├─> [Read Model 2: History]
                                      │                          ├─> [Read Model 3: Analytics]
                                      ▼                          └─> [Saga Orchestrator]
                               [Event History]
                               [Complete Audit Trail]
```

### Advanced Patterns

### Event Snapshotting

**Why needed:** Loading aggregates with thousands of events is slow.

```html
@Component
public class SnapshotService {
    
    public void createSnapshot(String aggregateId, long version, BankAccount account) {
        AccountSnapshot snapshot = AccountSnapshot.builder()
            .aggregateId(aggregateId)
            .version(version)
            .balance(account.getBalance())
            .accountNumber(account.getAccountNumber())
            .timestamp(LocalDateTime.now())
            .build();
            
        snapshotRepository.save(snapshot);
    }
    
    public BankAccount loadAggregateWithSnapshot(String aggregateId) {
        AccountSnapshot snapshot = snapshotRepository.findLatest(aggregateId);
        
        if (snapshot != null) {
            // Start from snapshot
            BankAccount account = rebuildFromSnapshot(snapshot);
            
            // Apply only events since snapshot
            List<DomainEvent> eventsSinceSnapshot = 
                eventStore.getEventsForAggregate(aggregateId, snapshot.getVersion() + 1);
            eventsSinceSnapshot.forEach(account::applyEvent);
            
            return account;
        } else {
            // No snapshot - rebuild from all events
            return rebuildFromAllEvents(aggregateId);
        }
    }
}
```

### Event Versioning

**Why needed:** Event schemas evolve over time.

```html
public class MoneyDepositedEventV2 extends DomainEvent {
    private String version = "v2";
    private BigDecimal amount;
    private String description;
    private String sourceAccount; // New field in v2
    
    @JsonCreator
    public MoneyDepositedEventV2(@JsonProperty("amount") BigDecimal amount,
                               @JsonProperty("description") String description,
                               @JsonProperty("sourceAccount") String sourceAccount) {
        this.amount = amount;
        this.description = description;
        this.sourceAccount = sourceAccount != null ? sourceAccount : "UNKNOWN";
    }
}
```

### Projection Rebuilding

**Why needed:** Fix bugs in projections or add new read models.

```html
@Service
public class ProjectionRebuilder {
    
    public void rebuildAccountSummaryProjection() {
        // Clear existing projection
        jdbcTemplate.update("TRUNCATE TABLE account_summary_view");
        
        // Replay all events
        List<DomainEvent> allEvents = eventStore.getAllEvents();
        
        AccountProjectionUpdater updater = new AccountProjectionUpdater();
        
        allEvents.forEach(event -> {
            if (event instanceof MoneyDepositedEvent) {
                updater.handleMoneyDeposited((MoneyDepositedEvent) event);
            } else if (event instanceof MoneyWithdrawnEvent) {
                updater.handleMoneyWithdrawn((MoneyWithdrawnEvent) event);
            }
        });
        
        log.info("Rebuilt account summary projection with {} events", allEvents.size());
    }
}
```

### Production Considerations

### Monitoring and Metrics

```html
@Component
public class EventSourcingMetrics {
    private final MeterRegistry registry;
    
    public void recordEventStored(String eventType) {
        registry.counter("events.stored", "type", eventType).increment();
    }
    
    public void recordProjectionLag(String projectionName, Duration lag) {
        registry.gauge("projection.lag.seconds", lag.toSeconds());
    }
    
    public void recordSagaCompleted(String sagaType, Duration duration) {
        registry.timer("saga.completion.time", "type", sagaType).record(duration);
    }
}
```

### Error Handling

```html
@Component
public class EventProcessingErrorHandler {
    
    @EventListener
    @RetryableTopic(attempts = "3", backoff = @Backoff(delay = 1000))
    public void handleEvent(DomainEvent event) {
        try {
            projectionUpdater.updateProjection(event);
        } catch (Exception e) {
            log.error("Failed to process event: {}", event.getEventId(), e);
            throw e; // Will trigger retry
        }
    }
    
    @DltHandler
    public void handleDlt(DomainEvent event, Exception exception) {
        // Send to dead letter topic after all retries failed
        deadLetterService.handleFailedEvent(event, exception);
    }
}
```

### Decision Framework

### Use Event Sourcing when:

- Need complete audit trail (financial systems)
- Complex business logic requires replay capability
- Debugging requires event history
- Compliance requires immutable records

### Use CQRS when:

- Read and write patterns are very different
- Need to scale reads independently from writes
- Complex reporting requirements
- Multiple read models from same data

### Use Sagas when:

- Distributed transactions across microservices
- Need eventual consistency over strong consistency
- Long-running business processes
- Can define compensating actions

### Avoid these patterns when:

- Simple CRUD applications
- Strong consistency is absolutely required
- Team lacks experience with event-driven systems
- Operational complexity outweighs benefits

### Common Pitfalls

1. **Event Store as Database**: Don’t query event store for business logic
2. **Too Many Projections**: Each projection adds complexity
3. **Ignoring Event Ordering**: Events must be processed in order per aggregate
4. **Snapshot Strategy**: Balance between performance and storage

### Tomorrow’s Preview

Day 14: “Monitoring & Observer Patterns”. How to build comprehensive observability into your systems with metrics, traces, and logging patterns.

### Your Architect Assignment

1. **Identify audit requirements** in your domain that need event history
2. **Find read-heavy operations** that could benefit from CQRS
3. **Look for distributed transactions** that could use Sagas
4. **Consider event-driven refactoring** for better scalability

Remember: **Event Sourcing gives you perfect audit trails and time travel. CQRS scales reads independently. Sagas handle distributed workflows. These patterns are complex but solve complex problems that traditional CRUD cannot.**

*Previous articles:*

- [*Day 1 Building Your Architect Mindset*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [*Day 2 Strategy & Observer Patterns*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [*Day 3 Decorator & Proxy Patterns*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [*Day 4 Singleton & Builder Patterns*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [*Day 5 Command & Template Method Patterns*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [*Day 6 Adapter & Facade Patterns*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [*Day 7 Chain of Responsibility & State Patterns*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [*Day 8 Load Balancing & Circuit Breaker Patterns*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)
- [*Day 9 Database Patterns & Repository Pattern*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)
- [*Day 10 Caching Patterns*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)
- [*Day 11 API Gateway & Proxy Patterns*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)
- [*Day 12 Message Queue Patterns*](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)

*Follow along daily as we master the most advanced patterns for building audit-compliant, scalable, event-driven systems.*

## Responses (1)

Write a response[What are your thoughts?](https://archive.is/o/zquSs/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)

```html
As you brought them up together, I think it makes sense to emphasize that CQRS (and CQS) is not bound to event sourcing, ES just feels more natural with CQRS. In my experience, taking the initial step causes the most of the headaches. To ease into it, I’d point to event modeling (https://eventmodeling.org/about/).
```

[0%](https://archive.is/zquSs#0%) [10%](https://archive.is/zquSs#10%) [20%](https://archive.is/zquSs#20%) [30%](https://archive.is/zquSs#30%) [40%](https://archive.is/zquSs#40%) [50%](https://archive.is/zquSs#50%) [60%](https://archive.is/zquSs#60%) [70%](https://archive.is/zquSs#70%) [80%](https://archive.is/zquSs#80%) [90%](https://archive.is/zquSs#90%) [100%](https://archive.is/zquSs#100%)