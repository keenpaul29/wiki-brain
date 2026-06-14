---
name: wiki-maintain
version: 1.0.0
description: |
  Full wiki maintenance lifecycle: scan raw sources, ingest changes,
  auto-deepen concept coverage gaps, run link/lint checks, sync to GBrain.
  Run daily or on demand. Handles the complete raw→wiki→GBrain pipeline.
triggers:
  - "wiki maintain"
  - "wiki maintenance"
  - "update wiki"
  - "daily wiki"
  - "wiki scan"
  - "wiki sync"
  - "run wiki workflow"
mutating: true
writes_pages: true
writes_to:
  - wiki/sources/
  - wiki/concepts/
  - wiki/synthesis/
  - wiki/index.md
  - wiki/log.md
---

# Wiki Maintain — Full Lifecycle

## What this solves

Every session needs:
1. Scan raw/ for changes.
2. Ingest new/changed sources.
3. Deepen concept pages to maintain coverage.
4. Run link/lint checks.
5. Update index, log, synthesis.
6. Sync to GBrain.

Without automation, these steps are done manually or forgotten. This skill
orchestrates the full pipeline.

## Phases

### Phase 0: Prerequisites

```powershell
# Check that the wiki state script exists
Test-Path scripts/update-wiki-state.ps1
Test-Path scripts/check-wiki-links.ps1
Test-Path scripts/lint-wiki.ps1
```

### Phase 1: Scan for Changes

```powershell
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1
```

Then read `wiki/_state/daily-scan.md` to identify new or changed raw files.
If nothing changed, skip to Phase 5 (maintenance).

### Phase 2: Ingest Changed Sources

For each new or changed raw file:
1. Read the raw file.
2. Create or update the source summary in `wiki/sources/`.
3. Update related concept pages with new cross-references.

### Phase 3: Auto-Deepen Concepts

After ingestion, identify which concept pages need deepening:

1. List all concept pages from `wiki/concepts/`.
2. For each concept, check:
   - Line count (< 100 lines → needs deepening)
   - Cross-source references (< 3 sources → needs more sources)
   - Age (last updated > 30 days ago → revisit)
   - New sources just ingested (if new sources reference the concept → expand it)

**Auto-deepen batch**: deepen up to 5 concepts per run, prioritizing:
- Concepts with the fewest source references first
- Concepts with the most inbound links from other concepts
- Concepts that are parents of other concepts

Each deepening pass:
1. Read all sources the concept links to.
2. Identify cross-source insights not yet captured.
3. Add new sections, deeper technical content, or better examples.
4. Update the concept's frontmatter `updated` date.

### Phase 4: Deep Content Expansion

For periodic deep-content campaigns (triggered by "wiki deepen campaign" or
when coverage analysis reveals gaps):

1. Run `skills/wiki-deepen/SKILL.md` for automated N-pass deepening.
2. Target specific coverage gaps (e.g., "no concept page for X").
3. Batch create new concept pages from orphan source content.

### Phase 5: Link Check and Lint

```powershell
# Check all wiki links resolve
powershell -ExecutionPolicy Bypass -File scripts/check-wiki-links.ps1

# Check for orphan pages
powershell -ExecutionPolicy Bypass -File scripts/lint-wiki.ps1
```

Fix any broken links or orphan pages before proceeding.

### Phase 6: Update Index and Log

1. Update `wiki/index.md` with any new concept pages.
2. Append a dated entry to `wiki/log.md` summarizing what was done.
3. Update `wiki/synthesis/` pages if the new content warrants it.

### Phase 7: Commit State

```powershell
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1 -CommitState
```

### Phase 8: Sync to GBrain

After all wiki changes are committed, sync the brain source:

```powershell
# Source-scoped sync (carries source identity through the import stack)
bun run src/cli.ts sync --source brain --no-embed --no-pull
```

This makes the new wiki content searchable in GBrain.

## Cadence

| Cadence | Actions | Duration |
|---------|---------|----------|
| Daily | Phase 1-2, 5-8 | 5-10 min |
| Weekly | Phase 3 (auto-deepen) | 15-30 min |
| Monthly | Phase 4 (deep campaign, 10-20 passes) | 30-60 min |
| On demand | Full pipeline | Varies |

## Quality Gates

- All wiki links resolve (no broken `[[...]]` references).
- No orphan concept pages (every page has ≥1 inbound link from another page).
- Concept pages reference ≥2 sources (preferably 3+).
- Source summaries are < 50 lines (compact, factual).
- Index and log are up to date.
- `raw/` is never modified.
- GBrain sync completes without errors.

## Anti-Patterns

- ❌ Editing `raw/` — these are immutable source documents.
- ❌ Skipping link check — broken links compound across sessions.
- ❌ Skipping GBrain sync — wiki content is invisible to GBrain queries.
- ❌ Deepening every concept every run — prioritize by gap size.
- ❌ Creating duplicate concept pages — always check existing pages first.
- ❌ Removing old source cross-links — sources are evidence, not decoration.

## Related Skills

- `skills/wiki-deepen/SKILL.md` — deep content expansion campaigns
- `skills/concept-synthesis/SKILL.md` — intellectual map synthesis
- `skills/maintain/SKILL.md` — brain health checks
- `skills/ingest/SKILL.md` — generic content ingestion
- `skills/eiirp/SKILL.md` — filing and organization

## Contract

This skill guarantees:
- Routing matches the canonical triggers in the frontmatter.
- Wiki pages are consistent (no broken links, no orphans).
- Raw files are never modified.
- GBrain sync is source-scoped to the `brain` source.
- Output written under the directories listed in `writes_to:`.
- Privacy contract preserved.

## Output Format

The skill's output is the wiki itself — updated source summaries, concept pages,
index, log, and synthesis pages. Each phase reports its results inline.
