---
title: System Design Case Studies
type: concept
created: 2026-04-28
tags:
  - concept
  - case-studies
  - system-design
---

# System Design Case Studies

The system design course uses case studies to turn primitives into reusable design judgment. Each case study follows a similar pattern: requirements, estimates, data model, APIs, high-level architecture, detailed design, and bottlenecks.

## URL Shortener

Core problem: generate unique short aliases for long URLs and redirect reads with low latency. The source frames it as read-heavy and highlights expiration, abuse prevention, analytics, encoding, key generation, caching, data partitioning, cleanup, and security.

Useful patterns:

- Read-heavy design.
- Cache hot redirects.
- Key generation service.
- API keys for client control and abuse prevention.
- Cleanup for expired links.

## WhatsApp-Like Messaging

Core problem: real-time chat with users, groups, message history, notifications, read receipts, media, and high availability.

Useful patterns:

- Persistent realtime connections.
- Message storage and partitioning.
- Notification pipeline.
- Media storage plus CDN.
- API gateway and cache for supporting reads.

## Twitter-Like Social Feed

Core problem: posting, following, feed generation, ranking, search, media, trends, and notifications.

Useful patterns:

- Fan-out on write, fan-out on read, or hybrid feeds.
- Ranking based on relevance, recency, and engagement.
- Search infrastructure for text and trends.
- Graph queries for relationships.
- Caching top traffic and paginating feeds.

## Netflix-Like Video Streaming

Core problem: upload, process, store, search, and stream video at huge read scale with low latency and high reliability.

Useful patterns:

- Object storage for media.
- CDN for video delivery.
- Resume playback state.
- Geo-blocking.
- Analytics and metrics.
- High storage and bandwidth estimation.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Source: [[sources/system-design-course|System Design Course]]

