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

## Edison Engine Architecture (Dropbox)

Dropbox's [[sources/dropbox-edison-web-performance|Edison]] replaces the older architecture where each UI feature independently fetched from the server. The two-layer design:

```
User Action → Edison Engine (local read/write) → Sync Service (WebSocket) → Dropbox Server
```

- **Edison Engine**: the local-first sync engine. All file operations (list, search, preview) read from and write to a local representation. The engine restructures the web client's data access so components share a single storage layer instead of each maintaining independent server fetches.
- **Sync Service**: maintains a persistent WebSocket connection to the server. Handles uploads, change propagation, and conflict resolution in the background while the UI remains interactive.
- **Multi-tab coordination**: uses BroadcastChannel API so all open tabs see state changes immediately. When one tab renames a file, all other tabs update without a server round-trip.
- **Durable store**: IndexedDB with a specialized schema for file metadata, content chunks, and sync state. The schema is designed for the read patterns of file browsing — directory listings, search results, and content previews — not for generic key-value storage.
- **Optimistic UI**: every user action applies to local state first. If sync fails (offline, conflict), the engine retries in the background or surfaces the conflict.

## Conflict Resolution Strategies

Local-first systems must handle concurrent edits from multiple devices or tabs. The common strategies in order of sophistication:

1. **Last-Writer-Wins (LWW)**: simplest strategy. Each change carries a timestamp; the most recent wins. Risk: silent data loss when two users edit different parts of the same document.
2. **Operational Transform (OT)**: edits are represented as operations (insert, delete, format) that can be transformed against concurrent operations. Used by Google Docs. Requires a central server to coordinate transformation.
3. **CRDT (Conflict-Free Replicated Data Type)**: each replica applies operations independently; the data type's merge semantics guarantee eventual consistency without a central coordinator. Used by Automerge, Yjs, and Figma. Tradeoff: higher storage overhead for metadata.

For file-level sync (Dropbox, Google Drive), LWW is standard because files are opaque blobs. For real-time collaborative editing (Notion, Figma, Google Docs), CRDTs or OT are required.

## Offline Resilience

Local-first architecture enables offline operation as a natural consequence of the local read/write pattern:

- **Reads always work**: local data is available regardless of connectivity. The user sees the last-synced state immediately.
- **Writes queue locally**: offline mutations are stored in a pending operation queue. When connectivity returns, the sync engine replays the queue in order.
- **Conflict detection on reconnect**: if the same data was modified on another device while offline, the system detects the divergence and applies the conflict resolution strategy.
- **Sync state visibility**: the UI should communicate sync status — "saved locally," "syncing," "conflict detected" — so the user is never surprised by data loss.

This connects to [[concepts/reliability-and-operations|Reliability and Operations]]: offline resilience is a reliability pattern, not just a UX feature. It prevents data loss during network interruptions and reduces server load during reconnection storms.

## Benefits

- Perceived performance: instant UI updates regardless of network conditions.
- Offline support: core operations work without connectivity.
- Unified data access: all components read/write through a shared storage layer instead of independent fetches.

## Sources

- [[sources/dropbox-edison-web-performance|How Edison Is Helping Us Build a Faster, More Powerful Dropbox on the Web]]
