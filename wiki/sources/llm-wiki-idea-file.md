---
title: LLM Wiki Idea File
type: source
source_path: "C:\\Users\\giftlaya\\Downloads\\442a6bf555914893e9891c11519de94f-ac46de1ad27f92b28ac95459c782c07f6b8c964a\\llm-wiki.md"
created: 2026-04-28
tags:
  - source
  - knowledge-management
  - llm-workflow
---

# LLM Wiki Idea File

## Summary

This source defines the core operating model for the wiki itself. Instead of treating raw documents as chunks to retrieve at query time, the LLM incrementally compiles them into a persistent, interlinked markdown wiki. The wiki is a compounding artifact: summaries, contradictions, cross-references, and synthesis pages are maintained over time so future questions start from organized knowledge rather than rediscovering the same fragments.

The architecture has three layers:

- Raw sources: immutable source-of-truth documents.
- Wiki: LLM-written markdown pages with summaries, concept pages, synthesis, index, and log.
- Schema: operating instructions that tell the LLM how to maintain the wiki consistently.

The source proposes three recurring operations: ingest new material, query the wiki for grounded answers, and lint the wiki for contradictions, stale claims, or missing links.

## Key Ideas

- A wiki can sit between raw documents and chat answers as a maintained knowledge layer.
- The LLM owns summarizing, cross-linking, updating, and bookkeeping.
- `index.md` is content-oriented; `log.md` is chronological.
- Good answers to questions should often become new wiki pages.
- Obsidian can act as the viewing and navigation environment while the LLM acts as the maintainer.

## Links

- Supports [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
