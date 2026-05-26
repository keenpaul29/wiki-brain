---
title: "Snapchat Bento ML Platform Architecture"
type: source
created: 2026-05-26
source: https://substack.com/home/post/p-197814482
published: 2026-05-19
tags:
  - source
---

# Snapchat Bento ML Platform Architecture

## Summary

Explains Snapchat's Bento machine learning platform, which serves over a billion ranking predictions per second by separating model training from serving, optimizing CPU/GPU splits, and co-locating document features to eliminate network fanout.

## Key Ideas

- Real-time recommendation ranking requires a two-stage pipeline: candidate retrieval (filtering millions of items) and deep ranking (scoring hundreds of candidates).
- Bento's training architecture isolates core framework code, user models, and YAML configuration settings to enable high-frequency experimentation.
- Inference engines split models during export: dense neural networks are run on GPUs, while memory-heavy embedding lookups execute on CPUs.
- Features are synchronized between offline analytical storage (Apache Iceberg) and online low-latency key-value stores (Robusta on Spark) to prevent train-serve skew.
- Co-locating candidate features directly in inference engine memory avoids high-fanout network retrieval calls.
- Deferring feature deserialization and sending raw bytes directly to the inference engine reduced data plane costs by 10x.

## Links

- Connects to [[concepts/system-design-case-studies|System Design Case Studies]]
- Connects to [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- Connects to [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
