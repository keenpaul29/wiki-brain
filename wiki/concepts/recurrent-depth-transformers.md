---
title: Recurrent-Depth Transformers
type: concept
created: 2026-04-28
tags:
  - concept
  - llm-architecture
---

# Recurrent-Depth Transformers

Recurrent-depth transformers reuse a transformer block across multiple loop iterations. Instead of making every layer unique, the model has a Prelude, a recurrent block, and a Coda. More inference-time loops can provide more effective depth without linearly increasing parameter count.

## Architecture Sketch

- Prelude: initial transformer layers that encode the input.
- Recurrent block: a shared block applied repeatedly to update hidden state.
- Coda: final transformer layers that produce output logits.

The OpenMythos source frames each recurrent loop as a latent reasoning step. This reasoning is internal to the forward pass rather than exposed as generated chain-of-thought text.

## Design Issues

- Stability: hidden states can explode unless recurrent updates are constrained. LayerNorm placement, residual scaling, and gating mechanisms are candidate mitigations.
- Loop differentiation: loop-index embeddings or depth-wise adaptations (e.g., learned per-loop scaling vectors) may let the same weights behave differently at different depths, preventing mode collapse across iterations.
- Overthinking: too many loops can degrade output beyond an optimal depth. Adaptive halting (a learned head that predicts whether to continue or stop per token) is the standard solution.
- Breadth: MoE layers can let the model cover many domains while recurrence supplies depth. The two mechanisms are complementary — MoE handles knowledge coverage, recurrence handles multi-step reasoning.
- Efficiency: variable-depth batching groups inputs by their halting step, avoiding wasted compute on easy inputs while allocating more iterations to hard ones.

## Latent Reasoning vs. Chain-of-Thought

The key architectural distinction from standard transformers is that recurrent-depth loops perform reasoning in the model's hidden state space rather than generating intermediate text tokens. Standard chain-of-thought reasoning produces human-readable intermediate steps (tokens that can be inspected, logged, and verified). Recurrent-depth latent reasoning is internal to the forward pass — there is no token-level trace of the intermediate reasoning.

This has implications for interpretability and debugging:

- **No intermediate token trace**: if the model produces a wrong answer, there is no CoT trace to inspect for the error step. Debugging must rely on activation analysis or probing classifiers on the hidden states after each loop.
- **Compute efficiency**: latent reasoning does not generate visible tokens, so the "thinking" does not consume output token budget or increase the latency of the first visible token. The cost is in FLOPs, not token generation latency.
- **Untruncated reasoning**: because no intermediate tokens are generated, the model's reasoning is not truncated by token limits. The hidden state can iterate as many times as the halting mechanism allows, up to the maximum loop count.

## Production Considerations

If recurrent-depth architectures reach production deployment:

- **Batch shape**: variable loop counts across batch elements require padding or dynamic batching. Padding wastes compute; dynamic batching (grouping by current loop at each step) adds scheduler complexity.
- **Loop profiling**: monitoring should track loop iteration counts at the p50/p95/p99 per request class. An upward drift in average loops may signal that the model needs more reasoning depth (or that input quality is degrading).
- **Hardware utilization**: recurrent loops reduce the effective batch size because each loop iteration processes the same batch through the same weights. Memory-bound operations (attention, FFN) may become compute-bound at high loop counts because the same weights are fetched repeatedly.
- **Fallthrough threshold**: if the halting mechanism is too conservative (always loops close to the maximum), the compute cost multiplies without accuracy gain. The halting head's threshold should be tuned against eval accuracy to find the Pareto frontier.

## Caveat

This page summarizes a speculative reconstruction from [[sources/openmythos|OpenMythos]], not an official model disclosure. The architecture details, stability mechanisms, and production considerations are informed inferences from published research, not confirmed design decisions.

## Links

- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Related: [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]]
- Related: [[concepts/local-llm-serving|Local LLM Serving]]
- Source: [[sources/openmythos|OpenMythos]]

