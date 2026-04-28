---
title: LLM-Maintained Wiki
type: concept
created: 2026-04-28
tags:
  - concept
  - knowledge-management
---

# LLM-Maintained Wiki

An LLM-maintained wiki is a persistent markdown knowledge base compiled from raw sources. It differs from ordinary chat-with-files or RAG because the LLM does not merely retrieve source chunks on demand. It transforms sources into durable pages, links them, updates them, and keeps a chronological record of changes.

## Operating Model

1. Raw sources are stored unchanged.
2. The LLM ingests each source and writes a source summary.
3. The LLM updates concept, entity, comparison, and synthesis pages.
4. The LLM updates [[index]] and appends to [[log]].
5. Good query answers can be filed back as new pages.
6. Periodic linting finds stale claims, contradictions, missing pages, and weak links.

## Why It Matters

The wiki turns reading into a compounding process. The current source set suggests this is especially useful for learning technical material: [[sources/system-design-course|System Design Course]] supplies a curriculum, [[sources/retaining-cs-knowledge|Retaining Computer Science Knowledge]] supplies review mechanics, and this wiki pattern supplies durable organization.

## Relation to Agent Learning

[[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]] apply the same compounding idea to behavior instead of knowledge. Corrections are captured, distilled into rules, and loaded in later sessions. In this wiki, new raw sources are captured, distilled into pages, and loaded as durable context for later questions.

## Source Support

- [[sources/llm-wiki-idea-file|LLM Wiki Idea File]]
- [[sources/karpathy-second-brain-article|Karpathy Second Brain Article]]
- [[sources/self-evolving-hooks|Self-Evolving Hooks]]
