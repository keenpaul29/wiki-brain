---
title: LLM Wiki Idea File
type: source
source_path: "llm-wiki.md"
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

The source proposes three recurring operations: ingest new material, query the wiki for grounded answers, and lint the wiki for contradictions, stale claims, orphan pages, missing links, and data gaps.

The human role is curation and direction: choose sources, ask good questions, inspect the results, and decide what matters. The LLM role is maintenance: summarize, cross-reference, update pages, note contradictions, and keep the index and log current. Obsidian is framed as the IDE, the LLM as the programmer, and the wiki as the codebase.

The pattern is intentionally broad. It can support personal reflection, research projects, book notes, business/team knowledge, competitive analysis, due diligence, trip planning, course notes, or hobby deep dives. The common denominator is accumulating knowledge over time and wanting organized synthesis instead of scattered chat history.

## Key Ideas

- A wiki can sit between raw documents and chat answers as a maintained knowledge layer.
- The LLM owns summarizing, cross-linking, updating, and bookkeeping.
- `index.md` is content-oriented; `log.md` is chronological.
- Good answers to questions should often become new wiki pages.
- Obsidian can act as the viewing and navigation environment while the LLM acts as the maintainer.
- Query outputs can be markdown pages, comparison tables, slide decks, charts, canvases, or other durable artifacts when the question deserves them.
- Optional tools can improve the workflow as the wiki grows: markdown search, Obsidian Web Clipper, local image downloads, graph view, Marp, Dataview, and git history.
- The schema should evolve with the wiki so repeated preferences become durable maintenance rules.

## Practical Notes

- The index can remain enough at moderate scale, but larger wikis may need dedicated markdown search such as local BM25/vector tooling.
- Images clipped from the web should be downloaded locally when they matter, because remote URLs are brittle and images may need separate LLM inspection.
- Frontmatter makes the wiki more queryable with tools like Dataview.
- The log should use consistent headings so recent activity is easy to parse.

## Links

- Supports [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]]
- Supports [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
