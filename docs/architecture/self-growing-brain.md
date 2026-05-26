# Self-Growing Brain

A self-growing brain is a design pattern where the local wiki, the brain source, and daily automation work together so knowledge is not just stored, but also discovered, enriched, and preserved over time.

This repository already contains the building blocks for a self-growing brain:

- a source-scoped local brain (`brain` source)
- a wiki maintenance layer for `raw/` and `wiki/`
- daily automation guidance in `docs/guides/cron-schedule.md`
- a nightly dream cycle and autopilot runtime in `src/commands/dream.ts` and `src/commands/autopilot.ts`

## What makes a brain "self-growing"

A self-growing brain is more than a searchable index. It has three connected properties:

1. **Continuous intake** from added wiki content and raw source documents.
2. **Automated maintenance** that consolidates new signals into enriched pages, links, and patterns.
3. **Day-by-day compound growth** where each cycle makes the brain fitter than the day before.

In this repository, those properties map to the following architectural layers.

## Layers of the self-growing brain

### 1. Input layer: wiki + raw source material

The local wiki is the first signal source.

- `raw/` holds immutable source documents. Agents should not edit these files.
- `wiki/sources/`, `wiki/concepts/`, and `wiki/synthesis/` hold curated, durable knowledge.
- `wiki/_state/` records scan and ingest status.

The daily auto-update workflow in `wiki/automation.md` is the operational contract for this layer. It defines how new or changed raw files enter the wiki and how the wiki stays coherent.

### 2. Source layer: `brain` source and sync

The brain database is the persistent knowledge store.

- This checkout is attached as the `brain` source.
- Use `--source brain` for sync and search commands.
- `gbrain sync --source brain` is the gateway that imports the wiki into the database.

Source identity is critical. The self-growing brain must keep the wiki's content within the `brain` source, not leak it into a generic default source.

### 3. Automation layer: dream, wiki ingest, autopilot, and health checks

The self-growing brain depends on automation to turn updates into durable knowledge.

- `gbrain autopilot` can run periodic maintenance and keep the brain honest.
- `gbrain dream` is the nightly consolidation loop that detects entity signals, repairs links, fixes citations, and synthesizes patterns.
- `gbrain dream --phase wiki` is the new LLM wiki ingestion phase that scans `raw/`, ingests changed source files, updates `wiki/index.md`, and maintains `wiki/log.md`.
- `gbrain doctor` watches for drift, stale embeddings, broken links, and sync failures.

The recommended discipline is to run a daily dream cycle plus a weekly health check. This is the compound-growth engine.

### 4. Search and recall layer

A growing brain must also be a reliable memory.

- `gbrain embed --stale` refreshes vector search coverage after new content is added.
- `gbrain search`, `gbrain query`, and the agent tool layer read from the brain and avoid unnecessary external lookups.

Because the brain is both a source and a memory, the search layer must stay current with every sync and every automation cycle.

## Day-by-day workflow

A self-growing brain should run a repeatable daily cadence.

1. **Add or edit wiki content** in `raw/` or `wiki/`.
2. **Run the daily wiki ingest workflow** (`scripts/update-wiki-state.ps1`) and commit state.
3. **Sync the project source into the brain** with `bun run src/cli.ts sync --source brain --no-embed --no-pull`.
4. **Ingest new raw sources into the wiki** by running `bun run src/cli.ts dream --phase wiki` or the full cycle. This updates `wiki/sources/`, `wiki/concepts/`, and `wiki/synthesis/` using the same Sonnet-powered pipeline the brain already trusts.
5. **Run the dream/autopilot cycle**:
   - `bun run src/cli.ts dream` or
   - `bun run src/cli.ts autopilot --install` on a machine that can run a daily daemon.
6. **Refresh recall** with `bun run src/cli.ts embed --stale` and check health with `bun run src/cli.ts doctor`.
7. **Review and refine**: fix any warnings from the wiki link/lint checks and continue.

Over time, this cadence creates a feedback loop. New wiki content becomes indexed, then the dream cycle discovers and elevates the most important signals, and the brain becomes a stronger base for new pages and agent actions.

## How new wiki content becomes advanced tasks

The current implementation already wires raw source changes into higher-order maintenance work.

1. `gbrain dream --phase wiki` detects new or changed files in `raw/` and runs a Sonnet-powered wiki ingest pipeline.
2. That pipeline summarizes changed files into `wiki/sources/`, updates related concept pages in `wiki/concepts/`, and revises synthesis pages in `wiki/synthesis/`.
3. It then updates `wiki/index.md`, appends entries to `wiki/log.md`, and stores the latest raw manifest in `wiki/_state/`.
4. A subsequent `gbrain sync --source brain` imports the updated wiki pages into the brain database.
5. `gbrain dream` continues with extract, patterns, and embed phases to materialize links, surface themes, and refresh vector recall.

This is the actual advanced-task loop: raw changes become wiki content, wiki content becomes graph structure, and graph structure becomes better search and agent recall.

## What gets better each day

A self-growing brain makes the following improvements automatically:

- New wiki material becomes searchable and linked.
- Thin or underdeveloped pages are identified and enriched.
- Entity mentions are turned into graph links instead of isolated text.
- Citation hygiene improves as the system audits sources.
- Patterns and themes surface from accumulated notes.
- Stale embeddings are refreshed so recall stays fast and accurate.

This is the difference between a static knowledge repository and a brain that learns from its own outputs.

## Architectural guardrails

To preserve the self-growing brain architecture, keep these rules:

- Do not edit `raw/` files directly.
- Prefer source-scoped commands: `--source brain`.
- Keep `gbrain sync` after any change that should be searchable.
- Use `gbrain dream --dry-run` when testing new automation behavior.
- Honor quiet hours and notification gates when the brain is part of a live agent system.
- Keep `BRAIN_CONTEXT.md`, `SESSION_HANDOFF.md`, and `GBRAIN_DEV_WORKFLOW.md` aligned with how the brain is used by agents.

## Reference docs

- `docs/guides/self-growing-brain.md` — daily operational runbook for the local wiki source
- `docs/guides/cron-schedule.md` — the production schedule for daily and nightly jobs
- `docs/guides/operational-disciplines.md` — the five non-negotiable brain maintenance rules
- `docs/architecture/project-operating-architecture.md` — how this repo stays both an app and a wiki
- `wiki/automation.md` — the daily wiki ingestion workflow

A self-growing brain is an architectural pattern, not a one-off script. The repository is already structured for it; the next step is to keep the wiki, the sync, and the dream cycle connected every day.
