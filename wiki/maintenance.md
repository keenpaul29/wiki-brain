---
title: Maintenance
type: guide
created: 2026-04-28
updated: 2026-04-28
tags:
  - maintenance
  - workflow
---

# Maintenance

This is the everyday operating routine for the wiki.

## Ingest

When new files appear in `raw/`:

1. Read the new source without modifying it.
2. Create or update a source summary under `wiki/sources/`.
3. Extract durable concepts, entities, frameworks, claims, and open questions.
4. Update existing concept pages before creating new ones.
5. Add backlinks between related pages.
6. Update [[index]].
7. Append an entry to [[log]] using `## [YYYY-MM-DD] ingest | Source title`.

## Query

When answering questions:

1. Read [[index]] first.
2. Open the relevant concept, source, and synthesis pages.
3. Answer from wiki context and cite the relevant pages.
4. If the answer is durable, save it as a new synthesis or concept page.
5. Update [[index]] and [[log]] when a new page is filed.

## Lint

Periodically scan for:

- Broken or missing backlinks.
- Important repeated concepts without pages.
- Source summaries that are too thin.
- Contradictions between pages.
- Claims that need fresher sources.
- Orphan pages with no meaningful inbound links.

## Current Bias

Keep pages compact and useful. Expand only when a source adds real detail, a question creates a durable synthesis, or a concept becomes central enough to deserve its own page.

