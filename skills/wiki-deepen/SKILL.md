---
name: wiki-deepen
version: 1.0.0
description: |
  Automated deep-content expansion for the wiki. Runs N passes to identify
  coverage gaps, deepen thin concept pages, create new pages from orphan
  sources, and add cross-source synthesis. No more manual "do 50 passes."
triggers:
  - "wiki deepen"
  - "deepen wiki"
  - "deep content"
  - "depth campaign"
  - "wiki coverage"
  - "coverage gap"
  - "deep expansion"
  - "auto deepen"
mutating: true
writes_pages: true
writes_to:
  - wiki/concepts/
  - wiki/synthesis/
  - wiki/index.md
  - wiki/log.md
---

# Wiki Deepen — Automated Deep Content Expansion

## What this solves

Manually instructing "do 50 deep-content passes" wastes context and depends
on the agent knowing what needs deepening. This skill codifies the analysis
and execution so any future session can run a depth campaign on demand.

## Coverage Analysis (Phase 1)

Before deepening, map the current state:

### 1. Thin Concept Detection

Scan `wiki/concepts/` for pages that need deepening:

| Criterion | Threshold | Action |
|-----------|-----------|--------|
| Line count | < 100 lines | Deepen to 150+ lines |
| Source references | < 3 sources | Add cross-references from other sources |
| Source-to-content ratio | > 1 source per 20 lines of content | Already dense enough |
| Last updated | > 60 days ago | Revisit with newer sources |
| Inbound links | 0 (orphan) | Link from related pages |

### 2. Coverage Gap Detection

Identify topics from sources that have no dedicated concept page:

```
For each source in wiki/sources/:
  Check if its "Connects to" / "Supports" links include a concept page
  If no concept page covers the source's topic:
    → Candidate for new concept page
```

Rank candidates by:
- Number of orphan sources on the same topic (clustering)
- Source depth (single-page sources → section in existing concept)
- Cross-source recurrence (topic appears across 3+ sources → new concept)

### 3. Synthesis Gap Detection

Check `wiki/synthesis/` for missing cross-domain synthesis:

- Do new concept pages need to be linked from the synthesis page?
- Are there emerging meta-topics that span concept boundaries?

## Execution (Phase 2)

### Batch Execution

Run passes in batches. Each batch is logged.

```powershell
# Batch size: 5-10 passes per run
# Each pass:
#   1. Identify the target (thin concept, new concept, or synthesis update)
#   2. Read all relevant sources
#   3. Create or update the page
#   4. Run link check
#   5. Log the pass
```

### Pass Types (in order of priority)

1. **Deepen existing concept** (highest priority):
   - Read the concept page + all linked sources
   - Identify missing cross-source insights
   - Add 2-4 new substantive sections
   - Update frontmatter `updated` date
   - Add cross-links to related concepts

2. **Create new concept page**:
   - Read all sources on the topic
   - Create a comprehensive concept page with:
     - Overview and definitions
     - Detailed technical content
     - Cross-source synthesis
     - Links to related concepts
     - Source references

3. **Add cross-source links**:
   - For each concept page, ensure it links to all relevant sources
   - For each source, ensure it links to all relevant concept pages
   - Add cross-links between related concept pages

4. **Update synthesis**:
   - Read the synthesis page
   - Add entries for new concept pages
   - Update the study spine with new building blocks

### Pass Budget

Track progress toward a target:

```
Total passes:     N
Deepen existing:  N (#)
Create new:       N (#)
Cross-linking:    N (#)
Synthesis:        N (#)
Remaining:        N (#)
```

## Logging

After each pass batch, append to `wiki/log.md`:

```markdown
## [DATE] deep content | Auto-deepen batch: X passes

**Pass N — [[concepts/target|Target Page]]**: Summary of what was added
and which sources were cross-referenced.

Link check and lint pass clean.
```

## Anti-Patterns

- ❌ Deepening pages that already have high density (> 1 source per 20 lines).
- ❌ Creating concept pages for topics with only 1 source (add as section instead).
- ❌ Deepening the same page twice in a single campaign.
- ❌ Skipping link/lint checks between batches.
- ❌ Removing existing content to add new content (add, don't replace).

## Related Skills

- `skills/wiki-maintain/SKILL.md` — daily wiki maintenance lifecycle
- `skills/concept-synthesis/SKILL.md` — tiered intellectual map synthesis
- `skills/ingest/SKILL.md` — initial source ingestion

## Contract

This skill guarantees:
- Routing matches the canonical triggers in the frontmatter.
- Coverage analysis is performed before any writes.
- Passes are logged to wiki/log.md.
- Link and lint checks pass after each batch.
- Output written under the directories listed in `writes_to:`.
- Privacy contract preserved.
