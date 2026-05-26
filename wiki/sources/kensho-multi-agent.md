---
title: "Kensho Financial Multi-Agent Retrieval Architecture"
type: source
created: 2026-05-26
source: https://www.langchain.com/blog/customers-kensho
published: 2026-03-27
tags:
  - source
---

# Kensho Financial Multi-Agent Retrieval Architecture

## Summary

Describes Kensho's design of 'Grounding,' a federated multi-agent routing system using LangGraph to unify and execute trusted data retrieval across structured financial datasets.

## Key Ideas

- Financial search requires high precision, necessitating search systems that retrieve data from highly structured, diverse tables rather than just web-text.
- The 'Grounding' framework uses a centralized RouterGraph to orchestrate requests, routing queries to specialized data agents.
- Custom communication protocols allow agents to query, respond, and pass execution metadata consistently across the network.
- Comprehensive LangGraph tracing enables end-to-end observability, which is critical for debugging complex, nested routing paths.
- Multi-stage evaluations measure router accuracy, checking routing decisions and tool-call correctness against exact-match datasets.

## Links

- Connects to [[concepts/system-design-case-studies|System Design Case Studies]]
- Connects to [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]
- Connects to [[concepts/communication-and-architecture-patterns|Communication and Architecture Patterns]]
