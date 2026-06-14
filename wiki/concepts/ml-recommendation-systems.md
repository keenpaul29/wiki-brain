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

## Snapchat Bento: ML Platform for a Billion Predictions/Second

[[sources/snapchat-billion-predictions|Snapchat Bento ML Platform Architecture]] describes a platform serving over a billion ranking predictions per second with a two-stage pipeline (candidate retrieval + deep ranking). Key architectural choices:

- **CPU/GPU model splitting**: dense neural network layers run on GPUs while memory-heavy embedding lookups execute on CPUs. This prevents GPU memory from being consumed by large embedding tables while keeping computation on the right hardware.
- **Feature co-location**: candidate features are loaded directly into inference engine memory, eliminating high-fanout network retrieval calls during scoring. This is the opposite of a microservices approach — features live with the model, not behind a separate service.
- **Raw bytes optimization**: deferring feature deserialization and sending raw bytes directly to the inference engine reduced data plane costs by 10x. Parsing happens lazily inside the inference engine, not in the data pipeline.
- **Train-serve skew prevention**: features are synchronized between offline analytical storage (Apache Iceberg) and online low-latency key-value stores (Robusta on Spark) with versioned schemas and automated validation.

## Netflix Multimodal Video Search

[[sources/netflix-multimodal-video-search|Netflix Multimodal Video Search Architecture]] extends recsys principles to content understanding and search. Instead of user-item interaction prediction, the system indexes video content itself:

- **Multimodal embedding space**: visual frames (CLIP ViT), audio tracks (CLAP models), and textual metadata are encoded into a shared embedding space. This enables searching video by text description, by visual similarity, or by audio characteristics.
- **Temporal segment hashing**: video is split into time segments with hash-based fingerprints. Billions of frames are indexed in vector databases for real-time retrieval.
- **Fusion layer alignment**: the key engineering challenge is preventing cross-modal mismatch — a text query must align with the correct visual and audio embeddings. The fusion layer learns to weight modalities per query type.
- **Future directions**: conversational query interfaces, adaptive relevance ranking, and personalized search weights based on user profile.

This represents a shift from collaborative filtering (what similar users liked) to content-based retrieval (what the content actually contains).

## LinkedIn Semantic Search: GPU-Accelerated EBR

[[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]] replaces keyword matching with an embedding-based retrieval (EBR) pipeline at millions of QPS:

- **Query understanding module** generates query embeddings for exhaustive GPU vector search using CUDA-enabled GPUs. No ANN approximation — full scan on GPU.
- **Hybrid inference pipeline**: offline Spark/Flyte workflows generate candidate embeddings, nearline Flink systems provide low-latency feature updates, and online GPU servers handle real-time scoring.
- **Cross-Encoder SLM** deployed on SGLang for fine-grained relevance ranking of the top candidates. The SLM scores query-document pairs with higher accuracy than embedding similarity alone.
- **Auction layer** applies budget and pacing strategies on top of relevance scores, balancing engagement metrics with business constraints.
- **Score caching and ranking-depth controllers** manage the cost-latency-quality tradeoff, limiting how many candidates enter the Cross-Encoder stage.

## Common Patterns Across Production RecSys

Comparing Instagram Explore, Snapchat Bento, Netflix multimodal search, and LinkedIn semantic search reveals shared architectural patterns:

| Pattern | Instagram | Snapchat | Netflix | LinkedIn |
|---|---|---|---|---|
| Multi-stage funnel | 4 stages | 2 stages | 3 stages | 3 stages |
| Embedding model | Two Tower | Learned embeddings | CLIP/CLAP multimodal | LLM embeddings |
| ANN / exhaustive | ANN (FAISS) | In-memory | Vector DB | Exhaustive GPU |
| Online training | Hourly fine-tuning | High-freq experiments | Ingestion pipeline | Nearline Flink |
| Hardware split | CPU cache + GPU score | CPU embeddings + GPU NN | GPU encoding + CPU index | GPU search + GPU SLM |
| Feature serving | Precomputed | Co-located in engine | Temporal hashing | Hybrid offline/nearline |

The trend is toward **unified embedding spaces, GPU-accelerated search, hybrid offline/online pipelines, and platform-level separation of training from serving**.

## Challenges

Growing system complexity creates maintainability and feedback-loop challenges. Consolidating retrieval strategies into fewer, more general ML algorithms is an active area of development.

## Links

- Parent concept: [[concepts/system-design|System Design]]
- Related: [[concepts/system-design-case-studies|System Design Case Studies]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Source: [[sources/instagram-explore-recommendations|Scaling Instagram Explore Recommendations]]
- Source: [[sources/snapchat-billion-predictions|Snapchat Bento ML Platform Architecture]]
- Source: [[sources/netflix-multimodal-video-search|Netflix Multimodal Video Search Architecture]]
- Source: [[sources/linkedin-semantic-search-rebuild|Reimagining LinkedIn's Search Tech Stack]]
