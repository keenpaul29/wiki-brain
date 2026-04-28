---
title: Self-Evolving Hooks
type: source
created: 2026-04-28
source_path: raw/Self-Evolving Hooks.md
tags:
  - source
  - agents
  - automation
  - learning-loops
---

# Self-Evolving Hooks

## Summary

This source describes a Claude Code workflow where hooks capture user corrections from sessions and turn repeated corrections into persistent rules that are loaded into future sessions. The goal is to get "self-improving agents" without relying on model memory or manual prompt tuning.

The system has three moving parts:

- A subagent-start hook loads global and agent-specific lessons before an agent runs (printed into the agent context).
- A stop hook captures session observations as small JSON records (human messages, agents run, skills read, prompt/output previews).
- A background "dream" worker reviews recent observations, detects repeated correction patterns, and writes concise rules into the closest useful file (global, agent-specific, or skill-specific).

The key design insight is that user corrections are high-quality supervision. If the user repeatedly says "not like that," the workflow should preserve that signal somewhere the agent reads next time.

## Key Ideas

- Session transcripts contain feedback signals that are otherwise lost.
- Repeated corrections are stronger evidence than one-off complaints.
- Lessons should be written as short, concrete rules.
- Agent-specific lessons should live close to the agent or skill that caused the mistake.
- The workflow separates capture from interpretation: hooks collect raw observations, and an LLM later infers patterns and writes lessons.

## Links

- Supports [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]
- Connects to [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]]
- Connects to [[maintenance]]
- Connects to [[automation]]
