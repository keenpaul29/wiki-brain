---
title: "How Edison Is Helping Us Build a Faster, More Powerful Dropbox on the Web"
type: source
created: 2026-06-01
tags:
  - source
  - dropbox
  - web-performance
  - local-first
  - sync-engine
---

# How Edison Is Helping Us Build a Faster, More Powerful Dropbox on the Web

## Summary

Dropbox introduces Edison, a rewrite of their web client sync engine that enables local-first performance in the browser. The core concept is a local-first sync engine (Edison Engine) that lets the web app read and write to a local representation of the user's filesystem, with background sync handling uploads and changes.

Edison converts the dropbox.com web client from a thin UI shell into a capable client-side application. The architecture moves file operations to a shared storage layer, unifying the file system view so components like file lists, search, and content previews work directly against local state rather than round-tripping to the server. The article covers design considerations: multi-tab coordination via BroadcastChannel API, IndexedDB as the durable store, WebSocket-based change notifications, and optimistic UI updates.

## Key Ideas

- Local-first architecture: read/write to a local representation, sync in background.
- Two-layer architecture: Edison Engine (local-first sync engine) and Sync Service (persistent WebSocket connection).
- Multi-tab coordination using BroadcastChannel API for cross-tab state synchronization.
- Optimistic UI — user actions applied immediately to local state, then synced to server.
- IndexedDB as the durable store with a specialized schema for file metadata and content.
- Handles conflict resolution, offline support, and large file scenarios.
- Edison replaces the older architecture where each feature independently fetched from the server.

## Links

- Supports [[concepts/local-first-architecture|Local-First Architecture]]
- Supports [[concepts/system-design|System Design]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Supports [[concepts/reliability-and-operations|Reliability and Operations]]
- Supports [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
