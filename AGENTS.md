# Codex Wiki Maintainer Instructions

This workspace is an LLM-maintained Obsidian-style wiki.

## Folders

- `raw/`: immutable source documents. Read only.
- `wiki/`: generated and maintained markdown wiki. Edit here.
- `scripts/`: helper scripts for scan/state checks.

## Daily Workflow

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1
```

Then read `wiki/_state/daily-scan.md`.

If new or changed raw files exist:

1. Read each new or changed source.
2. Create or update a source summary in `wiki/sources/`.
3. Update related concept and synthesis pages.
4. Add backlinks.
5. Update `wiki/index.md`.
6. Append a dated entry to `wiki/log.md`.
7. Run the link check from `wiki/automation.md`.
8. Commit state with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1 -CommitState
```

Do not modify `raw/`.

