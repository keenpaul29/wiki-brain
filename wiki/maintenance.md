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
4. Choose the output shape that fits the question: answer, page, comparison table, chart, slide outline, or other durable artifact.
5. If the answer is durable, save it as a new synthesis or concept page.
6. Update [[index]] and [[log]] when a new page is filed.

## Lint

Periodically scan for:

- Broken or missing backlinks.
- Important repeated concepts without pages.
- Source summaries that are too thin.
- Contradictions between pages.
- Claims that need fresher sources.
- Orphan pages with no meaningful inbound links.
- Important query answers that should have been filed back into the wiki.
- Source images or attachments that should be downloaded locally for durability.

Run the wiki link check after any ingest or link maintenance:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-wiki-links.ps1
```

Run orphan-page lint after major updates:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/lint-wiki.ps1
```

## Current Bias

Keep pages compact and useful. Expand only when a source adds real detail, a question creates a durable synthesis, or a concept becomes central enough to deserve its own page.
