---
title: "Learn System Design With Me . Day 4: Singleton & Builder Patterns (The Right Way) | by The Latency Gambler"
source: "https://freedium-mirror.cfd/medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4"
author:
  - "[[The Latency Gambler]]"
published:
created: 2026-05-26
description: "This is Day 4 of our 30-day journey from code writer to system architect. Start with Day 1, then..."
tags:
  - "clippings"
---
[< Go to the original](https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/0*yc6xs3ueTD_F1uyY)

## Learn System Design With Me. Day 4: Singleton & Builder Patterns (The Right Way)

## This is Day 4 of our 30-day journey from code writer to system architect. Start with Day 1, then Day 2, and Day 3

a11y-light · September 16, 2025 (Updated: September 16, 2025) · Free: No

We've covered behavioral patterns (Strategy, Observer) and structural patterns (Decorator, Proxy). Today, we tackle two **creational patterns** that are either loved or hated by architects: **Singleton and Builder**.

Here's the reality check: **Most developers implement these patterns wrong.** Singleton becomes a global variable nightmare, and Builder becomes boilerplate hell. But when done right, they're powerful system design tools.

Let me show you the architect's way.

#### Singleton Pattern: The Double-Edged Sword

#### The Problem It Actually Solves

Everyone says "one instance." That's the kindergarten explanation. **The real problem**: You need **consistent global state** or **expensive resource management** database connection pools, configuration managers, logging systems.

#### The Wrong Way (What Most Do)

```csharp
// DON'T DO THIS - Classic mistakes
public class DatabaseConnection {
    private static DatabaseConnection instance;
    
    private DatabaseConnection() {}
    
    public static DatabaseConnection getInstance() {
        if (instance == null) { // Thread safety issue!
            instance = new DatabaseConnection();
        }
        return instance;
    }
}
```

> **Problems**: Thread unsafe, breaks with serialization, reflection can destroy it, testing nightmare.

#### The Right Way: Thread-Safe Implementations

#### 1\. Enum Singleton (Joshua Bloch's Recommendation)

```typescript
// BEST PRACTICE - Handles everything automatically
public enum ConfigurationManager {
    INSTANCE;
    
    private final Properties config;
    
    ConfigurationManager() {
        config = loadConfiguration();
    }
    
    public String getProperty(String key) {
        return config.getProperty(key);
    }
    
    public void setProperty(String key, String value) {
        config.setProperty(key, value);
        persistConfiguration(); // Save to file/database
    }
    
    private Properties loadConfiguration() {
        // Load from application.yml, database, etc.
        return new Properties();
    }
}

// Usage
String dbUrl = ConfigurationManager.INSTANCE.getProperty("database.url");
```

**Why Enum is Perfect**:

- Thread-safe by default
- Serialization handled automatically
- Reflection can't break it
- JVM guarantees single instance

#### 2\. Lazy Initialization (When Enum Isn't Suitable)

```java
public class DatabaseConnectionPool {
    private static class Holder {
        private static final DatabaseConnectionPool INSTANCE = new DatabaseConnectionPool();
    }
    
    private final HikariDataSource dataSource;
    
    private DatabaseConnectionPool() {
        // Expensive initialization
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(ConfigurationManager.INSTANCE.getProperty("db.url"));
        config.setMaximumPoolSize(20);
        config.setConnectionTimeout(30000);
        this.dataSource = new HikariDataSource(config);
    }
    
    public static DatabaseConnectionPool getInstance() {
        return Holder.INSTANCE; // Lazy + thread-safe
    }
    
    public Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }
    
    // Handle serialization properly
    private Object readResolve() {
        return getInstance();
    }
}
```

#### System Architecture: Singleton in Distributed Systems

```
[Service A] ──┐
              ├─ [Configuration Manager Singleton]
[Service B] ──┤
              ├─ [Connection Pool Singleton]
[Service C] ──┘
```

> **Architecture Challenge**: In microservices, "single instance per JVM" breaks down. Use **external configuration stores** (Consul, etcd, Spring Cloud Config).

#### Singleton with Dependency Injection (Spring Way)

```java
// Spring manages singleton lifecycle
@Component
@Scope("singleton") // Default scope
public class MetricsCollector {
    private final MeterRegistry meterRegistry;
    private final ConcurrentMap<String, Counter> counters = new ConcurrentHashMap<>();
    
    @Autowired
    public MetricsCollector(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }
    
    public void increment(String metricName) {
        counters.computeIfAbsent(metricName, 
            name -> Counter.builder(name).register(meterRegistry))
            .increment();
    }
}

// Usage - Spring injects the same instance everywhere
@Service
public class PaymentService {
    private final MetricsCollector metrics; // Same instance across app
    
    public PaymentService(MetricsCollector metrics) {
        this.metrics = metrics;
    }
}
```

#### Builder Pattern: Complex Object Assembly

#### The Problem It Solves

Creating complex objects with many optional parameters. Traditional constructors become unreadable and error-prone.

```typescript
// The Telescope Constructor Anti-Pattern
public class DatabaseConfig {
    public DatabaseConfig(String url, String username, String password, 
                         int maxConnections, int timeout, boolean autoCommit, 
                         String validationQuery, boolean testOnBorrow, 
                         int maxWait, String driverClass) {
        // Which parameter is which? Easy to mix up!
    }
}
```

#### The Right Way: Fluent Builder

```kotlin
public class DatabaseConfig {
    private final String url;
    private final String username;
    private final String password;
    private final int maxConnections;
    private final int connectionTimeout;
    private final boolean autoCommit;
    private final String validationQuery;
    private final boolean testOnBorrow;
    
    private DatabaseConfig(Builder builder) {
        // Validation during construction
        if (builder.url == null || builder.url.trim().isEmpty()) {
            throw new IllegalArgumentException("Database URL cannot be null or empty");
        }
        if (builder.maxConnections <= 0) {
            throw new IllegalArgumentException("Max connections must be positive");
        }
        
        this.url = builder.url;
        this.username = builder.username;
        this.password = builder.password;
        this.maxConnections = builder.maxConnections;
        this.connectionTimeout = builder.connectionTimeout;
        this.autoCommit = builder.autoCommit;
        this.validationQuery = builder.validationQuery;
        this.testOnBorrow = builder.testOnBorrow;
    }
    
    public static class Builder {
        // Required parameters
        private final String url;
        private final String username;
        private final String password;
        
        // Optional parameters with defaults
        private int maxConnections = 10;
        private int connectionTimeout = 30000;
        private boolean autoCommit = true;
        private String validationQuery = "SELECT 1";
        private boolean testOnBorrow = true;
        
        public Builder(String url, String username, String password) {
            this.url = url;
            this.username = username;
            this.password = password;
        }
        
        public Builder maxConnections(int maxConnections) {
            this.maxConnections = maxConnections;
            return this;
        }
        
        public Builder connectionTimeout(int timeout) {
            this.connectionTimeout = timeout;
            return this;
        }
        
        public Builder autoCommit(boolean autoCommit) {
            this.autoCommit = autoCommit;
            return this;
        }
        
        public Builder validationQuery(String query) {
            this.validationQuery = query;
            return this;
        }
        
        public DatabaseConfig build() {
            return new DatabaseConfig(this);
        }
    }
    
    // Getters...
    public String getUrl() { return url; }
    public int getMaxConnections() { return maxConnections; }
}

// Usage - Clean and readable
DatabaseConfig config = new DatabaseConfig.Builder(
        "jdbc:postgresql://localhost:5432/mydb", 
        "user", 
        "password")
    .maxConnections(20)
    .connectionTimeout(60000)
    .autoCommit(false)
    .build();
```

#### Advanced Builder: Self-Referential Generics

```kotlin
// Handles inheritance elegantly
public abstract class BaseHttpClient {
    protected final String baseUrl;
    protected final Map<String, String> headers;
    protected final int timeout;
    
    protected BaseHttpClient(BaseBuilder<?> builder) {
        this.baseUrl = builder.baseUrl;
        this.headers = new HashMap<>(builder.headers);
        this.timeout = builder.timeout;
    }
    
    public abstract static class BaseBuilder<T extends BaseBuilder<T>> {
        protected String baseUrl;
        protected Map<String, String> headers = new HashMap<>();
        protected int timeout = 30000;
        
        @SuppressWarnings("unchecked")
        protected T self() {
            return (T) this;
        }
        
        public T baseUrl(String baseUrl) {
            this.baseUrl = baseUrl;
            return self();
        }
        
        public T header(String name, String value) {
            this.headers.put(name, value);
            return self();
        }
        
        public T timeout(int timeout) {
            this.timeout = timeout;
            return self();
        }
    }
}

public class RestHttpClient extends BaseHttpClient {
    private final ObjectMapper objectMapper;
    
    private RestHttpClient(Builder builder) {
        super(builder);
        this.objectMapper = builder.objectMapper;
    }
    
    public static class Builder extends BaseBuilder<Builder> {
        private ObjectMapper objectMapper = new ObjectMapper();
        
        public Builder objectMapper(ObjectMapper mapper) {
            this.objectMapper = mapper;
            return this;
        }
        
        public RestHttpClient build() {
            return new RestHttpClient(this);
        }
    }
}

// Usage - Inheritance works perfectly
RestHttpClient client = new RestHttpClient.Builder()
    .baseUrl("https://api.example.com")  // From base class
    .header("Authorization", "Bearer " + token)  // From base class
    .timeout(60000)  // From base class
    .objectMapper(customMapper)  // From derived class
    .build();
```

#### Lombok @Builder: Boilerplate Elimination

```dart
import lombok.Builder;
import lombok.Value;

@Value // Immutable
@Builder
public class ApiConfig {
    String baseUrl;
    String apiKey;
    
    @Builder.Default
    int timeout = 30000;
    
    @Builder.Default
    int retryCount = 3;
    
    @Builder.Default
    Map<String, String> headers = new HashMap<>();
}

// Usage - Zero boilerplate
ApiConfig config = ApiConfig.builder()
    .baseUrl("https://api.service.com")
    .apiKey("secret-key")
    .timeout(60000)
    .build();
```

#### Modern Java: Records + Builder

```typescript
public record ServerConfig(
    String host,
    int port,
    boolean ssl,
    Map<String, String> properties
) {
    // Compact constructor for validation
    public ServerConfig {
        if (port <= 0) {
            throw new IllegalArgumentException("Port must be positive");
        }
        properties = Map.copyOf(properties); // Defensive copy
    }
    
    public static class Builder {
        private String host = "localhost";
        private int port = 8080;
        private boolean ssl = false;
        private Map<String, String> properties = new HashMap<>();
        
        public Builder host(String host) {
            this.host = host;
            return this;
        }
        
        public Builder port(int port) {
            this.port = port;
            return this;
        }
        
        public Builder ssl(boolean ssl) {
            this.ssl = ssl;
            return this;
        }
        
        public Builder property(String key, String value) {
            this.properties.put(key, value);
            return this;
        }
        
        public ServerConfig build() {
            return new ServerConfig(host, port, ssl, properties);
        }
    }
}
```

#### System Architecture: Configuration Management

```
[Application Startup] → [Configuration Builder] → [Singleton Config Manager] → [Services]
// Combining Singleton + Builder for system configuration
public enum SystemConfiguration {
    INSTANCE;
    
    private final DatabaseConfig dbConfig;
    private final RedisConfig redisConfig;
    private final ApiConfig apiConfig;
    
    SystemConfiguration() {
        // Build configurations from various sources
        this.dbConfig = new DatabaseConfig.Builder(
                getEnv("DB_URL"),
                getEnv("DB_USER"),
                getEnv("DB_PASSWORD"))
            .maxConnections(getIntEnv("DB_MAX_CONNECTIONS", 20))
            .build();
            
        this.redisConfig = RedisConfig.builder()
            .host(getEnv("REDIS_HOST", "localhost"))
            .port(getIntEnv("REDIS_PORT", 6379))
            .build();
    }
    
    public DatabaseConfig getDatabaseConfig() { return dbConfig; }
    public RedisConfig getRedisConfig() { return redisConfig; }
}
```

#### Anti-Patterns: What Goes Wrong

#### Singleton Anti-Patterns

#### 1\. Global State Abuse

```typescript
// DON'T DO THIS - Singleton as global variable
public enum UserSession {
    INSTANCE;
    private User currentUser; // Shared mutable state!
    
    public void setCurrentUser(User user) {
        this.currentUser = user; // Race conditions!
    }
}
```

#### 2\. Testing Nightmare

```java
// DON'T DO THIS - Hard to test
public class OrderService {
    public void processOrder(Order order) {
        // Direct dependency on singleton - can't mock!
        String config = ConfigManager.INSTANCE.getValue("payment.url");
    }
}

// BETTER - Dependency injection
public class OrderService {
    private final ConfigManager configManager;
    
    public OrderService(ConfigManager configManager) {
        this.configManager = configManager;
    }
}
```

#### Builder Anti-Patterns

#### 1\. Builder Overkill

```java
// DON'T DO THIS - Builder for simple objects
@Builder
public class Point {
    private int x;
    private int y;
}

// Just use a constructor!
public class Point {
    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }
}
```

#### 2\. Mutable Builder Result

```typescript
// DON'T DO THIS - Builder creates mutable objects
public class MutableConfig {
    private String value; // Can be changed after build()!
    
    public void setValue(String value) {
        this.value = value; // Breaks builder contract
    }
}
```

#### Production Lessons: What I Learned

#### Singleton Lessons

1. **Prefer DI over global singletons**: Spring/Guice manage lifecycle better
2. **Use for expensive resources only**: Connection pools, caches, thread pools
3. **Avoid mutable state**: Singletons should be stateless or thread-safe
4. **Consider lifecycle**: What happens during shutdown?

#### Builder Lessons

1. **Validate in build()**: Catch configuration errors early
2. **Immutable results**: Builder creates immutable objects
3. **Required vs optional**: Make required parameters constructor parameters
4. **Use for 4+ parameters**: Below that, constructors are fine

#### Tomorrow's Preview

Day 5: "Command & Template Method Patterns". How to turn operations into objects and create algorithmic frameworks. We'll explore how Kafka handles message processing and how Spring Boot uses template methods.

#### Your Architect Assignment

Review your current codebase:

1. **Find global variables** that should be proper singletons
2. **Identify complex constructors** that need builders
3. **Look for repeated configuration patterns** that could use builder + singleton combo
4. **Check thread safety** of your existing singletons

Remember: **These patterns are about object lifecycle and construction. Use them to make complex initialization simple and safe.**

*Previous articles:*

- *[Day 1 — Building Your Architect Mindset](https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)*
- *[Day 2 — Strategy & Observer Patterns](https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*
- *[Day 3 — Decorator & Proxy Patterns](https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*

*Follow along daily as we master the creational patterns that power robust systems.*

[< Go to the original](https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4#bypass)