---
title: Self-Improving Agent Workflows
type: concept
created: 2026-04-28
tags:
  - concept
  - agents
  - automation
  - learning-loops
---

# Self-Improving Agent Workflows

Self-improving agent workflows capture feedback from human-agent sessions and convert repeated corrections into persistent instructions. The agent does not need true memory if the workflow writes lessons into files that future sessions read.

## Loop

1. Capture raw session signals.
2. Preserve human corrections, approvals, agent prompts, outputs, and skills used.
3. Wait until there are enough sessions to distinguish pattern from noise.
4. Ask an LLM worker to infer repeated mistakes.
5. Write concise rules to the most local useful place.
6. Load those lessons at the start of future work.

## Design Principles

- Human corrections are ground truth.
- Do not overfit to a single session.
- Keep lessons short and behavioral.
- Put global rules in global files and agent-specific rules near the relevant agent.
- Separate raw capture from later interpretation.

## Relevance to This Wiki

This wiki uses the same basic pattern at the knowledge-base level. Raw sources are captured in `raw/`; the maintained lessons live in `wiki/`; [[automation]] and [[maintenance]] define how future runs keep the system current. The daily auto-update job is a simpler cousin of the hook workflow: scan for new signal, integrate it into durable markdown, and preserve the result for future sessions.

## Skills and Hooks

Agent workflows become more reliable when recurring behavior is encoded as commands, skills, hooks, and permission-bounded agents. Hooks can run formatting, guard risky actions, and verify completion. Skills are most useful when they capture tested gotchas and operational protocol rather than generic explanations. Fat-skill systems go further by letting workflows run on triggers or schedules and file the results back into persistent memory.

## Agent Harnesses and Execution Sandboxes

Autonomous agents require an execution harness to turn base intelligence into functional work engines. Key components of an agent harness include:
- **Filesystem Primitives**: Serving as a workspace, coordinate state area, and git-managed integration space.
- **Sandboxed Execution**: Using secure environments (like WebAssembly or Docker containers) to run LLM-generated code (e.g. Pandas operations) and prevent arbitrary code execution on host machines.
- **Context Rot Mitigation**: Compacting context, offloading tool payloads, and employing progressive tool disclosure (skills).
- **Federated Multi-Agent Routing**: Routing complex tasks to specialized subagents using directed state graphs (such as LangGraph Routing/Grounding) with custom protocols and schemas to isolate concerns.
- **Skill Normalization**: Abstracting all data sources and capabilities into swappable, modular tools to allow new capabilities to scale without rewriting main orchestrators.

## Project Operating Layer

A maintainable agent setup needs a clear filesystem shape. Keep global project context in a compact root instruction file, keep operational controls in obvious settings files, and move specialized guidance into modular rule files. Commands, hooks, skills, and agents should each have a distinct home so reusable behavior can grow without turning the main instruction file into an overloaded prompt dump.

## Environment-Aware Automation

Remote and containerized development environments can carry their own agent instructions. This lets an assistant know which toolchains are installed, which commands are safe, and what kind of machine it is operating in. The same principle applies to wiki automation: preserve durable rules near the workspace and use logs or queues so scheduled jobs coordinate instead of re-discovering state each run.

## Source Support

- [[sources/self-evolving-hooks|Self-Evolving Hooks]]
- [[sources/claude-code-best-practices|Claude Code Best Practices]]
- [[sources/claude-folder-structure|How to Structure .claude Folder]]
- [[sources/rag-llm-wiki-gbrain|RAG, LLM Wiki, or GBrain]]
- [[sources/ai-remote-development|Enhance Productivity with AI + Remote Dev]]
- [[sources/ai-brain-never-forgets|How To Build An AI Brain That Never Forgets]]
- [[sources/anatomy-agent-harness|Anatomy of an AI Agent Harness]]
- [[sources/kensho-multi-agent|Kensho Financial Multi-Agent Retrieval Architecture]]
- [[sources/madrigal-multi-agent|Madrigal Pharmaceuticals Agentic Research Platform]]

