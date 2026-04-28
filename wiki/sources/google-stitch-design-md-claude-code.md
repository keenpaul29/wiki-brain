---
title: Google Stitch design.md + Claude Code
type: source
created: 2026-04-28
source_path: raw/How to Use Google Stitch's Design.md File with Claude Code for Consistent UI.md
tags:
  - source
  - design-systems
  - agents
  - ui
---

# Google Stitch design.md + Claude Code

## Summary

This source describes Google Stitch's `design.md` export: a single Markdown file that captures a UI design system (colors, typography, spacing scale, layout, components, radii, shadows) in a structured, LLM-readable format. The claim is that giving an agent a stable design reference reduces UI drift across generations (e.g., buttons vs cards suddenly changing spacing or color choices).

It positions `design.md` as "design tokens as plain text": easy for LLMs to parse, version-control friendly, and portable across agent tools. A practical workflow is: generate a design system in Stitch, export `design.md`, place it in the repo, and add project-level agent instructions (e.g., Claude Code's `CLAUDE.md`) that tell the agent to follow the file strictly.

The source also suggests turning the tokens into implementation constraints (e.g., Tailwind/theme config) so that even if an agent drifts, the codebase enforces consistency.

## Key Ideas

- Put the design system in an agent-readable file, not only in prompts.
- Markdown works as a lowest-common-denominator spec format for LLM tools.
- Combine "spec in context" (`design.md`) with "enforced constraints" (theme/config) to reduce drift.
- Treat UI generation as a multi-step workflow: spec → code → audit.

## Links

- Supports [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Connects to [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]]
- Connects to [[automation]]

