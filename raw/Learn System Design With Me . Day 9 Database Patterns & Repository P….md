---
title: "Learn System Design With Me . Day 9: Database Patterns & Repository P…"
source: https://archive.is/eaS3M
author: "[[The Latency Gambler]]"
published: 2025-10-20
created: 2026-05-27
description:
tags:
  - clippings
---
## Learn System Design With Me. Day 9: Database Patterns & Repository Pattern

*This is Day 9 of our 30-day journey from code writer to system architect. Start with* [*Day 1*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build the foundation, then progress through* [*Day 2*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*,* [*Day 3*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*,* [*Day 4*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*,* [*Day 5*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*,* [*Day 6*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*,* [*Day 7*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)*, and* [*Day 8*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)

We’ve mastered system resilience patterns. Today, we dive into the **foundation of every system**: data persistence patterns. **Repository Pattern and Database Connection strategies** determine whether your system scales or crumbles under data load.

![](https://d2lrcw20xf8ij6.archive.is/eaS3M/c55cf1ea5e7b40e5fad26ee11145eff6194dc66a.webp)

Here’s the architect’s insight: **Bad data access patterns are technical debt that compounds exponentially.** The Repository pattern abstracts complexity, connection patterns manage resources, and choosing the right database type prevents architectural disasters.

> Let me show you how to build data access layers that don’t become bottlenecks.

### Repository Pattern: Clean Data Access Abstraction

### The Problem It Solves

Business logic mixed with SQL queries, testing nightmares with databases, tight coupling to specific database technologies. **Repository pattern creates a clean abstraction layer between your business logic and data persistence.**

### Basic Repository Implementation

```html
// Domain Entity
public class User {
    private String id;
    private String email;
    private String firstName;
    private String lastName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private UserStatus status;
    
    // Constructor, getters, setters, builder pattern...
}

// Repository Interface - Your Data Contract
public interface UserRepository {
    // Basic CRUD operations
    User findById(String id);
    Optional<User> findByEmail(String email);
    List<User> findByStatus(UserStatus status);
    List<User> findAll(Pageable pageable);
    
    // Business-specific queries
    List<User> findActiveUsersCreatedAfter(LocalDateTime date);
    List<User> findUsersByEmailDomain(String domain);
    long countActiveUsers();
    
    // Persistence operations
    User save(User user);
    void delete(String id);
    boolean exists(String id);
    
    // Batch operations
    void saveAll(List<User> users);
    void deleteAll(List<String> ids);
}

// SQL Implementation
@Repository
public class JdbcUserRepository implements UserRepository {
    private final JdbcTemplate jdbcTemplate;
    private final RowMapper<User> userRowMapper;
    
    public JdbcUserRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.userRowMapper = (rs, rowNum) -> User.builder()
            .id(rs.getString("id"))
            .email(rs.getString("email"))
            .firstName(rs.getString("first_name"))
            .lastName(rs.getString("last_name"))
            .createdAt(rs.getTimestamp("created_at").toLocalDateTime())
            .updatedAt(rs.getTimestamp("updated_at").toLocalDateTime())
            .status(UserStatus.valueOf(rs.getString("status")))
            .build();
    }
    
    @Override
    public User findById(String id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        
        try {
            return jdbcTemplate.queryForObject(sql, userRowMapper, id);
        } catch (EmptyResultDataAccessException e) {
            throw new UserNotFoundException("User not found with id: " + id);
        }
    }
    
    @Override
    public Optional<User> findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        
        List<User> users = jdbcTemplate.query(sql, userRowMapper, email);
        return users.isEmpty() ? Optional.empty() : Optional.of(users.get(0));
    }
    
    @Override
    public List<User> findActiveUsersCreatedAfter(LocalDateTime date) {
        String sql = """
            SELECT * FROM users 
            WHERE status = 'ACTIVE' 
            AND created_at > ? 
            ORDER BY created_at DESC
            """;
            
        return jdbcTemplate.query(sql, userRowMapper, Timestamp.valueOf(date));
    }
    
    @Override
    public User save(User user) {
        if (exists(user.getId())) {
            return update(user);
        } else {
            return insert(user);
        }
    }
    
    private User insert(User user) {
        String sql = """
            INSERT INTO users (id, email, first_name, last_name, created_at, updated_at, status)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """;
            
        user.setId(UUID.randomUUID().toString());
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        
        jdbcTemplate.update(sql,
            user.getId(),
            user.getEmail(),
            user.getFirstName(),
            user.getLastName(),
            Timestamp.valueOf(user.getCreatedAt()),
            Timestamp.valueOf(user.getUpdatedAt()),
            user.getStatus().name()
        );
        
        return user;
    }
    
    private User update(User user) {
        String sql = """
            UPDATE users SET 
                email = ?, 
                first_name = ?, 
                last_name = ?, 
                updated_at = ?, 
                status = ?
            WHERE id = ?
            """;
            
        user.setUpdatedAt(LocalDateTime.now());
        
        int rowsAffected = jdbcTemplate.update(sql,
            user.getEmail(),
            user.getFirstName(),
            user.getLastName(),
            Timestamp.valueOf(user.getUpdatedAt()),
            user.getStatus().name(),
            user.getId()
        );
        
        if (rowsAffected == 0) {
            throw new UserNotFoundException("User not found with id: " + user.getId());
        }
        
        return user;
    }
    
    @Override
    public void saveAll(List<User> users) {
        String sql = """
            INSERT INTO users (id, email, first_name, last_name, created_at, updated_at, status)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE
                email = VALUES(email),
                first_name = VALUES(first_name),
                last_name = VALUES(last_name),
                updated_at = VALUES(updated_at),
                status = VALUES(status)
            """;
        
        List<Object[]> batchArgs = users.stream()
            .map(user -> {
                if (user.getId() == null) {
                    user.setId(UUID.randomUUID().toString());
                    user.setCreatedAt(LocalDateTime.now());
                }
                user.setUpdatedAt(LocalDateTime.now());
                
                return new Object[]{
                    user.getId(),
                    user.getEmail(),
                    user.getFirstName(),
                    user.getLastName(),
                    Timestamp.valueOf(user.getCreatedAt()),
                    Timestamp.valueOf(user.getUpdatedAt()),
                    user.getStatus().name()
                };
            })
            .collect(Collectors.toList());
        
        jdbcTemplate.batchUpdate(sql, batchArgs);
    }
}
```

### Advanced Repository: Generic Base Repository

```html
// Generic Repository Interface
public interface Repository<T, ID> {
    Optional<T> findById(ID id);
    List<T> findAll();
    List<T> findAll(Pageable pageable);
    T save(T entity);
    void delete(ID id);
    boolean exists(ID id);
    long count();
}

// Abstract Base Repository
public abstract class AbstractJdbcRepository<T, ID> implements Repository<T, ID> {
    protected final JdbcTemplate jdbcTemplate;
    protected final RowMapper<T> rowMapper;
    private final String tableName;
    private final String idColumn;
    
    public AbstractJdbcRepository(JdbcTemplate jdbcTemplate, 
                                RowMapper<T> rowMapper,
                                String tableName, 
                                String idColumn) {
        this.jdbcTemplate = jdbcTemplate;
        this.rowMapper = rowMapper;
        this.tableName = tableName;
        this.idColumn = idColumn;
    }
    
    @Override
    public Optional<T> findById(ID id) {
        String sql = String.format("SELECT * FROM %s WHERE %s = ?", tableName, idColumn);
        
        try {
            T entity = jdbcTemplate.queryForObject(sql, rowMapper, id);
            return Optional.of(entity);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }
    
    @Override
    public List<T> findAll(Pageable pageable) {
        String sql = String.format(
            "SELECT * FROM %s ORDER BY %s LIMIT ? OFFSET ?", 
            tableName, getDefaultOrderBy()
        );
        
        return jdbcTemplate.query(sql, rowMapper, 
            pageable.getPageSize(), 
            pageable.getOffset()
        );
    }
    
    @Override
    public boolean exists(ID id) {
        String sql = String.format("SELECT COUNT(*) FROM %s WHERE %s = ?", tableName, idColumn);
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, id);
        return count != null && count > 0;
    }
    
    @Override
    public long count() {
        String sql = String.format("SELECT COUNT(*) FROM %s", tableName);
        Long count = jdbcTemplate.queryForObject(sql, Long.class);
        return count != null ? count : 0;
    }
    
    // Template methods for subclasses to implement
    protected abstract String getDefaultOrderBy();
    protected abstract String getInsertSql();
    protected abstract String getUpdateSql();
    protected abstract Object[] getInsertParameters(T entity);
    protected abstract Object[] getUpdateParameters(T entity);
    protected abstract ID getId(T entity);
    protected abstract void setId(T entity, ID id);
}

// Concrete Implementation
@Repository
public class JdbcUserRepositoryV2 extends AbstractJdbcRepository<User, String> 
                                  implements UserRepository {
    
    public JdbcUserRepositoryV2(JdbcTemplate jdbcTemplate) {
        super(jdbcTemplate, createUserRowMapper(), "users", "id");
    }
    
    private static RowMapper<User> createUserRowMapper() {
        return (rs, rowNum) -> User.builder()
            .id(rs.getString("id"))
            .email(rs.getString("email"))
            .firstName(rs.getString("first_name"))
            .lastName(rs.getString("last_name"))
            .createdAt(rs.getTimestamp("created_at").toLocalDateTime())
            .updatedAt(rs.getTimestamp("updated_at").toLocalDateTime())
            .status(UserStatus.valueOf(rs.getString("status")))
            .build();
    }
    
    @Override
    protected String getDefaultOrderBy() {
        return "created_at DESC";
    }
    
    @Override
    protected String getInsertSql() {
        return "INSERT INTO users (id, email, first_name, last_name, created_at, updated_at, status) " +
               "VALUES (?, ?, ?, ?, ?, ?, ?)";
    }
    
    @Override
    protected String getUpdateSql() {
        return "UPDATE users SET email = ?, first_name = ?, last_name = ?, updated_at = ?, status = ? " +
               "WHERE id = ?";
    }
    
    // Business-specific methods
    @Override
    public List<User> findActiveUsersCreatedAfter(LocalDateTime date) {
        String sql = "SELECT * FROM users WHERE status = 'ACTIVE' AND created_at > ? ORDER BY created_at DESC";
        return jdbcTemplate.query(sql, rowMapper, Timestamp.valueOf(date));
    }
}
```

### SQL vs NoSQL: The Architect’s Decision Framework

### SQL Databases: When to Choose

**Use SQL when you need:**

- **ACID transactions**: Financial systems, inventory management
- **Complex relationships**: Many-to-many, foreign keys, joins
- **Complex queries**: Reporting, analytics, aggregations
- **Mature ecosystem**: Tools, monitoring, expertise
```html
// SQL Repository for Complex Queries
@Repository
public class OrderSqlRepository implements OrderRepository {
    
    @Override
    public OrderSummary getOrderSummaryWithDetails(String orderId) {
        String sql = """
            SELECT 
                o.id, o.customer_id, o.total_amount, o.status,
                c.first_name, c.last_name, c.email,
                oi.product_id, oi.quantity, oi.unit_price,
                p.name as product_name, p.category
            FROM orders o
            JOIN customers c ON o.customer_id = c.id
            JOIN order_items oi ON o.id = oi.order_id
            JOIN products p ON oi.product_id = p.id
            WHERE o.id = ?
            """;
        
        Map<String, OrderSummary> orderMap = new HashMap<>();
        
        jdbcTemplate.query(sql, rs -> {
            String id = rs.getString("id");
            OrderSummary order = orderMap.computeIfAbsent(id, k -> 
                OrderSummary.builder()
                    .id(id)
                    .customerId(rs.getString("customer_id"))
                    .customerName(rs.getString("first_name") + " " + rs.getString("last_name"))
                    .customerEmail(rs.getString("email"))
                    .totalAmount(rs.getBigDecimal("total_amount"))
                    .status(OrderStatus.valueOf(rs.getString("status")))
                    .items(new ArrayList<>())
                    .build()
            );
            
            order.getItems().add(OrderItem.builder()
                .productId(rs.getString("product_id"))
                .productName(rs.getString("product_name"))
                .quantity(rs.getInt("quantity"))
                .unitPrice(rs.getBigDecimal("unit_price"))
                .build()
            );
        }, orderId);
        
        return orderMap.values().iterator().next();
    }
}
```

### NoSQL Databases: When to Choose

**Use NoSQL when you need:**

- **Horizontal scaling**: Massive datasets, high throughput
- **Flexible schema**: Rapid iteration, varying data structures
- **Simple queries**: Key-value lookups, document retrieval
- **High availability**: Eventual consistency is acceptable
```html
// MongoDB Repository Implementation
@Repository
public class MongoUserRepository implements UserRepository {
    private final MongoTemplate mongoTemplate;
    
    public MongoUserRepository(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
    }
    
    @Override
    public User findById(String id) {
        User user = mongoTemplate.findById(id, User.class);
        if (user == null) {
            throw new UserNotFoundException("User not found with id: " + id);
        }
        return user;
    }
    
    @Override
    public List<User> findByEmailDomain(String domain) {
        Query query = new Query(Criteria.where("email").regex(".*@" + domain + "$"));
        return mongoTemplate.find(query, User.class);
    }
    
    @Override
    public List<User> findActiveUsersCreatedAfter(LocalDateTime date) {
        Query query = new Query(
            Criteria.where("status").is("ACTIVE")
                .and("createdAt").gt(date)
        ).with(Sort.by(Sort.Direction.DESC, "createdAt"));
        
        return mongoTemplate.find(query, User.class);
    }
    
    @Override
    public User save(User user) {
        if (user.getId() == null) {
            user.setId(ObjectId.get().toString());
            user.setCreatedAt(LocalDateTime.now());
        }
        user.setUpdatedAt(LocalDateTime.now());
        
        return mongoTemplate.save(user);
    }
    
    // Aggregation pipeline for complex queries
    public List<UserStatistics> getUserStatisticsByDomain() {
        Aggregation aggregation = Aggregation.newAggregation(
            Aggregation.match(Criteria.where("status").is("ACTIVE")),
            Aggregation.project()
                .and(ArrayOperators.ArrayElemAt.arrayOf(
                    StringOperators.Split.valueOf("email").split("@")
                ).at(1)).as("domain")
                .and("id").as("userId"),
            Aggregation.group("domain")
                .count().as("userCount")
                .first("domain").as("domain"),
            Aggregation.sort(Sort.Direction.DESC, "userCount")
        );
        
        AggregationResults<UserStatistics> results = mongoTemplate.aggregate(
            aggregation, "users", UserStatistics.class);
            
        return results.getMappedResults();
    }
}
```

### Database Connection Patterns

### Connection Pool Pattern

```html
// Connection Pool Configuration
@Configuration
public class DatabaseConfig {
    
    @Bean
    @Primary
    public DataSource primaryDataSource() {
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(env.getProperty("db.primary.url"));
        config.setUsername(env.getProperty("db.primary.username"));
        config.setPassword(env.getProperty("db.primary.password"));
        
        // Connection pool settings
        config.setMaximumPoolSize(20);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(30000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);
        config.setLeakDetectionThreshold(60000);
        
        // Performance settings
        config.addDataSourceProperty("cachePrepStmts", "true");
        config.addDataSourceProperty("prepStmtCacheSize", "250");
        config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
        config.addDataSourceProperty("useServerPrepStmts", "true");
        
        return new HikariDataSource(config);
    }
    
    @Bean
    public DataSource readOnlyDataSource() {
        // Separate pool for read replicas
        HikariConfig config = new HikariConfig();
        config.setJdbcUrl(env.getProperty("db.readonly.url"));
        config.setUsername(env.getProperty("db.readonly.username"));
        config.setPassword(env.getProperty("db.readonly.password"));
        config.setReadOnly(true);
        config.setMaximumPoolSize(15);
        
        return new HikariDataSource(config);
    }
}
```

### Connection Factory Pattern

```html
// Database Connection Factory
public interface ConnectionFactory {
    Connection getConnection() throws SQLException;
    Connection getReadOnlyConnection() throws SQLException;
    void releaseConnection(Connection connection);
}

@Component
public class PooledConnectionFactory implements ConnectionFactory {
    private final DataSource primaryDataSource;
    private final DataSource readOnlyDataSource;
    private final CircuitBreaker primaryCircuitBreaker;
    private final CircuitBreaker readOnlyCircuitBreaker;
    
    @Override
    public Connection getConnection() throws SQLException {
        return primaryCircuitBreaker.execute(() -> {
            Connection conn = primaryDataSource.getConnection();
            conn.setAutoCommit(false); // Enable transaction management
            return conn;
        });
    }
    
    @Override
    public Connection getReadOnlyConnection() throws SQLException {
        return readOnlyCircuitBreaker.executeWithFallback(
            () -> readOnlyDataSource.getConnection(),
            (exception) -> {
                log.warn("Read-only database unavailable, falling back to primary");
                return primaryDataSource.getConnection();
            }
        );
    }
    
    @Override
    public void releaseConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close(); // Returns to pool
            } catch (SQLException e) {
                log.error("Error releasing connection", e);
            }
        }
    }
}
```

### Advanced Repository with Connection Management

```html
// Repository with Read/Write Separation
@Repository
public class OptimizedUserRepository implements UserRepository {
    private final ConnectionFactory connectionFactory;
    private final UserMapper userMapper;
    
    // Write operations use primary database
    @Override
    @Transactional
    public User save(User user) {
        try (Connection conn = connectionFactory.getConnection()) {
            if (exists(user.getId())) {
                return updateUser(conn, user);
            } else {
                return insertUser(conn, user);
            }
        } catch (SQLException e) {
            throw new DataAccessException("Failed to save user", e);
        }
    }
    
    // Read operations can use read replicas
    @Override
    @Transactional(readOnly = true)
    public User findById(String id) {
        try (Connection conn = connectionFactory.getReadOnlyConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE id = ?")) {
            
            stmt.setString(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return userMapper.mapFromResultSet(rs);
                } else {
                    throw new UserNotFoundException("User not found: " + id);
                }
            }
        } catch (SQLException e) {
            throw new DataAccessException("Failed to find user by id", e);
        }
    }
    
    // Batch operations with connection reuse
    @Override
    @Transactional
    public void saveAll(List<User> users) {
        try (Connection conn = connectionFactory.getConnection()) {
            conn.setAutoCommit(false);
            
            String sql = "INSERT INTO users (id, email, first_name, last_name, created_at, updated_at, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?) " +
                        "ON DUPLICATE KEY UPDATE email = VALUES(email), updated_at = VALUES(updated_at)";
                        
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                for (User user : users) {
                    setUserParameters(stmt, user);
                    stmt.addBatch();
                }
                
                stmt.executeBatch();
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            throw new DataAccessException("Failed to save users batch", e);
        }
    }
}
```

### System Architecture: Complete Data Access Layer

```html
[Business Layer] → [Repository Interface] → [Repository Implementation] → [Connection Factory] → [Connection Pool] → [Database]
                                    ↓                                            ↓
                            [Cache Layer]                              [Circuit Breaker]
                                    ↓                                            ↓
                            [Redis/Hazelcast]                        [Read Replica Fallback]
```

### Production Lessons: What I Learned

### Repository Pattern Lessons

1. **Keep repositories focused**: One repository per aggregate root
2. **Abstract business queries**: Don’t expose SQL details to business layer
3. **Use batch operations**: Single operations don’t scale
4. **Implement proper error handling**: Database exceptions need context

### Database Selection Lessons

1. **Start with SQL**: Unless you have specific NoSQL requirements
2. **Don’t mix paradigms**: Keep transactional and analytical data separate
3. **Plan for read replicas**: Separate read and write workloads early
4. **Monitor connection pools**: Pool exhaustion kills applications

### Connection Management Lessons

1. **Always use connection pooling**: Raw connections are a performance killer
2. **Set proper timeouts**: Prevent hanging connections
3. **Monitor pool metrics**: Track usage, leaks, and wait times
4. **Implement circuit breakers**: Database failures should fail fast

### Tomorrow’s Preview

Day 10: “Caching Patterns”. How to implement cache-aside, write-through, and write-behind patterns effectively, and when to use each strategy.

### Your Architect Assignment

Examine your current data access layer:

1. **Find direct SQL in business logic** that should be in repositories
2. **Identify places mixing read and write operations** that need separation
3. **Look for connection management issues** that could be optimized
4. **Check if you’re using the right database type** for each use case

Remember: **Repository pattern abstracts data complexity. Connection patterns manage resources efficiently. Database choice determines scalability limits.**

*Previous articles:*

- [*Day 1 Building Your Architect Mindset*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [*Day 2 Strategy & Observer Patterns*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [*Day 3 Decorator & Proxy Patterns*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [*Day 4 Singleton & Builder Patterns*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [*Day 5 Command & Template Method Patterns*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [*Day 6 Adapter & Facade Patterns*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [*Day 7 Chain of Responsibility & State Patterns*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [*Day 8 Load Balancing & Circuit Breaker Patterns*](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)

> *Follow along daily as we master the data access patterns that form the foundation of scalable systems.*

## Responses (1)

Write a response[What are your thoughts?](https://archive.is/o/eaS3M/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)

==Start with Day 1 to build the foundation, then progress through Day 2, Day 3, Day 4, Day 5, Day 6, Day 7, and Day 8==
