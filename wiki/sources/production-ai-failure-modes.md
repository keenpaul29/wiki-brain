---
title: Beyond Shipped - Production AI Failure Modes
type: source
created: 2026-05-05
source: https://medium.com/aws-in-plain-english/heres-your-final-publication-ready-medium-article-tightened-more-compelling-and-optimized-for-c97f96d02d9f
tags:
  - source
  - ai
  - production
  - reliability
---

# Beyond Shipped - Production AI Failure Modes

## Summary

This source argues that shipping an AI feature is the start of engineering work, not the end. Production failures usually come from system design gaps: weak retrieval, slow inference, uncontrolled agents, insecure tool access, runaway cost, and absent evaluation.

## Key Ideas

- Hallucination mitigation should be treated as a grounding and evidence-gating problem, not only a prompt problem.
- Retrieval needs engineering: semantic chunking, hybrid search, reranking, precision/recall evaluation, and sometimes graph-aware retrieval.
- Latency is architectural: KV cache reuse, speculative decoding, parallel tools, and caching affect user experience.
- Memory should be explicit: short-term state, long-term state, summarization, and top-k retrieval serve different roles.
- Agents need deterministic orchestration through state machines, DAGs, step limits, tool constraints, and traces.
- Tool failures require distributed-systems controls: retries, fallbacks, input/output validation, graceful degradation, and tool latency/error monitoring.
- Prompt injection turns external content into an adversarial input channel; tool permissions and trusted/untrusted data separation matter.
- Cost control should optimize for cost per successful outcome using caching, model cascades, prompt reduction, and budget-aware rate limits.
- Evaluation should run offline in CI/CD and online in production to detect regressions and drift.

## Links

- Connects to [[concepts/reliability-and-operations|Reliability and Operations]] (production AI observability and failure controls)
- Connects to [[concepts/local-llm-serving|Local LLM Serving]] (latency, inference, and cost tradeoffs)
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] (engineering ownership after AI launch)

