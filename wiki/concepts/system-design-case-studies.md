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

## GenAI Shopping Assistant

Core problem: answer open-ended shopping questions with low latency, evidence grounding, and useful product-aware rendering at very large concurrency. The Rufus source frames this as a full production system: domain data preparation, custom LLM training, RAG over trusted shopping sources, feedback-driven improvement, accelerator-backed inference, continuous batching, and token-level streaming with response hydration.

Useful patterns:

- Domain-specialized model or adaptation.
- RAG over source-specific evidence with relevance by question type.
- Feedback loop for response-quality improvement.
- Accelerator and compiler/runtime work for low-latency inference.
- Continuous batching for high-throughput LLM serving.
- Streaming responses plus structured markup for product-aware UX.

## Agent-Backed Backend Slice

Core problem: replace frequently changing backend behavior with agent workflows while preserving deterministic boundaries. The GPT-5.5 backend source frames a candidate slice around validation, recommendation, reporting, and scheduling, with traditional code retained for auth, writes, payments, and compliance.

Useful patterns:

- Run agents side-by-side with existing code before cutover.
- Validate behavior with output suites rather than only implementation-level unit tests.
- Log agent decisions and tool calls for observability.
- Monitor token/API costs as part of system cost.
- Keep critical security and mutation paths deterministic.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Source: [[sources/system-design-course|System Design Course]]
- Source: [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]]
- Source: [[sources/gpt-5-5-agents-replaced-python-backend|GPT-5.5 Agents Replaced My Python Backend]]
