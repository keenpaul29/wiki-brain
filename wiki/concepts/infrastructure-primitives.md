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
- Tunnels let a connector establish outbound connectivity so local services or private network ranges can be reached through a managed edge without opening direct inbound ports.
- API gateways centralize cross-cutting concerns such as routing, authentication, rate limits, and request shaping.

## Compute and Deployment

- Virtual machines isolate full operating environments through a hypervisor.
- Containers package application processes and dependencies more lightly than VMs.
- Container image construction affects both delivery speed and security: multi-stage builds, lightweight bases, `.dockerignore`, and stable layer ordering keep images smaller and builds more cacheable.
- Docker and Podman share much of the Dockerfile surface, but differ operationally around daemon use, rootless workflows, systemd integration, Compose compatibility, volume permissions, and registry auth.
- Service discovery lets services find each other dynamically in changing environments.
- Service meshes manage service-to-service traffic, observability, and security in microservice systems.

## AI Inference at Scale

- Accelerators (GPUs/TPUs/custom chips) are often required for low-latency LLM serving.
- Compilers and runtimes matter: graph compilation and kernel selection can materially change throughput/latency.
- Batching strategies are part of the serving architecture; continuous batching can reduce tail latency under load.
- Streaming responses improve perceived latency, but require careful client/server coordination.
- Local LLM serving capacity depends on prefill, decode, KV cache size, context length, quantization, model residency, and scheduler design.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Source: [[sources/system-design-course|System Design Course]]
- Related source: [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]]
- Related source: [[sources/create-tunnel-dashboard|Create a tunnel (dashboard)]]
- Related source: [[sources/docker-image-security-optimization|Docker Image Security and Optimization]]
- Related source: [[sources/podman-python-deploys|Podman for Faster Python Deploys]]
- Related source: [[sources/local-llm-serving-mental-model|Local LLM Serving Mental Model]]
- Related: [[concepts/local-llm-serving|Local LLM Serving]]
