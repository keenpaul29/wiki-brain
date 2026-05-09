---
title: The Dictionary Problem - Fast Lookups in Large Collections
type: source
created: 2026-05-08
source: https://substack.com/@francofernando/p-193795555
tags:
  - source
  - data-structures
  - algorithms
  - system-design
---

# The Dictionary Problem - Fast Lookups in Large Collections

## Summary

This source explains lookup-oriented data structures through the example of a browser spell checker with more than 100,000 words. It compares unsorted arrays, sorted arrays, hash tables, and binary search trees by lookup speed, insertion/removal cost, ordering support, and memory tradeoffs.

## Key Ideas

- The abstract data type is a dictionary, map, associative array, or symbol table: a collection of keys, optionally paired with values. A set is the membership-only version.
- Unsorted arrays are simple and cheap to append to, but membership checks are O(n), which is too slow for large interactive lookup workloads.
- Sorted arrays support O(log n) lookup through binary search and low extra memory, but insertion and deletion remain O(n) because elements must shift.
- Hash tables use a hash function and collision strategy to deliver average O(1) lookup, insertion, and removal, trading speed for extra memory.
- Binary search trees support O(log n) operations when balanced and preserve order, making them better when range queries, predecessor/successor lookup, or sorted traversal matter.
- For pure spell-check membership, a hash set is the practical default; if memory becomes the limiting factor, probabilistic structures such as Bloom filters become relevant.

## Links

- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]] (indexes, key-value lookup, and storage tradeoffs)
- Connects to [[concepts/system-design|System Design]] (choosing data structures from access patterns)
- Connects to [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] (CS fundamentals as AI-era judgment)

