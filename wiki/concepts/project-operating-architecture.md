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

This project now has four coordinated architecture layers: local GBrain recall, generated wiki maintenance, GBrain application code, and cross-session agent handoff.

## Architecture Layers

- GBrain source layer: the local PGLite brain indexes this checkout as source `brain`, attached by `.gbrain-source`.
- Wiki layer: `raw/` remains immutable input; `wiki/` is generated and maintained output.
- Code layer: sync/import must carry source identity through page, chunk, tag, and version writes.
- Handoff layer: `BRAIN_CONTEXT.md`, `SESSION_HANDOFF.md`, and `GBRAIN_DEV_WORKFLOW.md` preserve operating state across tools.

## Key Decision

Source routing is not just a CLI concern. A source-scoped sync must pass `sourceId` through the import pipeline so full syncs do not write project pages into the legacy `default` source.

## Working Rule

Use `bun run src/cli.ts <command>` from this checkout until `gbrain` is installed globally, and prefer `--source brain` for project sync/search commands.

## Links

- Architecture doc: `docs/architecture/project-operating-architecture.md`
- Related workflow: [[automation|Daily Auto Update Workflow]]
- Related synthesis: [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]]
