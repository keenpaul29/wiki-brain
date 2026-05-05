---
title: "I Deployed Local LLMs in Production for a Year. Part 1: The Mental Model | by Mustafa Genc | in AI Advances"
source: "https://freedium-mirror.cfd/https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-1-the-mental-model-712a4a3f888f"
author:
published:
created: 2026-05-05
description: "Your paywall breakthrough for Medium!"
tags:
  - "clippings"
---
[< Go to the original](https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-1-the-mental-model-712a4a3f888f#bypass)

![Preview image](https://miro.medium.com/v2/resize:fit:700/1*4PwTlDMmJfC9ZdOGFcejiQ.png)

## I Deployed Local LLMs in Production for a Year. Part 1: The Mental Model[AI Advances](https://medium.com/ai-advances "Democratizing access to artificial intelligence")a11y-light ~18 min read · May 4, 2026 (Updated: May 4, 2026) · Free: Yes

### I Deployed Local LLMs in Production for a Year. Here's What the Tutorials Don't Tell You — Part 1: The Mental Model

*A hands-on field guide to running Ollama, llama.cpp, and vLLM past the* *`hello world`* *stage — the prefill/decode mental model, KV cache memory math you can actually do on a napkin, keep-alive behavior, concurrency queues hiding inside "async" APIs, the configuration knobs that actually matter, and the deployment mistakes that will page you at 3 AM.*

*Part 1 of a two-part series. This part builds the conceptual foundation: how requests actually execute, where the memory really goes, what the API is hiding from you, and why "the model is loaded" doesn't mean what you think it means.* *[Part 2](https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-2-the-operational-playbook-cc903d6a4426?postPublishedType=repub)* *is the operational follow-up — configurations, tradeoffs, observability, and the specific mistakes I've made.*

The first time I deployed a local LLM to serve real traffic, the setup took twenty minutes. `curl` the install script, `ollama pull llama3.1:8b`, point an app at `localhost:11434`, done. The tutorial said so. The README said so. Every blog post I'd read said so.

Three weeks later, I was on a call with a product manager explaining why a feature that "worked perfectly in demo" was timing out in production. The logs showed nothing unusual. The GPU was "fine" — `nvidia-smi` reported 40% utilization, plenty of VRAM free. The model was "loaded" — Ollama said so. But every fourth request was coming back empty, the second-fastest [p99](https://aerospike.com/blog/what-is-p99-latency/) was four times the p50, and a warm reload after a quiet Monday morning had OOM'd a GPU that had been serving the same model for six days.

Here's what I learned that week — and spent the next year refining. Ollama's default `num_ctx` is 4096 tokens regardless of what the model card says. `OLLAMA_NUM_PARALLEL=1` is the default, which means "concurrent users" are actually a FIFO queue wearing a trench coat. The "loaded" model can get silently paged out of RAM by Linux under memory pressure, costing you the full cold-load latency on the next request even though the daemon thinks everything's fine. The KV cache, which nobody's tutorial mentioned, was consuming more VRAM than the model weights.

This is the article I wish I'd had. It's a companion to *[Ollama vs vLLM: A Comprehensive Guide to Local LLM Serving](https://medium.com/@mustafa.gencc94/ollama-vs-vllm-a-comprehensive-guide-to-local-llm-serving-91705ec50c1d)* — that one tells you which tool to pick. This one tells you what happens after you pick it: when the demo is over, real traffic is hitting your server, and the gap between the landing-page throughput numbers and your actual p99 is big enough to fit a mid-sized consulting engagement.

If you're deploying local LLMs — as an internal API, as a teammate's backend, as a production service — and you've ever wondered why memory usage doesn't match any formula in the docs, why the second request is mysteriously slower than the first, or why your GPU is pinned at 100% serving what feels like three users, this two-part series is for you. **Part 1 (this article)** builds the mental model. **[Part 2](https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-2-the-operational-playbook-cc903d6a4426?postPublishedType=repub)** covers configuration, tradeoffs, observability, and the mistakes I've made so you don't have to.

*If you liked this article, please clap — and if you're feeling generous, you can give up to 50 claps 👏*

### The Seven Things Tutorials Don't Tell You

![None](https://miro.medium.com/v2/resize:fit:700/1*m6rWRCdNdIqP7P9UL89KNw.png)

Most tutorials cover installation. This series covers everything else. Seven deployment realities I had to learn the hard way:

1. Every request has two phases with different bottlenecks. Prefill is compute-bound; decode is memory-bandwidth-bound. Optimizations that help one often hurt the other.
2. The "simple API" has a queue, and the queue is shorter than you think. Default concurrency on Ollama is one request at a time per model.
3. The KV cache, not the model weights, is your scaling bottleneck. You cannot understand VRAM until you can compute KV cache size.
4. Model loading is a three-phase process, not one. Disk → RAM → VRAM, each with its own caching, its own failure mode, its own first-request penalty.
5. Context length is the single most expensive knob you can turn — the model card's "128K" is a lie your runtime will charge you 16GB to make true.
6. Keep-alive is a memory contract, not a performance optimization. Misconfigure it and you'll either OOM or burn 30 seconds per request reloading from disk.
7. The runtime is not your bottleneck — the request mix is. Throughput numbers on landing pages assume uniform prompts. Your traffic is not uniform.

Part 1 covers the first four — the conceptual foundations. [Part 2](https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-2-the-operational-playbook-cc903d6a4426?postPublishedType=repub) picks up at context length and works through the operational side: configuration, tradeoffs, observability, benchmarking, and the specific mistakes I've made and how to detect each one.

Every section is deeper than the version you've seen on every LLM serving blog. We're going to actually derive the KV cache formula, walk through what happens at the CUDA kernel level, and name the exact flag to flip. No hand-waving.

### Prefill and Decode: The Two Phases Every Request Goes Through

If you remember one thing from this article, remember this: every LLM request is actually two workloads glued together, and they have completely different performance characteristics.

**Prefill** is what happens when your prompt first arrives. The model processes all N input tokens in one big parallel batch, computing the attention keys and values for every token. This is **compute-bound** — the GPU's floating-point units are the bottleneck. Prefill scales roughly linearly with prompt length on modern hardware, but with very high utilization of the GPU's tensor cores. A 2,000-token prompt might prefill in 100ms on an A100; a 20,000-token prompt might take 1 second.

**Decode** is what happens after prefill — generating output tokens one at a time. Each new token requires a single forward pass through the model, reading the entire KV cache (which grows with each token generated) and the model weights from memory. This is **memory-bandwidth-bound** — the GPU's VRAM bandwidth is the bottleneck, not its compute. A single decode step on an 8B model on an A100 is roughly 10–15ms regardless of prompt length, dominated by the time it takes to stream the model weights through the compute units. For a 500-token response, decode is ~5–7 seconds of pure GPU time.

This distinction explains nearly every deployment pathology:

- **Why the first token takes longer than subsequent tokens:** the first token includes all of prefill (compute-bound, can be fast for small prompts but balloons for long ones). Subsequent tokens are pure decode (memory-bound, steady per-token cost).
- **Why "time to first token" and "tokens per second" are different metrics:** they measure different phases. A runtime can be fast at one and slow at the other. Always measure both.
- **Why prefix caching is so powerful:** it skips prefill entirely for cached prefixes. RAG workloads where system prompt + retrieved chunks are often repeated see 5–10× latency reductions on cached requests.
- **Why bigger batches help throughput but hurt latency:** decode is memory-bandwidth-bound, so larger batches amortize weight reads across more requests — higher throughput. But larger batches mean each request waits longer for the batch to complete — higher latency.
- **Why FP8 KV cache helps decode specifically:** decode reads the KV cache every step. Cutting KV cache size in half roughly halves the memory traffic for decode, which is exactly where you're bottlenecked. *In other words, decode isn't limited by compute but by how fast data moves, so smaller KV cache directly translates into faster token generation.*
- **Why "100% GPU utilization" can still be slow:** if you're decode-bound, you're memory-bandwidth-pegged, not compute-pegged. The GPU looks busy. The compute units are actually idle most of the time, waiting on memory. This is the gap between `nvidia-smi --query-gpu=utilization.gpu` (the percent of time the GPU was doing something) and actual arithmetic throughput (tokens/sec). *So a "fully utilized" GPU can still deliver low tokens/sec because it's busy waiting on memory, not actually doing useful math.*

Every optimization in the rest of this series is either a prefill optimization, a decode optimization, or a scheduling optimization that trades between them. When you evaluate a knob, ask: *which phase does this affect, and is that the phase I'm bottlenecked on?*

### Setup Is Easy. What You Set Up Is Not.

Installing Ollama is one command. Running a model is one command. Pointing an app at it is four lines of Python. This is not the hard part.

The hard part is that the defaults are optimized for a single developer on a laptop — not for a service. Here's the baseline every deployment tutorial gives you:

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama serve                          # starts the daemon on 127.0.0.1:11434
ollama pull llama3.1:8b               # ~4.7GB Q4_K_M GGUF
```

And here's what you actually get from that:

**Bound to loopback only.** 127.0.0.1:11434 means no external traffic. For a service, you need OLLAMA\_HOST=0.0.0.0:11434 — but that alone doesn't make it public; it just makes the service listen on all network interfaces. If the host is reachable (e.g., a cloud VM or an open port), and you flip that on without a reverse proxy and auth, you've effectively exposed a free LLM endpoint. These endpoints are routinely discovered by automated scans and can be abused for free inference, driving up load and cost or being used for prompt/jailbreak probing. Always put Ollama behind an authenticated reverse proxy.

**Context window of 4096 tokens**, [per the Ollama FAQ](https://docs.ollama.com/faq). Every request that exceeds that gets silently truncated. If the model card advertises 128K context, you do not get 128K context by default — you get 4096 until you explicitly override `num_ctx`, either per-model via a Modelfile or per-request via the API.

**One request at a time per model**, because `OLLAMA_NUM_PARALLEL` defaults to 1. Second request queues. Third request queues. No HTTP 503, no backpressure signal in the logs — just silent latency.

**Model unloads from VRAM five minutes after the last request** (`OLLAMA_KEEP_ALIVE=5m`). The sixth-minute request eats a cold reload that can cost 15–60 seconds depending on model size and whether the file is still in the OS page cache.

**Flash attention off. KV cache in f16.** Both of these are free VRAM wins you have to opt into.

This isn't a criticism of Ollama — it's the right default for the primary use case (one developer, one laptop, interactive chat, swap models throughout the day). But when you're treating it as a serving layer, every single one of these defaults is wrong. Fix them before you put the URL in a deploy config.

The other two runtimes encode different assumptions about their users. vLLM defaults are tuned the opposite way — gpu-memory-utilization=0.9 by default, continuous batching on, OpenAI-compatible API on port 8000 — because it was built for serving from day one. [llama.cpp](https://github.com/ggml-org/llama.cpp) 's server sits in between: explicit about everything, no defaults that hide behavior, but also no opinions about what you should do.

Each runtime's defaults are a statement about who the authors thought would be running them and what those users were trying to accomplish. **If you treat those defaults as neutral, you're inheriting assumptions you didn't choose. In production, those assumptions become your bottlenecks.**

### The KV Cache Is Not an Implementation Detail. It's the Thing You're Buying.

Almost every "why did I OOM?" issue in local LLM serving reduces to the same thing: the engineer understood the model weights' VRAM cost but didn't understand the KV cache. This section fixes that.

**What the KV cache is.** In transformer decoders (which is what every LLM you'll deploy is), every output token is generated by computing attention over all previous tokens. To do that, the model needs each previous token's K (key) and V (value) vectors — the two projections that attention uses to decide "which past tokens matter for the current one?"

Without caching, the model would recompute K and V for every previous token at every step. That's O(n²) work per token for a prompt of length n — catastrophic. With caching, the model computes K and V for each token once when the token first enters the context, stores them, and reuses them for every subsequent step. That turns decode into O(n) per step, which is tractable.

The price: you have to store those K and V vectors somewhere. That somewhere is the KV cache, and it lives in VRAM alongside the model weights.

**The formula.** KV cache size in bytes, for a single request:

```java
KV cache = 2 × context_length × num_layers × num_kv_heads × head_dim × bytes_per_element
```

Walk through each factor:

- **2** — one K vector per token plus one V vector per token.
- **context\_length** — the number of tokens in the request's context (prompt tokens + generated tokens so far).
- **num\_layers** — transformer layers stack, and every layer has its own KV cache. For instance; Llama 3.1 8B has 32 layers; Llama 3.1 70B has 80.
- **num\_kv\_heads** — the number of attention KV heads per layer. In classic [multi-head attention (MHA)](https://medium.com/@mustafa.gencc94/transformers-llms-part-8-sharing-attention-heads-99873706e0fb), this equals the number of query heads. In [Grouped Query Attention (GQA)](https://medium.com/@mustafa.gencc94/transformers-llms-part-8-sharing-attention-heads-99873706e0fb), multiple query heads share one KV head, shrinking the cache. Llama 3.1 8B has 32 query heads but only 8 KV heads — 4× smaller KV cache than MHA. This is a big deal for deployment.
- **head\_dim** — the dimension of each head. Usually 64, 96, or 128.
- **bytes\_per\_element** — how many bytes each K/V element takes. f16 = 2 bytes, q8\_0 = 1 byte, q4\_0 = 0.5 bytes.

**Worked example — Llama 3.1 8B at f16, full 128K context:**

```python
2 × 128,000 × 32 × 8 × 128 × 2 = 16,777,216,000 bytes ≈ 16.8 GB
```

The model weights at f16 are ~16 GB. The KV cache at full context is another 16.8 GB. On a 24GB GPU, setting `num_ctx=128000` means you'll OOM on the first request that actually fills the context. The tutorial didn't warn you because the tutorial was tested with 500-token prompts.

A reference table for Llama 3.1 8B (f16 KV cache, single slot), to give you a mental anchor:

And then remember: each parallel slot needs its own KV cache allocation. With `OLLAMA_NUM_PARALLEL=4` at 32K context, you're spending 16.8 GB on KV cache alone — more than the 8B model weights take at f16. Quantizing the KV cache to q8\_0 halves those numbers; to q4\_0 quarters them.

What happens when you exceed the configured context length depends on the runtime. llama.cpp (and therefore Ollama) defaults to a sliding-window behavior — oldest tokens are dropped silently, newer tokens stay. vLLM defaults to returning HTTP 400 with a `context_length_exceeded` error. Neither behavior is wrong; they're just different. Know which one your runtime does, because the silent truncation case is a nightmare to debug ("why does the model forget the system prompt sometimes?") and the hard-error case can take down your service if you're not handling the response code.

### The Queue That Looks Like An API

This was my single most expensive lesson. The Ollama API looks like any other HTTP service. You send a request,1 you get a response, you call it from N clients in parallel. It behaves like a service. Right up until you measure it.

With `OLLAMA_NUM_PARALLEL=1` (the default), a second concurrent request does not run on a second "core" of the GPU, does not share batching, does not do anything clever. It waits in a FIFO queue until the first request finishes. The waiting is invisible: no HTTP 503, no backpressure signal, nothing obvious in the logs. It just takes longer. If the first request takes 8 seconds and the second starts 100ms in, the second request's latency is 15.9 seconds — your p50 looks fine, your p99 looks catastrophic, and the metric you need (queue depth) isn't exposed anywhere.

Here is what actually happens inside Ollama when you send N concurrent requests with default config:

```
Client 1 ──► [ slot 0: GENERATING ]  ──► response (t=8s)
Client 2 ──► [ queue position 0 ]    ──► waits 7.9s ──► slot 0 ──► response (t=15.9s)
Client 3 ──► [ queue position 1 ]    ──► waits 15.8s ──► slot 0 ──► response (t=23.8s)
```

Raise `OLLAMA_NUM_PARALLEL` to 4, and the picture changes:

```
Client 1 ──► [ slot 0: GENERATING ] ──► response
Client 2 ──► [ slot 1: GENERATING ] ──► response
Client 3 ──► [ slot 2: GENERATING ] ──► response
Client 4 ──► [ slot 3: GENERATING ] ──► response
Client 5 ──► [ queue position 0 ]   ──► waits ──► first free slot
```

Now you have four concurrent slots — but each slot gets its own full KV cache allocation, and the GPU's compute is shared across all active slots. With 4 parallel slots and a 32K context window on an 8B model, you're not paying for one 32K KV cache — you're paying for four. You also aren't getting 4× the throughput, because the GPU's compute is divided among the slots. You're getting maybe 2.5× throughput for 4× the memory cost. The math tightens fast.

**The core rule:** parallelism in Ollama (and in llama.cpp's server) is bought with VRAM, not with compute. Compute is shared. Memory is not.

vLLM solves this fundamentally differently. The Ollama/llama.cpp model is "N independent slots, each with pre-allocated KV cache, sharing compute." vLLM's model is "one scheduler, N active sequences sharing one paged KV cache pool, with new sequences added and completed sequences removed at every decode step." That single architectural difference is where vLLM's 10× throughput-under-load advantage comes from, and it's worth understanding mechanically.

**Continuous batching** (also called iteration-level scheduling) works at the decode-step level. Every decode iteration, vLLM's scheduler does three things:

1. **Evict completed sequences.** If a request finished on the previous step (generated its stop token or hit `max_tokens`), drop it from the batch. Its KV cache blocks become available for new sequences.
2. **Admit new sequences.** If new requests are waiting and there's KV cache headroom, prefill them and add them to the active batch.
3. **Decode one token for every active sequence in the batch.**

Static batching (the llama.cpp/Ollama model with multiple slots, roughly) processes requests in fixed groups: wait for a batch, process it to completion, return results, accept new batch. A short request waits for the longest request in its batch to finish. A burst of easy requests gets blocked behind one hard one. Continuous batching eliminates that wait: as soon as any request in the active batch finishes, a new one slots in at the next decode step.

**PagedAttention** is the memory-side innovation that makes continuous batching practical. Naive KV cache allocation pre-reserves contiguous memory for each sequence based on max context length — so a request that will only generate 100 tokens still holds a 16,000-token reservation. The original vLLM paper measured that [this waste](https://datasciencedojo.com/blog/understanding-paged-attention/?utm_source=chatgpt.com) was 60–80% of KV cache memory. PagedAttention allocates KV cache in fixed-size blocks (like OS memory pages) and indexes them through a lookup table, dropping the waste to under 4%. More effective KV memory → more concurrent sequences → higher throughput, without buying more GPU.

The combined effect: [the vLLM paper](https://arxiv.org/abs/2309.06180) showed up to 24× higher throughput than HuggingFace Transformers and up to 3.5× higher than HuggingFace TGI on the same hardware, for the same model, under realistic serving workloads. That's not incremental — that's architectural.

The tradeoff is engineering complexity. vLLM is primarily designed for GPU-backed serving, typically requiring a compatible CUDA environment and models in HuggingFace format, along with tuning configuration knobs for performance. Ollama hides most of this complexity at the start, but those tradeoffs reappear as soon as you scale beyond a single-user setup.

For small workloads with low concurrency and modest context lengths, increasing `OLLAMA_NUM_PARALLEL` may be sufficient. But as concurrency, context size, or latency requirements grow, you inevitably run into memory and scheduling limits. At that point, you're already paying the complexity cost — and systems like vLLM are designed to handle it more efficiently.

### Model Loading Is Three Phases. Each One Can Fail Differently.

When you run `ollama run llama3.1:8b` for the first time, it feels instant — one command, model appears. What's actually happening underneath is a three-step process, and each step has its own failure mode that looks different in production.

**Phase 1 — Download.** The model file gets pulled from Ollama's registry and saved to disk. About 4.7GB for an 8B model, ~40GB for a 70B. This phase fails loudly and obviously — network drops, disk full, corrupted file. You'll know immediately. Not the interesting failure mode.

**Phase 2 — Loading into RAM.** Rather than reading the entire model file into memory upfront, the runtime uses a technique called memory-mapping (`mmap`) — essentially telling the OS "I'll need this file, keep it close." The OS loads pages of the file into RAM lazily, only when they're actually needed. Think of it like a book you're reading: you don't photocopy the whole thing before you start, you just open to the right page.

This has a nice side effect: if you've loaded the same model recently, the OS probably still has those pages in RAM from before. The second load of the day is dramatically faster than the first because Linux holds onto file pages as long as it can.

The not-so-nice side effect: the OS can also quietly take those pages back if it needs memory for something else. The runtime doesn't get notified. From its perspective, the model is still "loaded." But the next request has to re-read from disk — and you get a sudden, unexplained latency spike with nothing in the logs to explain it. This is behind the classic "worked fine all morning, randomly slow after lunch" phenomenon.

**Phase 3 — Copy to GPU.** Once the model is in RAM, it gets transferred to GPU memory over the PCIe bus. On a modern machine, a 40GB model takes roughly 2–4 seconds just for the transfer itself, plus a bit more for the GPU driver to get everything initialized.

There's also a hidden fourth phase nobody documents: **the GPU needs to warm up.** The first request after a model loads triggers a round of JIT compilation — the GPU driver figures out the optimal way to run the specific operations for this model on this hardware. First-token latency on that initial request can be 2–5× slower than everything after it. Most serious deployments fire a tiny dummy request right after loading just to absorb this cost before real users arrive. Neither Ollama nor most tutorials mention this.

**What this means practically.** Cold start on a 70B model — file not recently used, GPU idle — typically runs 30–60 seconds end to end. If the file's already warm in RAM (you loaded it earlier today), that drops to 5–15 seconds. `OLLAMA_KEEP_ALIVE` is essentially controlling which of those two scenarios your users hit.

The failure mode that trips people up in containers: if you're running Ollama in Docker or Kubernetes with a memory limit set just above the model's file size, the OS will start evicting model pages from RAM under any kind of load. The runtime still reports "model loaded." But p99 latency quietly goes from 3 seconds to 45 seconds, with no errors anywhere. I've debugged this one more than once.

Three things that prevent it:

- Set your container's memory limit to at least **1.5× the model's file size** — the extra headroom covers the GPU driver, the runtime process, and OS overhead.
- **Disable swap** on any node serving LLMs. Swap is designed to handle memory overcommit gracefully; LLMs don't have a graceful swap path. If you're overcommitted, fail fast rather than limping along with 10-second latency spikes.
- **Don't trust "model loaded" log messages.** They reflect what the runtime knows about its own memory, not whether the OS has kept the underlying file pages resident. `nvidia-smi` tells you actual VRAM usage; `cat /proc/<pid>/status` and look at `VmRSS` for actual RAM.

### What's Next

You now have the conceptual model: every request has two phases (prefill compute-bound, decode memory-bound), the API has a hidden queue priced in VRAM, the KV cache is the line item nobody warned you about, and model loading is three phases plus a warmup nobody documented.

That's the foundation. **[Part 2](https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-2-the-operational-playbook-cc903d6a4426?postPublishedType=repub)** picks up from here and covers the operational side:

- Why context length is the most expensive knob you can turn, and the math that tells you exactly how expensive
- Prefix caching — the most underused flag in production LLM serving, often a 5–10× latency win for free
- Keep-alive: the memory contract you didn't know you signed
- The two quantizations (weights vs. KV cache) and how to pick both
- A reference configuration I actually deploy, line by line, with reasons for each setting
- Nine specific mistakes I've made — symptom, detection, fix
- How to load-test in a way that doesn't lie to you
- The vLLM equivalent config and when the complexity is worth it

If you're deploying local LLMs and want the operational playbook, [continue to Part 2.](https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-2-the-operational-playbook-cc903d6a4426?postPublishedType=repub)

### Sources

- [Ollama FAQ](https://github.com/ollama/ollama/blob/main/docs/faq.md) — authoritative source for environment variable defaults (`num_ctx=4096`, `OLLAMA_NUM_PARALLEL=1`, `OLLAMA_KEEP_ALIVE=5m`, `OLLAMA_MAX_LOADED_MODELS=3×GPUs`, `OLLAMA_FLASH_ATTENTION`, `OLLAMA_KV_CACHE_TYPE=f16`)
- [Ollama API reference](https://github.com/ollama/ollama/blob/main/docs/api.md) — per-request timing fields (`prompt_eval_duration`, `eval_duration`, `prompt_eval_count`, `eval_count`)
- [Ollama GitHub repository](https://github.com/ollama/ollama) — source code, issues, envconfig reference for all supported environment variables
- [llama.cpp server README](https://github.com/ggerganov/llama.cpp/blob/master/tools/server/README.md) — flag reference for `--flash-attn`, `--cache-type-k` / `-v` (f16 default; q8\_0, q4\_0, q5\_0, q5\_1, bf16 supported), `--ctx-size` (default 0 = from model)
- [vLLM blog: "Easy, Fast, and Cheap LLM Serving with PagedAttention"](https://blog.vllm.ai/2023/06/20/vllm.html) — KV cache memory waste figures (60–80% waste in existing systems → under 4% with PagedAttention), throughput improvements (up to 24× vs HuggingFace Transformers, up to 3.5× vs HuggingFace TGI)
- [PagedAttention paper (Kwon et al., SOSP 2023)](https://arxiv.org/abs/2309.06180) — original research behind vLLM's memory architecture
- [FlashAttention paper (Dao et al., 2022)](https://arxiv.org/abs/2205.14135) — IO-aware attention; original algorithm
- [Grouped Query Attention paper (Ainslie et al., 2023)](https://arxiv.org/abs/2305.13245) — the GQA mechanism that shrinks KV cache in Llama 3.1 and similar models
- [GGUF format specification](https://github.com/ggerganov/ggml/blob/master/docs/gguf.md) — file format used by Ollama and llama.cpp, including quantization schemes
- *[Ollama vs vLLM: A Comprehensive Guide to Local LLM Serving](https://medium.com/@mustafa.gencc94/ollama-vs-vllm-a-comprehensive-guide-to-local-llm-serving-91705ec50c1d)* — the companion article this series assumes as background

[< Go to the original](https://ai.gopubby.com/i-deployed-local-llms-in-production-for-a-year-part-1-the-mental-model-712a4a3f888f#bypass)