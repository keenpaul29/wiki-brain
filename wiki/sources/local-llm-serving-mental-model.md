---
title: Local LLM Serving Mental Model
type: source
created: 2026-05-05
source: https://freedium-mirror.cfd/https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-1-the-mental-model-712a4a3f888f
tags:
  - source
  - llm
  - inference
  - operations
---

# Local LLM Serving Mental Model

## Summary

This source explains why local LLM serving tutorials hide the real production constraints. The core model is prefill versus decode, KV cache as a first-class VRAM cost, hidden request queues in simple APIs, and model loading as disk-to-RAM-to-VRAM plus warmup.

## Key Ideas

- Prefill processes input tokens in parallel and is usually compute-bound.
- Decode generates output one token at a time and is often memory-bandwidth-bound.
- Time to first token and tokens per second measure different phases and should be tracked separately.
- KV cache size depends on context length, layers, KV heads, head dimension, element precision, and parallel request slots.
- Advertised context windows can be unaffordable in VRAM when filled by real requests.
- Ollama's default one-request-per-model behavior can create invisible FIFO queuing and bad p99 latency.
- vLLM's continuous batching and PagedAttention attack scheduling and KV-cache waste differently from slot-based serving.
- Model loading has multiple phases; OS page cache eviction and GPU warmup can create slow first requests even when a runtime says the model is loaded.

## Links

- Connects to [[concepts/local-llm-serving|Local LLM Serving]] (prefill/decode, KV cache, scheduling)
- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]] (AI inference at scale)
- Connects to [[concepts/reliability-and-operations|Reliability and Operations]] (latency and capacity planning)

