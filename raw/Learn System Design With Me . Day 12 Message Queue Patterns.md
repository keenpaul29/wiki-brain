---
title: "Learn System Design With Me . Day 12: Message Queue Patterns"
source: "https://archive.is/0Q7ky"
author:
  - "[[The Latency Gambler]]"
published: 2025-11-01
created: 2026-06-14
description:
tags:
  - "clippings"
---
## Async Communication That Scales

*This is Day 12 of our 30-day journey from code writer to system architect. Start with* [*Day 1*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build the foundation, then progress through* [*Day 2*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*,* [*Day 3*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*,* [*Day 4*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*,* [*Day 5*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*,* [*Day 6*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*,* [*Day 7*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)*,* [*Day 8*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)*,* [*Day 9*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)*,* [*Day 10*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)*, and* [*Day 11*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)

We’ve mastered synchronous communication with API gateways. Today, we dive into **asynchronous communication**: **Message Queue Patterns**. This is where systems become truly scalable, resilient, and decoupled.

![](https://d03zbv6pyg2zlc.archive.is/0Q7ky/00f82d710db973819c35e8d444a96302bb64bb56.webp)

Ai Generated Image

Here’s the architect truth: **Synchronous calls create brittle systems that fail together. Async messaging creates resilient systems that fail independently.** Message queues are your decoupling superpower.

### Why Message Queues Matter

### The Synchronous Problem

In synchronous systems, when Service A calls Service B directly:

- **Tight coupling**: A depends on B being available
- **Cascade failures**: B fails → A fails → entire system fails
- **Performance bottlenecks**: A waits for B’s response
- **Scaling issues**: B’s load affects A’s performance

### The Async Solution

With message queues:

- **Loose coupling**: Services communicate via messages
- **Failure isolation**: B fails, A continues working
- **Performance**: A doesn’t wait for B’s processing
- **Independent scaling**: Scale services based on their load

### Publisher-Subscriber Pattern: Event-Driven Architecture

### What It Is

**Publisher-Subscriber (Pub/Sub)** is a messaging pattern where publishers send messages to topics, and subscribers receive messages from topics they’re interested in. Publishers don’t know who the subscribers are complete decoupling.

**Real-world analogy:** Newspaper publishing. Publishers create content, subscribers read what interests them.

### Basic Pub/Sub Implementation

```html
// Event/Message Definition
public class OrderCreatedEvent {
    private final String orderId;
    private final String customerId;
    private final BigDecimal amount;
    private final LocalDateTime timestamp;
    private final List<OrderItem> items;
    
    // Constructor, getters, builder...
}

// Publisher Service
@Service
public class OrderService {
    private final OrderRepository orderRepository;
    private final EventPublisher eventPublisher;
    
    @Transactional
    public Order createOrder(CreateOrderRequest request) {
        // 1. Create and save order
        Order order = Order.builder()
            .customerId(request.getCustomerId())
            .items(request.getItems())
            .amount(calculateTotal(request.getItems()))
            .status(OrderStatus.CREATED)
            .build();
            
        Order savedOrder = orderRepository.save(order);
        
        // 2. Publish event (async, non-blocking)
        OrderCreatedEvent event = OrderCreatedEvent.builder()
            .orderId(savedOrder.getId())
            .customerId(savedOrder.getCustomerId())
            .amount(savedOrder.getAmount())
            .items(savedOrder.getItems())
            .timestamp(LocalDateTime.now())
            .build();
            
        eventPublisher.publish("order.created", event);
        
        return savedOrder; // Returns immediately, doesn't wait for subscribers
    }
}

// Subscriber Services (Multiple services can listen to same event)
@Component
public class InventoryService {
    
    @EventListener("order.created")
    public void handleOrderCreated(OrderCreatedEvent event) {
        log.info("Reserving inventory for order: {}", event.getOrderId());
        
        try {
            // Reserve inventory items
            event.getItems().forEach(item -> 
                inventoryRepository.reserveItem(item.getProductId(), item.getQuantity())
            );
            
            // Publish success event
            eventPublisher.publish("inventory.reserved", 
                new InventoryReservedEvent(event.getOrderId(), event.getItems()));
                
        } catch (InsufficientInventoryException e) {
            // Publish failure event
            eventPublisher.publish("inventory.reservation.failed",
                new InventoryReservationFailedEvent(event.getOrderId(), e.getMessage()));
        }
    }
}

@Component
public class EmailService {
    
    @EventListener("order.created")
    public void handleOrderCreated(OrderCreatedEvent event) {
        log.info("Sending order confirmation email for: {}", event.getOrderId());
        
        Customer customer = customerService.getCustomer(event.getCustomerId());
        
        EmailTemplate template = EmailTemplate.builder()
            .to(customer.getEmail())
            .subject("Order Confirmation - " + event.getOrderId())
            .template("order-confirmation")
            .variables(Map.of(
                "orderNumber", event.getOrderId(),
                "customerName", customer.getName(),
                "amount", event.getAmount(),
                "items", event.getItems()
            ))
            .build();
            
        emailSender.sendAsync(template);
    }
}

@Component
public class AnalyticsService {
    
    @EventListener("order.created")
    public void handleOrderCreated(OrderCreatedEvent event) {
        // Track order metrics
        meterRegistry.counter("orders.created", 
            "customer", event.getCustomerId()).increment();
            
        meterRegistry.gauge("orders.amount", event.getAmount().doubleValue());
        
        // Send to analytics pipeline
        analyticsPublisher.publish(AnalyticsEvent.builder()
            .eventType("order_created")
            .userId(event.getCustomerId())
            .properties(Map.of(
                "order_id", event.getOrderId(),
                "amount", event.getAmount(),
                "item_count", event.getItems().size()
            ))
            .build());
    }
}
```

**System Architecture:**

```html
[Order Service] ──publish──> [Message Topic: order.created] ──subscribe──> [Inventory Service]
                                        │                                  [Email Service]
                                        │                                  [Analytics Service]
                                        │                                  [Recommendation Service]
                                        └──subscribe──> [Any Future Services]
```

**Key Benefits:**

- **Complete decoupling**: Order service doesn’t know about subscribers
- **Easy to extend**: Add new subscribers without changing publisher
- **Parallel processing**: All subscribers process simultaneously
- **Failure isolation**: One subscriber failure doesn’t affect others

### Message Queue vs Topic Patterns

### Message Queue Pattern (Point-to-Point)

**What It Is:** One-to-one communication. Each message is consumed by exactly one consumer. Think of it as a **task distribution system**.

**Use Cases:**

- **Work distribution**: Image processing, report generation
- **Load balancing**: Distribute tasks across multiple workers
- **Sequential processing**: Order fulfillment pipeline
```html
// Message Queue Implementation
@Service
public class ImageProcessingService {
    private final MessageQueue<ImageProcessingTask> processingQueue;
    
    // Producer - adds tasks to queue
    public void queueImageProcessing(String imageUrl, String userId) {
        ImageProcessingTask task = ImageProcessingTask.builder()
            .imageUrl(imageUrl)
            .userId(userId)
            .taskId(UUID.randomUUID().toString())
            .timestamp(LocalDateTime.now())
            .build();
            
        processingQueue.send("image.processing.queue", task);
        log.info("Queued image processing task: {}", task.getTaskId());
    }
}

// Multiple Workers - compete for tasks
@Component
public class ImageProcessingWorker {
    
    @MessageListener("image.processing.queue")
    public void processImage(ImageProcessingTask task) {
        String workerId = getWorkerId();
        log.info("Worker {} processing task: {}", workerId, task.getTaskId());
        
        try {
            // 1. Download image
            BufferedImage image = downloadImage(task.getImageUrl());
            
            // 2. Process image (resize, filter, etc.)
            BufferedImage processed = applyFilters(image);
            
            // 3. Upload processed image
            String processedUrl = uploadProcessedImage(processed, task.getUserId());
            
            // 4. Notify completion
            notificationService.notifyImageProcessed(task.getUserId(), processedUrl);
            
            log.info("Worker {} completed task: {}", workerId, task.getTaskId());
            
        } catch (Exception e) {
            log.error("Worker {} failed to process task: {}", workerId, task.getTaskId(), e);
            
            // Send to dead letter queue for manual review
            deadLetterQueue.send(task);
        }
    }
}
```

**Message Queue Characteristics:**

- **One consumer per message**: Message is removed after consumption
- **Load balancing**: Multiple workers share the workload
- **Ordering**: FIFO processing (if configured)
- **Persistence**: Messages survive system restarts

### Topic Pattern (Publish-Subscribe)

**What It Is:** One-to-many communication. Each message is delivered to all interested subscribers. Think of it as a **broadcast system**.

**Use Cases:**

- **Event broadcasting**: System events, state changes
- **Real-time updates**: Stock prices, sports scores
- **Audit logging**: Multiple services need same event data
```html
// Topic Implementation
@Service
public class UserService {
    
    @Transactional
    public User updateUserProfile(String userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId);
        user.updateProfile(request);
        User updatedUser = userRepository.save(user);
        
        // Publish to topic - all subscribers get this event
        UserProfileUpdatedEvent event = UserProfileUpdatedEvent.builder()
            .userId(userId)
            .oldProfile(user.getProfile())
            .newProfile(updatedUser.getProfile())
            .timestamp(LocalDateTime.now())
            .build();
            
        topicPublisher.publish("user.profile.updated", event);
        
        return updatedUser;
    }
}

// Multiple subscribers - all receive the same event
@Component
public class SearchIndexService {
    @TopicListener("user.profile.updated")
    public void updateSearchIndex(UserProfileUpdatedEvent event) {
        searchIndex.updateUser(event.getUserId(), event.getNewProfile());
    }
}

@Component
public class RecommendationService {
    @TopicListener("user.profile.updated") 
    public void updateRecommendations(UserProfileUpdatedEvent event) {
        recommendationEngine.recalculateForUser(event.getUserId());
    }
}

@Component
public class AuditService {
    @TopicListener("user.profile.updated")
    public void auditProfileChange(UserProfileUpdatedEvent event) {
        auditLog.record(AuditEvent.builder()
            .entityType("User")
            .entityId(event.getUserId())
            .action("profile_updated")
            .oldValue(event.getOldProfile())
            .newValue(event.getNewProfile())
            .build());
    }
}
```

**Topic Characteristics:**

- **Multiple consumers per message**: Each subscriber gets a copy
- **Broadcasting**: All interested parties receive events
- **Durability**: Subscribers can be offline and catch up
- **Filtering**: Subscribers can filter events by criteria

### Command Pattern for Async Operations

### What It Is

**Command Pattern in async context** turns operations into message objects that can be queued, scheduled, retried, and audited. It’s the backbone of **task queue systems** and **workflow engines**.

### Async Command Implementation

```html
// Base Command Interface
public interface AsyncCommand {
    String getCommandId();
    String getCommandType();
    LocalDateTime getCreatedAt();
    int getRetryCount();
    void execute() throws CommandExecutionException;
    void onSuccess();
    void onFailure(Exception e);
    boolean canRetry();
}

// Concrete Commands
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, property = "type")
@JsonSubTypes({
    @JsonSubTypes.Type(value = ProcessOrderCommand.class, name = "PROCESS_ORDER"),
    @JsonSubTypes.Type(value = SendEmailCommand.class, name = "SEND_EMAIL"),
    @JsonSubTypes.Type(value = GenerateReportCommand.class, name = "GENERATE_REPORT")
})
public abstract class BaseAsyncCommand implements AsyncCommand {
    private final String commandId;
    private final LocalDateTime createdAt;
    private int retryCount = 0;
    
    public BaseAsyncCommand() {
        this.commandId = UUID.randomUUID().toString();
        this.createdAt = LocalDateTime.now();
    }
    
    @Override
    public boolean canRetry() {
        return retryCount < 3; // Max 3 retries
    }
    
    public void incrementRetryCount() {
        this.retryCount++;
    }
}
// Order Processing Command
public class ProcessOrderCommand extends BaseAsyncCommand {
    private final String orderId;
    private final List<OrderItem> items;
    private final PaymentDetails paymentDetails;
    
    @Override
    public String getCommandType() {
        return "PROCESS_ORDER";
    }
    
    @Override
    public void execute() throws CommandExecutionException {
        try {
            // 1. Validate inventory
            inventoryService.validateAvailability(items);
            
            // 2. Process payment
            PaymentResult payment = paymentService.processPayment(paymentDetails);
            if (!payment.isSuccess()) {
                throw new PaymentFailedException("Payment failed: " + payment.getError());
            }
            
            // 3. Reserve inventory
            String reservationId = inventoryService.reserveItems(items);
            
            // 4. Update order status
            orderService.updateOrderStatus(orderId, OrderStatus.PROCESSING, 
                Map.of("paymentId", payment.getTransactionId(),
                       "reservationId", reservationId));
                       
            // 5. Schedule fulfillment
            fulfillmentService.scheduleFulfillment(orderId);
            
        } catch (Exception e) {
            throw new CommandExecutionException("Order processing failed", e);
        }
    }
    
    @Override
    public void onSuccess() {
        log.info("Order {} processed successfully", orderId);
        
        // Publish success event
        eventPublisher.publish("order.processed", 
            new OrderProcessedEvent(orderId, LocalDateTime.now()));
    }
    
    @Override
    public void onFailure(Exception e) {
        log.error("Order {} processing failed", orderId, e);
        
        // Publish failure event
        eventPublisher.publish("order.processing.failed",
            new OrderProcessingFailedEvent(orderId, e.getMessage()));
    }
}
// Command Processor/Executor
@Component
public class AsyncCommandProcessor {
    private final MessageQueue<AsyncCommand> commandQueue;
    private final CommandRepository commandRepository;
    private final ExecutorService executorService;
    
    @PostConstruct
    public void startProcessing() {
        // Start multiple worker threads
        for (int i = 0; i < 10; i++) {
            executorService.submit(this::processCommands);
        }
    }
    
    public void submitCommand(AsyncCommand command) {
        // 1. Persist command for durability
        commandRepository.save(CommandEntity.from(command));
        
        // 2. Send to queue for processing
        commandQueue.send("async.commands", command);
        
        log.info("Submitted command: {} ({})", command.getCommandId(), command.getCommandType());
    }
    
    private void processCommands() {
        while (!Thread.currentThread().isInterrupted()) {
            try {
                AsyncCommand command = commandQueue.receive("async.commands", Duration.ofSeconds(30));
                if (command != null) {
                    processCommand(command);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }
    
    private void processCommand(AsyncCommand command) {
        String commandId = command.getCommandId();
        
        try {
            log.info("Processing command: {} ({})", commandId, command.getCommandType());
            
            // Update status to processing
            commandRepository.updateStatus(commandId, CommandStatus.PROCESSING);
            
            // Execute command
            command.execute();
            
            // Mark as completed
            commandRepository.updateStatus(commandId, CommandStatus.COMPLETED);
            command.onSuccess();
            
            log.info("Command completed: {}", commandId);
            
        } catch (Exception e) {
            log.error("Command failed: {}", commandId, e);
            
            command.onFailure(e);
            
            if (command.canRetry()) {
                // Increment retry count and requeue
                command.incrementRetryCount();
                commandQueue.send("async.commands", command);
                commandRepository.updateStatus(commandId, CommandStatus.RETRYING);
                
                log.info("Command queued for retry: {} (attempt {})", 
                         commandId, command.getRetryCount());
            } else {
                // Move to dead letter queue
                commandRepository.updateStatus(commandId, CommandStatus.FAILED);
                deadLetterQueue.send("failed.commands", command);
                
                log.error("Command permanently failed: {}", commandId);
            }
        }
    }
}
```

### Advanced Message Queue Patterns

### Dead Letter Queue (DLQ)

**What It Is:** A special queue for messages that can’t be processed after multiple attempts.

```html
@Component
public class DeadLetterQueueHandler {
    
    public void handleDeadLetter(FailedMessage message) {
        log.error("Message sent to DLQ: {} - Reason: {}", 
                  message.getMessageId(), message.getFailureReason());
        
        // Store in database for manual investigation
        deadLetterRepository.save(DeadLetterRecord.builder()
            .messageId(message.getMessageId())
            .originalQueue(message.getOriginalQueue())
            .failureReason(message.getFailureReason())
            .retryCount(message.getRetryCount())
            .payload(message.getPayload())
            .failedAt(LocalDateTime.now())
            .build());
        
        // Alert operations team
        alertService.sendAlert("Dead Letter Queue Alert", 
            "Message " + message.getMessageId() + " requires manual intervention");
    }
    
    // Manual reprocessing of DLQ messages
    public void reprocessDeadLetter(String messageId) {
        DeadLetterRecord record = deadLetterRepository.findById(messageId);
        
        // Recreate original message
        AsyncCommand command = deserializeCommand(record.getPayload());
        
        // Reset retry count
        command.resetRetryCount();
        
        // Resubmit to original queue
        commandProcessor.submitCommand(command);
        
        log.info("Reprocessing dead letter: {}", messageId);
    }
}
```

### Message Deduplication

**Why Needed:** In distributed systems, messages can be delivered multiple times. Deduplication ensures idempotent processing.

```html
@Component
public class MessageDeduplicator {
    private final RedisTemplate<String, String> redis;
    private final Duration deduplicationWindow = Duration.ofHours(24);
    
    public boolean isDuplicate(String messageId) {
        String key = "msg_dedup:" + messageId;
        
        Boolean isNew = redis.opsForValue().setIfAbsent(key, "processed", deduplicationWindow);
        
        return !Boolean.TRUE.equals(isNew);
    }
    
    @EventListener
    public void handleMessage(OrderCreatedEvent event) {
        String messageId = event.getMessageId();
        
        if (isDuplicate(messageId)) {
            log.warn("Duplicate message received: {}", messageId);
            return;
        }
        
        // Process message normally
        processOrderCreatedEvent(event);
    }
}
```

### Priority Queues

**What It Is:** Messages with different priorities are processed in priority order.

```html
public enum MessagePriority {
    LOW(1), NORMAL(5), HIGH(10), CRITICAL(20);
    
    private final int value;
}

@Component
public class PriorityQueueManager {
    private final PriorityBlockingQueue<PrioritizedCommand> priorityQueue;
    
    public void submitCommand(AsyncCommand command, MessagePriority priority) {
        PrioritizedCommand prioritizedCommand = new PrioritizedCommand(command, priority);
        priorityQueue.offer(prioritizedCommand);
    }
    
    private static class PrioritizedCommand implements Comparable<PrioritizedCommand> {
        private final AsyncCommand command;
        private final MessagePriority priority;
        
        @Override
        public int compareTo(PrioritizedCommand other) {
            return Integer.compare(other.priority.getValue(), this.priority.getValue());
        }
    }
}
```

### System Architecture: Complete Async Architecture

```html
[API Layer] ──commands──> [Command Queue] ──> [Workers] ──> [Database]
     │                                           │
     └──events──> [Event Topics] ──┬──> [Email Service]
                                   ├──> [Analytics Service] 
                                   ├──> [Search Service]
                                   └──> [Audit Service]
                                   
[Failed Messages] ──> [Dead Letter Queue] ──> [Manual Processing]
```

### Message Queue Technologies Comparison

Technology Type Use Case Pros Cons  
**RabbitMQ** Both General messaging Feature-rich, reliable Complex setup **Apache Kafka** Topic High throughput, streaming Excellent performance Operational complexity  
**Amazon SQS** Queue Simple task queues Fully managed, scalable AWS-specific  
**Redis Pub/Sub** Topic Real-time notifications Fast, simple Not persistent **Apache Pulsar** Both Multi-tenant, geo-replication Modern features Newer, less mature

### Production Best Practices

### 1\. Message Serialization

```html
// Use versioned, evolvable schemas
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, property = "@type")
public class OrderEvent {
    private String version = "v1.0";
    private String eventId;
    private LocalDateTime timestamp;
    // Event data...
    
    // Backward compatibility
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class V1 extends OrderEvent { }
}
```

### 2\. Circuit Breakers for Messaging

```html
@Component
public class ResilientMessageSender {
    private final CircuitBreaker messagingCircuitBreaker;
    
    public void sendMessage(String queue, Object message) {
        messagingCircuitBreaker.executeRunnable(() -> {
            messageQueue.send(queue, message);
        });
    }
}
```

### 3\. Monitoring and Metrics

```html
@Component
public class MessageQueueMetrics {
    
    public void recordMessageSent(String queue, String messageType) {
        meterRegistry.counter("messages.sent",
            "queue", queue,
            "type", messageType).increment();
    }
    
    public void recordProcessingTime(String queue, Duration processingTime) {
        meterRegistry.timer("message.processing.time",
            "queue", queue).record(processingTime);
    }
}
```

### Common Pitfalls and Solutions

### 1\. Message Ordering Issues

**Problem:** Messages processed out of order **Solution:** Use message keys for partitioning, single-threaded consumers for ordering

### 2\. Poison Messages

**Problem:** Malformed messages crash consumers **Solution:** Robust error handling, dead letter queues, message validation

### 3\. Memory Leaks

**Problem:** Unconsumed messages accumulate **Solution:** Set TTL on messages, monitor queue depths, implement backpressure

### Decision Framework

**Use Message Queues when:**

- ✅ Need to distribute work across multiple workers
- ✅ Require guaranteed message delivery
- ✅ Want load balancing and scaling
- ✅ Need ordered processing

**Use Topics when:**

- ✅ Need to broadcast events to multiple services
- ✅ Want loose coupling between services
- ✅ Building event-driven architectures
- ✅ Multiple consumers need same data

**Use Command Pattern when:**

- ✅ Need to audit operations
- ✅ Want to retry failed operations
- ✅ Building workflow systems
- ✅ Need to schedule operations

### Tomorrow’s Preview

Day 13: “Event Sourcing & CQRS Patterns”. How to build systems that capture every change as events and separate read/write operations for ultimate scalability.

### Your Architect Assignment

1. **Identify synchronous bottlenecks** in your system that could benefit from async processing
2. **Map your events** What domain events happen that other services care about?
3. **Find retry-worthy operations** that could be commands in queues
4. **Look for fan-out scenarios** where one action triggers multiple operations

Remember: **Message queues decouple systems in time and space. Publishers don’t wait for consumers, services can scale independently, and failures are isolated. This is how you build truly resilient distributed systems.**

*Previous articles:*

- [*Day 1 Building Your Architect Mindset*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [*Day 2 Strategy & Observer Patterns*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [*Day 3 Decorator & Proxy Patterns*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [*Day 4 Singleton & Builder Patterns*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [*Day 5 Command & Template Method Patterns*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [*Day 6 Adapter & Facade Patterns*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [*Day 7 Chain of Responsibility & State Patterns*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [*Day 8 Load Balancing & Circuit Breaker Patterns*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)
- [*Day 9 Database Patterns & Repository Pattern*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)
- [*Day 10 Caching Patterns*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)
- [*Day 11 API Gateway & Proxy Patterns*](https://archive.is/o/0Q7ky/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)

*Follow along daily as we master async communication patterns that make distributed systems resilient and scalable.*

[0%](https://archive.is/0Q7ky#0%) [10%](https://archive.is/0Q7ky#10%) [20%](https://archive.is/0Q7ky#20%) [30%](https://archive.is/0Q7ky#30%) [40%](https://archive.is/0Q7ky#40%) [50%](https://archive.is/0Q7ky#50%) [60%](https://archive.is/0Q7ky#60%) [70%](https://archive.is/0Q7ky#70%) [80%](https://archive.is/0Q7ky#80%) [90%](https://archive.is/0Q7ky#90%) [100%](https://archive.is/0Q7ky#100%)