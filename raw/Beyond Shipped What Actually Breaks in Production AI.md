---
title: "Beyond Shipped: What Actually Breaks in Production AI"
source: "https://medium.com/aws-in-plain-english/heres-your-final-publication-ready-medium-article-tightened-more-compelling-and-optimized-for-c97f96d02d9f"
author:
  - "[[mogalapalli srihari]]"
published: 2026-05-02
created: 2026-05-05
description: "More"
tags:
  - "clippings"
---
Shipping an LLM isn’t the finish line.  
It’s where the real engineering begins.

The moment your system hits real users, everything changes:

- Outputs drift
- Costs spike
- Agents behave unpredictably
- Failures become harder to debug

In 2026, model intelligence is table stakes.  
What separates working AI systems from failing ones is **systems engineering**.

Here are the **9 failure modes that show up after you ship — and how experienced teams fix them.**

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*NRGyDUbhzUOnXj0VnE7CgQ.png)

## 1\. Hallucinations → From Naive RAG to Grounded Answers

Hallucinations aren’t a model bug.  
They’re a **system design problem**.

**What breaks**

- Confident but incorrect answers
- Fabricated citations
- Responses with no verifiable evidence

**What works in production**

- Retrieve only **high-confidence, relevant context**
- Enforce **evidence-backed answers** (cite or abstain)
- Add **confidence-aware fallbacks**

For complex domains (policy, compliance, legal), teams are moving toward **graph-based retrieval**, preserving relationships between entities for better multi-hop reasoning.

> ***Shift:*** *Retrieval is no longer context — it’s a* ***reliability gate***

## 2\. Poor Retrieval → From Vector Search to Retrieval Engineering

Most RAG systems don’t fail loudly.  
They fail *silently*.

**What breaks**

- Irrelevant chunks retrieved
- Missing critical context
- Answers that look correct but miss the actual question

**What works in production**

- **Semantic chunking** (not arbitrary splits)
- **Hybrid search** (vector + keyword)
- **Reranking layers**
- Continuous **retrieval evaluation (precision/recall)**

> ***Shift:*** *From “store embeddings” →* ***design retrieval systems***

## 3\. Latency → Inference Engineering Becomes Critical

A 10-second response is acceptable in a demo.  
It’s a failure in production.

**What breaks**

- Slow responses (>5–10s)
- Agents executing steps sequentially
- Tool calls blocking execution

**What works in production**

- **KV cache reuse** to avoid recomputation
- **Speculative decoding**
- **Parallel tool execution**
- Aggressive **response caching**

> ***Shift:*** *Latency is no longer a model problem — it’s an* ***architecture problem***

## 4\. Context Limits → Memory Is a First-Class System

LLMs don’t remember.  
They simulate memory — and that simulation breaks.

**What breaks**

- Truncated responses
- Lost conversation history
- Failures on long inputs

**What works in production**

- **Dynamic summarization of history**
- **Top-k retrieval instead of full context dumps**
- **Chunked reasoning / streaming**
- Explicit **memory layers (short-term + long-term)**

> ***Key insight:*** *More context ≠ better answers.  
> Irrelevant context* degrades *performance.*
> 
> ***Shift:*** *From stuffing prompts →* ***designing memory systems***

## 5\. Agent Loops → Deterministic Control Over Probabilistic Systems

Agents don’t fail like normal software.  
They loop. They stall. They overthink.

**What breaks**

- Infinite loops
- Repeated tool calls
- Reasoning chains with no progress

**What works in production**

- Separate:
- **LLM → decision-making (probabilistic)**
- **System → execution (deterministic)**
- Use **state machines / DAG workflows**
- Enforce **step limits + termination rules**
- Constrain **tool usage per step**
- Log full traces for debugging

> ***Shift:*** *From autonomous agents →* ***controlled orchestration***

## 6\. Tool & API Failures → Reliability Engineering for Agents

Agents are only as reliable as the tools they call.

**What breaks**

- Failed API calls
- Partial workflows
- Silent failures

**What works in production**

- **Retry + fallback strategies**
- **Input/output validation** at tool boundaries
- **Graceful degradation paths**
- Monitor tool latency and error rates

> ***Shift:*** *From LLM-centric design →* ***distributed systems thinking***

## 7\. Security → Prompt Injection Is the New Attack Surface

If your system reads external data, assume it’s adversarial.

**What breaks**

- Malicious instructions hidden in retrieved content
- Data leakage through prompts
- Unsafe tool execution

**What works in production**

- **Input sanitization + prompt guardrails**
- **Least-privilege access for tools**
- Separation of **trusted vs untrusted data flows**
- Emerging patterns like **taint tracking / data lineage**

> ***Shift:*** *From content moderation →* ***information flow control***

## 8\. Cost Explosion → AI Is an Economics Problem

Many AI systems don’t fail technically.  
They fail financially.

**What breaks**

- Excessive token usage
- Repeated identical queries
- Overuse of expensive models

**What works in production**

- **Semantic caching** (reuse by intent, not exact match)
- **Model cascading** (cheap → expensive fallback)
- **Prompt/token optimization**
- Budget-aware **rate limiting**

> ***Key insight:*** *Optimize for* ***cost-per-outcome****, not cost-per-request*

## 9\. Inconsistent Outputs → Taming Non-Determinism

Same input. Different output.

That’s the default behavior — and it breaks user trust fast.

**What breaks**

- Unstable responses
- Hard-to-test systems
- Poor reproducibility

**What works in production**

- **Temperature = 0** for deterministic flows
- **Structured outputs (JSON schemas)**
- **Evaluation pipelines + guardrails**
- Few-shot examples or fine-tuning

> ***Shift:*** *From best-effort generation →* ***controlled outputs***

## Evaluation: The Layer Most Teams Skip

You can’t improve what you don’t measure.

Mature teams implement **two evaluation loops**:

- **Offline (CI/CD):** catch regressions before release
- **Online (Production):** detect drift in real usage

Common tooling:

- **DeepEval** → regression testing
- **RAGAS** → retrieval + answer quality
- **LangSmith / Langfuse** → full pipeline observability

Evaluation is no longer optional.  
It’s your **quality gate**.

## The 2026 Production Checklist

Before calling your **AI “production-ready”**:

- **Reliability:** ≥90% task success on evaluation benchmarks
- **Latency:** P95 within SLA (typically ❤–5 seconds)
- **Cost:** Strong cache utilization or cost controls in place
- **Observability:** Full traceability (prompt → retrieval → tools → output)
- **Security:** Least-privilege access + prompt injection defenses
- **Debuggability:** Ability to replay any failure with full trace

## Final Thought

The teams winning in 2026 aren’t the ones with better prompts.  
They’re the ones with better systems.

Because once your AI is live — you’re no longer building a model.

You’re running a production system.

## ⚡ If you’re building with GenAI

- Treat prompts like code — version, test, optimize
- Design retrieval like search — precision and recall matter
- Control agents like workflows — probabilistic decisions, deterministic execution
- Measure everything — before and after you ship

Because once you ship your AI — **that’s when the real work begins.**

Seen a failure mode I missed? Or a better way to handle any of these? Share it below in the comments.