# Brain Wiki

This workspace is an LLM-maintained Obsidian-style wiki. Raw source documents go into `raw/`, and the compiled markdown wiki lives in `wiki/`.

The idea is simple: keep sources untouched, then let Codex summarize, link, and maintain the wiki over time.

## Folders

- `raw/` - Immutable source documents. Add articles, notes, transcripts, or other source material here.
- `wiki/` - Generated and maintained wiki pages. This is the knowledge base you read in Obsidian or any markdown editor.
- `scripts/` - Helper scripts for scanning sources and tracking raw-file state.
- `AGENTS.md` - Instructions for Codex sessions that maintain this wiki.

## Key Wiki Pages

- [wiki/index.md](wiki/index.md) - Main catalog of wiki pages.
- [wiki/log.md](wiki/log.md) - Chronological record of ingests and maintenance.
- [wiki/automation.md](wiki/automation.md) - Daily auto-update workflow.
- [wiki/maintenance.md](wiki/maintenance.md) - Ingest, query, and lint conventions.

## Manual Update Workflow

From the workspace root, run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1
```

Then read the scan report:

```text
wiki/_state/daily-scan.md
```

If the report lists new or changed raw files, ask Codex to ingest them into `wiki/`. After a successful ingest, commit the new raw-source baseline:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1 -CommitState
```

## Daily Automation

The Codex automation `daily-wiki-auto-update` runs every day at 9:00 AM local time.

It scans `raw/`, updates `wiki/` when sources change, runs the wiki link check, and commits the raw manifest only after a successful ingest.

