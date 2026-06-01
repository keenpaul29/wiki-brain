---
title: "The Packet Drop That Froze Three Requests at Once"
type: source
created: 2026-06-01
source: https://systemdesignprimer.substack.com/p/the-packet-drop-that-froze-three
tags:
  - source
---

# The Packet Drop That Froze Three Requests at Once

## Summary

This source explains why HTTP/2 over TCP only partially solved head-of-line blocking and why QUIC, the UDP-based transport behind HTTP/3, eliminates it at the transport layer. QUIC moves reliability, stream multiplexing, TLS 1.3, connection migration, and congestion-control evolution into userspace.

## Key Ideas

- **TCP head-of-line blocking**: TCP is one ordered byte stream. If one packet is lost, unrelated HTTP/2 streams sharing the connection stall until retransmission completes.
- **QUIC streams are transport-native**: A lost packet for one QUIC stream stalls only that stream; other streams continue delivering data.
- **Handshake reduction**: QUIC integrates TLS 1.3 so first connections can send application data after 1 RTT and resumed sessions can use 0-RTT for safe idempotent requests.
- **Connection migration**: QUIC uses opaque connection IDs rather than the TCP 4-tuple, so mobile clients can switch networks without resetting the application connection.
- **Userspace deployability**: QUIC can update congestion control and loss detection through application deployments instead of waiting on OS kernel rollout.
- **Deployment constraints**: UDP blocking, firewall policy, and QUIC-aware load balancing are the main operational hurdles; CDNs and modern load balancers often terminate HTTP/3 at the edge.

## Links

- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Connects to [[concepts/reliability-and-operations|Reliability and Operations]]
- Connects to [[concepts/system-design|System Design]]

