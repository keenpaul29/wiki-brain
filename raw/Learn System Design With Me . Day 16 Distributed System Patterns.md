---
title: "Learn System Design With Me . Day 16: Distributed System Patterns"
source: "https://archive.is/uXpXa"
author:
  - "[[The Latency Gambler]]"
published: 2025-10-04
created: 2026-06-14
description:
tags:
  - "clippings"
---
## Consensus, Coordination & Consistency

*This is Day 16 of our 30-day journey from code writer to system architect. Start with* [*Day 1*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1) *to build the foundation, then progress through* [*Day 2*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)*,* [*Day 3*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)*,* [*Day 4*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)*,* [*Day 5*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)*,* [*Day 6*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)*,* [*Day 7*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)*,* [*Day 8*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)*,* [*Day 9*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)*,* [*Day 10*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)*,* [*Day 11*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)*,* [*Day 12*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)*,* [*Day 13*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)*,* [*Day 14*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-14-monitoring-observer-patterns-cdd2bba68d9f)*, and* [*Day 15*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-15-microservices-patterns-532c7a4ab899)

We’ve mastered microservices patterns. Today, we tackle the **hardest distributed systems problems**: **Leader Election, Consensus, and Distributed Consistency**. These patterns solve problems that have no simple answers.

![](https://d0lkrq1lm3zfqi.archive.is/uXpXa/37fd9ce09bb7ee96b2d28618bd42b05627737fee.webp)

Ai Generated Image

Here’s the brutal truth: **In distributed systems, nodes fail, networks partition, and clocks drift. You can’t rely on anything being synchronized or available. These patterns help you build systems that work anyway.**

### Leader Election: Coordinating Distributed Systems

### The Problem

In distributed systems with multiple nodes:

- **Who coordinates?** Multiple nodes can’t all be leaders
- **What if leader fails?** System needs automatic failover
- **Split-brain scenarios**: Network partition creates multiple leaders
- **Coordination needed**: Distributed locks, task scheduling, data replication

### What Leader Election Solves

**Leader Election** ensures exactly **one node is the leader** at any time, coordinating actions across the distributed system.

**Real-world uses:**

- **Database clusters**: Primary node handles writes
- **Distributed schedulers**: One node schedules tasks
- **Distributed locks**: Leader manages lock state
- **Cache invalidation**: Leader broadcasts invalidations

### Basic Leader Election with Heartbeats

```html
// Node State
public enum NodeState {
    FOLLOWER,    // Following current leader
    CANDIDATE,   // Running for leader
    LEADER       // Currently the leader
}

// Leader Election Manager
@Component
public class LeaderElectionManager {
    private volatile NodeState currentState = NodeState.FOLLOWER;
    private volatile String currentLeaderId = null;
    private final String nodeId = UUID.randomUUID().toString();
    private volatile long lastHeartbeat = System.currentTimeMillis();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(2);
    
    @PostConstruct
    public void start() {
        // Start heartbeat monitoring
        scheduler.scheduleAtFixedRate(this::checkLeaderHeartbeat, 5, 5, TimeUnit.SECONDS);
        
        // If leader, send heartbeats
        scheduler.scheduleAtFixedRate(this::sendHeartbeatIfLeader, 2, 2, TimeUnit.SECONDS);
    }
    
    private void checkLeaderHeartbeat() {
        long now = System.currentTimeMillis();
        long timeSinceLastHeartbeat = now - lastHeartbeat;
        
        // If no heartbeat for 10 seconds, start election
        if (timeSinceLastHeartbeat > 10000 && currentState == NodeState.FOLLOWER) {
            log.warn("Leader heartbeat timeout. Starting election...");
            startElection();
        }
    }
    
    private void startElection() {
        currentState = NodeState.CANDIDATE;
        
        // Request votes from all nodes
        List<Node> allNodes = clusterManager.getAllNodes();
        int votesReceived = 1; // Vote for self
        
        for (Node node : allNodes) {
            if (!node.getId().equals(nodeId)) {
                try {
                    VoteResponse response = requestVote(node);
                    if (response.isVoteGranted()) {
                        votesReceived++;
                    }
                } catch (Exception e) {
                    log.error("Failed to request vote from node: {}", node.getId(), e);
                }
            }
        }
        
        // Need majority to become leader
        int majorityThreshold = (allNodes.size() / 2) + 1;
        
        if (votesReceived >= majorityThreshold) {
            becomeLeader();
        } else {
            currentState = NodeState.FOLLOWER;
            log.info("Election failed. Returning to follower state.");
        }
    }
    
    private void becomeLeader() {
        currentState = NodeState.LEADER;
        currentLeaderId = nodeId;
        
        log.info("Node {} became the leader", nodeId);
        
        // Notify all nodes of new leadership
        notifyNodesOfLeadership();
        
        // Start leader responsibilities
        startLeaderDuties();
    }
    
    private void sendHeartbeatIfLeader() {
        if (currentState == NodeState.LEADER) {
            List<Node> followers = clusterManager.getFollowerNodes();
            
            HeartbeatMessage heartbeat = HeartbeatMessage.builder()
                .leaderId(nodeId)
                .timestamp(System.currentTimeMillis())
                .build();
            
            for (Node follower : followers) {
                try {
                    sendHeartbeat(follower, heartbeat);
                } catch (Exception e) {
                    log.error("Failed to send heartbeat to: {}", follower.getId(), e);
                }
            }
        }
    }
    
    public void receiveHeartbeat(HeartbeatMessage heartbeat) {
        // Update last heartbeat time
        lastHeartbeat = System.currentTimeMillis();
        
        // If we were candidate/leader but received heartbeat from another leader
        if (currentState != NodeState.FOLLOWER) {
            log.info("Stepping down as {} to follow leader: {}", currentState, heartbeat.getLeaderId());
            currentState = NodeState.FOLLOWER;
        }
        
        currentLeaderId = heartbeat.getLeaderId();
    }
    
    private void startLeaderDuties() {
        // Leader-specific tasks
        scheduler.scheduleAtFixedRate(this::coordinateTasks, 10, 10, TimeUnit.SECONDS);
        scheduler.scheduleAtFixedRate(this::monitorClusterHealth, 30, 30, TimeUnit.SECONDS);
    }
    
    public boolean isLeader() {
        return currentState == NodeState.LEADER;
    }
    
    public String getCurrentLeaderId() {
        return currentLeaderId;
    }
}
```

### Raft Consensus Algorithm: Distributed Agreement

### What Consensus Solves

**Consensus** ensures all nodes in a distributed system **agree on the same value/state**, even with failures and network issues.

**The Challenge:**

- Nodes may fail at any time
- Network messages can be lost or delayed
- Need majority agreement (can’t wait for all nodes)
- Must handle “split-brain” scenarios

### Raft Algorithm Basics

**Raft uses three states:**

1. **Leader**: Handles all client requests
2. **Candidate**: Running for leader election
3. **Follower**: Replicates leader’s log

**Key Raft Concepts:**

- **Term**: Logical clock for leadership eras
- **Log**: Ordered sequence of commands
- **Commit Index**: Latest log entry known to be committed

### Raft Implementation

```html
// Raft Log Entry
@Data
public class LogEntry {
    private long term;
    private long index;
    private String command;
    private byte[] data;
    private LocalDateTime timestamp;
}

// Raft State
@Component
public class RaftNode {
    private volatile NodeState state = NodeState.FOLLOWER;
    private volatile long currentTerm = 0;
    private volatile String votedFor = null;
    private final List<LogEntry> log = new CopyOnWriteArrayList<>();
    private volatile long commitIndex = 0;
    private volatile long lastApplied = 0;
    
    // Leader state
    private final Map<String, Long> nextIndex = new ConcurrentHashMap<>();
    private final Map<String, Long> matchIndex = new ConcurrentHashMap<>();
    
    private final String nodeId = UUID.randomUUID().toString();
    
    // Request Vote RPC
    public VoteResponse requestVote(VoteRequest request) {
        // If request term is outdated, reject
        if (request.getTerm() < currentTerm) {
            return VoteResponse.builder()
                .term(currentTerm)
                .voteGranted(false)
                .build();
        }
        
        // If request term is newer, update our term and become follower
        if (request.getTerm() > currentTerm) {
            currentTerm = request.getTerm();
            state = NodeState.FOLLOWER;
            votedFor = null;
        }
        
        // Grant vote if:
        // 1. Haven't voted yet in this term
        // 2. Candidate's log is at least as up-to-date as ours
        boolean canVote = (votedFor == null || votedFor.equals(request.getCandidateId())) &&
                         isLogUpToDate(request.getLastLogIndex(), request.getLastLogTerm());
        
        if (canVote) {
            votedFor = request.getCandidateId();
            log.info("Granted vote to {} for term {}", request.getCandidateId(), currentTerm);
        }
        
        return VoteResponse.builder()
            .term(currentTerm)
            .voteGranted(canVote)
            .build();
    }
    
    // Append Entries RPC (log replication and heartbeat)
    public AppendEntriesResponse appendEntries(AppendEntriesRequest request) {
        // Reject if request term is outdated
        if (request.getTerm() < currentTerm) {
            return AppendEntriesResponse.builder()
                .term(currentTerm)
                .success(false)
                .build();
        }
        
        // If request term is newer, update term and become follower
        if (request.getTerm() > currentTerm) {
            currentTerm = request.getTerm();
            state = NodeState.FOLLOWER;
            votedFor = null;
        }
        
        // Reset election timeout (received heartbeat from leader)
        resetElectionTimeout();
        
        // Check if log contains entry at prevLogIndex with prevLogTerm
        if (request.getPrevLogIndex() > 0) {
            if (request.getPrevLogIndex() > log.size()) {
                return AppendEntriesResponse.builder()
                    .term(currentTerm)
                    .success(false)
                    .build();
            }
            
            LogEntry prevEntry = log.get((int) request.getPrevLogIndex() - 1);
            if (prevEntry.getTerm() != request.getPrevLogTerm()) {
                // Log inconsistency - delete conflicting entries
                log.subList((int) request.getPrevLogIndex() - 1, log.size()).clear();
                
                return AppendEntriesResponse.builder()
                    .term(currentTerm)
                    .success(false)
                    .build();
            }
        }
        
        // Append new entries
        if (request.getEntries() != null && !request.getEntries().isEmpty()) {
            int insertIndex = (int) request.getPrevLogIndex();
            
            for (LogEntry entry : request.getEntries()) {
                if (insertIndex < log.size()) {
                    // Replace existing entry if terms don't match
                    if (log.get(insertIndex).getTerm() != entry.getTerm()) {
                        log.set(insertIndex, entry);
                    }
                } else {
                    // Append new entry
                    log.add(entry);
                }
                insertIndex++;
            }
        }
        
        // Update commit index
        if (request.getLeaderCommit() > commitIndex) {
            commitIndex = Math.min(request.getLeaderCommit(), log.size());
            applyCommittedEntries();
        }
        
        return AppendEntriesResponse.builder()
            .term(currentTerm)
            .success(true)
            .matchIndex(log.size())
            .build();
    }
    
    // Client Request (only leader handles)
    public CompletableFuture<ClientResponse> clientRequest(String command, byte[] data) {
        if (state != NodeState.LEADER) {
            return CompletableFuture.completedFuture(
                ClientResponse.notLeader(getCurrentLeaderId())
            );
        }
        
        // Append to local log
        LogEntry entry = new LogEntry();
        entry.setTerm(currentTerm);
        entry.setIndex(log.size() + 1);
        entry.setCommand(command);
        entry.setData(data);
        entry.setTimestamp(LocalDateTime.now());
        
        log.add(entry);
        
        // Replicate to followers
        CompletableFuture<ClientResponse> future = new CompletableFuture<>();
        
        replicateToFollowers(entry).thenAccept(success -> {
            if (success) {
                // Once replicated to majority, commit
                commitIndex = entry.getIndex();
                applyCommittedEntries();
                
                future.complete(ClientResponse.success());
            } else {
                future.complete(ClientResponse.replicationFailed());
            }
        });
        
        return future;
    }
    
    private CompletableFuture<Boolean> replicateToFollowers(LogEntry entry) {
        List<Node> followers = clusterManager.getFollowerNodes();
        int requiredAcks = (followers.size() + 1) / 2 + 1; // Majority including self
        
        AtomicInteger acks = new AtomicInteger(1); // Self ack
        CompletableFuture<Boolean> future = new CompletableFuture<>();
        
        for (Node follower : followers) {
            CompletableFuture.runAsync(() -> {
                try {
                    AppendEntriesRequest request = buildAppendEntriesRequest(follower.getId());
                    AppendEntriesResponse response = sendAppendEntries(follower, request);
                    
                    if (response.isSuccess()) {
                        if (acks.incrementAndGet() >= requiredAcks) {
                            future.complete(true);
                        }
                    }
                } catch (Exception e) {
                    log.error("Failed to replicate to follower: {}", follower.getId(), e);
                }
            });
        }
        
        // Timeout if can't achieve majority
        scheduler.schedule(() -> {
            if (!future.isDone()) {
                future.complete(false);
            }
        }, 5, TimeUnit.SECONDS);
        
        return future;
    }
    
    private void applyCommittedEntries() {
        while (lastApplied < commitIndex) {
            lastApplied++;
            LogEntry entry = log.get((int) lastApplied - 1);
            
            // Apply to state machine
            stateMachine.apply(entry.getCommand(), entry.getData());
            
            log.info("Applied entry {} to state machine", entry.getIndex());
        }
    }
}
```

### Vector Clocks: Distributed Causality

### The Problem

In distributed systems:

- **No global clock**: Nodes have different times
- **Clock drift**: Hardware clocks drift apart
- **Causality tracking**: Need to know event order across nodes
- **Concurrent updates**: Detect conflicting updates

### What Vector Clocks Solve

**Vector Clocks** track **causality relationships** between events in distributed systems, detecting:

- **Happened-before**: Event A caused Event B
- **Concurrent**: Events happened independently
- **Conflicts**: Need manual resolution

### Vector Clock Implementation

```html
// Vector Clock
@Data
public class VectorClock implements Comparable<VectorClock> {
    private final Map<String, Long> clock;
    
    public VectorClock() {
        this.clock = new ConcurrentHashMap<>();
    }
    
    public VectorClock(Map<String, Long> clock) {
        this.clock = new ConcurrentHashMap<>(clock);
    }
    
    // Increment local node's clock
    public void increment(String nodeId) {
        clock.merge(nodeId, 1L, Long::sum);
    }
    
    // Update clock with received vector clock (merge)
    public void update(String nodeId, VectorClock other) {
        // Take max of each entry
        other.clock.forEach((key, value) -> 
            clock.merge(key, value, Math::max)
        );
        
        // Increment local node's clock
        increment(nodeId);
    }
    
    // Compare two vector clocks
    @Override
    public int compareTo(VectorClock other) {
        boolean thisLessOrEqual = true;
        boolean otherLessOrEqual = true;
        boolean equal = true;
        
        // Check all keys
        Set<String> allKeys = new HashSet<>();
        allKeys.addAll(this.clock.keySet());
        allKeys.addAll(other.clock.keySet());
        
        for (String key : allKeys) {
            long thisValue = this.clock.getOrDefault(key, 0L);
            long otherValue = other.clock.getOrDefault(key, 0L);
            
            if (thisValue > otherValue) {
                otherLessOrEqual = false;
            }
            if (thisValue < otherValue) {
                thisLessOrEqual = false;
            }
            if (thisValue != otherValue) {
                equal = false;
            }
        }
        
        if (equal) return 0;
        if (thisLessOrEqual) return -1;  // This happened before other
        if (otherLessOrEqual) return 1;   // Other happened before this
        return Integer.MIN_VALUE;         // Concurrent (conflict)
    }
    
    // Check if clocks are concurrent (conflicting)
    public boolean isConcurrent(VectorClock other) {
        return compareTo(other) == Integer.MIN_VALUE;
    }
    
    // Check if this happened before other
    public boolean happenedBefore(VectorClock other) {
        return compareTo(other) < 0 && !isConcurrent(other);
    }
}

// Versioned Data with Vector Clock
@Data
public class VersionedData<T> {
    private T data;
    private VectorClock version;
    private LocalDateTime timestamp;
    
    public VersionedData(T data, VectorClock version) {
        this.data = data;
        this.version = version;
        this.timestamp = LocalDateTime.now();
    }
}

// Distributed Key-Value Store with Vector Clocks
@Component
public class DistributedKVStore {
    private final Map<String, List<VersionedData<String>>> store = new ConcurrentHashMap<>();
    private final String nodeId = UUID.randomUUID().toString();
    private final VectorClock localClock = new VectorClock();
    
    // Put value (local write)
    public void put(String key, String value) {
        localClock.increment(nodeId);
        
        VersionedData<String> versioned = new VersionedData<>(
            value, 
            new VectorClock(localClock.getClock())
        );
        
        List<VersionedData<String>> versions = store.computeIfAbsent(key, k -> new CopyOnWriteArrayList<>());
        
        // Remove obsolete versions (causally dominated)
        versions.removeIf(existing -> 
            versioned.getVersion().happenedBefore(existing.getVersion())
        );
        
        // Add new version
        versions.add(versioned);
        
        log.info("Put key: {} with version: {}", key, versioned.getVersion());
        
        // Replicate to other nodes
        replicateToNodes(key, versioned);
    }
    
    // Get value (returns all concurrent versions if conflict)
    public List<VersionedData<String>> get(String key) {
        return store.getOrDefault(key, Collections.emptyList());
    }
    
    // Receive replicated data from another node
    public void receiveReplication(String key, VersionedData<String> data, String sourceNodeId) {
        localClock.update(nodeId, data.getVersion());
        
        List<VersionedData<String>> versions = store.computeIfAbsent(key, k -> new CopyOnWriteArrayList<>());
        
        boolean shouldAdd = true;
        List<VersionedData<String>> toRemove = new ArrayList<>();
        
        for (VersionedData<String> existing : versions) {
            VectorClock existingVersion = existing.getVersion();
            VectorClock newVersion = data.getVersion();
            
            if (existingVersion.happenedBefore(newVersion)) {
                // Existing is obsolete
                toRemove.add(existing);
            } else if (newVersion.happenedBefore(existingVersion)) {
                // New data is obsolete
                shouldAdd = false;
                break;
            }
            // else: concurrent versions (keep both)
        }
        
        versions.removeAll(toRemove);
        
        if (shouldAdd) {
            versions.add(data);
        }
        
        log.info("Received replication for key: {} from node: {}", key, sourceNodeId);
    }
    
    // Detect and resolve conflicts
    public String resolveConflicts(String key, ConflictResolver<String> resolver) {
        List<VersionedData<String>> versions = get(key);
        
        if (versions.isEmpty()) {
            return null;
        }
        
        if (versions.size() == 1) {
            return versions.get(0).getData();
        }
        
        // Multiple concurrent versions - conflict!
        log.warn("Conflict detected for key: {} with {} versions", key, versions.size());
        
        // Use resolver to merge conflicts
        String resolved = resolver.resolve(versions);
        
        // Write resolved value
        put(key, resolved);
        
        return resolved;
    }
}

// Conflict Resolution Strategies
public interface ConflictResolver<T> {
    T resolve(List<VersionedData<T>> conflictingVersions);
}

// Last-Write-Wins resolver
public class LastWriteWinsResolver implements ConflictResolver<String> {
    @Override
    public String resolve(List<VersionedData<String>> conflictingVersions) {
        return conflictingVersions.stream()
            .max(Comparator.comparing(VersionedData::getTimestamp))
            .map(VersionedData::getData)
            .orElse(null);
    }
}

// Custom merge resolver
public class CustomMergeResolver implements ConflictResolver<String> {
    @Override
    public String resolve(List<VersionedData<String>> conflictingVersions) {
        // Application-specific merge logic
        // For example, merge JSON objects, combine sets, etc.
        return mergeData(conflictingVersions);
    }
}
```

## System Architecture: Complete Distributed Coordination

```html
[Node 1: Leader] ──heartbeat──> [Node 2: Follower]
      │                            │
      ├──log replication──────────>│
      │                            │
      └──consensus (Raft)──────────┤
                                   │
[Node 3: Follower] <──AppendEntries──┘
      │
      └──Vector Clock──> [Conflict Detection]
                              │
                              ▼
                        [Conflict Resolution]
```

### Production Considerations

### Monitoring Consensus Health

```html
@Component
public class ConsensusMetrics {
    private final MeterRegistry registry;
    
    public void recordLeaderElection(boolean successful, long durationMs) {
        registry.counter("leader.election.total",
            "result", successful ? "success" : "failure").increment();
            
        registry.timer("leader.election.duration").record(durationMs, TimeUnit.MILLISECONDS);
    }
    
    public void recordLogReplication(long lag) {
        registry.gauge("raft.replication.lag", lag);
    }
    
    public void recordConflicts(String key, int versionCount) {
        registry.counter("vector.clock.conflicts",
            "key", key).increment();
            
        registry.gauge("conflicting.versions", versionCount);
    }
}
```

### Decision Framework

**Use Leader Election when:**

- Need single coordinator for distributed operations
- Task scheduling in distributed system
- Managing distributed locks
- Coordinating data replication

**Use Consensus (Raft) when:**

- Need strong consistency across nodes
- Building replicated state machines
- Distributed configuration management
- Critical data that must be consistent

**Use Vector Clocks when:**

- Tracking causality in distributed events
- Detecting concurrent updates
- Need eventual consistency with conflict detection
- Building distributed databases (Dynamo, Cassandra-style)

### Tomorrow’s Preview

Day 17 marks the start of **Week 4: Real-World Applications**. We’ll apply everything we’ve learned to design actual systems, starting with social media feed design patterns.

### Your Architect Assignment

1. **Map coordination needs** What operations need single leader?
2. **Identify consistency requirements** Strong vs eventual consistency?
3. **Check for conflicts** Where can concurrent updates happen?
4. **Plan for failures** What happens when leader/nodes fail?

Remember: **Distributed systems are hard because nothing is reliable. Leader Election gives you coordination, Raft gives you consensus, Vector Clocks give you causality. These patterns are battle-tested solutions to fundamental distributed systems problems.**

*Previous articles:*

- [*Day 1 Building Your Architect Mindset*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-1-building-your-architect-mindset-7b7c9a51c1c1)
- [*Day 2 Strategy & Observer Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-2-strategy-observer-patterns-for-system-design-f2746aa51abf)
- [*Day 3 Decorator & Proxy Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/day-3-decorator-proxy-patterns-adding-superpowers-without-surgery-67574c252164)
- [*Day 4 Singleton & Builder Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-4-singleton-builder-patterns-the-right-way-56a8a1be9bc4)
- [*Day 5 Command & Template Method Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-5-command-template-method-patterns-e7962394852c)
- [*Day 6 Adapter & Facade Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-8d9cfb8d8f48)
- [*Day 7 Chain of Responsibility & State Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-7-chain-of-responsibility-state-patterns-b7a47d1bae18)
- [*Day 8 Load Balancing & Circuit Breaker Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-8-load-balancing-circuit-breaker-patterns-2179b22a03ed)
- [*Day 9 Database Patterns & Repository Pattern*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-9-database-patterns-repository-pattern-9852d93d3172)
- [*Day 10 Caching Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-10-caching-patterns-ec46f1d9efd9)
- [*Day 11 API Gateway & Proxy Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-11-api-gateway-proxy-patterns-7b97233b5406)
- [*Day 12 Message Queue Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-12-message-queue-patterns-e92371d34a7c)
- [*Day 13 Event Sourcing & CQRS Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-13-event-sourcing-cqrs-patterns-1d150749edf7)
- [*Day 14 Monitoring & Observer Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-14-monitoring-observer-patterns-cdd2bba68d9f)
- [*Day 15 Microservices Patterns*](https://archive.is/o/uXpXa/https://medium.com/@kanishks772/learn-system-design-with-me-day-15-microservices-patterns-532c7a4ab899)

*Follow along daily as we complete Week 3’s advanced distributed system patterns and prepare for Week 4’s real-world system design applications.*

[0%](https://archive.is/uXpXa#0%) [10%](https://archive.is/uXpXa#10%) [20%](https://archive.is/uXpXa#20%) [30%](https://archive.is/uXpXa#30%) [40%](https://archive.is/uXpXa#40%) [50%](https://archive.is/uXpXa#50%) [60%](https://archive.is/uXpXa#60%) [70%](https://archive.is/uXpXa#70%) [80%](https://archive.is/uXpXa#80%) [90%](https://archive.is/uXpXa#90%) [100%](https://archive.is/uXpXa#100%)