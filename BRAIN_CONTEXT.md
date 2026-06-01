# BRAIN_CONTEXT

This file is the portable memory layer for cross-session/cross-tool continuity.
Any assistant session (Claude Code, Codex, others) must read this first along with `AGENTS.md`.

## 1) Identity and Working Style

- Preferred name:
  - Operator
- Primary goals (current season):
  - Maintain this repo as a self-growing LLM wiki with local PGLite GBrain recall
  - Keep raw-to-wiki pipeline healthy
  - Fix broken architecture, docs, and cross-references as they are discovered
- Communication preferences:
  - concise/detailed: concise (reply in 1-3 sentences unless asked for detail)
  - tone: direct, matter-of-fact
  - decision style (default if ambiguous): read existing docs first, ask if blocked
- Non-negotiables:
  - Never modify `raw/`
  - Never commit real names/companies/funds into public artifacts
  - Verify changes compile/build before committing

## 2) Operating Instructions (Persistent)

- Repository root:
  - `C:\Users\giftlaya\Documents\my-codes\brain\brain`
- Follow `AGENTS.md` exactly.
- Never modify `raw/`.
- Treat `wiki/` as maintained output.
- Before work, run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1
```

- Read:
  - `wiki/_state/daily-scan.md`
- If new/changed sources exist, execute full workflow in `AGENTS.md`.

## 3) Long-Term Knowledge Index

Use this section for stable personal/professional knowledge that should persist across sessions.

- About me:
  - GBrain fork user maintaining a local wiki with PGLite brain backend
- Domains I care about:
  - Personal knowledge management, agent-assisted workflows, wiki automation
  - Software engineering, system design, AI/LLM patterns
- Ongoing projects:
  - GBrain fork wiki maintenance (active) — keep raw→wiki pipeline running, fix architecture issues
  - Agent skill development — learning how to use agent skills effectively
- Important constraints (time, budget, stack, policy):
  - Windows primary environment (PowerShell 5.1)
  - Bun for TypeScript runtime
  - Local PGLite (no cloud Postgres configured)
  - Embeddings not configured (no API keys set up) — use `--no-embed`

## 4) Decision Log (Durable)

Record decisions that future sessions should treat as default unless explicitly changed.

| Date | Decision | Why | Applies To |
|---|---|---|---|
| YYYY-MM-DD | [fill] | [fill] | [fill] |
| 2026-05-09 | Use local PGLite GBrain source `brain` for this project. | Keeps repo/wiki recall available without requiring external Postgres. | Local development, wiki maintenance, future agent sessions |
| 2026-05-09 | Use `bun run src/cli.ts` for GBrain commands until a global `gbrain` binary is on PATH. | The source repo CLI works locally; global command is not currently installed. | Local command examples and automation |
| 2026-05-14 | Treat source identity as part of the import architecture, not only sync bookkeeping. | Source-scoped full syncs must not leak pages into `default`. | `src/commands/sync.ts`, `src/commands/import.ts`, `src/core/import-file.ts`, engine implementations |
| 2026-05-26 | Use full walk database sync (`sync --full`) to index local uncommitted markdown edits. | Incremental git diff sync skips uncommitted files; `--full` walks the filesystem. | Local command execution, synchronization, wiki update |

## 5) Current Priorities (Update Weekly)

1. Keep the wiki ingestion workflow current.
2. Keep the local GBrain source `brain` synced after meaningful markdown changes.
3. Configure embeddings later if vector search is needed.

## 6) Active Work Context (Update Daily)

- Current objective:
  - Maintain this project as an LLM-maintained wiki with local GBrain recall.
- Current blockers:
  - Embeddings are not generated yet because provider credentials were not configured during integration.
- Next concrete action:
  - Run the wiki daily scan, then run `bun run src/cli.ts sync --source brain --no-embed --no-pull --full` after accepted markdown changes.
- Related files/pages:
  - `AGENTS.md`
  - `SESSION_HANDOFF.md`
  - `GBRAIN_DEV_WORKFLOW.md`
  - `docs/architecture/project-operating-architecture.md`
  - `wiki/concepts/project-operating-architecture.md`
  - `wiki/automation.md`
  - `.gbrain-source`

## 7) Knowledge Canon

When uncertain, assistants should resolve conflicts in this order:

1. `AGENTS.md`
2. `BRAIN_CONTEXT.md`
3. `SESSION_HANDOFF.md`
4. `wiki/_state/daily-scan.md`
5. `GBRAIN_DEV_WORKFLOW.md`
6. Existing `wiki/` pages

## 8) Session Bootstrap Prompt (Use in Any New Claude/Codex Session)

```text
Read these files first and treat them as authoritative memory/instructions for this session:
1) AGENTS.md
2) BRAIN_CONTEXT.md
3) SESSION_HANDOFF.md
4) wiki/_state/daily-scan.md
5) GBRAIN_DEV_WORKFLOW.md

Then continue the daily wiki workflow end-to-end, without modifying raw/.
```

## 9) End-of-Session Update Rule

Before ending a session, update:

- `SESSION_HANDOFF.md` sections for state/work done/open items
- `BRAIN_CONTEXT.md` sections 4, 5, and 6 if new durable decisions or priorities emerged

This keeps memory portable across all future sessions.
