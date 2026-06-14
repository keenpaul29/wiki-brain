---
title: Vector and Semantic Search Architecture
type: concept
created: 2026-06-14
tags:
  - concept
  - search
  - vector-search
  - semantic-search
  - embeddings
  - system-design
---

# Vector and Semantic Search Architecture

Semantic search replaces exact keyword matching with meaning-based retrieval using vector embeddings. Instead of matching terms, it matches concepts. This shift requires fundamentally different infrastructure: embedding models, vector indexes, GPU acceleration, and hybrid retrieval pipelines.

## The Search Spectrum

```
Keyword Search (TF-IDF, BM25)
    → Exact term matching
    → No understanding of synonyms, context, or meaning
    → Fast, cheap, easy to debug

Hybrid Search (keyword + vector)
    → Both exact and semantic matching
    → Rerank or fuse results from both
    → Best overall quality for heterogeneous queries

Semantic Search (embedding-based)
    → Meaning-based retrieval
    → Requires embedding models and vector indexes
    → Expensive, harder to debug, but captures intent
```

## Embedding Pipeline

### Embedding Generation

Documents and queries are encoded into fixed-dimensional vectors using embedding models:

```
Document: "How to deploy PostgreSQL on Kubernetes"
    → Model: text-embedding-3-small
    → Vector: [0.023, -0.145, 0.678, ..., -0.089]  (1536 dimensions)

Query: "Postgres K8s deployment guide"
    → Model: text-embedding-3-small
    → Vector: [0.031, -0.152, 0.691, ..., -0.077]
```

### Embedding Model Selection

| Model | Dimensions | Quality | Cost | Use Case |
|-------|-----------|---------|------|----------|
| text-embedding-3-small | 1536 | Good | Low | General purpose |
| text-embedding-3-large | 3072 | Better | Medium | High-precision retrieval |
| BGE-base-en-v1.5 | 768 | Good | Low | Self-hosted |
| E5-mistral-7b-instruct | 4096 | Best | High | Domain-specific |
| Multimodal (CLIP) | 512 | N/A (cross-modal) | High | Image/video search |

## Vector Search Indexes

### Exact vs Approximate

| Approach | Recall | Query Speed | Build Time | Memory |
|----------|--------|-------------|------------|--------|
| Exhaustive (brute force) | 100% | Slow | None | Full vectors |
| IVF (inverted file index) | 95-99% | Fast | Medium | Medium |
| HNSW (hierarchical navigable small world) | 95-99% | Very fast | Slow | High |
| DiskANN (SSD-based) | 90-95% | Fast (disk) | Slow | Low (compressed) |

**HNSW** is the most popular choice for high-throughput semantic search: it provides excellent recall (97%+) with millisecond query times at the cost of more memory and slower index building.

### Index Parameters

- `M`: number of connections per node (higher = better recall, more memory). Default 16.
- `ef_construction`: search breadth during index building (higher = better recall, slower build). Default 200.
- `ef_search`: search breadth during query (higher = better recall, slower query). Default 50.

## Multimodal Search

Multimodal models (CLIP, CLAP) encode different modalities into a shared embedding space:

```
Text: "sunset over a beach"
    → CLIP text encoder → [0.12, 0.45, ..., -0.23]

Image: [pixel data]
    → CLIP vision encoder → [0.15, 0.42, ..., -0.20]

Audio: [waveform data]
    → CLAP audio encoder → [0.10, 0.48, ..., -0.19]
```

### Netflix Multimodal Video Search

Netflix indexes raw video footage using:
- CLIP ViT for visual frames.
- CLAP for audio tracks.
- Text encoders for metadata.
- Temporal segment hashing + vector DB for billions of frames.

### Cross-Modal Challenges

- Fusion layer must align diverse models to prevent cross-modal mismatch.
- Search skew: different modalities may return different quality results for the same query.
- Scale: encoding a video frame every N seconds produces billions of vectors.

## Hybrid Retrieval

The best production systems combine keyword and semantic retrieval:

```
Query: "Postgres K8s deployment guide 2025"
    →
    [BM25 search]     → top 100 documents
    [Vector search]   → top 100 documents
        ↓
    [Reciprocal Rank Fusion (RRF)]
        ↓
    [Reranker (Cross-Encoder)]
        ↓
    Top 10 final results
```

### Reciprocal Rank Fusion

Fuse results from multiple sources by their rank position:

```
score = Σ(1 / (60 + rank_source))

BM25:   doc A (rank 1), doc B (rank 2), doc C (rank 3)
Vector: doc B (rank 1), doc A (rank 3), doc D (rank 4)

doc B: 1/61 + 1/61 = 0.0328
doc A: 1/61 + 1/63 = 0.0323
doc D: 0 + 1/64 = 0.0156
```

RRF is simple, effective, and requires no training.

## Production Architecture

### LinkedIn-Scale Semantic Search

LinkedIn's search rebuild at millions QPS:

```
[Query] → [Query Understanding (LLM)]
    → [Query Embedding]
    → [GPU-Accelerated Exhaustive Vector Search]
        ↓
    [Cross-Encoder SLM (SGLang)] → Relevance score
        ↓
    [Auction Layer] → Budget + pacing
        ↓
    [Results]
```

Hybrid pipeline: offline Spark/Flyte for large-scale processing, nearline Flink for low-latency feature updates.

## Links

- Parent concept: [[concepts/ml-recommendation-systems|ML Recommendation Systems at Scale]]
- Related: [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Related: [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Related: [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Source: [[sources/linkedin-semantic-search-rebuild|LinkedIn Semantic Search Rebuild]]
- Source: [[sources/netflix-multimodal-video-search|Netflix Multimodal Video Search]]
- Source: [[sources/instagram-explore-recommendations|Instagram Explore Recommendations]]
