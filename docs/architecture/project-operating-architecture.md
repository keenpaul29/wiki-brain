# Project Operating Architecture

This repository has two jobs that must stay connected:

- It is the GBrain application source tree.
- It is also an LLM-maintained markdown wiki that this local checkout indexes into GBrain.

The architecture below keeps those jobs from blurring into each other.

The goal is to make this repo a self-growing brain: new wiki content should flow into the `brain` source, then daily automation should turn that content into richer pages, better links, and stronger search recall.

## Layers

### 1. Source Database Layer

GBrain stores knowledge in a brain database and scopes repo content by source.

- Local brain database: `C:\Users\giftlaya\.gbrain\brain.pglite`
- Project source id: `brain`
- Project source pin: `.gbrain-source`
- Source path: `C:\Users\giftlaya\Documents\my-codes\brain\brain`

The `brain` source is the project boundary. Project sync, search, and future automation should pass `--source brain` or run inside the attached checkout so writes do not fall back to `default`.

### 2. Wiki Maintenance Layer

The wiki is generated and maintained from immutable raw inputs.

- `raw/`: source documents, read-only for agents.
- `wiki/sources/`: one compact summary per raw document.
- `wiki/concepts/`: cross-source concepts and reusable knowledge.
- `wiki/synthesis/`: higher-level synthesis pages.
- `wiki/_state/`: scan state and raw-file manifest.

The maintenance workflow is still owned by `AGENTS.md` and `wiki/automation.md`: scan raw files, ingest only new or changed sources, update backlinks/index/log, run link/lint checks, then commit state.

### 3. Codebase Architecture Layer

The GBrain app remains contract-first:

- `src/core/operations.ts`: shared CLI/MCP operation contracts.
- `src/core/engine.ts`: engine interface.
- `src/core/pglite-engine.ts` and `src/core/postgres-engine.ts`: engine implementations.
- `src/core/import-file.ts`: import pipeline for markdown, code, and images.
- `src/commands/sync.ts`: git-aware source sync.
- `src/commands/import.ts`: directory import walker.

Source-scoped sync must carry source identity through the full import stack, not just through sync bookkeeping. The expected path is:

```text
sync --source brain
  -> performSync(sourceId)
  -> runImport(sourceId) or importFile(sourceId)
  -> importFromContent/importCodeFile/importImageFile(sourceId)
  -> engine.putPage(page.source_id)
  -> source-scoped tags/chunks/versions
```

This prevents a source-scoped full sync from writing pages into the legacy `default` source.

### 4. Agent Handoff Layer

Future sessions should load the local context before acting:

1. `AGENTS.md`
2. `BRAIN_CONTEXT.md`
3. `SESSION_HANDOFF.md`
4. `GBRAIN_DEV_WORKFLOW.md`
5. `wiki/_state/daily-scan.md`

`SESSION_HANDOFF.md` is the current state. `BRAIN_CONTEXT.md` is durable memory. `GBRAIN_DEV_WORKFLOW.md` is the command reference for local GBrain integration.

## Operating Rules

- Do not edit `raw/`.
- Prefer `bun run src/cli.ts <command>` until a global `gbrain` binary is installed.
- Use source-scoped commands for this checkout: `--source brain`.
- Use `--no-embed` by default until embedding credentials are configured.
- After changing markdown that should be searchable, run a project sync.
- After changing wiki pages, run link/lint checks.

## Verification

Use these checks after architecture-sensitive changes:

```powershell
bun run typecheck
bun test --timeout 180000 test/sync.test.ts
powershell -ExecutionPolicy Bypass -File scripts/check-wiki-links.ps1
powershell -ExecutionPolicy Bypass -File scripts/lint-wiki.ps1
bun run src/cli.ts sources list
bun run src/cli.ts stats
```
