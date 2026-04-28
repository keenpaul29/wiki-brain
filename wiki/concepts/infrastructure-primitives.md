---
title: Infrastructure Primitives
type: concept
created: 2026-04-28
tags:
  - concept
  - infrastructure
  - system-design
---

# Infrastructure Primitives

Infrastructure primitives are the reusable building blocks that appear across system designs. The system design source covers them as foundational vocabulary before moving into larger architectures.

## Networking

- IP addresses identify devices on networks.
- OSI layers provide a shared model for reasoning about network behavior.
- TCP provides ordered, reliable delivery with more overhead.
- UDP provides lower-latency, connectionless delivery without guaranteed delivery.
- DNS maps human-readable names to network addresses through resolvers, root servers, TLD nameservers, and authoritative nameservers.

## Traffic and Delivery

- Load balancers distribute traffic across servers and reduce single points of failure.
- CDNs place static or cacheable content closer to users.
- Forward proxies act on behalf of clients.
- Reverse proxies act on behalf of servers.
- API gateways centralize cross-cutting concerns such as routing, authentication, rate limits, and request shaping.

## Compute and Deployment

- Virtual machines isolate full operating environments through a hypervisor.
- Containers package application processes and dependencies more lightly than VMs.
- Service discovery lets services find each other dynamically in changing environments.
- Service meshes manage service-to-service traffic, observability, and security in microservice systems.

## AI Inference at Scale

- Accelerators (GPUs/TPUs/custom chips) are often required for low-latency LLM serving.
- Compilers and runtimes matter: graph compilation and kernel selection can materially change throughput/latency.
- Batching strategies are part of the serving architecture; continuous batching can reduce tail latency under load.
- Streaming responses improve perceived latency, but require careful client/server coordination.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Source: [[sources/system-design-course|System Design Course]]
- Related source: [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]]
