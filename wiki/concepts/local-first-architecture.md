---
title: Local-First Architecture
type: concept
created: 2026-06-01
tags:
  - concept
  - architecture
  - web
  - sync
  - offline
---

# Local-First Architecture

Local-first architecture enables web applications to read and write to a local representation of data, with background synchronization handling server round-trips. This shifts the web client from a thin UI shell into a capable client-side application.

## Core Principles (from Dropbox Edison)

- **Local reads and writes**: user operations apply immediately to local state, not waiting for server round-trips.
- **Background sync**: a sync engine handles uploads, change notifications, and conflict resolution asynchronously.
- **Optimistic UI**: actions appear instant; the server is the source of truth but the client does not block on it.

## Implementation Patterns

- **Two-layer architecture**: a local-first sync engine (read/write to local representation) and a sync service (persistent WebSocket connection for change propagation).
- **Multi-tab coordination**: using BroadcastChannel API for cross-tab state synchronization.
- **Durable store**: IndexedDB with specialized schemas for file metadata and content.
- **Change notifications**: WebSocket-based to propagate changes from server to all connected clients.
- **Conflict resolution**: handling concurrent edits from multiple devices or tabs.

## Benefits

- Perceived performance: instant UI updates regardless of network conditions.
- Offline support: core operations work without connectivity.
- Unified data access: all components read/write through a shared storage layer instead of independent fetches.

## Sources

- [[sources/dropbox-edison-web-performance|How Edison Is Helping Us Build a Faster, More Powerful Dropbox on the Web]]
