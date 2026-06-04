---
title: ML Recommendation Systems at Scale
type: concept
created: 2026-06-04
tags:
  - concept
  - machine-learning
  - recommendations
  - system-design
---

# ML Recommendation Systems at Scale

Large-scale recommendation systems (like Instagram Explore) use a multi-stage funnel to narrow billions of possible items into a personalized shortlist. Each stage trades cost for precision: lighter models process more candidates, heavier models score the best few hundred.

## Multi-Stage Funnel

1. **Retrieval**: selects thousands of candidate items from a pool of billions. Multiple retrieval sources (heuristic, real-time, pre-generated, ML-based) feed the funnel with tunable weights.
2. **First-Stage Ranking**: a lightweight model scores candidates and narrows to hundreds. Often uses the same architecture as retrieval (Two Tower NN) for cacheability, but trained to distill the second-stage model's output.
3. **Second-Stage Ranking**: a heavier multi-task multi-label (MTML) model predicts engagement probabilities (click, like, share, see-less) for each candidate. Combines them via a value model: `Expected Value = W_click * P(click) + W_like * P(like) - W_seeless * P(seeless)`.
4. **Final Reranking**: applies integrity filtering, diversity rules, and business constraints after model scoring.

## Key Techniques

### Two Tower Neural Networks

Two Tower NNs consist of separate neural networks for users and items. Each tower produces an embedding. After training, user embeddings sit close to embeddings of relevant items for that user.

Advantage: towers produce cacheable embeddings. Item embeddings can be precomputed offline and stored in an approximate nearest neighbor (ANN) service like FAISS. User embeddings can be regenerated on the fly with fresh features. This makes inference extremely efficient — no need to score every item at query time.

Limitation: Two Tower models cannot consume user-item interaction features (like "did the user click this post before") because cross features would break the independent embedding model.

### Distillation

The first-stage ranker is trained to predict which items the second-stage ranker would rank in top K. This knowledge distillation lets a lightweight model approximate a heavier model's behavior.

### Caching and Precomputation

Precomputation during off-peak hours reduces peak-load compute. Cached embeddings serve retrieval and first-stage ranking instantly. Precomputed recommendations for some user segments further reduce online inference load.

### Online Training

Neural networks are retrained (fine-tuned) every hour as new interaction data arrives. This lets the system adapt to rapidly changing user behavior and content trends without full retraining.

## Parameter Tuning

Hundreds of tunable parameters control retrieval weights, ranking thresholds, and value model coefficients.

- **Bayesian optimization online**: requires only parameter ranges and a goal metric; converges slowly (weeks) but handles live interactions.
- **Offline tuning**: uses historical data to learn functions mapping offline metric changes to online outcomes; faster (hours) but requires strong offline/online correlation.

## Challenges

Growing system complexity creates maintainability and feedback-loop challenges. Consolidating retrieval strategies into fewer, more general ML algorithms is an active area of development.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/system-design-case-studies|System Design Case Studies]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Source: [[sources/instagram-explore-recommendations|Scaling Instagram Explore Recommendations]]
