---
title: Distributed Coordination and Consensus
type: concept
created: 2026-06-14
tags:
  - concept
  - distributed-systems
  - consensus
  - system-design
---

# Distributed Coordination and Consensus

Distributed coordination solves the fundamental problem of multiple nodes agreeing on shared state when any node can fail, messages can be delayed or lost, and clocks drift. These patterns are the bedrock of replicated databases, distributed locks, configuration stores, and any system that needs consistent state across machines.

## Leader Election: Choosing a Coordinator

### The Problem

In a distributed system with multiple nodes, many operations require a single coordinator: database primary for writes, task scheduler, lock manager, or cache invalidation broadcaster. Without a leader, nodes conflict. With multiple leaders, split-brain corrupts state.

### Heartbeat-Based Election

The simplest production-grade leader election uses heartbeats and timeout-based failover:

1. **Followers** expect periodic heartbeats from the leader.
2. If a follower misses N heartbeats within a timeout window, it transitions to **candidate**.
3. The candidate requests votes from all nodes. It votes for itself.
4. If it receives a **majority** (N/2 + 1) of votes, it becomes leader.
5. The new leader starts sending heartbeats to all nodes.

A node that receives a heartbeat from a legitimate leader while campaigning steps down immediately. This prevents split-brain when the old leader was merely partitioned, not dead.

### Common Problem: Split-Brain

Split-brain occurs when a network partition divides the cluster and both sides elect a leader. Both leaders accept writes, and when the partition heals, the data diverges irreconcilably.

**Solutions:**
- **Quorum-based writes**: Require W + R > N (quorum overlap ensures at least one node has the latest write).
- **Fencing tokens**: A monotonically increasing token issued by the coordination service. A leader with an old token is ignored.
- **Lease-based leadership**: The leader holds a time-limited lease from a coordination service. Expired leases are automatically vacated.

## Raft Consensus Algorithm

Raft is the most widely taught consensus algorithm because it decomposes into independently understandable pieces: leader election, log replication, safety, and membership changes.

### Three Node States

| State | Behavior |
|-------|----------|
| **Leader** | Handles all client requests, replicates log entries to followers |
| **Candidate** | Campaigning to become leader, requests votes |
| **Follower** | Replicates leader's log, responds to RPCs, starts election on timeout |

### Key Concepts

- **Term**: A logical clock that advances with each election. Each term can have at most one leader.
- **Log**: An ordered, append-only sequence of commands. Every node maintains a log.
- **Commit Index**: The highest log entry known to be safely replicated to a majority of nodes.
- **Quorum**: For any decision, a majority (N/2 + 1) of nodes must agree.

### Log Replication

1. Client sends a command to the leader.
2. Leader appends the command to its local log.
3. Leader sends `AppendEntries` RPC to all followers with new entries and metadata.
4. Followers append entries to their logs and acknowledge.
5. Once the leader receives acknowledgments from a majority, it commits the entry (applies it to state machine) and notifies followers.

### Safety Properties

Raft guarantees five safety properties:

1. **Election Safety**: At most one leader can be elected in a given term.
2. **Leader Append-Only**: A leader never overwrites or deletes entries in its log, only appends new ones.
3. **Log Matching**: If two logs contain an entry with the same index and term, the logs are identical in all preceding entries.
4. **Leader Completeness**: A committed entry is present in the logs of all future leaders.
5. **State Machine Safety**: If a server has applied a log entry at a given index to its state machine, no other server will ever apply a different entry at the same index.

### Conflict Resolution

When a leader discovers that a follower's log diverges (e.g., after a crash), it finds the latest common entry and truncates the follower's log from that point, then replicates its own entries from that point forward. This is called **ConflictTerm backtracking**.

### When to Use Raft

Raft is ideal for strongly consistent metadata stores (etcd, Consul, CockroachDB). It is CP under the CAP theorem — it sacrifices availability during partition. It is not suitable for high-throughput write workloads where eventual consistency is acceptable.

## Vector Clocks: Tracking Causality

### The Problem

In distributed systems, there is no global clock. Two events on different machines cannot be ordered by wall-clock time alone because clocks drift. Vector clocks track **causal relationships** without synchronized time.

### How Vector Clocks Work

Each node maintains a logical clock (a map of node ID → counter):

- **Increment** on local event: increment your own counter.
- **Merge** on receiving a remote event: take the per-node max of local and remote clocks, then increment your own.
- **Compare** two vector clocks:
  - Clock A happened-before Clock B if every entry in A ≤ B and at least one is strictly less.
  - A and B are **concurrent** if neither happened-before the other (A has some entry > B, B has some entry > A).

### Conflict Detection

When a key-value store uses vector clocks, two writes are concurrent if their vector clocks are concurrent. The store retains both versions (sibling values) and requires conflict resolution:

- **Last-Write-Wins (LWW)**: Timestamp-based, simple but can lose data.
- **CRDT-based merge**: Application-defined commutative merge functions.
- **Present both to user**: Allow the client to resolve (Amazon Shopping Cart pattern).

### Vector Clocks vs. Hybrid Logical Clocks

Vector clocks grow linearly with the number of nodes (O(n) per entry), which limits scalability. **Hybrid Logical Clocks** (HLCs) combine physical time with a logical counter, providing causality tracking with O(1) metadata per message. HLCs are preferred in systems with hundreds or thousands of nodes.

## Coordination Services in Practice

### ZooKeeper vs. etcd vs. Consul

| Feature | ZooKeeper | etcd | Consul |
|---------|-----------|------|--------|
| Consensus | ZAB (ZooKeeper Atomic Broadcast) | Raft | Raft |
| API | Hierarchical znodes | gRPC key-value | HTTP/gRPC key-value |
| Watch model | Persistent watches per znode | Watch streams per key range | Blocking queries |
| Service discovery | Via znodes + watches | Via keys + TTL | Built-in DNS + health checks |
| Use case | Coordination-heavy, Java ecosystem | Kubernetes, cloud-native | Service mesh, multi-datacenter |

### Common Coordination Patterns

- **Distributed locks**: A lock is a key + TTL + fencing token. Never rely on TTL alone for correctness — always use fencing.
- **Service registry**: Services register themselves with a TTL-based heartbeat. Consumers watch for changes.
- **Configuration management**: Store configuration at a known path. Watchers reload on change.
- **Leader election**: Compete for an ephemeral key. The creator is leader; loss of connection releases it.

## Raft in Production: etcd Operations

[[sources/raft-consensus-explained|Raft Consensus Explained]] provides production guidance for operating Raft-based systems like etcd:

- **Disk I/O sensitivity**: Raft's heartbeats and log replication depend on low-latency disk writes. A slow disk (high I/O wait) delays `AppendEntries` responses, causing spurious leader elections. Use dedicated SSDs with fsync latency < 1ms.
- **Network latency**: inter-node RPCs must complete within the election timeout (typically 150-300ms). Cross-datacenter clusters need higher timeouts and tolerate longer leader election windows.
- **Quorum math for scaling**: a 3-node cluster tolerates 1 failure; 5 nodes tolerate 2. Beyond 7 nodes, write latency increases significantly because the leader must replicate to a majority. For read-only workloads, add follower nodes that are not in the voting set.
- **Leader election storms**: if the leader's disk stalls or network glitches, all followers detect timeout simultaneously and start elections. The cluster enters a cycle of failed elections until the timeout stabilizes. Mitigation: staggered election timeouts (random per node), pre-vote extension (candidates check if they could win before starting election).
- **Defragmentation**: etcd's storage (boltdb) suffers from page fragmentation as keys are created and deleted. Regular defragmentation (`etcdctl defrag`) recovers space and improves read performance. Schedule during low traffic.

## Gossip Protocols and Epidemic Broadcast

Not every distributed system needs consensus. When eventual consistency is acceptable, gossip protocols provide a simpler coordination mechanism:

### How Gossip Works

Each node periodically picks a random peer and exchanges state summaries. Information spreads exponentially — after O(log N) rounds, every node has the information.

### When to Use Gossip

- **Membership detection**: new nodes join, failed nodes leave. Gossip-based membership (SWIM, Serf) detects failures without a central registry.
- **Configuration propagation**: feature flags, routing tables, or allowlists that need eventual propagation without strong consistency.
- **Load metrics aggregation**: CPU, memory, and request rates shared across nodes for load-balancing decisions.

### Weaknesses

- No strong consistency guarantees — information is propagated "best effort" within a convergence window.
- Convergence time depends on the gossip interval and fanout. A 1-second gossip interval with fanout 3 takes ~log₃(N) seconds to converge.
- Not suitable for leader election or distributed locking.

Hybrid pattern: use gossip for membership and health detection (fast, decentralized). Use Raft/etcd for leader election and configuration storage (consistent, authoritative).

## Production Considerations

### Monitoring Consensus Health

Track these metrics:
- Leader election count and duration (elections indicate instability)
- Log replication lag per follower
- Commit index vs. last applied (stale followers)
- Term changes (frequent term bumps suggest network issues)

### Consistency vs. Availability Decision Framework

| Requirement | Approach |
|-------------|----------|
| Strong consistency, partition-tolerant | Raft/Paxos (CP) |
| High availability, partition-tolerant | Gossip + vector clocks + CRDTs (AP) |
| Causal consistency | Hybrid Logical Clocks |
| Read-your-writes | Session guarantees + primary reads after writes |
| No coordination needed | Eventual consistency |

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/microservices-architecture|Microservices Architecture]]
- Source: [[sources/latency-gambler-day-16|Distributed System Patterns]]
- Source: [[sources/raft-consensus-explained|Raft Consensus Explained]]
- Source: [[sources/latency-gambler-day-15|Microservices Patterns]]
- Source: [[sources/latency-gambler-day-17|Resilience Patterns]]
