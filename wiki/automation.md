---
title: Daily Auto Update Workflow
type: guide
created: 2026-04-28
updated: 2026-06-14
tags:
  - automation
  - workflow
  - auto-deepen
  - skills
---

# Daily Auto Update Workflow

This page defines the automated daily workflow for keeping the wiki current.
Use `skills/wiki-maintain/SKILL.md` to run the full lifecycle, or use the
steps below directly.

## Daily Job

1. Run `powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1`.
2. Read `wiki/_state/daily-scan.md`.
3. If there are new or changed raw files, ingest only those files first.
4. Update or create source pages under `wiki/sources/`.
5. Update existing concept and synthesis pages before creating new pages.
6. **Auto-deepen** (weekly): run `skills/wiki-deepen/SKILL.md` to identify
   thin concept pages (< 100 lines, < 3 sources) and deepen the top 5
   candidates. Log all passes to `wiki/log.md`.
7. Update [[index]] and append a dated entry to [[log]].
8. Run the wiki link check and lint check.
9. After successful ingest, run `powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1 -CommitState`.
10. Sync the project source into local GBrain with `bun run src/cli.ts sync --source brain --no-embed --no-pull`.

## Ingest Rules

- Never edit files in `raw/`.
- Keep source summaries factual and compact.
- Prefer expanding existing pages over creating duplicate concepts.
- Add new concept pages when a repeated or central idea needs its own home.
- Log every ingest, lint pass, or durable query result.
- If no raw files changed, append nothing unless a lint issue was fixed.
- GBrain recall augments the wiki; it does not replace the raw-to-wiki maintenance workflow.

## Auto-Deepening

Run via `skills/wiki-deepen/SKILL.md`. The skill automatically:

1. Scans `wiki/concepts/` for thin pages (< 100 lines or < 3 sources).
2. Queues up to 5 per run, prioritizing orphan pages and pages with the most
   inbound links from other concepts.
3. Creates new concept pages from topics that appear across 3+ sources but
   have no dedicated page.
4. Cross-links related concept pages.
5. Updates synthesis pages when new concepts are added.

For a campaign of 10-20+ passes, use the `wiki-deepen` skill directly.

## Link Check

Use this check after edits:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/check-wiki-links.ps1
```

The script validates Obsidian-style links by relative wiki path or basename
and exits non-zero when missing links are found.

## Lint Check

Use this check after edits:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/lint-wiki.ps1
```

The script reports wiki pages with no inbound links (excluding
index/log/workflow/state pages) and exits non-zero when orphan pages are found.

## Related Skills

- `skills/wiki-maintain/SKILL.md` — full lifecycle orchestration
- `skills/wiki-deepen/SKILL.md` — deep content expansion campaigns
- `skills/concept-synthesis/SKILL.md` — tiered intellectual map synthesis
