---
title: Agent Skills for Real Engineers
type: source
created: 2026-04-28
tags:
  - source
  - agents
  - workflow
  - software-engineering
---

# Agent Skills for Real Engineers

## Summary

This source presents a small, composable skill system for coding agents. Its premise is that large agentic process frameworks can remove too much engineer control, while focused skills can correct common failure modes without hiding the work. The most important failure modes named are agent-user misalignment and verbose output caused by missing shared domain language.

The proposed remedy is to make agents ask sharper questions before implementation, capture project terminology in a shared context document, and record durable architecture decisions. This fits the wiki's existing pattern: transient interaction becomes persistent context that future agent sessions can reuse.

## Key Ideas

- Agent workflows should improve alignment before coding, not just accelerate implementation.
- Shared language documents reduce repeated explanation and help agents use project-specific terms correctly.
- ADRs preserve hard-to-explain decisions so later sessions have design continuity.
- Small skills are easier to audit, adapt, and compose than broad end-to-end agent frameworks.
- Skills can encode engineering loops such as diagnosis, TDD, issue slicing, and architecture review.

## Links

- Supports [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]
- Connects to [[concepts/llm-maintained-wiki|LLM-Maintained Wiki]]
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
