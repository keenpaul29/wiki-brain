---
title: "I Deployed Local LLMs in Production for a Year. Part 2: The Operational Playbook | by Mustafa Genc | in AI Advances"
source: "https://freedium-mirror.cfd/https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-2-the-operational-playbook-cc903d6a4426"
author:
published:
created: 2026-05-05
description: "Your paywall breakthrough for Medium!"
tags:
  - "clippings"
---
[< Go to the original](https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-2-the-operational-playbook-cc903d6a4426#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/1*4o1Oad24YjEACgWxRgkEZg.png)

## I Deployed Local LLMs in Production for a Year. Part 2: The Operational Playbook[AI Advances](https://medium.com/ai-advances "Democratizing access to artificial intelligence")a11y-light ~23 min read · May 4, 2026 (Updated: May 4, 2026) · Free: Yes

### I Deployed Local LLMs in Production for a Year. Here's What the Tutorials Don't Tell You — Part 2: The Operational Playbook

*A hands-on field guide to running Ollama, llama.cpp, and vLLM past the* *`hello world`* *stage — the prefill/decode mental model, KV cache memory math you can actually do on a napkin, keep-alive behavior, concurrency queues hiding inside "async" APIs, the configuration knobs that actually matter, and the deployment mistakes that will page you at 3 AM.*

*Part 2 of a two-part series.* *[Part 1](https://medium.com/ai-advances/i-deployed-local-llms-in-production-for-a-year-part-1-the-mental-model-712a4a3f888f)* *built the mental model — prefill vs. decode, the KV cache formula, the hidden queue inside Ollama's API, and the three-phase reality of model loading. This part is the operational follow-up: configuration, tradeoffs, observability, benchmarking, and the specific mistakes I've made so you don't have to.*

If you skipped [Part 1](https://medium.com/ai-advances/i-deployed-local-llms-in-production-for-a-year-part-1-the-mental-model-712a4a3f888f), the short version: every LLM request is two workloads (compute-bound prefill, memory-bandwidth-bound decode), the KV cache often costs more VRAM than the model weights themselves, and the simple-looking Ollama API hides a FIFO queue that defaults to a single slot. With that foundation in place, the rest of this article is about what to do about it.

*If you liked this article, please clap — and if you're feeling generous, you can give up to 50 claps 👏*

### Context Length: The Knob That Costs More Than You Think

Every runtime has a context length parameter: `num_ctx` in Ollama, `--ctx-size` in llama.cpp's server, `--max-model-len` in vLLM. The tutorials say "set this to the model's maximum supported context." The tutorials are wrong in a way that will OOM your GPU.

We already derived the KV cache formula in [Part 1](https://medium.com/ai-advances/i-deployed-local-llms-in-production-for-a-year-part-1-the-mental-model-712a4a3f888f). Now look at what it means in practice.

**Worked example 1: a 24GB GPU serving Llama 3.1 8B.**

- Model weights at Q4\_K\_M: ~5 GB
- CUDA context + workspace: ~1.5 GB
- Available for KV cache: ~17 GB

At f16 KV cache and 1 parallel slot, you have budget for:

- 128K context: ~16 GiB / ~17.2 GB ✓ barely
- 32K context: ~4 GiB / ~4.3 GB

But at 4 parallel slots (because you raised `OLLAMA_NUM_PARALLEL=4` for concurrency):

- 128K × 4: ~64 GiB / ~68.7 GB ✗ OOM
- 32K × 4: ~16 GiB / ~17.2 GB ✓ barely
- 8K × 4: ~4 GiB / ~4.3 GB

**Worked example 2: the same GPU with KV cache quantized to q8\_0.**

Everything halves:

- 128K × 1 slot: ~8 GiB / ~8.6 GB
- 32K × 4 slots: ~8 GiB / ~8.6 GB
- 8K × 4 slots: ~2 GiB / ~2.1 GB

The q8\_0 KV cache lets you serve 4× more concurrency at 4× longer context than f16 on the same hardware, for a quality cost that's usually unmeasurable. This is the single highest-leverage optimization in local LLM serving.

**Rules I now follow:**

1. **Set context length to the 95th percentile of your actual request lengths**, not the model's maximum. Measure this. Don't guess. Every extra token increases KV cache linearly, which directly eats VRAM and reduces how many requests you can serve in parallel. In practice, most systems don't need anywhere near the maximum context (often requests stay under ~8K tokens), but this varies a lot by workload (chat vs. RAG vs. document QA). Setting context too high is one of the easiest ways to silently kill throughput.
2. **If you need large context occasionally, run two instances** — a short-context high-concurrency instance (*num\_ctx=4096, num\_parallel=8*) for most traffic, and a long-context low-concurrency instance (*num\_ctx=32768, num\_parallel=1*) for the outliers. Longer context means a much larger KV cache per request, which reduces how many requests fit into VRAM at the same time. Splitting workloads like this prevents rare long prompts from slowing down everything else. Route based on prompt length at the application layer. This is the *two-instance pattern*, and it's often worth the extra operational complexity because it keeps latency low for the majority of users.
3. **Use KV cache quantization by default, but verify quality on your own evals.** Quantizing the KV cache (e.g. *q8\_0, fp8*) roughly halves its memory usage, which usually translates into more parallel requests, longer context, or a balanced mix of both on the same hardware. This is one of the highest-leverage knobs in local LLM serving because KV cache often dominates memory, not the model weights. In many workloads, the quality impact is small enough to be hard to notice — but not always, especially for reasoning-heavy or code tasks. In Ollama, set *OLLAMA\_KV\_CACHE\_TYPE=q8\_0* (often paired with *OLLAMA\_FLASH\_ATTENTION=1* for performance). In llama.cpp, use *— cache-type-k q8\_0 — cache-type-v q8\_0*. In vLLM, use *— kv-cache-dtype fp8* on newer GPUs. Treat KV cache quantization as a high-leverage optimization — not a free one.

### The Most Underused Flag in Production LLM Serving: Prefix Caching

If KV cache quantization is one of the highest-leverage VRAM optimizations, prefix caching is one of the highest-leverage latency optimizations for workloads where requests share common prefixes — which is common in many production systems, but not universal.

**What it does.** Prefill is the compute-heavy phase where the model processes every input token. If multiple requests share the same prefix — system prompts, few-shot examples, or repeated RAG chunks — recomputing those tokens is wasted work.

Prefix caching stores KV cache blocks for previously seen token prefixes (typically at fixed block sizes like 16–256 tokens) and reuses them for future requests. When a cache hit occurs, the model skips prefill for the cached portion and only computes the new suffix.

**What it's worth.** In workloads with high prefix reuse (e.g. RAG systems or chatbots with long system prompts), prefix caching can significantly reduce time-to-first-token — sometimes by multiple times. The actual gain depends heavily on cache hit rate and prefix length. When hits are frequent, the saved compute can also improve overall throughput by freeing up GPU time.

**When it shines:**

- System prompts longer than ~200 tokens (everything after them benefits)
- Few-shot prompting (the examples are reused verbatim)
- RAG with retrieved chunks that repeat across requests
- Chat applications where conversation history grows append-only
- Agent workflows where the task description and tool schemas are stable

**When it doesn't help:**

- Every request is completely unique (e.g., document summarization where each input is a new document)
- Prefix variance starts at token 1 (e.g., user questions directly appended to a tiny system prompt)

**How to turn it on.** In vLLM, `--enable-prefix-caching`. It's off by default because it costs some VRAM (the prefix cache lives in the KV cache pool) and because for truly-unique-request workloads it's pure overhead. In llama.cpp, prefix caching is automatic for single requests but shared across requests only in recent versions — check `--cache-reuse`. Ollama currently has no prefix cache across requests; this is one of its real functional gaps for production serving.

Turning `--enable-prefix-caching` on for a RAG service with a 1,500-token system prompt and retrieved-chunk repetition is often a 2–5× throughput multiplier with no quality impact and no hardware cost. It's the closest thing to a free lunch in LLM deployment, and it's off by default because the tool's authors can't know your workload.

### Keep-Alive: The Memory Contract You Didn't Know You Signed

`OLLAMA_KEEP_ALIVE=5m` is the default. It means: after the last request to a given model, keep it loaded in VRAM for five minutes; then unload.

This default exists because on a laptop, you probably want VRAM freed for other work after a chat session. On a server, it's usually the wrong choice. If your traffic is sporadic — a request every 6 minutes on average — every single request pays the warm reload cost (5–15 seconds for a mid-sized model). Your users experience an LLM that's unreliably slow, and the latency variance looks mysterious because the daemon reports "model loaded" most of the time.

Three keep-alive strategies I actually use:

1. **`OLLAMA_KEEP_ALIVE=-1`** (keep indefinitely) for dedicated serving nodes where the LLM is the only workload. The model stays resident forever; reloads only happen on process restart. This is the right default for 90% of production services.
2. **`OLLAMA_KEEP_ALIVE=24h`** for shared nodes where you want the model evicted overnight but resident during business hours. Matches the actual traffic pattern without burning VRAM when nobody's using it.
3. **`OLLAMA_KEEP_ALIVE=0`** (unload immediately) for batch processing jobs where you're running one model, doing a job, and switching to another. Counterintuitive, but it prevents VRAM fragmentation when you're cycling through models repeatedly — each load starts from a clean VRAM state.

A trap I didn't see documented anywhere: `OLLAMA_MAX_LOADED_MODELS` defaults to 3 × num\_GPUs (or 3 on CPU). If different models are being pulled by different endpoints — a small model for classification, a large model for generation, an embedding model for retrieval — all three can be resident simultaneously. If their combined VRAM exceeds your GPU budget, Ollama's LRU **(Least Recently Used)** eviction kicks in when a fourth request comes in. The eviction is silent. Your p99 latency spikes because a user's request triggered a reload of a different model they didn't ask for.

Set `OLLAMA_MAX_LOADED_MODELS=1` on servers hosting a single model. Set it to exactly the number of models you intend to host, and verify your VRAM budget accommodates all of them resident simultaneously. Don't rely on the default — it's a multi-tenant default in a single-tenant world, and it will bite you specifically when you're trying to add a second model "just for one feature."

### Two Quantizations, Not One: Weights and KV Cache

Quantization is usually discussed as if there's a single knob. In reality, there are two — and they do very different things. They impact different parts of the system, have different quality tradeoffs, and consume different amounts of VRAM.

**Weight quantization** reduces the size of the model itself by lowering the precision of its parameters. The weights are loaded from disk in whatever format the GGUF file was generated with (you choose this upfront). Common GGUF quantizations include:

![None](https://miro.medium.com/v2/resize:fit:700/1*MTv3pTqkp8eRYAciz91Orw.png)

The K-quants (Q4\_K\_M, Q5\_K\_M, etc.) use a more sophisticated block structure — allocating higher precision to more important weights — and generally outperform older "legacy" formats (Q4\_0, Q4\_1) at the same memory budget. Use [K-quants](https://www.reddit.com/answers/cfba8926-3e5b-41bd-8503-808f5151453d/?q=K+quantization+mechanism&source=SERP&upstreamCID=1b042236-9761-4967-a724-839ddc415a9e&upstreamIID=760df122-4961-4ade-8540-cf2a9b79783b&upstreamQ=K+quantization+mechanism&upstreamQID=8e512d53-d015-40a6-b33e-11d231504778) when available.

The important quality boundary is between Q4 and Q3 — not between F16 and Q4. In practice, most production systems can run Q4\_K\_M without any noticeable impact on user-facing quality. Running F16 "for safety" is often just burning 3–4× more VRAM without measurable benefit.

**KV cache quantization is a different lever entirely.** It does not change the model. Instead, it changes the precision of the K and V tensors stored during inference. This directly reduces both:

- KV cache VRAM usage
- Memory bandwidth during decode (which is usually your real bottleneck)

The quality impact is typically small, but different in nature from weight quantization — it can affect how well the model distinguishes subtle differences between tokens, especially at longer contexts.

Available in llama.cpp / Ollama:

In vLLM on Hopper/Ada GPUs, `--kv-cache-dtype fp8` is the equivalent. It also benefits from hardware acceleration, improving both memory efficiency and decode speed—a rare double win.

**The combined recipe I use for most deployments:**

- **Weights:** Q4\_K\_M or Q5\_K\_M (Use F16 only if you've explicitly benchmarked and need the difference)
- **KV cache:** q8\_0 (or fp8 on vLLM with supported hardware)
- **Flash attention:** on (required for KV cache quantization in Ollama, and generally improves performance)

This setup typically cuts VRAM usage roughly in half compared to default settings, without measurable quality impact on chat, classification, RAG, or summarization workloads. As always, validate on your own evaluations — but the prior strongly favors this configuration.

### The Configurations That Actually Move the Needle

Ollama exposes 15+ environment variables. Most of them don't matter in production.

These six do.

They are the difference between something that "works" in a demo — and something that survives real traffic.

On the Modelfile side, `num_ctx` is the one parameter you must set explicitly. Leaving it at 4096 when you expected the model's native context is the #1 bug I see in deployed Ollama services.

For llama.cpp's server, the equivalent flags and their sane-defaults:

For vLLM, the knobs that matter most:

The delta between a naïve `vllm serve` and a well-configured one is not marginal. On an A100 serving an 8B model, I've seen throughput go from 800 tokens/sec to 3,200 tokens/sec by enabling prefix caching and FP8 KV cache alone. No model change, no hardware change — just knobs.

### Tradeoffs, Named and Priced

Every optimization above costs something. The three tradeoff axes you're actually negotiating:

**Memory vs. Context Length.** Bigger context means a larger KV cache, which directly reduces how much VRAM is left for concurrency. On a 24GB GPU serving an 8B model, a single 32K request can consume more VRAM than four 4K requests. If your traffic skews short, capping context is the cheapest throughput win you have. If your workload truly needs long context, your options are: a larger GPU, KV cache quantization (q8\_0 or fp8), or the two-instance pattern (short-context/high-concurrency + long-context/low-concurrency, routed at the application layer).

The priced version: on an A100 40GB with an 8B model and q8\_0 KV cache, you can serve either ~16 concurrent requests at 4K context or ~2 at 32K. Your actual context distribution determines which configuration feels "fast" to users.

**Throughput vs. Latency.** These pull in opposite directions. Continuous batching (vLLM) maximizes throughput — more requests per second — but individual latency can vary depending on batch composition. FIFO serving (default Ollama) prioritizes predictability — each request runs in isolation — but leaves throughput on the table.

Some techniques bend the curve: speculative decoding and prefix caching can reduce latency *and* increase throughput — but only when your workload fits (predictable token streams for speculation, shared prefixes for caching). Neither is a universal win.

The priced version: if your SLA is p99 < 3s at ~10 Requests Per Second (RPS), Ollama with OLLAMA\_NUM\_PARALLEL=4 is often enough on an A100 with an 8B model. At ~100 RPS, you're in vLLM territory. At ~1000 RPS, you need vLLM + prefix caching + FP8 KV cache + horizontal scaling — and multiple A100s in your budget.

**Simplicity vs. Performance.**Ollama is simpler. vLLM is faster. llama.cpp gives you the most control — and the most responsibility.

A small team without dedicated MLOps probably shouldn't run vLLM with tensor parallelism in Kubernetes — the operational overhead will outweigh the performance gains. A high-traffic system shouldn't stay on Ollama — the per-request inefficiency compounds into real cost.

The honest version: pick the simplest system that meets your latency and cost targets. Then test it at 3× your current load. Only move up the complexity curve when the data forces you to. Premature complexity is just as expensive as premature optimization.

### If You Can't See It, You Can't Tune It

The biggest gap between deployments that "work" and those that fail mysteriously is observability. Ollama's default logs tell you two things: the model loaded, and requests arrived. That's not enough.

They don't tell you:

- queue depth
- KV cache utilization
- prefill vs. decode time
- token/sec throughput
- whether a request was truncated

Without these, you're guessing.

**Minimum viable observability for a local LLM service:**

**Per-request metrics:**

- `prompt_eval_duration` (prefill time)
- `eval_duration` (decode time)
- `prompt_eval_count` (prefill tokens)
- `eval_count` (decode tokens)

Derived:

- time-to-first-token ≈ `prompt_eval_duration`
- tokens/sec = `eval_count / eval_duration`

Ollama returns these in the response body of `/api/generate` and `/api/chat`. Capture them, log them, and chart them. They are your ground truth.

**Per-instance metrics:**

- GPU VRAM usage (`nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits`)
- GPU utilization over time (use 10s windows — instant values are misleading)
- Loaded models (`/api/ps`)
- Active request count
- Pending request queue depth (you need to instrument this at the reverse proxy — Ollama doesn't expose it)

**Per-request logging that actually matters:**

- Tokenized prompt length (not just string length — tokens ≠ chars)
- Whether the prompt was truncated (measure at the application layer: `tokens_in_prompt > num_ctx - expected_output_tokens`)
- Output token count
- User or tenant identifier (for capacity planning)
- The actual prompt (sampled, for debugging)

**The one chart you always need:**

p50, p95, and p99 latency over time, grouped by request type.

Read it like this:

- p99 ≫ p95 → queuing or eviction problem
- p95 ≫ p50 → prefill problem (prompt length variance)
- gradual upward drift → memory leak or cache fragmentation

If you don't have this chart, you don't have observability.

For vLLM, most of this comes out of the box via the Prometheus metrics endpoint. Enable it with `--disable-log-requests` (this disables request logs, not metrics) and scrape `/metrics`.

For Ollama, you need to build it yourself: a sidecar or reverse proxy (e.g., Caddy + Prometheus exporter) to turn response-body timing fields into metrics.

### Your Benchmark Is Lying To You

Every runtime's landing page shows throughput numbers. They're not wrong. They're just not relevant to you.

Vendor benchmarks typically use:

- Uniform prompt lengths (often 128 or 512 tokens)
- Uniform output lengths (often 128 or 512 tokens)
- Dense concurrency (N simultaneous requests, no pauses)
- No prefix sharing OR trivially-sharable prefixes
- Idealized hardware (PCIe 5.0, dedicated GPU, no noisy neighbors)

Your production traffic looks like:

- Prompt lengths from 50 to 20,000 tokens with a long tail
- Output lengths from 10 to 4,000 tokens, varying by task
- Bursty concurrency with minutes of quiet between spikes
- Heavy prefix sharing (system prompts, RAG chunks) OR none (document summarization), depending on the endpoint
- Real hardware: real NUMA topology, real background processes, real restarts that wipe your warmup

The numbers you'll see in production are typically:

- **30–60% of the advertised throughput**
- **3–5× higher p99 latency than the reported median**

This isn't because the vendor lied. It's because they reported a best case — and you're running an average case.

How to load-test properly:

1. **Capture real traffic.** Log every prompt — or a representative sample — for a week. You need the actual distribution: prompt lengths, output lengths, and arrival patterns.
2. **Replay it.** Feed that log into your candidate configurations using locust, k6, or even a simple asyncio script. Real prompts, real timing — not synthetic uniform load.
3. **Measure the right things.** Track p50, p95, p99 latency and sustained throughput over 10-minute windows. Short tests won't show warmup effects or memory leaks.
4. **Change one thing at a time.** Don't tweak five knobs and celebrate the aggregate win. You won't know what actually worked — and when you upgrade, you'll guess wrong.
5. **Test beyond your comfort zone.** Run at 2× your expected peak traffic. Systems that look fine at steady state often fail under bursts. Better to find the failure mode now than at 3 AM.

The payoff for doing this properly is boring and unambiguous: you get a number you can trust for capacity planning.

The payoff for not doing it is also unambiguous: getting paged at 3 AM and discovering your "tested" system fails at 1.3× load.

### Common Mistakes I've Made (So You Don't Have To)

I've made every one of these. I now check each of them explicitly on every deploy. For each, I'll name the mistake, the symptom you'll see, and how to verify you've actually fixed it.

**1\. Trusting the advertised context window.** The model card says 128K. The runtime defaults to 4096. You deploy.

> **Symptom:** prompts are silently truncated past 4096 tokens; the model appears to "forget" the system prompt intermittently, depending on prompt length.

> **Detection:** log tokenized prompt length and compare it to `num_ctx` at request time. Any request where `tokens_in_prompt + max_output > num_ctx` is affected.

> **Fix:** set `num_ctx` explicitly (Modelfile or per-request). Verify with a test prompt of `num_ctx - 10` tokens and observe truncation behavior.

**2\. Confusing model size with VRAM requirement.** "An 8B Q4 model is ~5GB, so it fits on my 8GB GPU."

> **Symptom:** the process starts fine; the first large request OOMs.

> **Detection:** compute `model_size + (kv_cache_at_full_context × num_parallel_slots) + ~2GB` and compare it to actual VRAM. The extra ~2GB covers CUDA runtime, workspace, and margin.

> **Fix:** increase VRAM, reduce `num_ctx`, reduce `num_parallel`, or enable KV cache quantization. Verify with `nvidia-smi` during a full-context request— **peak VRAM matters, not idle VRAM.**

**3\. Enabling Flash Attention without checking GPU generation.** Flash Attention requires modern compute capability — typically Turing (7.5+) or newer.

> **Symptom:** either unexpected startup errors, or no performance gain when you expected a 30–50% speedup at long contexts.

> **Detection:** `nvidia-smi --query-gpu=compute_cap --format=csv` and compare with the requirements of your Flash Attention version.

> **Fix:** only enable `OLLAMA_FLASH_ATTENTION=1` on GPUs with compute capability ≥ 7.5. On older GPUs, expect fallback behavior—or no benefit. If you need KV cache quantization there, your only real option is upgrading hardware.

**4\. Running F16 when lower precision is indistinguishable.** F16 *looks* like the safe, high-quality option.

> **Symptom:** 2×–4× VRAM usage with no measurable quality improvement.

> **Detection:** run your eval suite (you do have one) on F16 vs Q5\_K\_M / Q8\_0. Compare aggregate metrics and inspect samples. For chat, RAG, and summarization, differences are usually negligible.

> **Fix:** use Q4\_K\_M / Q5\_K\_M (weights) and q8\_0 (KV cache) in production. Reserve F16 for explicitly validated, quality-critical cases.

**5\. Thinking "100% GPU utilization" means "optimal performance."** `nvidia-smi` shows 100%, so you assume the GPU is fully utilized.

> **Symptom:** low throughput, unclear bottleneck, wasted time profiling application code.

> **Detection:** `utilization.gpu` only tells you that *some* kernel is running—not whether you're compute-bound or memory-bound. Measure tokens/sec and compare to theoretical limits (memory bandwidth ÷ bytes per decode step).

> **Fix:** reduce memory pressure (Flash Attention, KV cache quantization), or increase batching. If performance is still low, you're likely compute-bound — upgrade hardware.

**6\. Load-testing with uniform prompts.** You test with 100 identical 512-token prompts and trust the result.

> **Symptom:** production throughput is ~40% of your benchmark; real p99 is 3× higher.

> **Detection:** compare prompt length distribution in tests vs production logs. If test variance is low (<10%) and production variance is high (>100%), your benchmark is meaningless.

> **Fix:** replay real request distributions (prompt length, output length, arrival patterns). Re-run after every config change.

**7\. Assuming OpenAI compatibility means identical behavior.** You write against OpenAI's API, then point `base_url` to Ollama or vLLM.

> **Symptom:** features work in dev but break in production — structured outputs, function calling, logprobs, streaming, stop sequences.

> **Detection:** build a compatibility test suite for the features you use. Run it against each backend. Differences are subtle and version-dependent.

> **Fix:** explicitly document required features and test them per backend. Ollama's function calling and vLLM's `guided_json` are common edge cases.

**8\. Skipping warmup after model load.** You restart the service and ignore the first slow requests.

> **Symptom:** first N users after deploy see 3–5× slower responses.

> **Detection:** measure time-to-first-token for the first 10 requests after restart. If #1 is >2× #10, you have a warmup problem.

> **Fix:** run a warmup request (small prompt, small `max_tokens`) on startup. Let CUDA init, JIT compile, and memory pages warm. Start serving traffic only after that.

**9\. Deploying without a reverse proxy.** Ollama has no auth, no TLS, no rate limiting. You expose `0.0.0.0:11434`.

> **Symptom:** your service is either abused silently or used as a proxy in attacks — and your logs won't clearly show it.

> **Detection:** run `nmap` from outside. If port 11434 is reachable, you have a problem.

> **Fix:** always place Ollama behind a reverse proxy (nginx, Caddy, Traefik) with TLS, API key auth, and rate limiting. Bind the model server to an internal interface only.

### A Reference Configuration, Explained

This is what I actually deploy for a mid-sized internal service — 10–20 concurrent users, mixed RAG and classification traffic, one Llama 3.1 8B-class model on a single A100 40GB. Every line has a reason.

```
# /etc/systemd/system/ollama.service
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/local/bin/ollama serve
User=ollama
Group=ollama
Restart=always
RestartSec=3

# Bind to all interfaces - reverse proxy in front handles TLS and auth.
# Without the reverse proxy, this is a security incident.
Environment="OLLAMA_HOST=0.0.0.0:11434"

# 4 concurrent slots: enough for ~20 bursty users given our request
# duration distribution. Higher would need more KV cache VRAM.
Environment="OLLAMA_NUM_PARALLEL=4"

# Only load one model on this node. Prevents surprise LRU eviction of
# the wrong model when someone pulls a second model via the API.
Environment="OLLAMA_MAX_LOADED_MODELS=1"

# Keep model resident indefinitely - this is a dedicated serving node,
# so the VRAM has no better use.
Environment="OLLAMA_KEEP_ALIVE=-1"

# Flash attention: faster decode, lower memory traffic, required for
# KV cache quantization. A100 is compute capability 8.0 - FA is supported.
Environment="OLLAMA_FLASH_ATTENTION=1"

# Halve the KV cache VRAM footprint. Measured: no quality regression on
# our RAG eval versus f16. Saves enough VRAM to run with 4 parallel slots.
Environment="OLLAMA_KV_CACHE_TYPE=q8_0"

[Install]
WantedBy=default.target
```

Paired with a Modelfile that sets the context window and sampling defaults explicitly:

```yaml
# Modelfile
FROM llama3.1:8b

# 8K context - empirically covers >95% of our actual requests.
# KV cache math: 2 × 32 × 8 × 128 × 1 (q8_0) × 8192 × 4 slots ≈ 2 GB total.
# Model weights Q4_K_M ≈ 5 GB. Total footprint ≈ 7 GB. A100 40GB has ample room.
PARAMETER num_ctx 8192

# Low temperature for RAG consistency; raise to 0.7+ for creative tasks.
PARAMETER temperature 0.3
PARAMETER top_p 0.9

# System prompts live in the app layer, not here - separates
# model configuration from product configuration.
```

And a reverse proxy (Caddy in this example — simple, handles TLS automatically):

```perl
# /etc/caddy/Caddyfile
llm.internal.example.com {
    reverse_proxy localhost:11434 {
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
    }

    # API key auth - minimum viable
    @unauthenticated not header Authorization "Bearer {env.LLM_API_KEY}"
    respond @unauthenticated 401

    # Rate limit: 60 requests per minute per API key
    # (requires caddy-ratelimit plugin)
    rate_limit {
        zone per_key {
            key {http.request.header.authorization}
            events 60
            window 60s
        }
    }

    # Log every request for audit + observability
    log {
        output file /var/log/caddy/llm.log
        format json
    }
}
```

For a vLLM-based equivalent on the same hardware:

```
vllm serve meta-llama/Meta-Llama-3.1-8B-Instruct \
    --host 0.0.0.0 \
    --port 8000 \
    --max-model-len 8192 \
    --gpu-memory-utilization 0.92 \
    --max-num-seqs 64 \
    --enable-prefix-caching \
    --enable-chunked-prefill \
    --kv-cache-dtype fp8 \
    --disable-log-requests
```

Key differences from the Ollama config:

- `--max-num-seqs 64`: vLLM's continuous batching handles 64 concurrent sequences in one batch without the 4-slot limit; we still cap it to keep KV cache headroom for prefix caching.
- `--enable-prefix-caching`: the RAG workload has heavy system-prompt repetition — this is our biggest single win.
- `--enable-chunked-prefill`: interleaves prefill chunks with decode steps, smoothing latency when a long prompt arrives while other requests are mid-decode.
- `--kv-cache-dtype fp8`: A100 doesn't have hardware FP8, but vLLM's software FP8 path still helps; on H100/H200, this doubles effective KV capacity with hardware acceleration.

On the same A100, this vLLM config serves roughly 4–6× the throughput of the Ollama config at similar latency. The cost: HuggingFace model format only (no GGUF convenience), NVIDIA-only runtime, heavier Docker image, a harder-to-debug component. That's the tradeoff, priced honestly.

### Counter-Arguments and What We Don't Know

This is the honest section. Every recommendation above has limits — and it's better to name them explicitly than pretend they don't exist.

**The 10× vLLM throughput advantage isn't universal.** The vLLM blog cites up to 24× vs HF Transformers and ~3.5× vs TGI, measured on specific workloads in [2023](https://arxiv.org/abs/2511.17593). Those numbers reflect particular conditions: model size, prompt distribution, and hardware. Since then, TGI has improved, llama.cpp has improved, and Ollama has improved its scheduling. On your workload, the gap might be 10×, 3×, or barely noticeable. Always measure on your own traffic.

**Ollama's scheduling model is a moving target**. As of this writing, `OLLAMA_NUM_PARALLEL` provides slot-based parallelism rather than continuous batching. That may change. Recent versions have already introduced smarter scheduling, and future versions may blur or remove the strict "slot" model. Verify against current documentation instead of assuming the behavior described here is stable.

**KV cache quantization quality impact depends on your evaluation.** "No measurable quality loss" means "no measurable loss on common benchmarks and in these specific use cases." Long-context reasoning, precise numerical tasks, and code generation can show regressions — especially at more aggressive levels like q4\_0 — that don't show up in standard chatbot evals. Run your own task-specific evaluations before committing. For q8\_0, regressions are rare enough that it's generally safe as a default — but still worth validating.

**The** **`num_ctx=4096`** **default is also a moving target.** Ollama has discussed raising it in future releases. If you're reading this later and the default has changed, update your mental model accordingly. The underlying rule doesn't change: always set `num_ctx` explicitly and never rely on defaults.

**Hardware matters more than most guides admit.** The tradeoffs in this article assume modern NVIDIA GPUs. Apple Silicon (Metal), AMD (ROCm), and Intel (Level Zero) change the picture significantly. Apple's unified memory removes PCIe transfer costs but caps you at system RAM. ROCm support is strong in llama.cpp but still evolving in vLLM. Most "your mileage may vary" disclaimers apply far more strongly outside the NVIDIA ecosystem.

**This article assumes single-node, single-GPU deployments.** Multi-GPU setups (tensor parallelism) and multi-node serving introduce a different class of tradeoffs: interconnect bandwidth, communication overhead, and request routing become first-order concerns. PagedAttention behaves differently under tensor parallelism, and prefix caching becomes sensitive to routing decisions. That's a separate discussion.

**Observability inside the runtime is still limited.** Ollama and llama.cpp expose per-request timing, but not the deeper scheduler-level metrics that vLLM provides (queue depth, batch composition, KV cache utilization). If you're operating at scale, you'll need to build observability at the application layer — and accept that some runtime behavior remains opaque.

**Finally,** **quantization itself may not be the long-term answer.** The field is moving toward architectures that are efficient by design: mixture-of-experts with small active parameter counts, linear attention, and state-space models. The quantization strategies in this article are correct today — but in a few years, the dominant optimization may shift from compressing large dense models to selecting fundamentally more efficient ones. Don't let "Q4\_K\_M is good enough" turn into dogma.

### What This Means For You

Four takeaways, each named with the condition it applies to:

**If you're deploying for a handful of users on a single GPU:** Use Ollama. Set `OLLAMA_NUM_PARALLEL=4`, `OLLAMA_KEEP_ALIVE=-1`, `OLLAMA_FLASH_ATTENTION=1`, `OLLAMA_KV_CACHE_TYPE=q8_0`, and set `num_ctx` to the 95th percentile of your real prompt lengths. Put Caddy or nginx in front with API key auth. Log `prompt_eval_duration` and `eval_duration` per request. That's enough. Don't over-engineer.

**If you're operating at >50 RPS or targeting sub-second p99 latency:** Use vLLM. Enable `--enable-prefix-caching` if your workload has shared prefixes (it usually does). Use `--kv-cache-dtype fp8` on Hopper/Ada GPUs. Set `--max-model-len` to your actual 95th percentile, not the model's advertised maximum. Start scraping `/metrics` into Prometheus from day one. The system is more complex, but the cost per request is significantly lower—and at this scale, that's what matters.

**If you're serving multiple models:** Set `OLLAMA_MAX_LOADED_MODELS` to exactly the number of models you intend to keep resident. Then verify their combined VRAM usage (weights + KV cache × `num_parallel`) fits your GPU. Never rely on the default—it will silently evict models you care about and show up as unexplained latency spikes.

**If latency is bad and you don't know why:** Measure prefill and decode separately. Go back to the prefill vs. decode model from [Part 1](https://medium.com/ai-advances/i-deployed-local-llms-in-production-for-a-year-part-1-the-mental-model-712a4a3f888f). In aggregate latency, these look identical — but they require completely different fixes. Don't optimize until you know which phase you're dealing with.

### Lessons Learned

Five things I'd tell my past self, the one who ran `curl | sh` twenty minutes before a demo:

1. **Defaults are for demos, not deployments.** Runtime defaults are tuned for the most common use case. If you're deploying a service, you are not that use case. Read every environment variable. Set the ones that matter explicitly. Know why you set them.
2. **Measure before you optimize, and measure with real traffic.** Synthetic benchmarks lie about both throughput and latency. Capture real requests, replay them against candidate configurations, and compare p50/p95/p99 — not averages. Averages hide your worst users.
3. **KV cache is the silent budget.** Your GPU budget isn't just model size. It's model weights + KV cache + parallel slots + CUDA overhead. KV cache is often the largest and least visible cost. Understand the math. Keep a spreadsheet. Don't guess.
4. **Simplicity compounds; so does complexity.** Ollama's simplicity is an asset: fewer moving parts, fewer failure modes, fewer 3 AM surprises. vLLM's performance is an asset: lower cost per request, better throughput at scale. Neither is free. Choose based on your constraints — and revisit the decision as your scale changes.
5. **The runtime is not the product.** Users don't care what you run. They care that responses are fast, consistent, and correct. A well-tuned Ollama beats a poorly configured vLLM every time. The real engineering work is in tuning, observability, and request routing — not in picking a tool.

If this two-part series saved you a 3 AM debugging session, follow for more posts like this. The companion article covers the "which tool should I use?" question this series assumes you've already answered. And if you missed it, [Part 1](https://medium.com/ai-advances/i-deployed-local-llms-in-production-for-a-year-part-1-the-mental-model-712a4a3f888f) builds the mental model — prefill vs. decode, KV cache math, hidden queues, model loading — that everything here depends on.

### Sources

- [Ollama FAQ](https://github.com/ollama/ollama/blob/main/docs/faq.md) — authoritative source for environment variable defaults
- [Ollama API reference](https://github.com/ollama/ollama/blob/main/docs/api.md) — per-request timing fields
- [Ollama GitHub repository](https://github.com/ollama/ollama) — envconfig reference for all supported environment variables
- [Ollama model library](https://ollama.com/library) — registry for GGUF models, quantization level choices
- [llama.cpp server README](https://github.com/ggerganov/llama.cpp/blob/master/tools/server/README.md) — flag reference for `--flash-attn`, `--cache-type-k` / `-v`, `--parallel`, `--ctx-size`
- [llama.cpp repository](https://github.com/ggerganov/llama.cpp) — the C/C++ inference engine under Ollama
- [vLLM engine arguments documentation](https://docs.vllm.ai/en/latest/serving/engine_args.html) — authoritative source for `gpu-memory-utilization`, `max-model-len`, `max-num-seqs`, `enable-prefix-caching`, `kv-cache-dtype`, `enable-chunked-prefill`
- [vLLM documentation home](https://docs.vllm.ai/en/latest/) — complete reference
- [vLLM blog: "Easy, Fast, and Cheap LLM Serving with PagedAttention"](https://blog.vllm.ai/2023/06/20/vllm.html) — KV cache memory waste figures, throughput improvements
- [PagedAttention paper (Kwon et al., SOSP 2023)](https://arxiv.org/abs/2309.06180) — original research behind vLLM's memory architecture
- [FlashAttention paper (Dao et al., 2022)](https://arxiv.org/abs/2205.14135) and [FlashAttention-2 paper (Dao, 2023)](https://arxiv.org/abs/2307.08691)
- [Grouped Query Attention paper (Ainslie et al., 2023)](https://arxiv.org/abs/2305.13245)
- [GGUF format specification](https://github.com/ggerganov/ggml/blob/master/docs/gguf.md)

[< Go to the original](https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-2-the-operational-playbook-cc903d6a4426#bypass)