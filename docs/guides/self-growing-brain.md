# Self-Growing Brain Guide

This guide turns the self-growing brain architecture into a concrete daily runbook for the local wiki source.

## Why this matters

A self-growing brain is not just a repository of pages. It is a daily cycle:

- new raw and wiki content is ingested,
- the brain syncs and indexes it,
- automation discovers links and themes,
- recall is refreshed so the next query is stronger.

If you skip this cadence, the wiki becomes a static file collection instead of a compounding knowledge system.

## Daily runbook

1. **Ingest new raw source content**
   - Run `powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1`
   - Review `wiki/_state/daily-scan.md`
   - Commit the updated state with `-CommitState` after successful ingest.

2. **Sync the source into the brain**
   - Run `bun run src/cli.ts sync --source brain --no-embed --no-pull`
   - This imports the updated wiki pages into the `brain` source.

3. **Run wiki ingestion**
   - Run `bun run src/cli.ts dream --phase wiki`
   - This scans `raw/`, ingests changed files, updates `wiki/index.md`, and writes `wiki/log.md`.

4. **Run the full maintenance cycle**
   - Run `bun run src/cli.ts dream`
   - Or install a daemon with `bun run src/cli.ts autopilot --install` on a machine that can run daily.

5. **Refresh recall and health**
   - Run `bun run src/cli.ts embed --stale`
   - Run `bun run src/cli.ts doctor`

6. **Fix issues and continue**
   - Run `powershell -ExecutionPolicy Bypass -File scripts/check-wiki-links.ps1`
   - Run `powershell -ExecutionPolicy Bypass -File scripts/lint-wiki.ps1`
   - Address any orphan pages, broken links, or ingest warnings before the next cycle.

## When to use `--dry-run`

Use `gbrain dream --phase wiki --dry-run` to preview what would be ingested from `raw/` without writing changes. Use `gbrain dream --dry-run` before you run a full maintenance cycle if you want a safe check.

## Practical notes

- Always use `--source brain` when syncing this checkout.
- Do not edit `raw/` directly; the workflow is `raw/` → wiki pages → brain source.
- `gbrain autopilot` is the scheduler; `gbrain dream` is the one-shot maintenance run.

## Recommended rhythm

- `daily`: `scripts/update-wiki-state.ps1`, `gbrain dream --phase wiki`, `gbrain dream`
- `weekly`: `gbrain doctor`, `gbrain embed --stale`, wiki link/lint checks

This guide is the operational companion to the self-growing brain architecture. Keep the wiki, sync, and dream cycle connected every day.
