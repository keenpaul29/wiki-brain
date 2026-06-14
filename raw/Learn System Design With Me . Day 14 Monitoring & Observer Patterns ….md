---
title: "Learn System Design With Me . Day 14: Monitoring & Observer Patterns …"
source: "https://archive.is/xZVQT"
author:
  - "[[The Latency Gambler]]"
published: 2025-10-06
created: 2026-06-14
description:
tags:
  - "clippings"
---
## Learn System Design With Me. Day 14: Monitoring & Observer Patterns

## Building Observable Systems

*This is Day 14 of our 30-day journey from code writer to system architect. Start with* [*Day 1*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build the foundation, then progress through* [*Day 2*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*,* [*Day 3*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*,* [*Day 4*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*,* [*Day 5*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*,* [*Day 6*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*,* [*Day 7*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)*,* [*Day 8*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)*,* [*Day 9*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)*,* [*Day 10*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)*,* [*Day 11*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)*,* [*Day 12*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)*, and* [*Day 13*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)

We’ve mastered event-driven architectures. Today, we tackle **observability**: **Monitoring and Observer Patterns**. This is how you know what’s happening inside your distributed systems when things go wrong at 3 AM.

![](https://da0c3dvm83g2zy.archive.is/xZVQT/4f5e6833c6d5f12727024817bd416ffabf994016.webp)

Here’s the architect reality: **You can’t fix what you can’t see. Observable systems tell you what’s broken, where it’s broken, and why it’s broken before your users complain.**

### Why Observability Matters

### The Distributed Systems Problem

In microservices architectures:

- **Requests span multiple services**: One API call touches 5+ services
- **Failures cascade unpredictably**: Service A timeout causes Service B overload
- **Performance issues hide**: Slow database queries affect entire system
- **Root cause analysis is hard**: Where did the problem actually start?

### The Three Pillars of Observability

1. **Logs**: What happened (events, errors, debug info)
2. **Metrics**: How much/how fast (counters, gauges, histograms)
3. **Traces**: Where requests go (distributed request tracing)

### Observer Pattern for System Monitoring

### What It Is

**Observer pattern in monitoring** means your system components notify interested monitoring systems about events, state changes, and performance metrics automatically.

### Basic Monitoring Observer Implementation

```html
// Monitoring Event Interface
public interface MonitoringEvent {
    String getEventType();
    LocalDateTime getTimestamp();
    Map<String, Object> getAttributes();
    String getServiceName();
}

// Concrete Events
public class RequestProcessedEvent implements MonitoringEvent {
    private final String endpoint;
    private final int statusCode;
    private final long durationMs;
    private final String userId;
    private final LocalDateTime timestamp;
    
    public RequestProcessedEvent(String endpoint, int statusCode, 
                               long durationMs, String userId) {
        this.endpoint = endpoint;
        this.statusCode = statusCode;
        this.durationMs = durationMs;
        this.userId = userId;
        this.timestamp = LocalDateTime.now();
    }
    
    @Override
    public Map<String, Object> getAttributes() {
        return Map.of(
            "endpoint", endpoint,
            "status_code", statusCode,
            "duration_ms", durationMs,
            "user_id", userId != null ? userId : "anonymous"
        );
    }
    
    @Override
    public String getEventType() { return "request_processed"; }
    
    @Override
    public String getServiceName() { return "user-service"; }
}
public class ErrorOccurredEvent implements MonitoringEvent {
    private final String errorType;
    private final String errorMessage;
    private final String stackTrace;
    private final String contextInfo;
    private final LocalDateTime timestamp;
    
    // Constructor and implementations...
}
// Monitoring Observer Interface
public interface MonitoringObserver {
    void onEvent(MonitoringEvent event);
    String getObserverName();
    boolean shouldProcess(MonitoringEvent event);
}
// Metrics Observer
@Component
public class MetricsObserver implements MonitoringObserver {
    private final MeterRegistry meterRegistry;
    
    @Override
    public void onEvent(MonitoringEvent event) {
        switch (event.getEventType()) {
            case "request_processed":
                handleRequestProcessed(event);
                break;
            case "error_occurred":
                handleErrorOccurred(event);
                break;
            case "cache_hit":
            case "cache_miss":
                handleCacheEvent(event);
                break;
        }
    }
    
    private void handleRequestProcessed(MonitoringEvent event) {
        Map<String, Object> attrs = event.getAttributes();
        
        // Counter - total requests
        meterRegistry.counter("http.requests.total",
            "endpoint", (String) attrs.get("endpoint"),
            "status", String.valueOf(attrs.get("status_code")))
            .increment();
        
        // Timer - request duration
        meterRegistry.timer("http.request.duration",
            "endpoint", (String) attrs.get("endpoint"))
            .record((Long) attrs.get("duration_ms"), TimeUnit.MILLISECONDS);
        
        // Gauge - active users
        if (attrs.get("user_id") != null) {
            meterRegistry.gauge("active.users", getActiveUserCount());
        }
    }
    
    private void handleErrorOccurred(MonitoringEvent event) {
        Map<String, Object> attrs = event.getAttributes();
        
        meterRegistry.counter("errors.total",
            "error_type", (String) attrs.get("error_type"),
            "service", event.getServiceName())
            .increment();
    }
    
    @Override
    public boolean shouldProcess(MonitoringEvent event) {
        return true; // Process all events
    }
    
    @Override
    public String getObserverName() { return "MetricsObserver"; }
}
// Logging Observer
@Component
public class LoggingObserver implements MonitoringObserver {
    private final Logger log = LoggerFactory.getLogger(LoggingObserver.class);
    
    @Override
    public void onEvent(MonitoringEvent event) {
        String logMessage = buildLogMessage(event);
        
        switch (event.getEventType()) {
            case "error_occurred":
                log.error(logMessage);
                break;
            case "warning_issued":
                log.warn(logMessage);
                break;
            default:
                log.info(logMessage);
        }
    }
    
    private String buildLogMessage(MonitoringEvent event) {
        StringBuilder sb = new StringBuilder();
        sb.append("[").append(event.getServiceName()).append("] ");
        sb.append(event.getEventType().toUpperCase()).append(" - ");
        
        Map<String, Object> attrs = event.getAttributes();
        attrs.forEach((key, value) -> 
            sb.append(key).append("=").append(value).append(" "));
            
        return sb.toString();
    }
    
    @Override
    public boolean shouldProcess(MonitoringEvent event) {
        // Only log errors and warnings in production
        return isProd() ? 
            List.of("error_occurred", "warning_issued").contains(event.getEventType()) :
            true;
    }
    
    @Override
    public String getObserverName() { return "LoggingObserver"; }
}
// Monitoring Event Publisher
@Component
public class MonitoringEventPublisher {
    private final List<MonitoringObserver> observers = new CopyOnWriteArrayList<>();
    private final ExecutorService asyncExecutor = Executors.newFixedThreadPool(5);
    
    @Autowired
    public void setObservers(List<MonitoringObserver> observers) {
        this.observers.addAll(observers);
        log.info("Registered {} monitoring observers: {}", 
                observers.size(),
                observers.stream().map(MonitoringObserver::getObserverName)
                        .collect(Collectors.joining(", ")));
    }
    
    public void publish(MonitoringEvent event) {
        // Async processing to not block main thread
        asyncExecutor.submit(() -> {
            for (MonitoringObserver observer : observers) {
                try {
                    if (observer.shouldProcess(event)) {
                        observer.onEvent(event);
                    }
                } catch (Exception e) {
                    log.error("Observer {} failed to process event", 
                             observer.getObserverName(), e);
                }
            }
        });
    }
    
    @PreDestroy
    public void shutdown() {
        asyncExecutor.shutdown();
    }
}
```

### Logs, Metrics, and Traces Patterns

### Structured Logging Pattern

**Why structured logs:** Machine-readable logs enable better searching, filtering, and analysis.

```html
@Component
public class StructuredLogger {
    private final ObjectMapper objectMapper;
    private final Logger logger = LoggerFactory.getLogger(StructuredLogger.class);
    
    public void logRequest(HttpServletRequest request, HttpServletResponse response, 
                          long durationMs) {
        LogEvent logEvent = LogEvent.builder()
            .timestamp(Instant.now())
            .level("INFO")
            .service("user-service")
            .traceId(MDC.get("traceId"))
            .spanId(MDC.get("spanId"))
            .event("http_request")
            .attributes(Map.of(
                "method", request.getMethod(),
                "uri", request.getRequestURI(),
                "status", response.getStatus(),
                "duration_ms", durationMs,
                "user_agent", request.getHeader("User-Agent"),
                "client_ip", getClientIP(request)
            ))
            .build();
            
        try {
            String jsonLog = objectMapper.writeValueAsString(logEvent);
            logger.info(jsonLog);
        } catch (Exception e) {
            logger.error("Failed to serialize log event", e);
        }
    }
    
    public void logError(String operation, Exception error, Map<String, Object> context) {
        LogEvent logEvent = LogEvent.builder()
            .timestamp(Instant.now())
            .level("ERROR")
            .service("user-service")
            .traceId(MDC.get("traceId"))
            .event("error_occurred")
            .attributes(Map.of(
                "operation", operation,
                "error_type", error.getClass().getSimpleName(),
                "error_message", error.getMessage(),
                "stack_trace", getStackTrace(error)
            ))
            .context(context)
            .build();
            
        try {
            logger.error(objectMapper.writeValueAsString(logEvent));
        } catch (Exception e) {
            logger.error("Logging failed for operation: " + operation, e);
        }
    }
}

// Log Event Structure
@Data
@Builder
public class LogEvent {
    private Instant timestamp;
    private String level;
    private String service;
    private String traceId;
    private String spanId;
    private String event;
    private Map<String, Object> attributes;
    private Map<String, Object> context;
}
```

### Metrics Collection Pattern

**Why metrics:** Quantitative data about system behavior, performance, and business KPIs.

```html
@Component
public class ApplicationMetrics {
    private final MeterRegistry meterRegistry;
    private final Counter requestsTotal;
    private final Timer requestDuration;
    private final Gauge activeConnections;
    private final DistributionSummary payloadSize;
    
    @Autowired
    public ApplicationMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        
        // Counter - monotonically increasing
        this.requestsTotal = Counter.builder("http.requests.total")
            .description("Total number of HTTP requests")
            .register(meterRegistry);
            
        // Timer - measures duration and provides rate
        this.requestDuration = Timer.builder("http.request.duration")
            .description("HTTP request duration")
            .register(meterRegistry);
            
        // Gauge - current value that can go up/down
        this.activeConnections = Gauge.builder("http.connections.active")
            .description("Active HTTP connections")
            .register(meterRegistry, this, ApplicationMetrics::getActiveConnectionCount);
            
        // Distribution Summary - tracks distribution of values
        this.payloadSize = DistributionSummary.builder("http.payload.size")
            .description("HTTP payload sizes")
            .baseUnit("bytes")
            .register(meterRegistry);
    }
    
    public void recordRequest(String endpoint, int statusCode, long durationMs, int payloadBytes) {
        // Record multiple metrics from single event
        requestsTotal.increment(
            Tags.of(
                "endpoint", endpoint,
                "status", String.valueOf(statusCode),
                "status_class", statusCode < 400 ? "success" : "error"
            )
        );
        
        requestDuration.record(durationMs, TimeUnit.MILLISECONDS,
            Tags.of("endpoint", endpoint));
            
        payloadSize.record(payloadBytes);
    }
    
    public void recordBusinessMetric(String operation, double value, String...tags) {
        meterRegistry.counter("business.operations.total", tags).increment();
        meterRegistry.gauge("business.operation.value", Tags.of(tags), value);
    }
    
    // Custom gauge function
    private double getActiveConnectionCount() {
        // Return current active connection count
        return ThreadPoolTaskExecutor.getActiveCount();
    }
}
```

### Distributed Tracing Pattern

**Why tracing:** Track requests across multiple services to understand request flows and find bottlenecks.

```html
@Component
public class DistributedTracing {
    private final Tracer tracer;
    
    public <T> T traceOperation(String operationName, Supplier<T> operation) {
        Span span = tracer.nextSpan()
            .name(operationName)
            .tag("service.name", "user-service")
            .start();
            
        try (Tracer.SpanInScope ws = tracer.withSpanInScope(span)) {
            T result = operation.get();
            
            span.tag("operation.result", "success");
            return result;
            
        } catch (Exception e) {
            span.tag("operation.result", "error");
            span.tag("error.type", e.getClass().getSimpleName());
            span.tag("error.message", e.getMessage());
            throw e;
        } finally {
            span.end();
        }
    }
    
    public void traceAsyncOperation(String operationName, Runnable operation) {
        Span span = tracer.nextSpan()
            .name(operationName)
            .start();
            
        CompletableFuture.runAsync(() -> {
            try (Tracer.SpanInScope ws = tracer.withSpanInScope(span)) {
                operation.run();
                span.tag("operation.result", "success");
            } catch (Exception e) {
                span.tag("operation.result", "error");
                span.tag("error", e.getMessage());
            } finally {
                span.end();
            }
        });
    }
}

// Usage in Service Layer
@Service
public class UserService {
    private final DistributedTracing tracing;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    
    public User createUser(CreateUserRequest request) {
        return tracing.traceOperation("user.create", () -> {
            
            // Child span for database operation
            User user = tracing.traceOperation("user.database.save", () -> {
                return userRepository.save(User.fromRequest(request));
            });
            
            // Async span for notification (doesn't block main flow)
            tracing.traceAsyncOperation("user.notification.send", () -> {
                notificationService.sendWelcomeEmail(user.getEmail());
            });
            
            return user;
        });
    }
}
```

### Alerting and Notification Systems

### Alerting Observer Pattern

**Why alerting:** Proactive notifications when systems deviate from expected behavior.

```html
// Alert Condition Interface
public interface AlertCondition {
    String getConditionName();
    boolean shouldAlert(MonitoringEvent event);
    AlertSeverity getSeverity();
    String getAlertMessage(MonitoringEvent event);
}

// Concrete Alert Conditions
public class HighErrorRateCondition implements AlertCondition {
    private final SlidingWindow errorRateWindow;
    private final double threshold;
    
    public HighErrorRateCondition(double threshold) {
        this.threshold = threshold;
        this.errorRateWindow = new SlidingWindow(Duration.ofMinutes(5));
    }
    
    @Override
    public boolean shouldAlert(MonitoringEvent event) {
        if ("request_processed".equals(event.getEventType())) {
            Map<String, Object> attrs = event.getAttributes();
            int statusCode = (Integer) attrs.get("status_code");
            
            errorRateWindow.addDataPoint(statusCode >= 400 ? 1.0 : 0.0);
            
            double errorRate = errorRateWindow.getAverage();
            return errorRate > threshold;
        }
        return false;
    }
    
    @Override
    public String getAlertMessage(MonitoringEvent event) {
        double currentErrorRate = errorRateWindow.getAverage() * 100;
        return String.format("High error rate detected: %.2f%% (threshold: %.2f%%)", 
                           currentErrorRate, threshold * 100);
    }
    
    @Override
    public AlertSeverity getSeverity() { return AlertSeverity.WARNING; }
    
    @Override
    public String getConditionName() { return "HighErrorRate"; }
}
public class ServiceDownCondition implements AlertCondition {
    private final Map<String, LocalDateTime> lastSeenTimes = new ConcurrentHashMap<>();
    private final Duration timeout = Duration.ofMinutes(2);
    
    @Override
    public boolean shouldAlert(MonitoringEvent event) {
        String serviceName = event.getServiceName();
        LocalDateTime now = LocalDateTime.now();
        
        // Update last seen time for service
        lastSeenTimes.put(serviceName, now);
        
        // Check if any services haven't been seen recently
        return lastSeenTimes.entrySet().stream()
            .anyMatch(entry -> Duration.between(entry.getValue(), now).compareTo(timeout) > 0);
    }
    
    @Override
    public String getAlertMessage(MonitoringEvent event) {
        LocalDateTime now = LocalDateTime.now();
        List<String> downServices = lastSeenTimes.entrySet().stream()
            .filter(entry -> Duration.between(entry.getValue(), now).compareTo(timeout) > 0)
            .map(Map.Entry::getKey)
            .collect(Collectors.toList());
            
        return "Services appear to be down: " + String.join(", ", downServices);
    }
    
    @Override
    public AlertSeverity getSeverity() { return AlertSeverity.CRITICAL; }
    
    @Override
    public String getConditionName() { return "ServiceDown"; }
}
// Alerting Observer
@Component
public class AlertingObserver implements MonitoringObserver {
    private final List<AlertCondition> alertConditions;
    private final NotificationService notificationService;
    private final AlertHistoryService alertHistoryService;
    
    @Override
    public void onEvent(MonitoringEvent event) {
        for (AlertCondition condition : alertConditions) {
            try {
                if (condition.shouldAlert(event)) {
                    Alert alert = Alert.builder()
                        .alertId(UUID.randomUUID().toString())
                        .conditionName(condition.getConditionName())
                        .severity(condition.getSeverity())
                        .message(condition.getAlertMessage(event))
                        .serviceName(event.getServiceName())
                        .timestamp(LocalDateTime.now())
                        .triggeringEvent(event)
                        .build();
                        
                    handleAlert(alert);
                }
            } catch (Exception e) {
                log.error("Alert condition {} failed", condition.getConditionName(), e);
            }
        }
    }
    
    private void handleAlert(Alert alert) {
        // Prevent alert spam
        if (alertHistoryService.wasRecentlyTriggered(alert.getConditionName(), Duration.ofMinutes(10))) {
            log.debug("Suppressing duplicate alert: {}", alert.getConditionName());
            return;
        }
        
        // Store alert history
        alertHistoryService.recordAlert(alert);
        
        // Send notifications based on severity
        switch (alert.getSeverity()) {
            case CRITICAL:
                notificationService.sendSMS(alert);
                notificationService.sendEmail(alert);
                notificationService.sendSlack(alert);
                break;
            case WARNING:
                notificationService.sendEmail(alert);
                notificationService.sendSlack(alert);
                break;
            case INFO:
                notificationService.sendSlack(alert);
                break;
        }
        
        log.info("Alert triggered: {} - {}", alert.getConditionName(), alert.getMessage());
    }
    
    @Override
    public boolean shouldProcess(MonitoringEvent event) {
        return true;
    }
    
    @Override
    public String getObserverName() { return "AlertingObserver"; }
}
```

### Multi-Channel Notification System

```html
public interface NotificationChannel {
    void sendNotification(Alert alert);
    String getChannelName();
    boolean isAvailable();
}

@Component
public class SlackNotificationChannel implements NotificationChannel {
    private final SlackClient slackClient;
    
    @Override
    public void sendNotification(Alert alert) {
        String emoji = getEmojiForSeverity(alert.getSeverity());
        String color = getColorForSeverity(alert.getSeverity());
        
        SlackMessage message = SlackMessage.builder()
            .channel("#alerts")
            .username("MonitoringBot")
            .text(emoji + " " + alert.getMessage())
            .attachment(SlackAttachment.builder()
                .color(color)
                .title("Alert Details")
                .fields(List.of(
                    SlackField.builder().title("Service").value(alert.getServiceName()).build(),
                    SlackField.builder().title("Severity").value(alert.getSeverity().name()).build(),
                    SlackField.builder().title("Time").value(alert.getTimestamp().toString()).build()
                ))
                .build())
            .build();
            
        slackClient.sendMessage(message);
    }
    
    @Override
    public String getChannelName() { return "Slack"; }
    
    @Override
    public boolean isAvailable() {
        return slackClient.isConnected();
    }
}
@Component
public class EmailNotificationChannel implements NotificationChannel {
    private final EmailService emailService;
    
    @Override
    public void sendNotification(Alert alert) {
        EmailTemplate template = EmailTemplate.builder()
            .to(getAlertingEmailList(alert.getSeverity()))
            .subject(String.format("[%s] %s Alert: %s", 
                                 alert.getSeverity().name(),
                                 alert.getServiceName(),
                                 alert.getConditionName()))
            .template("alert-notification")
            .variables(Map.of(
                "alertMessage", alert.getMessage(),
                "serviceName", alert.getServiceName(),
                "severity", alert.getSeverity().name(),
                "timestamp", alert.getTimestamp(),
                "alertId", alert.getAlertId()
            ))
            .build();
            
        emailService.sendAsync(template);
    }
    
    private List<String> getAlertingEmailList(AlertSeverity severity) {
        return switch (severity) {
            case CRITICAL -> List.of("oncall@company.com", "engineering@company.com");
            case WARNING -> List.of("engineering@company.com");
            case INFO -> List.of("devops@company.com");
        };
    }
    
    @Override
    public String getChannelName() { return "Email"; }
    
    @Override
    public boolean isAvailable() { return true; }
}
```

### System Architecture: Complete Observability Stack

```html
[Application Layer] ──┬─> [Monitoring Events] ──> [Event Publisher] ──┬─> [Metrics Observer] ──> [Prometheus/Grafana]
                      │                                                ├─> [Logging Observer] ──> [ELK Stack]
                      ├─> [Distributed Traces] ──> [Jaeger/Zipkin]     ├─> [Alerting Observer] ──> [Notification Channels]
                      │                                                └─> [Custom Observers]
                      └─> [Health Checks] ──> [Service Registry]

[Dashboards] ←── [Grafana] ←── [Prometheus] ←── [Metrics]
[Log Search] ←── [Kibana] ←── [Elasticsearch] ←── [Logs]  
[Trace Analysis] ←── [Jaeger UI] ←── [Jaeger] ←── [Traces]
[Alerts] ←── [AlertManager] ←── [Alert Rules] ←── [Metrics/Logs]
```

### Production Considerations

### Performance Impact

```html
@Component
public class HighPerformanceMonitoring {
    private final RingBuffer<MonitoringEvent> eventBuffer;
    private final DisruptorEventProcessor processor;
    
    // Use lock-free data structures for high-throughput
    public void publishEvent(MonitoringEvent event) {
        long sequence = eventBuffer.next();
        try {
            MonitoringEvent bufferedEvent = eventBuffer.get(sequence);
            bufferedEvent.copyFrom(event);
        } finally {
            eventBuffer.publish(sequence);
        }
    }
    
    // Sampling for high-volume events
    private final Sampler requestSampler = new RateLimitingSampler(1000); // 1000 events/second
    
    public void recordRequest(HttpServletRequest request, long duration) {
        if (requestSampler.shouldSample()) {
            publishEvent(new RequestProcessedEvent(request, duration));
        }
    }
}
```

### Resource Management

```html
@Component
public class ResourceAwareMonitoring {
    private final AtomicLong pendingEvents = new AtomicLong(0);
    private final int maxPendingEvents = 10000;
    
    public void publishEvent(MonitoringEvent event) {
        if (pendingEvents.get() > maxPendingEvents) {
            // Drop events to prevent memory issues
            log.warn("Dropping monitoring event due to backpressure");
            return;
        }
        
        pendingEvents.incrementAndGet();
        
        asyncExecutor.submit(() -> {
            try {
                processEvent(event);
            } finally {
                pendingEvents.decrementAndGet();
            }
        });
    }
}
```

### Decision Framework

### When to Use Each Pattern:

**Observer Pattern for Monitoring:**

- Real-time event processing needed
- Multiple consumers of same monitoring data
- Decoupled monitoring from business logic
- Custom alerting and analytics required

**Structured Logging:**

- Machine-readable logs needed
- Log aggregation and searching required
- Compliance and audit trails needed
- Correlation across distributed services

**Metrics Collection:**

- Quantitative system performance data
- Business KPI tracking
- Alerting based on thresholds
- Historical trend analysis

**Distributed Tracing:**

- Multi-service request flows
- Performance bottleneck identification
- Service dependency mapping
- Error propagation analysis

### Common Pitfalls

1. **Over-monitoring**: Too many metrics create noise
2. **Under-sampling**: Missing important events in high-traffic systems
3. **Blocking monitoring**: Monitoring slows down main application
4. **Alert fatigue**: Too many false positives reduce alert effectiveness
5. **Missing context**: Events without sufficient context for debugging

### Tomorrow’s Preview

Day 15: “Microservices Patterns” Service Registry & Discovery patterns, API Gateway pattern implementation, and Bulkhead pattern for service isolation.

### Your Architect Assignment

1. **Audit your current monitoring**: What events are you missing?
2. **Identify critical alerts**: What would you want to know at 3 AM?
3. **Map your request flows**: Where do requests go across services?
4. **Check monitoring performance**: Is observability slowing your system?

Remember: **Observable systems are debuggable systems. The Observer pattern makes monitoring event-driven and decoupled. Logs tell you what happened, metrics tell you how much, traces tell you where. Together, they give you complete system visibility.**

*Previous articles:*

- [*Day 1 Building Your Architect Mindset*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [*Day 2 Strategy & Observer Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [*Day 3 Decorator & Proxy Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [*Day 4 Singleton & Builder Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [*Day 5 Command & Template Method Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [*Day 6 Adapter & Facade Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [*Day 7 Chain of Responsibility & State Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [*Day 8 Load Balancing & Circuit Breaker Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)
- [*Day 9 Database Patterns & Repository Pattern*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)
- [*Day 10 Caching Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)
- [*Day 11 API Gateway & Proxy Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)
- [*Day 12 Message Queue Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)
- [*Day 13 Event Sourcing & CQRS Patterns*](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)

*Follow along daily as we master the observability patterns that make distributed systems debuggable and reliable.*

## Responses (1)

Write a response[What are your thoughts?](https://archive.is/o/xZVQT/https://medium.com/@kanishks772/learn-system-design-with-me-day-14-monitoring-observer-patterns-cdd2bba68d9f)

```html
Slow database queries silently affecting the entire system really highlight why proactive observability matters so much.
```

[0%](https://archive.is/xZVQT#0%) [10%](https://archive.is/xZVQT#10%) [20%](https://archive.is/xZVQT#20%) [30%](https://archive.is/xZVQT#30%) [40%](https://archive.is/xZVQT#40%) [50%](https://archive.is/xZVQT#50%) [60%](https://archive.is/xZVQT#60%) [70%](https://archive.is/xZVQT#70%) [80%](https://archive.is/xZVQT#80%) [90%](https://archive.is/xZVQT#90%) [100%](https://archive.is/xZVQT#100%)