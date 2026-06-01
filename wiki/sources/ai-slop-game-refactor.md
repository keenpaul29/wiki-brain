---
title: "Scrubbing AI Slop From a Game Codebase"
type: source
created: 2026-06-01
source: https://medium.com/according-to-context/how-i-scrubbed-100-of-the-ai-slop-from-my-game-cut-code-by-45-1d1f99b564c1
tags:
  - source
---

# Scrubbing AI Slop From a Game Codebase

## Summary

This article is a firsthand account of reducing an LLM-assisted Godot game codebase from 191,000 tokens to 104,000 tokens by removing generated comments, excessive instrumentation, and architecture drift. The stronger lesson is not "avoid LLMs," but that LLM coding requires human-owned architecture, complete context, explicit anti-pattern rules, and repeated review.

## Key Ideas

- **Comment slop**: Generated comments mostly restated code or encoded prompt-debugging artifacts. The useful exception was human-written comments that prevent repeated bugs or explain non-obvious ordering constraints.
- **Instrumentation slop**: LLM-added `print` statements initially helped debugging but eventually obscured logic and hurt runtime behavior.
- **Context omission multiplies architecture drift**: When the state chart file dropped out of the prompt bundle, the model did not ask for it; it generated new behavior outside the intended state-machine architecture.
- **Vibe architecture**: The author identifies unnecessary signals, duplicated state, race-prone startup sequencing, and scattered input handlers as LLM-amplified anti-patterns.
- **Anti-slop pillars**: Each discovered failure mode was turned into a durable rule in the context document, making future review easier and reducing repeated mistakes.
- **Human planning remains the boundary**: The author argues that LLMs can still accelerate implementation, but the engineer must own UI behavior, state charts, constraints, and final code review.

## Links

- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
- Connects to [[concepts/software-design-patterns|Software Design Patterns]]
- Connects to [[sources/dont-outsource-learning|Don't Outsource the Learning]]
- Connects to [[sources/ai-coding-workflow-context-first|Context-First AI Coding Workflow]]

