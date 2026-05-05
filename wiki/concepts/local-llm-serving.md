---
title: Local LLM Serving
type: concept
created: 2026-05-05
tags:
  - concept
  - llm
  - inference
  - operations
---

# Local LLM Serving

Local LLM serving is the operational work of running models such as Ollama, llama.cpp, or vLLM under real traffic. The central lesson from the current sources is that demos hide the actual budget: latency, VRAM, queueing, context length, and observability.

## Mental Model

- Prefill processes input tokens and is usually compute-bound.
- Decode generates output tokens and is often memory-bandwidth-bound.
- Time to first token and tokens per second must be measured separately.
- KV cache is a first-class memory cost, often larger than expected once context length and parallel slots are included.
- "Model loaded" does not guarantee warm RAM pages, resident VRAM, or a warmed GPU execution path.

## Operational Knobs

- Set context length from measured request percentiles, not model-card maximums.
- Treat concurrency as a memory decision because each active request consumes KV cache.
- Use KV cache quantization and weight quantization as separate, evaluated choices.
- Use prefix caching when requests share long stable prefixes such as system prompts, few-shot examples, tool schemas, or repeated RAG chunks.
- Make keep-alive and maximum loaded models explicit so reloads and evictions do not become unexplained p99 spikes.
- Choose runtime by constraint: Ollama for simplicity, llama.cpp for control, vLLM for higher-throughput serving with continuous batching and PagedAttention.

## Observability

Minimum useful telemetry includes prompt token count, output token count, prefill duration, decode duration, p50/p95/p99 latency, GPU memory, loaded models, active requests, queue depth, cache hit behavior, and truncation checks. Benchmarks should replay real prompt and output length distributions instead of uniform synthetic prompts.

## Links

- Parent: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Source: [[sources/local-llm-serving-mental-model|Local LLM Serving Mental Model]]
- Source: [[sources/local-llm-serving-operational-playbook|Local LLM Serving Operational Playbook]]
- Source: [[sources/production-ai-failure-modes|Beyond Shipped - Production AI Failure Modes]]

