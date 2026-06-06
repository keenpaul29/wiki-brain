---
title: "Understanding Raft Consensus: The Algorithm That Keeps Your Database Honest"
source: "https://backendbytes.com/articles/understanding-raft-consensus/"
author:
  - "BackendBytes Engineering Team"
published: 2025-01-02
created: 2026-06-06
description: "A deep dive into the Raft consensus algorithm covering leader election, log replication, safety properties, and production operations for engineers running etcd, Consul, or CockroachDB."
tags:
  - "clippings"
---

## Raft Consensus Explained

Raft is a consensus algorithm that tolerates (N-1)/2 failures by electing a leader, replicating a log, and committing entries only when replicated to a majority. Used by etcd (Kubernetes), Consul, CockroachDB, TiKV, and HashiCorp Vault.

### Key Invariants

- Only one leader per term (majority voting prevents split brain)
- Leaders always have all previously committed entries (up-to-date vote check)
- Log matching with term numbers guarantees consistency across reboots and partitions

### Leader Election

Nodes are Followers, Candidates, or Leaders. Each has a `currentTerm` (persisted) and `votedFor` (persisted). When a follower's heartbeat times out (150-300ms randomized), it becomes a Candidate, increments term, votes for itself, and sends `RequestVote` to peers.

Vote granted only if:
1. Candidate's term >= voter's currentTerm
2. Voter hasn't already voted this term
3. Candidate's log is at least as up-to-date as voter's (higher last-term wins; longer log wins on tie)

Critical: `persist()` must be called BEFORE responding to RPCs. If a node crashes after responding but before persisting, it can vote twice.

### Log Replication

Leader receives client requests, appends to log (uncommitted), sends `AppendEntries` to followers in parallel. On majority ack, commit and apply to state machine. Followers learn commitIndex from the next heartbeat.

**ConflictTerm backtracking:** when a follower rejects AppendEntries, the ConflictIndex/ConflictTerm fields let the leader skip entire terms at once instead of decrementing one entry at a time.

**Commit index rule:** only advance commitIndex for entries from the current term. Previous-term entries become committed transitively via the Log Matching Property (Figure 8 in the Raft paper).

### Safety Properties

- Election Safety: at most one leader per term
- Leader Append-Only: leaders never overwrite/delete entries
- Log Matching: same index/term implies identical prefixes
- Leader Completeness: committed entries present in all future leaders
- State Machine Safety: if one node applies entry at index i, no other node applies a different entry at i

### Production Operations

**Status check:** `etcdctl endpoint status --write-out=table` — matching RAFT TERM = no recent election storm; trailing RAFT INDEX > 10k = needs snapshot install.

**Alert on leader churn:** `increase(etcd_server_leader_changes_seen_total[10m]) > 3` triggers investigation of disk fsync latency and peer round-trip time.

**Apply timeout:** Use separate Raft timeout (5s) and request context (cancellation only) — never use the HTTP context as the Raft Apply timeout.

**Snapshot/restore:** snapshot from healthy member → scp to new node → stop etcd → `etcdctl snapshot restore` with matching `--initial-cluster-token` → start. Practice quarterly.

### Quorum

| Nodes | Failures Tolerated |
|-------|-------------------|
| 1 | 0 |
| 3 | 1 |
| 5 | 2 |
| 7 | 3 |

Raft is a CP system — the minority side rejects reads/writes during a partition.
