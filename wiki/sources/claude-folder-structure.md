---
title: How to Structure .claude Folder
type: source
created: 2026-05-05
source: https://substack.com/home/post/p-193360884
author: Youssef Hosni
published: 2026-04-06
tags:
  - source
  - agents
  - claude-code
  - workflow
---

# How to Structure .claude Folder

## Summary

This source argues that `.claude/` should be treated as a project operating layer, not a dumping ground for prompts and scripts. The recommended structure separates global project guidance, operational controls, modular rules, hooks, reusable commands, skills, agents, and personal local overrides.

## Key Ideas

- Keep `CLAUDE.md` as the root-level entry point for broad project context: stack, architecture, core commands, conventions, and constraints.
- Keep `.claude/settings.json` easy to find because it controls permissions, hooks, and project-level Claude Code behavior.
- Move narrow or area-specific instructions into `.claude/rules/` so frontend, backend, testing, migration, or security guidance can evolve independently.
- Use `.claude/hooks/`, `.claude/commands/`, `.claude/skills/`, and `.claude/agents/` for automation, repeatable workflows, packaged capabilities, and specialized subagents.
- Separate shared team structure from local personal overrides such as `CLAUDE.local.md` or `.claude/settings.local.json`.
- The source emphasizes clarity over size: every file should have a purpose, and the top level should stay intentionally small.

## Links

- Connects to [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]] (persistent rules, hooks, skills, and agents)
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]] (project structure as agent alignment)
- Connects to [[sources/claude-code-best-practices|Claude Code Best Practices]] (related Claude Code operating patterns)
