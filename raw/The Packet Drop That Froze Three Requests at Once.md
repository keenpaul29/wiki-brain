---
title: "The Packet Drop That Froze Three Requests at Once"
source: "https://systemdesignprimer.substack.com/p/the-packet-drop-that-froze-three"
author:
  - "[[System Design Primer]]"
published: 2026-05-20
created: 2026-06-01
description: "You load a webpage."
tags:
  - "clippings"
---
> You load a webpage. The browser opens a connection and sends three requests in parallel — the HTML, a CSS file, and a font. All three are in flight simultaneously over the same TCP connection. A router somewhere in the middle drops one packet from the CSS request. TCP detects the loss and retransmits. While it waits for the retransmission, the connection stalls.
> 
> Not just the CSS request. All three. The HTML and the font, which had nothing to do with the dropped packet, are frozen because TCP is a single ordered byte stream. It cannot deliver byte 5000 until byte 4999 arrives, regardless of which request byte 4999 belongs to. This is head-of-line blocking — one dropped packet holds the entire connection hostage.
> 
> HTTP/2 was designed to fix this with multiplexed streams. It worked at the application layer. But it still ran over TCP, so the fix was partial: HTTP/2 streams are independent at the HTTP layer, but at the TCP layer they all share the same ordered byte stream. Drop one TCP segment and all HTTP/2 streams stall until it’s retransmitted.
> 
> QUIC solves this completely. Not by patching TCP, but by replacing it.

---

## What QUIC Actually Is

QUIC is a transport protocol built on UDP, developed by Google and standardised by the IETF in 2021 as RFC 9000. HTTP/3 is HTTP running over QUIC instead of TCP. When you see Chrome connecting to a server over HTTP/3, the packets at the network layer are UDP datagrams — not TCP segments.

The choice of UDP is not because UDP is faster. It is because TCP’s behaviour is enforced by the operating system kernel, and getting a new transport protocol deployed means getting it into the kernel of billions of devices — which takes a decade. By building on UDP, QUIC runs entirely in userspace on both ends, allowing Google to iterate and deploy rapidly. The reliability, ordering, and congestion control that TCP provides are all reimplemented in QUIC — but differently, in ways that fix the problems.

Three things QUIC does that TCP cannot:

**Independent stream multiplexing.** QUIC has streams as a first-class concept at the transport layer, not bolted on at the application layer. When a packet carrying stream 2 data is lost, only stream 2 stalls while waiting for the retransmission. Streams 1 and 3 continue delivering their data to the application uninterrupted. This is genuine head-of-line blocking elimination — not an approximation at a higher layer.

**Integrated TLS 1.3.** In TCP+TLS, you pay two round-trips before sending application data: one for the TCP handshake and one for the TLS handshake. QUIC combines the transport and cryptographic handshakes into a single exchange. A fresh QUIC connection to a server you have visited before can complete the handshake and send application data in 0 round-trips (0-RTT), using cached session credentials from the previous connection. A first-time connection takes 1 round-trip instead of the 2–3 required for TCP+TLS.

The TLS integration is not optional or configurable. Every QUIC connection is encrypted. There is no “QUIC without TLS” — encryption is built into the protocol at the same level as the stream multiplexing. This makes packet-level inspection and middlebox interference much harder, which is a feature for privacy and a challenge for network operators who relied on deep packet inspection.

**Connection migration via connection ID.** TCP connections are identified by the 4-tuple of source IP, source port, destination IP, destination port. Change any of these and the connection breaks. When a mobile device switches from WiFi to cellular, its IP address changes and every TCP connection resets. The application has to reconnect, reauthenticate, and resume from scratch.

QUIC connections are identified by a connection ID — a randomly generated opaque identifier chosen at connection establishment. The connection ID has no relationship to IP addresses or ports. When the client’s IP changes (WiFi → cellular, or cellular handoff between towers), it sends the next packet with the same connection ID from the new IP address. The server recognises the connection ID and continues from where it left off. From the application’s perspective, the connection never broke.

---

## The Handshake Comparison

The performance advantage of QUIC compounds with each handshake.

**TCP + TLS 1.2:**

1. TCP SYN → SYN-ACK → ACK (1 RTT)
2. TLS ClientHello → ServerHello → client finished → server finished (2 RTT)
3. First application data: **3 RTT total**

**TCP + TLS 1.3:**

1. TCP SYN → SYN-ACK → ACK (1 RTT)
2. TLS ClientHello → ServerHello + Finished → client Finished (1 RTT)
3. First application data: **2 RTT total**

**QUIC (first connection):**

1. QUIC Initial (crypto handshake) → server response (1 RTT)
2. First application data: **1 RTT total**

**QUIC (resumed connection, 0-RTT):**

1. QUIC Initial with 0-RTT application data embedded in first packet
2. First application data: **0 RTT total**

On a mobile network with 80ms RTT, this difference is 240ms versus 80ms versus 0ms for page load initiation. On a high-latency satellite link with 600ms RTT, the difference is 1,800ms versus 600ms versus 0ms. The latency reduction is proportional to RTT — the worse your network, the more QUIC helps.

The 0-RTT mode comes with a security trade-off: 0-RTT data can be replayed by an attacker who captures the initial packet. This means 0-RTT should only be used for idempotent requests — GET requests are safe; POST requests that create resources are not. Major implementations (Chrome, curl with QUIC support) limit 0-RTT to safe HTTP methods by default.

---

## What QUIC Changes About Congestion Control

TCP’s congestion control (BBR, CUBIC, RENO) is implemented in the operating system kernel. Changing it requires a kernel update, which means getting millions of servers and routers to upgrade — typically a multi-year process. QUIC’s congestion control is implemented in userspace, per application, and can be updated with a normal application deployment.

This sounds like a minor operational detail. It is actually a significant architectural advantage. Google deployed BBR (Bottleneck Bandwidth and RTT) as QUIC’s default congestion controller years before it became the default in Linux kernels. YouTube’s video quality improvements in 2016–2017 were partly attributable to QUIC running BBR while TCP deployments were still on CUBIC.

QUIC also improves loss detection accuracy. TCP infers packet loss from timeout or duplicate ACKs, which can be slow to detect in some network conditions. QUIC uses explicit packet numbers that never repeat — unlike TCP sequence numbers which track bytes, QUIC packet numbers are monotonically increasing per-packet identifiers that make loss detection more accurate and faster.

![](https://substackcdn.com/image/fetch/$s_!Rnav!,w_1456,c_limit,f_webp,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2Fb674059d-ce65-491b-9e8e-af7260e3dccb_760x460.gif)

---

## Why QUIC Is Hard to Deploy Behind Existing Infrastructure

QUIC runs on UDP. Many enterprise firewalls, load balancers, and network appliances have rules that rate-limit or block UDP traffic that is not DNS or NTP. UDP has historically been associated with amplification attacks (UDP flood, DNS amplification) so network operators applied restrictive policies. A QUIC connection attempt that is silently dropped by a firewall produces no feedback to the client — the connection fails and the client may fall back to TCP/TLS.

QUIC implementations handle this with the `Alt-Svc` HTTP response header: a server signals that it supports QUIC on a specific UDP port, and the client remembers this for future connections. If the first connection succeeds over TCP, subsequent connections to the same origin attempt QUIC. If QUIC is blocked, the client falls back to TCP without interruption. Chrome and other browsers maintain a service that tracks which origins support QUIC and remembers past failures, avoiding repeated failed QUIC attempts.

Load balancers present a different problem. TCP load balancers route connections based on the 5-tuple, which is stable for the lifetime of a TCP connection. QUIC connection IDs are opaque to the network — a load balancer that inspects the source IP and port will misroute QUIC packets from a migrated connection (new IP, same connection ID) to a different backend than the backend that has the connection state.

The solution is QUIC-aware load balancers that inspect the connection ID and route accordingly. NGINX (since version 1.25), HAProxy (since 2.6), and AWS ALB all support QUIC-aware routing. The load balancer must be configured to use QUIC’s connection ID as the routing key rather than the source IP, and the backend servers must be configured to accept the connection ID format that the load balancer expects.

---

## Adoption and Where It Actually Runs Today

HTTP/3 is used for the majority of connections between Chrome and Google’s services. Cloudflare serves HTTP/3 by default to all customers whose browsers support it. Fastly, Akamai, and AWS CloudFront all support HTTP/3. As of 2025, roughly 30% of websites support HTTP/3, up from near-zero in 2020.

Server-side support requires a QUIC-capable TLS implementation integrated with your web server or CDN. Nginx supports QUIC/HTTP3 as of version 1.25 (compiled with OpenSSL 3.x or BoringSSL). Caddy has supported QUIC since its initial design. For application servers in your own infrastructure, most traffic passes through a CDN or load balancer that handles QUIC termination — your application servers typically continue using HTTP/1.1 or HTTP/2 for origin connections, while the edge handles QUIC for browser-to-edge traffic.

The performance gains are largest for:

- High-latency connections (mobile, satellite, intercontinental)
- Lossy connections (mobile networks, congested WiFi)
- Connection-heavy workloads (many short-lived requests, like APIs)
- Mobile applications that switch networks frequently

The performance gains are smallest for:

- Low-latency wired connections with near-zero packet loss
- Long-lived connections (streaming, WebSocket) where the handshake cost amortises
- Server-to-server communication on controlled networks

---

The web spent 30 years on TCP because changing a transport protocol requires changing every device on the internet. QUIC found a way around that constraint by building on UDP and implementing transport-layer logic in userspace. The result is a protocol that is faster on lossy networks, eliminates head-of-line blocking completely, makes connection migration free, and deploys like application software rather than like infrastructure.

The packet drop that froze three requests at once is not a problem QUIC works around. It is a problem QUIC’s architecture makes impossible.