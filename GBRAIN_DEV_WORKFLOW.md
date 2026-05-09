---
title: GBrain Development Workflow
type: guide
created: 2026-05-09
updated: 2026-05-09
---

# GBrain Development Workflow

This project is integrated with a local GBrain PGLite database for repo and wiki recall.

## Local Setup

- Brain database: `C:\Users\giftlaya\.gbrain\brain.pglite`
- Project source id: `brain`
- Source dotfile: `.gbrain-source`
- Source path: `C:\Users\giftlaya\Documents\my-codes\brain\brain`

The global `gbrain` command is not currently on PATH. From this source checkout, use:

```powershell
bun run src/cli.ts <command>
```

## Daily Project Sync

Use a text-only sync by default. This keeps the local database current without requiring embedding API keys.

```powershell
bun run src/cli.ts sync --source brain --no-embed --no-pull
```

After embedding credentials are configured, run:

```powershell
bun run src/cli.ts embed --stale
```

## Verify Integration

```powershell
bun run src/cli.ts sources list
bun run src/cli.ts stats
bun run src/cli.ts search "wiki maintenance workflow" --source brain
```

Expected state after the 2026-05-09 integration:

- Source `brain` is federated.
- Source `brain` is attached via `.gbrain-source`.
- 280 markdown pages are imported.
- 2427 chunks are present.
- Embeddings are pending until provider credentials are configured.

## Wiki Workflow Still Applies

GBrain recall augments the existing wiki-maintainer workflow; it does not replace it.

Before wiki maintenance, still run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1
```

Then follow `AGENTS.md` and `wiki/automation.md`.

