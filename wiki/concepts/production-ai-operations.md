---
title: Production AI Operations
type: concept
created: 2026-06-14
tags:
  - concept
  - ai
  - production
  - operations
  - reliability
  - system-design
---

# Production AI Operations

Shipping an AI feature is the start of engineering work, not the end. Production failures in AI systems usually come from system design gaps — weak retrieval, slow inference, uncontrolled agents, insecure tool access, runaway cost, and absent evaluation.

## The AI Failure Mode Taxonomy

Production AI failures fall into distinct categories, each with different mitigation strategies:

### Hallucination and Grounding

Hallucination is not a prompt problem — it is a grounding and evidence-gating problem. The model should not be asked to answer from parametric memory alone when external evidence exists.

**Mitigations:**
- Ground every factual claim in a retrieved source. The response should cite the source chunk.
- Use evidence-gating: if no retrieved chunk has relevance above a threshold, respond "I don't know" or ask for clarification.
- Structure retrieval to return passages, not isolated chunks. Paragraph-level context reduces hallucination.
- Evaluate hallucination rate offline with a labeled test set. Track it in production with output-based detectors.

### Retrieval Failures

Retrieval is the most common source of production AI quality degradation:

| Failure Mode | Symptom | Fix |
|-------------|---------|-----|
| Fragmented chunks | Answer misses critical context | Semantic chunking (paragraphs, not fixed sizes) |
| Irrelevant results | RAG returns wrong documents | Hybrid search (keyword + vector) |
| Missing recall | Answer doesn't find the evidence | Reranker on top-N results |
| Stale documents | Answer is outdated | CDC pipelines, document expiry timestamps |
| Latency | Retrieval adds 500ms+ | Cached embeddings, tiered retrieval (fast index first) |

### Inference Latency

Latency in AI systems is architectural, not just model-sized:

| Technique | Latency Reduction | Cost |
|-----------|------------------|------|
| KV cache reuse | 40-60% on follow-up turns | Memory (~1MB per cached turn) |
| Speculative decoding | 1.5-2x throughput | Draft model compute |
| Prefix caching | Skip re-processing shared prompt prefix | Cache storage |
| Continuous batching | 2-4x throughput at same latency | Implementation complexity |
| Quantization (FP16→INT8) | ~2x speed, ~50% memory | Minor quality degradation |

### Cost Management

AI feature cost should be managed as cost per successful outcome, not cost per token:

```
cost_per_outcome = (prompt_tokens + completion_tokens) × token_price
                   ─────────────────────────────────────────────
                   successful_outcomes

Model cascade: try cheap model first, escalate to expensive only when needed
  → Small model (80% of requests) → Medium model (15%) → Large model (5%)
  → 5-10x cost reduction while maintaining quality
```

Additional cost controls:
- Prompt reduction: shorter system prompts reduce per-request cost.
- Cache management: cached responses for identical or near-identical queries.
- Budget-aware rate limits: refuse requests when per-customer budget is exhausted.

### Model Selection by Task

Generic leaderboards are the wrong basis for model selection. Map the work to cognitive demands and select models or agent chains accordingly:

| Cognitive Task | Model Requirement | Risk if Mismatched |
|---------------|-------------------|-------------------|
| Classification | Small model (7B-8B) | Overpaying for capacity |
| Summarization | Medium model (70B) | Factual drift |
| Code generation | Large model (latest) | Subtle logic errors |
| Multi-step reasoning | Chain-of-thought capable | Hallucinated intermediate steps |
| Long-context analysis | Models with proven recall | Missing information in long docs |
| Real-time classification | Distilled/small models only | Latency SLA breach |

## Agent Operations

### Deterministic Orchestration

Agents in production need deterministic guardrails, not just prompts:

```
[User Input] → [Intent Classifier] → [State Machine Router]
                                         ↓
                              [Tool Selection (allowed list)]
                                         ↓
                              [Tool Execution with timeout]
                                         ↓
                              [Output Validation (schema check)]
                                         ↓
                              [Response Generation]
```

- State machine: define allowed states and transitions. Agents should not invent new tools or steps.
- DAG execution: parallelizable agent steps should run concurrently with a timeout per branch.
- Step limits: cap the total number of agent steps (e.g., 10 max). Prevent infinite loops.
- Tool constraints: allowlist tools per agent. Never let the agent call execution or write tools without human review.

### Tool Security

Tools are the most exposed attack surface in agent systems:

- Input validation: sanitize all tool arguments. Prevent injection through tool parameters.
- Output validation: verify tool results before passing to the model. A compromised tool can inject malicious content into the agent's context.
- Trust boundary: mark data sources as trusted (internal APIs) or untrusted (user upload, web content). Do not allow the model to execute actions based on untrusted data.
- Permissions: each tool has a minimum permission set. Read-only tools cannot write. Write tools operate in scoped namespaces.

### Evaluation and Monitoring

AI features need evaluation at two stages:

**Offline (CI/CD):**
- Regression test set: 200-500 curated inputs with expected outputs.
- Automatic metrics: answer exact match, ROUGE-L, factual consistency.
- Behavioral tests: adversarial inputs, edge cases, refusal boundaries.

**Online (production):**
- Output quality monitoring: sample responses for human review.
- Latency tracking: prompt→completion time, retrieval time, reranker time.
- Error rate: explicit errors (timeout, schema validation fail) + implicit errors (user repeats the same question, session abandonment).

### Memory Architecture

Production agents need explicit memory tiers:

| Tier | Persistence | Storage | Access Pattern |
|------|-------------|---------|----------------|
| Session context | Minutes-hours | In-memory token buffer | Full context |
| Working memory | Hours-days | Vector store (top-k) | Semantic retrieval |
| Long-term memory | Days-months | Structured DB or wiki | Periodic summarization |
| Ephemeral state | Single turn | Context window | Current conversation |

## Cost per Successful Outcome

The north star metric for production AI is not latency or tokens — it is cost per successful outcome:

```
improvement = (old_cost_per_outcome - new_cost_per_outcome) / old_cost_per_outcome
```

A 50% reduction in cost per successful outcome justifies significant engineering investment in caching, model cascades, prompt optimization, and retrieval improvements.

## Links

- Parent concept: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Related: [[concepts/reliability-and-operations|Reliability and Operations]]
- Related: [[concepts/local-llm-serving|Local LLM Serving]]
- Related: [[concepts/observability-and-monitoring|Observability and Monitoring]]
- Related: [[concepts/agent-memory-architecture|Agent Memory Architecture]]
- Related: [[concepts/ai-coding-workflow-productivity|AI Coding Workflow and Productivity]]
- Related: [[concepts/multi-agent-orchestration|Multi-Agent Orchestration]]
- Related: [[concepts/vector-semantic-search-architecture|Vector and Semantic Search Architecture]]
- Related: [[concepts/api-protocol-selection|API Protocol Selection]]
- Related: [[concepts/recurrent-depth-transformers|Recurrent-Depth Transformers]]
- Source: [[sources/production-ai-failure-modes|Production AI Failure Modes]]
- Source: [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]]
- Source: [[sources/stop-using-wrong-llm|Stop Using the Wrong LLM]]
- Source: [[sources/local-llm-serving-operational-playbook|Local LLM Serving Operational Playbook]]
