---
title: "Raft Consensus Explained"
type: source
created: 2026-06-06
source: https://backendbytes.com/articles/understanding-raft-consensus/
author: "BackendBytes Engineering Team"
tags:
  - source
  - distributed-systems
  - consensus
  - raft
  - system-design
---

# Raft Consensus Explained

## Summary

Deep dive into the Raft consensus algorithm covering leader election (randomized timeouts, term persistence, up-to-date vote check), log replication (AppendEntries, ConflictTerm backtracking, commit-index rule), safety properties (election safety, leader append-only, log matching, leader completeness, state machine safety), and production operations for etcd (leader churn alerting, snapshot/restore procedures, apply timeout separation, quorum math).

## Key Ideas

- Raft tolerates (N-1)/2 failures. 3 nodes → 1 failure tolerated, 5 nodes → 2, 7 nodes → 3.
- Leader election uses randomized timeouts (150-300ms) to prevent split-brain. A candidate must have a log at least as up-to-date as the voter.
- ConflictTerm backtracking optimizes log reconciliation: when a follower rejects AppendEntries, the leader skips entire terms at once.
- Commit index rule: only advance commitIndex for entries from the current term. Previous-term entries commit transitively via the Log Matching Property (Figure 8).
- Five safety properties guarantee correctness across reboots, partitions, and leader changes.
- Production alerting: `increase(etcd_server_leader_changes_seen_total[10m]) > 3` triggers investigation of disk fsync latency and peer round-trip time.
- Raft is CP — the minority side rejects reads/writes during a partition.
- Separate Raft timeout (5s) from request context cancellation; never use the HTTP context as the Apply timeout.

## Links

- Supports [[concepts/reliability-and-operations|Reliability and Operations]]
- Supports [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Supports [[concepts/system-design|System Design]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
