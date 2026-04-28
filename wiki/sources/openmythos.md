---
title: OpenMythos
type: source
created: 2026-04-28
tags:
  - source
  - llm-architecture
  - transformers
---

# OpenMythos

## Summary

OpenMythos is an independent, speculative open-source reconstruction of a Claude-like architecture based on recurrent-depth transformers. It proposes a model with a Prelude, a looped Recurrent Block, and a Coda. The recurrent block can run for multiple loop iterations, enabling inference-time depth without adding a separate set of parameters for every layer.

The source connects looped architectures to latent reasoning, depth extrapolation, stability constraints, adaptive computation, mixture-of-experts breadth, and compressed attention mechanisms such as GQA or MLA. It is explicitly not an official Anthropic description; it is a theoretical reconstruction from public research and speculation.

## Key Ideas

- Recurrent-depth transformers reuse a block multiple times to trade compute for reasoning depth.
- Loop iterations are framed as implicit latent reasoning steps rather than visible chain-of-thought tokens.
- Stability depends on preventing hidden-state explosion across recurrent updates.
- MoE can provide breadth while recurrence provides depth.
- Adaptive halting can avoid overthinking and allocate more compute to harder inputs.

## Links

- Supports [[concepts/recurrent-depth-transformers|Recurrent-Depth Transformers]]
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]

