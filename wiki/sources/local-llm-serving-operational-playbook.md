---
title: Local LLM Serving Operational Playbook
type: source
created: 2026-05-05
source: https://freedium-mirror.cfd/https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-2-the-operational-playbook-cc903d6a4426
tags:
  - source
  - llm
  - inference
  - operations
---

# Local LLM Serving Operational Playbook

## Summary

This source turns the local LLM serving mental model into operations guidance. The main advice is to set context length from measured traffic, use KV-cache quantization and prefix caching where validated, make keep-alive explicit, observe prefill/decode separately, benchmark with real prompt distributions, and put model servers behind proper auth and rate limits.

## Key Ideas

- Context length should usually match the 95th percentile of real request lengths, not the model's advertised maximum.
- A two-instance pattern can separate short-context high-concurrency traffic from rare long-context low-concurrency requests.
- KV cache quantization can reduce VRAM pressure and improve decode memory traffic, but should be checked against task-specific evals.
- Prefix caching is high leverage when system prompts, few-shot examples, RAG chunks, or agent tool schemas repeat.
- Keep-alive controls a memory contract: dedicated servers often want resident models, while shared or batch systems may need eviction.
- Weight quantization and KV cache quantization are separate decisions with different quality and memory tradeoffs.
- Minimum observability includes prompt/decode timings, token counts, GPU memory, active requests, loaded models, queue depth, truncation checks, and p50/p95/p99 latency by request type.
- Benchmarks should replay real prompt lengths, output lengths, and burst patterns for sustained windows.
- Exposing Ollama or similar servers directly is a security issue; use an authenticated reverse proxy with TLS, rate limits, and internal binding where possible.

## Links

- Connects to [[concepts/local-llm-serving|Local LLM Serving]] (production knobs and observability)
- Connects to [[concepts/reliability-and-operations|Reliability and Operations]] (SLOs, security, and benchmarking)
- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]] (serving runtimes and accelerators)

