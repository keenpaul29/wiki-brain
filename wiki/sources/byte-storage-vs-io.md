---
title: "Byte Storage vs. I/O"
type: source
created: 2026-06-05
source: https://thecodinggopher.substack.com/p/byte-storage-vs-io
author: "The Coding Gopher"
tags:
  - source
  - storage
  - system-design
---

# Byte Storage vs. I/O

## Summary

Explains the difference between storage capacity and storage performance. Byte storage is how much data a system can hold; I/O is how quickly data can be moved between storage, memory, CPU, and network paths under load.

## Key Ideas

- Capacity and performance are separate dimensions. A large drive can still be slow for a high-traffic workload.
- Throughput measures bulk data moved per unit time and matters for large sequential transfers such as backups, media files, and batch processing.
- IOPS measures how many discrete read/write operations can be completed per second and matters for fragmented, small-record workloads such as transactional databases.
- Database systems often starve on I/O long before they exhaust byte capacity.
- Cloud storage pricing separates capacity from provisioned IOPS because architecture must account for both data volume and access velocity.

## Links

- Supports [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Supports [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Supports [[concepts/system-design|System Design]]
