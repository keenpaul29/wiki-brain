---
title: "HLD Fundamentals #1 — Network Protocols for System Design"
type: source
created: 2026-06-14
source_url: "https://dev.to/jaspreet_singh_86ae1740ac/hld-fundamentals-1-network-protocols-171p"
---

# HLD Fundamentals #1 — Network Protocols

A comprehensive study-guide covering fundamental network protocols for system design interviews: Client-Server model, P2P, WebSockets, HTTP, TCP, UDP, FTP, SMTP, POP3, and IMAP. Each protocol includes a definition, mechanics, advantages/disadvantages, and an interview one-liner.

## Key Ideas

- **Client-Server**: central server handles requests from multiple clients. Simple, scalable, single point of failure.
- **P2P**: no central authority. Nodes act as both clients and servers. Used by BitTorrent and Blockchain.
- **WebSockets**: persistent full-duplex connection over a single TCP socket. Essential for real-time apps.
- **HTTP**: request-response protocol. Stateless, cacheable, widely understood.
- **TCP**: connection-oriented, reliable, ordered delivery with 3-way handshake. Advantages: guaranteed delivery, error checking. Disadvantages: higher latency, slower than UDP.
- **UDP**: connectionless, no delivery guarantees. Advantages: low latency, low overhead. Used for gaming, video calls, live streaming.
- **FTP**: file transfer protocol with separate control and data connections.
- **SMTP/POP3/IMAP**: email protocols — SMTP for sending, POP3 for downloading, IMAP for multi-device sync.

## Links

- Related: [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- Related: [[concepts/system-design|System Design]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
