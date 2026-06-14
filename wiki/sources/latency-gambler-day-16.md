---
title: "Distributed System Patterns"
type: source
created: 2026-06-14
source: https://archive.is/uXpXa
tags:
  - source
---

# Distributed System Patterns

## Summary

Day 16 of The Latency Gambler's system design series. Covers Leader Election (with heartbeat-based voting), Raft Consensus Algorithm (leader election, log replication, commit index), Vector Clocks (distributed causality and conflict detection), and production monitoring for distributed coordination.

## Key Ideas

- **Leader Election**: Ensures exactly one node is the leader at any time. Uses heartbeat monitoring, election timeouts, and majority voting to elect a leader and detect failures.
- **Raft Consensus Algorithm**: Three states (Leader, Candidate, Follower). Uses terms as logical clocks, append-only logs, and majority-based commit. Leader handles all client requests and replicates to followers.
- **Raft Log Replication**: Leader appends entry to its log, replicates to followers, commits once majority acknowledges. ConflictTerm backtracking handles log inconsistencies.
- **Vector Clocks**: Track causality relationships between events in distributed systems. Detect happened-before relationships, concurrent updates, and conflicts.
- **Conflict Resolution**: Last-Write-Wins (LWW) by timestamp or custom merge resolvers for application-specific conflict resolution.
- **Monitoring Consensus**: Track leader election success/duration, replication lag, and conflict counts.
- **Raft Safety & Availability**: Raft guarantees at most one leader per term (Election Safety), appends entries in a single order (Log Matching), and commits entries only after they've been durably stored on a majority (Leader Completeness). A cluster of 2N+1 nodes tolerates N failures.
- **Gossip Protocols for Member Discovery**: In large clusters, peer-to-peer gossip (SWIM protocol, lifeguard refinements) propagates membership changes faster than central registry polling, at the cost of probabilistic convergence guarantees.
- **Practical Consensus Engineering**: Production Raft deployments (etcd, Consul) add pre-vote checks to avoid spurious leader elections under network partitions and use learner nodes to join new replicas without affecting quorum.

## Links

- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Connects to [[concepts/reliability-and-operations|Reliability and Operations]]
- Connects to [[concepts/system-design|System Design]]
- Connects to [[concepts/distributed-coordination|Distributed Coordination and Consensus]]
- Connects to [[concepts/resilience-patterns|Resilience and Fault Tolerance Patterns]]
- Connects to [[concepts/microservices-architecture|Microservices Architecture]]
