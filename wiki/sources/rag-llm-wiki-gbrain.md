---
title: RAG, LLM Wiki, or GBrain
type: source
created: 2026-05-05
source: https://medium.com/ai-advances/rag-llm-wiki-or-gbrain-how-your-agent-remembers-changes-everything-56829e66725c
tags:
  - source
  - agents
  - knowledge-management
  - rag
---

# RAG, LLM Wiki, or GBrain

## Summary

This source compares three agent memory architectures: RAG as a retriever, LLM Wiki as a compiler, and fat skills or GBrain-style systems as operators. The useful decision point is the job: retrieve answers at scale, compile knowledge that compounds, or act autonomously on stored knowledge.

## Key Ideas

- Context windows are not durable memory; they are temporary working space.
- RAG handles large and frequently changing corpora well, but can suffer from fragmented chunks, re-derivation, passivity, and pipeline latency.
- LLM Wiki systems compile sources into persistent, interlinked markdown pages, making synthesis reusable across future queries.
- LLM Wiki systems fit hundreds of sources better than massive enterprise corpora unless paired with retrieval.
- Fat-skill systems put intelligence in workflow documents that declare triggers, tools, mutability, write locations, quality bars, and execution protocol.
- Always-on skills and cron jobs turn memory into autonomous monitoring, enrichment, and reporting.
- Deterministic code should handle reproducible writes, calculations, and API operations while the LLM handles synthesis and pattern recognition.
- Hybrid systems are likely: retrieval for scale, wiki for synthesis, skills for action.

## Links

- Connects to [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] (compile versus retrieve)
- Connects to [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]] (fat skills and autonomous workflows)
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] (choosing memory architecture by task)

