---
title: "Madrigal Pharmaceuticals Agentic Research Platform"
type: source
created: 2026-05-26
source: https://www.langchain.com/blog/customers-madrigal
published: 2026-04-29
tags:
  - source
---

# Madrigal Pharmaceuticals Agentic Research Platform

## Summary

Details how Madrigal Pharmaceuticals built a modular, multi-agent platform using LangChain, LangGraph, and LangSmith to accelerate clinical data synthesis and drug research workflows.

## Key Ideas

- Scaling agent platforms requires abstracting data sources into standardized tool interfaces, decoupling orchestration logic from raw data ingestion.
- Structuring capabilities as swappable, modular skills enables fast configuration of new research workflows without modifying orchestrators.
- LangSmith tracing provides transparency into model decisions, tool calls, and data retrievals, accelerating the move from prototype to production.
- Managed deployment containers host agents as microservices, allowing separate research teams to invoke agent skills via APIs.
- Evaluative feedback loops capture production errors, converting them into assertions and regression tests to improve system reliability.

## Links

- Connects to [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]
- Connects to [[concepts/system-design-case-studies|System Design Case Studies]]
- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
