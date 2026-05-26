# GBrain Architecture

This directory is the canonical architecture reference for the GBrain application.
It explains the mental model, runtime layers, and operating boundaries that every
contributor and agent should understand before changing the code or the wiki.

## Core architecture docs

- `brains-and-sources.md` — the two-axis mental model of brains (databases) and
  sources (repos inside a brain). This is the primary routing contract for
  `gbrain --brain`, `gbrain --source`, dotfiles, and source-aware sync.
- `project-operating-architecture.md` — the repository's dual role as a GBrain
  app source tree and an LLM-maintained markdown wiki. It explains the source
  database layer, wiki layer, codebase contracts, and agent handoff rules.
- `self-growing-brain.md` — how the local wiki, source sync, and nightly
  automation combine into a continuously learning brain.
- `infra-layer.md` — the core data pipeline, search architecture, schema overview,
  and the thin-harness / fat-skills separation.
- `topologies.md` — example deployment topologies for personal brains, team
  brains, and CEO-class multi-brain users.

## Why this matters

GBrain's architecture is intentionally layered:

1. Database and source boundaries are the first design decision.
2. Deterministic runtime code is the second.
3. LLM-facing skills and agents are the third.

Keeping these boundaries clear prevents cross-brain leakage, accidental source
miswrites, and skills that depend on undocumented engine behavior.

## Recommended reading order

1. `brains-and-sources.md`
2. `project-operating-architecture.md`
3. `infra-layer.md`
4. `topologies.md`

## Suggested improvements

- Keep this directory focused on architecture and avoid adding implementation
  details that belong in `docs/guides/` or `README.md`.
- When architecture changes, update this landing page and the relevant doc.
- If a new layer is introduced, add a new section here first.
