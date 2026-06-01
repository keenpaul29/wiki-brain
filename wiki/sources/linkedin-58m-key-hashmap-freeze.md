---
title: "The 58-Million-Key Freeze: What a HashMap Resize Taught Us About Memory Allocation at Scale"
type: source
created: 2026-06-01
tags:
  - source
  - linkedin
  - fishdb
  - rust
  - performance
  - memory
  - debugging
---

# The 58-Million-Key Freeze: HashMap Resize at Scale

## Summary

LinkedIn's Feed Retrieval platform (FishDB, Rust-based) suffered intermittent 15-second freezes affecting availability SLOs. After an investigation combining automated profiling instrumentation with deep cross-layer analysis — from application data structures to Linux kernel internals — engineers traced the root cause to a single HashMap resize event at approximately 58.7 million keys.

The HashMap used the `hashbrown::HashMap` (Rust's standard HashMap implementation, based on Google's SwissTable). During resize, jemalloc would call `brk()` to extend the heap, which acquires the `mmap_lock` in the Linux kernel. This lock is also acquired during page faults. The Tokio async runtime's stackless coroutines share the same address space, so a page fault in any task would contend on the same `mmap_lock` held by the resizing thread, effectively freezing the entire runtime. The fix: pre-allocate the HashMap with `HashMap::with_capacity()`.

## Key Ideas

- Root cause: HashMap resize → jemalloc `brk()` → kernel `mmap_lock` contention → async runtime freeze.
- The Tokio async runtime's cooperative scheduling means one task blocking on a kernel lock blocks all tasks.
- Cross-layer debugging: from application data structures through allocator to kernel internals.
- The fix was a single line: pre-allocating capacity `HashMap::with_capacity(capacity)`.
- Instruments automated profiling: recorded stack traces at 1ms intervals with low overhead to catch intermittent events.
- FishDB uses Rust, jemalloc, Tokio, and hashbrown::HashMap (SwissTable).
- Deployed across 48 shards, ~1.75 GB memory per shard for the doc-ref map.

## Links

- Supports [[concepts/fishdb|FishDB]]
- Supports [[concepts/reliability-and-operations|Reliability and Operations]]
- Supports [[concepts/system-design|System Design]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Supports [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
