---
title: Reliability and Operations
type: concept
created: 2026-04-28
tags:
  - concept
  - reliability
  - operations
  - system-design
---

# Reliability and Operations

Reliability and operations convert an architecture from a diagram into a system that survives load, failures, abuse, and change. The system design source covers availability, fault tolerance, rate limiting, disaster recovery, security, and observability-oriented service management.

## Availability and Failure

- Availability measures how often a system is usable.
- Reliability measures whether the system performs correctly over time.
- Fault tolerance means the system continues operating despite component failures.
- Redundant load balancers, replicas, caches, and service instances reduce single points of failure.

## Control and Protection

- Rate limiting protects systems from abuse, traffic spikes, and noisy clients.
- Common rate-limit algorithms include leaky bucket, token bucket, fixed window, sliding log, and sliding window.
- Circuit breakers stop repeated calls into failing dependencies and allow controlled recovery.
- Backpressure prevents producers from overwhelming consumers.
- Microservice boundaries turn local function calls into fallible network calls, so retries, timeouts, circuit breakers, and monitoring become part of the architecture rather than optional polish.

## Service Operations

- SLA: external promise to users or customers.
- SLO: internal or external target for reliability.
- SLI: measured indicator used to judge whether the target is met.
- Disaster recovery uses RTO and RPO to reason about recovery time and acceptable data loss.
- Cold sites, hot sites, and backups represent different cost/recovery tradeoffs.

## Agent Operations

Agent-backed production paths need reliability controls that ordinary request handlers may not expose by default: decision logs, tool-call traces, output validation, fallback paths, latency distribution monitoring, and API cost tracking. Debugging shifts from stack traces alone toward reconstructing the agent's context, instructions, tools, and intermediate decisions.

Production AI systems add specific failure modes: weak retrieval, hallucinated answers, agent loops, tool-call failures, prompt injection, runaway inference cost, inconsistent output format, and missing evaluation gates. Mature systems separate probabilistic decisions from deterministic execution, enforce step limits, validate tool inputs and outputs, replay traces, and run both offline regression evals and online drift checks.

Local LLM serving needs its own operational telemetry. Prefill duration, decode duration, token counts, queue depth, GPU memory, loaded models, truncation checks, and p50/p95/p99 latency by request type are required to distinguish prefill, decode, queuing, eviction, and memory pressure problems.

## Security and Identity

- OAuth 2.0 delegates authorization.
- OpenID Connect adds identity on top of OAuth.
- SSO centralizes authentication across services.
- TLS secures transport; mTLS authenticates both sides and is common in zero-trust microservice environments.
- Zero Trust tunnels should pair exposed hostnames with explicit access policy where needed, and connector health states should be monitored after setup.
- Container operations should avoid unnecessary daemon exposure, prefer rootless execution where practical, scan images during the lifecycle, and protect remote engine access with SSH or TLS.
- Model-serving endpoints such as Ollama should not be exposed directly without a reverse proxy, TLS, authentication, and rate limits.

## Migration and Release Risk

Framework upgrades can make systems safer while still breaking production behavior. FastAPI `0.115` examples include stricter dependency signatures, response validation, CORS enforcement, WebSocket disconnect handling, optional query typing, and serializer changes. The safe pattern is to categorize failures, fix critical paths first, test with real frontend/configuration behavior, and roll out gradually with monitoring.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Source: [[sources/system-design-course|System Design Course]]
- Source: [[sources/gpt-5-5-agents-replaced-python-backend|GPT-5.5 Agents Replaced My Python Backend]]
- Source: [[sources/microservices-vs-monoliths|Microservices vs. Monoliths]]
- Source: [[sources/create-tunnel-dashboard|Create a tunnel (dashboard)]]
- Source: [[sources/fastapi-0-115-migration|FastAPI 0.115 Migration Breakages]]
- Source: [[sources/production-ai-failure-modes|Beyond Shipped - Production AI Failure Modes]]
- Source: [[sources/local-llm-serving-mental-model|Local LLM Serving Mental Model]]
- Source: [[sources/local-llm-serving-operational-playbook|Local LLM Serving Operational Playbook]]
- Source: [[sources/docker-image-security-optimization|Docker Image Security and Optimization]]
- Source: [[sources/podman-python-deploys|Podman for Faster Python Deploys]]
- Source: [[sources/unlock-system-design-production|Unlock Production System Design Case Study]]
