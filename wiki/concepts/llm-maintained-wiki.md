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

The human and LLM have separate jobs. The human curates sources, asks questions, checks emphasis, and decides what matters. The LLM handles the maintenance labor: summarizing, filing, cross-linking, revising old pages, and keeping navigation current.

## Why It Matters

The wiki turns reading into a compounding process. The current source set suggests this is especially useful for learning technical material: [[sources/system-design-course|System Design Course]] supplies a curriculum, [[sources/retaining-cs-knowledge|Retaining Computer Science Knowledge]] supplies review mechanics, and this wiki pattern supplies durable organization.

The same pattern can support research, personal journals, book notes, team knowledge, competitive analysis, trip planning, and course notes. The domain changes, but the mechanism stays the same: raw material is compiled into a maintained knowledge layer that future questions can reuse.

## Tooling Surface

At small scale, [[index]] and [[log]] are enough for navigation and memory. As the wiki grows, local markdown search, Obsidian graph view, frontmatter queries, slide generation, charts, and local image handling can become useful extensions. These tools should stay optional; the core artifact is still a git-tracked directory of markdown files.

## Relation to Agent Learning

[[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]] apply the same compounding idea to behavior instead of knowledge. Corrections are captured, distilled into rules, and loaded in later sessions. In this wiki, new raw sources are captured, distilled into pages, and loaded as durable context for later questions.

## Agent-Readable Specs

One practical pattern for LLM work is to put "house rules" and "reference truth" into plain-text files the agent can read every time. This wiki uses that approach for knowledge, and the same approach can be applied to other domains like UI design systems: keep a canonical spec in a file and tell the agent to follow it.

## Shared Language

The agent-skills source adds a related workflow: maintain a shared language document and architecture decision records so agents can use the project's real terms instead of verbose generic explanations. This is the same persistence principle applied to collaboration: store terminology and decisions where future sessions can inherit them.

## Anti-Slop Rule

The wiki should preserve thinking, not just generated text. Source summaries and concept pages should distill the source's concrete claims, tradeoffs, and links to other pages. If a page could have been generated without reading the source, it is too generic to be useful.

## Source Support

- [[sources/llm-wiki-idea-file|LLM Wiki Idea File]]
- [[sources/karpathy-second-brain-article|Karpathy Second Brain Article]]
- [[sources/self-evolving-hooks|Self-Evolving Hooks]]
- [[sources/google-stitch-design-md-claude-code|Google Stitch design.md + Claude Code]]
- [[sources/agent-skills-real-engineers|Agent Skills for Real Engineers]]
- [[sources/stop-feeding-me-ai-slop|Stop Feeding Me AI Slop]]
