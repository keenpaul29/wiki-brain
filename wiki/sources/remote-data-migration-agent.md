---
title: "Remote Data Migration Agentic Architecture"
type: source
created: 2026-05-26
source: https://www.langchain.com/blog/customers-remote
published: 2026-01-19
tags:
  - source
---

# Remote Data Migration Agentic Architecture

## Summary

Details Remote's design of a Code Execution Agent using LangChain and LangGraph to automate massive payroll and HR spreadsheet migrations into structured schema formats.

## Key Ideas

- Standard LLMs cannot directly ingest large spreadsheets or database tables due to context windows and hallucination risks.
- Remote's system separates planning (LLM reasoning and tool selection) from execution (deterministic sandboxed Python code run).
- LLM-generated code runs in a secure WebAssembly sandbox utilising data science libraries (Pandas) to load, clean, and map data.
- Large data volumes stay inside the sandbox environment; only high-level schemas and execution summaries return to the LLM.
- Workflows are mapped as a directed state graph in LangGraph, establishing explicit success, fail, and retry nodes for each stage.

## Links

- Connects to [[concepts/self-improving-agent-workflows|Self-Improving Agent Workflows]]
- Connects to [[concepts/system-design-case-studies|System Design Case Studies]]
- Connects to [[concepts/ai-era-software-engineering|AI-Era Software Engineering]]
