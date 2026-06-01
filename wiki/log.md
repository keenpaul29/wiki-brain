---
title: Wiki Log
type: log
created: 2026-04-28
updated: 2026-04-28
---

# Wiki Log

## [2026-06-01] ingest | Agents, transport, data projections, and fork migration

Processed new/changed raw sources:

- `raw/Escaping the Fork How Meta Modernized WebRTC Across 50+ Use Cases.md`
- `raw/How I Scrubbed 100% of the AI Slop From My Game & Cut Code by 45%.md`
- `raw/Learn System Design With Me . Day 7 Chain of Responsibility & State Patterns .  by The Latency Gambler.md` (changed)
- `raw/Learn System Design With Me . Day 8 Load Balancing & Circuit Breaker….md`
- `raw/Learn System Design With Me . Day 9 Database Patterns & Repository P….md`
- `raw/The last year of localhost.md`
- `raw/The Packet Drop That Froze Three Requests at Once.md`
- `raw/The Read That Was Killing the Write.md`
- `raw/Your Database Has Been Writing an Event Log the Whole Time.md`

Added source summaries for Meta's WebRTC dual-stack fork migration, AI slop cleanup in a Godot game, cloud development environments for background agents, QUIC/HTTP3 head-of-line blocking, CQRS read/write separation, and CDC over database transaction logs. Preserved the existing Day 7-9 Latency Gambler summaries and linked the newly scanned Day 8-9 raw sources.

Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/infrastructure-primitives|Infrastructure Primitives]], [[concepts/reliability-and-operations|Reliability and Operations]], [[concepts/data-storage-and-consistency|Data Storage and Consistency]], [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]], [[concepts/software-design-patterns|Software Design Patterns]], [[concepts/system-design|System Design]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-25] ingest | AI learning posture refresh

Processed changed raw source:

- `raw/Don't Outsource the Learning.md`

Refreshed [[sources/dont-outsource-learning|Don't Outsource the Learning]] with stronger study-backed evidence, the order-of-operations risk from early LLM problem framing, and the point that learning-oriented AI modes are useful for experienced engineers entering unfamiliar domains. Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/structured-learning-and-retention|Structured Learning and Retention]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-19] decision | Shared engineering language page

Decision: yes, the wiki should maintain a shared engineering language page, similar to a lightweight `CONTEXT.md`, for recurring project terms and durable engineering decisions.

Added [[concepts/shared-engineering-language|Shared Engineering Language]] with initial definitions for raw sources, wiki pages, source summaries, concept pages, synthesis pages, project operating architecture, brain/source routing, ship-and-learn, and context-first workflow. Updated [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] and [[index]].

## [2026-05-19] ingest | AI coding learning ownership

Processed new raw source:

- `raw/Don't Outsource the Learning.md`

Added [[sources/dont-outsource-learning|Don't Outsource the Learning]] for Addy Osmani's warning that AI coding workflows can trade present-day speed for future engineering capability when engineers skip hypothesis formation, explanation, review, and reconstruction. Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/structured-learning-and-retention|Structured Learning and Retention]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-04-28] ingest | Initial raw source compilation

Processed the initial source set:

- `llm-wiki.md`
- `AI Replaced 80% of Coding - Master These 7 Skills Instead. by Prakash Sharma.md`
- `Andrej Karpathy Stopped Using AI to Write Code. He's Using It to Build a Second Brain Instead by Nikhil in Neural Notions.md`
- `How to Learn from Course Content Without Paying for It.md`
- `Learn how to design systems at scale and prepare for system design interviews.md`
- `OpenMythos - a theoretical reconstruction of the Claude Mythos architecture, built from first principles using the available research literature.md`
- `Retaining Computer Science Knowledge.md`

Created initial index, source summaries, concept pages, and synthesis page. Main cross-source theme: use AI to reduce mechanical work, but preserve human judgment through structured learning, system design practice, source-grounded knowledge compilation, and accountability.

## [2026-04-28] ingest | Expanded system design course map

Expanded the broad [[sources/system-design-course|System Design Course]] into six reference pages:

- [[concepts/system-design-interview-workflow|System Design Interview Workflow]]
- [[concepts/infrastructure-primitives|Infrastructure Primitives]]
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]]
- [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
- [[concepts/reliability-and-operations|Reliability and Operations]]
- [[concepts/system-design-case-studies|System Design Case Studies]]

Updated [[index]], [[concepts/system-design|System Design]], and [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] to make these pages navigable.

## [2026-04-28] ingest | Self-Evolving Hooks and daily automation workflow

Added workflow support for daily updates:

- Created `scripts/update-wiki-state.ps1` to scan `raw/`, compare source hashes, and write `wiki/_state/daily-scan.md`.
- Created [[automation]] to document the automated daily scan, ingest, link-check, and state-commit routine.
- Created `AGENTS.md` so future Codex sessions know the wiki-maintenance workflow.

Ingested `raw/Self-Evolving Hooks.md` as [[sources/self-evolving-hooks|Self-Evolving Hooks]] and added [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]. Updated [[index]], [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]], and [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]].

## [2026-04-28] ingest | Design specs for agents + Rufus engineering notes

Processed new/changed raw sources:

- `raw/How to Use Google Stitch's Design.md File with Claude Code for Consistent UI.md`
- `raw/The technology behind Amazon’s GenAI-powered shopping assistant, Rufus.md`
- `raw/Self-Evolving Hooks.md` (updated)

Added new source summaries: [[sources/google-stitch-design-md-claude-code|Google Stitch design.md + Claude Code]] and [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]]. Updated [[sources/self-evolving-hooks|Self-Evolving Hooks]] to better reflect the hook roles.

Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] and [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] with the "persistent context file" pattern, and expanded [[concepts/infrastructure-primitives|Infrastructure Primitives]] with inference-at-scale notes from Rufus. Updated [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] and [[index]] accordingly.

## [2026-04-28] ingest | Rufus production assistant case study

Processed changed source:

- `raw/The technology behind Amazon's GenAI-powered shopping assistant, Rufus.md`

Refined [[sources/amazon-rufus-technology|Technology Behind Amazon Rufus]] with source metadata and additional details on public-web data, Stores APIs, response hydration, and upstream data pipelines. Expanded [[concepts/system-design-case-studies|System Design Case Studies]] with a GenAI shopping-assistant case study covering domain model adaptation, RAG, feedback loops, accelerator-backed inference, continuous batching, and streaming structured UX. Updated [[index]].

## [2026-04-28] ingest | Agent backend boundaries, architecture choice, and AI communication quality

Processed new raw sources:

- `raw/GPT-5.5 Agents Replaced My Python Backend. 83% Cost Cut.  by inprogrammer.md`
- `raw/Microservices vs. Monoliths When to Choose What (and Why It Matters).md`
- `raw/Skills for Real Engineers. Straight from my .claude directory.md`
- `raw/Stop Feeding Me AI Slop.md`

Added source summaries: [[sources/gpt-5-5-agents-replaced-python-backend|GPT-5.5 Agents Replaced My Python Backend]], [[sources/microservices-vs-monoliths|Microservices vs. Monoliths]], [[sources/agent-skills-real-engineers|Agent Skills for Real Engineers]], and [[sources/stop-feeding-me-ai-slop|Stop Feeding Me AI Slop]].

Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] with agent boundary and communication-quality notes, [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]] with monolith-vs-microservices guidance, [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] with shared-language and anti-slop rules, [[concepts/system-design-case-studies|System Design Case Studies]] with an agent-backed backend slice, [[concepts/reliability-and-operations|Reliability and Operations]] with agent observability notes, [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-04-28] maintenance | Link-check script

Added `scripts/check-wiki-links.ps1` so wiki link validation is a reusable command instead of an inline snippet in [[automation]]. Updated [[maintenance]] and `README.md` with the command.

## [2026-04-28] maintenance | LLM wiki source refinement

Re-read `llm-wiki.md` and expanded [[sources/llm-wiki-idea-file|LLM Wiki Idea File]] with the human/LLM role split, broader application areas, query-output formats, optional tooling, and practical Obsidian notes. Updated [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] and [[maintenance]] to reflect those operating details.

## [2026-04-28] ingest | Microservices source metadata refresh

Re-read `raw/Microservices vs. Monoliths When to Choose What (and Why It Matters).md`, added source metadata and missing operational details to [[sources/microservices-vs-monoliths|Microservices vs. Monoliths]], and linked its retry/circuit-breaker implications into [[concepts/reliability-and-operations|Reliability and Operations]].

## [2026-04-28] maintenance | Orphan-page lint script

Added `scripts/lint-wiki.ps1` to detect orphan wiki pages with no inbound links (excluding index/log/workflow/state pages). Updated [[automation]], [[maintenance]], and `README.md` with the command.

## [2026-05-02] ingest | Cloudflare Tunnel source

Processed new raw source:

- `raw/Create a tunnel (dashboard).md`

Added [[sources/create-tunnel-dashboard|Create a tunnel (dashboard)]] documenting Cloudflare Tunnel setup via Zero Trust dashboard. Connected to [[concepts/infrastructure-primitives|Infrastructure Primitives]] and [[concepts/reliability-and-operations|Reliability and Operations]]. Updated [[index]].

## [2026-05-05] ingest | Webpack tree shaking and tunnel refresh

Processed new/changed raw sources:

- `raw/Improving Site Performance With Webpack Tree Shaking.md`
- `raw/Create a tunnel (dashboard).md`

Added [[sources/webpack-tree-shaking-performance|Improving Site Performance With Webpack Tree Shaking]] and [[concepts/frontend-build-performance|Frontend Build Performance]] for ES module migration, tree shaking requirements, codemod review, and incremental performance rollout. Refreshed [[sources/create-tunnel-dashboard|Create a tunnel (dashboard)]] with current dashboard flow, published application/private network options, Access policy note, and connector health states. Updated [[concepts/infrastructure-primitives|Infrastructure Primitives]], [[concepts/reliability-and-operations|Reliability and Operations]], [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-05] ingest | Production AI, local LLMs, agent memory, containers, and frontend skills

Processed new raw sources:

- `raw/A FastAPI Update Broke My Production App. Here Is the Fix.  by inprogrammer  in Artificial Intelligence in Plain English.md`
- `raw/Beyond Shipped What Actually Breaks in Production AI.md`
- `raw/Claude Code Best Practices 12 Patterns Agentic Engineers Use  by huizhou92  in Level Up Coding.md`
- `raw/Docker Was Slowing My Deploys. Podman Fixed It in 45 Seconds.  by inprogrammer.md`
- `raw/How I Made a Desktop App Invisible to Screen Sharing (Electron + OS-Level Tricks).md`
- `raw/How to Secure and Optimize Docker images  Best Practices.md`
- `raw/I Deployed Local LLMs in Production for a Year. Part 1 The Mental Model  by Mustafa Genc  in AI Advances.md`
- `raw/I Deployed Local LLMs in Production for a Year. Part 2 The Operational Playbook  by Mustafa Genc  in AI Advances.md`
- `raw/RAG, LLM Wiki, or Gbrain -  How Your Agent Remembers Changes Everything.md`
- `raw/Stop Using the Wrong LLM  by Jose Crespo, PhD  in AI Advances.md`
- `raw/tech skills vs system design Unlock case study in Production.md`
- `raw/The 4 Cognitive Archetypes of Developers Using AI.md`
- `raw/Top Skills Frontend Developers Need in 2026 (Beyond React)  by Kevin - MERN Stack Developer.md`

Added source summaries for FastAPI migration risk, production AI failure modes, Claude Code practices, Podman deploys, Electron screen-capture protection, Docker image security, local LLM serving mental model and operations, RAG/wiki/GBrain memory architectures, LLM task-fit selection, the Unlock system-design case study, AI developer cognitive archetypes, and frontend skills beyond React.

Created [[concepts/local-llm-serving|Local LLM Serving]]. Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/reliability-and-operations|Reliability and Operations]], [[concepts/infrastructure-primitives|Infrastructure Primitives]], [[concepts/system-design|System Design]], [[concepts/system-design-case-studies|System Design Case Studies]], [[concepts/frontend-build-performance|Frontend Build Performance]], [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]], [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]], [[concepts/structured-learning-and-retention|Structured Learning and Retention]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-05] ingest | Claude folder structure and Unlock refresh

Processed new/changed raw sources:

- `raw/How to Structure .claude Folder for Maximum Efficiency.md`
- `raw/tech skills vs system design Unlock case study in Production.md`

Added [[sources/claude-folder-structure|How to Structure .claude Folder]] for Claude Code project structure: root instructions, `.claude/settings.json`, modular rules, hooks, commands, skills, agents, and local overrides. Refreshed [[sources/unlock-system-design-production|Unlock Production System Design Case Study]] with source publication metadata and a sharper note on the false dichotomy between implementation skill and system design. Updated [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]], [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-08] ingest | Remote AI, AI safety, wiki cadence, patterns, and lookup structures

Processed new raw sources:

- `raw/Enhance productivity with AI + Remote Dev.md`
- `raw/How To Build An AI Brain That Never Forgets.md`
- `raw/How to Use AI at Work Without Breaking Your Systems.md`
- `raw/Stop Memorizing Design Patterns Use This Decision Tree Instead  by Alina Kovtun✨  in Women in Technology.md`
- `raw/The Dictionary Problem Fast Lookups in Large Collections.md`

Added source summaries for AI-aware remote development, local AI brain architecture, workplace AI safety guardrails, design-pattern selection, and dictionary lookup data structures. Created [[concepts/software-design-patterns|Software Design Patterns]]. Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]], [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]], [[concepts/reliability-and-operations|Reliability and Operations]], [[concepts/data-storage-and-consistency|Data Storage and Consistency]], [[concepts/system-design|System Design]], [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]].

## [2026-05-09] ingest | Context-first AI coding and exception handling patterns

Processed new/changed raw sources:

- `raw/How I Get 100% Out of AI When Coding — The Workflow Nobody Taught Me  by Udara Abeythilake  in Level Up Coding.md`
- `raw/Junior Devs Use try-catch Everywhere. Senior Devs Use These 4 Exception Handling Patterns.md`
- `raw/Stop Memorizing Design Patterns Use This Decision Tree Instead  by Alina Kovtun✨  in Women in Technology.md` (changed)

Added new source summaries: [[sources/ai-coding-workflow-context-first|Context-First AI Coding Workflow]] and [[sources/exception-handling-patterns|Exception Handling Patterns Over Blanket try-catch]]. Refreshed [[sources/design-pattern-decision-tree|Stop Memorizing Design Patterns - Use This Decision Tree Instead]] with stronger decision-tree framing and applied scenarios.

Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/reliability-and-operations|Reliability and Operations]], [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]], and [[index]] to integrate planning-first AI execution and explicit expected-vs-exceptional failure handling.

## [2026-05-14] architecture | Project, wiki, GBrain, and sync architecture pass

Modified the project architecture across four layers:

- Added `docs/architecture/project-operating-architecture.md` as the canonical local operating architecture.
- Added [[concepts/project-operating-architecture|Project Operating Architecture]] to the wiki and linked it from [[index]].
- Updated [[automation]] so wiki maintenance ends by syncing the attached GBrain source `brain`.
- Updated `BRAIN_CONTEXT.md`, `SESSION_HANDOFF.md`, `GBRAIN_DEV_WORKFLOW.md`, and `AGENTS.md` with the new source-routing and handoff model.
- Refactored source-scoped sync/import so `sourceId` is carried into page, version, tag, and chunk writes instead of only being used for sync bookmarks.

Verification: `bun run typecheck` and `bun test --timeout 180000 test/sync.test.ts` passed.

## [2026-05-26] ingest | 23 new sources, software design patterns, and CLI/Git productivity

Processed 23 new raw sources:

- 10 no-code AI platforms, caching patterns, cheap code vs. judgment shift, end of legacy code through AI behavior testing, agent harness components, multi-agent frameworks (Kensho, Madrigal, Remote), Snapchat Bento prediction architecture, Netflix multimodal video search, and monolith-to-service migration patterns.
- Version control and terminal tips: effective Git (bisect, worktrees, reflogs, interactive staging) and terminal efficiency hacks.
- Google L7 system design URLs, Rust WAF firewalls, and active study roadmaps.

Created [[concepts/command-line-and-git-productivity|Command-Line and Git Productivity]].
Updated [[concepts/ai-era-software-engineering|AI-Era Software Engineering]], [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]], [[concepts/system-design|System Design]], [[concepts/system-design-case-studies|System Design Case Studies]], [[concepts/software-design-patterns|Software Design Patterns]], and [[index]].

Verification: Verified all links resolved and committed raw scanner state. Sync'd DB source `brain`.

## [2026-05-27] ingest & fix | Day 7 Ingestion, Sync Exclusions & Windows Test Fixes

Processed 1 new raw source:
- `raw/Learn System Design With Me . Day 7 Chain of Responsibility & State Patterns .  by The Latency Gambler.md`

Created [[sources/latency-gambler-day-7|Chain of Responsibility & State Patterns]] summary.
Updated [[concepts/software-design-patterns|Software Design Patterns]] with Chain of Responsibility and State Pattern descriptions, and linked Day 7.
Updated [[index]] to list the new source.

Fixed sync and test bugs:
- Added `test` and `tests` directories to the sync/import walkers to prevent indexing of test fixtures (resolved `SLUG_MISMATCH` blocks in `bun run pull`).
- Resolved Windows-specific path separator issues and skipped privilege-restricted symlink tests in `test/sync-walker-symlink.test.ts`.

Verification: Checked that `bun test test/sync-walker-symlink.test.ts` runs clean on Windows and `bun run pull` successfully completes.

## [2026-06-01] ingest | AI coding workflow, Dropbox Nova, LinkedIn search & FishDB deep dives

Processed 7 new raw sources:

- `raw/Beyond code generation rethinking engineering productivity in the age of AI agents.md`
- `raw/Building collaborative prompt engineering playgrounds using Jupyter Notebook.md`
- `raw/FishDB - a generic retrieval engine for scaling LinkedIn's feed.md`
- `raw/How Edison is helping us build a faster, more powerful Dropbox on the web.md`
- `raw/I'm a 10x Dev. Here's How I Use a $250Month LLM To Code 250% Faster Without Generating "Slop".md`
- `raw/Reimagining LinkedIn's search tech stack.md`
- `raw/The 58-Million-Key Freeze What a HashMap Resize Taught Us About Memory Allocation at Scale.md`

Added source summaries for Dropbox's Nova agent platform (1-in-12 PRs agent-produced, bottleneck shift from generation to review/testing), LinkedIn's collaborative Jupyter prompt engineering playgrounds, FishDB Rust-based feed retrieval engine, Dropbox Edison local-first sync engine for the web, structured LLM coding without slop, LinkedIn's GPU-accelerated semantic search rebuild, and the HashMap → `mmap_lock` → async runtime freeze case study at 58.7M keys.

Created [[concepts/fishdb|FishDB]] and [[concepts/local-first-architecture|Local-First Architecture]].

Updated **11 concept pages** with cross-source synthesis:

- [[concepts/system-design-case-studies|System Design Case Studies]] — added 5 new case studies: Dropbox Nova (agent platform), Dropbox Edison (local-first sync), FishDB (feed retrieval engine), LinkedIn semantic search (GPU EBR), HashMap freeze (cross-layer debugging).
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]] — added specialized index structures (B-tree, bit-sliced, inverted with skip lists), vector embeddings and EBR, client-side IndexedDB storage.
- [[concepts/infrastructure-primitives|Infrastructure Primitives]] — added storage engine design (document model, allocator interaction, async runtime coupling), client-side sync infrastructure.
- [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]] — added local-first communication patterns (BroadcastChannel, WebSocket sync, optimistic UI) and EBR pipeline stages.
- [[concepts/reliability-and-operations|Reliability and Operations]] — added traffic shaping/ranking controllers and conflict resolution/offline resilience.
- [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] — added bottleneck-shift, collaborative prompt engineering, structured LLM coding workflow, GPU semantic search sections.
- [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]] — added production agent platform section (Dropbox Nova, 4-stage measurement model).
- [[concepts/structured-learning-and-retention|Structured Learning and Retention]] — added speed-vs-retention tension in AI-assisted coding.
- [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]] — added collaborative notebooks as prompt engineering surface, agent-produced content as wiki source material.
- [[concepts/shared-engineering-language|Shared Engineering Language]] — added 5 new terms: bottleneck shift, slop, collaborative prompt engineering playground, local-first sync engine, Fuel→Adoption→Output→Impact.
- [[concepts/system-design|System Design]] — added deeper sub-concepts (FishDB, Local-First Architecture) and 4 new case study references.

Updated [[index]].

Deep content pass:
- Updated [[synthesis/software-engineering-learning-os|Software Engineering Learning OS]] with full synthesis of all 7 new sources — bottleneck-shift insight, local-first architecture, FishDB+Rust+Tokio case study, GPU semantic search, collaborative prompt engineering, cross-layer debugging. Added FishDB and Local-First Architecture to the system design study spine.
- Added concept-to-concept cross-links across 6 pages: `system-design` (sub-concept links), `infrastructure-primitives` (→ fishdb, local-first-architecture), `data-storage-and-consistency` (→ fishdb, local-first-architecture), `system-design-interview-workflow` (→ infrastructure-primitives, comm-patterns, case-studies), `frontend-build-performance` (→ system-design), `recurrent-depth-transformers` (→ ai-era-software-engineering, llm-maintained-wiki).
- Verified bidirectional integrity: all 77 sources referenced by ≥1 concept page, all concept pages reference ≥1 source (except project-operating-architecture, which is internal architecture).

Cross-reference pass over all 77 source summaries:
- Fixed orphan `electron-screen-capture-protection` → linked to [[concepts/reliability-and-operations|Reliability and Operations]].
- Expanded thin source references: `learn-from-course-content`, `llm-wiki-idea-file`, and all 7 new summaries now link to 3-6 concept pages each (was 1-2).
- Added missing source backlinks to `system-design-interview-workflow` (added `system-design-study-roadmap`, `google-l7-system-design`, `latency-gambler-day-1`).

## [2026-05-27] ingest | Day 8 and Day 9 Ingestion

Processed 2 new raw sources:
- `raw/Learn System Design With Me . Day 8 Load Balancing & Circuit Breaker….md`
- `raw/Learn System Design With Me . Day 9 Database Patterns & Repository P….md`

Created source summaries:
- [[sources/latency-gambler-day-8|Load Balancing & Circuit Breaker Patterns]]
- [[sources/latency-gambler-day-9|Database Patterns & Repository Pattern]]

Updated concept pages:
- [[concepts/reliability-and-operations|Reliability and Operations]] with load balancing strategies, circuit breaker states, and fallback resilience patterns.
- [[concepts/data-storage-and-consistency|Data Storage and Consistency]] with the Repository Pattern, Connection Pools, and Connection Factories.

Updated [[index]] to list the new sources.

