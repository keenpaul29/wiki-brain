# Agents working on GBrain

This is your install + operating protocol. Claude Code reads `./CLAUDE.md` automatically.
Everyone else (Codex, Cursor, OpenClaw, Aider, Continue, or an LLM fetching via URL):
start here.

## Install (5 min)

1. Install gbrain via Bun (the canonical path):
   ```bash
   curl -fsSL https://bun.sh/install | bash
   export PATH="$HOME/.bun/bin:$PATH"
   bun install -g github:garrytan/gbrain
   ```
   If `bun install -g` aborts or `gbrain doctor` reports `schema_version: 0`,
   the CLI prints a recovery hint pointing at [#218](https://github.com/garrytan/gbrain/issues/218).
   Run `gbrain apply-migrations --yes` to recover, or fall back to the
   deterministic install: `git clone https://github.com/garrytan/gbrain.git ~/gbrain && cd ~/gbrain && bun install && bun link`.
2. Init the brain: `gbrain init` (defaults to PGLite, zero-config). For 1000+ files or
   multi-machine sync, init suggests Postgres + pgvector via Supabase.
3. **STOP — ask the user about search mode.** `gbrain init` auto-applied a
   default but printed a 9-cell cost matrix (mode × downstream model)
   preceded by `[AGENT]` markers. You MUST relay the matrix to the operator
   and confirm their choice before continuing. Cost spread between corners
   is 25x — silent acceptance is the wrong default. See
   [`./INSTALL_FOR_AGENTS.md`](./INSTALL_FOR_AGENTS.md) Step 3.5 for the
   exact ask-the-user protocol. Same banner fires on `gbrain post-upgrade`
   for existing users (search modes were added in v0.32.3).
4. Read [`./INSTALL_FOR_AGENTS.md`](./INSTALL_FOR_AGENTS.md) for the full 9-step flow
   (API keys, identity, cron, verification).

## Startup Protocol (Brain-First)

Every session MUST follow this sequence before doing any work:

```powershell
# Step 1 — Read this file (AGENTS.md) for protocol + priority queue
# Step 2 — Read BRAIN_CONTEXT.md for current state and identity
# Step 3 — Query the brain for context relevant to this session
powershell -ExecutionPolicy Bypass -File scripts/wiki-health.ps1
gbrain query "project state recent changes wiki sync status" --top-k 3
# Step 4 — Check for pending raw file changes
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1
Get-Content wiki/_state/daily-scan.md
# Step 5 — Pick highest-priority action from the queue below
# Step 6 — Work. Update SESSION_HANDOFF.md before ending.
```

Key principle: **GBrain is faster than file reads.** Query the brain first,
fall back to static files only when the brain's answer is insufficient.

## Priority Action Queue

Pick the highest unblocked action. Rows are cost-sorted (cheapest first).

| Priority | Action | When | Cost |
|----------|--------|------|------|
| P0 | Process changed raw files → wiki sources | Daily scan shows changes | 2-5 min/file |
| P1 | Deepen thin concept pages (<80 lines) | Health dashboard shows thin | 3-8 min/page |
| P1 | Fix broken wikilinks + orphan pages | Health dashboard shows orphans | 1-3 min/page |
| P2 | Run GBrain sync after wiki changes | After any wiki/ edit | 30s |
| P2 | Re-run dream cycle for freshness | After sync | 10s |
| P3 | Process integrity review queue | When queue > 10 items | 5-10 min |
| P3 | Dig into stale pages (>30d old) | Cyclical maintenance | 3-5 min/page |
| P4 | Upgrade schema pack to gbrain-base-v2 | Manual, needs operator approval | 10 min |
| P4 | Enable extract_atoms in schema pack | After pack upgrade | 5 min |

## Read this order

1. `./AGENTS.md` (this file) — install + operating protocol + priority queue.
2. [`./BRAIN_CONTEXT.md`](./BRAIN_CONTEXT.md) — project memory, current state.
3. [`./SESSION_HANDOFF.md`](./SESSION_HANDOFF.md) — last session's work.
4. [`./CLAUDE.md`](./CLAUDE.md) — architecture reference, key files, trust boundaries,
   test layout.
5. [`./docs/architecture/brains-and-sources.md`](./docs/architecture/brains-and-sources.md)
   — the two-axis mental model (brain = which DB, source = which repo in the DB). Every
   query routes on both axes. Read before writing anything that touches brain ops.
6. [`./skills/conventions/brain-routing.md`](./skills/conventions/brain-routing.md) —
   agent-facing decision table: when to switch brain, when to switch source, how
   cross-brain federation works (latent-space only; the agent decides).
7. [`./skills/RESOLVER.md`](./skills/RESOLVER.md) — skill dispatcher. Read before any task.
8. [`./GBRAIN_DEV_WORKFLOW.md`](./GBRAIN_DEV_WORKFLOW.md) — source-sync commands.
9. [`./docs/architecture/project-operating-architecture.md`](./docs/architecture/project-operating-architecture.md)
   — local operating architecture tying GBrain source routing, wiki maintenance,
   source-scoped sync/import, and agent handoff together.

## Trust boundary (critical)

GBrain distinguishes **trusted local CLI callers** (`OperationContext.remote = false`,
set by `src/cli.ts`) from **untrusted agent-facing callers** (`remote = true`, set by
`src/mcp/server.ts`). Security-sensitive operations like `file_upload` tighten filesystem
confinement when `remote = true` and default to strict behavior when unset. If you are
writing or reviewing an operation, consult `src/core/operations.ts` for the contract.

## Common tasks

- **Configure:** [`docs/ENGINES.md`](./docs/ENGINES.md),
  [`docs/guides/live-sync.md`](./docs/guides/live-sync.md),
  [`docs/mcp/DEPLOY.md`](./docs/mcp/DEPLOY.md).
- **Debug:** [`docs/GBRAIN_VERIFY.md`](./docs/GBRAIN_VERIFY.md),
  [`docs/guides/minions-fix.md`](./docs/guides/minions-fix.md), `gbrain doctor --fix`.
- **Migrate / upgrade:** `gbrain upgrade` (binary self-update + schema migrations + post-upgrade prompts),
  [`docs/UPGRADING_DOWNSTREAM_AGENTS.md`](./docs/UPGRADING_DOWNSTREAM_AGENTS.md),
  [`skills/migrations/`](./skills/migrations/), `gbrain apply-migrations --yes` (manual schema-only).
- **Eval retrieval changes:** capture is off by default. To benchmark a
  retrieval change against real captured queries, set
  `GBRAIN_CONTRIBUTOR_MODE=1`, then `gbrain eval export --since 7d > base.ndjson`
  and `gbrain eval replay --against base.ndjson`. For public benchmark
  coverage (LongMemEval, ground-truth scoring), `gbrain eval longmemeval
  <dataset.jsonl>` (v0.28.8) runs against an isolated in-memory PGLite
  per question — your `~/.gbrain` is never opened. Full guide:
  [`docs/eval-bench.md`](./docs/eval-bench.md).
- **Drive the brain to a target health score (v0.36.4.0):** the one-command
  loop. `gbrain doctor --remediation-plan --json` previews what would be
  fixed; `gbrain doctor --remediate --yes --target-score 90 --max-usd 5`
  walks a dependency-ordered plan (sync before extract, embed after
  consolidate), re-checking score between every step, refusing to spend
  past the cost cap. Empty brains (no entity pages) or unconfigured embedding
  keys hit a `max_reachable_score` ceiling and bail with what's missing.
  Three phase handlers (synthesize / patterns / consolidate) are
  PROTECTED — only trusted local callers can submit them; MCP cannot.
  Reference: [`docs/architecture/topologies.md`](./docs/architecture/topologies.md)
  and the CHANGELOG entry for v0.36.4.0.
- **Track a founder/company over time (v0.35.7):** when an entity has
  typed metric claims in its `## Facts` fence (`metric: mrr`, `value: 50000`,
  `unit: USD`, `period: monthly` columns), run
  `gbrain eval trajectory <entity-slug>` for the chronological history
  with regressions auto-flagged, or `gbrain founder scorecard <entity-slug>`
  for a four-signal JSON rollup (claim_accuracy / consistency /
  growth_trajectory / red_flags). MCP op `find_trajectory` exposes the
  same data — read scope, visibility-filtered for remote callers. **v0.40.2.0:**
  `gbrain think` now uses this substrate automatically on temporal /
  knowledge_update intent (default ON; flip `think.trajectory_enabled=false`
  to opt out). Migration v82 added `facts.event_type` so non-metric event
  rows (`meeting`, `job_change`, `location_change`) ride through the same
  pipeline; pass `kind: 'event'` or `'all'` to `find_trajectory` to query
  them.
- **Everything else:** [`./llms.txt`](./llms.txt) is the full documentation map.
  [`./llms-full.txt`](./llms-full.txt) is the same map with core docs inlined for
  single-fetch ingestion.

## Before shipping

Easiest path: `bun run ci:local` runs the full CI gate inside Docker (gitleaks,
unit tests with `DATABASE_URL` unset, then all 29 E2E files sequentially against a
fresh pgvector container) and tears down. Use `bun run ci:local:diff` for the
diff-aware subset during fast iteration on a focused branch. Requires Docker
(Docker Desktop / OrbStack / Colima) and `gitleaks` (`brew install gitleaks`).

Manual path: `bun test` plus the E2E lifecycle described in `./CLAUDE.md` (spin
up the test Postgres container, run `bun run test:e2e`, tear it down).

Ship via the `/ship` skill, not by hand.

## Privacy

Never commit real names of people, companies, or funds into public artifacts. See the
Privacy rule in `./CLAUDE.md`. GBrain pages reference real contacts; public docs must
use generic placeholders (`alice-example`, `acme-example`, `fund-a`).

## Forks

If you are a fork, regenerate `llms.txt` + `llms-full.txt` with your own URL base before
publishing: `LLMS_REPO_BASE=https://raw.githubusercontent.com/your-org/your-fork/main bun run build:llms`.

# Wiki Maintainer Instructions

This workspace is an LLM-maintained Obsidian-style wiki linked to GBrain.

## Folders

- `raw/`: immutable source documents. Read only.
- `wiki/`: generated and maintained markdown wiki. Edit here.
- `scripts/`: helper scripts for scan/state checks.
- `skills/wiki-maintain/`: full lifecycle wiki maintenance skill.
- `skills/wiki-deepen/`: automated deep-content expansion skill.

## Daily Workflow

Use `skills/wiki-maintain/SKILL.md` for the full orchestrated pipeline.
Or run manually:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1
```

Then read `wiki/_state/daily-scan.md`.

If new or changed raw files exist:

1. Read each new or changed source.
2. Create or update a source summary in `wiki/sources/`.
3. Update related concept and synthesis pages.
4. Add backlinks.
5. Run auto-deepen: invoke `skills/wiki-deepen/SKILL.md` (deepen up to 5 thin concepts per week).
6. Update `wiki/index.md`.
7. Append a dated entry to `wiki/log.md`.
8. Run link check + lint check from `wiki/automation.md`.
9. Commit state with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/update-wiki-state.ps1 -CommitState
```

10. Sync to GBrain:

```powershell
bun run src/cli.ts sync --source brain --no-embed --no-pull
```

11. Or run the full cycle in one command:
    ```powershell
    powershell -ExecutionPolicy Bypass -File scripts/run-daily-cycle.ps1 -AutoDeepen
    ```

Do not modify `raw/`.

---

# gstack — AI Engineering Workflow

This repository also contains gstack — a collection of SKILL.md files that give AI agents
structured roles for software development. Each skill is a specialist: CEO reviewer, eng
manager, designer, QA lead, release engineer, debugger, and more.

## Available skills

Skills live in `.agents/skills/` (or `~/.claude/skills/gstack/` on Claude Code).
Invoke them by name (e.g., `/office-hours`).

### Plan-mode reviews

| Skill | What it does |
|-------|-------------|
| `/office-hours` | Start here. Reframes your product idea before you write code. |
| `/plan-ceo-review` | CEO-level review: find the 10-star product in the request. |
| `/plan-eng-review` | Lock architecture, data flow, edge cases, and tests. |
| `/plan-design-review` | Rate each design dimension 0-10, explain what a 10 looks like. |
| `/plan-devex-review` | DX-mode review: TTHW, magical moments, friction points, persona traces. |
| `/plan-tune` | Self-tune AskUserQuestion sensitivity per question. |
| `/autoplan` | One command runs CEO → design → eng → DX review. |
| `/design-consultation` | Build a complete design system from scratch. |
| `/spec` | Turn vague intent into a precise, executable spec in five phases. Files a GitHub issue, optionally spawns a Claude Code agent in a fresh worktree, and lets `/ship` close the source issue on merge. |

### Implementation + review

| Skill | What it does |
|-------|-------------|
| `/review` | Pre-landing PR review. Finds bugs that pass CI but break in prod. |
| `/codex` | Second opinion via OpenAI Codex. Review, challenge, or consult modes. |
| `/investigate` | Systematic root-cause debugging. No fixes without investigation. |
| `/design-review` | Live-site visual audit + fix loop with atomic commits. |
| `/design-shotgun` | Generate multiple AI design variants, comparison board, iterate. |
| `/design-html` | Generate production-quality Pretext-native HTML/CSS. |
| `/devex-review` | Live developer experience audit (TTHW measured against the real flow). |
| `/qa` | Open a real browser, find bugs, fix them, re-verify. |
| `/qa-only` | Same methodology as /qa but report only — no code changes. |
| `/scrape` | Pull data from a web page. First call prototypes; codified call runs in ~200ms. |
| `/skillify` | Codify the most recent successful `/scrape` flow into a permanent browser-skill. |

### Release + deploy

| Skill | What it does |
|-------|-------------|
| `/ship` | Run tests, review, push, open PR. Workspace-aware version queue. |
| `/land-and-deploy` | Merge the PR, wait for CI and deploy, verify production health. |
| `/canary` | Post-deploy monitoring loop using the browse daemon. |
| `/landing-report` | Read-only dashboard for the workspace-aware ship queue. |
| `/document-release` | Update all docs to match what you just shipped. |
| `/document-generate` | Generate Diataxis docs (tutorial / how-to / reference / explanation) from code. |
| `/setup-deploy` | One-time deploy config detection (Fly.io, Render, Vercel, etc.). |
| `/gstack-upgrade` | Update gstack to the latest version. |

### Operational + memory

| Skill | What it does |
|-------|-------------|
| `/context-save` | Save working context (git state, decisions, remaining work). |
| `/context-restore` | Resume from a saved context, even across Conductor workspaces. |
| `/learn` | Manage what gstack learned across sessions. |
| `/retro` | Weekly retro with per-person breakdowns and shipping streaks. |
| `/health` | Code quality dashboard (type checker, linter, tests, dead code). |
| `/benchmark` | Performance regression detection (page load, Core Web Vitals). |
| `/benchmark-models` | Cross-model benchmark for skills (Claude, GPT, Gemini side-by-side). |
| `/cso` | OWASP Top 10 + STRIDE security audit. |
| `/setup-gbrain` | Set up gbrain for cross-machine session memory sync. |
| `/sync-gbrain` | Keep gbrain current with this repo's code; refresh agent search guidance in CLAUDE.md. |

### Browser + agent integration

| Skill | What it does |
|-------|-------------|
| `/browse` | Headless browser — real Chromium, real clicks, ~100ms/command. |
| `/open-gstack-browser` | Launch the visible GStack Browser with sidebar + stealth. |
| `/setup-browser-cookies` | Import cookies from your real browser for authenticated testing. |
| `/pair-agent` | Pair a remote AI agent (OpenClaw, Codex, etc.) with your browser. |

### iOS QA — drive real iPhones over USB or Tailscale (v1.43.0.0+)

| Skill | What it does |
|-------|-------------|
| `/ios-qa` | Live-device iOS QA via USB CoreDevice tunnel + embedded StateServer. Optionally exposes the device over Tailscale so remote agents can drive it. |
| `/ios-fix` | Autonomous iOS bug fixer with regression snapshot capture. |
| `/ios-design-review` | Designer's-eye QA on a real iPhone — 10-dimension Apple HIG rubric. |
| `/ios-clean` | Convenience: strip DebugBridge + #if DEBUG wiring before a Release build. |
| `/ios-sync` | Regenerate the iOS debug bridge against the latest upstream templates. |

Companion CLIs (run on the Mac that's plugged into the device):

| Command | What it does |
|---------|-------------|
| `gstack-ios-qa-daemon` | Mac-side broker. Loopback by default; `--tailnet` adds a Tailscale-facing listener with capability tiers and audit logging. |
| `gstack-ios-qa-mint` | Owner-grant CLI for the tailnet allowlist (`grant`/`revoke`/`list`). |

End-to-end walkthrough: [docs/howto-ios-testing-with-gstack.md](docs/howto-ios-testing-with-gstack.md).

### Safety + scoping

| Skill | What it does |
|-------|-------------|
| `/careful` | Warn before destructive commands (rm -rf, DROP TABLE, force-push). |
| `/freeze` | Lock edits to one directory. Hard block, not just a warning. |
| `/guard` | Activate both careful + freeze at once. |
| `/unfreeze` | Remove directory edit restrictions. |
| `/make-pdf` | Turn any markdown file into a publication-quality PDF. |
| `/diagram` | English in, diagram out: mermaid source + editable .excalidraw + SVG/PNG, offline. |

## Build commands

```bash
bun install              # install dependencies
bun test                 # run free tests (no API spend)
bun run test:windows     # curated Windows-safe subset (runs on windows-latest)
bun run build            # generate docs + compile binaries
bun run gen:skill-docs   # regenerate SKILL.md files from templates
bun run skill:check      # health dashboard for all skills
```

## Platform support

- **macOS** + **Linux**: full test suite supported.
- **Windows**: curated Windows-safe subset runs on `windows-latest` via the
  `windows-free-tests` CI job. Setup script (`./setup`) requires Git Bash or
  MSYS today; native PowerShell support is a future expansion. The `bin/gstack-paths`
  helper resolves state roots through `CLAUDE_PLUGIN_DATA` / `GSTACK_HOME` so plugin
  installs work on every platform.

## Key conventions

- SKILL.md files are **generated** from `.tmpl` templates. Edit the template, not the output.
- Run `bun run gen:skill-docs --host codex` to regenerate Codex-specific output.
- The browse binary provides headless browser access. Use `$B <command>` in skills.
- Safety skills (careful, freeze, guard) use inline advisory prose — always confirm before destructive operations.
- State paths resolve via `bin/gstack-paths` (sourced via `eval "$(...)"`). Honors `GSTACK_HOME`, `CLAUDE_PLUGIN_DATA`, `CLAUDE_PLANS_DIR`.
- The `claude` CLI binary resolves via `browse/src/claude-bin.ts` (`Bun.which()` + `GSTACK_CLAUDE_BIN` override). Set `GSTACK_CLAUDE_BIN=wsl` plus `GSTACK_CLAUDE_BIN_ARGS='["claude"]'` to run Claude through WSL on Windows.
