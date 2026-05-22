---
title: Daily Auto Update Workflow
type: guide
created: 2026-04-28
updated: 2026-04-28
tags:
  - automation
  - workflow
---

# Daily Auto Update Workflow

This page defines the automated daily workflow for keeping the wiki current.

## Daily Job

1. Run `powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1`.
2. Read `wiki/_state/daily-scan.md`.
3. If there are new or changed raw files, ingest only those files first.
4. Update or create source pages under `wiki/sources/`.
5. Update existing concept and synthesis pages before creating new pages.
6. Update [[index]] and append a dated entry to [[log]].
7. Run the wiki link check and lint check.
8. After successful ingest, run `powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1 -CommitState`.
9. Sync the project source into local GBrain with `bun run src/cli.ts sync --source brain --no-embed --no-pull`.

## Ingest Rules

- Never edit files in `raw/`.
- Keep source summaries factual and compact.
- Prefer expanding existing pages over creating duplicate concepts.
- Add new concept pages when a repeated or central idea needs its own home.
- Log every ingest, lint pass, or durable query result.
- If no raw files changed, append nothing unless a lint issue was fixed.
- GBrain recall augments the wiki; it does not replace the raw-to-wiki maintenance workflow.

## Link Check

Use this check after edits:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-wiki-links.ps1
```

The script validates Obsidian-style links by relative wiki path or basename and exits non-zero when missing links are found.

## Lint Check

Use this check after edits:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/lint-wiki.ps1
```

The script reports wiki pages with no inbound links (excluding index/log/workflow/state pages) and exits non-zero when orphan pages are found.
