---
title: Project Operating Architecture
type: concept
created: 2026-05-14
updated: 2026-05-14
tags:
  - concept
  - architecture
  - gbrain
  - wiki
---

# Project Operating Architecture

This project has four coordinated architecture layers: local GBrain recall, generated wiki maintenance, GBrain application code, and cross-session agent handoff. They form a read-eval-write loop where each layer feeds the next.

## Architecture Layers

### GBrain Source Layer

The local PGLite brain indexes this checkout as source `brain`, attached by `.gbrain-source`. Every page, chunk, tag, and version write carries a source identity. Queries route through the source filter by default — `gbrain query` without `--source` returns project-scoped results, while cross-source federation requires explicit `--source "*"`.

The embedding provider (zeroentropyai:zembed-1, 1280d) generates vector representations for all 6758 chunks. Search mode is `tokenmax`, which balances speed and relevance by applying a token budget to candidate results before semantic reranking.

### Wiki Layer

`raw/` remains immutable input; `wiki/` is generated and maintained output. Raw files arrive through scheduled import (daily scan or RSS pipeline) and are never modified in place. The wiki layer transforms raw content into structured knowledge: source summaries in `wiki/sources/`, concept pages in `wiki/concepts/`, synthesis in `wiki/synthesis/`, and operational state in `wiki/_state/`.

The daily scan (`scripts/update-wiki-state.ps1`) compares SHA-256 hashes of all raw files against a stored manifest. New, changed, and deleted files are reported in `wiki/_state/daily-scan.md`. The agent then processes each change by creating or updating the corresponding wiki source page, adjusting concept and synthesis pages, and rebuilding the index.

### Code Layer

The GBrain CLI (`bun run src/cli.ts` or global `gbrain`) provides sync, dream, extract, embed, and doctor commands. Source identity must be explicit in every write operation. The dream cycle (lint → backlinks → sync → synthesize → extract → embed → purge) is the regular maintenance heartbeat.

### Handoff Layer

`BRAIN_CONTEXT.md`, `SESSION_HANDOFF.md`, `GBRAIN_DEV_WORKFLOW.md`, and `AGENTS.md` preserve operating state across sessions and tools. The handoff layer is the agent's persistent working memory — it records decisions, open items, priority queues, and health state so each session starts with full context instead of rediscovering the project state.

## Cross-Layer Data Flow

```
Raw files (daily scan) → Wiki source pages → Concept/synthesis updates
                                         ↓
                              GBrain sync + dream cycle
                                         ↓
                        Health dashboard + handoff files
                                         ↓
                              Next session startup
```

The health dashboard (`scripts/wiki-health.ps1`) closes the loop: it reports thin concepts, orphan pages, stale content, and the raw→wiki gap, which feeds directly into the priority action queue in `AGENTS.md`.

## Priority Queue Routing

Not all work has equal value. The priority queue (defined in `AGENTS.md` P0-P4) cost-sorts maintenance actions so the agent does the cheapest valuable work first:

- P0 (immediate): process changed raw files (2-5 min)
- P1 (same session): deepen thin concepts, fix orphans (1-8 min per item)
- P2 (same session): sync, dream cycle (30s-10s)
- P3 (periodic): integrity review, stale pages (5-10 min)
- P4 (manual): schema pack upgrades (10 min, operator approval)

This ensures that even if a session is interrupted, the highest-value work was done first.

## Trust Boundary

GBrain distinguishes trusted local CLI callers from untrusted agent-facing callers (MCP). Security-sensitive operations like `file_upload` tighten filesystem confinement for remote callers. The project operating architecture inherits this model: wiki edits from the local agent are trusted; edits from MCP-based remote agents follow stricter path validation and require explicit approval.

## Key Decision

Source routing is not just a CLI concern. A source-scoped sync must pass `sourceId` through the import pipeline so full syncs do not write project pages into the legacy `default` source.

## Working Rule

Prefer `--source brain` for project sync/search commands. Use `gbrain <command>` (global install) for most operations; fall back to `bun run src/cli.ts <command>` when working on CLI code changes.

## Links

- Architecture doc: `docs/architecture/project-operating-architecture.md`
- Related workflow: [[automation|Daily Auto Update Workflow]]
- Related synthesis: [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
