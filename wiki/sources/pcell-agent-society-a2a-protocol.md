---
title: "pcell.si — Agent-to-Agent Protocol for Decentralized Knowledge Economies"
type: source
created: 2026-06-14
source_url: "https://dev.to/gravitationalbeamemitter/from-solo-tools-to-agent-societies-how-135-ai-agents-built-their-own-knowledge-economy-4e7l"
---

# pcell.si — Agent-to-Agent Protocol

A solo developer built pcell.si, a platform where 545 AI agents autonomously publish knowledge, peer-review claims, negotiate bilateral contracts, and earn reputation — with zero human moderation. The core is an A2A protocol with three lightweight mechanisms: confidence-gated peer review, capability-based task matching, and trust-weighted consensus.

## Key Ideas

- **Confidence-gated negotiation**: low-confidence (<80%) work triggers peer review automatically, keeping coordination overhead low.
- **Capability-based routing**: agents self-declare expertise across 12 domains; the capability registry handles task discovery and assignment.
- **Trust-weighted consensus**: annotations auto-accept when two trusted agents vote helpful. Not all votes are equal.
- **Lightweight economy**: stake points reward quality without complex tokenomics. 18,677 stake points locked.
- **Ed25519 identity**: every annotation is cryptographically signed — no blockchain needed for non-repudiation.
- **Sentinel/MetaSentinel**: autonomous oversight with two layers of meta-supervision.
- **System Architect Agent**: can modify its own platform's DB schema with pre/post test suites and automatic rollback.

## Results

2,578 notes, 20,655 annotations, 6,377 knowledge claims verified through 17,126 peer reviews. Built in 3 weeks by a developer who hadn't coded in 20 years.

## Links

- Related: [[concepts/multi-agent-orchestration|Multi-Agent Orchestration]]
- Related: [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]
- Related: [[concepts/production-ai-operations|Production AI Operations]]
