---
title: "Reimagining LinkedIn's Search Tech Stack"
type: source
created: 2026-06-01
tags:
  - source
  - linkedin
  - search
  - semantic-search
  - llm
  - gpu
---

# Reimagining LinkedIn's Search Tech Stack

## Summary

LinkedIn describes the transformation of their search infrastructure from keyword matching to a semantic search stack powered by LLMs. The new architecture serves millions of real-time queries per second using GPU-accelerated embedding-based retrieval and Cross-Encoder Small Language Models (SLMs) for ranking.

The pipeline begins with a query understanding module that creates query embeddings for embedding-based retrieval (EBR) on CUDA-enabled GPUs using exhaustive vector search. A Cross-Encoder SLM deployed on SGLang generates relevance and engagement scores. Optimization techniques include score caching, ranking-depth controllers, and traffic shaping. Features are produced through a hybrid pipeline: offline Spark/Flyte workflows and nearline Flink systems. An auction layer applies budget and pacing strategies.

## Key Ideas

- Semantic search replaces exact keyword matching with natural language understanding.
- Query embeddings enable flexible retrieval beyond vocabulary overlap.
- GPU-accelerated exhaustive vector search at LinkedIn's scale (millions of QPS).
- Hybrid inference pipeline: offline (Spark, Flyte) for large-scale processing, nearline (Flink) for low-latency updates.
- Cross-Encoder SLM for fine-grained relevance scoring.
- Context compression and efficient LLM inference to manage cost and latency.
- Balanced by an auction layer for relevance, engagement, and business metrics.

## Links

- Supports [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Supports [[concepts/system-design|System Design]]
- Supports [[concepts/system-design-case-studies|System Design Case Studies]]
- Supports [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Supports [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- Supports [[concepts/reliability-and-operations|Reliability and Operations]]
- Supports [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
