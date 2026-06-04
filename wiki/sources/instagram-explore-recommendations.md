---
title: "Scaling Instagram Explore Recommendations"
type: source
created: 2026-06-04
source: https://engineering.fb.com/2023/08/09/ml-applications/scaling-instagram-explore-recommendations-system/
author: "Vladislav Vorotilov; Ilnur Shugaepov"
tags:
  - source
  - recommendations
  - instagram
  - machine-learning
---

# Scaling Instagram Explore Recommendations

## Summary

Meta describes Instagram Explore as a multi-stage recommendation funnel that narrows billions of possible media items into ranked, personalized results using retrieval sources, Two Tower models, cached embeddings, neural rankers, precomputation, and final business/integrity reranking.

## Key Ideas

- Explore uses a funnel: retrieval, first-stage ranking, second-stage ranking, and final reranking.
- Retrieval combines multiple candidate sources, including heuristic, real-time, pre-generated, and ML-based sources with tunable weights.
- Two Tower neural networks are useful because user and item towers can produce cacheable embeddings, allowing efficient approximate nearest-neighbor retrieval.
- User interaction history can seed retrieval by finding items similar to high-quality prior engagements while filtering poor-quality or risky items.
- First-stage ranking distills a heavier second-stage model into a lighter cacheable model that can process more candidates.
- Second-stage ranking uses a heavier multi-task multi-label model that can consume user-item interaction features and combine engagement probabilities with value-model weights.
- Final reranking applies integrity, diversity, and business rules after model scoring.
- Parameter tuning uses online Bayesian optimization or faster offline tuning when offline metrics correlate with online outcomes.

## Links

- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Supports [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Supports [[concepts/reliability-and-operations|Reliability and Operations]]
- Supports [[concepts/system-design|System Design]]
