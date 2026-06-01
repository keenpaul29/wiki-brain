---
title: "The 58-Million-Key Freeze: What a HashMap Resize Taught Us About Memory Allocation at Scale"
source: "https://www.linkedin.com/blog/engineering/feed/the-58-million-key-freeze-what-a-hashmap-resize-taught-us-about-memory-allocation-at-scale"
author:
  - "[[Rajeev Kumar]]"
published: 2026-05-21
created: 2026-06-01
description:
tags:
  - "clippings"
---
## Introduction

LinkedIn's Feed is the central experience for over a billion members - it's where they discover relevant content, engage with their network, and stay informed. Behind the scenes, serving the Feed depends on a chain of infrastructure components that must respond reliably in milliseconds. When one of those components starts freezing for 15 seconds at a time, the Feed experience for members is degraded. That’s exactly what we saw happen.

Our Feed Retrieval platform - powered by [FishDB](https://www.linkedin.com/blog/engineering/infrastructure/fishdb-a-generic-retrieval-engine-for-scaling-linkedins-feed), a Rust-based storage and retrieval engine - began experiencing intermittent availability drops. Entire shards would breach their availability SLO (Service Level Objective), then recover before engineers could investigate. The issue was elusive: no logs during the freeze, no obvious trigger, and no way to reproduce it on demand. Different shards were affected at different times, and the breaches lasted barely a minute.

By devising a novel automated profiling instrumentation and performing deep cross-layer analysis - from application data structures to Linux kernel internals - we traced the root cause to a single HashMap resizing at approximately 58.7 million keys, which triggered a cascade of kernel-level lock contentions that froze our entire async runtime. The fix was deceptively simple - a single line of code - but the *path to finding it* was not. This blog chronicles the investigation, the technical details of the root cause, and the lessons we learned along the way.

## FishDB and the Feed

FishDB is the foundational storage and retrieval layer for LinkedIn's Feed. Written in Rust with [jemalloc](https://github.com/jemalloc/jemalloc) as its memory allocator and [Tokio](https://tokio.rs/) as its async runtime, FishDB performs initial candidate selection for Feed activities. The service is deployed across 48 shards, and uses an [Envoy](https://www.envoyproxy.io/) proxy sidecar for traffic management (e.g., load shedding).

FishDB maintains several index structures in memory to support low-latency retrieval. The most relevant to this experience is the document reference index - a HashMap that maps primary keys to internal document references (doc-refs), enabling efficient lookups during query execution. At the time of the incident, this map held approximately 56–59 million entries per shard, consuming roughly 1.75 GB of memory.

For a deeper look at FishDB's architecture, query engine, and index design, see our earlier blog post: [FishDB: a generic retrieval engine for scaling LinkedIn's feed](https://www.linkedin.com/blog/engineering/infrastructure/fishdb-a-generic-retrieval-engine-for-scaling-linkedins-feed).

## The Mystery: Elusive Availability Drops

The problem surfaced as recurring 1-minute breaches of FishDB's availability SLO - defined as the ratio of successful (non-500) responses to total responses at the shard level, with a target of 99.9%. These breaches would appear, resolve themselves, and leave almost no trace.

![Shard-level availability over a ~40-minute window showing three different shards (colored lines) experiencing brief availability dips at different times. Each dip breaches the 99.9% SLO target, auto-resolves within approximately one minute, and occurs independently across shards.](https://media.licdn.com/dms/image/v2/D4D08AQGT88Evzy7-Ug/croft-frontend-shrinkToFit767/B4DZ5I4vhLJ4AQ-/0/1779339296873?e=2147483647&v=beta&t=syY_P5LPMfqOEANZ213FBj_loxFMYnYpVtD1WQoLoqQ)

Figure 1. Shard-level availability

The characteristics that made this particularly difficult to investigate:

- **Ephemeral**: Each breach lasted only 10-15 seconds. By the time an alert fired and an engineer could look, the issue had already been resolved.
- **Silent**: During the freeze, the application produced zero logs. Health checks went unanswered. It was as if the process had paused entirely.
- **Sporadic**: Different shards were affected at different times, with no obvious pattern in timing.
- **No trigger**: There had been no deployment changes, no traffic spikes, and no data ingestion anomalies.

Correlation analysis revealed the first critical clue: every availability drop coincided with a **spike in RSS** (Resident Set Size) memory. RSS would jump approximately ***4 GB above its baseline momentarily***, then settle back to a persistent ***~2 GB increase over the previous baseline***. This pattern was consistent across hosts in an affected shard.

![RSS memory spike (top) correlated with availability breach (bottom) on the same host. RSS jumps ~4 GB momentarily then persists ~2 GB above the previous baseline; availability drops simultaneously to ~94.5% and recovers within approximately one minute.](https://media.licdn.com/dms/image/v2/D4D08AQGtMdaQBrS6iw/croft-frontend-shrinkToFit600/B4DZ5I5Oa4G4Ac-/0/1779339423767?e=2147483647&v=beta&t=1nnLlD1Z36KLSW4ZYypNXOGgdFxjXygJ86KtpHoxrjU)

Figure 2. RSS memory spike

The fact that all hosts in a shard spiked simultaneously ruled out hot queries or bad traffic - this was a systemic, data-driven issue. But what was causing it?

## The Elimination Process

Before reaching for advanced profiling tools, we systematically eliminated the most probable causes using available observability metrics.

**CPU throttling.** Container-level CPU throttling can cause momentary unresponsiveness. We verified via cgroup metrics that throttling was negligible - our containers had ample CPU headroom.

**Kernel-level memory defragmentation.** Linux can stall processes during memory compaction events. We checked allocstall counters in /proc/vmstat on affected hosts - all zeros. No allocation stalls were occurring at the kernel level.

**Envoy proxy sidecar.** FishDB runs behind an Envoy proxy sidecar, which handles inbound traffic. If Envoy itself was freezing or dropping connections, it could explain the availability dip. We ruled this out by comparing two sets of metrics: application-layer metrics (reported by FishDB itself, bypassing Envoy) and transport-layer metrics (reported by Envoy). Both showed the same availability dip simultaneously, confirming that the application itself was freezing, not the proxy.

**Memory-mapped file I/O.** FishDB uses [RocksDB](https://rocksdb.org/) for disk-backed attribute storage. If RocksDB's memory-mapped I/O was causing page faults under contention, it could explain the freeze. However, we confirmed that mmap-based read and write operations were disabled in our RocksDB configuration, ruling out disk-backed storage as a contributing factor and confirming the issue was isolated to in-memory data structures.

With conventional monitoring and metrics exhausted, we had no clear culprit. We needed to look deeper - into what was happening at the OS and runtime level during the freeze itself.

## Building the Trap: Off-CPU Profiling with eBPF

Traditional CPU profiling shows what threads are *doing* - but our threads weren't doing anything. They were frozen. What we needed was off-CPU profiling: a technique that shows what threads are *waiting on*.

The challenge was timing. The freeze lasted only 10-15 seconds and occurred unpredictably across hundreds of hosts. We couldn't debug reactively - by the time we noticed a freeze, it was already over.

Our solution was to build a trap. We wrote a monitoring script that would automatically capture an off-CPU profile the instant a freeze was detected. The script works as follows:

1. It continuously sends a health check request to a known FishDB endpoint with a short timeout.
2. If the health check times out (indicating a freeze is in progress), it immediately triggers [offcputime](https://github.com/iovisor/bcc/blob/master/tools/offcputime.py) from the [BCC](https://github.com/iovisor/bcc) toolkit - an eBPF-based tool that records kernel stack traces of threads that are blocked or sleeping.
3. The profiling runs for 15 seconds, capturing the full duration of the freeze.
4. Results are written to a local file for later analysis.

The script runs at the host level (not inside the container) because eBPF requires host-level kernel access. We deployed it across dozens of hosts in multiple shards to maximize the chance of capturing the ephemeral event.

Once the scripts were in place, ***we successfully captured a profile during a live freeze***. This was the key breakthrough - these events were too brief for conventional monitoring to capture the underlying cause, so the only way to observe the root cause was to have profiling instrumentation already in place when the freeze began.

## The Eureka Moment: mmap\_lock Contention

The off-CPU profile captured during the freeze revealed the root cause. Three kernel stack trace patterns stood out in the profile:

**Stack trace 1: Write lock acquisition in the mmap path**

Multiple threads were blocked in [rwsem\_down\_write\_slowpath](https://github.com/torvalds/linux/blob/master/kernel/locking/rwsem.c#L1111) - the Linux kernel function that waits to acquire a read-write semaphore in write mode. The call path showed a large memory allocation via mmap, which requires an exclusive (write) lock on the process-wide mmap\_lock (also known as mmap\_sem or the VMA semaphore).

**Stack trace 2: Read lock blocked in the madvise path**

Other threads were blocked in [rwsem\_down\_read\_slowpath](https://github.com/torvalds/linux/blob/master/kernel/locking/rwsem.c#L993) - waiting to acquire the same lock in read mode. The call path traced through madvise, which is how jemalloc purges unused memory pages back to the operating system.

**Stack trace 3: Read lock blocked in the page fault path**

Additional threads were blocked in rwsem\_down\_read\_slowpath while handling page faults. During thread creation and normal memory access, the kernel resolves page faults via do\_user\_addr\_fault, which also requires the mmap\_lock in read mode - and was therefore blocked by the ongoing write lock.

![Annotated off-CPU profile captured during a live freeze, showing the three stack trace paths converging on the kernel's process-wide mmap_lock. Path A holds the write lock during a large memory allocation; Paths B and C are blocked waiting for the read lock. Contextual labels marked with * are inferred from the investigation (see note); all kernel function names are directly from the raw eBPF trace.](https://media.licdn.com/dms/image/v2/D4D08AQHNaF6DUY8PHw/croft-frontend-shrinkToFit1024/B4DZ5JEvrUKAAc-/0/1779342443842?e=2147483647&v=beta&t=I-CU8eL0ue_LY8VmPuQGG9iC-O-xAw0K9Vw8ahktidw)

Figure 3. Annotated off-CPU profile

The mechanism became clear:

Linux's mmap\_lock is a process-wide read-write semaphore that protects the virtual memory area (VMA) data structures. Any operation that modifies the process's virtual address space - such as a large mmap allocation - must hold this lock in write mode. While the write lock is held, all other threads that need any memory operation (including madvise for purging, and page fault handling for I/O) are blocked.

In this particular case:

1. A large memory allocation - too large for jemalloc's internal free lists - triggered a direct mmap syscall, acquiring the mmap\_lock in write mode.
2. Jemalloc's background purging, which uses madvise to release unused pages, was blocked because it needs the mmap\_lock in read mode.
3. Tokio worker threads servicing requests encountered page faults during normal memory access. Resolving page faults also requires the mmap\_lock - so these threads were blocked too.
4. Tokio's async runtime uses a fixed pool of OS worker threads. When a worker thread is blocked on a kernel lock, it cannot service any other async tasks. With all worker threads blocked on mmap\_lock, no requests could be processed.
5. The result: complete application freeze - zero logs, zero health check responses - for the duration of the large allocation.

The question remained: what was causing the large mmap allocation?

## The Root Cause: The Magic Number 58,720,256

With the mmap\_lock contention identified, we needed to find what was triggering the massive memory allocation. Further analysis pointed to the document reference index - the in-memory HashMap (pkey\_vs\_docref) that maps primary keys to internal document references.  
Rust's standard library HashMap roughly doubles its allocated capacity when it runs out of room for new entries. The map was growing by approximately 2–3 million keys per day as new content was ingested.

| Resize trigger (keys) | New capacity | Approx. memory (32 bytes/entry) |
| --- | --- | --- |
| 14,680,065 | 29,360,128 | ~0.87 GB |
| 29,360,129 | 58,720,256 | ~1.75 GB |
| 58,720,257 | 117,440,512 | ~3.5 GB |

When the number of entries exceeded the HashMap's current capacity of ***58,720,256,*** it triggered a resize - doubling to ***117,440,512*** entries. With each entry consuming approximately 32 bytes (key + value), this meant:

- **Old buffer**: 58,720,256 × 32 bytes ≈ **1.75 GB**
- **New buffer**: 117,440,512 × 32 bytes ≈ **3.5 GB**

During the resize, both buffers must coexist in memory - the new buffer is allocated via mmap (triggering the write lock), entries are copied from old to new, and then the old buffer is freed. This sequence produced the exact memory pattern we observed:

| Observation | Explanation |
| --- | --- |
| ~4 GB momentary RSS spike | Old (~1.75 GB) and new (~3.5 GB) buffers coexisting during resize |
| ~2 GB persistent RSS increase | New buffer retained after old buffer is freed |
| Happens only once per host lifecycle | Resize triggers exactly once at this capacity boundary |
| Started appearing recently | Year-end data reduction caused maps to start below the threshold after reboots, reaching it after 2–3 days of growth |

![RSS memory spike (top) correlated with DocRefIndexKeyCount (bottom) crossing the ~58.72M threshold at 08:29. The key count's steady upward growth crosses the HashMap capacity boundary at the precise moment of the RSS spike, confirming the resize as the trigger.](https://media.licdn.com/dms/image/v2/D4D08AQG-eaBEiV39Wg/croft-frontend-shrinkToFit1024/B4DZ5JAnVPH4Ag-/0/1779341362688?e=2147483647&v=beta&t=SdPie7cqLUd1xGwnavbZMj7Q_X_f0HuBsUc8nQKmj-Q)

Figure 4. RSS memory spike

The DocRefIndexKeyCount metric confirmed it: at the exact moment of each RSS spike and availability breach, the HashMap had reached approximately 58.7 million keys.

This also explained the cascading pattern we observed - hosts within a shard would freeze in sequence over a span of approximately 3 seconds. Since all hosts in a shard ingest the same data, they reached the threshold at nearly the same time.

## The Fix

The fix was straightforward: pre-allocate the HashMap with approximately 3x the base index size at startup using Rust's HashMap::with\_capacity(). This ensures the map has sufficient capacity from the start, preventing the catastrophic mid-operation resize at the 58,720,256-key boundary.

// Before: HashMap grows dynamically, triggering a massive resize at ~58.7M keys

let map = HashMap::new();

// After: Pre-allocate with sufficient capacity to avoid mid-operation resize

let map = HashMap::with\_capacity(base\_index\_size \* 3);

The trade-off is approximately 3 GB of extra RSS at startup - a cost we considered acceptable given the alternative of periodic 15-second application freezes.

After deployment, we monitored the DocRefIndexKeyCount metric closely. When a shard crossed the 58.7-million-key threshold, there was **zero SLO impact** - no RSS spike, no availability breach, no freeze. The root cause was confirmed.

## Conclusion

A single line of pre-allocation code fixed a cascading failure that spanned from a user-space data structure to a memory allocator to the kernel virtual memory subsystem to an async runtime. The investigation taught us several lessons that we believe are broadly applicable:

**Pre-allocate large data structures.** Rust's HashMap::with\_capacity() - and equivalent APIs in other languages - exist for a reason. In high-memory services, the cost of extra upfront memory is negligible compared to the risk of a catastrophic mid-operation resize. When a data structure is expected to hold millions of entries, dynamic growth is a liability.

**Off-CPU profiling with eBPF is essential for diagnosing silent freezes.** While traditional application metrics helped us identify the pattern and rule out several suspects, they could not reveal what was happening during the freeze itself - our threads weren't busy, they were blocked. Off-CPU profiling revealed what they were waiting on, leading directly to the root cause.

**Large, infrequent memory allocations can create process-wide contention.** When an allocation is large enough to go through mmap (rather than the allocator's internal free lists), it acquires the Linux kernel's process-wide mmap\_lock. In applications with many concurrent threads - especially those using async runtimes like Tokio - this can serialize all memory operations and freeze the entire process.

**When bugs are too ephemeral to catch reactively, build automated instrumentation that lies in wait.** The freeze lasted only 10-15 seconds and left no actionable diagnostic trace in conventional monitoring. The only way we caught it was by deploying profiling scripts that would trigger automatically when the freeze began. This experience has also motivated us to develop an always-on observability sidecar for proactive detection of such transient anomalies in the future.

## Acknowledgements

This investigation was a collaborative effort across the Information Retrieval Platform and Service Infrastructure teams, with strong support from our engineering leadership-we’d like to thank everyone who contributed to triaging and fixing this issue.

Information Retrieval Platform (FishDB): [Rajeev Kumar](https://www.linkedin.com/in/rajeevkumar6/), [Rajdeep Das](https://www.linkedin.com/in/rajdeep-das-5586a5b2/), [Jaiwant Rawat](https://www.linkedin.com/in/jaiwant-rawat-97493982/), [Tulika Saxena](https://www.linkedin.com/in/tulikasaxena21/), [Vishnu Pandey](https://www.linkedin.com/in/vishnu-pandey-6a9922a4/), [Siddharth Singh](https://www.linkedin.com/in/siddharth-singh-532a53128/), [Pratikmohan Srivastav](https://www.linkedin.com/in/pratikmohan-srivastav-94b22616a/)

System Infrastructure: [Jeff Jiang](https://www.linkedin.com/in/jeff-jiang-65897b1a/), [Alex Dubrouski](https://www.linkedin.com/in/sinister/), [Harrison Liang](https://www.linkedin.com/in/harrison-l-2738bb103/)

We would like to specially thank Alex Dubrouski for guiding the off-CPU profiling approach and helping analyze the flamegraph that revealed the mmap\_lock contention.