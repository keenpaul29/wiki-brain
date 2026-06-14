# BRAIN_CONTEXT

Portable memory layer for cross-session/tool continuity.
**Brain-first protocol:** read this, then query GBrain, then work.

## 1) Identity and Working Style

- Preferred name: Operator
- Primary goals:
  - Maintain self-growing wiki + GBrain with local PGLite recall
  - Keep raw-to-wiki pipeline healthy
  - Fix broken architecture, docs, cross-references as discovered
- Communication: concise (1-3 sentences unless asked); direct, matter-of-fact
- Non-negotiables:
  - Never modify `raw/`
  - Never commit real names/companies/funds into public artifacts
  - Verify changes before committing

## 2) Operating Instructions (Persistent)

- Repository root: `D:\my prog\wiki-brain`
- Follow `AGENTS.md` exactly.
- Never modify `raw/`. Treat `wiki/` as maintained output.
- **Brain-first:** before any work, query GBrain for relevant context.
- Run health check `powershell -ExecutionPolicy Bypass -File scripts/wiki-health.ps1` before starting a content session.

## 3) Current GBrain State

- Engine: PGLite at `C:\Users\ANIRU\.gbrain\brain.pglite`
- Pages: 902 indexed, 6758 chunks with embeddings
- Embedding model: zeroentropyai:zembed-1 (1280d)
- Source: `brain` (this repo), attached by `.gbrain-source`
- Sync mode: full walk, last sync healthy (910 files, 6 imported, 904 unchanged)
- Search mode: tokenmax
- Health score: brain 45/100 (embed 35/35, links 0/25, timeline 0/15, orphans 0/15, dead-links 10/10)
- Primary gap: no wikilinks → no link graph → no timeline entries

## 4) Brain-First Startup Protocol

Every session must run this sequence:

1. Query GBrain for context: `gbrain query "project state recent changes" --top-k 3`
2. Check `wiki/_state/daily-scan.md` for changed raw files
3. Run `scripts/wiki-health.ps1` to see dashboard
4. Pick highest-priority action from AGENTS.md priority table
5. Work, then update SESSION_HANDOFF.md before ending

## 5) Long-Term Knowledge Index

- About: GBrain wiki maintainer, local PGLite backend
- Domains: PKM, agent-assisted workflows, wiki automation, system design, AI/LLM patterns
- Environment: Windows (PowerShell 5.1), Bun runtime, local PGLite
- `gbrain` CLI is on PATH (global install via `bun install -g`)

## 4) Session Log

### 14 June 2026

- **Orphans eliminated**: 10 to 0 by adding backlinks from `production-ai-operations`, `self-improving-agent-workflows`, `command-line-and-git-productivity`, `system-design`, `microservices-architecture`, `communication-and-architecture-patterns`, `ai-era-software-engineering`, `observability-and-monitoring`, `ci-cd-pipeline-and-deployment`, `ai-coding-workflow-productivity`
- **Thin concepts deepened**: 5 pages past 80 lines (project-operating-architecture 36 to 108, recurrent-depth-transformers 59 to 106, local-first-architecture 66 to 109, system-design-interview-workflow 74 to 113, frontend-build-performance 79 to 115)
- **Integrity check**: 898 pages scanned, 0 auto-repaired, 29 review items (all in gbrain docs, not wiki)
- **Dream cycle**: 9.4s, all phases OK

### Next session priorities

- Investigate gbrain reindex-frontmatter PGLite lock timeout (low pri)
- Consider gbrain-base-v2 pack upgrade (manual, operator approval)
- Process any new raw files from daily scan

## 5) Decision Log

| Date | Decision | Why |
|------|----------|-----|
| 2026-05-09 | Use local PGLite source `brain` | Keeps recall available without external Postgres |
| 2026-05-09 | Prefer `--source brain` on sync/search cmds | Source-scoped ops don't pollute `default` |
| 2026-05-14 | Source identity is import architecture | Full syncs must not leak pages into `default` |
| 2026-05-26 | Use `sync --full` for uncommitted edits | Incremental git diff skips uncommitted files |
| 2026-06-14 | Enabled zeroentropyai:zembed-1 embeddings | Vector search now available |
| 2026-06-14 | Tokenmax search mode | Balanced relevance + speed |

## 7) Current Priorities

1. Monitor daily scan for new/changed raw files
2. Investigate gbrain reindex-frontmatter PGLite lock (low pri)
3. Consider gbrain-base-v2 pack upgrade (manual, operator approval)
4. Keep GBrain synced after wiki changes

## 8) Knowledge Canon (Conflict Resolution)

1. `AGENTS.md`
2. `BRAIN_CONTEXT.md`
3. `SESSION_HANDOFF.md`
4. `wiki/_state/daily-scan.md`
5. `GBRAIN_DEV_WORKFLOW.md`
6. Existing `wiki/` pages
7. GBrain query results

## 9) End-of-Session Rule

Before ending a session:
- Update `SESSION_HANDOFF.md` (state, work done, open items)
- Update sections 4-6 here if new decisions/priorities emerged
