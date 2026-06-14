---
title: Performance Engineering
type: concept
created: 2026-06-14
tags:
  - concept
  - performance
  - profiling
  - load-testing
  - database
  - system-design
---

# Performance Engineering

Performance engineering is a systematic discipline: establish a budget, measure, find the bottleneck, fix it, verify, and repeat. Without a budget, optimization is guesswork. Without measurement, you cannot tell what is fast or slow. Without the loop, you fix one bottleneck and immediately hit the next.

## The Performance Engineering Loop

```
1. Establish a budget (target p50/p95/p99 latency, throughput, error rate)
2. Measure the current state (profiling, distributed tracing, metrics)
3. Identify the bottleneck (which resource is most constrained?)
4. Fix the bottleneck (optimize the hot path)
5. Verify (re-measure, compare to budget)
6. Repeat (the bottleneck shifts to the next resource)
```

The loop never terminates. Performance is a constraint, not a feature — it must be maintained continuously.

## Performance Budgets

Define a numeric contract before any optimization work:

| Metric | Target | Measurement |
|--------|--------|-------------|
| p50 latency | < 100ms | Request-level tracing |
| p95 latency | < 300ms | Request-level tracing |
| p99 latency | < 1s | Request-level tracing |
| Throughput | > 1000 req/s | Counter per instance |
| Error rate | < 0.1% | Counter per status code |
| Query latency | < 50ms (p50), < 200ms (p99) | Database monitoring |
| Connection pool utilization | < 70% | Pool metrics |
| Cache hit rate | > 80% | Cache metrics |

Percentiles over averages. A 200ms average latency can hide 5-second p99. Users experience the tail, not the mean.

## Profiling

### CPU Profiling

CPU flame graphs show where the CPU spends its time. Each frame is a function call; wider frames consume more CPU:

```
┌─────────────────────────────────────────┐
│  process_request                        │
│  ├── validate_input          (5%)       │
│  ├── query_database          (40%)      │
│  │    ├── parse_query        (5%)       │
│  │    ├── execute_plan       (30%)      │
│  │    └── serialize_results  (5%)       │
│  └── format_response         (5%)       │
└─────────────────────────────────────────┘
```

The widest frame at the top of each stack is the hottest path. Focus optimization there.

### Memory Profiling

Track allocation rate, not just total memory usage:

| Metric | What It Indicates |
|--------|-------------------|
| High allocation rate (MB/s) | Temporary object churn, GC pressure |
| Large heap after GC | Long-lived accumulation, possible leak |
| High survivor ratio | Objects promoted to old gen unnecessarily |
| Fragmentation | Many small allocations, allocator overhead |

High allocation rate is often worse than high memory usage because of GC pauses. A service using 500MB with low allocation rate can outperform a service using 200MB with 100MB/s allocation.

### I/O Profiling

Measure the four dimensions of I/O:

| Dimension | Measurement | Bottleneck Indicator |
|-----------|-------------|---------------------|
| IOPS | Operations per second | Queue depth > 2x device capacity |
| Throughput | MB/s | Bandwidth saturation |
| Latency | Time per operation | P99 > 10ms on SSD |
| Concurrency | In-flight operations | Connection pool exhaustion |

Database systems starve on I/O long before exhausting byte capacity.

## Load Testing

### Six Types of Load Tests

| Type | Purpose | Profile |
|------|---------|---------|
| **Smoke** | Verify basic functionality under minimal load | 1-2 concurrent users |
| **Load** | Measure performance under expected normal peak | Target throughput × 1.0 |
| **Stress** | Find the breaking point | Ramp up until failure |
| **Spike** | Test recovery from sudden traffic surge | 2-5x normal in seconds |
| **Soak** | Detect degradation over time (memory leaks, GC) | Normal load for hours-days |
| **Breakpoint** | Identify exact system capacity | Step load until bottleneck limit |

### Load Testing Anti-Patterns

- **Testing in staging, not production**: staging environments never match production hardware, data volume, or traffic patterns. Use production mirroring or traffic shadowing when possible.
- **Not measuring client-side timing**: server-side metrics miss network latency, DNS resolution, TLS handshake, and client processing time. Measure from the client perspective.
- **Short tests only**: a 5-minute load test will not catch memory leaks, connection pool exhaustion, or slow GC accumulation over hours.
- **Failing to incrementally ramp**: starting at full load masks the load level at which the system breaks.

### Metrics to Capture

For each load test run:

- Request latency (p50, p95, p99, p99.9, max)
- Throughput (requests/second)
- Error rate (by HTTP status code or error type)
- CPU utilization (by core)
- Memory (heap, GC, RSS)
- I/O (IOPS, throughput, queue depth)
- Network (bandwidth, connections, retransmits)
- Database (query latency, connection pool, lock waits)
- Cache hit rate

## Database Performance

### The 80/20 Rule

Proper indexing solves approximately 80% of database performance problems. Before tuning queries or adding caching, check the index plan.

### Finding Slow Queries

```
PostgreSQL:  pg_stat_statements (total_time, calls, mean_time, rows)
MySQL:       slow_query_log
MongoDB:     profiler (db.setProfilingLevel(1, threshold_ms))
```

Sort by `total_time` or `mean_time × calls` to find the queries worth optimizing.

### Indexing Strategy

- Composite indexes: most selective column first. The index can satisfy queries filtering on the first N columns.
- Covering indexes: include all columns the query needs. Avoids heap lookups.
- Partial indexes: `CREATE INDEX ... WHERE status = 'active'`. Smaller, faster for filtered queries.
- Concurrent creation: `CREATE INDEX CONCURRENTLY` avoids table locks in production.
- Monitor unused indexes: an index that is never used adds write overhead with no read benefit.

### N+1 Query Fix

N+1 queries happen when a list query fetches N items, then a loop fetches related data for each item:

```python
# N+1: 1 query for orders + N queries for items
orders = Order.find_all(customer_id=123)
for order in orders:                # N iterations
    items = Item.find_by_order(order.id)  # N queries

# Fixed: 1 query for orders + 1 batch query for items
orders = Order.find_all(customer_id=123)
order_ids = [o.id for o in orders]
items = Item.find_by_order_ids(order_ids)  # WHERE order_id IN (...)
```

### Connection Pool Sizing

The standard formula: `pool_size = (core_count × 2) + effective_spindle_count`

In practice, 10-20 connections per pool is sufficient for most services. Higher pools increase contention rather than throughput.

## Caching Strategy

### When to Cache

Caching helps when data is:
- Read frequently and written rarely
- Expensive to compute or fetch
- Tolerates staleness (seconds to minutes)

### Cache Sizing

| Metric | Target | Action if Below |
|--------|--------|-----------------|
| Hit rate | > 80% | Increase TTL, cache more fields |
| Miss rate | < 20% | Optimize warming strategy |
| Eviction rate | < 5% of total | Increase cache size or shard |
| Staleness | < TTL × 2 | Reduce TTL or use write-through |

## Cross-Layer Debugging

Performance issues often span multiple layers. The LinkedIn HashMap freeze case study demonstrates the pattern:

```
Layer 1: Application  → HashMap resize at 58.7M keys
Layer 2: Allocator    → jemalloc calls brk() to extend heap
Layer 3: Kernel       → brk() acquires mmap_lock; page faults contend on same lock
Layer 4: Async Runtime → Tokio holds 1500 tasks; one blocked lock freezes all
```

The fix was at Layer 1 (pre-allocate with `HashMap::with_capacity()`), but the investigation required understanding all four layers. Performance debugging in modern systems requires multi-layer literacy.

### Cross-Layer Investigation Tools

| Layer | Tool |
|-------|------|
| Application | Flame graphs, allocation tracking, async span dumps |
| Allocator | jemalloc stats (`malloc_stats`), tcmalloc heap profiles |
| Kernel | `perf`, `/proc/stat`, `/proc/lock_stat`, `slabtop` |
| Runtime | Tokio console, async-task dumps, thread-dump analysis |

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/observability-and-monitoring|Observability and Monitoring]]
- Source: [[sources/backend-performance-engineering|Backend Performance Engineering]]
- Source: [[sources/byte-storage-vs-io|Byte Storage vs. I/O]]
- Source: [[sources/linkedin-58m-key-hashmap-freeze|HashMap Freeze at 58M Keys]]
- Source: [[sources/webpack-tree-shaking-performance|Webpack Tree Shaking Performance]]
- Related: [[concepts/frontend-build-performance|Frontend Build Performance]]
