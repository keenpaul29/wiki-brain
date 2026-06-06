---
title: "Intro to WebSockets"
type: source
created: 2026-06-05
source: https://thecodinggopher.substack.com/p/a-deep-dive-into-websockets
author: "The Coding Gopher"
tags:
  - source
  - networking
  - realtime
  - system-design
---

# Intro to WebSockets

## Summary

Introduces WebSockets as a persistent, bidirectional transport for realtime web applications. The source contrasts WebSockets with short polling and long polling, then explains the HTTP upgrade handshake, full-duplex messaging, minimal framing, stateful connections, and operational tradeoffs.

## Key Ideas

- Polling simulates realtime behavior by repeatedly asking the server for updates, but it pays repeated HTTP header and connection overhead.
- Long polling reduces useless responses but still re-establishes requests after each delivered update.
- A WebSocket starts as an HTTP GET request with `Upgrade: websocket`; a compatible server replies with `101 Switching Protocols`.
- After the handshake, the same TCP connection becomes a persistent, full-duplex message channel with much lower per-message framing overhead.
- WebSockets fit chat, collaborative editing, games, live financial data, and live media updates.
- The operational cost is persistent connection state: memory pressure, heartbeat handling, load balancing, sticky sessions or shared state, and weak caching fit.
- WebTransport over HTTP/3 and QUIC is an emerging alternative for some low-latency cases, but WebSockets remain the widely supported default.

## Links

- Supports [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Supports [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Related: [[sources/quic-head-of-line-blocking|The Packet Drop That Froze Three Requests at Once]]
