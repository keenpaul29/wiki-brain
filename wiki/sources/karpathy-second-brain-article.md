---
title: Karpathy Second Brain Article
type: source
created: 2026-04-28
tags:
  - source
  - second-brain
  - llm-workflow
---

# Karpathy Second Brain Article

## Summary

This article explains Andrej Karpathy's reported workflow of using an LLM agent to build and maintain a research wiki from raw material. The source contrasts this with RAG: RAG retrieves relevant chunks each time a question is asked, while a maintained wiki compiles knowledge once and updates it incrementally.

The article breaks the workflow into raw sources, schema instructions, and generated wiki pages. It emphasizes that the output is plain markdown rather than a hidden vector database, making the knowledge inspectable in Obsidian or any text editor. It also names three operations: ingest, query, and lint.

## Key Ideas

- The LLM behaves like a research librarian, not just a search engine.
- The value comes from persistent structure: summaries, entity pages, concept pages, comparisons, and synthesis pages.
- Query outputs can be filed back into the wiki so exploration compounds.
- The human still supplies judgment and original synthesis; the LLM removes organizational drudgery.

## Links

- Extends [[sources/llm-wiki-idea-file|LLM Wiki Idea File]]
- Supports [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]]
- Connects to [[concepts/structured-learning-and-retention|Structured Learning and Retention]]

