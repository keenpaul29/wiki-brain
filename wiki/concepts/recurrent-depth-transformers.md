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

- Stability: hidden states can explode unless recurrent updates are constrained.
- Loop differentiation: loop-index embeddings or depth-wise adaptations may let the same weights behave differently at different depths.
- Overthinking: too many loops can degrade output, so adaptive halting is useful.
- Breadth: MoE layers can let the model cover many domains while recurrence supplies depth.
- Efficiency: variable-depth batching can spend more compute on harder inputs.

## Caveat

This page summarizes a speculative reconstruction, not an official model disclosure.

## Source Support

- [[sources/openmythos|OpenMythos]]

