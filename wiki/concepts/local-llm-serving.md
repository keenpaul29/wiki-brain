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

## PagedAttention and Memory Management

Traditional KV cache allocation pre-allocates contiguous memory for the maximum context length of every request. This leads to severe internal fragmentation — most requests use far less than the model's max context length, but the allocation cannot be shared or reused between requests.

vLLM's **PagedAttention** solves this by managing KV cache in fixed-size blocks (pages), analogous to virtual memory in operating systems:
- Blocks are allocated on demand as new tokens are generated, not pre-allocated for the full context.
- Pages can be shared across multiple requests when they share a prefix (e.g., the same system prompt or RAG context), dramatically reducing memory for common patterns.
- Block tables map logical KV positions to physical block locations, enabling the allocator to compact, defragment, and reuse memory efficiently.
- The outcome: 2-4x higher throughput under high concurrency compared to contiguous pre-allocation, and support for much larger effective batch sizes.

Operational implication: the memory savings from PagedAttention mean that concurrency limits are softer than with contiguous KV cache, but they are not free. Monitor page-level utilization and the number of active block tables.

## Quantization Strategy

Weight quantization and KV cache quantization are separate decisions.

### Weight Quantization

Reduces the memory footprint of the model weights at load time, trading quality for VRAM or RAM savings.

| Technique | Bits | Quality Impact | Best For |
|---|---|---|---|
| **GGUF** (llama.cpp) | 2-8 | Low to moderate | CPU + GPU hybrid, Apple Metal, single-node serving |
| **GPTQ** | 2-8 | Low to moderate | GPU-only, throughput-oriented serving |
| **AWQ** | 4 | Very low | Production GPU serving — better quality-per-bit than GPTQ at 4-bit |
| **FP8 / FP4** | 8, 4 | Very low to low | Native hardware support on Hopper/Ada GPUs |

The practical rule: use the highest bit width that fits your VRAM budget with headroom. AWQ 4-bit is the current best quality-per-bit ratio for GPU serving. Always evaluate quantized quality on your actual task distribution, not on perplexity benchmarks.

### KV Cache Quantization

Reduces per-token memory consumption during decode, enabling longer context lengths or higher concurrency on the same hardware. KV cache quantization (FP8, INT8) is less well studied than weight quantization and can interact badly with long contexts or sparse attention patterns. Always validate against task-specific evals before enabling.

## Model Loading Phases

When a deployment reports "model loaded", the actual readiness depends on multiple phases:

1. **Disk → RAM**: model weights read from storage into system memory. This is I/O-bound and can take 30-120s for a 7B+ model depending on storage speed.
2. **RAM → VRAM**: weights transferred across PCIe. Bandwidth-bound. For large models this dominates loading time.
3. **Weight processing**: quantized models may need dequantization tables or GPTQ/AWQ post-processing. This happens in VRAM and takes seconds.
4. **CUDA graph capture**: runtime compiles attention and kernel execution graphs. vLLM and TensorRT-LLM do this at load time for static shapes.
5. **Cache warming**: the first few requests are disproportionately slow because GPU caches are cold, attention computation is not yet optimized, and the runtime is still discovering memory access patterns.

Operational implication: health checks after loading should not pass until phase 4-5 completes. Use dummy requests to warm the cache before accepting production traffic. Pre-load models during low-traffic windows or on deployment startup to avoid cold-start p99 spikes.

## Production Serving Architecture

Exposing model servers (Ollama, vLLM, llama.cpp) directly to clients is a security risk. The recommended production architecture uses a reverse proxy layer:

```
Client → TLS Termination → Rate Limiter → Auth Proxy → Model Router → Backend
```

- **TLS termination and rate limiting** at the proxy layer, not the model server.
- **Auth proxy** validates API keys or tokens before forwarding requests.
- **Model router** selects backend based on model name, context-length needs, or latency profile.
- **Two-instance pattern** for mixed workloads: instance A handles short-context high-concurrency requests (32K context, high throughput), instance B handles rare long-context requests (128K+ context, low concurrency).
- **Keep-alive policies** should be explicit per instance: dedicated instances keep models resident; shared instances may evict idle models for memory efficiency.
- **Health probe path** that reports not just process liveness but model readiness, VRAM utilization, and queue depth.

## Observability

Minimum useful telemetry includes prompt token count, output token count, prefill duration, decode duration, p50/p95/p99 latency, GPU memory, loaded models, active requests, queue depth, cache hit behavior, and truncation checks. Benchmarks should replay real prompt and output length distributions instead of uniform synthetic prompts.

Separate observability by request type: short-context vs long-context, streaming vs non-streaming, high-priority vs batch. A p99 metric that pools all types hides the fact that long-context requests are slow — that is expected, not a problem. What matters is whether each service-level objective (SLO) is met within its own request class.

## Links

- Parent: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Source: [[sources/local-llm-serving-mental-model|Local LLM Serving Mental Model]]
- Source: [[sources/local-llm-serving-operational-playbook|Local LLM Serving Operational Playbook]]
- Source: [[sources/production-ai-failure-modes|Beyond Shipped - Production AI Failure Modes]]

