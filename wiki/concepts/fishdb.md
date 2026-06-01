---
title: FishDB
type: concept
created: 2026-06-01
tags:
  - concept
  - linkedin
  - storage
  - retrieval
  - rust
---

# FishDB

FishDB is LinkedIn's Rust-based storage and retrieval engine powering their Feed platform. It provides a document-oriented data model where each document is a collection of typed fields, supporting multiple use cases (Feed, Notification Center, Jobs) with a single engine.

## Architecture

- Written in Rust with jemalloc as its memory allocator and Tokio as its async runtime.
- Deployed across 48 shards, using an Envoy proxy sidecar for traffic management.
- Maintains index structures in memory: a HashMap mapping primary keys to internal document references (~56-59M entries, ~1.75 GB per shard).
- Uses hashbrown::HashMap (Rust's standard HashMap, based on Google's SwissTable).

## Query Engine

- Two-phase model: pre-filtering (index scanning) and result processing (projection, sorting, pagination).
- Supports relational operators (AND, OR, NOT), comparison operators, IN/REGEXP, and full-text search.
- Precomputed indexes: sorted-set indexes (B-tree), bit-sliced indexes (numeric range queries), inverted indexes (full-text search with skip-list posting lists).

## Key Incident

A HashMap resize at ~58.7M keys caused jemalloc to call `brk()`, acquiring the kernel's `mmap_lock`. This lock also contended with page faults in the Tokio async runtime, freezing all tasks. Fix: pre-allocation with `HashMap::with_capacity()`.

## Sources

- [[sources/linkedin-fishdb-retrieval-engine|FishDB: A Generic Retrieval Engine for Scaling LinkedIn's Feed]]
- [[sources/linkedin-58m-key-hashmap-freeze|The 58-Million-Key Freeze: HashMap Resize at Scale]]
